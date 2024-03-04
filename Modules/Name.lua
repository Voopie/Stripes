local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Name');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local string_format, string_gsub, string_gmatch = string.format, string.gsub, string.gmatch;
local strlenutf8 = strlenutf8;

-- WoW API
local UnitSelectionColor = UnitSelectionColor;

-- Stripes API
local ShouldShowName = Stripes.ShouldShowName;
local IsNameOnlyMode = Stripes.IsNameOnlyMode;
local IsNameOnlyModeAndFriendly = Stripes.IsNameOnlyModeAndFriendly;
local UpdateFontObject = Stripes.UpdateFontObject;
local GetCachedName = Stripes.GetCachedName;
local U_utf8sub, U_firstUpper, U_firstLower = U.UTF8SUB, U.FirstToUpper, U.FirstToLower;
local U_UnitIsTapped, U_GetUnitArenaId, U_GetNpcSubLabelByID = U.UnitIsTapped, U.GetUnitArenaId, U.GetNpcSubLabelByID;

local PlayerState = D.Player.State;

-- Libraries
local LT = S.Libraries.LT;
local LDC = S.Libraries.LDC;

-- Local Config
local POSITION, POSITION_V, OFFSET_X, OFFSET_Y, TRUNCATE, ABBR_ENABLED, ABBR_MODE, ABRR_UNIT_TYPE, SHOW_ARENA_ID, SHOW_ARENA_ID_SOLO, COLORING_MODE, COLORING_MODE_NPC;
local NAME_ONLY_MODE, NAME_ONLY_OFFSET_Y, NAME_ONLY_FRIENDLY_PLAYERS_ONLY, NAME_ONLY_COLOR_CLASS, NAME_ONLY_COLOR_HEALTH, NAME_ONLY_SHOW_LEVEL, NAME_ONLY_GUILD_NAME, NAME_ONLY_GUILD_NAME_COLOR, NAME_ONLY_GUILD_NAME_SAME_COLOR;
local NAME_WITH_TITLE_ENABLED, NAME_WITH_TITLE_UNIT_TYPE, NAME_WITHOUT_REALM;
local NAME_TEXT_ENABLED;
local RAID_TARGET_ICON_SHOW, RAID_TARGET_ICON_SCALE, RAID_TARGET_ICON_FRAME_STRATA, RAID_TARGET_ICON_POSITION, RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y;
local NAME_TRANSLIT, NAME_REPLACE_DIACRITICS;
local CUSTOM_NPC_ENABLED;
local CLASSIFICATION_INDICATOR_ENABLED, CLASSIFICATION_INDICATOR_STAR, CLASSIFICATION_INDICATOR_SIZE;
local CLASSIFICATION_INDICATOR_POINT, CLASSIFICATION_INDICATOR_RELATIVE_POINT, CLASSIFICATION_INDICATOR_OFFSET_X, CLASSIFICATION_INDICATOR_OFFSET_Y;
local FIRST_MODE;
local NAME_CUT_ENABLED, NAME_CUT_NUMBER, NAME_CUT_UNIT_TYPE;
local NAME_HOLDER_FRAME_STRATA;

local StripesNameFont      = CreateFont('StripesNameFont');
local StripesGuildNameFont = CreateFont('StripesGuildNameFont');

local ABBR_FORMAT = '(%S+) ';
local ABBR_LAST_FORMAT = '%S+';
local ARENAID_STRING_FORMAT = '%s  %s';
local GUILD_NAME_FORMAT = '«%s»';
local GREY_COLOR_START = '|cff666666';

local NAME_WITH_TITLE_MODES = {
    [1] = 'ALL',
    [2] = 'FRIENDLY_PLAYER',
    [3] = 'ENEMY_PLAYER',
};

local WHO_MODES = {
    [1] = 'ALL',
    [2] = 'FRIENDLY_NPC',
    [3] = 'ENEMY_NPC',
};

local ABBREVIATED_CACHE = {};
local CUTTED_CACHE = {};
local FIRST_MODE_CACHE = {};


local function UpdateFont(unitframe)
    unitframe.name:SetFontObject(StripesNameFont);
end

