local S, L, O, U, D, E = unpack(select(2, ...));
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
local C_QuestLog_UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest;
local C_TooltipInfo_GetUnit, TooltipUtil_SurfaceArgs = C_TooltipInfo.GetUnit, TooltipUtil.SurfaceArgs;
local TooltipUtil_FindLinesFromData = TooltipUtil.FindLinesFromData;
local Enum_TooltipDataLineType_QuestTitle, Enum_TooltipDataLineType_QuestObjective = Enum.TooltipDataLineType.QuestTitle, Enum.TooltipDataLineType.QuestObjective;

-- Stripes API
local IsNameOnlyModeAndFriendly = Stripes.IsNameOnlyModeAndFriendly;

-- Nameplates
local NP = S.NamePlates;

local PlayerState = D.Player.State;

-- Local Config
local ENABLED, POSITION;

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
    if not C_QuestLog_UnitIsRelatedToActiveQuest(unit) then
        return;
    end

    local tooltipData = C_TooltipInfo_GetUnit(unit);

    if not tooltipData then
        return;
    end

    TooltipUtil_SurfaceArgs(tooltipData);

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

    if not ENABLED or not unit or unitframe.data.isPersonal or PlayerState.inChallenge then
        unitframe.QuestIndicator:Hide();
        return;
    end

    local progressGlob, questType, objectiveCount, questLogIndex, questId = GetQuestProgress(unit);
    if progressGlob and questType then
        unitframe.QuestIndicator.counterText:SetText(objectiveCount > 0 and objectiveCount or '?');

        if questType == 1 then
            unitframe.QuestIndicator.counterText:SetTextColor(1, 1, 1);
        elseif questType == 2 then
            unitframe.QuestIndicator.counterText:SetTextColor(1, 0.42, 0.3);
        elseif questType == 3 then
            unitframe.QuestIndicator.counterText:SetTextColor(0.15, 0.65, 1);
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
        end

        if lootIconShow then
            unitframe.QuestIndicator.swordIcon:Hide();
            unitframe.QuestIndicator.lootIcon:Show();
            unitframe.QuestIndicator.counterText:SetPoint('CENTER', unitframe.QuestIndicator.lootIcon, 'CENTER', 1, -3);
        else
            unitframe.QuestIndicator.swordIcon:Show();
            unitframe.QuestIndicator.lootIcon:Hide();
            unitframe.QuestIndicator.counterText:SetPoint('CENTER', unitframe.QuestIndicator.swordIcon, 'CENTER', -2, -2);
        end

        unitframe.QuestIndicator:Show();
    else
        unitframe.QuestIndicator:Hide();
    end
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

    frame.swordIcon = frame:CreateTexture(nil, 'BORDER', nil, 0);

    if POSITION == 1 then
        frame.swordIcon:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -2, 0);
    else
        frame.swordIcon:SetPoint('BOTTOMLEFT', frame, 'BOTTOMRIGHT', 4, 0);
    end

    frame.swordIcon:SetSize(16, 16);
    frame.swordIcon:SetTexture(S.Media.Icons2.TEXTURE);
    frame.swordIcon:SetTexCoord(unpack(S.Media.Icons2.COORDS.ROUNDSHIELD_SWORD));

    frame.lootIcon = frame:CreateTexture(nil, 'BORDER', nil, 1);
    frame.lootIcon:SetPoint('BOTTOMLEFT', frame.swordIcon, 'BOTTOMLEFT', -3, 0);
    frame.lootIcon:SetSize(16, 16);
    frame.lootIcon:SetTexture(S.Media.Icons2.TEXTURE);
    frame.lootIcon:SetTexCoord(unpack(S.Media.Icons2.COORDS.LOOT));
    frame.lootIcon:Hide();

    frame.counterText = frame:CreateFontString(nil, 'OVERLAY');
    frame.counterText:SetFont(S.Media.Fonts['Systopie Bold'], 8, 'OUTLINE');
    frame.counterText:SetJustifyH('CENTER');
    frame.counterText:SetShadowOffset(1, -1);
    frame.counterText:SetTextColor(1, 1, 1);

    unitframe.QuestIndicator = frame;
end

local function UpdateStyle(unitframe)
    unitframe.QuestIndicator:ClearAllPoints();

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
        unitframe.QuestIndicator:SetAllPoints(unitframe.name);
    else
        unitframe.QuestIndicator:SetAllPoints(unitframe.healthBar);
    end

    unitframe.QuestIndicator.swordIcon:ClearAllPoints();

    if POSITION == 1 then
        unitframe.QuestIndicator.swordIcon:SetPoint('BOTTOMRIGHT', unitframe.QuestIndicator, 'BOTTOMLEFT', -2, 0);
        unitframe.QuestIndicator.lootIcon:SetPoint('BOTTOMLEFT', unitframe.QuestIndicator.swordIcon, 'BOTTOMLEFT', -1, 0);
    else
        unitframe.QuestIndicator.swordIcon:SetPoint('BOTTOMLEFT', unitframe.QuestIndicator, 'BOTTOMRIGHT', 4, 0);
        unitframe.QuestIndicator.lootIcon:SetPoint('BOTTOMLEFT', unitframe.QuestIndicator.swordIcon, 'BOTTOMLEFT', -3, 0);
    end
end

local function UpdateQuestLogIndexCache()
    table_wipe(QuestLogIndexCache);

    for i = 1, C_QuestLog_GetNumQuestLogEntries() do
        local info = C_QuestLog_GetInfo(i);
        if info and not info.isHeader then
            QuestLogIndexCache[info.title] = i;
        end
    end

    for _, unitframe in pairs(NP) do
        if unitframe.isActive and unitframe:IsShown() then
            Update(unitframe, unitframe.data.unit);
        end
    end
end

local function UnitQuestLogChanged(unit)
    if unit == 'player' then
        UpdateQuestLogIndexCache();
    else
        for _, unitframe in pairs(NP) do
            if unitframe.isActive and unitframe:IsShown() then
                Update(unitframe);
            end
        end
    end
end

local function QuestChanged(questID)
    if questID and C_QuestLog_IsQuestTask(questID) then
        local questName = C_TaskQuest_GetQuestInfoByQuestID(questID);
        if questName then
            QuestActiveCache[questName] = questID;
        end
    end

    UnitQuestLogChanged();
end

local function QuestRemoved(questID)
    local questName = C_TaskQuest_GetQuestInfoByQuestID(questID);
    if questName and QuestActiveCache[questName] then
        QuestActiveCache[questName] = nil;
    end

    UnitQuestLogChanged();
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

    local uiMapID = C_Map.GetBestMapForUnit('player');

    if not uiMapID then
        return;
    end

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

function Module:UpdateLocalConfig()
    ENABLED  = O.db.quest_indicator_enabled;
    POSITION = O.db.quest_indicator_position;
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('QUEST_ACCEPTED', QuestChanged);
    self:RegisterEvent('QUEST_REMOVED', QuestRemoved);
    self:RegisterEvent('QUEST_LOG_UPDATE', UpdateQuestLogIndexCache);
    self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', QuestChanged);
    self:RegisterEvent('UNIT_QUEST_LOG_CHANGED', UnitQuestLogChanged);
end