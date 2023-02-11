local S, L, O, U, D, E = unpack(select(2, ...));

StripesAPI = {};

StripesAPI.IsUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    if not unitId then
        return;
    end

    return S:GetNameplateModule('Handler'):IsUnimportantUnit(unitId);
end

StripesAPI.AddUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    if not unitId then
        return;
    end

    S:GetNameplateModule('Handler'):AddUnimportantUnit(unitId);
end

StripesAPI.AddBatchUnimportantUnits = function(...)
    local units = { ... };

    for _, unitId in ipairs(units) do
        StripesAPI.AddUnimportantUnit(unitId);
    end
end

StripesAPI.RemoveUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    if not unitId then
        return;
    end

    S:GetNameplateModule('Handler'):RemoveUnimportantUnit(unitId);
end

StripesAPI.GetUnimportantUnits = function()
    return S:GetNameplateModule('Handler'):GetUnimportantUnits();
end