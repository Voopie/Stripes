local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('SpellInterrupted');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local pairs = pairs;

-- WoW API
local UnitName, CombatLogGetCurrentEventInfo, UnitExists, GetSpellTexture = UnitName, CombatLogGetCurrentEventInfo, UnitExists, GetSpellTexture;

-- Stripes API
local UnitHasAura = U.UnitHasAura;
local U_GetClassColor = U.GetClassColor;
local U_UnitIsPetByGUID = U.UnitIsPetByGUID;
local GetUnitColor = U.GetUnitColor;
local UpdateFontObject = Stripes.UpdateFontObject;
local GetCachedName = Stripes.GetCachedName;

-- Local Config
local ENABLED, SIZE, COUNTDOWN_ENABLED, CASTER_NAME_SHOW, FRAME_STRATA;
local POINT, RELATIVE_POINT, OFFSET_X, OFFSET_Y;
local DRAW_SWIPE, DRAW_EDGE;
local SHOW_INTERRUPTED_ICON;

local StripesSpellInterruptedCooldownFont = CreateFont('StripesSpellInterruptedCooldownFont');
local StripesSpellInterruptedCasterFont   = CreateFont('StripesSpellInterruptedCasterFont');

local durations = {
    [ 47528] = 4, -- Death Knight -- Mind Freeze
    [ 47476] = 3, -- Death Knight (Blood) -- Strangulate (PvP talent)
    [183752] = 3, -- Demon Hunter -- Disrupt
    [204490] = 6, -- Demon Hunter (Vengeance) -- Sigil of Silence
    [ 32737] = 3, -- Demon Hunter (Vengeance) -- Sigil of Silence (hmmm... Arcane Torrent?)
    [106839] = 4, -- Druid (Feral/Guardian) -- Skull bash
    [ 78675] = 5, -- Druid (Balance) -- Solar beam
    [147362] = 3, -- Hunter -- Counter shot
    [187707] = 3, -- Hunter (Survival) -- Muzzle
    [  2139] = 6, -- Mage -- Counterspell
    [116705] = 4, -- Monk -- Spear Hand Strike
    [ 31935] = 3, -- Paladin (Protection) -- Avenger's Shield
    [ 96231] = 4, -- Paladin -- Rebuke
    [ 15487] = 3, -- Priest (Shadow) -- Silence
    [  1766] = 5, -- Rogue -- Kick
    [ 57994] = 3, -- Shaman -- Wild Shear
    [ 19647] = 6, -- Warlock -- Spell Lock (felhunter)
    [119910] = 6, -- Warlock -- Spell Lock NOTE: Command Demon when felhunter summoned
    [132409] = 6, -- Warlock -- Spell Lock NOTE: Command Demon when felhunter sacrificed
    [212619] = 6, -- Warlock -- Call Felhunter (Demonology honor talent)
    [  6552] = 4, -- Warrior -- Pummel
};

local auras = {
    [  1330] = true, -- Garrote - Rogue (Assa)
    [ 31935] = true, -- Avenger's Shield - Paladin (Protection)
    [204490] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
    [202137] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
    [207682] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
};

local DEFAULT_DURATION = 4;

local function Create(unitframe)
    if unitframe.SpellInterrupted then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpellInterrupted', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameLevel(frame:GetFrameLevel() + 100);

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    frame.icon:SetSize(SIZE, SIZE);

    frame.border = frame:CreateTexture(nil, 'BORDER');
    frame.border:SetPoint('TOPLEFT', frame.icon, 'TOPLEFT', -1, 1);
    frame.border:SetPoint('BOTTOMRIGHT', frame.icon, 'BOTTOMRIGHT', 1, -1);
    frame.border:SetColorTexture(0.1, 0.1, 0.1);

    frame.cooldown = CreateFrame('Cooldown', nil, frame, 'CooldownFrameTemplate');
    frame.cooldown:SetAllPoints(frame.icon);
    frame.cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
    frame.cooldown:SetDrawEdge(DRAW_EDGE);
    frame.cooldown:SetDrawSwipe(DRAW_SWIPE);
    frame.cooldown:GetRegions():SetFontObject(StripesSpellInterruptedCooldownFont);
    frame.cooldown:HookScript('OnCooldownDone', function(self)
        self:GetParent().expTime = 0;
        self:GetParent().destGUID = nil;
        self:GetParent():Hide();
    end);

    frame.casterName = frame:CreateFontString(nil, 'ARTWORK', 'StripesSpellInterruptedCasterFont');
    PixelUtil.SetPoint(frame.casterName, 'BOTTOM', frame.icon, 'TOP', 0, 2);

    frame.expTime = 0;
    frame.destGUID = nil;

    frame:Hide();

    unitframe.SpellInterrupted = frame;
end

local function Update(unitframe)
    if ENABLED then
        unitframe.SpellInterrupted.cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        unitframe.SpellInterrupted.cooldown:SetDrawEdge(DRAW_EDGE);
        unitframe.SpellInterrupted.cooldown:SetDrawSwipe(DRAW_SWIPE);

        if FRAME_STRATA == 1 then
            unitframe.SpellInterrupted:SetFrameStrata(unitframe.SpellInterrupted:GetParent():GetFrameStrata());
        else
            unitframe.SpellInterrupted:SetFrameStrata(FRAME_STRATA);
        end

        unitframe.SpellInterrupted.icon:ClearAllPoints();
        PixelUtil.SetPoint(unitframe.SpellInterrupted.icon, POINT, unitframe.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);

        unitframe.SpellInterrupted.icon:SetSize(SIZE, SIZE);

        unitframe.SpellInterrupted:SetShown(unitframe.SpellInterrupted.expTime > GetTime() and unitframe.data.unitGUID == unitframe.SpellInterrupted.destGUID);
    else
        unitframe.SpellInterrupted:Hide();
    end