local function GetPlayerName(unitframe)
    local name = unitframe.data.name;

    if NAME_WITH_TITLE_ENABLED and (unitframe.data.unitType == NAME_WITH_TITLE_UNIT_TYPE or NAME_WITH_TITLE_UNIT_TYPE == 'ALL') then
        name = unitframe.data.namePVP or name;
    elseif NAME_WITHOUT_REALM then
        name = unitframe.data.nameWoRealm or name;
    end

    if NAME_TRANSLIT then
        name = LT:Transliterate(name);
    end

    if NAME_REPLACE_DIACRITICS then
        name = LDC:Replace(name);
    end

    return name;
end

local function AbbreviateNameWithDot(t)
    return U_utf8sub(t, 1, 1) .. '.';
end

local function AbbreviateNameWithDotAndSpace(t)
    return U_utf8sub(t, 1, 1) .. '. ';
end

local function AbbreviateNameLastWord(name)
    for n in string_gmatch(name, ABBR_LAST_FORMAT) do
        name = n;
    end

    return name;
end

local function AbbreviateNameFirstWord(name)
    for n in string_gmatch(name, ABBR_LAST_FORMAT) do
        return n;
    end

    return name;
end

local function ApplyCaseTransformation(name, caseTransformation)
    if caseTransformation == 'upper' then
        return U_firstUpper(name);
    elseif caseTransformation == 'lower' then
        return U_firstLower(name);
    else
        return name;
    end
end

local function GetCaseTransformation()
    if FIRST_MODE == 2 then
        return 'upper';
    elseif FIRST_MODE == 3 then
        return 'lower';
    else
        return 'none';
    end
end

local function GetCacheKey(oldName, suffix)
    return oldName .. FIRST_MODE .. (suffix or '');
end

local function GetAbbreviatedName(name)
    local oldName = name;
    local caseTransformation = GetCaseTransformation();
    local suffix = ABBR_MODE == 2 and 'SPACE' or ABBR_MODE == 3 and 'LAST' or ABBR_MODE == 4 and 'FIRST' or 'WOSPACE';
    local keyName = GetCacheKey(oldName, suffix);

    if ABBREVIATED_CACHE[keyName] then
        return ABBREVIATED_CACHE[keyName];
    end

    local format = ABBR_FORMAT;
    local abbreviatedFunction = AbbreviateNameWithDot;

    if ABBR_MODE == 2 then
        abbreviatedFunction = AbbreviateNameWithDotAndSpace;
    elseif ABBR_MODE == 3 then
        abbreviatedFunction = AbbreviateNameLastWord;
    elseif ABBR_MODE == 4 then
        abbreviatedFunction = AbbreviateNameFirstWord;
        format = ABBR_LAST_FORMAT;
    end

    name = string_gsub(name or '', format, abbreviatedFunction);
    name = ApplyCaseTransformation(name, caseTransformation);

    ABBREVIATED_CACHE[keyName] = name;

    return name;
end

local function GetCuttedName(name)
    local oldName = name;
    local caseTransformation = GetCaseTransformation();
    local keyName = GetCacheKey(oldName, NAME_CUT_NUMBER);

    if CUTTED_CACHE[keyName] then
        return CUTTED_CACHE[keyName];
    end

    name = U_utf8sub(name, 0, NAME_CUT_NUMBER) or '';
    name = ApplyCaseTransformation(name, caseTransformation);

    CUTTED_CACHE[keyName] = name;

    return name;
end

local function GetFirstModeName(name)
    local oldName = name;
    local caseTransformation = GetCaseTransformation();
    local keyName = GetCacheKey(oldName);

    if FIRST_MODE_CACHE[keyName] then
        return FIRST_MODE_CACHE[keyName];
    end

    name = ApplyCaseTransformation(name, caseTransformation);

    FIRST_MODE_CACHE[keyName] = name;

    return name;
end

local function HandleCustomName(unitframe)
    if not CUSTOM_NPC_ENABLED then
        unitframe.data.nameCustom = nil;
        return false;
    end

    local npcId     = unitframe.data.npcId;
    local customNpc = O.db.custom_npc[npcId];

    if customNpc and customNpc.enabled and customNpc.npc_new_name then
        unitframe.name:SetText(customNpc.npc_new_name);
        unitframe.data.nameCustom = customNpc.npc_new_name;

        return true;
    end
end

