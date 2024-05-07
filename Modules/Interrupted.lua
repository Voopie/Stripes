local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Interrupted');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local string_format, bit_band = string.format, bit.band;

-- WoW API
local UnitName, UnitExists, GetPlayerInfoByGUID, GetSpellTexture, CombatLogGetCurrentEventInfo =
      UnitName, UnitExists, GetPlayerInfoByGUID, GetSpellTexture, CombatLogGetCurrentEventInfo;

-- Stripes API
local S_GetCachedName, S_UpdateFontObject = Stripes.GetCachedName, Stripes.UpdateFontObject;
local U_UnitHasAura, U_UnitIsPetByGUID, U_GetUnitColor, U_GetClassColor =
      U.UnitHasAura, U.UnitIsPetByGUID, U.GetUnitColor, U.GetClassColor;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local LPS_CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.STUN);
local LPS_CROWD_CTRL = LPS.constants.CROWD_CTRL;

-- Local Config
local WI_ENABLED;
local SI_ENABLED, SI_SIZE, SI_COUNTDOWN_ENABLED, SI_CASTER_NAME_SHOW, SI_FRAME_STRATA, SI_POINT, SI_RELATIVE_POINT, SI_OFFSET_X, SI_OFFSET_Y, SI_DRAW_SWIPE, SI_DRAW_EDGE, SI_SHOW_INTERRUPTED_ICON;

local StripesSpellInterruptedCooldownFont = CreateFont('StripesSpellInterruptedCooldownFont');
local StripesSpellInterruptedCasterFont   = CreateFont('StripesSpellInterruptedCasterFont');

local blacklist = {
    [197214] = true, -- Sundering (Shaman Enhancement talent)
};

local INTERRUPTED_FORMAT = '|cff%s' .. INTERRUPTED .. '! [%s]|r';

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
    [ 15487] = true, -- Priest (Shadow) -- Silence
};

local DEFAULT_DURATION = 3;

local function Create(unitframe)
    if unitframe.SpellInterrupted then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpellInterrupted', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameLevel(frame:GetFrameLevel() + 100);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    icon:SetSize(SI_SIZE, SI_SIZE);

    local border = frame:CreateTexture(nil, 'BORDER');
    border:SetPoint('TOPLEFT', icon, 'TOPLEFT', -1, 1);
    border:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 1, -1);
    border:SetColorTexture(0.1, 0.1, 0.1);

    local cooldown = CreateFrame('Cooldown', nil, frame, 'CooldownFrameTemplate');
    cooldown:SetAllPoints(icon);
    cooldown:SetHideCountdownNumbers(not SI_COUNTDOWN_ENABLED);
    cooldown:SetDrawEdge(SI_DRAW_EDGE);
    cooldown:SetDrawSwipe(SI_DRAW_SWIPE);
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

    if not SI_ENABLED then
        spellInterruptedFrame:Hide();
        return;
    end

    spellInterruptedFrame:SetFrameStrata(SI_FRAME_STRATA == 1 and spellInterruptedFrame:GetParent():GetFrameStrata() or SI_FRAME_STRATA);

    spellInterruptedFrame.cooldown:SetHideCountdownNumbers(not SI_COUNTDOWN_ENABLED);
    spellInterruptedFrame.cooldown:SetDrawEdge(SI_DRAW_EDGE);
    spellInterruptedFrame.cooldown:SetDrawSwipe(SI_DRAW_SWIPE);

    spellInterruptedFrame.icon:ClearAllPoints();
    PixelUtil.SetPoint(spellInterruptedFrame.icon, SI_POINT, unitframe.healthBar, SI_RELATIVE_POINT, SI_OFFSET_X, SI_OFFSET_Y);
    spellInterruptedFrame.icon:SetSize(SI_SIZE, SI_SIZE);

    spellInterruptedFrame:SetShown(spellInterruptedFrame.expTime > GetTime() and unitframe.data.unitGUID == spellInterruptedFrame.destGUID);
end

local function UpdateByAura(unitframe)
    if not SI_ENABLED or not unitframe.data.unit then
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

    CooldownFrame_Set(spellInterruptedFrame.cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, SI_DRAW_EDGE);

    spellInterruptedFrame.expTime  = aura.expirationTime;
    spellInterruptedFrame.destGUID = unitframe.data.unitGUID;
    spellInterruptedFrame.byAura   = true;

    local sourceUnit = aura.sourceUnit;

    if SI_CASTER_NAME_SHOW and sourceUnit then
        local useTranslit, useReplaceDiacritics, useCut = true, true, false;
        local name = S_GetCachedName(UnitName(sourceUnit), useTranslit, useReplaceDiacritics, useCut);

        spellInterruptedFrame.casterName:SetText(name);
        spellInterruptedFrame.casterName:SetTextColor(U_GetUnitColor(sourceUnit, 2));
        spellInterruptedFrame.casterName:Show();
    else
        spellInterruptedFrame.casterName:Hide();
    end

    spellInterruptedFrame:Show();
end

