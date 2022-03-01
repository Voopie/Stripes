local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Auras');
local Profile = S:GetModule('Options_Categories_Profiles');

local GetIconFromSpellCache = U.GetIconFromSpellCache;

local LSM = S.Libraries.LSM;

O.frame.Left.Auras, O.frame.Right.Auras = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_AURAS']), 'auras', 6);
local button = O.frame.Left.Auras;
local panel = O.frame.Right.Auras;

local aurasCustomFramePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local NAME_WIDTH = 380;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_AURAS_TAB_COMMON']),
    },
    [2] = {
        name  = 'SpellstealTab',
        title = string.upper(L['OPTIONS_AURAS_TAB_SPELLSTEAL']),
    },
    [3] = {
        name  = 'MythicPlusTab',
        title = string.upper(L['OPTIONS_AURAS_TAB_MYTHICPLUS']),
    },
    [4] = {
        name  = 'ImportantTab',
        title = string.upper(L['OPTIONS_AURAS_TAB_IMPORTANT']),
    },
    [5] = {
        name  = 'CustomTab',
        title = string.upper(L['OPTIONS_AURAS_TAB_CUSTOM']),
    },
};

local function ToggleTooltip_Show(self)
    if not self.tooltip then
        return;
    end

    GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
    GameTooltip:AddLine(self.tooltip, 1, 0.85, 0, false);
    GameTooltip:Show();
end

local function AddCustomAura(id, byName, name)
    id = byName and name or id;

    if not id or O.db.auras_custom_data[id] then
        return;
    end

    O.db.auras_custom_data[id] = {
        id       = id,
        filter   = O.db.auras_custom_helpful and 'HELPFUL' or 'HARMFUL',
        enabled  = true,
        own_only = true,
    };

    if O.db.auras_custom_to_blacklist then
        O.db.auras_blacklist[id] = {
            id      = id,
            enabled = true,
        };
    end
end

local DataCustomAuraRows = {};

local function CreateCustomAuraRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.auras_custom_data[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.OwnToggleButton = CreateFrame('Button', nil, frame);
    frame.OwnToggleButton:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.OwnToggleButton:SetSize(ROW_HEIGHT, ROW_HEIGHT);
    frame.OwnToggleButton.texture = frame.OwnToggleButton:CreateTexture(nil, 'ARTWORK');
    frame.OwnToggleButton.texture:SetPoint('TOPLEFT', 6, -6);
    frame.OwnToggleButton.texture:SetPoint('BOTTOMRIGHT', -6, 6);
    frame.OwnToggleButton:SetScript('OnClick', function(self)
        if O.db.auras_custom_data[self:GetParent().id].own_only then
            O.db.auras_custom_data[self:GetParent().id].own_only = false;
            self.texture:SetColorTexture(0.4, 0.4, 1);

            self.text:SetText('A');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_OWN'];
            ToggleTooltip_Show(self);
        else
            O.db.auras_custom_data[self:GetParent().id].own_only = true;
            self.texture:SetColorTexture(1, 0.4, 0);

            self.text:SetText('O');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_ALL'];
            ToggleTooltip_Show(self);
        end

        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    frame.OwnToggleButton.text = frame.OwnToggleButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.OwnToggleButton.text:SetAllPoints(frame.OwnToggleButton.texture);
    frame.OwnToggleButton.text:SetJustifyH('CENTER');

    frame.OwnToggleButton:HookScript('OnEnter', ToggleTooltip_Show);
    frame.OwnToggleButton:HookScript('OnLeave', GameTooltip_Hide);
    frame.OwnToggleButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.OwnToggleButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.FilterToggleButton = CreateFrame('Button', nil, frame);
    frame.FilterToggleButton:SetPoint('LEFT', frame.OwnToggleButton, 'RIGHT', 0, 0);
    frame.FilterToggleButton:SetSize(ROW_HEIGHT, ROW_HEIGHT);
    frame.FilterToggleButton.texture = frame.FilterToggleButton:CreateTexture(nil, 'ARTWORK');
    frame.FilterToggleButton.texture:SetPoint('TOPLEFT', 6, -6);
    frame.FilterToggleButton.texture:SetPoint('BOTTOMRIGHT', -6, 6);
    frame.FilterToggleButton:SetScript('OnClick', function(self)
        if O.db.auras_custom_data[self:GetParent().id].filter == 'HELPFUL' then
            O.db.auras_custom_data[self:GetParent().id].filter = 'HARMFUL';
            self.texture:SetColorTexture(1, 0.4, 0.4);

            self.text:SetText('D');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HELPFUL'];
            ToggleTooltip_Show(self);
        else
            O.db.auras_custom_data[self:GetParent().id].filter = 'HELPFUL';
            self.texture:SetColorTexture(0.4, 0.85, 0.4);

            self.text:SetText('B');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HARMFUL'];
            ToggleTooltip_Show(self);
        end

        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    frame.FilterToggleButton.text = frame.FilterToggleButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.FilterToggleButton.text:SetAllPoints(frame.FilterToggleButton.texture);
    frame.FilterToggleButton.text:SetJustifyH('CENTER');

    frame.FilterToggleButton:HookScript('OnEnter', ToggleTooltip_Show);
    frame.FilterToggleButton:HookScript('OnLeave', GameTooltip_Hide);
    frame.FilterToggleButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.FilterToggleButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.BlacklistButton = CreateFrame('Button', nil, frame);
    frame.BlacklistButton:SetPoint('LEFT', frame.FilterToggleButton, 'RIGHT', 0, 0);
    frame.BlacklistButton:SetSize(ROW_HEIGHT, ROW_HEIGHT);
    frame.BlacklistButton.texture = frame.BlacklistButton:CreateTexture(nil, 'ARTWORK');
    frame.BlacklistButton.texture:SetPoint('TOPLEFT', 6, -6);
    frame.BlacklistButton.texture:SetPoint('BOTTOMRIGHT', -6, 6);
    frame.BlacklistButton:SetScript('OnClick', function(self)
        local id = self:GetParent().id;

        if not id then
            return;
        end

        if O.db.auras_blacklist[id] then
            O.db.auras_blacklist[id] = nil;
            self.texture:SetColorTexture(0.8, 0.8, 0.8);

            self.text:SetText('W');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_ADD_TO_BLACKLIST'];
            ToggleTooltip_Show(self);
        else
            O.db.auras_blacklist[id] = {
                id      = id,
                enabled = true,
            };

            self.texture:SetColorTexture(0, 0, 0);

            self.text:SetText('B');

            self.tooltip = L['OPTIONS_AURAS_CUSTOM_REMOVE_FROM_BLACKLIST'];
            ToggleTooltip_Show(self);
        end

        panel:UpdateScroll();
        panel:UpdateBlackListScroll();

        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    frame.BlacklistButton.text = frame.BlacklistButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.BlacklistButton.text:SetAllPoints(frame.BlacklistButton.texture);
    frame.BlacklistButton.text:SetJustifyH('CENTER');

    frame.BlacklistButton:HookScript('OnEnter', ToggleTooltip_Show);
    frame.BlacklistButton:HookScript('OnLeave', GameTooltip_Hide);
    frame.BlacklistButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.BlacklistButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.BlacklistButton, 'RIGHT', 8, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 8, ROW_HEIGHT - 8);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.IdText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.IdText:SetPoint('LEFT', frame.Icon, 'RIGHT', 10, 0);
    frame.IdText:SetSize(60, ROW_HEIGHT);
    frame.IdText:SetTextColor(0.67, 0.67, 0.67);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.IdText, 'RIGHT', 2, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -16, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        local id = self:GetParent().id;

        if not id then
            return;
        end

        if O.db.auras_custom_data[id] then
            O.db.auras_custom_data[id] = nil;

            if O.db.auras_blacklist[id] then
                O.db.auras_blacklist[id] = nil;
            end

            panel:UpdateScroll();
            panel:UpdateBlackListScroll();

            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        if self.id and type(self.id) == 'number' then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
            GameTooltip:Show();
        end
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

local function UpdateCustomAuraRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.auras_custom_scrollchild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.auras_custom_scrollchild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataCustomAuraRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataCustomAuraRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(frame.icon);
    frame.IdText:SetText(type(frame.id) == 'number' and frame.id or 'NA');
    frame.NameText:SetText(frame.name);

    if frame.filter == 'HELPFUL' then
        frame.FilterToggleButton.texture:SetColorTexture(0.4, 0.85, 0.4);
        frame.FilterToggleButton.text:SetText('B');
        frame.FilterToggleButton.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HARMFUL'];
    else
        frame.FilterToggleButton.texture:SetColorTexture(1, 0.4, 0.4);
        frame.FilterToggleButton.text:SetText('D');
        frame.FilterToggleButton.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HELPFUL'];
    end

    if frame.own_only then
        frame.OwnToggleButton.texture:SetColorTexture(1, 0.4, 0);
        frame.OwnToggleButton.text:SetText('O');
        frame.OwnToggleButton.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_ALL'];
    else
        frame.OwnToggleButton.texture:SetColorTexture(0.4, 0.4, 1);
        frame.OwnToggleButton.text:SetText('A');
        frame.OwnToggleButton.tooltip = L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_OWN'];
    end

    if frame.isBlacklisted then
        frame.BlacklistButton.texture:SetColorTexture(0, 0, 0);
        frame.BlacklistButton.text:SetText('B');
        frame.BlacklistButton.tooltip = L['OPTIONS_AURAS_CUSTOM_REMOVE_FROM_BLACKLIST'];
    else
        frame.BlacklistButton.texture:SetColorTexture(0.8, 0.8, 0.8);
        frame.BlacklistButton.text:SetText('W');
        frame.BlacklistButton.tooltip = L['OPTIONS_AURAS_CUSTOM_ADD_TO_BLACKLIST'];
    end
end

local sortedCustomData = {};
panel.UpdateScroll = function()
    wipe(DataCustomAuraRows);
    wipe(sortedCustomData);

    for id in pairs(O.db.auras_custom_data) do
        table.insert(sortedCustomData, id);
    end

    table.sort(sortedCustomData, function(a, b)
        if type(a) == 'string' and type(b) == 'number' then
            return a < (GetSpellInfo(b));
        elseif type(a) == 'number' and type(b) == 'string' then
            return (GetSpellInfo(a)) < b;
        elseif type(a) == 'string' and type(b) == 'string' then
            return a < b;
        else
            return (GetSpellInfo(a)) < (GetSpellInfo(b));
        end
    end);

    aurasCustomFramePool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local name, icon, data;

    for _, id in pairs(sortedCustomData) do
        if type(id) == 'string' then
            name = id;
            icon = GetIconFromSpellCache(name);
        else
            name, _, icon = GetSpellInfo(id);
        end

        data = O.db.auras_custom_data[id];

        index = index + 1;

        frame, isNew = aurasCustomFramePool:Acquire();

        table.insert(DataCustomAuraRows, frame);

        if isNew then
            CreateCustomAuraRow(frame);
        end

        frame.index         = index;
        frame.id            = id;
        frame.icon          = icon;
        frame.name          = name;
        frame.filter        = data.filter;
        frame.enabled       = data.enabled;
        frame.own_only      = data.own_only;
        frame.isBlacklisted = O.db.auras_blacklist[id] and true or false;

        UpdateCustomAuraRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.auras_custom_scrollchild, panel.auras_custom_editframe:GetWidth(), panel.auras_custom_editframe:GetHeight() - (panel.auras_custom_editframe:GetHeight() % ROW_HEIGHT + 8));
end

local DataBlackListRows = {};
local function AddBlackListAura(id, byName, name)
    id = byName and name or id;

    if not id or O.db.auras_blacklist[id] then
        return;
    end

    O.db.auras_blacklist[id] = {
        id      = id,
        enabled = true,
    };
end

local function CreateBlackListRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.auras_blacklist[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 10, ROW_HEIGHT - 10);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.Icon, 'RIGHT', 8, 0);
    frame.NameText:SetSize(150, ROW_HEIGHT);

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -8, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        if O.db.auras_blacklist[self:GetParent().id] then
            O.db.auras_blacklist[self:GetParent().id] = nil;

            panel:UpdateScroll();
            panel:UpdateBlackListScroll();

            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        if self.id and type(self.id) == 'number' then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
            GameTooltip:AddLine('|cffff6666' .. self.id .. '|r');
            GameTooltip:Show();
        end
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

local function UpdateBlackListRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.BlackListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.BlackListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataBlackListRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataBlackListRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(frame.icon);
    frame.NameText:SetText(frame.name);
end

local sortedBlackListData = {};
panel.UpdateBlackListScroll = function()
    wipe(DataBlackListRows);
    wipe(sortedBlackListData);

    for id in pairs(O.db.auras_blacklist) do
        table.insert(sortedBlackListData, id);
    end

    table.sort(sortedBlackListData, function(a, b)
        if type(a) == 'string' and type(b) == 'number' then
            return a < (GetSpellInfo(b));
        elseif type(a) == 'number' and type(b) == 'string' then
            return (GetSpellInfo(a)) < b;
        elseif type(a) == 'string' and type(b) == 'string' then
            return a < b;
        else
            return (GetSpellInfo(a)) < (GetSpellInfo(b));
        end
    end);

    panel.BlackListButtonPool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local name, icon, data;

    for _, id in pairs(sortedBlackListData) do
        if type(id) == 'string' then
            name = id;
            icon = GetIconFromSpellCache(name);
        else
            name, _, icon = GetSpellInfo(id);
        end

        data = O.db.auras_blacklist[id];

        index = index + 1;

        frame, isNew = panel.BlackListButtonPool:Acquire();

        table.insert(DataBlackListRows, frame);

        if isNew then
            CreateBlackListRow(frame);
        end

        frame.index   = index;
        frame.id      = id;
        frame.icon    = icon;
        frame.name    = name;
        frame.enabled = data.enabled;

        UpdateBlackListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.BlackListScrollArea.scrollChild, panel.BlackListScroll:GetWidth(), panel.BlackListScroll:GetHeight() - (panel.BlackListScroll:GetHeight() % ROW_HEIGHT));
end

local DataWhiteListRows = {};
local function AddWhiteListAura(id, byName, name)
    id = byName and name or id;

    if not id or O.db.auras_whitelist[id] then
        return;
    end

    O.db.auras_whitelist[id] = {
        id      = id,
        enabled = true,
    };
end

local function CreateWhiteListRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.auras_whitelist[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 10, ROW_HEIGHT - 10);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.Icon, 'RIGHT', 8, 0);
    frame.NameText:SetSize(150, ROW_HEIGHT);

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -8, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        if O.db.auras_whitelist[self:GetParent().id] then
            O.db.auras_whitelist[self:GetParent().id] = nil;

            panel:UpdateScroll();
            panel:UpdateWhiteListScroll();

            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        if self.id and type(self.id) == 'number' then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
            GameTooltip:AddLine('|cffff6666' .. self.id .. '|r');
            GameTooltip:Show();
        end
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

local function UpdateWhiteListRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.WhiteListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.WhiteListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataWhiteListRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataWhiteListRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(frame.icon);
    frame.NameText:SetText(frame.name);
end