local function HandleAbbreviatedName(unitframe)
    if not ABBR_ENABLED then
        unitframe.data.nameAbbr = nil;
        return false;
    end

    if ABRR_UNIT_TYPE == 'ALL' or ABRR_UNIT_TYPE == unitframe.data.unitType then
        local name;

        if NAME_CUT_ENABLED and (NAME_CUT_UNIT_TYPE == 'ALL' or NAME_CUT_UNIT_TYPE == unitframe.data.unitType) then
            name = GetCuttedName(GetAbbreviatedName(unitframe.data.name));
        else
            name = GetAbbreviatedName(unitframe.data.name);
        end

        unitframe.name:SetText(name);
        unitframe.data.nameAbbr = name;

        return true;
    end
end

local function HandleCuttedName(unitframe)
    if not NAME_CUT_ENABLED then
        unitframe.data.nameCut = nil;
        return false;
    end

    if NAME_CUT_UNIT_TYPE == 'ALL' or NAME_CUT_UNIT_TYPE == unitframe.data.unitType then
        local name = GetCuttedName(unitframe.data.name);

        unitframe.name:SetText(name);
        unitframe.data.nameCut = name;

        return true;
    end
end

local function HandleFirstModeName(unitframe)
    if FIRST_MODE == 1 then
        unitframe.data.nameFirst = nil;
        return false;
    end

    local name = GetFirstModeName(unitframe.data.name);

    unitframe.name:SetText(name);
    unitframe.data.nameFirst = name;

    return true;
end

local function HandleArenaName(unitframe)
    local arenaId = U_GetUnitArenaId(unitframe.data.unit);

    if not arenaId then
        return;
    end

    if SHOW_ARENA_ID_SOLO then
        unitframe.name:SetText(arenaId);
    else
        unitframe.name:SetText(string_format(ARENAID_STRING_FORMAT, arenaId, GetPlayerName(unitframe)));
    end
end

local function HandlePlayerName(unitframe)
    unitframe.name:SetText(GetPlayerName(unitframe));
end

-- ORDER IS IMPORTANT!
local HandleNpcNameFunctions = {
    HandleCustomName,
    HandleAbbreviatedName,
    HandleCuttedName,
    HandleFirstModeName,
};

local function UpdateName(unitframe)
    if unitframe.data.commonUnitType == 'NPC' then
        for _, handleFunction in ipairs(HandleNpcNameFunctions) do
            local result = handleFunction(unitframe);

            if result then
                break;
            end
        end
    end

    if unitframe.data.unitType == 'ENEMY_PLAYER' and SHOW_ARENA_ID and PlayerState.inArena then
        HandleArenaName(unitframe);
        return;
    end

    if unitframe.data.unitType == 'ENEMY_PLAYER' or (unitframe.data.unitType == 'FRIENDLY_PLAYER' and not (IsNameOnlyMode() and NAME_ONLY_COLOR_HEALTH)) then
        HandlePlayerName(unitframe);
    end
end

local function DefaultColor(frame)
    if not frame.data.unit then
        return;
    end

    if frame.UpdateNameOverride and frame:UpdateNameOverride() then
        return;
    end

    if U_UnitIsTapped(frame.data.unit) then
        frame.name:SetVertexColor(0.5, 0.5, 0.5);
    elseif frame.optionTable.colorNameBySelection then
        frame.name:SetVertexColor(UnitSelectionColor(frame.data.unit, frame.optionTable.colorNameWithExtendedColors));
    end
end

local function SetInitialTruncatedNameAnchor(unitframe, isLeftH, isCenterH, isRightH)
    if not TRUNCATE then
        return;
    end

    local offsetX1 = isLeftH and 0 or OFFSET_X;
    local offsetY1 = 0;

    local offsetX2 = isRightH and 0 or OFFSET_X;
    local offsetY2 = 0;

    PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', offsetX1, offsetY1);
    PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', offsetX2, offsetY2);
end

