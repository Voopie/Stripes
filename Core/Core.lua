local ADDON_NAME, NAMESPACE = ...;

-- Lua API
local ipairs, pairs, tostring, table_insert, table_remove = ipairs, pairs, tostring, table.insert, table.remove;

-- WoW API
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;

local locale = GetLocale();
local convert = {
    enGB = 'enUS',
    ptPT = 'ptBR',
};
local gameLocale = convert[locale] or locale or 'enUS';

local AddOn = CreateFrame('Frame');
AddOn:SetScript('OnEvent', function(self, event, ...)
    if self[event] then
        return self[event](self, ...);
    end
end);

local EN_I18N = NAMESPACE[2]['enUS'];

NAMESPACE[1] = AddOn;                    -- AddOn
NAMESPACE[2] = NAMESPACE[2][gameLocale] or EN_I18N; -- Locale
NAMESPACE[3] = {};                       -- Options
NAMESPACE[4] = {};                       -- Utility
NAMESPACE[5] = {};                       -- Data
NAMESPACE[6] = {};                       -- Elements

local S, L, O, U, D, E = unpack(NAMESPACE);

local L = setmetatable(NAMESPACE[2], {
    __index = function(t, k)
        t[k] = tostring(k);
        return t[k];
    end
});

AddOn.AddonName        = ADDON_NAME;
AddOn.Title            = GetAddOnMetadata(ADDON_NAME, 'Title');
AddOn.Version          = GetAddOnMetadata(ADDON_NAME, 'Version');
AddOn.ClientLocale     = gameLocale;
AddOn.Modules          = {};
AddOn.NameplateModules = {};
AddOn.NamePlates       = {};
AddOn.UnitFrames       = {};
AddOn.Debug            = false;

local NP = AddOn.NamePlates;
local UF = AddOn.UnitFrames;

AddOn.Libraries = {
    CH  = LibStub('CallbackHandler-1.0'),
    LSM = LibStub('LibSharedMedia-3.0'),
    LCG = LibStub('LibCustomGlow-1.0'),
    LPS = LibStub('LibPlayerSpells-1.0'),
    LT  = LibStub('LibTranslit-1.0'),
    LDC = LibStub('LibDiacritics'),

    LibSerialize = LibStub('LibSerialize'),
    LibDeflate   = LibStub('LibDeflate'),
};

local Eventer = {};

Eventer.frame     = CreateFrame('Frame', 'Stripes_Eventer', UIParent);
Eventer.frameUnit = CreateFrame('Frame', 'Stripes_Eventer_Unit', UIParent);

Eventer.frame.embeds         = {};
Eventer.frameUnit.embedsUnit = {};
Eventer.frame.addons         = {};

local embeds     = Eventer.frame.embeds;
local embedsUnit = Eventer.frameUnit.embedsUnit;
local addons     = Eventer.frame.addons;

Eventer.frame:SetScript('OnEvent', function(_, eventName, ...)
    if not embeds[eventName] then
        return;
    end

    for _, entry in ipairs(embeds[eventName]) do
        for registeredCallback, registeredFunction in pairs(entry) do
            if registeredFunction == 0 then
                registeredCallback[eventName](registeredCallback, ...);
            else
                if registeredCallback[registeredFunction] then
                    registeredCallback[registeredFunction](registeredCallback, ...);
                else
                    registeredFunction(...);
                end
            end
        end
    end
end);

Eventer.frameUnit:SetScript('OnEvent', function(_, eventName, ...)
    if not embedsUnit[eventName] then
        return;
    end

    for _, entry in ipairs(embedsUnit[eventName]) do
        for registeredCallback, registeredFunction in pairs(entry) do
            if registeredFunction == 0 then
                registeredCallback[eventName](registeredCallback, ...);
            else
                if registeredCallback[registeredFunction] then
                    registeredCallback[registeredFunction](registeredCallback, ...);
                else
                    registeredFunction(...);
                end
            end
        end
    end
end);

function Eventer:RegisterEvent(eventName, eventCallback, eventFunction)
    if self:IsEventRegistered(eventName, eventCallback) then
        return;
    end

    if eventFunction == nil then
        eventFunction = 0;
    end

    if embeds[eventName] == nil then
        embeds[eventName] = {};
        Eventer.frame:RegisterEvent(eventName);
    end

    table_insert(embeds[eventName], { [eventCallback] = eventFunction });
