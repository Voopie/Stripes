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

Eventer.frame:SetScript('OnEvent', function(_, event, ...)
    if not embeds[event] then
        return;
    end

    for _, data in ipairs(embeds[event]) do
        for callback, func in pairs(data) do
            if func == 0 then
                callback[event](callback, ...);
            else
                if callback[func] then
                    callback[func](callback, ...);
                else
                    func(...);
                end
            end
        end
    end
end);

Eventer.frameUnit:SetScript('OnEvent', function(_, event, ...)
    if not embedsUnit[event] then
        return;
    end

    for _, data in ipairs(embedsUnit[event]) do
        for callback, func in pairs(data) do
            if func == 0 then
                callback[event](callback, ...);
            else
                if callback[func] then
                    callback[func](callback, ...);
                else
                    func(...);
                end
            end
        end
    end
end);

function Eventer:RegisterEvent(event, callback, func)
    if self:IsEventRegistered(event, callback) then
        return;
    end

    if func == nil then
        func = 0;
    end

    if embeds[event] == nil then
        embeds[event] = {};
        Eventer.frame:RegisterEvent(event);
    end

    table_insert(embeds[event], { [callback] = func });
end

function Eventer:IsEventRegistered(event, callback)
    if not embeds[event] then
        return false;
    end

    for _, data in ipairs(embeds[event]) do
        for c, _ in pairs(data) do
            if callback == c then
                return true;
            end
        end
    end

    return false;
end

function Eventer:IsUnitEventRegistered(event, callback)
    if not embedsUnit[event] then
        return false;
    end

    for _, data in ipairs(embedsUnit[event]) do
        for c, _ in pairs(data) do
            if callback == c then
                return true;
            end
        end
    end

    return false;
end

function Eventer:RegisterUnitEvent(event, callback, unit1, unit2, func)
    if func == nil then
        func = 0;
    end

    unit1 = unit1 or 'player';

    if embedsUnit[event] == nil then
        embedsUnit[event] = {};

        if unit2 and unit2 ~= '' then
            Eventer.frameUnit:RegisterUnitEvent(event, unit1, unit2);
        else
            Eventer.frameUnit:RegisterUnitEvent(event, unit1);
        end
    end

    table_insert(embedsUnit[event], { [callback] = func });
end

function Eventer:UnregisterEvent(event, callback)
    if not embeds[event] then
        return;
    end

    if not self:IsEventRegistered(event, callback) then
        return;
    end

    for index, data in ipairs(embeds[event]) do
        for cb, _ in pairs(data) do
            if cb == callback then
                table_remove(embeds[event], index);
            end
        end
    end

    if #embeds[event] == 0 then
        embeds[event] = nil;
        Eventer.frame:UnregisterEvent(event);
    end
end

function Eventer:UnregisterUnitEvent(event, callback)
    if not embedsUnit[event] then
        return;
    end

    for index, data in ipairs(embedsUnit[event]) do
        for cb, _ in pairs(data) do
            if cb == callback then
                table_remove(embedsUnit[event], index)
            end
        end
    end

    if #embedsUnit[event] == 0 then
        embedsUnit[event] = nil;
        Eventer.frameUnit:UnregisterEvent(event);
    end
end

function Eventer:ADDON_LOADED(name)
    if not addons[name] then
        return;
    end

    for _, data in ipairs(addons[name]) do
        for callback, func in pairs(data) do
            if func == 0 then
                callback[name](callback);
            else
                if callback[func] then
                    callback[func](callback, name);
                else
                    func(name);
                end
            end

            if func or func == 0 or callback[func] then
                self:UnregisterAddon(name, callback, func);
            end
        end
    end
end

function Eventer:RegisterAddon(name, callback, func)
    if func == nil then
        func = 0;
    end

    if IsAddOnLoaded(name) then
        if func == 0 then
            callback[name](callback);
        else
            if callback[func] then
                callback[func](callback, name);
            else
                func(name);
            end
        end
    else
        self:RegisterEvent('ADDON_LOADED', self);

        if addons[name] == nil then
            addons[name] = {};
        end

        table_insert(addons[name], { [callback] = func });
    end
end

function Eventer:UnregisterAddon(name, callback, func)
    if not addons[name] then
        return;
    end

    if func == nil then
        func = 0;
    end

    for index, data in ipairs(addons[name]) do
        for cb, ff in pairs(data) do
            if cb == callback and ff == func then
                table_remove(addons[name], index);
            end
        end
    end

    if #addons[name] == 0 then
        addons[name] = nil;
    end
end

AddOn.Eventer = Eventer;

local ModuleMixin = {};

function ModuleMixin:RegisterEvent(event, func)
    Eventer:RegisterEvent(event, self, func);
end

function ModuleMixin:UnregisterEvent(event)
    Eventer:UnregisterEvent(event, self);
end

function ModuleMixin:IsEventRegistered(event)
    return Eventer:IsEventRegistered(event, self);