local function UpdateAnchor(unitframe)
    unitframe.name:ClearAllPoints();

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
        unitframe.name:SetParent(unitframe);
        unitframe.name:SetDrawLayer('ARTWORK', 0);
        unitframe.name:SetJustifyH('CENTER');
        PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, NAME_ONLY_OFFSET_Y);

        return;
    end

    local isLeftH, isCenterH, isRightH  = POSITION == 1, POSITION == 2, POSITION == 3;
    local isTopV,  isCenterV, isBottomV = POSITION_V == 1, POSITION_V == 2, POSITION_V == 3;

    unitframe.name:SetParent(unitframe.NameHolder or unitframe.healthBar);
    unitframe.name:SetDrawLayer('OVERLAY', 7);
    unitframe.name:SetJustifyH(isLeftH and 'LEFT' or isCenterH and 'CENTER' or 'RIGHT');

    SetInitialTruncatedNameAnchor(unitframe, isLeftH, isCenterH, isRightH);

    if isLeftH then -- LEFT
        if TRUNCATE then
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', OFFSET_X, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOPLEFT', unitframe.healthBar, 'BOTTOMLEFT', OFFSET_X, OFFSET_Y);
            end
        end
    elseif isCenterH then -- CENTER
        if TRUNCATE then
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', OFFSET_X, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'CENTER', unitframe.healthBar, 'CENTER', OFFSET_X, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', OFFSET_X, OFFSET_Y);
            end
        end
    elseif isRightH then -- RIGHT
        if TRUNCATE then
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if isTopV then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', OFFSET_X, OFFSET_Y);
            elseif isCenterV then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
            elseif isBottomV then
                PixelUtil.SetPoint(unitframe.name, 'TOPRIGHT', unitframe.healthBar, 'BOTTOMRIGHT', OFFSET_X, OFFSET_Y);
            end
        end
    end

    PixelUtil.SetHeight(unitframe.name, unitframe.name:GetLineHeight() + 1);
end

local function UpdateColor(unitframe)
    if IsNameOnlyMode() and NAME_ONLY_COLOR_CLASS and unitframe.data.unitType == 'FRIENDLY_PLAYER' then
        unitframe.name:SetVertexColor(unitframe.data.colorR, unitframe.data.colorG, unitframe.data.colorB);
        return;
    end

    if unitframe.data.commonUnitType == 'NPC' then
        if unitframe.data.threatNameColored and unitframe.data.threatColorR then
            unitframe.name:SetVertexColor(unitframe.data.threatColorR, unitframe.data.threatColorG, unitframe.data.threatColorB);
        else
            if COLORING_MODE_NPC == 1 then -- NONE
                unitframe.name:SetVertexColor(1, 1, 1);
            else
                DefaultColor(unitframe);
            end
        end

        return;
    end

    if unitframe.data.commonUnitType == 'PET' then
        if COLORING_MODE_NPC == 1 then -- NONE
            unitframe.name:SetVertexColor(1, 1, 1);
        else
            DefaultColor(unitframe);
        end

        return;
    end

    if unitframe.data.commonUnitType == 'PLAYER' then
        if COLORING_MODE == 1 then -- NONE
            unitframe.name:SetVertexColor(1, 1, 1);
        elseif COLORING_MODE == 2 then -- CLASS COLOR
            unitframe.name:SetVertexColor(unitframe.data.colorR, unitframe.data.colorG, unitframe.data.colorB);
        else -- FACTION COLOR
            DefaultColor(unitframe);
        end

        return;
    end
end

local function UpdateNameVisibility(unitframe)
    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
        unitframe.name:SetShown(NAME_TEXT_ENABLED and not unitframe.data.widgetsOnly and ShouldShowName(unitframe));
    else
        unitframe.name:SetShown(ShouldShowName(unitframe));
    end
end

local UpdateRaidTargetIconPosition = {
    [1] = function(unitframe)
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'RIGHT', unitframe.healthBar, 'LEFT', RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y);
    end,

    [2] = function(unitframe)
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'LEFT', unitframe.healthBar, 'RIGHT', RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y);
    end,

    [3] = function(unitframe)
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'CENTER', unitframe.healthBar, 'CENTER', RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y);
    end,

    [4] = function(unitframe)
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'BOTTOM', unitframe.healthBar, 'TOP', RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y);
    end,

    [5] = function(unitframe)
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'TOP', unitframe.healthBar, 'BOTTOM', RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y);
    end,
};

local function UpdateRaidTargetIcon(unitframe)
    unitframe.RaidTargetFrame:SetScale(RAID_TARGET_ICON_SCALE);

    if RAID_TARGET_ICON_FRAME_STRATA == 1 then
        unitframe.RaidTargetFrame:SetFrameStrata(unitframe.RaidTargetFrame:GetParent():GetFrameStrata());
    else
        unitframe.RaidTargetFrame:SetFrameStrata(RAID_TARGET_ICON_FRAME_STRATA);
    end

    unitframe.RaidTargetFrame:SetShown(RAID_TARGET_ICON_SHOW);