end

function Eventer:IsEventRegistered(eventName, eventCallback)
    if not embeds[eventName] then
        return false;
    end

    for _, entry in ipairs(embeds[eventName]) do
        for registeredCallback, _ in pairs(entry) do
            if registeredCallback == eventCallback then
                return true;
            end
        end
    end

    return false;
end

function Eventer:IsUnitEventRegistered(eventName, eventCallback)
    if not embedsUnit[eventName] then
        return false;
    end

    for _, entry in ipairs(embedsUnit[eventName]) do
        for registeredCallback, _ in pairs(entry) do
            if registeredCallback == eventCallback then
                return true;
            end
        end
    end

    return false;
end

function Eventer:RegisterUnitEvent(eventName, eventCallback, unit1, unit2, func)
    if func == nil then
        func = 0;
    end

    unit1 = unit1 or 'player';

    if embedsUnit[eventName] == nil then
        embedsUnit[eventName] = {};

        if unit2 and unit2 ~= '' then
            Eventer.frameUnit:RegisterUnitEvent(eventName, unit1, unit2);
        else
            Eventer.frameUnit:RegisterUnitEvent(eventName, unit1);
        end
    end

    table_insert(embedsUnit[eventName], { [eventCallback] = func });
end

function Eventer:UnregisterEvent(eventName, eventCallback)
    if not embeds[eventName] then
        return;
    end

    if not self:IsEventRegistered(eventName, eventCallback) then
        return;
    end

    for i, entry in ipairs(embeds[eventName]) do
        for registeredCallback, _ in pairs(entry) do
            if registeredCallback == eventCallback then
                table_remove(embeds[eventName], i);
            end
        end
    end

    if #embeds[eventName] == 0 then
        embeds[eventName] = nil;
        Eventer.frame:UnregisterEvent(eventName);
    end
end

function Eventer:UnregisterUnitEvent(eventName, eventCallback)
    if not embedsUnit[eventName] then
        return;
    end

    for i, entry in ipairs(embedsUnit[eventName]) do
        for registeredCallback, _ in pairs(entry) do
            if registeredCallback == eventCallback then
                table_remove(embedsUnit[eventName], i)
            end
        end
    end

    if #embedsUnit[eventName] == 0 then
        embedsUnit[eventName] = nil;
        Eventer.frameUnit:UnregisterEvent(eventName);
    end
end

function Eventer:ADDON_LOADED(addonName)
    if not addons[addonName] then
        return;
    end

    for _, entry in ipairs(addons[addonName]) do
        for registeredCallback, registeredFunction in pairs(entry) do
            if registeredFunction == 0 then
                registeredCallback[addonName](registeredCallback);
            else
                if registeredCallback[registeredFunction] then
                    registeredCallback[registeredFunction](registeredCallback, addonName);
                else
                    registeredFunction(addonName);
                end
            end

            if registeredFunction or registeredFunction == 0 or registeredCallback[registeredFunction] then
                self:UnregisterAddon(addonName, registeredCallback, registeredFunction);
            end
        end
    end
end

function Eventer:RegisterAddon(addonName, addonCallback, addonFunction)
    if addonFunction == nil then
        addonFunction = 0;
    end

    if IsAddOnLoaded(addonName) then
        if addonFunction == 0 then
            addonCallback[addonName](addonCallback);
        else
            if addonCallback[addonFunction] then
                addonCallback[addonFunction](addonCallback, addonName);
            else
                addonFunction(addonName);
            end
        end
    else
        self:RegisterEvent('ADDON_LOADED', self);

        if addons[addonName] == nil then
            addons[addonName] = {};
        end

        table_insert(addons[addonName], { [addonCallback] = addonFunction });
    end
end

function Eventer:UnregisterAddon(addonName, addonCallback, addonFunction)
    if not addons[addonName] then
        return;
    end

    if addonFunction == nil then
        addonFunction = 0;
    end

    for i, entry in ipairs(addons[addonName]) do
        for registeredCallback, registeredFunction in pairs(entry) do
            if registeredCallback == addonCallback and registeredFunction == addonFunction then
                table_remove(addons[addonName], i);
                break;
            end
        end
    end

    if #addons[addonName] == 0 then
        addons[addonName] = nil;
    end
