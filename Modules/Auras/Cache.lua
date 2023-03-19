local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('Auras_Cache');

-- Lua API
local pairs, ipairs, type = pairs, ipairs, type;

-- WoW API
local AuraUtil_ForEachAura = AuraUtil.ForEachAura;
local C_UnitAuras_GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;

local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

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

    if byName then
        for _, aura in pairs(CACHE[unit]) do
            if aura.name == spellId then
                return aura;
            end
        end
    else
        for _, aura in pairs(CACHE[unit]) do
            if aura.spellId == spellId then
                return aura;
            end
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

function Module:FullUpdate(unit)
    self:FlushUnit();

    local function HandleAura(aura)
        if aura then
            self:Add(unit, aura);
        end

        return false;
    end

    AuraUtil_ForEachAura(unit, filterHarmful, nil, HandleAura, true);
    AuraUtil_ForEachAura(unit, filterHelpful, nil, HandleAura, true);
end

function Module:ProcessAuras(unit, unitAuraUpdateInfo)
    if not unit then
        return;
    end

    if unitAuraUpdateInfo == nil then
        self:FullUpdate(unit);
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                self:Add(unit, aura);
            end
        end

        if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                if self:CheckAuraInstanceID(unit, auraInstanceID) then
                    local newAura = C_UnitAuras_GetAuraDataByAuraInstanceID(unit, auraInstanceID);
                    CACHE[unit][auraInstanceID] = newAura;
                end
            end
        end

        if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
            for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                if self:CheckAuraInstanceID(unit, auraInstanceID) then
                    CACHE[unit][auraInstanceID] = nil;
                end
            end
        end
    end
end

function Module:FlushAll()
    CACHE = {};
end

function Module:FlushUnit(unit)
    if CACHE[unit] then
        CACHE[unit] = {};
    end
end