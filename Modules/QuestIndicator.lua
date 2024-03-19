local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('QuestIndicator');
local Stripes = S:GetNameplateModule('Handler');

-- Based on QuestPlates (semlar) and KuiNameplates (Quest element) (kesavaa)
-- https://www.curseforge.com/wow/addons/questplates
-- https://www.curseforge.com/wow/addons/kuinameplates

-- Lua API
local pairs, tonumber, math_ceil, string_match, table_wipe = pairs, tonumber, math.ceil, string.match, wipe;

-- WoW API
local C_TaskQuest_GetQuestProgressBarInfo, C_QuestLog_GetQuestObjectives, C_QuestLog_GetQuestIDForLogIndex = C_TaskQuest.GetQuestProgressBarInfo, C_QuestLog.GetQuestObjectives, C_QuestLog.GetQuestIDForLogIndex;
local C_QuestLog_GetNumQuestLogEntries, C_QuestLog_GetInfo, C_QuestLog_IsQuestTask, C_TaskQuest_GetQuestInfoByQuestID = C_QuestLog.GetNumQuestLogEntries, C_QuestLog.GetInfo, C_QuestLog.IsQuestTask, C_TaskQuest.GetQuestInfoByQuestID;
local C_TooltipInfo_GetUnit = C_TooltipInfo.GetUnit;
local TooltipUtil_FindLinesFromData = TooltipUtil.FindLinesFromData;
local Enum_TooltipDataLineType_QuestTitle, Enum_TooltipDataLineType_QuestObjective = Enum.TooltipDataLineType.QuestTitle, Enum.TooltipDataLineType.QuestObjective;

-- Stripes API
local UpdateFontObject = Stripes.UpdateFontObject;

local PlayerState = D.Player.State;

-- Local Config
local ENABLED, POSITION;

local StripesQuestIndicatorFont = CreateFont('StripesQuestIndicatorFont');

local QuestActiveCache, QuestLogIndexCache = {}, {};

local SEARCH_PATTERN_AB = '(%d+)/(%d+)';
local SEARCH_PATTERN_PROGRESS = '%((%d+)%%%)';

local LOOT_TYPES = {
    ['item']   = true,
    ['object'] = true,
};

local questLines = {
    Enum_TooltipDataLineType_QuestTitle,
    Enum_TooltipDataLineType_QuestObjective,
};

local function GetQuestProgress(unit)
    local tooltipData = C_TooltipInfo_GetUnit(unit);

    if not tooltipData then
        return;
    end

    local lines = TooltipUtil_FindLinesFromData(questLines, tooltipData);

    if #lines == 0 then
        return;
    end

    local progressGlob, questType, questLogIndex, questId, questName;
    local objectiveCount = 0;

    for i = 1, #lines do
        local line = lines[i];

        if line.type == Enum_TooltipDataLineType_QuestTitle then
            questId   = questId   or line.id;
            questName = questName or line.leftText;
        elseif line.type == Enum_TooltipDataLineType_QuestObjective then
            local objText = line.leftText;

            if objText then
                local a, b = string_match(objText, SEARCH_PATTERN_AB);
                a, b = tonumber(a), tonumber(b);

                if a and b then
                    local numLeft = b - a;
                    if numLeft > objectiveCount then
                        objectiveCount = numLeft;
                    end
                else
                    questId = questId or (questName and QuestActiveCache[questName]);
                    questType = 3;

                    a = string_match(objText, SEARCH_PATTERN_PROGRESS);
                    a = tonumber(a);

                    if a and a <= 100 then
                        return objText, questType, math_ceil(100 - a), questId;
                    end
                end

                if not a or (a and b and a ~= b) then
                    progressGlob = progressGlob and progressGlob .. '\n' .. objText or objText;
                end
            else
                if questName then
                    if QuestActiveCache[questName] then
                        questId = questId or QuestActiveCache[questName];
                        local progress = C_TaskQuest_GetQuestProgressBarInfo(questId);
                        if progress then
                            questType = 3;
                            return questName, questType, math_ceil(100 - progress), questId;
                        end
                    elseif QuestLogIndexCache[questName] then
                        questLogIndex = QuestLogIndexCache[questName];
                    end
                end
            end
        end
    end

    return progressGlob, progressGlob and 1 or questType, objectiveCount, questLogIndex, questId;
