local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Filter');

-- Local Config
local ENABLED;

local units = {
    ['player']  = true,
    ['pet']     = true,
    ['vehicle'] = true,
};

local function FilterShouldShowBuff(self, name, caster, nameplateShowPersonal, nameplateShowAll)
    if not name then
        return false;
    end

    if ENABLED and self:GetParent().data.unitType ~= 'SELF' then
        return units[caster];
    else
        return nameplateShowAll or (nameplateShowPersonal and units[caster]);
    end
end

local function Update(unitframe)
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;

    if unitframe.BuffFrame.unit and unitframe.BuffFrame.filter then
        unitframe.BuffFrame:UpdateBuffs(unitframe.BuffFrame.unit, unitframe.BuffFrame.filter, unitframe.data.unitType == 'FRIENDLY_PLAYER');
    end
end

function Module:UnitAdded(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.auras_filter_player_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end