end

AddOn.Eventer = Eventer;

local ModuleMixin = {};

function ModuleMixin:RegisterEvent(eventName, func)
    Eventer:RegisterEvent(eventName, self, func);
end

function ModuleMixin:UnregisterEvent(eventName)
    Eventer:UnregisterEvent(eventName, self);
end

function ModuleMixin:IsEventRegistered(eventName)
    return Eventer:IsEventRegistered(eventName, self);
end

function ModuleMixin:RegisterUnitEvent(eventName, unit1, unit2, func)
    Eventer:RegisterUnitEvent(eventName, self, unit1, unit2, func);
end

function ModuleMixin:UnregisterUnitEvent(eventName)
    Eventer:UnregisterUnitEvent(eventName, self);
end

function ModuleMixin:IsUnitEventRegistered(eventName)
    return Eventer:IsUnitEventRegistered(eventName, self);
end

function ModuleMixin:RegisterAddon(addonName, func)
    Eventer:RegisterAddon(addonName, self, func);
end

function ModuleMixin:UnregisterAddon(addonName)
    Eventer:UnregisterAddon(addonName, self);
end

function ModuleMixin:CheckNamePlate(nameplate)
    if NP[nameplate] then
        return true;
    end

    return false;
end

function ModuleMixin:GetNamePlate(nameplate)
    return NP[nameplate];
end

function ModuleMixin:CheckUnitFrame(unitframe)
    for _, frame in pairs(NP) do
        if frame == unitframe and frame.isActive then
            return true;
        end
    end

    return false;
end

function ModuleMixin:GetUnitFrame(unitframe)
    for _, frame in pairs(NP) do
        if frame == unitframe and frame.isActive then
            return frame;
        end
    end
end

function ModuleMixin:ForAllUnitFrames(func)
    for _, frame in pairs(NP) do
        func(frame);
    end
end

function ModuleMixin:ForAllActiveUnitFrames(func)
    for _, frame in pairs(NP) do
        if frame.isActive and frame:IsShown() then
            func(frame);
        end
    end
end

function ModuleMixin:ProcessNamePlateForUnit(unit, func)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);

    if not nameplate or not NP[nameplate] then
        return;
    end

    func(NP[nameplate]);
end

function ModuleMixin:AddedNamePlateForUnit(unit, func)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit);
    local unitframe = nameplate and nameplate.UnitFrame;

    if not unitframe then
        return;
    end

    NP[nameplate] = unitframe;

    func(unitframe);
end

function ModuleMixin:SecureHook(objectName, methodName, func)
    if not _G[objectName] then
        error('SecureHook: «' .. objectName.. '» is not exists! («' .. self.Name .. '»)');
    end

    if self.Hooks[objectName] and self.Hooks[objectName][methodName] then
        error('SecureHook: «' .. objectName .. '.' .. methodName .. ' » was already hooked in «' .. self.Name .. '» module!');
    end

    self.Hooks[objectName] = self.Hooks[objectName] or {};
    self.Hooks[objectName][methodName] = true;

    hooksecurefunc(_G[objectName], methodName, func);
end

function ModuleMixin:SecureUnitFrameHook(name, func1, func2, func3)
    if not _G[name] then
        error('SecureUnitFrameHook: «' .. name.. '» is not exists! («' .. self.Name .. '»)');
    end

    if self.Hooks[name] then
        error('SecureUnitFrameHook: «' .. name.. '» was already hooked in «' .. self.Name .. '» module!');
    end

    if func3 then
        self.Hooks[name] = function(...)
            func1(...);
            func2(...);
            func3(...);
        end
    elseif func2 then
        self.Hooks[name] = function(...)
            func1(...);
            func2(...);
        end
    else
        self.Hooks[name] = func1;
    end

    if type(self.Hooks[name]) == 'table' then
        for hookMethod, hookFunc2 in pairs(self.Hooks[name]) do
            hooksecurefunc(_G[name], hookMethod, function(unitframe)
                if self:CheckUnitFrame(unitframe) then
                    hookFunc2(unitframe);
                end
            end);
        end
    else
        hooksecurefunc(name, function(unitframe)
            if self:CheckUnitFrame(unitframe) then
                self.Hooks[name](unitframe);
            end
        end);
    end
