local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('SpellInterrupted');
local Stripes = S:GetNameplateModule('Handler');

-- WoW API
local UnitName, UnitExists, GetSpellTexture, CombatLogGetCurrentEventInfo = UnitName, UnitExists, GetSpellTexture, CombatLogGetCurrentEventInfo;

-- Stripes API
local U_UnitHasAura, U_UnitIsPetByGUID, U_GetUnitColor, U_GetClassColor =
      U.UnitHasAura, U.UnitIsPetByGUID, U.GetUnitColor, U.GetClassColor;
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
    [ 47528] = 3, -- Death Knight -- Mind Freeze
    [ 47476] = 4, -- Death Knight (Blood) -- Strangulate (PvP talent)
    [183752] = 3, -- Demon Hunter -- Disrupt
    [ 32737] = 3, -- Demon Hunter (Vengeance) -- Sigil of Silence (hmmm... Arcane Torrent?)
    [106839] = 3, -- Druid (Feral/Guardian) -- Skull bash
    [ 78675] = 8, -- Druid (Balance) -- Solar beam
    [147362] = 3, -- Hunter -- Counter shot
    [187707] = 3, -- Hunter (Survival) -- Muzzle
    [  2139] = 5, -- Mage -- Counterspell
    [116705] = 3, -- Monk -- Spear Hand Strike
    [ 31935] = 3, -- Paladin (Protection) -- Avenger's Shield
    [ 96231] = 3, -- Paladin -- Rebuke
    [ 15487] = 4, -- Priest (Shadow) -- Silence
    [  1766] = 3, -- Rogue -- Kick
    [ 57994] = 2, -- Shaman -- Wild Shear
    [ 19647] = 5, -- Warlock -- Spell Lock (felhunter)
    [119910] = 5, -- Warlock -- Spell Lock NOTE: Command Demon when felhunter summoned
    [132409] = 5, -- Warlock -- Spell Lock NOTE: Command Demon when felhunter sacrificed
    [212619] = 5, -- Warlock -- Call Felhunter (Demonology honor talent)
    [  6552] = 3, -- Warrior -- Pummel
    [351338] = 4, -- Evoker -- Quell
};

local auras = {
    [  1330] = true, -- Garrote - Rogue (Assa)
    [ 31935] = true, -- Avenger's Shield - Paladin (Protection)
    [204490] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
    [202137] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
    [207682] = true, -- Sigil of Silence - Demon Hunter (Vengeance)
    [214459] = true, -- Choking Flames - Ember of Nullification (Trinket)
};

local DEFAULT_DURATION = 3;

local function Create(unitframe)
    if unitframe.SpellInterrupted then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpellInterrupted', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameLevel(frame:GetFrameLevel() + 100);

    local icon frame:CreateTexture(nil, 'OVERLAY');
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    icon:SetSize(SIZE, SIZE);

    local border = frame:CreateTexture(nil, 'BORDER');
    border:SetPoint('TOPLEFT', icon, 'TOPLEFT', -1, 1);
    border:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 1, -1);
    border:SetColorTexture(0.1, 0.1, 0.1);

    local cooldown = CreateFrame('Cooldown', nil, frame, 'CooldownFrameTemplate');
    cooldown:SetAllPoints(icon);
    cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
    cooldown:SetDrawEdge(DRAW_EDGE);
    cooldown:SetDrawSwipe(DRAW_SWIPE);
    cooldown:GetRegions():SetFontObject(StripesSpellInterruptedCooldownFont);
    cooldown:HookScript('OnCooldownDone', function(self)
        self:GetParent().expTime = 0;
        self:GetParent().destGUID = nil;
        self:GetParent():Hide();
    end);

    local casterName = frame:CreateFontString(nil, 'ARTWORK', 'StripesSpellInterruptedCasterFont');
    PixelUtil.SetPoint(casterName, 'BOTTOM', icon, 'TOP', 0, 2);

    frame.icon       = icon;
    frame.border     = border;
    frame.cooldown   = cooldown;
    frame.casterName = casterName;

    frame.expTime = 0;
    frame.destGUID = nil;

    frame:Hide();

    unitframe.SpellInterrupted = frame;
end