local sortedWhiteListData = {};
panel.UpdateWhiteListScroll = function()
    wipe(DataWhiteListRows);
    wipe(sortedWhiteListData);

    for id in pairs(O.db.auras_whitelist) do
        table.insert(sortedWhiteListData, id);
    end

    table.sort(sortedWhiteListData, function(a, b)
        if type(a) == 'string' and type(b) == 'number' then
            return a < (GetSpellInfo(b));
        elseif type(a) == 'number' and type(b) == 'string' then
            return (GetSpellInfo(a)) < b;
        elseif type(a) == 'string' and type(b) == 'string' then
            return a < b;
        else
            return (GetSpellInfo(a)) < (GetSpellInfo(b));
        end
    end);

    panel.WhiteListButtonPool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local name, icon, data;

    for _, id in pairs(sortedWhiteListData) do
        if type(id) == 'string' then
            name = id;
            icon = GetIconFromSpellCache(name);
        else
            name, _, icon = GetSpellInfo(id);
        end

        data = O.db.auras_whitelist[id];

        index = index + 1;

        frame, isNew = panel.WhiteListButtonPool:Acquire();

        table.insert(DataWhiteListRows, frame);

        if isNew then
            CreateWhiteListRow(frame);
        end

        frame.index   = index;
        frame.id      = id;
        frame.icon    = icon;
        frame.name    = name;
        frame.enabled = data.enabled;

        UpdateWhiteListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.WhiteListScrollArea.scrollChild, panel.WhiteListScroll:GetWidth(), panel.WhiteListScroll:GetHeight() - (panel.WhiteListScroll:GetHeight() % ROW_HEIGHT));
end

local DataHPBarColorRows = {};
local function AddHPBarColorAura(id, byName, name)
    id = byName and name or id;

    if not id or O.db.auras_hpbar_color_data[id] then
        return;
    end

    O.db.auras_hpbar_color_data[id] = {
        id      = id,
        enabled = true,
        color   = { 0.15, 0.95, 0, 1 };
    };
end

local function CreateHPBarColorRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.auras_hpbar_color_data[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 10, ROW_HEIGHT - 10);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.Icon, 'RIGHT', 8, 0);
    frame.NameText:SetSize(120, ROW_HEIGHT);

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -8, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        if O.db.auras_hpbar_color_data[self:GetParent().id] then
            O.db.auras_hpbar_color_data[self:GetParent().id] = nil;

            panel:UpdateHPBarColorScroll();
            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame.ColorPicker = E.CreateColorPicker(frame);
    frame.ColorPicker:SetPosition('RIGHT', frame.RemoveButton, 'LEFT', -4, 0);
    frame.ColorPicker.OnValueChanged = function(self, r, g, b, a)
        O.db.auras_hpbar_color_data[self:GetParent().id].color[1] = r;
        O.db.auras_hpbar_color_data[self:GetParent().id].color[2] = g;
        O.db.auras_hpbar_color_data[self:GetParent().id].color[3] = b;
        O.db.auras_hpbar_color_data[self:GetParent().id].color[4] = a or 1;

        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.ColorPicker:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.ColorPicker:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    frame:HookScript('OnEnter', function(self)
        if self.id and type(self.id) == 'number' then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
            GameTooltip:AddLine('|cffff6666' .. self.id .. '|r');
            GameTooltip:Show();
        end
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

local function UpdateHPBarColorRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.HPBarColorListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.HPBarColorListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataHPBarColorRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataHPBarColorRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(frame.icon);
    frame.NameText:SetText(frame.name);
    frame.ColorPicker:SetValue(unpack(frame.color));
end

local sortedHBBarColorData = {};
panel.UpdateHPBarColorScroll = function()
    wipe(DataHPBarColorRows);
    wipe(sortedHBBarColorData);

    for id in pairs(O.db.auras_hpbar_color_data) do
        table.insert(sortedHBBarColorData, id);
    end

    table.sort(sortedHBBarColorData, function(a, b)
        if type(a) == 'string' and type(b) == 'number' then
            return a < (GetSpellInfo(b));
        elseif type(a) == 'number' and type(b) == 'string' then
            return (GetSpellInfo(a)) < b;
        elseif type(a) == 'string' and type(b) == 'string' then
            return a < b;
        else
            return (GetSpellInfo(a)) < (GetSpellInfo(b));
        end
    end);

    panel.HPBarColorButtonPool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local name, icon, data;

    for _, id in pairs(sortedHBBarColorData) do
        if type(id) == 'string' then
            name = id;
            icon = GetIconFromSpellCache(name);
        else
            name, _, icon = GetSpellInfo(id);
        end

        data = O.db.auras_hpbar_color_data[id];

        index = index + 1;

        frame, isNew = panel.HPBarColorButtonPool:Acquire();

        table.insert(DataHPBarColorRows, frame);

        if isNew then
            CreateHPBarColorRow(frame);
        end

        frame.index   = index;
        frame.id      = id;
        frame.name    = name;
        frame.icon    = icon;
        frame.enabled = data.enabled;
        frame.color   = data.color;

        UpdateHPBarColorRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.HPBarColorListScrollArea.scrollChild, panel.HPBarColorListScroll:GetWidth(), panel.HPBarColorListScroll:GetHeight() - (panel.HPBarColorListScroll:GetHeight() % ROW_HEIGHT));