end

local function Update(unitframe, unit)
    unit = unit or unitframe.data.unit;

    if not ENABLED or not unit or unitframe.data.isPersonal or PlayerState.inChallenge or PlayerState.inPvPInstance or PlayerState.inArena then
        unitframe.QuestIndicator:Hide();
        return;
    end

    local questIndicator = unitframe.QuestIndicator;
    local progressGlob, questType, objectiveCount, questLogIndex, questId = GetQuestProgress(unit);

    if not (progressGlob and questType) then
        questIndicator:Hide();
        return;
    end

    questIndicator.counterText:SetText(objectiveCount > 0 and objectiveCount or '?');

    if questType == 1 then
        questIndicator.counterText:SetTextColor(1, 1, 1);
    elseif questType == 2 then
        questIndicator.counterText:SetTextColor(1, 0.42, 0.3);
    elseif questType == 3 then
        questIndicator.counterText:SetTextColor(0.15, 0.65, 1);
    end

    local lootIconShow = false;

    if questId then
        local objectives = C_QuestLog_GetQuestObjectives(questId);
        if objectives then
            for _, objectiveInfo in pairs(objectives) do
                if not objectiveInfo.text then
                    break;
                end

                if not objectiveInfo.finished then
                    if LOOT_TYPES[objectiveInfo.type] then
                        lootIconShow = true;
                        break;
                    end
                end
            end
        end
    elseif questLogIndex then
        questId = C_QuestLog_GetQuestIDForLogIndex(questLogIndex);
        local objectives = questId and C_QuestLog_GetQuestObjectives(questId);
        if objectives then
            for _, objectiveInfo in pairs(objectives) do
                if not objectiveInfo.text then
                    break;
                end

                if not objectiveInfo.finished then
                    if LOOT_TYPES[objectiveInfo.type] then
                        lootIconShow = true;
                        break;
                    end
                end
            end
        end
    end

    if lootIconShow then
        questIndicator.swordIcon:Hide();
        questIndicator.lootIcon:Show();
        questIndicator.counterText:SetPoint('CENTER', questIndicator.lootIcon, 'CENTER', 1, -3);
    else
        questIndicator.swordIcon:Show();
        questIndicator.lootIcon:Hide();
        questIndicator.counterText:SetPoint('CENTER', questIndicator.swordIcon, 'CENTER', -2, -2);
    end

    questIndicator:Show();
end

local function Create(unitframe)
    if unitframe.QuestIndicator then
        return;
    end

    local frame = CreateFrame('Frame', '$parentQuestIndicator', unitframe);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameStrata('HIGH');
    frame:SetFrameLevel(frame:GetFrameLevel() + 50);
    frame:Hide();

    local swordIcon = frame:CreateTexture(nil, 'BORDER', nil, 0);
    swordIcon:SetSize(16, 16);
    swordIcon:SetTexture(S.Media.Icons2.TEXTURE);
    swordIcon:SetTexCoord(unpack(S.Media.Icons2.COORDS.ROUNDSHIELD_SWORD));

    local lootIcon = frame:CreateTexture(nil, 'BORDER', nil, 1);
    lootIcon:SetPoint('BOTTOMLEFT', swordIcon, 'BOTTOMLEFT', -3, 0);
    lootIcon:SetSize(16, 16);
    lootIcon:SetTexture(S.Media.Icons2.TEXTURE);
    lootIcon:SetTexCoord(unpack(S.Media.Icons2.COORDS.LOOT));
    lootIcon:Hide();

    local counterText = frame:CreateFontString(nil, 'OVERLAY', 'StripesQuestIndicatorFont');
    counterText:SetJustifyH('CENTER');

    frame.swordIcon   = swordIcon;
    frame.lootIcon    = lootIcon;
    frame.counterText = counterText;

    unitframe.QuestIndicator = frame;
end

