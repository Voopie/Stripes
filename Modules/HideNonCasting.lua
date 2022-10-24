local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('HideNonCasting');

-- Lua API
local select = select;

-- WoW API
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo;

-- Nameplates frames
local NP = S.NamePlates;

-- Local Config
local ENABLED, SHOW_UNINTERRUPTIBLE, MODIFIER;

local modifiers = O.Lists.hide_non_casting_modifiers;
local visibilityState = true;

local function UpdateVisibility(unitframe)
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

local function ShowOnlyCasting()
    visibilityState = false;

    for _, unitframe in pairs(NP) do
        UpdateVisibility(unitframe);
    end
end

local function ShowAll()
    visibilityState = true;

    for _, unitframe in pairs(NP) do
        UpdateVisibility(unitframe);
    end
end

local function CheckCasting(unit)
    for _, unitframe in pairs(NP) do
        if unitframe.data.unit == unit then
            UpdateVisibility(unitframe);
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
        self:Enable();
    else
        self:Disable();
    end
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if key == modifiers[MODIFIER] then
        if down == 1 then
            ShowOnlyCasting();
        else
            ShowAll();
        end
    end
end

local KeyChecker = CreateFrame('Frame', nil, UIParent);

function Module:Enable()
    self:RegisterEvent('MODIFIER_STATE_CHANGED');
    self:RegisterEvent('UNIT_SPELLCAST_START', CheckCasting);
    self:RegisterEvent('UNIT_SPELLCAST_STOP', CheckCasting);

    KeyChecker:SetScript('OnKeyDown', function(_, key)
        if ENABLED and key == 'TAB' then
            ShowAll();
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