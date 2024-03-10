local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('HideNonCasting');

-- Stripes API
local U_UnitIsCasting = U.UnitIsCasting;

-- Local Config
local ENABLED, SHOW_UNINTERRUPTIBLE, MODIFIER;

local modifiers = O.Lists.hide_non_casting_modifiers;
local visibilityState = true;

function Module:UpdateVisibility(unitframe)
    if visibilityState then
        unitframe:Show();
        return;
    end

    local spellId, notInterruptible = U_UnitIsCasting(unitframe.data.unit);

    unitframe:SetShown(spellId and (SHOW_UNINTERRUPTIBLE or not notInterruptible));
end

function Module:ShowOnlyCasting()
    visibilityState = false;

    self:ForAllActiveUnitFrames(function(unitframe)
        if unitframe.data.unit then
            self:UpdateVisibility(unitframe);
        end
    end);
end

function Module:ShowAll()
    visibilityState = true;

    self:ForAllActiveUnitFrames(function(unitframe)
        if unitframe.data.unit then
            self:UpdateVisibility(unitframe);
        end
    end);
end

function Module:CheckCasting(unit)
    self:ForAllActiveUnitFrames(function(unitframe)
        if unitframe.data.unit == unit then
            self:UpdateVisibility(unitframe);
        end
    end);
end

function Module:UnitAdded(unitframe)
    self:UpdateVisibility(unitframe);
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if key == modifiers[MODIFIER] then
        if down == 1 then
            self:ShowOnlyCasting();
        else
            self:ShowAll();
        end
    end
end

function Module:UpdateLocalConfig()
    ENABLED               = O.db.hide_non_casting_enabled;
    MODIFIER              = O.db.hide_non_casting_modifier;
    SHOW_UNINTERRUPTIBLE  = O.db.hide_non_casting_show_uninterruptible;

    if ENABLED then
        self:RegisterEvent('MODIFIER_STATE_CHANGED');
        self:RegisterEvent('UNIT_SPELLCAST_START', 'CheckCasting');
        self:RegisterEvent('UNIT_SPELLCAST_STOP', 'CheckCasting');
    else
        self:UnregisterEvent('MODIFIER_STATE_CHANGED');
        self:UnregisterEvent('UNIT_SPELLCAST_START');
        self:UnregisterEvent('UNIT_SPELLCAST_STOP');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end