end

local function UpdateHealthBarVisibility(unitframe)
    if unitframe.data.isPersonal then
        return;
    end

    unitframe.RaidTargetFrame:ClearAllPoints();

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'BOTTOM', unitframe.name, 'TOP', 0, 8);

        unitframe.healthBar:Hide();
        unitframe.classificationIndicator:Hide();
    else
        UpdateRaidTargetIconPosition[RAID_TARGET_ICON_POSITION](unitframe);

        if unitframe.data.widgetsOnly or unitframe.data.isGameObject then
            unitframe.healthBar:Hide();
        else
            unitframe.healthBar:Show();
        end
    end
end

local function GetNameAndLevel(unitframe, isFriendlyPlayer, isFriendlyPlayerOrNpc)
    local name, level = '', '';

    if isFriendlyPlayer then
        name = GetPlayerName(unitframe);

        if NAME_ONLY_SHOW_LEVEL and unitframe.data.level and unitframe.data.diff then
            level = U.RGB2CFFHEX(unitframe.data.diff) .. unitframe.data.level .. ' P|r ';
        end
    elseif isFriendlyPlayerOrNpc then
        name = unitframe.data.nameCustom or unitframe.data.nameAbbr or unitframe.data.nameCut or unitframe.data.nameFirst or unitframe.data.name;

        if NAME_ONLY_SHOW_LEVEL and unitframe.data.level and unitframe.data.diff and unitframe.data.classification then
            level = U.RGB2CFFHEX(unitframe.data.diff) .. unitframe.data.level .. unitframe.data.classification .. '|r ';
        end
    end

    return name, level;
end

local function GetHealthLength(unitframe, name)
    return strlenutf8(name) * (unitframe.data.healthCurrent / unitframe.data.healthMax);
end

local function HandleNameHealth(unitframe, isFriendlyPlayer, isFriendlyPlayerOrNpc)
    if isFriendlyPlayer and not unitframe.data.isConnected then
        unitframe.name:SetText(GREY_COLOR_START .. GetPlayerName(unitframe));
        return;
    end

    if unitframe.data.healthCurrent > 0 and unitframe.data.healthMax > 0 then
        local name, level = GetNameAndLevel(unitframe, isFriendlyPlayer, isFriendlyPlayerOrNpc);
        local healthLength = GetHealthLength(unitframe, name);
        unitframe.name:SetText(level .. U_utf8sub(name, 0, healthLength) .. GREY_COLOR_START .. U_utf8sub(name, healthLength + 1));
    end
end

local function NameOnly_UpdateNameHealth(unitframe)
    if not IsNameOnlyMode() or not NAME_ONLY_COLOR_HEALTH then
        return
    end

    local isFriendlyPlayer      = unitframe.data.unitType == 'FRIENDLY_PLAYER' and not unitframe.data.canAttack;
    local isFriendlyPlayerOrNpc = not NAME_ONLY_FRIENDLY_PLAYERS_ONLY and IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack);

    if isFriendlyPlayer or isFriendlyPlayerOrNpc then
        HandleNameHealth(unitframe, isFriendlyPlayer, isFriendlyPlayerOrNpc);
    end
end

local function NameOnly_CreateGuildName(unitframe)
    if unitframe.GuildName then
        return;
    end

    local frame = CreateFrame('Frame', '$parentGuildName', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'OVERLAY', 'StripesGuildNameFont');
    PixelUtil.SetPoint(frame.text, 'TOP', unitframe.name, 'BOTTOM', 0, -1);

    frame:Hide();

    unitframe.GuildName = frame;
end