local function UpdateStyle(unitframe)
    local questIndicator = unitframe.QuestIndicator;

    questIndicator:ClearAllPoints();

    if Stripes.NameOnly:IsUnitFrameFriendly(unitframe) then
        questIndicator:SetAllPoints(unitframe.name);
    else
        questIndicator:SetAllPoints(unitframe.healthBar);
    end

    questIndicator.swordIcon:ClearAllPoints();

    if POSITION == 1 then
        questIndicator.swordIcon:SetPoint('BOTTOMRIGHT', questIndicator, 'BOTTOMLEFT', -2, 0);
        questIndicator.lootIcon:SetPoint('BOTTOMLEFT', questIndicator.swordIcon, 'BOTTOMLEFT', -1, 0);
    else
        questIndicator.swordIcon:SetPoint('BOTTOMLEFT', questIndicator, 'BOTTOMRIGHT', 4, 0);
        questIndicator.lootIcon:SetPoint('BOTTOMLEFT', questIndicator.swordIcon, 'BOTTOMLEFT', -3, 0);
    end
end

function Module:UpdateQuestLogIndexCache()
    table_wipe(QuestLogIndexCache);

    for i = 1, C_QuestLog_GetNumQuestLogEntries() do
        local info = C_QuestLog_GetInfo(i);
        if info and not info.isHeader then
            QuestLogIndexCache[info.title] = i;
        end
    end

    self:ForAllActiveAndShownUnitFrames(Update);
end

function Module:UnitQuestLogChanged(unit)
    if unit == 'player' then
        self:UpdateQuestLogIndexCache();
    else
        self:ForAllActiveAndShownUnitFrames(Update);
    end
end

function Module:QuestChanged(questID)
    if questID and C_QuestLog_IsQuestTask(questID) then
        local questName = C_TaskQuest_GetQuestInfoByQuestID(questID);
        if questName then
            QuestActiveCache[questName] = questID;
        end
    end

    self:UnitQuestLogChanged();
end

function Module:QuestRemoved(questID)
    local questName = C_TaskQuest_GetQuestInfoByQuestID(questID);
    if questName and QuestActiveCache[questName] then
        QuestActiveCache[questName] = nil;
    end

    self:UnitQuestLogChanged();
end

function Module:UpdateQuestActive()
    local uiMapID = C_Map.GetBestMapForUnit('player');

    if not uiMapID then
        return;
    end

    table_wipe(QuestActiveCache);

    for _, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
        if task.inProgress then
            local questID = task.questId;
            local questName = C_TaskQuest_GetQuestInfoByQuestID(questID);

            if questName then
                QuestActiveCache[questName] = questID;
            end
        end
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.QuestIndicator then
        unitframe.QuestIndicator:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateStyle(unitframe);
end

function Module:PLAYER_LOGIN()
    C_CVar.SetCVar('showQuestTrackingTooltips', 1); -- !!!
end

function Module:UpdateLocalConfig()
    ENABLED  = O.db.quest_indicator_enabled;
    POSITION = O.db.quest_indicator_position;

    UpdateFontObject(StripesQuestIndicatorFont, O.db.quest_indicator_font_value, O.db.quest_indicator_font_size, O.db.quest_indicator_font_flag, O.db.quest_indicator_font_shadow);

    if ENABLED then
        self:RegisterEvent('QUEST_ACCEPTED', 'QuestChanged');
        self:RegisterEvent('QUEST_REMOVED', 'QuestRemoved');
        self:RegisterEvent('QUEST_LOG_UPDATE', 'UpdateQuestLogIndexCache');
        self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', 'QuestChanged');
        self:RegisterEvent('UNIT_QUEST_LOG_CHANGED', 'UnitQuestLogChanged');

        self:UpdateQuestLogIndexCache();
        self:UpdateQuestActive();
    else
        self:UnregisterEvent('QUEST_ACCEPTED');
        self:UnregisterEvent('QUEST_REMOVED');
        self:UnregisterEvent('QUEST_LOG_UPDATE');
        self:UnregisterEvent('QUEST_WATCH_LIST_CHANGED');
        self:UnregisterEvent('UNIT_QUEST_LOG_CHANGED');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:RegisterEvent('PLAYER_LOGIN');
end