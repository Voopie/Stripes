local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Sort');

-- Lua API
local select, ipairs, tonumber, table_sort, table_wipe = select, ipairs, tonumber, table.sort, wipe;

-- WoW API
local UnitAura = UnitAura;

-- Local Config
local IS_ACTIVE, ENABLED, SORT_METHOD, SPACING_X, AURAS_DIRECTION;

local function SortMethodFunction(a, b)
    if not a.expires or not b.expires then
        return;
    end

    if SORT_METHOD == 1 then      -- EXPIRES ASC
        return a.expires < b.expires;
    elseif SORT_METHOD == 2 then  -- EXPIRES DESC
        return a.expires > b.expires;
    end
end

local function SortBuffs(unitframe)
    if not IS_ACTIVE or not ENABLED or unitframe.data.unitType == 'SELF' then
        return;
    end

    if not unitframe.BuffFrame or not unitframe.BuffFrame.buffList or not unitframe.BuffFrame.unit or not unitframe.BuffFrame.filter then
        return;
    end

    if not unitframe.SortBuffs then
        unitframe.SortBuffs = {};
    else
        table_wipe(unitframe.SortBuffs);
    end

    local expirationTime;
    for buffIndex, aura in ipairs(unitframe.BuffFrame.buffList) do
        if unitframe.BuffFrame.buffList[buffIndex]:IsShown() then
            expirationTime = select(6, UnitAura(unitframe.BuffFrame.unit, aura:GetID(), unitframe.BuffFrame.filter));

            unitframe.SortBuffs[buffIndex]           = unitframe.SortBuffs[buffIndex] or {};
            unitframe.SortBuffs[buffIndex].buffIndex = buffIndex;
            unitframe.SortBuffs[buffIndex].expires   = tonumber(expirationTime) or 0;
        end
    end

    if #unitframe.SortBuffs > 0 then
        table_sort(unitframe.SortBuffs, SortMethodFunction);

        for i, data in ipairs(unitframe.SortBuffs) do
            if unitframe.BuffFrame.buffList[data.buffIndex] then
                unitframe.BuffFrame.buffList[data.buffIndex]:ClearAllPoints();

                if AURAS_DIRECTION == 1 then
                    unitframe.BuffFrame.buffList[data.buffIndex]:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                else
                    unitframe.BuffFrame.buffList[data.buffIndex]:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                end
            end
        end
    end
end

function Module:UnitAdded(unitframe)
    SortBuffs(unitframe);
end

function Module:UnitAura(unitframe)
    SortBuffs(unitframe);
end

function Module:Update(unitframe)
    SortBuffs(unitframe);
end

function Module:UpdateLocalConfig()
    IS_ACTIVE       = O.db.auras_is_active;
    ENABLED         = O.db.auras_sort_enabled;
    SORT_METHOD     = O.db.auras_sort_method;
    SPACING_X       = O.db.auras_spacing_x or 4;
    AURAS_DIRECTION = O.db.auras_direction;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end