local function NameOnly_UpdateGuildName(unitframe)
    if not unitframe.GuildName then
        return;
    end

    if IsNameOnlyMode() and NAME_ONLY_GUILD_NAME then
        if unitframe.data.unitType == 'FRIENDLY_PLAYER' and unitframe.data.guild then
            local guild = GetCachedName(unitframe.data.guild, true, true, false);

            unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, guild));
            if D.Player.GuildName == unitframe.data.guild then
                unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_SAME_COLOR[1], NAME_ONLY_GUILD_NAME_SAME_COLOR[2], NAME_ONLY_GUILD_NAME_SAME_COLOR[3], NAME_ONLY_GUILD_NAME_SAME_COLOR[4]);
            else
                unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_COLOR[1], NAME_ONLY_GUILD_NAME_COLOR[2], NAME_ONLY_GUILD_NAME_COLOR[3], NAME_ONLY_GUILD_NAME_COLOR[4]);
            end

            unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
        elseif IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
            local subLabel = U_GetNpcSubLabelByID(unitframe.data.npcId);

            if subLabel then
                unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, subLabel));
                unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_COLOR[1], NAME_ONLY_GUILD_NAME_COLOR[2], NAME_ONLY_GUILD_NAME_COLOR[3], NAME_ONLY_GUILD_NAME_COLOR[4]);
                unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
            else
                unitframe.GuildName:Hide();
            end
        else
            unitframe.GuildName:Hide();
        end
    else
        unitframe.GuildName:Hide();
    end
end

local function UpdateClassificationIndicator(unitframe)
    if not unitframe.classificationIndicator then
        return;
    end

    if unitframe.data.isSoftInteract and not unitframe.data.isSoftEnemy then
        unitframe.classificationIndicator:Hide();
        return;
    end

    if unitframe.optionTable.showPvPClassificationIndicator and unitframe.unit and CompactUnitFrame_UpdatePvPClassificationIndicator(unitframe) then
        unitframe.classificationIndicator:SetSize(CLASSIFICATION_INDICATOR_SIZE, CLASSIFICATION_INDICATOR_SIZE);

        if unitframe.classificationIndicator.wasChanged then
            unitframe.classificationIndicator:SetTexCoord(0, 1, 0, 1);
            unitframe.classificationIndicator:SetVertexColor(1, 1, 1, 1);

            unitframe.classificationIndicator.wasChanged = nil;
        end

        return;
    elseif not CLASSIFICATION_INDICATOR_ENABLED or not unitframe.optionTable.showClassificationIndicator then
        unitframe.classificationIndicator:Hide();
    else
        if CLASSIFICATION_INDICATOR_STAR and unitframe.data.classification then
            unitframe.classificationIndicator:SetTexture(S.Media.Icons2.TEXTURE);
            unitframe.classificationIndicator:SetTexCoord(unpack(S.Media.Icons2.COORDS.STAR_WHITE));
            unitframe.classificationIndicator:SetSize(CLASSIFICATION_INDICATOR_SIZE, CLASSIFICATION_INDICATOR_SIZE);

            if unitframe.data.classification == '+' or unitframe.data.classification == 'b' then
                unitframe.classificationIndicator:SetVertexColor(0.85, 0.65, 0.13, 1);
            elseif unitframe.data.classification == 'r' then
                unitframe.classificationIndicator:SetVertexColor(0.8, 0.4, 0.15, 1);
            elseif unitframe.data.classification == 'r+' then
                unitframe.classificationIndicator:SetVertexColor(0.6, 0.6, 0.6, 1);
            end

            unitframe.classificationIndicator.wasChanged = true;
        else
            unitframe.classificationIndicator:SetSize(CLASSIFICATION_INDICATOR_SIZE, CLASSIFICATION_INDICATOR_SIZE);

            if unitframe.classificationIndicator.wasChanged then
                unitframe.classificationIndicator:SetTexCoord(0, 1, 0, 1);
                unitframe.classificationIndicator:SetVertexColor(1, 1, 1, 1);

                unitframe.classificationIndicator.wasChanged = nil;
            end
        end
    end
end

local function UpdateClassificationIndicatorPosition(unitframe)
    unitframe.classificationIndicator:ClearAllPoints();
    unitframe.classificationIndicator:SetPoint(CLASSIFICATION_INDICATOR_POINT, unitframe.healthBar, CLASSIFICATION_INDICATOR_RELATIVE_POINT, CLASSIFICATION_INDICATOR_OFFSET_X, CLASSIFICATION_INDICATOR_OFFSET_Y);
end

