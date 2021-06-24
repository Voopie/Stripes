local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Name');

-- Lua API
local string_format, string_gsub, string_gmatch = string.format, string.gsub, string.gmatch;
local strlenutf8 = strlenutf8;

-- WoW API
local UnitSelectionColor = UnitSelectionColor;

-- Stripes API
local utf8sub = U.UTF8SUB;
local GetUnitArenaId = U.GetUnitArenaId;
local PlayerState = D.Player.State;
local UnitIsTapped = U.UnitIsTapped;
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local IsNameOnlyMode = S:GetNameplateModule('Handler').IsNameOnlyMode;
local IsNameOnlyModeAndFriendly = S:GetNameplateModule('Handler').IsNameOnlyModeAndFriendly;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Libraries
local LT = S.Libraries.LT;

-- Local Config
local POSITION, POSITION_V, OFFSET_Y, TRUNCATE, ABBR_ENABLED, ABBR_MODE, SHOW_ARENA_ID, SHOW_ARENA_ID_SOLO, COLORING_MODE, COLORING_MODE_NPC;
local NAME_ONLY_OFFSET_Y, NAME_ONLY_FRIENDLY_PLAYERS_ONLY, NAME_ONLY_COLOR_CLASS, NAME_ONLY_COLOR_HEALTH, NAME_ONLY_GUILD_NAME, NAME_ONLY_GUILD_NAME_COLOR, NAME_ONLY_GUILD_NAME_SAME_COLOR;
local NAME_PVP, NAME_WITHOUT_REALM;
local NAME_TEXT_ENABLED;
local RAID_TARGET_ICON_SHOW, RAID_TARGET_ICON_SCALE, RAID_TARGET_ICON_FRAME_STRATA, RAID_TARGET_ICON_POSITION, RAID_TARGET_ICON_POSITION_OFFSET_X, RAID_TARGET_ICON_POSITION_OFFSET_Y;
local NAME_TRANSLIT;

local StripesNameFont      = CreateFont('StripesNameFont');
local StripesGuildNameFont = CreateFont('StripesGuildNameFont');

local ABBR_FORMAT = '(%S+) ';
local ABBR_LAST_FORMAT = '%S+';
local ARENAID_STRING_FORMAT = '%s  %s';
local GUILD_NAME_FORMAT = '«%s»';
local GREY_COLOR_START = '|cff666666';

local function UpdateFont(unitframe)
    unitframe.name:SetFontObject(StripesNameFont);
end

local function GetName(unitframe)
    local name;

    if NAME_WITHOUT_REALM then
        name = NAME_TRANSLIT and unitframe.data.nameTranslitWoRealm or unitframe.data.nameWoRealm;
    end

    if not name or name == '' then
        name = NAME_TRANSLIT and unitframe.data.nameTranslit or unitframe.data.name;
    end

    return name;
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

local GetAbbreviatedName = {
    [1] = function(name)
        return string_gsub(name, ABBR_FORMAT, AbbrSub);
    end,

    [2] = function(name)
        return string_gsub(name, ABBR_FORMAT, AbbrSubSpace);
    end,

    [3] = function(name)
        return AbbrLast(name);
    end,
};

local function UpdateName(unitframe)
    if ABBR_ENABLED and unitframe.data.commonUnitType == 'NPC' then
        local name = unitframe.data.name;
        if name then
            unitframe.name:SetText(GetAbbreviatedName[ABBR_MODE](name));
            unitframe.data.nameAbbr = unitframe.name:GetText();
        end
    end

    if PlayerState.inArena then
        if SHOW_ARENA_ID and unitframe.data.unitType == 'ENEMY_PLAYER' then
            local arenaId = GetUnitArenaId(unitframe.data.unit);
            if not arenaId then
                return;
            end

            if SHOW_ARENA_ID_SOLO then
                unitframe.name:SetText(arenaId);
            else
                unitframe.name:SetText(string_format(ARENAID_STRING_FORMAT, arenaId, GetName(unitframe)));
            end

            return;
        end
    end

    if unitframe.data.unitType == 'ENEMY_PLAYER' or (not IsNameOnlyMode() and unitframe.data.unitType == 'FRIENDLY_PLAYER') then
        unitframe.name:SetText(GetName(unitframe));
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

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
        unitframe.name:SetJustifyH('CENTER');
        PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, NAME_ONLY_OFFSET_Y);

        return;
    end

    if POSITION == 1 then
        unitframe.name:SetJustifyH('LEFT');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOPLEFT', unitframe.healthBar, 'BOTTOMLEFT', 0, OFFSET_Y);
            end
        end

    elseif POSITION == 2 then
        unitframe.name:SetJustifyH('CENTER');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        end
    else
        unitframe.name:SetJustifyH('RIGHT');

        if TRUNCATE then
            PixelUtil.SetPoint(unitframe.name, 'RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
            PixelUtil.SetPoint(unitframe.name, 'LEFT', unitframe.healthBar, 'LEFT', 0, 0);

            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOM', unitframe.healthBar, 'TOP', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOP', unitframe.healthBar, 'BOTTOM', 0, OFFSET_Y);
            end
        else
            if POSITION_V == 1 then
                PixelUtil.SetPoint(unitframe.name, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0, OFFSET_Y);
            else
                PixelUtil.SetPoint(unitframe.name, 'TOPRIGHT', unitframe.healthBar, 'BOTTOMRIGHT', 0, OFFSET_Y);
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
    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
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

    if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
        PixelUtil.SetPoint(unitframe.RaidTargetFrame, 'BOTTOM', unitframe.name, 'TOP', 0, 8);

        unitframe.healthBar:SetShown(false);
        unitframe.classificationIndicator:SetShown(false);
    else
        UpdateRaidTargetIconPosition[RAID_TARGET_ICON_POSITION](unitframe);

        unitframe.healthBar:SetShown(not unitframe.data.widgetsOnly);
    end
