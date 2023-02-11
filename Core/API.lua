local S, L, O, U, D, E = unpack(select(2, ...));

StripesAPI = {};

StripesAPI.IsUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    return S:GetNameplateModule('Handler'):IsUnimportantUnit(unitId);
end

StripesAPI.AddUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    S:GetNameplateModule('Handler'):AddUnimportantUnit(unitId);
end

StripesAPI.RemoveUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    S:GetNameplateModule('Handler'):RemoveUnimportantUnit(unitId);
end