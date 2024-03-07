local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('WhoInterrupted');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local string_format, bit_band = string.format, bit.band;

-- WoW API
local UnitExists, GetPlayerInfoByGUID = UnitExists, GetPlayerInfoByGUID;

-- WoW Global string
local INTERRUPTED = INTERRUPTED;

-- Stripes API
local U_GetClassColor = U.GetClassColor;
local U_UnitIsPetByGUID = U.UnitIsPetByGUID;
local GetCachedName = Stripes.GetCachedName;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local LPS_CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.STUN);
local LPS_CROWD_CTRL = LPS.constants.CROWD_CTRL;

local INTERRUPTED_FORMAT = '|cff%s%s! [%s]|r';

local blacklist = {
    [197214] = true, -- Sundering (Shaman Enhancement talent)
};

local function OnInterrupt(unitframe, sourceGUID, sourceName)
    if not sourceGUID or sourceGUID == '' or not unitframe.castingBar then
        return;
    end

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

        unitframe.castingBar.Text:SetText(string_format(INTERRUPTED_FORMAT, U_GetClassColor(casterNameUnit, 1), INTERRUPTED, casterNameText));
    end
end

local function HandleCombatLogEvent()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo();

    local isInterrupt   = subEvent == 'SPELL_INTERRUPT';
    local isAuraApplied = subEvent == 'SPELL_AURA_APPLIED' and not blacklist[spellId];

    if not (isInterrupt or isAuraApplied) then
        return;
    end

    local isCrowdControl = false;

    if isAuraApplied then
        local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
        isCrowdControl = flags and cc and bit_band(flags, LPS_CROWD_CTRL) > 0 and bit_band(cc, LPS_CC_TYPES) > 0;
    end

    if isInterrupt or isCrowdControl then
        Module:ForAllActiveUnitFrames(function(unitframe)
            if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                OnInterrupt(unitframe, sourceGUID, sourceName);
            end
        end);
    end
end

function Module:UpdateLocalConfig()
    if O.db.who_interrupted_enabled then
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