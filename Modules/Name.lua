local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Name');

-- Lua API
local string_format, string_gsub, string_gmatch = string.format, string.gsub, string.gmatch;
local strlenutf8 = strlenutf8;

-- WoW API
local UnitSelectionColor = UnitSelectionColor;

-- Stripes API
local utf8sub = U.UTF8SUB;
local firstUpper, firstLower = U.FirstToUpper, U.FirstToLower;
local GetUnitArenaId = U.GetUnitArenaId;
local PlayerState = D.Player.State;
local UnitIsTapped = U.UnitIsTapped;
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local IsNameOnlyMode = S:GetNameplateModule('Handler').IsNameOnlyMode;
local IsNameOnlyModeAndFriendly = S:GetNameplateModule('Handler').IsNameOnlyModeAndFriendly;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Nameplates
local NP = S.NamePlates;

-- Libraries
local LT = S.Libraries.LT;
local LDC = S.Libraries.LDC;

-- Local Config
local POSITION, POSITION_V, OFFSET_X, OFFSET_Y, TRUNCATE, ABBR_ENABLED, ABBR_MODE, ABRR_UNIT_TYPE, SHOW_ARENA_ID, SHOW_ARENA_ID_SOLO, COLORING_MODE, COLORING_MODE_NPC;
local NAME_ONLY_MODE, NAME_ONLY_OFFSET_Y, NAME_ONLY_FRIENDLY_PLAYERS_ONLY, NAME_ONLY_COLOR_CLASS, NAME_ONLY_COLOR_HEALTH, NAME_ONLY_GUILD_NAME, NAME_ONLY_GUILD_NAME_COLOR, NAME_ONLY_GUILD_NAME_SAME_COLOR;
local NAME_WITH_TITLE_ENABLED, NAME_WITH_TITLE_UNIT_TYPE, NAME_WITHOUT_REALM;
local NAME_TEXT_ENABLED;
local RAID_TARGET_ICON_SHOW, RAID_TARGET_ICON_SCALE, RAID_TARGET_ICON_FRAME_STRATA, RAID_TARGET_ICON_POSITION, RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y;
local NAME_TRANSLIT, NAME_REPLACE_DIACRITICS;
local CUSTOM_NAME_ENABLED;
local CLASSIFICATION_INDICATOR_ENABLED, CLASSIFICATION_INDICATOR_STAR, CLASSIFICATION_INDICATOR_SIZE;
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

local function UpdateFont(unitframe)
    unitframe.name:SetFontObject(StripesNameFont);
end

local function GetPlayerName(unitframe)
    if NAME_TRANSLIT then
        if NAME_WITH_TITLE_ENABLED then
            if unitframe.data.unitType == NAME_WITH_TITLE_UNIT_TYPE or NAME_WITH_TITLE_UNIT_TYPE == 'ALL' then
                if NAME_REPLACE_DIACRITICS then
                    return LDC:Replace(LT:Transliterate(unitframe.data.namePVP or unitframe.data.name));
                else
                    return LT:Transliterate(unitframe.data.namePVP or unitframe.data.name);
                end
            end
        elseif NAME_WITHOUT_REALM then
            if NAME_REPLACE_DIACRITICS then
                return LDC:Replace(LT:Transliterate(unitframe.data.nameWoRealm or unitframe.data.name));
            else
                return LT:Transliterate(unitframe.data.nameWoRealm or unitframe.data.name);
            end
        end

        return NAME_REPLACE_DIACRITICS and LDC:Replace(LT:Transliterate(unitframe.data.name)) or LT:Transliterate(unitframe.data.name);
    else
        if NAME_WITH_TITLE_ENABLED then
            if unitframe.data.unitType == NAME_WITH_TITLE_UNIT_TYPE or NAME_WITH_TITLE_UNIT_TYPE == 'ALL' then
                if NAME_REPLACE_DIACRITICS then
                    return LDC:Replace(unitframe.data.namePVP or unitframe.data.name);
                else
                    return unitframe.data.namePVP or unitframe.data.name;
                end
            end
        elseif NAME_WITHOUT_REALM then
            if NAME_REPLACE_DIACRITICS then
                return LDC:Replace(unitframe.data.nameWoRealm or unitframe.data.name);
            else
                return unitframe.data.nameWoRealm or unitframe.data.name;
            end
        end

        return NAME_REPLACE_DIACRITICS and LDC:Replace(unitframe.data.name) or unitframe.data.name;
    end
end