end

local function UpdateByAura(unitframe)
    if not ENABLED or not unitframe.data.unit then
        return;
    end

    local _, icon, _, _, duration, expirationTime, source = UnitHasAura(unitframe.data.unit, 'HARMFUL', auras);

    if not icon then
        return;
    end

    unitframe.SpellInterrupted.icon:SetTexture(icon);

    CooldownFrame_Set(unitframe.SpellInterrupted.cooldown, expirationTime - duration, duration, duration > 0, DRAW_EDGE);

    unitframe.SpellInterrupted.expTime  = expirationTime;
    unitframe.SpellInterrupted.destGUID = unitframe.data.unitGUID;

    if CASTER_NAME_SHOW and source then
        local name = GetCachedName(UnitName(source), true, true, false);

        unitframe.SpellInterrupted.casterName:SetText(name);
        unitframe.SpellInterrupted.casterName:SetTextColor(GetUnitColor(source, 2));
        unitframe.SpellInterrupted.casterName:Show();
    else
        unitframe.SpellInterrupted.casterName:Hide();
    end

    unitframe.SpellInterrupted:Show();
end

local function OnInterrupt(unitframe, spellId, sourceGUID, destGUID, sourceName, extraSpellId)
    if not spellId then
        unitframe.SpellInterrupted.expTime  = 0;
        unitframe.SpellInterrupted.destGUID = nil;
        unitframe.SpellInterrupted:Hide();
        return;
    end

    local duration = durations[spellId] or DEFAULT_DURATION;

    unitframe.SpellInterrupted.icon:SetTexture(GetSpellTexture(SHOW_INTERRUPTED_ICON and extraSpellId or spellId));

    CooldownFrame_Set(unitframe.SpellInterrupted.cooldown, GetTime(), duration, duration > 0, true);

    unitframe.SpellInterrupted.expTime  = GetTime() + duration;
    unitframe.SpellInterrupted.destGUID = destGUID;

    if CASTER_NAME_SHOW and (sourceGUID and sourceGUID ~= '') then
        local _, englishClass, _, _, _, name = GetPlayerInfoByGUID(sourceGUID);

        if name then
            name = GetCachedName(name, true, true, false);

            unitframe.SpellInterrupted.casterName:SetText(name);
            unitframe.SpellInterrupted.casterName:SetTextColor(U_GetClassColor(englishClass, 2));
            unitframe.SpellInterrupted.casterName:Show();
        elseif U_UnitIsPetByGUID(sourceGUID) then
            name = GetCachedName(sourceName, true, true, false);

            unitframe.SpellInterrupted.casterName:SetText(name);
            unitframe.SpellInterrupted.casterName:SetTextColor(U_GetClassColor(sourceName, 2));
            unitframe.SpellInterrupted.casterName:Show();
        else
            unitframe.SpellInterrupted.casterName:Hide();
        end
    else
        unitframe.SpellInterrupted.casterName:Hide();
    end

    unitframe.SpellInterrupted:Show();
end

function Module:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId, _, _, extraSpellId = CombatLogGetCurrentEventInfo();

    if subEvent == 'SPELL_INTERRUPT' then
        self:ForAllActiveUnitFrames(function(unitframe)
            if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                OnInterrupt(unitframe, spellId, sourceGUID, destGUID, sourceName, extraSpellId);
            end
        end);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
    UpdateByAura(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.SpellInterrupted then
        unitframe.SpellInterrupted:Hide();
    end
end

function Module:UnitAura(unitframe)
    UpdateByAura(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
    UpdateByAura(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED           = O.db.spell_interrupted_icon;
    SIZE              = O.db.spell_interrupted_icon_size;
    COUNTDOWN_ENABLED = O.db.spell_interrupted_icon_countdown_show;
    CASTER_NAME_SHOW  = O.db.spell_interrupted_icon_caster_name_show;
    FRAME_STRATA      = O.db.spell_interrupted_icon_frame_strata ~= 1 and O.Lists.frame_strata[O.db.spell_interrupted_icon_frame_strata] or 1;

    POINT          = O.Lists.frame_points[O.db.spell_interrupted_icon_point] or 'LEFT';
    RELATIVE_POINT = O.Lists.frame_points[O.db.spell_interrupted_icon_relative_point] or 'RIGHT';
    OFFSET_X       = O.db.spell_interrupted_icon_offset_x;
    OFFSET_Y       = O.db.spell_interrupted_icon_offset_y;

    DRAW_SWIPE = O.db.spell_interrupted_icon_cooldown_draw_swipe;
    DRAW_EDGE  = O.db.spell_interrupted_icon_cooldown_draw_edge;

    SHOW_INTERRUPTED_ICON = O.db.spell_interrupted_icon_show_interrupted_icon;

    UpdateFontObject(StripesSpellInterruptedCooldownFont, O.db.spell_interrupted_icon_countdown_font_value, O.db.spell_interrupted_icon_countdown_font_size, O.db.spell_interrupted_icon_countdown_font_flag, O.db.spell_interrupted_icon_countdown_font_shadow);
    UpdateFontObject(StripesSpellInterruptedCasterFont, O.db.spell_interrupted_icon_caster_name_font_value, O.db.spell_interrupted_icon_caster_name_font_size, O.db.spell_interrupted_icon_caster_name_font_flag, O.db.spell_interrupted_icon_caster_name_font_shadow);

    if ENABLED then
        self:Enable();
    else
        self:Disable();
    end
end

function Module:Enable()
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
end

function Module:Disable()
    self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
end

function Module:StartUp()
    self:UpdateLocalConfig();
end