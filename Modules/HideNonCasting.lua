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

local function RecalculateVisibilityState(unitframe)
    if visibilityState then
        unitframe:SetShown(true);
        return;
    end

    local notInterruptible, spellId = select(8, UnitCastingInfo(unitframe.data.unit));

    if not spellId then
        notInterruptible, spellId = select(7, UnitChannelInfo(unitframe.data.unit));
    end

    if spellId then
        if SHOW_UNINTERRUPTIBLE or not notInterruptible then
            unitframe:SetShown(true);
            return;
        end
    end

    unitframe:SetShown(false);
end

local function ShowOnlyCastingNamePlates()
    visibilityState = false;

    for _, unitframe in pairs(NP) do
        RecalculateVisibilityState(unitframe);
    end
end

local function ShowAllNamePlates()
    visibilityState = true;

    for _, unitframe in pairs(NP) do
        RecalculateVisibilityState(unitframe);
    end
end

local function CheckCasting(unit)
    for _, unitframe in pairs(NP) do
        if unitframe.data.unit == unit then
            RecalculateVisibilityState(unitframe);
        end
    end
end

function Module:UnitAdded(unitframe)
    RecalculateVisibilityState(unitframe);
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
            ShowOnlyCastingNamePlates();
        else
            ShowAllNamePlates();
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
            ShowAllNamePlates();
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

    if ENABLED then
        self:Enable();
    end
end