local function AbbrSub(t)
    return utf8sub(t, 1, 1) .. '.';
end

local function AbbrSubSpace(t)
    return utf8sub(t, 1, 1) .. '. ';
end

local function AbbrLast(name)
    for n in string_gmatch(name, ABBR_LAST_FORMAT) do
        name = n;
    end

    return name;
end

local function AbbrFirst(name)
    for n in string_gmatch(name, ABBR_LAST_FORMAT) do
        return n;
    end

    return name;
end

local GetAbbreviatedName = {
    [1] = function(name)
        if FIRST_MODE == 1 then
            name = string_gsub(name or '', ABBR_FORMAT, AbbrSub);
        elseif FIRST_MODE == 2 then
            name = firstUpper(string_gsub(name or '', ABBR_FORMAT, AbbrSub));
        elseif FIRST_MODE == 3 then
            name = firstLower(string_gsub(name or '', ABBR_FORMAT, AbbrSub));
        end

        return name;
    end,

    [2] = function(name)
        if FIRST_MODE == 1 then
            name = string_gsub(name or '', ABBR_FORMAT, AbbrSubSpace);
        elseif FIRST_MODE == 2 then
            name = firstUpper(string_gsub(name or '', ABBR_FORMAT, AbbrSubSpace));
        elseif FIRST_MODE == 3 then
            name = firstLower(string_gsub(name or '', ABBR_FORMAT, AbbrSubSpace));
        end

        return name;
    end,

    [3] = function(name)
        if FIRST_MODE == 1 then
            name = AbbrLast(name or '');
        elseif FIRST_MODE == 2 then
            name = firstUpper(AbbrLast(name or ''));
        elseif FIRST_MODE == 3 then
            name = firstLower(AbbrLast(name or ''));
        end

        return name;
    end,

    [4] = function(name)
        if FIRST_MODE == 1 then
            name = AbbrFirst(name or '');
        elseif FIRST_MODE == 2 then
            name = firstUpper(AbbrFirst(name or ''));
        elseif FIRST_MODE == 3 then
            name = firstLower(AbbrFirst(name or ''));
        end

        return name;
    end,
};

local function GetCuttedName(name)
    if FIRST_MODE == 1 then
        name = utf8sub(name, 0, NAME_CUT_NUMBER) or '';
    elseif FIRST_MODE == 2 then
        name = firstUpper(utf8sub(name, 0, NAME_CUT_NUMBER) or '');
    elseif FIRST_MODE == 3 then
        name = firstLower(utf8sub(name, 0, NAME_CUT_NUMBER) or '');
    end

    return name;
end

local function GetCustomName(npcId)
    if npcId and O.db.custom_name_data[npcId] then
        return O.db.custom_name_data[npcId].new_name;
    end
end

local function UpdateName(unitframe)
    if unitframe.data.commonUnitType == 'NPC' then
        local customName = CUSTOM_NAME_ENABLED and GetCustomName(unitframe.data.npcId);

        -- I don't like this Leaning Tower of Pisa...
        if customName then
            unitframe.name:SetText(customName);
        elseif ABBR_ENABLED then
            if unitframe.data.unitType == ABRR_UNIT_TYPE or ABRR_UNIT_TYPE == 'ALL' then
                if NAME_CUT_ENABLED and (unitframe.data.unitType == NAME_CUT_UNIT_TYPE or NAME_CUT_UNIT_TYPE == 'ALL') then
                    unitframe.name:SetText(utf8sub(GetAbbreviatedName[ABBR_MODE](unitframe.data.name) or '', 0, NAME_CUT_NUMBER));
                else
                    unitframe.name:SetText(GetAbbreviatedName[ABBR_MODE](unitframe.data.name));
                end

                unitframe.data.nameAbbr = unitframe.name:GetText();
            else
                if NAME_CUT_ENABLED then
                    if unitframe.data.unitType == NAME_CUT_UNIT_TYPE or NAME_CUT_UNIT_TYPE == 'ALL' then
                        unitframe.name:SetText(GetCuttedName(unitframe.data.name));
                        unitframe.data.nameCut = unitframe.name:GetText();
                    else
                        unitframe.data.nameCut = nil;
                    end
                end

                unitframe.data.nameAbbr = nil;
            end
        elseif NAME_CUT_ENABLED then
            if unitframe.data.unitType == NAME_CUT_UNIT_TYPE or NAME_CUT_UNIT_TYPE == 'ALL' then
                unitframe.name:SetText(GetCuttedName(unitframe.data.name));
                unitframe.data.nameCut = unitframe.name:GetText();
            else
                unitframe.data.nameCut = nil;
            end
        elseif FIRST_MODE ~= 1 then
            local nameFirst;
            if FIRST_MODE == 2 then
                nameFirst = firstUpper(unitframe.data.name);
            elseif FIRST_MODE == 3 then
                nameFirst = firstLower(unitframe.data.name);
            end

            unitframe.name:SetText(nameFirst);
            unitframe.data.nameFirst = nameFirst;
        else
            unitframe.data.nameAbbr  = nil;
            unitframe.data.nameCut   = nil;
            unitframe.data.nameFirst = nil;
        end
    end

    if PlayerState.inArena and SHOW_ARENA_ID and unitframe.data.unitType == 'ENEMY_PLAYER' then
        local arenaId = GetUnitArenaId(unitframe.data.unit);
        if not arenaId then
            return;
        end

        if SHOW_ARENA_ID_SOLO then
            unitframe.name:SetText(arenaId);
        else
            unitframe.name:SetText(string_format(ARENAID_STRING_FORMAT, arenaId, GetPlayerName(unitframe)));
        end

        return;
    end

    if unitframe.data.unitType == 'ENEMY_PLAYER' or (unitframe.data.unitType == 'FRIENDLY_PLAYER' and not (IsNameOnlyMode() and NAME_ONLY_COLOR_HEALTH)) then
        unitframe.name:SetText(GetPlayerName(unitframe));
    end