end

local Modules          = AddOn.Modules;
local NameplateModules = AddOn.NameplateModules;

function AddOn:NewModule(name)
    local object = {};

    Modules[name] = object;
    table_insert(Modules, object);

    Mixin(object, ModuleMixin);

    object.Name  = name;
    object.Hooks = {};

    return object;
end

function AddOn:GetModule(name)
    return Modules[name] or error('Invalid module name: ' .. name);
end

function AddOn:ForAllModules(event, ...)
    for _, m in ipairs(Modules) do
        if m[event] then
            m[event](m, ...);
        end
    end
end

function AddOn:NewNameplateModule(name)
    local object = {};

    NameplateModules[name] = object;
    table_insert(NameplateModules, object);

    Mixin(object, ModuleMixin);

    object.Name  = name;
    object.Hooks = {};

    return object;
end

function AddOn:GetNameplateModule(name)
    return NameplateModules[name] or error('Invalid nameplate module name: ' .. name);
end

function AddOn:ForAllNameplateModules(event, ...)
    for _, m in ipairs(NameplateModules) do
        if m[event] then
            m[event](m, ...);
        end
    end
end

local MinimapButton = {};
local LDB = LibStub('LibDataBroker-1.1', true);
local LDBIcon = LDB and LibStub('LibDBIcon-1.0', true);

do
    local defaultCoords  = { 0, 1, 0, 1 };
    local deltaX, deltaY = 0, 0;

    MinimapButton.UpdateCoord = function(self)
        local coords = self:GetParent().dataObject.iconCoords or defaultCoords;
        self:SetTexCoord(coords[1] + deltaX, coords[2] - deltaX, coords[3] + deltaY, coords[4] - deltaY);
    end
end

MinimapButton.Initialize = function()
    if not LDB then
        return;
    end

    local LDB_Stripes = LDB:NewDataObject('Stripes', {
        type          = 'launcher',
        text          = 'Stripes',
        icon          = NAMESPACE[1].Media.LOGO_MINI,
        OnClick       = MinimapButton.OnClick,
        OnTooltipShow = MinimapButton.OnTooltipShow,
    });

    if LDBIcon then
        LDBIcon:Register('Stripes', LDB_Stripes, StripesDB.minimap_button);

        if not StripesDB.minimap_button.hide then
            LDBIcon:GetMinimapButton('Stripes').icon.UpdateCoord = MinimapButton.UpdateCoord;
            LDBIcon:GetMinimapButton('Stripes').icon:UpdateCoord();
        end

        LDBIcon:AddButtonToCompartment('Stripes');
    end
end

MinimapButton.ToggleShown = function()
    StripesDB.minimap_button.hide = not StripesDB.minimap_button.hide;

    if StripesDB.minimap_button.hide then
        LDBIcon:Hide('Stripes');
        U.Print(L['MINIMAP_BUTTON_COMMAND_SHOW']);
    else
        LDBIcon:Show('Stripes');
        LDBIcon:GetMinimapButton('Stripes').icon.UpdateCoord = MinimapButton.UpdateCoord;
        LDBIcon:GetMinimapButton('Stripes').icon:UpdateCoord();
    end
end

MinimapButton.OnClick = function(_, button)
    if button == 'LeftButton' then
        NAMESPACE[3]:ToggleOptions();
    elseif button == 'RightButton' then
        MinimapButton:ToggleShown();
    end
end

MinimapButton.OnTooltipShow = function(tooltip)
    tooltip:AddDoubleLine(AddOn.Media.GRADIENT_NAME, AddOn.Version);
    tooltip:AddLine(' ');
    tooltip:AddDoubleLine(L['MINIMAP_BUTTON_LMB'], L['MINIMAP_BUTTON_OPEN'], 1, 0.85, 0, 1, 1, 1);
    tooltip:AddDoubleLine(L['MINIMAP_BUTTON_RMB'], L['MINIMAP_BUTTON_HIDE'], 1, 0.85, 0, 1, 1, 1);
    tooltip:AddLine(' ');
    tooltip:AddDoubleLine(L['MINIMAP_ACTIVE_PROFILE'], NAMESPACE[3].activeProfileName, 1, 0.85, 0, 1, 1, 1);
end

