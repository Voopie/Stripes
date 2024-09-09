local S, L, O, U, D, E = unpack((select(2, ...)));

StripesAPI = {};

StripesAPI.IsUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    if not unitId then
        return;
    end

    return StripesDB.UnimportantsUnits and StripesDB.UnimportantsUnits[unitId];
end

StripesAPI.AddUnimportantUnit = function(unitId)
    if unitId and not (type(unitId) == 'number') then
        unitId = tonumber(unitId);
    end

    if not unitId then
        return;
    end

    if StripesDB.UnimportantsUnits then
        StripesDB.UnimportantsUnits[unitId] = true;
    end
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

    if StripesDB.UnimportantsUnits and StripesDB.UnimportantsUnits[unitId] then
        StripesDB.UnimportantsUnits[unitId] = nil;
    end
end

StripesAPI.GetUnimportantUnits = function()
    return StripesDB.UnimportantsUnits;
end

StripesAPI.GetModule = function(moduleName)
    return S:GetModule(moduleName);
end

StripesAPI.GetNameplateModule = function(moduleName)
    return S:GetNameplateModule(moduleName);
end

StripesAPI.GetOptions = function()
    return O;
end

StripesAPI.GetUtility = function()
    return U;
end

StripesAPI.GetData = function()
    return D;
end

StripesAPI.GetElements = function()
    return E;
end

StripesAPI.GetAll = function()
    return S, L, O, U, D, E;
end