end

local function DefaultColor(frame)
    if not frame.data.unit then
        return;
    end

    if frame.UpdateNameOverride and frame:UpdateNameOverride() then
        return;
    end

    if UnitIsTapped(frame.data.unit) then
        frame.name:SetVertexColor(0.5, 0.5, 0.5);
    elseif frame.optionTable.colorNameBySelection then
        frame.name:SetVertexColor(UnitSelectionColor(frame.data.unit, frame.optionTable.colorNameWithExtendedColors));
    end
end

local function UpdateAnchor(unitframe)
    unitframe.name:ClearAllPoints();

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
        unitframe.name:SetParent(unitframe);
        unitframe.name:SetJustifyH('CENTER');
        PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, NAME_ONLY_OFFSET_Y);

        return;
    end

    unitframe.name:SetParent(unitframe.NameHolder or unitframe.healthBar);
    unitframe.name:SetDrawLayer('OVERLAY', 7);

    if POSITION == 1 then -- LEFT
        unitframe.name:SetJustifyH('LEFT');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 3 then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 3 then
                PixelUtil.SetPoint(unitframe.name, 'TOPLEFT', unitframe.healthBar, 'BOTTOMLEFT', OFFSET_X, OFFSET_Y);
            end
        end

    elseif POSITION == 2 then -- CENTER
        unitframe.name:SetJustifyH('CENTER');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 3 then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'CENTER', unitframe.healthBar, 'CENTER', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 3 then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', OFFSET_X, OFFSET_Y);
            end
        end
    elseif POSITION == 3 then -- RIGHT
        unitframe.name:SetJustifyH('RIGHT');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
                PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, OFFSET_Y);
            elseif POSITION_V == 3 then
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 2 then
                PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', OFFSET_X, OFFSET_Y);
            elseif POSITION_V == 3 then
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
        unitframe.name:SetShown(NAME_TEXT_ENABLED and not unitframe.data.widgetsOnly);
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

local function NameOnly_UpdateHealthBar(unitframe)
    if unitframe.data.unitType == 'SELF' then
        return;
    end

    unitframe.RaidTargetFrame:ClearAllPoints();

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'BOTTOM', unitframe.name, 'TOP', 0, 8);

        unitframe.healthBar:SetShown(false);
        unitframe.classificationIndicator:SetShown(false);
    else
        UpdateRaidTargetIconPosition[RAID_TARGET_ICON_POSITION](unitframe);

        unitframe.healthBar:SetShown(not unitframe.data.widgetsOnly);
    end
end

