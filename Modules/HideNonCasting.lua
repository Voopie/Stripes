local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('HideNonCasting');

-- Stripes API
local U_UnitIsCasting = U.UnitIsCasting;

-- Local Config
local ENABLED, SHOW_UNINTERRUPTIBLE, MODIFIER;

local modifiers = O.Lists.hide_non_casting_modifiers;
local visibilityState = true;

local function UpdateVisibility(unitframe)
    if visibilityState then
        if not unitframe:IsShown() then
            unitframe:Show();
        end

        return;
    end

    local spellId, notInterruptible = U_UnitIsCasting(unitframe.data.unit);

    unitframe:SetShown(spellId and (SHOW_UNINTERRUPTIBLE or not notInterruptible));
end

local function ShowOnlyCasting()
    visibilityState = false;

    Module:ForAllActiveUnitFrames(function(unitframe)
        if unitframe.data.unit then
            UpdateVisibility(unitframe);
        end
    end);
end

local function ShowAll()
    visibilityState = true;

    Module:ForAllActiveUnitFrames(function(unitframe)
        if unitframe.data.unit then
            UpdateVisibility(unitframe);
        end
    end);
end

local function CheckCasting(unit)
    Module:ProcessNamePlateForUnit(unit, UpdateVisibility);
end

local function OnModifierChanged(key, down)
    if key == modifiers[MODIFIER] then
        if down == 1 then
            ShowOnlyCasting();
        else
            ShowAll();
        end
    end
end

function Module:UnitAdded(unitframe)
    UpdateVisibility(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED               = O.db.hide_non_casting_enabled;
    MODIFIER              = O.db.hide_non_casting_modifier;
    SHOW_UNINTERRUPTIBLE  = O.db.hide_non_casting_show_uninterruptible;

    if ENABLED then
        self:RegisterEvent('MODIFIER_STATE_CHANGED', OnModifierChanged);
        self:RegisterEvent('UNIT_SPELLCAST_START', CheckCasting);
        self:RegisterEvent('UNIT_SPELLCAST_STOP', CheckCasting);
    else
        self:UnregisterEvent('MODIFIER_STATE_CHANGED');
        self:UnregisterEvent('UNIT_SPELLCAST_START');
        self:UnregisterEvent('UNIT_SPELLCAST_STOP');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end