end

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_is_active = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_is_active:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_is_active:SetLabel(L['OPTIONS_AURAS_IS_ACTIVE']);
    self.auras_is_active:SetTooltip(L['OPTIONS_AURAS_IS_ACTIVE_TOOLTIP']);
    self.auras_is_active:AddToSearch(button, L['OPTIONS_AURAS_IS_ACTIVE_TOOLTIP'], self.Tabs[1]);
    self.auras_is_active:SetChecked(O.db.auras_is_active);
    self.auras_is_active.Callback = function(self)
        O.db.auras_is_active = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_direction = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_direction:SetPosition('TOPLEFT', self.auras_is_active, 'BOTTOMLEFT', 0, -8);
    self.auras_direction:SetSize(130, 20);
    self.auras_direction:SetList(O.Lists.auras_horizontal_direction);
    self.auras_direction:SetLabel(L['OPTIONS_AURAS_DIRECTION']);
    self.auras_direction:SetTooltip(L['OPTIONS_AURAS_DIRECTION_TOOLTIP']);
    self.auras_direction:AddToSearch(button, L['OPTIONS_AURAS_DIRECTION_TOOLTIP'], self.Tabs[1]);
    self.auras_direction:SetValue(O.db.auras_direction);
    self.auras_direction.OnValueChangedCallback = function(_, value)
        O.db.auras_direction = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_sort_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_sort_enabled:SetPosition('LEFT', self.auras_direction, 'RIGHT', 16, 0);
    self.auras_sort_enabled:SetLabel(L['OPTIONS_AURAS_SORT_ENABLED']);
    self.auras_sort_enabled:SetTooltip(L['OPTIONS_AURAS_SORT_ENABLED_TOOLTIP']);
    self.auras_sort_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.auras_sort_enabled:SetChecked(O.db.auras_sort_enabled);
    self.auras_sort_enabled.Callback = function(self)
        O.db.auras_sort_enabled = self:GetChecked();

        panel.auras_sort_method:SetEnabled(O.db.auras_sort_enabled);

        Stripes:UpdateAll();
    end

    self.auras_sort_method = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_sort_method:SetPosition('LEFT', self.auras_sort_enabled.Label, 'RIGHT', 12, 0);
    self.auras_sort_method:SetSize(170, 20);
    self.auras_sort_method:SetList(O.Lists.auras_sort_method);
    self.auras_sort_method:SetTooltip(L['OPTIONS_AURAS_SORT_TOOLTIP']);
    self.auras_sort_method:AddToSearch(button, L['OPTIONS_AURAS_SORT_TOOLTIP'], self.Tabs[1]);
    self.auras_sort_method:SetValue(O.db.auras_sort_method);
    self.auras_sort_method:SetEnabled(O.db.auras_sort_enabled);
    self.auras_sort_method.OnValueChangedCallback = function(_, value)
        O.db.auras_sort_method = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_filter_player_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_filter_player_enabled:SetPosition('TOPLEFT', self.auras_direction, 'BOTTOMLEFT', 0, -8);
    self.auras_filter_player_enabled:SetLabel(L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED']);
    self.auras_filter_player_enabled:SetTooltip(L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED_TOOLTIP']);
    self.auras_filter_player_enabled:AddToSearch(button, L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_filter_player_enabled:SetChecked(O.db.auras_filter_player_enabled);
    self.auras_filter_player_enabled.Callback = function(self)
        O.db.auras_filter_player_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_xlist_mode = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_xlist_mode:SetPosition('TOPLEFT', self.auras_filter_player_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_xlist_mode:SetSize(160, 20);
    self.auras_xlist_mode:SetList(O.Lists.auras_xlist_mode);
    self.auras_xlist_mode:SetLabel(L['OPTIONS_AURAS_XLIST_MODE']);
    self.auras_xlist_mode:SetTooltip(L['OPTIONS_AURAS_XLIST_MODE_TOOLTIP']);
    self.auras_xlist_mode:AddToSearch(button, L['OPTIONS_AURAS_XLIST_MODE_TOOLTIP'], self.Tabs[1]);
    self.auras_xlist_mode:SetValue(O.db.auras_xlist_mode);
    self.auras_xlist_mode.OnValueChangedCallback = function(_, value)
        O.db.auras_xlist_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.WhiteListButton = E.CreateButton(self.TabsFrames['CommonTab'].Content);
    self.WhiteListButton:SetPosition('LEFT', self.auras_xlist_mode, 'RIGHT', 16, 0);
    self.WhiteListButton:SetScale(0.8);
    self.WhiteListButton:SetHighlightColor('eeeeee');
    self.WhiteListButton:SetLabel(L['OPTIONS_AURAS_WHITELIST_BUTTON']);
    self.WhiteListButton:SetScript('OnClick', function(self)
        panel.WhiteList:SetShown(not panel.WhiteList:IsShown());

        if panel.WhiteList:IsShown() then
            self:LockHighlight();
        else
            self:UnlockHighlight();
        end

        panel.BlackList:SetShown(false);
        panel.BlackListButton:UnlockHighlight();

        panel.HPBarColorList:SetShown(false);
        panel.HPBarColorListButton:UnlockHighlight();
        panel.HPBarColorListButton:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_LIST_BUTTON_OPEN']);
    end);

    self.WhiteList = Mixin(CreateFrame('Frame', nil, self.TabsFrames['CommonTab'].Content, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.WhiteList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.WhiteList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.WhiteList:SetWidth(250);
    self.WhiteList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.WhiteList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.WhiteList:SetShown(false);

    self.WhiteListText = E.CreateFontString(self.WhiteList);
    self.WhiteListText:SetPosition('TOP', self.WhiteList, 'TOP', 0, -10);
    self.WhiteListText:SetText(L['OPTIONS_AURAS_WHITELIST_BUTTON']);

    self.WhiteListEditbox = E.CreateEditBox(self.WhiteList);
    self.WhiteListEditbox:SetPosition('TOP', self.WhiteListText, 'BOTTOM', 0, -4);
    self.WhiteListEditbox:SetFrameLevel(self.WhiteList:GetFrameLevel() + 10);
    self.WhiteListEditbox:SetSize(228, 20);
    self.WhiteListEditbox.useLastValue = false;
    self.WhiteListEditbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.WhiteListEditbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        local byName = false;
        local byNameIcon;

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            byNameIcon = GetIconFromSpellCache(text);

            if byNameIcon then
                byName = true;
            end
        end

        if not saveId and not byName then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddWhiteListAura(tonumber(saveId), byName, text);

        panel:UpdateWhiteListScroll();
        self:SetText('');

        Stripes:UpdateAll();
    end);

    self.WhiteListScroll = Mixin(CreateFrame('Frame', nil, self.WhiteList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.WhiteListScroll:SetPoint('TOPLEFT', self.WhiteList , 'TOPLEFT', 6, -60);
    self.WhiteListScroll:SetPoint('BOTTOMRIGHT', self.WhiteList, 'BOTTOMRIGHT', -6, 6);
    self.WhiteListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.WhiteListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.WhiteListScrollChild, self.WhiteListScrollArea = E.CreateScrollFrame(self.WhiteListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.WhiteListScrollArea.ScrollBar, 'TOPLEFT', self.WhiteListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.WhiteListScrollArea.ScrollBar, 'BOTTOMLEFT', self.WhiteListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.WhiteListButtonPool = CreateFramePool('Button', self.WhiteListScrollChild, 'BackdropTemplate');

    self:UpdateWhiteListScroll();

    self.BlackListButton = E.CreateButton(self.TabsFrames['CommonTab'].Content);
    self.BlackListButton:SetPosition('LEFT', self.WhiteListButton, 'RIGHT', 13, 0);
    self.BlackListButton:SetScale(0.8);
    self.BlackListButton:SetHighlightColor('111111');
    self.BlackListButton:SetLabel(L['OPTIONS_AURAS_BLACKLIST_BUTTON']);
    self.BlackListButton:SetScript('OnClick', function(self)
        panel.BlackList:SetShown(not panel.BlackList:IsShown());

        if panel.BlackList:IsShown() then
            self:LockHighlight();
        else
            self:UnlockHighlight();
        end

        panel.WhiteList:SetShown(false);
        panel.WhiteListButton:UnlockHighlight();

        panel.HPBarColorList:SetShown(false);
        panel.HPBarColorListButton:UnlockHighlight();
        panel.HPBarColorListButton:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_LIST_BUTTON_OPEN']);
    end);

    self.BlackList = Mixin(CreateFrame('Frame', nil, self.TabsFrames['CommonTab'].Content, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.BlackList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.BlackList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.BlackList:SetWidth(250);
    self.BlackList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.BlackList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.BlackList:SetShown(false);

    self.BlackListText = E.CreateFontString(self.BlackList);
    self.BlackListText:SetPosition('TOP', self.BlackList, 'TOP', 0, -10);
    self.BlackListText:SetText(L['OPTIONS_AURAS_BLACKLIST_BUTTON']);

    self.BlackListEditbox = E.CreateEditBox(self.BlackList);
    self.BlackListEditbox:SetPosition('TOP', self.BlackListText, 'BOTTOM', 0, -4);
    self.BlackListEditbox:SetFrameLevel(self.BlackList:GetFrameLevel() + 10);
    self.BlackListEditbox:SetSize(228, 20);
    self.BlackListEditbox.useLastValue = false;
    self.BlackListEditbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.BlackListEditbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        local byName = false;
        local byNameIcon;

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            byNameIcon = GetIconFromSpellCache(text);

            if byNameIcon then
                byName = true;
            end
        end

        if not saveId and not byName then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddBlackListAura(tonumber(saveId), byName, text);

        panel:UpdateBlackListScroll();
        self:SetText('');

        Stripes:UpdateAll();
    end);

    self.BlackListScroll = Mixin(CreateFrame('Frame', nil, self.BlackList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.BlackListScroll:SetPoint('TOPLEFT', self.BlackList , 'TOPLEFT', 6, -60);
    self.BlackListScroll:SetPoint('BOTTOMRIGHT', self.BlackList, 'BOTTOMRIGHT', -6, 6);
    self.BlackListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.BlackListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.BlackListScrollChild, self.BlackListScrollArea = E.CreateScrollFrame(self.BlackListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.BlackListScrollArea.ScrollBar, 'TOPLEFT', self.BlackListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.BlackListScrollArea.ScrollBar, 'BOTTOMLEFT', self.BlackListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.BlackListButtonPool = CreateFramePool('Button', self.BlackListScrollChild, 'BackdropTemplate');

    self:UpdateBlackListScroll();

    self.auras_square = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_square:SetPosition('TOPLEFT', self.auras_xlist_mode, 'BOTTOMLEFT', 0, -8);
    self.auras_square:SetLabel(L['OPTIONS_AURAS_SQUARE']);
    self.auras_square:SetTooltip(L['OPTIONS_AURAS_SQUARE_TOOLTIP']);
    self.auras_square:AddToSearch(button, L['OPTIONS_AURAS_SQUARE_TOOLTIP'], self.Tabs[1]);
    self.auras_square:SetChecked(O.db.auras_square);
    self.auras_square.Callback = function(self)
        O.db.auras_square = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_border_color_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_border_color_enabled:SetPosition('LEFT', self.auras_square.Label, 'RIGHT', 12, 0);
    self.auras_border_color_enabled:SetLabel(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED']);
    self.auras_border_color_enabled:SetTooltip(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP']);
    self.auras_border_color_enabled:AddToSearch(button, L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_border_color_enabled:SetChecked(O.db.auras_border_color_enabled);
    self.auras_border_color_enabled.Callback = function(self)
        O.db.auras_border_color_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_border_hide = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_border_hide:SetPosition('LEFT', self.auras_border_color_enabled.Label, 'RIGHT', 12, 0);
    self.auras_border_hide:SetLabel(L['OPTIONS_AURAS_BORDER_HIDE']);
    self.auras_border_hide:SetTooltip(L['OPTIONS_AURAS_BORDER_HIDE_TOOLTIP']);
    self.auras_border_hide:AddToSearch(button, L['OPTIONS_AURAS_BORDER_HIDE_TOOLTIP'], self.Tabs[1]);
    self.auras_border_hide:SetChecked(O.db.auras_border_hide);
    self.auras_border_hide.Callback = function(self)
        O.db.auras_border_hide = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_show_debuffs_on_friendly = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_show_debuffs_on_friendly:SetPosition('LEFT', self.auras_border_hide.Label, 'RIGHT', 12, 0);
    self.auras_show_debuffs_on_friendly:SetLabel(L['OPTIONS_AURAS_SHOW_DEBUFFS_ON_FRIENDLY']);
    self.auras_show_debuffs_on_friendly:SetTooltip(L['OPTIONS_AURAS_SHOW_DEBUFFS_ON_FRIENDLY_TOOLTIP']);
    self.auras_show_debuffs_on_friendly:AddToSearch(button, nil, self.Tabs[1]);
    self.auras_show_debuffs_on_friendly:SetChecked(O.db.auras_show_debuffs_on_friendly);
    self.auras_show_debuffs_on_friendly.Callback = function(self)
        O.db.auras_show_debuffs_on_friendly = self:GetChecked();

        C_CVar.SetCVar('nameplateShowDebuffsOnFriendly', O.db.auras_show_debuffs_on_friendly and 1 or 0);

        Stripes:UpdateAll();
    end

    self.auras_pandemic_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_pandemic_enabled:SetPosition('TOPLEFT', self.auras_square, 'BOTTOMLEFT', 0, -8);
    self.auras_pandemic_enabled:SetLabel(L['OPTIONS_AURAS_PANDEMIC_ENABLED']);
    self.auras_pandemic_enabled:SetTooltip(L['OPTIONS_AURAS_PANDEMIC_ENABLED_TOOLTIP']);
    self.auras_pandemic_enabled:AddToSearch(button, L['OPTIONS_AURAS_PANDEMIC_ENABLED'], self.Tabs[1]);
    self.auras_pandemic_enabled:SetChecked(O.db.auras_pandemic_enabled);
    self.auras_pandemic_enabled.Callback = function(self)
        O.db.auras_pandemic_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_pandemic_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.auras_pandemic_color:SetPosition('LEFT', self.auras_pandemic_enabled.Label, 'RIGHT', 12, 0);
    self.auras_pandemic_color:SetTooltip(L['OPTIONS_AURAS_PANDEMIC_COLOR_TOOLTIP']);
    self.auras_pandemic_color:AddToSearch(button, L['OPTIONS_AURAS_PANDEMIC_COLOR_TOOLTIP'], self.Tabs[1]);
    self.auras_pandemic_color:SetValue(unpack(O.db.auras_pandemic_color));
    self.auras_pandemic_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_pandemic_color[1] = r;
        O.db.auras_pandemic_color[2] = g;
        O.db.auras_pandemic_color[3] = b;
        O.db.auras_pandemic_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_hpbar_color_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_hpbar_color_enabled:SetPosition('LEFT', self.auras_pandemic_color, 'RIGHT', 12, 0);
    self.auras_hpbar_color_enabled:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED']);
    self.auras_hpbar_color_enabled:SetTooltip(L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED_TOOLTIP']);
    self.auras_hpbar_color_enabled:AddToSearch(button, L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_hpbar_color_enabled:SetChecked(O.db.auras_hpbar_color_enabled);
    self.auras_hpbar_color_enabled.Callback = function(self)
        O.db.auras_hpbar_color_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.HPBarColorListButton = E.CreateButton(self.TabsFrames['CommonTab'].Content);
    self.HPBarColorListButton:SetPosition('LEFT', self.auras_hpbar_color_enabled.Label, 'RIGHT', 16, 0);
    self.HPBarColorListButton:SetScale(0.8);
    self.HPBarColorListButton:SetHighlightColor('ffa033');
    self.HPBarColorListButton:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_LIST_BUTTON_OPEN']);
    self.HPBarColorListButton:SetScript('OnClick', function(self)
        panel.HPBarColorList:SetShown(not panel.HPBarColorList:IsShown());

        if panel.HPBarColorList:IsShown() then
            self:LockHighlight();
            self:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_LIST_BUTTON_CLOSE']);
        else
            self:UnlockHighlight();
            self:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_LIST_BUTTON_OPEN']);
        end

        panel.BlackList:SetShown(false);
        panel.BlackListButton:UnlockHighlight();

        panel.WhiteList:SetShown(false);
        panel.WhiteListButton:UnlockHighlight();
    end);

    self.HPBarColorList = Mixin(CreateFrame('Frame', nil, self.TabsFrames['CommonTab'].Content, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.HPBarColorList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.HPBarColorList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.HPBarColorList:SetWidth(250);
    self.HPBarColorList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.HPBarColorList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.HPBarColorList:SetShown(false);

    self.HPBarColorListText = E.CreateFontString(self.HPBarColorList);
    self.HPBarColorListText:SetPosition('TOP', self.HPBarColorList, 'TOP', 0, -10);
    self.HPBarColorListText:SetText(L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED']);

    self.HPBarColorListEditbox = E.CreateEditBox(self.HPBarColorList);
    self.HPBarColorListEditbox:SetPosition('TOP', self.HPBarColorListText, 'BOTTOM', 0, -4);
    self.HPBarColorListEditbox:SetFrameLevel(self.HPBarColorList:GetFrameLevel() + 10);
    self.HPBarColorListEditbox:SetSize(228, 20);
    self.HPBarColorListEditbox.useLastValue = false;
    self.HPBarColorListEditbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.HPBarColorListEditbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        local byName = false;
        local byNameIcon;

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            byNameIcon = GetIconFromSpellCache(text);

            if byNameIcon then
                byName = true;
            end
        end

        if not saveId and not byName then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddHPBarColorAura(tonumber(saveId), byName, text);

        panel:UpdateHPBarColorScroll();
        self:SetText('');

        Stripes:UpdateAll();
    end);

    self.HPBarColorListScroll = Mixin(CreateFrame('Frame', nil, self.HPBarColorList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.HPBarColorListScroll:SetPoint('TOPLEFT', self.HPBarColorList , 'TOPLEFT', 6, -60);
    self.HPBarColorListScroll:SetPoint('BOTTOMRIGHT', self.HPBarColorList, 'BOTTOMRIGHT', -6, 6);
    self.HPBarColorListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.HPBarColorListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.HPBarColorListScrollChild, self.HPBarColorListScrollArea = E.CreateScrollFrame(self.HPBarColorListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.HPBarColorListScrollArea.ScrollBar, 'TOPLEFT', self.HPBarColorListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.HPBarColorListScrollArea.ScrollBar, 'BOTTOMLEFT', self.HPBarColorListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.HPBarColorButtonPool = CreateFramePool('Button', self.HPBarColorListScrollChild, 'BackdropTemplate');

    self:UpdateHPBarColorScroll();

    self.auras_expire_glow_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_enabled:SetPosition('TOPLEFT', self.auras_pandemic_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_expire_glow_enabled:SetLabel(L['OPTIONS_AURAS_EXPIRE_GLOW_ENABLED']);
    self.auras_expire_glow_enabled:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_ENABLED_TOOLTIP']);
    self.auras_expire_glow_enabled:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_enabled:SetChecked(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_enabled.Callback = function(self)
        O.db.auras_expire_glow_enabled = self:GetChecked();

        panel.auras_expire_glow_type:SetEnabled(O.db.auras_expire_glow_enabled);
        panel.auras_expire_glow_percent:SetEnabled(O.db.auras_expire_glow_enabled);
        panel.auras_expire_glow_percent_sign:SetFontObject(O.db.auras_expire_glow_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');
        panel.auras_expire_glow_color:SetEnabled(O.db.auras_expire_glow_enabled);

        Stripes:UpdateAll();
    end

    self.auras_expire_glow_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_color:SetPosition('LEFT', self.auras_expire_glow_enabled.Label, 'RIGHT', 12, 0);
    self.auras_expire_glow_color:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_COLOR_TOOLTIP']);
    self.auras_expire_glow_color:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_COLOR_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_color:SetValue(unpack(O.db.auras_expire_glow_color));
    self.auras_expire_glow_color:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_expire_glow_color[1] = r;
        O.db.auras_expire_glow_color[2] = g;
        O.db.auras_expire_glow_color[3] = b;
        O.db.auras_expire_glow_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_expire_glow_type = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_type:SetPosition('LEFT', self.auras_expire_glow_color, 'RIGHT', 12, 0);
    self.auras_expire_glow_type:SetSize(140, 20);
    self.auras_expire_glow_type:SetList(O.Lists.glow_type_short);
    self.auras_expire_glow_type:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_TYPE_TOOLTIP']);
    self.auras_expire_glow_type:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_TYPE_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_type:SetValue(O.db.auras_expire_glow_type);
    self.auras_expire_glow_type:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_type.OnValueChangedCallback = function(_, value)
        O.db.auras_expire_glow_type = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_expire_glow_percent = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_percent:SetPosition('LEFT', self.auras_expire_glow_type, 'RIGHT', 12, 0);
    self.auras_expire_glow_percent:SetW(140);
    self.auras_expire_glow_percent:SetValues(O.db.auras_expire_glow_percent, 1, 100, 1);
    self.auras_expire_glow_percent:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_PERCENT_TOOLTIP']);
    self.auras_expire_glow_percent:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_PERCENT_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_percent:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_percent.OnValueChangedCallback = function(_, value)
        O.db.auras_expire_glow_percent = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_expire_glow_percent_sign = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_percent_sign:SetPosition('LEFT', self.auras_expire_glow_percent, 'RIGHT', 2, 0);
    self.auras_expire_glow_percent_sign:SetText('%');
    self.auras_expire_glow_percent_sign:SetFontObject(O.db.auras_expire_glow_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');


    self.auras_masque_support = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_masque_support:SetPosition('TOPLEFT', self.auras_expire_glow_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_masque_support:SetLabel(L['OPTIONS_AURAS_MASQUE_SUPPORT']);
    self.auras_masque_support:SetTooltip(L['OPTIONS_AURAS_MASQUE_SUPPORT_TOOLTIP']);
    self.auras_masque_support:AddToSearch(button, L['OPTIONS_AURAS_MASQUE_SUPPORT_TOOLTIP'], self.Tabs[1]);
    self.auras_masque_support:SetChecked(O.db.auras_masque_support);
    self.auras_masque_support.Callback = function(self)
        O.db.auras_masque_support = self:GetChecked();
        Stripes:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_masque_support, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_max_display = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_max_display:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_max_display:SetW(104);
    self.auras_max_display:SetValues(O.db.auras_max_display, 1, 32, 1);
    self.auras_max_display:SetLabel(L['MAX_SHORT']);
    self.auras_max_display:SetTooltip(L['OPTIONS_AURAS_MAX_DISPLAY_TOOLTIP']);
    self.auras_max_display:AddToSearch(button, L['OPTIONS_AURAS_MAX_DISPLAY_TOOLTIP'], self.Tabs[1]);
    self.auras_max_display.OnValueChangedCallback = function(_, value)
        O.db.auras_max_display = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spacing_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_spacing_x:SetPosition('LEFT', self.auras_max_display, 'RIGHT', 16, 0);
    self.auras_spacing_x:SetW(104);
    self.auras_spacing_x:SetValues(O.db.auras_spacing_x, 0, 20, 1);
    self.auras_spacing_x:SetLabel(L['SPACING']);
    self.auras_spacing_x:SetTooltip(L['OPTIONS_AURAS_SPACING_X_TOOLTIP']);
    self.auras_spacing_x:AddToSearch(button, L['OPTIONS_AURAS_SPACING_X_TOOLTIP'], self.Tabs[1]);
    self.auras_spacing_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spacing_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_scale = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_scale:SetPosition('LEFT', self.auras_spacing_x, 'RIGHT', 16, 0);
    self.auras_scale:SetW(104);
    self.auras_scale:SetValues(O.db.auras_scale, 0.25, 3, 0.05);
    self.auras_scale:SetLabel(L['SCALE']);
    self.auras_scale:SetTooltip(L['OPTIONS_AURAS_SCALE_TOOLTIP']);
    self.auras_scale:AddToSearch(button, L['OPTIONS_AURAS_SCALE_TOOLTIP'], self.Tabs[1]);
    self.auras_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_offset_x:SetPosition('LEFT', self.auras_scale, 'RIGHT', 16, 0);
    self.auras_offset_x:SetW(104);
    self.auras_offset_x:SetValues(O.db.auras_offset_x, -200, 200, 1);
    self.auras_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.auras_offset_x:SetTooltip(L['OPTIONS_AURAS_OFFSET_X_TOOLTIP']);
    self.auras_offset_x:AddToSearch(button, L['OPTIONS_AURAS_OFFSET_X_TOOLTIP'], self.Tabs[1]);
    self.auras_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_offset_y:SetPosition('LEFT', self.auras_offset_x, 'RIGHT', 16, 0);
    self.auras_offset_y:SetW(104);
    self.auras_offset_y:SetValues(O.db.auras_offset_y, -200, 200, 1);
    self.auras_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.auras_offset_y:SetTooltip(L['OPTIONS_AURAS_OFFSET_Y_TOOLTIP']);
    self.auras_offset_y:AddToSearch(button, L['OPTIONS_AURAS_OFFSET_Y_TOOLTIP'], self.Tabs[1]);
    self.auras_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_max_display, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_countdown_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_countdown_enabled:SetLabel(L['OPTIONS_AURAS_COUNTDOWN_ENABLED']);
    self.auras_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_countdown_enabled:SetChecked(O.db.auras_countdown_enabled);
    self.auras_countdown_enabled.Callback = function(self)
        O.db.auras_countdown_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_omnicc_suppress = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_omnicc_suppress:SetPosition('LEFT', self.auras_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_omnicc_suppress:SetLabel(L['OPTIONS_AURAS_OMNICC_SUPPRESS']);
    self.auras_omnicc_suppress:SetTooltip(L['OPTIONS_AURAS_OMNICC_SUPPRESS_TOOLTIP']);
    self.auras_omnicc_suppress:AddToSearch(button, L['OPTIONS_AURAS_OMNICC_SUPPRESS_TOOLTIP'], self.Tabs[1]);
    self.auras_omnicc_suppress:SetChecked(O.db.auras_omnicc_suppress);
    self.auras_omnicc_suppress.Callback = function(self)
        O.db.auras_omnicc_suppress = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_draw_swipe = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_draw_swipe:SetPosition('LEFT', self.auras_omnicc_suppress.Label, 'RIGHT', 12, 0);
    self.auras_draw_swipe:SetLabel(L['OPTIONS_AURAS_DRAW_SWIPE']);
    self.auras_draw_swipe:SetTooltip(L['OPTIONS_AURAS_DRAW_SWIPE_TOOLTIP']);
    self.auras_draw_swipe:AddToSearch(button, L['OPTIONS_AURAS_DRAW_SWIPE_TOOLTIP'], self.Tabs[1]);
    self.auras_draw_swipe:SetChecked(O.db.auras_draw_swipe);
    self.auras_draw_swipe.Callback = function(self)
        O.db.auras_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_draw_edge = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_draw_edge:SetPosition('LEFT', self.auras_draw_swipe.Label, 'RIGHT', 12, 0);
    self.auras_draw_edge:SetLabel(L['OPTIONS_AURAS_DRAW_EDGE']);
    self.auras_draw_edge:SetTooltip(L['OPTIONS_AURAS_DRAW_EDGE_TOOLTIP']);
    self.auras_draw_edge:AddToSearch(button, L['OPTIONS_AURAS_DRAW_EDGE_TOOLTIP'], self.Tabs[1]);
    self.auras_draw_edge:SetChecked(O.db.auras_draw_edge);
    self.auras_draw_edge.Callback = function(self)
        O.db.auras_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_countdown_text = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_countdown_text:SetPosition('TOPLEFT', self.auras_countdown_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_cooldown_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_color:SetPosition('LEFT', self.auras_countdown_text, 'RIGHT', 12, 0);
    self.auras_cooldown_color:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_COLOR_TOOLTIP']);
    self.auras_cooldown_color:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_COLOR_TOOLTIP'], self.Tabs[1]);
    self.auras_cooldown_color:SetValue(unpack(O.db.auras_cooldown_color));
    self.auras_cooldown_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_cooldown_color[1] = r;
        O.db.auras_cooldown_color[2] = g;
        O.db.auras_cooldown_color[3] = b;
        O.db.auras_cooldown_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_value:SetPosition('TOPLEFT', self.auras_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_cooldown_font_value:SetSize(160, 20);
    self.auras_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_cooldown_font_value:SetValue(O.db.auras_cooldown_font_value);
    self.auras_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_VALUE']);
    self.auras_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_VALUE'], self.Tabs[1]);
    self.auras_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_cooldown_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_size:SetPosition('LEFT', self.auras_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_cooldown_font_size:SetValues(O.db.auras_cooldown_font_size, 3, 28, 1);
    self.auras_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_SIZE']);
    self.auras_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_SIZE'], self.Tabs[1]);
    self.auras_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_cooldown_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_flag:SetPosition('LEFT', self.auras_cooldown_font_size, 'RIGHT', 12, 0);
    self.auras_cooldown_font_flag:SetSize(160, 20);
    self.auras_cooldown_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_cooldown_font_flag:SetValue(O.db.auras_cooldown_font_flag);
    self.auras_cooldown_font_flag:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_FLAG']);
    self.auras_cooldown_font_flag:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_FLAG'], self.Tabs[1]);
    self.auras_cooldown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_shadow:SetPosition('LEFT', self.auras_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_cooldown_font_shadow:SetChecked(O.db.auras_cooldown_font_shadow);
    self.auras_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW']);
    self.auras_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW'], self.Tabs[1]);
    self.auras_cooldown_font_shadow.Callback = function(self)
        O.db.auras_cooldown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_cooldown_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_point:SetPosition('TOPLEFT', self.auras_cooldown_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_cooldown_point:SetSize(120, 20);
    self.auras_cooldown_point:SetList(O.Lists.frame_points_localized);
    self.auras_cooldown_point:SetValue(O.db.auras_cooldown_point);
    self.auras_cooldown_point:SetLabel(L['POSITION']);
    self.auras_cooldown_point:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_POINT_TOOLTIP']);
    self.auras_cooldown_point:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_POINT_TOOLTIP'], self.Tabs[1]);
    self.auras_cooldown_point.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_cooldown_relative_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_relative_point:SetPosition('LEFT', self.auras_cooldown_point, 'RIGHT', 12, 0);
    self.auras_cooldown_relative_point:SetSize(120, 20);
    self.auras_cooldown_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_cooldown_relative_point:SetValue(O.db.auras_cooldown_relative_point);
    self.auras_cooldown_relative_point:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_RELATIVE_POINT_TOOLTIP']);
    self.auras_cooldown_relative_point:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_RELATIVE_POINT_TOOLTIP'], self.Tabs[1]);
    self.auras_cooldown_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_cooldown_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_offset_x:SetPosition('LEFT', self.auras_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_cooldown_offset_x:SetSize(120, 18);
    self.auras_cooldown_offset_x:SetValues(O.db.auras_cooldown_offset_x, -50, 50, 1);
    self.auras_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_cooldown_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_offset_y:SetPosition('LEFT', self.auras_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_cooldown_offset_y:SetSize(120, 18);
    self.auras_cooldown_offset_y:SetValues(O.db.auras_cooldown_offset_y, -50, 50, 1);
    self.auras_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_cooldown_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_count_text = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_count_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -2);
    self.auras_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_count_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.auras_count_color:SetPosition('LEFT', self.auras_count_text, 'RIGHT', 12, 0);
    self.auras_count_color:SetTooltip(L['OPTIONS_AURAS_COUNT_COLOR_TOOLTIP']);
    self.auras_count_color:AddToSearch(button, L['OPTIONS_AURAS_COUNT_COLOR_TOOLTIP'], self.Tabs[1]);
    self.auras_count_color:SetValue(unpack(O.db.auras_count_color));
    self.auras_count_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_count_color[1] = r;
        O.db.auras_count_color[2] = g;
        O.db.auras_count_color[3] = b;
        O.db.auras_count_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_count_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_value:SetPosition('TOPLEFT', self.auras_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_count_font_value:SetSize(160, 20);
    self.auras_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_count_font_value:SetValue(O.db.auras_count_font_value);
    self.auras_count_font_value:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_VALUE']);
    self.auras_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_VALUE'], self.Tabs[1]);
    self.auras_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_count_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_count_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_size:SetPosition('LEFT', self.auras_count_font_value, 'RIGHT', 12, 0);
    self.auras_count_font_size:SetValues(O.db.auras_count_font_size, 3, 28, 1);
    self.auras_count_font_size:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_SIZE']);
    self.auras_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_SIZE'], self.Tabs[1]);
    self.auras_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_count_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_count_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_flag:SetPosition('LEFT', self.auras_count_font_size, 'RIGHT', 12, 0);
    self.auras_count_font_flag:SetSize(160, 20);
    self.auras_count_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_count_font_flag:SetValue(O.db.auras_count_font_flag);
    self.auras_count_font_flag:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_FLAG']);
    self.auras_count_font_flag:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_FLAG'], self.Tabs[1]);
    self.auras_count_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_count_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_count_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_shadow:SetPosition('LEFT', self.auras_count_font_flag, 'RIGHT', 12, 0);
    self.auras_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_count_font_shadow:SetChecked(O.db.auras_count_font_shadow);
    self.auras_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_SHADOW']);
    self.auras_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_SHADOW'], self.Tabs[1]);
    self.auras_count_font_shadow.Callback = function(self)
        O.db.auras_count_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_count_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_count_point:SetPosition('TOPLEFT', self.auras_count_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_count_point:SetSize(120, 20);
    self.auras_count_point:SetList(O.Lists.frame_points_localized);
    self.auras_count_point:SetValue(O.db.auras_count_point);
    self.auras_count_point:SetLabel(L['POSITION']);
    self.auras_count_point:SetTooltip(L['OPTIONS_AURAS_COUNT_POINT_TOOLTIP']);
    self.auras_count_point:AddToSearch(button, L['OPTIONS_AURAS_COUNT_POINT_TOOLTIP'], self.Tabs[1]);
    self.auras_count_point.OnValueChangedCallback = function(_, value)
        O.db.auras_count_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_count_relative_point:SetPosition('LEFT', self.auras_count_point, 'RIGHT', 12, 0);
    self.auras_count_relative_point:SetSize(120, 20);
    self.auras_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_count_relative_point:SetValue(O.db.auras_count_relative_point);
    self.auras_count_relative_point:SetTooltip(L['OPTIONS_AURAS_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[1]);
    self.auras_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_count_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_count_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_offset_x:SetPosition('LEFT', self.auras_count_relative_point, 'RIGHT', 8, 0);
    self.auras_count_offset_x:SetSize(120, 18);
    self.auras_count_offset_x:SetValues(O.db.auras_count_offset_x, -50, 50, 1);
    self.auras_count_offset_x:SetTooltip(L['OPTIONS_AURAS_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_count_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_count_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_offset_y:SetPosition('LEFT', self.auras_count_offset_x, 'RIGHT', 12, 0);
    self.auras_count_offset_y:SetSize(120, 18);
    self.auras_count_offset_y:SetValues(O.db.auras_count_offset_y, -50, 50, 1);
    self.auras_count_offset_y:SetTooltip(L['OPTIONS_AURAS_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_count_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Spellsteal Tab ------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_spellsteal_enabled = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_enabled:SetPosition('TOPLEFT', self.TabsFrames['SpellstealTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_spellsteal_enabled:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_ENABLED']);
    self.auras_spellsteal_enabled:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_ENABLED_TOOLTIP']);
    self.auras_spellsteal_enabled:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_enabled:SetChecked(O.db.auras_spellsteal_enabled);
    self.auras_spellsteal_enabled.Callback = function(self)
        O.db.auras_spellsteal_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_color = E.CreateColorPicker(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_color:SetPosition('LEFT', self.auras_spellsteal_enabled.Label, 'RIGHT', 12, 0);
    self.auras_spellsteal_color:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COLOR_TOOLTIP']);
    self.auras_spellsteal_color:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COLOR_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_color:SetValue(unpack(O.db.auras_spellsteal_color));
    self.auras_spellsteal_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_spellsteal_color[1] = r;
        O.db.auras_spellsteal_color[2] = g;
        O.db.auras_spellsteal_color[3] = b;
        O.db.auras_spellsteal_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_spellsteal_glow_enabled = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_glow_enabled:SetPosition('LEFT', self.auras_spellsteal_color, 'RIGHT', 12, 0);
    self.auras_spellsteal_glow_enabled:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_GLOW_ENABLED']);
    self.auras_spellsteal_glow_enabled:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_GLOW_ENABLED_TOOLTIP']);
    self.auras_spellsteal_glow_enabled:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_GLOW_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_glow_enabled:SetChecked(O.db.auras_spellsteal_glow_enabled);
    self.auras_spellsteal_glow_enabled.Callback = function(self)
        O.db.auras_spellsteal_glow_enabled = self:GetChecked();

        panel.auras_spellsteal_glow_type:SetEnabled(O.db.auras_spellsteal_glow_enabled);
        panel.auras_spellsteal_glow_color:SetEnabled(O.db.auras_spellsteal_glow_enabled);

        Stripes:UpdateAll();
    end

    self.auras_spellsteal_glow_type = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_glow_type:SetPosition('LEFT', self.auras_spellsteal_glow_enabled.Label, 'RIGHT', 12, 0);
    self.auras_spellsteal_glow_type:SetSize(220, 20);
    self.auras_spellsteal_glow_type:SetList(O.Lists.glow_type);
    self.auras_spellsteal_glow_type:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_GLOW_TYPE_TOOLTIP']);
    self.auras_spellsteal_glow_type:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_GLOW_TYPE_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_glow_type:SetValue(O.db.auras_spellsteal_glow_type);
    self.auras_spellsteal_glow_type:SetEnabled(O.db.auras_spellsteal_glow_enabled);
    self.auras_spellsteal_glow_type.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_glow_type = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_glow_color = E.CreateColorPicker(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_glow_color:SetPosition('LEFT', self.auras_spellsteal_glow_type, 'RIGHT', 12, 0);
    self.auras_spellsteal_glow_color:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_GLOW_COLOR_TOOLTIP']);
    self.auras_spellsteal_glow_color:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_GLOW_COLOR_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_glow_color:SetValue(unpack(O.db.auras_spellsteal_glow_color));
    self.auras_spellsteal_glow_color:SetEnabled(O.db.auras_spellsteal_glow_enabled);
    self.auras_spellsteal_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_spellsteal_glow_color[1] = r;
        O.db.auras_spellsteal_glow_color[2] = g;
        O.db.auras_spellsteal_glow_color[3] = b;
        O.db.auras_spellsteal_glow_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_spellsteal_direction = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_direction:SetPosition('TOPLEFT', self.auras_spellsteal_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_spellsteal_direction:SetSize(180, 20);
    self.auras_spellsteal_direction:SetList(O.Lists.auras_horizontal_direction);
    self.auras_spellsteal_direction:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_DIRECTION']);
    self.auras_spellsteal_direction:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_DIRECTION_TOOLTIP']);
    self.auras_spellsteal_direction:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_DIRECTION_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_direction:SetValue(O.db.auras_spellsteal_direction);
    self.auras_spellsteal_direction.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_direction = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellstealTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_spellsteal_direction, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_spellsteal_max_display = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_max_display:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_spellsteal_max_display:SetW(104);
    self.auras_spellsteal_max_display:SetValues(O.db.auras_spellsteal_max_display, 1, 32, 1);
    self.auras_spellsteal_max_display:SetLabel(L['MAX_SHORT']);
    self.auras_spellsteal_max_display:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_MAX_DISPLAY_TOOLTIP']);
    self.auras_spellsteal_max_display:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_MAX_DISPLAY_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_max_display.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_max_display = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_spacing_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_spacing_x:SetPosition('LEFT', self.auras_spellsteal_max_display, 'RIGHT', 16, 0);
    self.auras_spellsteal_spacing_x:SetW(104);
    self.auras_spellsteal_spacing_x:SetValues(O.db.auras_spellsteal_spacing_x, 0, 20, 1);
    self.auras_spellsteal_spacing_x:SetLabel(L['SPACING']);
    self.auras_spellsteal_spacing_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_SPACING_X_TOOLTIP']);
    self.auras_spellsteal_spacing_x:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_SPACING_X_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_spacing_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_spacing_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_scale = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_scale:SetPosition('LEFT', self.auras_spellsteal_spacing_x, 'RIGHT', 16, 0);
    self.auras_spellsteal_scale:SetW(104);
    self.auras_spellsteal_scale:SetValues(O.db.auras_spellsteal_scale, 0.25, 4, 0.05);
    self.auras_spellsteal_scale:SetLabel(L['SCALE']);
    self.auras_spellsteal_scale:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_SCALE_TOOLTIP']);
    self.auras_spellsteal_scale:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_SCALE_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_offset_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_offset_x:SetPosition('LEFT', self.auras_spellsteal_scale, 'RIGHT', 16, 0);
    self.auras_spellsteal_offset_x:SetW(104);
    self.auras_spellsteal_offset_x:SetValues(O.db.auras_spellsteal_offset_x, -200, 200, 1);
    self.auras_spellsteal_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.auras_spellsteal_offset_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_OFFSET_X_TOOLTIP']);
    self.auras_spellsteal_offset_x:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_OFFSET_X_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_offset_y = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_offset_y:SetPosition('LEFT', self.auras_spellsteal_offset_x, 'RIGHT', 16, 0);
    self.auras_spellsteal_offset_y:SetW(104);
    self.auras_spellsteal_offset_y:SetValues(O.db.auras_spellsteal_offset_y, -200, 200, 1);
    self.auras_spellsteal_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.auras_spellsteal_offset_y:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_OFFSET_Y_TOOLTIP']);
    self.auras_spellsteal_offset_y:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_OFFSET_Y_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_static_position = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_static_position:SetPosition('TOPLEFT', self.auras_spellsteal_max_display, 'BOTTOMLEFT', 0, -14);
    self.auras_spellsteal_static_position:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_STATIC_POSITION']);
    self.auras_spellsteal_static_position:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_STATIC_POSITION_TOOLTIP']);
    self.auras_spellsteal_static_position:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_STATIC_POSITION_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_static_position:SetChecked(O.db.auras_spellsteal_static_position);
    self.auras_spellsteal_static_position.Callback = function(self)
        O.db.auras_spellsteal_static_position = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellstealTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_spellsteal_static_position, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_spellsteal_countdown_enabled = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_spellsteal_countdown_enabled:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED']);
    self.auras_spellsteal_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_spellsteal_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_countdown_enabled:SetChecked(O.db.auras_spellsteal_countdown_enabled);
    self.auras_spellsteal_countdown_enabled.Callback = function(self)
        O.db.auras_spellsteal_countdown_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_draw_swipe = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_draw_swipe:SetPosition('LEFT', self.auras_spellsteal_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_spellsteal_draw_swipe:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_DRAW_SWIPE']);
    self.auras_spellsteal_draw_swipe:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_DRAW_SWIPE_TOOLTIP']);
    self.auras_spellsteal_draw_swipe:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_DRAW_SWIPE_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_draw_swipe:SetChecked(O.db.auras_spellsteal_draw_swipe);
    self.auras_spellsteal_draw_swipe.Callback = function(self)
        O.db.auras_spellsteal_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_draw_edge = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_draw_edge:SetPosition('LEFT', self.auras_spellsteal_draw_swipe.Label, 'RIGHT', 12, 0);
    self.auras_spellsteal_draw_edge:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_DRAW_EDGE']);
    self.auras_spellsteal_draw_edge:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_DRAW_EDGE_TOOLTIP']);
    self.auras_spellsteal_draw_edge:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_DRAW_EDGE_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_draw_edge:SetChecked(O.db.auras_spellsteal_draw_edge);
    self.auras_spellsteal_draw_edge.Callback = function(self)
        O.db.auras_spellsteal_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_countdown_text = E.CreateFontString(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_countdown_text:SetPosition('TOPLEFT', self.auras_spellsteal_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_spellsteal_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_spellsteal_cooldown_color = E.CreateColorPicker(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_color:SetPosition('LEFT', self.auras_spellsteal_countdown_text, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_color:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_COLOR_TOOLTIP']);
    self.auras_spellsteal_cooldown_color:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_COLOR_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_color:SetValue(unpack(O.db.auras_spellsteal_cooldown_color));
    self.auras_spellsteal_cooldown_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_spellsteal_cooldown_color[1] = r;
        O.db.auras_spellsteal_cooldown_color[2] = g;
        O.db.auras_spellsteal_cooldown_color[3] = b;
        O.db.auras_spellsteal_cooldown_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_value:SetPosition('TOPLEFT', self.auras_spellsteal_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_spellsteal_cooldown_font_value:SetSize(160, 20);
    self.auras_spellsteal_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_spellsteal_cooldown_font_value:SetValue(O.db.auras_spellsteal_cooldown_font_value);
    self.auras_spellsteal_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_VALUE']);
    self.auras_spellsteal_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_VALUE'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_size = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_size:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_font_size:SetValues(O.db.auras_spellsteal_cooldown_font_size, 3, 28, 1);
    self.auras_spellsteal_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SIZE']);
    self.auras_spellsteal_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SIZE'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_flag = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_flag:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_size, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_font_flag:SetSize(160, 20);
    self.auras_spellsteal_cooldown_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_spellsteal_cooldown_font_flag:SetValue(O.db.auras_spellsteal_cooldown_font_flag);
    self.auras_spellsteal_cooldown_font_flag:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_FLAG']);
    self.auras_spellsteal_cooldown_font_flag:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_FLAG'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_shadow:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_spellsteal_cooldown_font_shadow:SetChecked(O.db.auras_spellsteal_cooldown_font_shadow);
    self.auras_spellsteal_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW']);
    self.auras_spellsteal_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_cooldown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_point = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_point:SetPosition('TOPLEFT', self.auras_spellsteal_cooldown_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_spellsteal_cooldown_point:SetSize(120, 20);
    self.auras_spellsteal_cooldown_point:SetList(O.Lists.frame_points_localized);
    self.auras_spellsteal_cooldown_point:SetValue(O.db.auras_spellsteal_cooldown_point);
    self.auras_spellsteal_cooldown_point:SetLabel(L['POSITION']);
    self.auras_spellsteal_cooldown_point:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_POINT_TOOLTIP']);
    self.auras_spellsteal_cooldown_point:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_POINT_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_point.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_relative_point = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_relative_point:SetPosition('LEFT', self.auras_spellsteal_cooldown_point, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_relative_point:SetSize(120, 20);
    self.auras_spellsteal_cooldown_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_spellsteal_cooldown_relative_point:SetValue(O.db.auras_spellsteal_cooldown_relative_point);
    self.auras_spellsteal_cooldown_relative_point:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_RELATIVE_POINT_TOOLTIP']);
    self.auras_spellsteal_cooldown_relative_point:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_RELATIVE_POINT_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_offset_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_offset_x:SetPosition('LEFT', self.auras_spellsteal_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_spellsteal_cooldown_offset_x:SetSize(120, 18);
    self.auras_spellsteal_cooldown_offset_x:SetValues(O.db.auras_spellsteal_cooldown_offset_x, -50, 50, 1);
    self.auras_spellsteal_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_spellsteal_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_cooldown_offset_y = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_offset_y:SetPosition('LEFT', self.auras_spellsteal_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_offset_y:SetSize(120, 18);
    self.auras_spellsteal_cooldown_offset_y:SetValues(O.db.auras_spellsteal_cooldown_offset_y, -50, 50, 1);
    self.auras_spellsteal_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_spellsteal_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellstealTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_spellsteal_cooldown_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_spellsteal_count_text = E.CreateFontString(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -2);
    self.auras_spellsteal_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_spellsteal_count_color = E.CreateColorPicker(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_color:SetPosition('LEFT', self.auras_spellsteal_count_text, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_color:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_COLOR_TOOLTIP']);
    self.auras_spellsteal_count_color:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_COLOR_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_count_color:SetValue(unpack(O.db.auras_spellsteal_count_color));
    self.auras_spellsteal_count_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_spellsteal_count_color[1] = r;
        O.db.auras_spellsteal_count_color[2] = g;
        O.db.auras_spellsteal_count_color[3] = b;
        O.db.auras_spellsteal_count_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_font_value = E.CreateDropdown('font', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_value:SetPosition('TOPLEFT', self.auras_spellsteal_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_spellsteal_count_font_value:SetSize(160, 20);
    self.auras_spellsteal_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_spellsteal_count_font_value:SetValue(O.db.auras_spellsteal_count_font_value);
    self.auras_spellsteal_count_font_value:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_VALUE']);
    self.auras_spellsteal_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_VALUE'], self.Tabs[2]);
    self.auras_spellsteal_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_font_size = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_size:SetPosition('LEFT', self.auras_spellsteal_count_font_value, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_font_size:SetValues(O.db.auras_spellsteal_count_font_size, 3, 28, 1);
    self.auras_spellsteal_count_font_size:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SIZE']);
    self.auras_spellsteal_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SIZE'], self.Tabs[2]);
    self.auras_spellsteal_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_font_flag = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_flag:SetPosition('LEFT', self.auras_spellsteal_count_font_size, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_font_flag:SetSize(160, 20);
    self.auras_spellsteal_count_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_spellsteal_count_font_flag:SetValue(O.db.auras_spellsteal_count_font_flag);
    self.auras_spellsteal_count_font_flag:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_FLAG']);
    self.auras_spellsteal_count_font_flag:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_FLAG'], self.Tabs[2]);
    self.auras_spellsteal_count_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_shadow:SetPosition('LEFT', self.auras_spellsteal_count_font_flag, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_spellsteal_count_font_shadow:SetChecked(O.db.auras_spellsteal_count_font_shadow);
    self.auras_spellsteal_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW']);
    self.auras_spellsteal_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_count_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_count_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_point = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_point:SetPosition('TOPLEFT', self.auras_spellsteal_count_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_spellsteal_count_point:SetSize(120, 20);
    self.auras_spellsteal_count_point:SetList(O.Lists.frame_points_localized);
    self.auras_spellsteal_count_point:SetValue(O.db.auras_spellsteal_count_point);
    self.auras_spellsteal_count_point:SetLabel(L['POSITION']);
    self.auras_spellsteal_count_point:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_POINT_TOOLTIP']);
    self.auras_spellsteal_count_point:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_POINT_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_count_point.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_relative_point:SetPosition('LEFT', self.auras_spellsteal_count_point, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_relative_point:SetSize(120, 20);
    self.auras_spellsteal_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_spellsteal_count_relative_point:SetValue(O.db.auras_spellsteal_count_relative_point);
    self.auras_spellsteal_count_relative_point:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_spellsteal_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_offset_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_offset_x:SetPosition('LEFT', self.auras_spellsteal_count_relative_point, 'RIGHT', 8, 0);
    self.auras_spellsteal_count_offset_x:SetSize(120, 18);
    self.auras_spellsteal_count_offset_x:SetValues(O.db.auras_spellsteal_count_offset_x, -50, 50, 1);
    self.auras_spellsteal_count_offset_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_spellsteal_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_spellsteal_count_offset_y = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_offset_y:SetPosition('LEFT', self.auras_spellsteal_count_offset_x, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_offset_y:SetSize(120, 18);
    self.auras_spellsteal_count_offset_y:SetValues(O.db.auras_spellsteal_count_offset_y, -50, 50, 1);
    self.auras_spellsteal_count_offset_y:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_spellsteal_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Mythic Plus Tab -----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_mythicplus_enabled = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_enabled:SetPosition('TOPLEFT', self.TabsFrames['MythicPlusTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_mythicplus_enabled:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_ENABLED']);
    self.auras_mythicplus_enabled:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_ENABLED_TOOLTIP']);
    self.auras_mythicplus_enabled:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_enabled:SetChecked(O.db.auras_mythicplus_enabled);
    self.auras_mythicplus_enabled.Callback = function(self)
        O.db.auras_mythicplus_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_border_color = E.CreateColorPicker(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_border_color:SetPosition('LEFT', self.auras_mythicplus_enabled.Label, 'RIGHT', 12, 0);
    self.auras_mythicplus_border_color:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_BORDER_COLOR_TOOLTIP']);
    self.auras_mythicplus_border_color:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_BORDER_COLOR_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_border_color:SetValue(unpack(O.db.auras_mythicplus_border_color));
    self.auras_mythicplus_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_mythicplus_border_color[1] = r;
        O.db.auras_mythicplus_border_color[2] = g;
        O.db.auras_mythicplus_border_color[3] = b;
        O.db.auras_mythicplus_border_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_mythicplus_direction = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_direction:SetPosition('TOPLEFT', self.auras_mythicplus_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_mythicplus_direction:SetSize(180, 20);
    self.auras_mythicplus_direction:SetList(O.Lists.auras_horizontal_direction);
    self.auras_mythicplus_direction:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_DIRECTION']);
    self.auras_mythicplus_direction:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_DIRECTION_TOOLTIP']);
    self.auras_mythicplus_direction:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_DIRECTION_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_direction:SetValue(O.db.auras_mythicplus_direction);
    self.auras_mythicplus_direction.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_direction = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['MythicPlusTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_mythicplus_direction, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_mythicplus_max_display = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_max_display:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_mythicplus_max_display:SetW(104);
    self.auras_mythicplus_max_display:SetValues(O.db.auras_mythicplus_max_display, 1, 32, 1);
    self.auras_mythicplus_max_display:SetLabel(L['MAX_SHORT']);
    self.auras_mythicplus_max_display:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_MAX_DISPLAY_TOOLTIP']);
    self.auras_mythicplus_max_display:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_MAX_DISPLAY_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_max_display.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_max_display = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_spacing_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_spacing_x:SetPosition('LEFT', self.auras_mythicplus_max_display, 'RIGHT', 16, 0);
    self.auras_mythicplus_spacing_x:SetW(104);
    self.auras_mythicplus_spacing_x:SetValues(O.db.auras_mythicplus_spacing_x, 0, 20, 1);
    self.auras_mythicplus_spacing_x:SetLabel(L['SPACING']);
    self.auras_mythicplus_spacing_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_SPACING_X_TOOLTIP']);
    self.auras_mythicplus_spacing_x:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_SPACING_X_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_spacing_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_spacing_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_scale = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_scale:SetPosition('LEFT', self.auras_mythicplus_spacing_x, 'RIGHT', 16, 0);
    self.auras_mythicplus_scale:SetW(104);
    self.auras_mythicplus_scale:SetValues(O.db.auras_mythicplus_scale, 0.25, 4, 0.05);
    self.auras_mythicplus_scale:SetLabel(L['SCALE']);
    self.auras_mythicplus_scale:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_SCALE_TOOLTIP']);
    self.auras_mythicplus_scale:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_SCALE_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_offset_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_offset_x:SetPosition('LEFT', self.auras_mythicplus_scale, 'RIGHT', 16, 0);
    self.auras_mythicplus_offset_x:SetW(104);
    self.auras_mythicplus_offset_x:SetValues(O.db.auras_mythicplus_offset_x, -200, 200, 1);
    self.auras_mythicplus_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.auras_mythicplus_offset_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_OFFSET_X_TOOLTIP']);
    self.auras_mythicplus_offset_x:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_OFFSET_X_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_offset_y = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_offset_y:SetPosition('LEFT', self.auras_mythicplus_offset_x, 'RIGHT', 16, 0);
    self.auras_mythicplus_offset_y:SetW(104);
    self.auras_mythicplus_offset_y:SetValues(O.db.auras_mythicplus_offset_y, -200, 200, 1);
    self.auras_mythicplus_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.auras_mythicplus_offset_y:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_OFFSET_Y_TOOLTIP']);
    self.auras_mythicplus_offset_y:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_OFFSET_Y_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['MythicPlusTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_mythicplus_max_display, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_mythicplus_countdown_enabled = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_mythicplus_countdown_enabled:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED']);
    self.auras_mythicplus_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_mythicplus_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_countdown_enabled:SetChecked(O.db.auras_mythicplus_countdown_enabled);
    self.auras_mythicplus_countdown_enabled.Callback = function(self)
        O.db.auras_mythicplus_countdown_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_draw_swipe = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_draw_swipe:SetPosition('LEFT', self.auras_mythicplus_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_mythicplus_draw_swipe:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_DRAW_SWIPE']);
    self.auras_mythicplus_draw_swipe:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_DRAW_SWIPE_TOOLTIP']);
    self.auras_mythicplus_draw_swipe:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_DRAW_SWIPE_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_draw_swipe:SetChecked(O.db.auras_mythicplus_draw_swipe);
    self.auras_mythicplus_draw_swipe.Callback = function(self)
        O.db.auras_mythicplus_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_draw_edge = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_draw_edge:SetPosition('LEFT', self.auras_mythicplus_draw_swipe.Label, 'RIGHT', 12, 0);
    self.auras_mythicplus_draw_edge:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_DRAW_EDGE']);
    self.auras_mythicplus_draw_edge:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_DRAW_EDGE_TOOLTIP']);
    self.auras_mythicplus_draw_edge:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_DRAW_EDGE_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_draw_edge:SetChecked(O.db.auras_mythicplus_draw_edge);
    self.auras_mythicplus_draw_edge.Callback = function(self)
        O.db.auras_mythicplus_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_countdown_text = E.CreateFontString(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_countdown_text:SetPosition('TOPLEFT', self.auras_mythicplus_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_mythicplus_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_mythicplus_cooldown_color = E.CreateColorPicker(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_color:SetPosition('LEFT', self.auras_mythicplus_countdown_text, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_color:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_COLOR_TOOLTIP']);
    self.auras_mythicplus_cooldown_color:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_COLOR_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_color:SetValue(unpack(O.db.auras_mythicplus_cooldown_color));
    self.auras_mythicplus_cooldown_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_mythicplus_cooldown_color[1] = r;
        O.db.auras_mythicplus_cooldown_color[2] = g;
        O.db.auras_mythicplus_cooldown_color[3] = b;
        O.db.auras_mythicplus_cooldown_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_value:SetPosition('TOPLEFT', self.auras_mythicplus_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_mythicplus_cooldown_font_value:SetSize(160, 20);
    self.auras_mythicplus_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_mythicplus_cooldown_font_value:SetValue(O.db.auras_mythicplus_cooldown_font_value);
    self.auras_mythicplus_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_VALUE']);
    self.auras_mythicplus_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_VALUE'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_size = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_size:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_font_size:SetValues(O.db.auras_mythicplus_cooldown_font_size, 3, 28, 1);
    self.auras_mythicplus_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SIZE']);
    self.auras_mythicplus_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SIZE'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_flag = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_flag:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_size, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_font_flag:SetSize(160, 20);
    self.auras_mythicplus_cooldown_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_mythicplus_cooldown_font_flag:SetValue(O.db.auras_mythicplus_cooldown_font_flag);
    self.auras_mythicplus_cooldown_font_flag:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_FLAG']);
    self.auras_mythicplus_cooldown_font_flag:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_FLAG'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_shadow:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_mythicplus_cooldown_font_shadow:SetChecked(O.db.auras_mythicplus_cooldown_font_shadow);
    self.auras_mythicplus_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW']);
    self.auras_mythicplus_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_cooldown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_point = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_point:SetPosition('TOPLEFT', self.auras_mythicplus_cooldown_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_mythicplus_cooldown_point:SetSize(120, 20);
    self.auras_mythicplus_cooldown_point:SetList(O.Lists.frame_points_localized);
    self.auras_mythicplus_cooldown_point:SetValue(O.db.auras_mythicplus_cooldown_point);
    self.auras_mythicplus_cooldown_point:SetLabel(L['POSITION']);
    self.auras_mythicplus_cooldown_point:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_POINT_TOOLTIP']);
    self.auras_mythicplus_cooldown_point:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_POINT_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_point.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_relative_point = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_relative_point:SetPosition('LEFT', self.auras_mythicplus_cooldown_point, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_relative_point:SetSize(120, 20);
    self.auras_mythicplus_cooldown_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_mythicplus_cooldown_relative_point:SetValue(O.db.auras_mythicplus_cooldown_relative_point);
    self.auras_mythicplus_cooldown_relative_point:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_RELATIVE_POINT_TOOLTIP']);
    self.auras_mythicplus_cooldown_relative_point:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_RELATIVE_POINT_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_offset_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_offset_x:SetPosition('LEFT', self.auras_mythicplus_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_mythicplus_cooldown_offset_x:SetSize(120, 18);
    self.auras_mythicplus_cooldown_offset_x:SetValues(O.db.auras_mythicplus_cooldown_offset_x, -50, 50, 1);
    self.auras_mythicplus_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_mythicplus_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_cooldown_offset_y = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_offset_y:SetPosition('LEFT', self.auras_mythicplus_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_offset_y:SetSize(120, 18);
    self.auras_mythicplus_cooldown_offset_y:SetValues(O.db.auras_mythicplus_cooldown_offset_y, -50, 50, 1);
    self.auras_mythicplus_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_mythicplus_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['MythicPlusTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_mythicplus_cooldown_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_mythicplus_count_text = E.CreateFontString(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -2);
    self.auras_mythicplus_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_mythicplus_count_color = E.CreateColorPicker(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_color:SetPosition('LEFT', self.auras_mythicplus_count_text, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_color:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_COLOR_TOOLTIP']);
    self.auras_mythicplus_count_color:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_COLOR_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_count_color:SetValue(unpack(O.db.auras_mythicplus_count_color));
    self.auras_mythicplus_count_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_mythicplus_count_color[1] = r;
        O.db.auras_mythicplus_count_color[2] = g;
        O.db.auras_mythicplus_count_color[3] = b;
        O.db.auras_mythicplus_count_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_font_value = E.CreateDropdown('font', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_value:SetPosition('TOPLEFT', self.auras_mythicplus_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_mythicplus_count_font_value:SetSize(160, 20);
    self.auras_mythicplus_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_mythicplus_count_font_value:SetValue(O.db.auras_mythicplus_count_font_value);
    self.auras_mythicplus_count_font_value:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_VALUE']);
    self.auras_mythicplus_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_VALUE'], self.Tabs[3]);
    self.auras_mythicplus_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_font_size = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_size:SetPosition('LEFT', self.auras_mythicplus_count_font_value, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_font_size:SetValues(O.db.auras_mythicplus_count_font_size, 3, 28, 1);
    self.auras_mythicplus_count_font_size:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SIZE']);
    self.auras_mythicplus_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SIZE'], self.Tabs[3]);
    self.auras_mythicplus_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_font_flag = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_flag:SetPosition('LEFT', self.auras_mythicplus_count_font_size, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_font_flag:SetSize(160, 20);
    self.auras_mythicplus_count_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_mythicplus_count_font_flag:SetValue(O.db.auras_mythicplus_count_font_flag);
    self.auras_mythicplus_count_font_flag:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_FLAG']);
    self.auras_mythicplus_count_font_flag:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_FLAG'], self.Tabs[3]);
    self.auras_mythicplus_count_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_font_shadow = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_shadow:SetPosition('LEFT', self.auras_mythicplus_count_font_flag, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_mythicplus_count_font_shadow:SetChecked(O.db.auras_mythicplus_count_font_shadow);
    self.auras_mythicplus_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW']);
    self.auras_mythicplus_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_count_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_count_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_point = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_point:SetPosition('TOPLEFT', self.auras_mythicplus_count_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_mythicplus_count_point:SetSize(120, 20);
    self.auras_mythicplus_count_point:SetList(O.Lists.frame_points_localized);
    self.auras_mythicplus_count_point:SetValue(O.db.auras_mythicplus_count_point);
    self.auras_mythicplus_count_point:SetLabel(L['POSITION']);
    self.auras_mythicplus_count_point:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_POINT_TOOLTIP']);
    self.auras_mythicplus_count_point:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_POINT_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_count_point.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_relative_point:SetPosition('LEFT', self.auras_mythicplus_count_point, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_relative_point:SetSize(120, 20);
    self.auras_mythicplus_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_mythicplus_count_relative_point:SetValue(O.db.auras_mythicplus_count_relative_point);
    self.auras_mythicplus_count_relative_point:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_mythicplus_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_offset_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_offset_x:SetPosition('LEFT', self.auras_mythicplus_count_relative_point, 'RIGHT', 8, 0);
    self.auras_mythicplus_count_offset_x:SetSize(120, 18);
    self.auras_mythicplus_count_offset_x:SetValues(O.db.auras_mythicplus_count_offset_x, -50, 50, 1);
    self.auras_mythicplus_count_offset_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_mythicplus_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_mythicplus_count_offset_y = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_offset_y:SetPosition('LEFT', self.auras_mythicplus_count_offset_x, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_offset_y:SetSize(120, 18);
    self.auras_mythicplus_count_offset_y:SetValues(O.db.auras_mythicplus_count_offset_y, -50, 50, 1);
    self.auras_mythicplus_count_offset_y:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_mythicplus_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Important Tab -------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_important_enabled = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_enabled:SetPosition('TOPLEFT', self.TabsFrames['ImportantTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_important_enabled:SetLabel(L['OPTIONS_AURAS_IMPORTANT_ENABLED']);
    self.auras_important_enabled:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_ENABLED_TOOLTIP']);
    self.auras_important_enabled:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.auras_important_enabled:SetChecked(O.db.auras_important_enabled);
    self.auras_important_enabled.Callback = function(self)
        O.db.auras_important_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_border_color = E.CreateColorPicker(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_border_color:SetPosition('LEFT', self.auras_important_enabled.Label, 'RIGHT', 12, 0);
    self.auras_important_border_color:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_BORDER_COLOR_TOOLTIP']);
    self.auras_important_border_color:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_BORDER_COLOR_TOOLTIP'], self.Tabs[4]);
    self.auras_important_border_color:SetValue(unpack(O.db.auras_important_border_color));
    self.auras_important_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_important_border_color[1] = r;
        O.db.auras_important_border_color[2] = g;
        O.db.auras_important_border_color[3] = b;
        O.db.auras_important_border_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_important_glow_enabled = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_glow_enabled:SetPosition('LEFT', self.auras_important_border_color, 'RIGHT', 12, 0);
    self.auras_important_glow_enabled:SetLabel(L['OPTIONS_AURAS_IMPORTANT_GLOW_ENABLED']);
    self.auras_important_glow_enabled:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_GLOW_ENABLED_TOOLTIP']);
    self.auras_important_glow_enabled:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_GLOW_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.auras_important_glow_enabled:SetChecked(O.db.auras_important_glow_enabled);
    self.auras_important_glow_enabled.Callback = function(self)
        O.db.auras_important_glow_enabled = self:GetChecked();

        panel.auras_important_glow_type:SetEnabled(O.db.auras_important_glow_enabled);
        panel.auras_important_glow_color:SetEnabled(O.db.auras_important_glow_enabled);

        Stripes:UpdateAll();
    end

    self.auras_important_glow_type = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_glow_type:SetPosition('LEFT', self.auras_important_glow_enabled.Label, 'RIGHT', 12, 0);
    self.auras_important_glow_type:SetSize(220, 20);
    self.auras_important_glow_type:SetList(O.Lists.glow_type);
    self.auras_important_glow_type:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_GLOW_TYPE_TOOLTIP']);
    self.auras_important_glow_type:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_GLOW_TYPE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_glow_type:SetValue(O.db.auras_important_glow_type);
    self.auras_important_glow_type:SetEnabled(O.db.auras_important_glow_enabled);
    self.auras_important_glow_type.OnValueChangedCallback = function(_, value)
        O.db.auras_important_glow_type = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_glow_color = E.CreateColorPicker(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_glow_color:SetPosition('LEFT', self.auras_important_glow_type, 'RIGHT', 12, 0);
    self.auras_important_glow_color:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_GLOW_COLOR_TOOLTIP']);
    self.auras_important_glow_color:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_GLOW_COLOR_TOOLTIP'], self.Tabs[4]);
    self.auras_important_glow_color:SetValue(unpack(O.db.auras_important_glow_color));
    self.auras_important_glow_color:SetEnabled(O.db.auras_important_glow_enabled);
    self.auras_important_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_important_glow_color[1] = r;
        O.db.auras_important_glow_color[2] = g;
        O.db.auras_important_glow_color[3] = b;
        O.db.auras_important_glow_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ImportantTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_important_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_important_max_display = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_max_display:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_important_max_display:SetW(104);
    self.auras_important_max_display:SetValues(O.db.auras_important_max_display, 1, 32, 1);
    self.auras_important_max_display:SetLabel(L['MAX_SHORT']);
    self.auras_important_max_display:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_MAX_DISPLAY_TOOLTIP']);
    self.auras_important_max_display:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_MAX_DISPLAY_TOOLTIP'], self.Tabs[4]);
    self.auras_important_max_display.OnValueChangedCallback = function(_, value)
        O.db.auras_important_max_display = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_spacing_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_spacing_x:SetPosition('LEFT', self.auras_important_max_display, 'RIGHT', 16, 0);
    self.auras_important_spacing_x:SetW(104);
    self.auras_important_spacing_x:SetValues(O.db.auras_important_spacing_x, 0, 20, 1);
    self.auras_important_spacing_x:SetLabel(L['SPACING']);
    self.auras_important_spacing_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_SPACING_X_TOOLTIP']);
    self.auras_important_spacing_x:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_SPACING_X_TOOLTIP'], self.Tabs[4]);
    self.auras_important_spacing_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_spacing_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_scale = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_scale:SetPosition('LEFT', self.auras_important_spacing_x, 'RIGHT', 16, 0);
    self.auras_important_scale:SetW(104);
    self.auras_important_scale:SetValues(O.db.auras_important_scale, 0.25, 4, 0.05);
    self.auras_important_scale:SetLabel(L['SCALE']);
    self.auras_important_scale:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP']);
    self.auras_important_scale:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_important_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_offset_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_offset_x:SetPosition('LEFT', self.auras_important_scale, 'RIGHT', 16, 0);
    self.auras_important_offset_x:SetW(104);
    self.auras_important_offset_x:SetValues(O.db.auras_important_offset_x, -200, 200, 1);
    self.auras_important_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.auras_important_offset_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_OFFSET_X_TOOLTIP']);
    self.auras_important_offset_x:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_OFFSET_X_TOOLTIP'], self.Tabs[4]);
    self.auras_important_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_offset_y = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_offset_y:SetPosition('LEFT', self.auras_important_offset_x, 'RIGHT', 16, 0);
    self.auras_important_offset_y:SetW(104);
    self.auras_important_offset_y:SetValues(O.db.auras_important_offset_y, -200, 200, 1);
    self.auras_important_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.auras_important_offset_y:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_OFFSET_Y_TOOLTIP']);
    self.auras_important_offset_y:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_OFFSET_Y_TOOLTIP'], self.Tabs[4]);
    self.auras_important_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_important_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ImportantTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_important_max_display, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_important_countdown_enabled = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_important_countdown_enabled:SetLabel(L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED']);
    self.auras_important_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_important_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.auras_important_countdown_enabled:SetChecked(O.db.auras_important_countdown_enabled);
    self.auras_important_countdown_enabled.Callback = function(self)
        O.db.auras_important_countdown_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_draw_swipe = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_draw_swipe:SetPosition('LEFT', self.auras_important_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_important_draw_swipe:SetLabel(L['OPTIONS_AURAS_IMPORTANT_DRAW_SWIPE']);
    self.auras_important_draw_swipe:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_DRAW_SWIPE_TOOLTIP']);
    self.auras_important_draw_swipe:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_DRAW_SWIPE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_draw_swipe:SetChecked(O.db.auras_important_draw_swipe);
    self.auras_important_draw_swipe.Callback = function(self)
        O.db.auras_important_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_draw_edge = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_draw_edge:SetPosition('LEFT', self.auras_important_draw_swipe.Label, 'RIGHT', 12, 0);
    self.auras_important_draw_edge:SetLabel(L['OPTIONS_AURAS_IMPORTANT_DRAW_EDGE']);
    self.auras_important_draw_edge:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_DRAW_EDGE_TOOLTIP']);
    self.auras_important_draw_edge:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_DRAW_EDGE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_draw_edge:SetChecked(O.db.auras_important_draw_edge);
    self.auras_important_draw_edge.Callback = function(self)
        O.db.auras_important_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_countdown_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_countdown_text:SetPosition('TOPLEFT', self.auras_important_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_important_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_important_cooldown_color = E.CreateColorPicker(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_color:SetPosition('LEFT', self.auras_important_countdown_text, 'RIGHT', 12, 0);
    self.auras_important_cooldown_color:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_COLOR_TOOLTIP']);
    self.auras_important_cooldown_color:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_COLOR_TOOLTIP'], self.Tabs[4]);
    self.auras_important_cooldown_color:SetValue(unpack(O.db.auras_important_cooldown_color));
    self.auras_important_cooldown_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_important_cooldown_color[1] = r;
        O.db.auras_important_cooldown_color[2] = g;
        O.db.auras_important_cooldown_color[3] = b;
        O.db.auras_important_cooldown_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_value:SetPosition('TOPLEFT', self.auras_important_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_important_cooldown_font_value:SetSize(160, 20);
    self.auras_important_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_important_cooldown_font_value:SetValue(O.db.auras_important_cooldown_font_value);
    self.auras_important_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_VALUE']);
    self.auras_important_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_VALUE'], self.Tabs[4]);
    self.auras_important_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_size:SetPosition('LEFT', self.auras_important_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_important_cooldown_font_size:SetValues(O.db.auras_important_cooldown_font_size, 3, 28, 1);
    self.auras_important_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SIZE']);
    self.auras_important_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_font_flag = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_flag:SetPosition('LEFT', self.auras_important_cooldown_font_size, 'RIGHT', 12, 0);
    self.auras_important_cooldown_font_flag:SetSize(160, 20);
    self.auras_important_cooldown_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_important_cooldown_font_flag:SetValue(O.db.auras_important_cooldown_font_flag);
    self.auras_important_cooldown_font_flag:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_FLAG']);
    self.auras_important_cooldown_font_flag:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_FLAG'], self.Tabs[4]);
    self.auras_important_cooldown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_shadow:SetPosition('LEFT', self.auras_important_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_important_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_cooldown_font_shadow:SetChecked(O.db.auras_important_cooldown_font_shadow);
    self.auras_important_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW']);
    self.auras_important_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_cooldown_font_shadow.Callback = function(self)
        O.db.auras_important_cooldown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_point = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_point:SetPosition('TOPLEFT', self.auras_important_cooldown_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_important_cooldown_point:SetSize(120, 20);
    self.auras_important_cooldown_point:SetList(O.Lists.frame_points_localized);
    self.auras_important_cooldown_point:SetValue(O.db.auras_important_cooldown_point);
    self.auras_important_cooldown_point:SetLabel(L['POSITION']);
    self.auras_important_cooldown_point:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_POINT_TOOLTIP']);
    self.auras_important_cooldown_point:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_POINT_TOOLTIP'], self.Tabs[4]);
    self.auras_important_cooldown_point.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_relative_point = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_relative_point:SetPosition('LEFT', self.auras_important_cooldown_point, 'RIGHT', 12, 0);
    self.auras_important_cooldown_relative_point:SetSize(120, 20);
    self.auras_important_cooldown_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_important_cooldown_relative_point:SetValue(O.db.auras_important_cooldown_relative_point);
    self.auras_important_cooldown_relative_point:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_RELATIVE_POINT_TOOLTIP']);
    self.auras_important_cooldown_relative_point:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_RELATIVE_POINT_TOOLTIP'], self.Tabs[4]);
    self.auras_important_cooldown_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_offset_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_offset_x:SetPosition('LEFT', self.auras_important_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_important_cooldown_offset_x:SetSize(120, 18);
    self.auras_important_cooldown_offset_x:SetValues(O.db.auras_important_cooldown_offset_x, -50, 50, 1);
    self.auras_important_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_important_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_cooldown_offset_y = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_offset_y:SetPosition('LEFT', self.auras_important_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_important_cooldown_offset_y:SetSize(120, 18);
    self.auras_important_cooldown_offset_y:SetValues(O.db.auras_important_cooldown_offset_y, -50, 50, 1);
    self.auras_important_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_important_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ImportantTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_important_cooldown_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_important_count_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -2);
    self.auras_important_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_important_count_color = E.CreateColorPicker(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_color:SetPosition('LEFT', self.auras_important_count_text, 'RIGHT', 12, 0);
    self.auras_important_count_color:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_COLOR_TOOLTIP']);
    self.auras_important_count_color:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_COLOR_TOOLTIP'], self.Tabs[4]);
    self.auras_important_count_color:SetValue(unpack(O.db.auras_important_count_color));
    self.auras_important_count_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_important_count_color[1] = r;
        O.db.auras_important_count_color[2] = g;
        O.db.auras_important_count_color[3] = b;
        O.db.auras_important_count_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_important_count_font_value = E.CreateDropdown('font', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_value:SetPosition('TOPLEFT', self.auras_important_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_important_count_font_value:SetSize(160, 20);
    self.auras_important_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_important_count_font_value:SetValue(O.db.auras_important_count_font_value);
    self.auras_important_count_font_value:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_VALUE']);
    self.auras_important_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_VALUE'], self.Tabs[4]);
    self.auras_important_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_important_count_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_size:SetPosition('LEFT', self.auras_important_count_font_value, 'RIGHT', 12, 0);
    self.auras_important_count_font_size:SetValues(O.db.auras_important_count_font_size, 3, 28, 1);
    self.auras_important_count_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SIZE']);
    self.auras_important_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_count_font_flag = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_flag:SetPosition('LEFT', self.auras_important_count_font_size, 'RIGHT', 12, 0);
    self.auras_important_count_font_flag:SetSize(160, 20);
    self.auras_important_count_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_important_count_font_flag:SetValue(O.db.auras_important_count_font_flag);
    self.auras_important_count_font_flag:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_FLAG']);
    self.auras_important_count_font_flag:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_FLAG'], self.Tabs[4]);
    self.auras_important_count_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_count_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_shadow:SetPosition('LEFT', self.auras_important_count_font_flag, 'RIGHT', 12, 0);
    self.auras_important_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_count_font_shadow:SetChecked(O.db.auras_important_count_font_shadow);
    self.auras_important_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW']);
    self.auras_important_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_count_font_shadow.Callback = function(self)
        O.db.auras_important_count_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_count_point = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_point:SetPosition('TOPLEFT', self.auras_important_count_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_important_count_point:SetSize(120, 20);
    self.auras_important_count_point:SetList(O.Lists.frame_points_localized);
    self.auras_important_count_point:SetValue(O.db.auras_important_count_point);
    self.auras_important_count_point:SetLabel(L['POSITION']);
    self.auras_important_count_point:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_POINT_TOOLTIP']);
    self.auras_important_count_point:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_POINT_TOOLTIP'], self.Tabs[4]);
    self.auras_important_count_point.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_relative_point:SetPosition('LEFT', self.auras_important_count_point, 'RIGHT', 12, 0);
    self.auras_important_count_relative_point:SetSize(120, 20);
    self.auras_important_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_important_count_relative_point:SetValue(O.db.auras_important_count_relative_point);
    self.auras_important_count_relative_point:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_important_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[4]);
    self.auras_important_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_count_offset_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_offset_x:SetPosition('LEFT', self.auras_important_count_relative_point, 'RIGHT', 8, 0);
    self.auras_important_count_offset_x:SetSize(120, 18);
    self.auras_important_count_offset_x:SetValues(O.db.auras_important_count_offset_x, -50, 50, 1);
    self.auras_important_count_offset_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_important_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_count_offset_y = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_offset_y:SetPosition('LEFT', self.auras_important_count_offset_x, 'RIGHT', 12, 0);
    self.auras_important_count_offset_y:SetSize(120, 18);
    self.auras_important_count_offset_y:SetValues(O.db.auras_important_count_offset_y, -50, 50, 1);
    self.auras_important_count_offset_y:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_important_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ImportantTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_important_count_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_important_castername_show = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_show:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_important_castername_show:SetLabel(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_SHOW']);
    self.auras_important_castername_show:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_SHOW_TOOLTIP']);
    self.auras_important_castername_show:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_SHOW_TOOLTIP'], self.Tabs[4]);
    self.auras_important_castername_show:SetChecked(O.db.auras_important_castername_show);
    self.auras_important_castername_show.Callback = function(self)
        O.db.auras_important_castername_show = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_important_castername_font_value = E.CreateDropdown('font', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_value:SetPosition('TOPLEFT', self.auras_important_castername_show, 'BOTTOMLEFT', 0, -8);
    self.auras_important_castername_font_value:SetSize(160, 20);
    self.auras_important_castername_font_value:SetList(LSM:HashTable('font'));
    self.auras_important_castername_font_value:SetValue(O.db.auras_important_castername_font_value);
    self.auras_important_castername_font_value:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_VALUE']);
    self.auras_important_castername_font_value:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_VALUE'], self.Tabs[4]);
    self.auras_important_castername_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_important_castername_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_important_castername_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_size:SetPosition('LEFT', self.auras_important_castername_font_value, 'RIGHT', 12, 0);
    self.auras_important_castername_font_size:SetValues(O.db.auras_important_castername_font_size, 3, 28, 1);
    self.auras_important_castername_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SIZE']);
    self.auras_important_castername_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_castername_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_castername_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_castername_font_flag = E.CreateDropdown('plain', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_flag:SetPosition('LEFT', self.auras_important_castername_font_size, 'RIGHT', 12, 0);
    self.auras_important_castername_font_flag:SetSize(160, 20);
    self.auras_important_castername_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_important_castername_font_flag:SetValue(O.db.auras_important_castername_font_flag);
    self.auras_important_castername_font_flag:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_FLAG']);
    self.auras_important_castername_font_flag:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_FLAG'], self.Tabs[4]);
    self.auras_important_castername_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_important_castername_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_important_castername_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_shadow:SetPosition('LEFT', self.auras_important_castername_font_flag, 'RIGHT', 12, 0);
    self.auras_important_castername_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_castername_font_shadow:SetChecked(O.db.auras_important_castername_font_shadow);
    self.auras_important_castername_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW']);
    self.auras_important_castername_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_castername_font_shadow.Callback = function(self)
        O.db.auras_important_castername_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Custom Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_custom_enabled = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_enabled:SetPosition('TOPLEFT', self.TabsFrames['CustomTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_custom_enabled:SetLabel(L['OPTIONS_AURAS_CUSTOM_ENABLED']);
    self.auras_custom_enabled:SetTooltip(L['OPTIONS_AURAS_CUSTOM_ENABLED_TOOLTIP']);
    self.auras_custom_enabled:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_ENABLED_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_enabled:SetChecked(O.db.auras_custom_enabled);
    self.auras_custom_enabled.Callback = function(self)
        O.db.auras_custom_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_border_color = E.CreateColorPicker(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_border_color:SetPosition('LEFT', self.auras_custom_enabled.Label, 'RIGHT', 12, 0);
    self.auras_custom_border_color:SetTooltip(L['OPTIONS_AURAS_CUSTOM_BORDER_COLOR_TOOLTIP']);
    self.auras_custom_border_color:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_BORDER_COLOR_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_border_color:SetValue(unpack(O.db.auras_custom_border_color));
    self.auras_custom_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_custom_border_color[1] = r;
        O.db.auras_custom_border_color[2] = g;
        O.db.auras_custom_border_color[3] = b;
        O.db.auras_custom_border_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_custom_direction = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_direction:SetPosition('TOPLEFT', self.auras_custom_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_custom_direction:SetSize(180, 20);
    self.auras_custom_direction:SetList(O.Lists.auras_horizontal_direction);
    self.auras_custom_direction:SetLabel(L['OPTIONS_AURAS_CUSTOM_DIRECTION']);
    self.auras_custom_direction:SetTooltip(L['OPTIONS_AURAS_CUSTOM_DIRECTION_TOOLTIP']);
    self.auras_custom_direction:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_DIRECTION_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_direction:SetValue(O.db.auras_custom_direction);
    self.auras_custom_direction.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_direction = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CustomTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_custom_direction, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_custom_max_display = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_max_display:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_custom_max_display:SetW(104);
    self.auras_custom_max_display:SetValues(O.db.auras_custom_max_display, 1, 32, 1);
    self.auras_custom_max_display:SetLabel(L['MAX_SHORT']);
    self.auras_custom_max_display:SetTooltip(L['OPTIONS_AURAS_CUSTOM_MAX_DISPLAY_TOOLTIP']);
    self.auras_custom_max_display:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_MAX_DISPLAY_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_max_display.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_max_display = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_spacing_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_spacing_x:SetPosition('LEFT', self.auras_custom_max_display, 'RIGHT', 16, 0);
    self.auras_custom_spacing_x:SetW(104);
    self.auras_custom_spacing_x:SetValues(O.db.auras_custom_spacing_x, 0, 20, 1);
    self.auras_custom_spacing_x:SetLabel(L['SPACING']);
    self.auras_custom_spacing_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_SPACING_X_TOOLTIP']);
    self.auras_custom_spacing_x:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_SPACING_X_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_spacing_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_spacing_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_scale = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_scale:SetPosition('LEFT', self.auras_custom_spacing_x, 'RIGHT', 16, 0);
    self.auras_custom_scale:SetW(104);
    self.auras_custom_scale:SetValues(O.db.auras_custom_scale, 0.25, 4, 0.05);
    self.auras_custom_scale:SetLabel(L['SCALE']);
    self.auras_custom_scale:SetTooltip(L['OPTIONS_AURAS_CUSTOM_SCALE_TOOLTIP']);
    self.auras_custom_scale:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_SCALE_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_offset_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_offset_x:SetPosition('LEFT', self.auras_custom_scale, 'RIGHT', 16, 0);
    self.auras_custom_offset_x:SetW(104);
    self.auras_custom_offset_x:SetValues(O.db.auras_custom_offset_x, -200, 200, 1);
    self.auras_custom_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.auras_custom_offset_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_OFFSET_X_TOOLTIP']);
    self.auras_custom_offset_x:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_OFFSET_X_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_offset_y:SetPosition('LEFT', self.auras_custom_offset_x, 'RIGHT', 16, 0);
    self.auras_custom_offset_y:SetW(104);
    self.auras_custom_offset_y:SetValues(O.db.auras_custom_offset_y, -200, 200, 1);
    self.auras_custom_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.auras_custom_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_OFFSET_Y_TOOLTIP']);
    self.auras_custom_offset_y:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_OFFSET_Y_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CustomTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_custom_max_display, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_custom_countdown_enabled = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_custom_countdown_enabled:SetLabel(L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED']);
    self.auras_custom_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_custom_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_countdown_enabled:SetChecked(O.db.auras_custom_countdown_enabled);
    self.auras_custom_countdown_enabled.Callback = function(self)
        O.db.auras_custom_countdown_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_draw_swipe = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_draw_swipe:SetPosition('LEFT', self.auras_custom_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_custom_draw_swipe:SetLabel(L['OPTIONS_AURAS_CUSTOM_DRAW_SWIPE']);
    self.auras_custom_draw_swipe:SetTooltip(L['OPTIONS_AURAS_CUSTOM_DRAW_SWIPE_TOOLTIP']);
    self.auras_custom_draw_swipe:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_DRAW_SWIPE_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_draw_swipe:SetChecked(O.db.auras_custom_draw_swipe);
    self.auras_custom_draw_swipe.Callback = function(self)
        O.db.auras_custom_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_draw_edge = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_draw_edge:SetPosition('LEFT', self.auras_custom_draw_swipe.Label, 'RIGHT', 12, 0);
    self.auras_custom_draw_edge:SetLabel(L['OPTIONS_AURAS_CUSTOM_DRAW_EDGE']);
    self.auras_custom_draw_edge:SetTooltip(L['OPTIONS_AURAS_CUSTOM_DRAW_EDGE_TOOLTIP']);
    self.auras_custom_draw_edge:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_DRAW_EDGE_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_draw_edge:SetChecked(O.db.auras_custom_draw_edge);
    self.auras_custom_draw_edge.Callback = function(self)
        O.db.auras_custom_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_countdown_text = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_countdown_text:SetPosition('TOPLEFT', self.auras_custom_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_custom_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_custom_cooldown_color = E.CreateColorPicker(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_color:SetPosition('LEFT', self.auras_custom_countdown_text, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_color:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_COLOR_TOOLTIP']);
    self.auras_custom_cooldown_color:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_COLOR_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_cooldown_color:SetValue(unpack(O.db.auras_custom_cooldown_color));
    self.auras_custom_cooldown_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_custom_cooldown_color[1] = r;
        O.db.auras_custom_cooldown_color[2] = g;
        O.db.auras_custom_cooldown_color[3] = b;
        O.db.auras_custom_cooldown_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_value:SetPosition('TOPLEFT', self.auras_custom_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_custom_cooldown_font_value:SetSize(160, 20);
    self.auras_custom_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_custom_cooldown_font_value:SetValue(O.db.auras_custom_cooldown_font_value);
    self.auras_custom_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_VALUE']);
    self.auras_custom_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_VALUE'], self.Tabs[5]);
    self.auras_custom_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_font_size = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_size:SetPosition('LEFT', self.auras_custom_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_font_size:SetValues(O.db.auras_custom_cooldown_font_size, 3, 28, 1);
    self.auras_custom_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SIZE']);
    self.auras_custom_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SIZE'], self.Tabs[5]);
    self.auras_custom_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_font_flag = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_flag:SetPosition('LEFT', self.auras_custom_cooldown_font_size, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_font_flag:SetSize(160, 20);
    self.auras_custom_cooldown_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_custom_cooldown_font_flag:SetValue(O.db.auras_custom_cooldown_font_flag);
    self.auras_custom_cooldown_font_flag:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_FLAG']);
    self.auras_custom_cooldown_font_flag:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_FLAG'], self.Tabs[5]);
    self.auras_custom_cooldown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_shadow:SetPosition('LEFT', self.auras_custom_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_custom_cooldown_font_shadow:SetChecked(O.db.auras_custom_cooldown_font_shadow);
    self.auras_custom_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SHADOW']);
    self.auras_custom_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SHADOW'], self.Tabs[5]);
    self.auras_custom_cooldown_font_shadow.Callback = function(self)
        O.db.auras_custom_cooldown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_point = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_point:SetPosition('TOPLEFT', self.auras_custom_cooldown_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_custom_cooldown_point:SetSize(120, 20);
    self.auras_custom_cooldown_point:SetList(O.Lists.frame_points_localized);
    self.auras_custom_cooldown_point:SetValue(O.db.auras_custom_cooldown_point);
    self.auras_custom_cooldown_point:SetLabel(L['POSITION']);
    self.auras_custom_cooldown_point:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_POINT_TOOLTIP']);
    self.auras_custom_cooldown_point:AddToSearch(button, L['OPTIONS_CUSTOM_AURAS_COOLDOWN_POINT_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_cooldown_point.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_relative_point = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_relative_point:SetPosition('LEFT', self.auras_custom_cooldown_point, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_relative_point:SetSize(120, 20);
    self.auras_custom_cooldown_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_custom_cooldown_relative_point:SetValue(O.db.auras_custom_cooldown_relative_point);
    self.auras_custom_cooldown_relative_point:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_RELATIVE_POINT_TOOLTIP']);
    self.auras_custom_cooldown_relative_point:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_RELATIVE_POINT_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_cooldown_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_offset_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_offset_x:SetPosition('LEFT', self.auras_custom_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_custom_cooldown_offset_x:SetSize(120, 18);
    self.auras_custom_cooldown_offset_x:SetValues(O.db.auras_custom_cooldown_offset_x, -50, 50, 1);
    self.auras_custom_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_custom_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_cooldown_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_offset_y:SetPosition('LEFT', self.auras_custom_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_offset_y:SetSize(120, 18);
    self.auras_custom_cooldown_offset_y:SetValues(O.db.auras_custom_cooldown_offset_y, -50, 50, 1);
    self.auras_custom_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_custom_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CustomTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_custom_cooldown_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_custom_count_text = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -2);
    self.auras_custom_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_custom_count_color = E.CreateColorPicker(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_color:SetPosition('LEFT', self.auras_custom_count_text, 'RIGHT', 12, 0);
    self.auras_custom_count_color:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_COLOR_TOOLTIP']);
    self.auras_custom_count_color:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_COLOR_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_count_color:SetValue(unpack(O.db.auras_custom_count_color));
    self.auras_custom_count_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_custom_count_color[1] = r;
        O.db.auras_custom_count_color[2] = g;
        O.db.auras_custom_count_color[3] = b;
        O.db.auras_custom_count_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.auras_custom_count_font_value = E.CreateDropdown('font', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_value:SetPosition('TOPLEFT', self.auras_custom_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_custom_count_font_value:SetSize(160, 20);
    self.auras_custom_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_custom_count_font_value:SetValue(O.db.auras_custom_count_font_value);
    self.auras_custom_count_font_value:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_VALUE']);
    self.auras_custom_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_VALUE'], self.Tabs[5]);
    self.auras_custom_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_font_value = value;
        Stripes:UpdateAll();
    end

    self.auras_custom_count_font_size = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_size:SetPosition('LEFT', self.auras_custom_count_font_value, 'RIGHT', 12, 0);
    self.auras_custom_count_font_size:SetValues(O.db.auras_custom_count_font_size, 3, 28, 1);
    self.auras_custom_count_font_size:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SIZE']);
    self.auras_custom_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SIZE'], self.Tabs[5]);
    self.auras_custom_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_count_font_flag = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_flag:SetPosition('LEFT', self.auras_custom_count_font_size, 'RIGHT', 12, 0);
    self.auras_custom_count_font_flag:SetSize(160, 20);
    self.auras_custom_count_font_flag:SetList(O.Lists.font_flags_localized);
    self.auras_custom_count_font_flag:SetValue(O.db.auras_custom_count_font_flag);
    self.auras_custom_count_font_flag:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_FLAG']);
    self.auras_custom_count_font_flag:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_FLAG'], self.Tabs[5]);
    self.auras_custom_count_font_flag.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_count_font_shadow = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_shadow:SetPosition('LEFT', self.auras_custom_count_font_flag, 'RIGHT', 12, 0);
    self.auras_custom_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_custom_count_font_shadow:SetChecked(O.db.auras_custom_count_font_shadow);
    self.auras_custom_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SHADOW']);
    self.auras_custom_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SHADOW'], self.Tabs[5]);
    self.auras_custom_count_font_shadow.Callback = function(self)
        O.db.auras_custom_count_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.auras_custom_count_point = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_point:SetPosition('TOPLEFT', self.auras_custom_count_font_value, 'BOTTOMLEFT', 0, -12);
    self.auras_custom_count_point:SetSize(120, 20);
    self.auras_custom_count_point:SetList(O.Lists.frame_points_localized);
    self.auras_custom_count_point:SetValue(O.db.auras_custom_count_point);
    self.auras_custom_count_point:SetLabel(L['POSITION']);
    self.auras_custom_count_point:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_POINT_TOOLTIP']);
    self.auras_custom_count_point:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_POINT_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_count_point.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_relative_point:SetPosition('LEFT', self.auras_custom_count_point, 'RIGHT', 12, 0);
    self.auras_custom_count_relative_point:SetSize(120, 20);
    self.auras_custom_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_custom_count_relative_point:SetValue(O.db.auras_custom_count_relative_point);
    self.auras_custom_count_relative_point:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_custom_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_count_offset_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_offset_x:SetPosition('LEFT', self.auras_custom_count_relative_point, 'RIGHT', 8, 0);
    self.auras_custom_count_offset_x:SetSize(120, 18);
    self.auras_custom_count_offset_x:SetValues(O.db.auras_custom_count_offset_x, -50, 50, 1);
    self.auras_custom_count_offset_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_custom_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.auras_custom_count_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_offset_y:SetPosition('LEFT', self.auras_custom_count_offset_x, 'RIGHT', 12, 0);
    self.auras_custom_count_offset_y:SetSize(120, 18);
    self.auras_custom_count_offset_y:SetValues(O.db.auras_custom_count_offset_y, -50, 50, 1);
    self.auras_custom_count_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_custom_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CustomTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_custom_count_point, 'BOTTOMLEFT', 0, -8);
    Delimiter:SetW(self:GetWidth());

    self.auras_custom_editbox = E.CreateEditBox(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_editbox:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 5, -12);
    self.auras_custom_editbox:SetSize(200, 22);
    self.auras_custom_editbox.useLastValue = false;
    self.auras_custom_editbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.auras_custom_editbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        local byName = false;
        local byNameIcon;

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            byNameIcon = GetIconFromSpellCache(text);

            if byNameIcon then
                byName = true;
            end
        end

        if not saveId and not byName then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddCustomAura(tonumber(saveId), byName, text);

        panel:UpdateScroll();
        panel:UpdateBlackListScroll();

        self:SetText('');

        Stripes:UpdateAll();
    end);

    self.auras_custom_helpful = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_helpful:SetPosition('LEFT', self.auras_custom_editbox, 'RIGHT', 16, 0);
    self.auras_custom_helpful:SetLabel(L['OPTIONS_AURAS_CUSTOM_HELPFUL']);
    self.auras_custom_helpful:SetChecked(O.db.auras_custom_helpful);
    self.auras_custom_helpful:SetTooltip(L['OPTIONS_AURAS_CUSTOM_HELPFUL_TOOLTIP']);
    self.auras_custom_helpful:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_HELPFUL_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_helpful.Callback = function(self)
        O.db.auras_custom_helpful = self:GetChecked();
    end

    self.auras_custom_to_blacklist = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_to_blacklist:SetPosition('LEFT', self.auras_custom_helpful.Label, 'RIGHT', 16, 0);
    self.auras_custom_to_blacklist:SetLabel(L['OPTIONS_AURAS_CUSTOM_TO_BLACKLIST']);
    self.auras_custom_to_blacklist:SetChecked(O.db.auras_custom_to_blacklist);
    self.auras_custom_to_blacklist:SetTooltip(L['OPTIONS_AURAS_CUSTOM_TO_BLACKLIST_TOOLTIP']);
    self.auras_custom_to_blacklist:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_TO_BLACKLIST_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_to_blacklist.Callback = function(self)
        O.db.auras_custom_to_blacklist = self:GetChecked();
    end

    self.AurasCustomHelpTipButton = E.CreateHelpTipButton(self.TabsFrames['CustomTab'].Content);
    self.AurasCustomHelpTipButton:SetPosition('LEFT', self.auras_custom_to_blacklist.Label, 'RIGHT', 30, 0);
    self.AurasCustomHelpTipButton:SetTooltip(L['OPTIONS_AURAS_CUSTOM_HELPTIP']);

    self.auras_custom_editframe = CreateFrame('Frame', nil, self.TabsFrames['CustomTab'].Content, 'BackdropTemplate');
    self.auras_custom_editframe:SetPoint('TOPLEFT', self.auras_custom_editbox, 'BOTTOMLEFT', -5, -8);
    self.auras_custom_editframe:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0);
    self.auras_custom_editframe:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.auras_custom_editframe:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.auras_custom_scrollchild, self.auras_custom_scrollarea = E.CreateScrollFrame(self.auras_custom_editframe, ROW_HEIGHT);
    PixelUtil.SetPoint(self.auras_custom_scrollarea.ScrollBar, 'TOPLEFT', self.auras_custom_scrollarea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.auras_custom_scrollarea.ScrollBar, 'BOTTOMLEFT', self.auras_custom_scrollarea, 'BOTTOMRIGHT', -8, 0);

    aurasCustomFramePool = CreateFramePool('Frame', self.auras_custom_scrollchild, 'BackdropTemplate');

    self:UpdateScroll();

    self.ProfilesDropdown = E.CreateDropdown('plain', self.TabsFrames['CustomTab'].Content);
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.auras_custom_editframe, 'TOPRIGHT', 0, 8);
    self.ProfilesDropdown:SetSize(157, 22);
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);
        if not index then
            self:SetValue(nil);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].auras_custom_data);
            StripesDB.profiles[O.activeProfileId].auras_custom_data = U.DeepCopy(StripesDB.profiles[index].auras_custom_data);
        else
            StripesDB.profiles[O.activeProfileId].auras_custom_data = U.Merge(StripesDB.profiles[index].auras_custom_data, StripesDB.profiles[O.activeProfileId].auras_custom_data);
        end

        self:SetValue(nil);

        panel:UpdateScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');
    Profile.UpdateProfilesDropdown(self.ProfilesDropdown, true);
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    self:UpdateScroll();
    self:UpdateBlackListScroll();
    self:UpdateWhiteListScroll();
    self:UpdateHPBarColorScroll();
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end