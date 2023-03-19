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
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

local INTERRUPTED_FORMAT = '|cff%s%s! [%s]|r';

local blacklist = {
    [197214] = true, -- Sundering (Shaman Enhancement talent)
};

local function OnInterrupt(unitframe, guid, sourceName)
    if guid and guid ~= '' then
        local _, englishClass, _, _, _, name = GetPlayerInfoByGUID(guid);
        if name then
            name = GetCachedName(name, true, true, false);
            unitframe.castingBar.Text:SetText(string_format(INTERRUPTED_FORMAT, U_GetClassColor(englishClass, 1), INTERRUPTED, name));
        else
            if U_UnitIsPetByGUID(guid) then
                name = GetCachedName(sourceName, true, true, false);
                unitframe.castingBar.Text:SetText(string_format(INTERRUPTED_FORMAT, U_GetClassColor(sourceName, 1), INTERRUPTED, name));
            end
        end
    end
end

function Module:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo();

    if subEvent == 'SPELL_INTERRUPT' then
        self:ForAllActiveUnitFrames(function(unitframe)
            if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                OnInterrupt(unitframe, sourceGUID, sourceName);
            end
        end);
    elseif subEvent == 'SPELL_AURA_APPLIED' and not blacklist[spellId] then
        local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
        if flags and cc and bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0 then
            self:ForAllActiveUnitFrames(function(unitframe)
                if UnitExists(unitframe.data.unit) and unitframe.data.unitGUID == destGUID then
                    OnInterrupt(unitframe, sourceGUID, sourceName);
                end
            end);
        end
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
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
end

function Module:Disable()
    self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
end

function Module:StartUp()
    self:UpdateLocalConfig();
end