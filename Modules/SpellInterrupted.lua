local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('SpellInterrupted');

-- Lua API
local pairs = pairs;

-- WoW API
local UnitName, CombatLogGetCurrentEventInfo, UnitExists, GetSpellTexture = UnitName, CombatLogGetCurrentEventInfo, UnitExists, GetSpellTexture;

-- Stripes API
local GetClassColorByGUID = U.GetClassColorByGUID;
local GetUnitColor = U.GetUnitColor;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local ENABLED, CASTER_NAME_SHOW, FRAME_STRATA;

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

local SigilOfSilenceAuras = {
    [204490] = true,
    [202137] = true,
    [207682] = true,
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
    frame.icon:SetPoint('LEFT', unitframe.healthBar, 'RIGHT', 4, 0);
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    frame.icon:SetSize(20, 20);

    frame.border = frame:CreateTexture(nil, 'BORDER');
    frame.border:SetPoint('TOPLEFT', frame.icon, 'TOPLEFT', -1, 1);
    frame.border:SetPoint('BOTTOMRIGHT', frame.icon, 'BOTTOMRIGHT', 1, -1);
    frame.border:SetColorTexture(0.1, 0.1, 0.1);

    frame.cooldown = CreateFrame('Cooldown', nil, frame, 'CooldownFrameTemplate');
    frame.cooldown:SetAllPoints(frame.icon);
    frame.cooldown:SetHideCountdownNumbers(false);
    frame.cooldown:GetRegions():SetFontObject(StripesSpellInterruptedCooldownFont);
    frame.cooldown:HookScript('OnCooldownDone', function(self)
        self:GetParent().expTime = 0;
        self:GetParent().destGUID = nil;
        self:GetParent():SetShown(false);
    end);

    frame.casterName = frame:CreateFontString(nil, 'ARTWORK', 'StripesSpellInterruptedCasterFont');
    PixelUtil.SetPoint(frame.casterName, 'BOTTOM', frame.icon, 'TOP', 0, 2);

    frame.expTime = 0;
    frame.destGUID = nil;

    frame:SetShown(false);

    unitframe.SpellInterrupted = frame;
end

local function Update(unitframe)
    if ENABLED then
        if FRAME_STRATA == 1 then
            unitframe.SpellInterrupted:SetFrameStrata(unitframe.SpellInterrupted:GetParent():GetFrameStrata());
        else
            unitframe.SpellInterrupted:SetFrameStrata(FRAME_STRATA);
        end

        unitframe.SpellInterrupted:SetShown(unitframe.SpellInterrupted.expTime > GetTime() and unitframe.data.unitGUID == unitframe.SpellInterrupted.destGUID);
    else
        unitframe.SpellInterrupted:SetShown(false);
    end
end

local function FindAura(unit)
    local spellId, duration, source;

    for i = 1, BUFF_MAX_DISPLAY do
        duration, _, _, source, _, _, spellId = select(5, UnitAura(unit, i, 'HARMFULL'));

        if not spellId then
            return false;
        end

        if SigilOfSilenceAuras[spellId] then
            return spellId, duration, source;
        end
    end

    return false;
end

local function UpdateByAura(unitframe)
    if not ENABLED then
        return;
    end

    local spellId, duration, source = FindAura(unitframe.data.unit);

    if not spellId then
        return;
    end

    unitframe.SpellInterrupted.icon:SetTexture(GetSpellTexture(spellId));
    CooldownFrame_Set(unitframe.SpellInterrupted.cooldown, GetTime(), duration, duration > 0, true);

    unitframe.SpellInterrupted.expTime  = GetTime() + duration;

    if CASTER_NAME_SHOW and source then
        unitframe.SpellInterrupted.casterName:SetText(UnitName(source));
        unitframe.SpellInterrupted.casterName:SetTextColor(GetUnitColor(source, 2));
        unitframe.SpellInterrupted.casterName:SetShown(true);
    else
        unitframe.SpellInterrupted.casterName:SetShown(false);
    end

    unitframe.SpellInterrupted:SetShown(true);
end

local function OnInterrupt(unitframe, spellId, sourceName, sourceGUID, destGUID)
    if not spellId then
        unitframe.SpellInterrupted.expTime  = 0;
        unitframe.SpellInterrupted.destGUID = nil;
        unitframe.SpellInterrupted:SetShown(false);
        return;
    end

    local duration = durations[spellId] or DEFAULT_DURATION;

    unitframe.SpellInterrupted.icon:SetTexture(GetSpellTexture(spellId));
    CooldownFrame_Set(unitframe.SpellInterrupted.cooldown, GetTime(), duration, duration > 0, true);

    unitframe.SpellInterrupted.expTime  = GetTime() + duration;
    unitframe.SpellInterrupted.destGUID = destGUID;

    if CASTER_NAME_SHOW and sourceName and sourceGUID then
        unitframe.SpellInterrupted.casterName:SetText(sourceName);
        unitframe.SpellInterrupted.casterName:SetTextColor(GetClassColorByGUID(sourceGUID, 2));
        unitframe.SpellInterrupted.casterName:SetShown(true);
    else
        unitframe.SpellInterrupted.casterName:SetShown(false);
    end

    unitframe.SpellInterrupted:SetShown(true);
end

function Module:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo();

    if subEvent == 'SPELL_INTERRUPT' then
        for _, unitframe in pairs(NP) do
            if unitframe:IsShown() and UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                OnInterrupt(unitframe, spellId, sourceName, sourceGUID, destGUID);
            end
        end
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.SpellInterrupted then
        unitframe.SpellInterrupted:SetShown(false);
    end
end

function Module:UnitAura(unitframe)
    UpdateByAura(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED          = O.db.spell_interrupted_icon;
    CASTER_NAME_SHOW = O.db.spell_interrupted_icon_caster_name_show;
    FRAME_STRATA     = O.db.spell_interrupted_icon_frame_strata ~= 1 and O.Lists.frame_strata[O.db.spell_interrupted_icon_frame_strata] or 1;

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