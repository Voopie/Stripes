local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('Auras_Cache');

-- Lua API
local pairs, ipairs, type = pairs, ipairs, type;

-- WoW API
local AuraUtil_ForEachAura = AuraUtil.ForEachAura;
local C_UnitAuras_GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;

local CACHE = {};

function Module:Add(unit, aura)
    if not (unit and aura) then
        return;
    end

    if not CACHE[unit] then
        CACHE[unit] = {};
    end

    CACHE[unit][aura.auraInstanceID] = aura;
end

function Module:Get(unit, spellId)
    if not CACHE[unit] then
        return;
    end

    local byName = type(spellId) == 'string';

    for _, aura in pairs(CACHE[unit]) do
        if (byName and aura.name == spellId) or (not byName and aura.spellId == spellId) then
            return aura;
        end
    end
end

function Module:GetAll(unit)
    if not CACHE[unit] then
        return;
    end

    return CACHE[unit];
end

function Module:CheckAuraInstanceID(unit, auraInstanceID)
    return CACHE[unit] and CACHE[unit][auraInstanceID] ~= nil;
end

function Module:FlushAll()
    CACHE = {};
end

function Module:FlushUnit(unit)
    if CACHE[unit] then
        CACHE[unit] = {};
    end
end

function Module:FullUpdate(unit)
    self:FlushUnit();

    local function HandleAura(aura)
        if aura then
            self:Add(unit, aura);
        end

        return false;
    end

    AuraUtil_ForEachAura(unit, 'HARMFUL', nil, HandleAura, true);
    AuraUtil_ForEachAura(unit, 'HELPFUL', nil, HandleAura, true);
end

function Module:UpdateAura(unit, auraInstanceID)
    if not self:CheckAuraInstanceID(unit, auraInstanceID) then
        return;
    end

    local newAura = C_UnitAuras_GetAuraDataByAuraInstanceID(unit, auraInstanceID);
    if newAura then
        CACHE[unit][auraInstanceID] = newAura;
    end
end

function Module:RemoveAura(unit, auraInstanceID)
    if not self:CheckAuraInstanceID(unit, auraInstanceID) then
        return;
    end

    CACHE[unit][auraInstanceID] = nil;
end

function Module:ProcessAuras(unit, unitAuraUpdateInfo)
    if not unit then
        return;
    end

    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
        self:FullUpdate(unit);
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                self:Add(unit, aura);
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                self:UpdateAura(unit, auraInstanceID);
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                self:RemoveAura(unit, auraInstanceID);
            end
        end
    end
end