end

local function NameOnly_GetName(unitframe)
    local name;

    if NAME_PVP then
        name = NAME_TRANSLIT and unitframe.data.nameTranslitPVP or unitframe.data.namePVP;
    elseif NAME_WITHOUT_REALM then
        name = NAME_TRANSLIT and unitframe.data.nameTranslitWoRealm or unitframe.data.nameWoRealm;
    end

    if not name or name == '' then
        name = NAME_TRANSLIT and unitframe.data.nameTranslit or unitframe.data.name;
    end

    return name;
end

local function NameOnly_UpdateNameHealth(unitframe)
    if not IsNameOnlyMode() then
        return;
    end

    if NAME_ONLY_COLOR_HEALTH then
        if unitframe.data.unitType == 'FRIENDLY_PLAYER' then
            if unitframe.data.healthCurrent > 0 and unitframe.data.healthMax > 0 then
                local name = NameOnly_GetName(unitframe);

                local health_len = strlenutf8(name) * (unitframe.data.healthCurrent / unitframe.data.healthMax);
                unitframe.name:SetText(utf8sub(name, 0, health_len) .. GREY_COLOR_START .. utf8sub(name, health_len + 1));
            end
        elseif not NAME_ONLY_FRIENDLY_PLAYERS_ONLY and unitframe.data.unitType == 'FRIENDLY_NPC' then
            local name = (ABBR_ENABLED and unitframe.data.nameAbbr ~= '') and unitframe.data.nameAbbr or unitframe.data.name;

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
    frame.text:SetTextColor(unpack(NAME_ONLY_GUILD_NAME_COLOR));

    frame:SetShown(false);

    unitframe.GuildName = frame;
end

local function NameOnly_UpdateGuildName(unitframe)
    if IsNameOnlyMode() and NAME_ONLY_GUILD_NAME then
        if unitframe.data.guild and unitframe.data.unitType == 'FRIENDLY_PLAYER' then
            unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, unitframe.data.guild));

            if D.Player.GuildName == unitframe.data.guild then
                unitframe.GuildName.text:SetTextColor(unpack(NAME_ONLY_GUILD_NAME_SAME_COLOR));
            else
                unitframe.GuildName.text:SetTextColor(unpack(NAME_ONLY_GUILD_NAME_COLOR));
            end

            unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
        elseif unitframe.data.subLabel and unitframe.data.unitType == 'FRIENDLY_NPC' then
            unitframe.GuildName.text:SetText(string_format(GUILD_NAME_FORMAT, unitframe.data.subLabel));
            unitframe.GuildName.text:SetTextColor(unpack(NAME_ONLY_GUILD_NAME_COLOR));

            unitframe.GuildName:SetShown(not unitframe.healthBar:IsShown());
        else
            unitframe.GuildName:SetShown(false);
        end
    else
        unitframe.GuildName:SetShown(false);
    end
end

function Module:UnitAdded(unitframe)
    UpdateFont(unitframe);
    UpdateName(unitframe);
    UpdateColor(unitframe);
    UpdateNameVisibility(unitframe);

    NameOnly_UpdateHealthBar(unitframe);
    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.GuildName then
        unitframe.GuildName:SetShown(false);
    end
end

function Module:Update(unitframe)
    UpdateFont(unitframe)
    UpdateName(unitframe);
    UpdateColor(unitframe);
    UpdateNameVisibility(unitframe);

    NameOnly_UpdateHealthBar(unitframe);
    NameOnly_UpdateNameHealth(unitframe);
    NameOnly_CreateGuildName(unitframe);
    NameOnly_UpdateGuildName(unitframe);

    UpdateRaidTargetIcon(unitframe);

    UpdateAnchor(unitframe);
end

function Module:UpdateLocalConfig()
    POSITION               = O.db.name_text_position;
    POSITION_V             = O.db.name_text_position_v;
    OFFSET_Y               = O.db.name_text_offset_y;
    TRUNCATE               = O.db.name_text_truncate;
    ABBR_ENABLED           = O.db.name_text_abbreviated
    ABBR_MODE              = O.db.name_text_abbreviated_mode;
    SHOW_ARENA_ID          = O.db.name_text_show_arenaid;
    SHOW_ARENA_ID_SOLO     = O.db.name_text_show_arenaid_solo;
    COLORING_MODE          = O.db.name_text_coloring_mode;
    COLORING_MODE_NPC      = O.db.name_text_coloring_mode_npc;

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

    NAME_PVP = O.db.name_only_friendly_name_pvp;

    NAME_WITHOUT_REALM = O.db.name_without_realm;

    NAME_TEXT_ENABLED = O.db.name_text_enabled;

    NAME_TRANSLIT = O.db.name_text_translit;

    RAID_TARGET_ICON_SHOW              = O.db.raid_target_icon_show;
    RAID_TARGET_ICON_SCALE             = O.db.raid_target_icon_scale;
    RAID_TARGET_ICON_FRAME_STRATA      = O.db.raid_target_icon_frame_strata ~= 1 and O.Lists.frame_strata[O.db.raid_target_icon_frame_strata] or 1;
    RAID_TARGET_ICON_POSITION          = O.db.raid_target_icon_position;
    RAID_TARGET_ICON_POSITION_OFFSET_X = O.db.raid_target_icon_position_offset_x;
    RAID_TARGET_ICON_POSITION_OFFSET_Y = O.db.raid_target_icon_position_offset_y;

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
end