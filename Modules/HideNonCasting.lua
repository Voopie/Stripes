local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('HideNonCasting');

-- Lua API
local select = select;

-- WoW API
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo;

-- Local Config
local ENABLED, SHOW_UNINTERRUPTIBLE, MODIFIER;

local modifiers = O.Lists.hide_non_casting_modifiers;
local visibilityState = true;

function Module:UpdateVisibility(unitframe)
    if visibilityState then
        unitframe:Show();
        return;
    end

    local notInterruptible, spellId = select(8, UnitCastingInfo(unitframe.data.unit));

    if not spellId then
        notInterruptible, spellId = select(7, UnitChannelInfo(unitframe.data.unit));
    end

    if spellId then
        if SHOW_UNINTERRUPTIBLE or not notInterruptible then
            unitframe:Show();
            return;
        end
    end

    unitframe:Hide();
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

function Module:UpdateLocalConfig()
    ENABLED               = O.db.hide_non_casting_enabled;
    MODIFIER              = O.db.hide_non_casting_modifier;
    SHOW_UNINTERRUPTIBLE  = O.db.hide_non_casting_show_uninterruptible;

    if ENABLED then
        self:Enable();
    else
        self:Disable();
    end
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

local KeyChecker = CreateFrame('Frame', nil, UIParent);

function Module:Enable()
    self:RegisterEvent('MODIFIER_STATE_CHANGED');
    self:RegisterEvent('UNIT_SPELLCAST_START', 'CheckCasting');
    self:RegisterEvent('UNIT_SPELLCAST_STOP', 'CheckCasting');

    KeyChecker:SetScript('OnKeyDown', function(_, key)
        if ENABLED and key == 'TAB' then
            self:ShowAll();
        end
    end);
    KeyChecker:SetPropagateKeyboardInput(true);
end

function Module:Disable()
    self:UnregisterEvent('MODIFIER_STATE_CHANGED');
    self:UnregisterEvent('UNIT_SPELLCAST_START');
    self:UnregisterEvent('UNIT_SPELLCAST_STOP');

    KeyChecker:SetScript('OnKeyDown', nil);
    KeyChecker:SetPropagateKeyboardInput(false);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end