local function OnInterruptIcon(unitframe, spellId, casterNameText, casterNameUnit, destGUID, extraSpellId)
    if not spellId then
        unitframe.SpellInterrupted.expTime  = 0;
        unitframe.SpellInterrupted.destGUID = nil;
        unitframe.SpellInterrupted.onInterrupt = nil;
        unitframe.SpellInterrupted:Hide();
        return;
    end

    local duration = durations[spellId] or DEFAULT_DURATION;

    local spellInterruptedFrame = unitframe.SpellInterrupted;

    spellInterruptedFrame.icon:SetTexture(GetSpellTexture(SI_SHOW_INTERRUPTED_ICON and extraSpellId or spellId));

    CooldownFrame_Set(spellInterruptedFrame.cooldown, GetTime(), duration, duration > 0, true);

    spellInterruptedFrame.expTime     = GetTime() + duration;
    spellInterruptedFrame.destGUID    = destGUID;
    spellInterruptedFrame.onInterrupt = true;

    if SI_CASTER_NAME_SHOW and casterNameText and casterNameUnit then
        spellInterruptedFrame.casterName:SetText(casterNameText);
        spellInterruptedFrame.casterName:SetTextColor(U_GetClassColor(casterNameUnit, 2));
        spellInterruptedFrame.casterName:Show();
    else
        spellInterruptedFrame.casterName:Hide();
    end

    spellInterruptedFrame:Show();
end


local function OnInterruptCastBar(unitframe, casterNameText, casterNameUnit)
    if not unitframe.castingBar then
        return;
    end

    if casterNameText and casterNameUnit then
        unitframe.castingBar.Text:SetText(string_format(INTERRUPTED_FORMAT, U_GetClassColor(casterNameUnit, 1), casterNameText));
    end
end

local function GetCasterInfo(sourceGUID, sourceName)
    if not sourceGUID or sourceGUID == '' then
        return;
    end

    local _, englishClass, _, _, _, name = GetPlayerInfoByGUID(sourceGUID);
    local casterNameText, casterNameUnit;

    if name then
        casterNameText = name;
        casterNameUnit = englishClass;
    elseif U_UnitIsPetByGUID(sourceGUID) then
        casterNameText = sourceName;
        casterNameUnit = sourceName;
    end

    if casterNameText and casterNameUnit then
        local useTranslit, useReplaceDiacritics, useCut = true, true, false;
        casterNameText = S_GetCachedName(casterNameText, useTranslit, useReplaceDiacritics, useCut);

        return casterNameUnit, casterNameText;
    end
end

-- SPELL_INTERRUPT is used by both (WI & SI)
-- SPELL_AURA_APPLIED is used only by WI
local function HandleCombatLogEvent()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId, _, _, extraSpellId = CombatLogGetCurrentEventInfo();

    local isInterrupt   = subEvent == 'SPELL_INTERRUPT';
    local isAuraApplied = subEvent == 'SPELL_AURA_APPLIED' and WI_ENABLED and not blacklist[spellId];

    if not (isInterrupt or isAuraApplied) then
        return;
    end

    local isCrowdControl = false;

    if isAuraApplied then
        local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
        isCrowdControl = flags and cc and bit_band(flags, LPS_CROWD_CTRL) > 0 and bit_band(cc, LPS_CC_TYPES) > 0;
    end

    if isInterrupt or isCrowdControl then
        Module:ForAllActiveAndShownUnitFrames(function(unitframe)
            if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                local casterNameUnit, casterNameText = GetCasterInfo(sourceGUID, sourceName);

                if WI_ENABLED then
                    OnInterruptCastBar(unitframe, casterNameText, casterNameUnit);
                end

                if SI_ENABLED and isInterrupt and not isCrowdControl then
                    OnInterruptIcon(unitframe, spellId, casterNameText, casterNameUnit, destGUID, extraSpellId);
                end
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
    WI_ENABLED = O.db.who_interrupted_enabled;
    SI_ENABLED = O.db.spell_interrupted_icon;

    SI_SIZE                  = O.db.spell_interrupted_icon_size;
    SI_COUNTDOWN_ENABLED     = O.db.spell_interrupted_icon_countdown_show;
    SI_CASTER_NAME_SHOW      = O.db.spell_interrupted_icon_caster_name_show;
    SI_FRAME_STRATA          = O.db.spell_interrupted_icon_frame_strata ~= 1 and O.Lists.frame_strata[O.db.spell_interrupted_icon_frame_strata] or 1;
    SI_POINT                 = O.Lists.frame_points[O.db.spell_interrupted_icon_point] or 'LEFT';
    SI_RELATIVE_POINT        = O.Lists.frame_points[O.db.spell_interrupted_icon_relative_point] or 'RIGHT';
    SI_OFFSET_X              = O.db.spell_interrupted_icon_offset_x;
    SI_OFFSET_Y              = O.db.spell_interrupted_icon_offset_y;
    SI_DRAW_SWIPE            = O.db.spell_interrupted_icon_cooldown_draw_swipe;
    SI_DRAW_EDGE             = O.db.spell_interrupted_icon_cooldown_draw_edge;
    SI_SHOW_INTERRUPTED_ICON = O.db.spell_interrupted_icon_show_interrupted_icon;

    S_UpdateFontObject(StripesSpellInterruptedCooldownFont, O.db.spell_interrupted_icon_countdown_font_value, O.db.spell_interrupted_icon_countdown_font_size, O.db.spell_interrupted_icon_countdown_font_flag, O.db.spell_interrupted_icon_countdown_font_shadow);
    S_UpdateFontObject(StripesSpellInterruptedCasterFont, O.db.spell_interrupted_icon_caster_name_font_value, O.db.spell_interrupted_icon_caster_name_font_size, O.db.spell_interrupted_icon_caster_name_font_flag, O.db.spell_interrupted_icon_caster_name_font_shadow);

    if WI_ENABLED or SI_ENABLED then
        self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', HandleCombatLogEvent);
    else
        self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end