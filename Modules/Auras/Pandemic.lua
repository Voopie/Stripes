local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Pandemic');

-- Lua API
local select, ipairs, table_wipe, bit_band = select, ipairs, wipe, bit.band;

-- WoW API
local UnitAura, GetSpellInfo, IsSpellKnown = UnitAura, GetSpellInfo, IsSpellKnown;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, PANDEMIC_COLOR;

local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

local knownSpells = {};

local function GetTrullySpellId(spellId)
    return select(7, GetSpellInfo(GetSpellInfo(spellId))); -- here we extract the spell name and then get needed spellId by spell name
end

--[[
    IsPlayerSpell(spellId), IsSpellKnown(spellId), IsSpellKnownOrOverridesKnown(spellId)
    Incorrectly returned false for some spells
]]

local function Update(unitframe)
    if not ENABLED or not COUNTDOWN_ENABLED or unitframe.data.unitType == 'SELF' or not unitframe.BuffFrame then
        return;
    end

    local _, duration, expirationTime, spellId, flags, cc;

    for _, buff in ipairs(unitframe.BuffFrame.buffList) do
        duration, expirationTime, _, _, _, spellId = select(5, UnitAura(unitframe.BuffFrame.unit, buff:GetID(), unitframe.BuffFrame.filter));

        if spellId and expirationTime and duration then
            flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);

            if not flags or not cc or not (bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0) then
                if expirationTime - GetTime() <= duration/100*30 and expirationTime - GetTime() >= 1 then
                    spellId = GetTrullySpellId(spellId);

                    if spellId and (knownSpells[spellId] or IsSpellKnown(spellId)) then
                        buff.Cooldown:GetRegions():SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4] or 1);

                        if not knownSpells[spellId] then
                            knownSpells[spellId] = true;
                        end
                    end
                else
                    buff.Cooldown:GetRegions():SetTextColor(1, 1, 1, 1);
                end
            end
        end
    end
end

local function Reset(unitframe)
    if unitframe.BuffFrame and unitframe.BuffFrame.buffList then
        for _, buff in ipairs(unitframe.BuffFrame.buffList) do
            buff.Cooldown:GetRegions():SetTextColor(1, 1, 1, 1);
        end
    end
end

function Module:UnitAdded(unitframe)
    if unitframe.data.unitType == 'SELF' then
        Reset(unitframe);
    else
        Update(unitframe);
    end
end

function Module:UnitRemoved(unitframe)
    Reset(unitframe);
end

function Module:Update(unitframe)
    Reset(unitframe);
    Update(unitframe);
end

function Module:UnitAura(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED           = O.db.auras_pandemic_enabled;
    COUNTDOWN_ENABLED = O.db.auras_countdown_enabled;

    PANDEMIC_COLOR    = PANDEMIC_COLOR or {}
    PANDEMIC_COLOR[1] = O.db.auras_pandemic_color[1];
    PANDEMIC_COLOR[2] = O.db.auras_pandemic_color[2];
    PANDEMIC_COLOR[3] = O.db.auras_pandemic_color[3];
    PANDEMIC_COLOR[4] = O.db.auras_pandemic_color[4] or 1;
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    table_wipe(knownSpells);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');

    self:SecureUnitFrameHook('CompactUnitFrame_UpdatePower', Update);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', Update);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealthBorder', Update);
end