local function NameOnly_UpdateNameHealth(unitframe)
    if not IsNameOnlyMode() then
        return;
    end

    if NAME_ONLY_COLOR_HEALTH then
        if unitframe.data.unitType == 'FRIENDLY_PLAYER' and not unitframe.data.canAttack then
            if unitframe.data.isConnected then
                if unitframe.data.healthCurrent > 0 and unitframe.data.healthMax > 0 then
                    local name = GetPlayerName(unitframe);

                    local health_len = strlenutf8(name) * (unitframe.data.healthCurrent / unitframe.data.healthMax);
                    unitframe.name:SetText(utf8sub(name, 0, health_len) .. GREY_COLOR_START .. utf8sub(name, health_len + 1));
                end
            else
                unitframe.name:SetText(GREY_COLOR_START .. GetPlayerName(unitframe));
            end
        elseif not NAME_ONLY_FRIENDLY_PLAYERS_ONLY and unitframe.data.unitType == 'FRIENDLY_NPC' then
            local name = unitframe.data.name;

            if ABBR_ENABLED and unitframe.data.nameAbbr and unitframe.data.nameAbbr ~= '' then
                name = unitframe.data.nameAbbr;
            elseif NAME_CUT_ENABLED and unitframe.data.nameCut and unitframe.data.nameCut ~= '' then
                name = unitframe.data.nameCut;
            elseif unitframe.data.nameFirst and unitframe.data.nameFirst ~= '' then
                name = unitframe.data.nameFirst;
            end

            if unitframe.data.healthCurrent > 0 and unitframe.data.healthMax > 0 then
                local health_len = strlenutf8(name) * (unitframe.data.healthCurrent / unitframe.data.healthMax);
                unitframe.name:SetText(utf8sub(name, 0, health_len) .. GREY_COLOR_START .. utf8sub(name, health_len + 1));
            end
        end
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

    frame:SetShown(false);

    unitframe.GuildName = frame;
end

local function NameOnly_UpdateGuildName(unitframe)
    if IsNameOnlyMode() and NAME_ONLY_GUILD_NAME then
        if unitframe.data.guild and unitframe.data.unitType == 'FRIENDLY_PLAYER' then
            local guild = unitframe.data.guild;

            if NAME_TRANSLIT then
                guild = LT:Transliterate(guild);
            end

            if NAME_REPLACE_DIACRITICS then
                guild = LDC:Replace(guild);
            end

            unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, guild));

            if D.Player.GuildName == unitframe.data.guild then
                unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_SAME_COLOR[1], NAME_ONLY_GUILD_NAME_SAME_COLOR[2], NAME_ONLY_GUILD_NAME_SAME_COLOR[3], NAME_ONLY_GUILD_NAME_SAME_COLOR[4]);
            else
                unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_COLOR[1], NAME_ONLY_GUILD_NAME_COLOR[2], NAME_ONLY_GUILD_NAME_COLOR[3], NAME_ONLY_GUILD_NAME_COLOR[4]);
            end

            unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
        elseif unitframe.data.subLabel and unitframe.data.unitType == 'FRIENDLY_NPC' then
            unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, unitframe.data.subLabel));
            unitframe.GuildName.text:SetTextColor(NAME_ONLY_GUILD_NAME_COLOR[1], NAME_ONLY_GUILD_NAME_COLOR[2], NAME_ONLY_GUILD_NAME_COLOR[3], NAME_ONLY_GUILD_NAME_COLOR[4]);

            unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
        else
            unitframe.GuildName:SetShown(false);
        end
    else
        unitframe.GuildName:SetShown(false);
    end
end

local function UpdateClassificationIndicator(unitframe)
    if not unitframe.classificationIndicator then
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
            elseif unitframe.data.classification == 'r' or unitframe.data.classification == 'r+' then
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

    NameOnly_UpdateHealthBar(unitframe);
    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateClassificationIndicator(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.GuildName then
        unitframe.GuildName:SetShown(false);
    end
end

function Module:Update(unitframe)
    UpdateNameHolder(unitframe);

    UpdateFont(unitframe)
    UpdateName(unitframe);
    UpdateColor(unitframe);
    UpdateNameVisibility(unitframe);

    NameOnly_UpdateHealthBar(unitframe);
    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateClassificationIndicator(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UpdateLocalConfig()
    CUSTOM_NAME_ENABLED = O.db.custom_name_enabled;

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

        NameOnly_UpdateHealthBar(unitframe);
        NameOnly_UpdateNameHealth(unitframe);

        UpdateAnchor(unitframe);
    end);

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', function(unitframe)
        UpdateAnchor(unitframe);
        NameOnly_UpdateHealthBar(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateWidgetsOnlyMode', NameOnly_UpdateHealthBar);

    self:SecureUnitFrameHook('CompactUnitFrame_UpdateClassificationIndicator', UpdateClassificationIndicator);
end