StaticPopupDialogs['STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON'] = {
    text    = L['OPTIONS_INCOMPATIBLE_NAMEPLATES_ADDON'],
    button1 = OKAY,
    button2 = L['OPTIONS_DONT_WARN_ME'],
    OnCancel = function()
        StripesDB.dontWarnAddons = true;
    end,
    hideOnEscape = true,
    whileDead = 1,
    preferredIndex = STATICPOPUPS_NUMDIALOGS,
};

function AddOn:CheckIncompatibleAddons()
    if StripesDB.dontWarnAddons then
        return;
    end

    if IsAddOnLoaded('Plater') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'Plater Nameplates');
        return;
    end

    if IsAddOnLoaded('ElvUI') and (ElvUI[1] and ElvUI[1].private and ElvUI[1].private.nameplates and ElvUI[1].private.nameplates.enable) then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'ElvUI Nameplates');
        return;
    end

    if IsAddOnLoaded('Kui_Nameplates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'KuiNameplates');
        return;
    end

    if IsAddOnLoaded('ThreatPlates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'ThreatPlates');
        return;
    end

    if IsAddOnLoaded('TidyPlates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'TidyPlates');
        return;
    end

    if IsAddOnLoaded('NeatPlates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'NeatPlates');
        return;
    end

    if IsAddOnLoaded('nPlates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'nPlates');
        return;
    end

    if IsAddOnLoaded('PhantomPlates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'PhantomPlates');
        return;
    end

    if IsAddOnLoaded('Nameplates') then
        StaticPopup_Show('STRIPES_INCOMPATIBLE_NAMEPLATES_ADDON', 'namePlateM+');
        return;
    end
end

AddOn:RegisterEvent('ADDON_LOADED');


-- Modified code from WeakAuras (https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAurasOptions/Cache.lua)
-- It will only be rebuilt if the client build number and locale changes
local string_find, string_lower = string.find, string.lower;
local GetSpellInfo = GetSpellInfo;
local SpellCache, SpellCacheMetaData, SpellCacheCoroutine;

local SpellCacheUpdater = CreateFrame('Frame');
SpellCacheUpdater:Hide();
SpellCacheUpdater:SetScript('OnUpdate', function()
    -- Start timing
    local start = debugprofilestop();

    -- Resume as often as possible (Limit to 16ms per frame -> 60 FPS)
    while debugprofilestop() - start < 16 do
        if coroutine.status(SpellCacheCoroutine) ~= 'dead' then
            local ok, msg = coroutine.resume(SpellCacheCoroutine);
            if not ok then
                geterrorhandler()(msg .. '\n' .. debugstack(SpellCacheCoroutine));
            end
        else
            SpellCacheUpdater:Hide();
            O.frame.Right.Auras:Update();
        end
    end
end);

SpellCacheUpdater.blockedSpellNames = {
    ['dnt']    = true,
    ['[dnd]']  = true,
    ['test']   = true,
    ['unused'] = true,
    ['reuse']  = true,
    ['resue']  = true, -- yep...
    ['[ph]']   = true,
    ['nyi']    = true,
    ['loot']   = true,
    ['boss']   = true,
};

function SpellCacheUpdater.isBlockedName(name)
    for blockedName, status in pairs(SpellCacheUpdater.blockedSpellNames) do
        if status and string_find(name, blockedName, 1, true) then
            return true;
        end
    end
end

function SpellCacheUpdater.Build()
    if not SpellCache then
        error('SpellCacheUpdater has not been loaded. Call SpellCacheUpdater.Load(...) first');
    end

    if not SpellCacheMetaData.needsRebuild then
        return;
    end

    wipe(SpellCache);

    SpellCacheCoroutine = coroutine.create(function()
        local id, misses = 0, 0;

        while misses < 80000 do
            id = id + 1;

            local name, _, icon = GetSpellInfo(id);
            local nameLower = name and string_lower(name);

            -- 136243 is the a gear icon, we can ignore those spells
            if icon == 136243 then
                misses = 0;
            elseif name and name ~= '' and icon and nameLower and not SpellCacheUpdater.isBlockedName(nameLower) then
                SpellCache[name] = SpellCache[name] or {};

                if not SpellCache[name].spells or SpellCache[name].spells == '' then
                    SpellCache[name].spells = id .. '=' .. icon;
                else
                    SpellCache[name].spells = SpellCache[name].spells .. ',' .. id .. '=' .. icon;
                end

                misses = 0;
            else
                misses = misses + 1;
            end

            coroutine.yield();
        end

        SpellCacheMetaData.needsRebuild = false;
    end);

    SpellCacheUpdater:Show();
end

function SpellCacheUpdater.Load(data)
    SpellCacheMetaData = data;
    SpellCache         = SpellCacheMetaData.data;

    local _, build = GetBuildInfo();

    local num = 0;

    for _, _ in pairs(SpellCache) do
        num = num + 1;
    end

    if num < 39000 or SpellCacheMetaData.locale ~= locale or SpellCacheMetaData.build ~= build or not SpellCacheMetaData.spellCacheStrings then
        SpellCacheMetaData.build             = build;
        SpellCacheMetaData.locale            = locale;
        SpellCacheMetaData.spellCacheStrings = true;
        SpellCacheMetaData.needsRebuild      = true;

        wipe(SpellCache);
    end
end

local function PrepareUnimportantUnitsNames()
    local units = StripesAPI.GetUnimportantUnits();
    if units then
        for unitId, _ in pairs(units) do
            U.GetNpcNameByID(unitId);
        end
    end
end

function AddOn:ADDON_LOADED(addonName)
    if addonName ~= AddOn.AddonName then
        return;
    end

    self:UnregisterEvent('ADDON_LOADED');

    StripesDB = StripesDB or {};
    StripesDB.minimap_button = StripesDB.minimap_button or { hide = false };
    StripesDB.last_used_hex_color = StripesDB.last_used_hex_color or nil;

    if StripesDB.spellCache then
        StripesDB.spellCache = nil;
    end

    StripesSpellDB      = StripesSpellDB or {};
    StripesSpellDB.data = StripesSpellDB.data or {};

    SpellCacheUpdater.Load(StripesSpellDB);
    SpellCacheUpdater.Build();

    self:ForAllModules('StartUp');
    self:ForAllNameplateModules('StartUp');

    self:CheckIncompatibleAddons();

    MinimapButton:Initialize();

    PrepareUnimportantUnitsNames();

    _G['SLASH_STRIPES1'] = '/stripes';
    SlashCmdList['STRIPES'] = function(input)
        if input then
            if string.find(input, 'minimap') then
                MinimapButton:ToggleShown();

                return;
            elseif string.find(input, 'profile') then
                if InCombatLockdown() then
                    U.Print(L['OPTIONS_PROFILES_CANT_CHANGE_IN_COMBAT']);
                else
                    local _, profileName1, profileName2, profileName3 = strsplit(' ', input);
                    local profileName = strtrim(string.format('%s %s %s', profileName1 or '', profileName2 or '', profileName3 or ''));

                    if not profileName or profileName == '' then
                        U.Print(L['OPTIONS_PROFILES_PROFILE_CHANGED_NO_INPUT']);
                        return;
                    end

                    local success = S:GetModule('Options_Categories_Profiles').ChooseProfileByName(profileName);
                    U.Print(string.format(success and L['OPTIONS_PROFILES_PROFILE_CHANGED_SUCCESS'] or L['OPTIONS_PROFILES_PROFILE_CHANGED_FAILED'], profileName));
                end

                return;
            elseif string.find(input, 'ununits') then
                local units = StripesAPI.GetUnimportantUnits();
                if units then
                    U.Print(L['UNIMPORTANT_UNITS']);

                    local index = 1;
                    for unitId, _ in pairs(units) do
                        U.Print(string.format('%s. [%s] %s', index, unitId, U.GetNpcNameByID(unitId)));
                        index = index + 1;
                    end
                else
                    U.Print(L['NO_UNIMPORTANT_UNITS']);
                end

                return;
            elseif string.find(input, 'help') then
                U.Print(L['AVAILABLE_COMMANDS']);
                U.Print(string.format('%s | %s', '|cffff6666minimap|r', 'Toggle visibility of the minimap button'));
                U.Print(string.format('%s | %s', '|cffff6666profile|r', 'Change profile (/stripes profile PROFILENAME)'));
                U.Print(string.format('%s | %s', '|cffff6666ununits|r', 'List of unimportant units'));

                return;
            end
        end

        O:ToggleOptions();
    end
end