end

function ModuleMixin:RegisterUnitEvent(event, unit1, unit2, func)
    Eventer:RegisterUnitEvent(event, self, unit1, unit2, func);
end

function ModuleMixin:UnregisterUnitEvent(event)
    Eventer:UnregisterUnitEvent(event, self);
end

function ModuleMixin:IsUnitEventRegistered(event)
    return Eventer:IsUnitEventRegistered(event, self);
end

function ModuleMixin:RegisterAddon(name, func)
    Eventer:RegisterAddon(name, self, func);
end

function ModuleMixin:UnregisterAddon(name)
    Eventer:UnregisterAddon(name, self);
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

function ModuleMixin:SecureHook(name, func1, func2, func3)
    if not _G[name] then
        return;
    end

    if self.Hooks[name] then
        error('SecureHook: «' .. name .. '» was already hooked in «' .. self.Name .. '» module!');
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
            hooksecurefunc(_G[name], hookMethod, hookFunc2);
        end
    else
        hooksecurefunc(name, self.Hooks[name]);
    end
end

function ModuleMixin:SecureUnitFrameHook(name, func1, func2, func3)
    if not _G[name] then
        return;
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
        icon          = NAMESPACE[1].Media.StripesArt.TEXTURE,
        iconCoords    = NAMESPACE[1].Media.StripesArt.COORDS.MINI_NOSTROKE_GRADIENT,
        OnClick       = MinimapButton.OnClick,
        OnTooltipShow = MinimapButton.OnTooltipShow,
    });

    if LDBIcon then
        LDBIcon:Register('Stripes', LDB_Stripes, StripesDB.minimap_button);

        if not StripesDB.minimap_button.hide then
            LDBIcon:GetMinimapButton('Stripes').icon.UpdateCoord = MinimapButton.UpdateCoord;
            LDBIcon:GetMinimapButton('Stripes').icon:UpdateCoord();
        end
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


-- Code from WeakAuras (https://github.com/WeakAuras/WeakAuras2/blob/main/WeakAurasOptions/Cache.lua)
-- It will only be rebuilt if the client build number and locale changes
local string_find, string_lower = string.find, string.lower;
local GetSpellInfo = GetSpellInfo;
local cache, metaData, spellCacheCoroutine;

local spellCache = CreateFrame('Frame');
spellCache:Hide();
spellCache:SetScript('OnUpdate', function()
    -- Start timing
    local start = debugprofilestop();

    -- Resume as often as possible (Limit to 16ms per frame -> 60 FPS)
    while debugprofilestop() - start < 16 do
        if coroutine.status(spellCacheCoroutine) ~= 'dead' then
            local ok, msg = coroutine.resume(spellCacheCoroutine);
            if not ok then
                geterrorhandler()(msg .. '\n' .. debugstack(spellCacheCoroutine));
            end
        else
            spellCache:Hide();
            NAMESPACE[3].frame.Right.Auras:Update();
        end
    end
end);

spellCache.blockedSpellNames = {
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

function spellCache.isBlockedName(name)
    for blockedName, status in pairs(spellCache.blockedSpellNames) do
        if status and string_find(name, blockedName, 1, true) then
            return true;
        end
    end
end

function spellCache.Build()
    if not cache then
        error('spellCache has not been loaded. Call spellCache.Load(...) first.');
    end

    if not metaData.needsRebuild then
        return;
    end

    wipe(cache);

    spellCacheCoroutine = coroutine.create(function()
        local id, misses = 0, 0;

        while misses < 80000 do
            id = id + 1;

            local name, _, icon = GetSpellInfo(id);
            local nameLower = name and string_lower(name);

            -- 136243 is the a gear icon, we can ignore those spells
            if icon == 136243 then
                misses = 0;
            elseif name and name ~= '' and icon and nameLower and not spellCache.isBlockedName(nameLower) then
                cache[name] = cache[name] or {};

                if not cache[name].spells or cache[name].spells == '' then
                    cache[name].spells = id .. '=' .. icon;
                else
                    cache[name].spells = cache[name].spells .. ',' .. id .. '=' .. icon;
                end

                misses = 0;
            else
                misses = misses + 1;
            end

            coroutine.yield();
        end

        metaData.needsRebuild = false;
    end);

    spellCache:Show();
end

function spellCache.Load(data)
    metaData = data;
    cache    = metaData.data;

    local _, build = GetBuildInfo();

    local num = 0;

    for _, _ in pairs(cache) do
        num = num + 1;
    end

    if num < 39000 or metaData.locale ~= locale or metaData.build ~= build or not metaData.spellCacheStrings then
        metaData.build             = build;
        metaData.locale            = locale;
        metaData.spellCacheStrings = true;
        metaData.needsRebuild      = true;

        wipe(cache);
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

    spellCache.Load(StripesSpellDB);
    spellCache.Build();

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