local function Update(unitframe)
    if not unitframe.SpellInterrupted then
        return;
    end

    local spellInterruptedFrame = unitframe.SpellInterrupted;

    if not ENABLED then
        spellInterruptedFrame:Hide();
        return;
    end

    spellInterruptedFrame:SetFrameStrata(FRAME_STRATA == 1 and spellInterruptedFrame:GetParent():GetFrameStrata() or FRAME_STRATA);

    spellInterruptedFrame.cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
    spellInterruptedFrame.cooldown:SetDrawEdge(DRAW_EDGE);
    spellInterruptedFrame.cooldown:SetDrawSwipe(DRAW_SWIPE);

    spellInterruptedFrame.icon:ClearAllPoints();
    PixelUtil.SetPoint(spellInterruptedFrame.icon, POINT, unitframe.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    spellInterruptedFrame.icon:SetSize(SIZE, SIZE);

    spellInterruptedFrame:SetShown(spellInterruptedFrame.expTime > GetTime() and unitframe.data.unitGUID == spellInterruptedFrame.destGUID);
end

local function UpdateByAura(unitframe)
    if not ENABLED or not unitframe.data.unit then
        return;
    end

    local aura = U_UnitHasAura(unitframe.data.unit, auras);

    if not aura then
        if not unitframe.SpellInterrupted.onInterrupt then
            unitframe.SpellInterrupted.expTime  = 0;
            unitframe.SpellInterrupted.destGUID = nil;
            unitframe.SpellInterrupted.byAura   = nil;
            unitframe.SpellInterrupted:Hide();
        end

        return;
    end

    local spellInterruptedFrame = unitframe.SpellInterrupted;

    unitframe.SpellInterrupted.icon:SetTexture(aura.icon);

    CooldownFrame_Set(spellInterruptedFrame.cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, DRAW_EDGE);

    spellInterruptedFrame.expTime  = aura.expirationTime;
    spellInterruptedFrame.destGUID = unitframe.data.unitGUID;
    spellInterruptedFrame.byAura   = true;

    local sourceUnit = aura.sourceUnit;

    if CASTER_NAME_SHOW and sourceUnit then
        local useTranslit, useReplaceDiacritics, useCut = true, true, false;
        local name = GetCachedName(UnitName(sourceUnit), useTranslit, useReplaceDiacritics, useCut);

        spellInterruptedFrame.casterName:SetText(name);
        spellInterruptedFrame.casterName:SetTextColor(U_GetUnitColor(sourceUnit, 2));
        spellInterruptedFrame.casterName:Show();
    else
        spellInterruptedFrame.casterName:Hide();
    end

    spellInterruptedFrame:Show();
end

local function OnInterrupt(unitframe, spellId, sourceGUID, destGUID, sourceName, extraSpellId)
    if not spellId then
        unitframe.SpellInterrupted.expTime  = 0;
        unitframe.SpellInterrupted.destGUID = nil;
        unitframe.SpellInterrupted.onInterrupt = nil;
        unitframe.SpellInterrupted:Hide();
        return;
    end

    local duration = durations[spellId] or DEFAULT_DURATION;

    local spellInterruptedFrame = unitframe.SpellInterrupted;

    spellInterruptedFrame.icon:SetTexture(GetSpellTexture(SHOW_INTERRUPTED_ICON and extraSpellId or spellId));

    CooldownFrame_Set(spellInterruptedFrame.cooldown, GetTime(), duration, duration > 0, true);

    spellInterruptedFrame.expTime     = GetTime() + duration;
    spellInterruptedFrame.destGUID    = destGUID;
    spellInterruptedFrame.onInterrupt = true;

    if CASTER_NAME_SHOW and (sourceGUID and sourceGUID ~= '') then
        local _, englishClass, _, _, _, name = GetPlayerInfoByGUID(sourceGUID);
        local casterNameText, casterNameUnit;

        if name then
            casterNameText = name;
            casterNameUnit = englishClass;
        elseif U_UnitIsPetByGUID(sourceGUID) then
            casterNameText = sourceName
            casterNameUnit = sourceName;
        end

        if casterNameText and casterNameUnit then
            local useTranslit, useReplaceDiacritics, useCut = true, true, false;
            casterNameText = GetCachedName(casterNameText, useTranslit, useReplaceDiacritics, useCut);

            spellInterruptedFrame.casterName:SetText(casterNameText);
            spellInterruptedFrame.casterName:SetTextColor(U_GetClassColor(casterNameUnit, 2));
            spellInterruptedFrame.casterName:Show();
        else
            spellInterruptedFrame.casterName:Hide();
        end
    else
        spellInterruptedFrame.casterName:Hide();
    end

    spellInterruptedFrame:Show();
end

local function HandleCombatLogEvent()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId, _, _, extraSpellId = CombatLogGetCurrentEventInfo();

    local isInterrupt = subEvent == 'SPELL_INTERRUPT';

    if not isInterrupt then
        return;
    end

    Module:ForAllActiveUnitFrames(function(unitframe)
        if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
            OnInterrupt(unitframe, spellId, sourceGUID, destGUID, sourceName, extraSpellId);
        end
    end);
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
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', HandleCombatLogEvent);
end

function Module:Disable()
    self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
end

function Module:StartUp()
    self:UpdateLocalConfig();
end