local function UpdateNameHolder(unitframe)
    if not unitframe.NameHolder then
        unitframe.NameHolder = CreateFrame('Frame', '$parentNameHolder', unitframe);
        unitframe.NameHolder:SetAllPoints(unitframe.healthBar);
    end

    unitframe.NameHolder:SetFrameStrata(NAME_HOLDER_FRAME_STRATA == 1 and unitframe.healthBar:GetFrameStrata() or NAME_HOLDER_FRAME_STRATA);
end

function Module:UnitAdded(unitframe)
    UpdateNameHolder(unitframe);

    UpdateFont(unitframe);
    UpdateName(unitframe);
    UpdateColor(unitframe);
    UpdateNameVisibility(unitframe);
    UpdateHealthBarVisibility(unitframe);

    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateClassificationIndicatorPosition(unitframe);
    UpdateClassificationIndicator(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.GuildName then
        unitframe.GuildName:Hide();
    end
end

function Module:Update(unitframe)
    UpdateNameHolder(unitframe);

    UpdateFont(unitframe)
    UpdateName(unitframe);
    UpdateColor(unitframe);
    UpdateNameVisibility(unitframe);
    UpdateHealthBarVisibility(unitframe);

    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateClassificationIndicatorPosition(unitframe);
    UpdateClassificationIndicator(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UpdateLocalConfig()
    CUSTOM_NPC_ENABLED = O.db.custom_npc_enabled;

    POSITION               = O.db.name_text_position;
    POSITION_V             = O.db.name_text_position_v;
    OFFSET_X               = O.db.name_text_offset_x;
    OFFSET_Y               = O.db.name_text_offset_y;
    TRUNCATE               = O.db.name_text_truncate;
    ABBR_ENABLED           = O.db.name_text_abbreviated
    ABBR_MODE              = O.db.name_text_abbreviated_mode;
    ABRR_UNIT_TYPE         = WHO_MODES[O.db.name_text_abbreviated_who_mode];
    SHOW_ARENA_ID          = O.db.name_text_show_arenaid;
    SHOW_ARENA_ID_SOLO     = O.db.name_text_show_arenaid_solo;
    COLORING_MODE          = O.db.name_text_coloring_mode;
    COLORING_MODE_NPC      = O.db.name_text_coloring_mode_npc;

    NAME_ONLY_MODE = O.db.name_only_friendly_mode;

    NAME_ONLY_OFFSET_Y     = O.db.name_only_friendly_y_offset;

    NAME_ONLY_COLOR_CLASS  = O.db.name_only_friendly_color_name_by_class;
    NAME_ONLY_COLOR_HEALTH = O.db.name_only_friendly_color_name_by_health;

    NAME_ONLY_SHOW_LEVEL   = O.db.name_only_friendly_show_level;

    NAME_ONLY_GUILD_NAME   = O.db.name_only_friendly_guild_name;

    NAME_ONLY_GUILD_NAME_COLOR = NAME_ONLY_GUILD_NAME_COLOR or {};
    NAME_ONLY_GUILD_NAME_COLOR[1] = O.db.name_only_friendly_guild_name_color[1];
    NAME_ONLY_GUILD_NAME_COLOR[2] = O.db.name_only_friendly_guild_name_color[2];
    NAME_ONLY_GUILD_NAME_COLOR[3] = O.db.name_only_friendly_guild_name_color[3];
    NAME_ONLY_GUILD_NAME_COLOR[4] = O.db.name_only_friendly_guild_name_color[4] or 1;

    NAME_ONLY_GUILD_NAME_SAME_COLOR = NAME_ONLY_GUILD_NAME_SAME_COLOR or {};
    NAME_ONLY_GUILD_NAME_SAME_COLOR[1] = O.db.name_only_friendly_guild_name_same_color[1];
    NAME_ONLY_GUILD_NAME_SAME_COLOR[2] = O.db.name_only_friendly_guild_name_same_color[2];
    NAME_ONLY_GUILD_NAME_SAME_COLOR[3] = O.db.name_only_friendly_guild_name_same_color[3];
    NAME_ONLY_GUILD_NAME_SAME_COLOR[4] = O.db.name_only_friendly_guild_name_same_color[4] or 1;

    NAME_ONLY_FRIENDLY_PLAYERS_ONLY = O.db.name_only_friendly_players_only;

    NAME_WITH_TITLE_ENABLED   = O.db.name_text_with_title;
    NAME_WITH_TITLE_UNIT_TYPE = NAME_WITH_TITLE_MODES[O.db.name_text_with_title_mode];

    NAME_WITHOUT_REALM = O.db.name_without_realm;

    NAME_TEXT_ENABLED = O.db.name_text_enabled;

    NAME_TRANSLIT = O.db.name_text_translit;
    NAME_REPLACE_DIACRITICS = O.db.name_text_replace_diacritics;

    RAID_TARGET_ICON_SHOW              = O.db.raid_target_icon_show;
    RAID_TARGET_ICON_SCALE             = O.db.raid_target_icon_scale;
    RAID_TARGET_ICON_FRAME_STRATA      = O.db.raid_target_icon_frame_strata ~= 1 and O.Lists.frame_strata[O.db.raid_target_icon_frame_strata] or 1;
    RAID_TARGET_ICON_POSITION          = O.db.raid_target_icon_position;
    RAID_TARGET_ICON_POSITION_OFFSET_X = O.db.raid_target_icon_position_offset_x;
    RAID_TARGET_ICON_POSITION_OFFSET_Y = O.db.raid_target_icon_position_offset_y;

    CLASSIFICATION_INDICATOR_ENABLED = O.db.classification_indicator_enabled;
    CLASSIFICATION_INDICATOR_STAR    = O.db.classification_indicator_star;
    CLASSIFICATION_INDICATOR_SIZE    = O.db.classification_indicator_size;
    CLASSIFICATION_INDICATOR_POINT          = O.Lists.frame_points[O.db.classification_indicator_point] or 'RIGHT';
    CLASSIFICATION_INDICATOR_RELATIVE_POINT = O.Lists.frame_points[O.db.classification_indicator_relative_point] or 'LEFT';
    CLASSIFICATION_INDICATOR_OFFSET_X       = O.db.classification_indicator_offset_x;
    CLASSIFICATION_INDICATOR_OFFSET_Y       = O.db.classification_indicator_offset_y;

    FIRST_MODE = O.db.name_text_first_mode;

    NAME_CUT_ENABLED   = O.db.name_text_cut_enabled;
    NAME_CUT_NUMBER    = O.db.name_text_cut_number;
    NAME_CUT_UNIT_TYPE = WHO_MODES[O.db.name_text_cut_who_mode];

    NAME_HOLDER_FRAME_STRATA = O.db.name_text_frame_strata ~= 1 and O.Lists.frame_strata[O.db.name_text_frame_strata] or 1;

    UpdateFontObject(SystemFont_NamePlate, O.db.name_text_font_value, O.db.name_text_font_size, O.db.name_text_font_flag, O.db.name_text_font_shadow);
    UpdateFontObject(SystemFont_NamePlateFixed, O.db.name_text_font_value, O.db.name_text_font_size, O.db.name_text_font_flag, O.db.name_text_font_shadow);
    UpdateFontObject(SystemFont_LargeNamePlate, O.db.name_text_font_value, O.db.name_text_font_size, O.db.name_text_font_flag, O.db.name_text_font_shadow);
    UpdateFontObject(SystemFont_LargeNamePlateFixed, O.db.name_text_font_value, O.db.name_text_font_size, O.db.name_text_font_flag, O.db.name_text_font_shadow);

    UpdateFontObject(StripesNameFont, O.db.name_text_font_value, O.db.name_text_font_size, O.db.name_text_font_flag, O.db.name_text_font_shadow);
    UpdateFontObject(StripesGuildNameFont, O.db.name_text_font_value, O.db.name_text_font_size - 2, O.db.name_text_font_flag, O.db.name_text_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', NameOnly_UpdateNameHealth);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateStatusText', NameOnly_UpdateNameHealth);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', function(unitframe)
        UpdateName(unitframe);
        UpdateColor(unitframe);
        UpdateNameVisibility(unitframe);
        UpdateHealthBarVisibility(unitframe);

        NameOnly_UpdateNameHealth(unitframe);
        NameOnly_UpdateGuildName(unitframe);

        UpdateAnchor(unitframe);
    end);

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', function(unitframe)
        UpdateAnchor(unitframe);
        UpdateHealthBarVisibility(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateWidgetsOnlyMode', UpdateHealthBarVisibility);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthColor', UpdateHealthBarVisibility);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateClassificationIndicator', UpdateClassificationIndicator);
end