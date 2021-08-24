local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Auras');

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

local function AddCustomAura(id)
    if O.db.auras_custom_data[id] then
        return;
    end

    O.db.auras_custom_data[id] = {
        id       = id,
        filter   = O.db.auras_custom_helpful and 'HELPFUL' or 'HARMFUL',
        enabled  = true,
        own_only = true,
    };

    if O.db.auras_custom_to_blacklist then
        if O.db.auras_blacklist[id] then
            O.db.auras_blacklist[id].enabled = true;
        else
            O.db.auras_blacklist[id] = {
                id      = id,
                enabled = true,
            };
        end
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
        if O.db.auras_custom_data[tonumber(self:GetParent().id)] then
            O.db.auras_custom_data[tonumber(self:GetParent().id)] = nil;

            panel:UpdateScroll();
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
        if self.id then
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

    local name, _, icon = GetSpellInfo(frame.id);

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(icon);
    frame.IdText:SetText(frame.id);
    frame.NameText:SetText(name);

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

panel.UpdateScroll = function()
    wipe(DataCustomAuraRows);
    aurasCustomFramePool:ReleaseAll();

    local index = 0;
    local frame, isNew;

    for id, data in pairs(O.db.auras_custom_data) do
        index = index + 1;

        frame, isNew = aurasCustomFramePool:Acquire();

        table.insert(DataCustomAuraRows, frame);

        if isNew then
            CreateCustomAuraRow(frame);
        end

        frame.index         = index;
        frame.id            = id;
        frame.filter        = data.filter;
        frame.enabled       = data.enabled;
        frame.own_only      = data.own_only;
        frame.isBlacklisted = O.db.auras_blacklist[id] and true or false;

        UpdateCustomAuraRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.auras_custom_scrollchild, panel.auras_custom_editframe:GetWidth(), panel.auras_custom_editframe:GetHeight() - (panel.auras_custom_editframe:GetHeight() % ROW_HEIGHT));
end

local profilesList = {};

panel.UpdateProfilesDropdown = function(self)
    wipe(profilesList);

    for _, data in pairs(StripesDB.profiles) do
        if data.profileName ~= O.activeProfileName then
            table.insert(profilesList, data.profileName);
        end
    end

    table.sort(profilesList, function(a, b)
        if a == b then
            return true;
        end

        if a == L['OPTIONS_PROFILE_DEFAULT_NAME'] then
            return true;
        end

        if b == L['OPTIONS_PROFILE_DEFAULT_NAME'] then
            return false;
        end

        return a < b;
    end);

    if self.ProfilesDropdown then
        self.ProfilesDropdown:SetEnabled(#profilesList > 1);
        self.ProfilesDropdown:SetList(profilesList);
        self.ProfilesDropdown:SetValue(0);
    end
end

local DataBlackListRows = {};

local function AddBlackListAura(id)
    if O.db.auras_blacklist[id] then
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
        if O.db.auras_blacklist[tonumber(self:GetParent().id)] then
            O.db.auras_blacklist[tonumber(self:GetParent().id)] = nil;

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
        if self.id then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
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

    local name, _, icon = GetSpellInfo(frame.id);

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(icon);
    frame.NameText:SetText(name);
end

panel.UpdateBlackListScroll = function()
    wipe(DataBlackListRows);
    panel.BlackListButtonPool:ReleaseAll();

    local index = 0;
    local frame, isNew;

    for id, data in pairs(O.db.auras_blacklist) do
        index = index + 1;

        frame, isNew = panel.BlackListButtonPool:Acquire();

        table.insert(DataBlackListRows, frame);

        if isNew then
            CreateBlackListRow(frame);
        end

        frame.index   = index;
        frame.id      = id;
        frame.enabled = data.enabled;

        UpdateBlackListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.BlackListScrollArea.scrollChild, panel.BlackListScroll:GetWidth(), panel.BlackListScroll:GetHeight() - (panel.BlackListScroll:GetHeight() % ROW_HEIGHT));
end

local DataHPBarColorRows = {};

local function AddHPBarColorAura(id)
    if O.db.auras_hpbar_color_data[id] then
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
        if O.db.auras_hpbar_color_data[tonumber(self:GetParent().id)] then
            O.db.auras_hpbar_color_data[tonumber(self:GetParent().id)] = nil;

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
        if self.id then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
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

    local name, _, icon = GetSpellInfo(frame.id);

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.Icon:SetTexture(icon);
    frame.NameText:SetText(name);
    frame.ColorPicker:SetValue(unpack(frame.color));
end

panel.UpdateHPBarColorScroll = function()
    wipe(DataHPBarColorRows);
    panel.HPBarColorButtonPool:ReleaseAll();

    local index = 0;
    local frame, isNew;

    for id, data in pairs(O.db.auras_hpbar_color_data) do
        index = index + 1;

        frame, isNew = panel.HPBarColorButtonPool:Acquire();

        table.insert(DataHPBarColorRows, frame);

        if isNew then
            CreateHPBarColorRow(frame);
        end

        frame.index   = index;
        frame.id      = id;
        frame.enabled = data.enabled;
        frame.color   = data.color;

        UpdateHPBarColorRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.HPBarColorListScrollArea.scrollChild, panel.HPBarColorListScroll:GetWidth(), panel.HPBarColorListScroll:GetHeight() - (panel.HPBarColorListScroll:GetHeight() % ROW_HEIGHT));
end

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.auras_filter_player_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_filter_player_enabled:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.auras_filter_player_enabled:SetLabel(L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED']);
    self.auras_filter_player_enabled:SetTooltip(L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED_TOOLTIP']);
    self.auras_filter_player_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.auras_filter_player_enabled:SetChecked(O.db.auras_filter_player_enabled);
    self.auras_filter_player_enabled.Callback = function(self)
        O.db.auras_filter_player_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_blacklist_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_blacklist_enabled:SetPosition('LEFT', self.auras_filter_player_enabled.Label, 'RIGHT', 12, 0);
    self.auras_blacklist_enabled:SetLabel(L['OPTIONS_AURAS_BLACKLIST_ENABLED']);
    self.auras_blacklist_enabled:SetTooltip(L['OPTIONS_AURAS_BLACKLIST_ENABLED_TOOLTIP']);
    self.auras_blacklist_enabled:AddToSearch(button, L['OPTIONS_AURAS_BLACKLIST_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_blacklist_enabled:SetChecked(O.db.auras_blacklist_enabled);
    self.auras_blacklist_enabled.Callback = function(self)
        O.db.auras_blacklist_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.BlackListButton = E.CreateButton(self.TabsFrames['CommonTab'].Content);
    self.BlackListButton:SetPosition('LEFT', self.auras_blacklist_enabled.Label, 'RIGHT', 16, 0);
    self.BlackListButton:SetScale(0.8);
    self.BlackListButton:SetHighlightColor('111111');
    self.BlackListButton:SetLabel(L['OPTIONS_AURAS_BLACKLIST_BUTTON_OPEN']);
    self.BlackListButton:SetScript('OnClick', function(self)
        panel.BlackList:SetShown(not panel.BlackList:IsShown());

        if panel.BlackList:IsShown() then
            self:LockHighlight();
            self:SetLabel(L['OPTIONS_AURAS_BLACKLIST_BUTTON_CLOSE']);
        else
            self:UnlockHighlight();
            self:SetLabel(L['OPTIONS_AURAS_BLACKLIST_BUTTON_OPEN']);
        end

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

    self.BlackListEditbox = E.CreateEditBox(self.BlackList);
    self.BlackListEditbox:SetPosition('TOP', self.BlackList, 'TOP', 0, -10);
    self.BlackListEditbox:SetSize(228, 20);
    self.BlackListEditbox.useLastValue = false;
    self.BlackListEditbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.BlackListEditbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            saveId = tonumber(select(7, GetSpellInfo(text)) or '');
        end

        if not saveId then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddBlackListAura(tonumber(saveId));

        panel:UpdateBlackListScroll();
        self:SetText('');

        Handler:UpdateAll();
    end);

    self.BlackListScroll = Mixin(CreateFrame('Frame', nil, self.BlackList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.BlackListScroll:SetPoint('TOPLEFT', self.BlackList , 'TOPLEFT', 6, -40);
    self.BlackListScroll:SetPoint('BOTTOMRIGHT', self.BlackList, 'BOTTOMRIGHT', -6, 6);
    self.BlackListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.BlackListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.BlackListScrollChild, self.BlackListScrollArea = E.CreateScrollFrame(self.BlackListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.BlackListScrollArea.ScrollBar, 'TOPLEFT', self.BlackListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.BlackListScrollArea.ScrollBar, 'BOTTOMLEFT', self.BlackListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.BlackListButtonPool = CreateFramePool('Button', self.BlackListScrollChild, 'BackdropTemplate');

    self:UpdateBlackListScroll();

    self.auras_square = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_square:SetPosition('TOPLEFT', self.auras_filter_player_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_square:SetLabel(L['OPTIONS_AURAS_SQUARE']);
    self.auras_square:SetTooltip(L['OPTIONS_AURAS_SQUARE_TOOLTIP']);
    self.auras_square:AddToSearch(button, L['OPTIONS_AURAS_SQUARE_TOOLTIP'], self.Tabs[1]);
    self.auras_square:SetChecked(O.db.auras_square);
    self.auras_square.Callback = function(self)
        O.db.auras_square = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_border_color_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_border_color_enabled:SetPosition('LEFT', self.auras_square.Label, 'RIGHT', 12, 0);
    self.auras_border_color_enabled:SetLabel(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED']);
    self.auras_border_color_enabled:SetTooltip(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP']);
    self.auras_border_color_enabled:AddToSearch(button, L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_border_color_enabled:SetChecked(O.db.auras_border_color_enabled);
    self.auras_border_color_enabled.Callback = function(self)
        O.db.auras_border_color_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_pandemic_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_pandemic_enabled:SetPosition('TOPLEFT', self.auras_square, 'BOTTOMLEFT', 0, -8);
    self.auras_pandemic_enabled:SetLabel(L['OPTIONS_AURAS_PANDEMIC_ENABLED']);
    self.auras_pandemic_enabled:SetTooltip(L['OPTIONS_AURAS_PANDEMIC_ENABLED_TOOLTIP']);
    self.auras_pandemic_enabled:AddToSearch(button, L['OPTIONS_AURAS_PANDEMIC_ENABLED'], self.Tabs[1]);
    self.auras_pandemic_enabled:SetChecked(O.db.auras_pandemic_enabled);
    self.auras_pandemic_enabled.Callback = function(self)
        O.db.auras_pandemic_enabled = self:GetChecked();
        Handler:UpdateAll();
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

        Handler:UpdateAll();
    end

    self.auras_show_debuffs_on_friendly = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_show_debuffs_on_friendly:SetPosition('TOPLEFT', self.auras_pandemic_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_show_debuffs_on_friendly:SetLabel(L['OPTIONS_AURAS_SHOW_DEBUFFS_ON_FRIENDLY']);
    self.auras_show_debuffs_on_friendly:AddToSearch(button, nil, self.Tabs[1]);
    self.auras_show_debuffs_on_friendly:SetChecked(O.db.auras_show_debuffs_on_friendly);
    self.auras_show_debuffs_on_friendly.Callback = function(self)
        O.db.auras_show_debuffs_on_friendly = self:GetChecked();

        C_CVar.SetCVar('nameplateShowDebuffsOnFriendly', O.db.auras_show_debuffs_on_friendly and 1 or 0);

        Handler:UpdateAll();
    end

    self.auras_sort_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_sort_enabled:SetPosition('TOPLEFT', self.auras_show_debuffs_on_friendly, 'BOTTOMLEFT', 0, -8);
    self.auras_sort_enabled:SetLabel(L['OPTIONS_AURAS_SORT_ENABLED']);
    self.auras_sort_enabled:SetTooltip(L['OPTIONS_AURAS_SORT_ENABLED_TOOLTIP']);
    self.auras_sort_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.auras_sort_enabled:SetChecked(O.db.auras_sort_enabled);
    self.auras_sort_enabled.Callback = function(self)
        O.db.auras_sort_enabled = self:GetChecked();

        panel.auras_sort_method:SetEnabled(O.db.auras_sort_enabled);

        Handler:UpdateAll();
    end

    self.auras_sort_method = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_sort_method:SetPosition('LEFT', self.auras_sort_enabled.Label, 'RIGHT', 12, 0);
    self.auras_sort_method:SetSize(180, 20);
    self.auras_sort_method:SetList(O.Lists.auras_sort_method);
    self.auras_sort_method:SetTooltip(L['OPTIONS_AURAS_SORT_TOOLTIP']);
    self.auras_sort_method:AddToSearch(button, L['OPTIONS_AURAS_SORT_TOOLTIP'], self.Tabs[1]);
    self.auras_sort_method:SetValue(O.db.auras_sort_method);
    self.auras_sort_method:SetEnabled(O.db.auras_sort_enabled);
    self.auras_sort_method.OnValueChangedCallback = function(_, value)
        O.db.auras_sort_method = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_hpbar_color_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_hpbar_color_enabled:SetPosition('TOPLEFT', self.auras_sort_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_hpbar_color_enabled:SetLabel(L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED']);
    self.auras_hpbar_color_enabled:SetTooltip(L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED_TOOLTIP']);
    self.auras_hpbar_color_enabled:AddToSearch(button, L['OPTIONS_AURAS_HPBAR_COLOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_hpbar_color_enabled:SetChecked(O.db.auras_hpbar_color_enabled);
    self.auras_hpbar_color_enabled.Callback = function(self)
        O.db.auras_hpbar_color_enabled = self:GetChecked();
        Handler:UpdateAll();
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
        panel.BlackListButton:SetLabel(L['OPTIONS_AURAS_BLACKLIST_BUTTON_OPEN']);
    end);

    self.HPBarColorList = Mixin(CreateFrame('Frame', nil, self.TabsFrames['CommonTab'].Content, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.HPBarColorList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.HPBarColorList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.HPBarColorList:SetWidth(250);
    self.HPBarColorList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.HPBarColorList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.HPBarColorList:SetShown(false);

    self.HPBarColorListEditbox = E.CreateEditBox(self.HPBarColorList);
    self.HPBarColorListEditbox:SetPosition('TOP', self.HPBarColorList, 'TOP', 0, -10);
    self.HPBarColorListEditbox:SetSize(228, 20);
    self.HPBarColorListEditbox.useLastValue = false;
    self.HPBarColorListEditbox:SetInstruction(L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID']);
    self.HPBarColorListEditbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            saveId = tonumber(select(7, GetSpellInfo(text)) or '');
        end

        if not saveId then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddHPBarColorAura(tonumber(saveId));

        panel:UpdateHPBarColorScroll();
        self:SetText('');

        Handler:UpdateAll();
    end);

    self.HPBarColorListScroll = Mixin(CreateFrame('Frame', nil, self.HPBarColorList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.HPBarColorListScroll:SetPoint('TOPLEFT', self.HPBarColorList , 'TOPLEFT', 6, -40);
    self.HPBarColorListScroll:SetPoint('BOTTOMRIGHT', self.HPBarColorList, 'BOTTOMRIGHT', -6, 6);
    self.HPBarColorListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.HPBarColorListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.HPBarColorListScrollChild, self.HPBarColorListScrollArea = E.CreateScrollFrame(self.HPBarColorListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.HPBarColorListScrollArea.ScrollBar, 'TOPLEFT', self.HPBarColorListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.HPBarColorListScrollArea.ScrollBar, 'BOTTOMLEFT', self.HPBarColorListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.HPBarColorButtonPool = CreateFramePool('Button', self.HPBarColorListScrollChild, 'BackdropTemplate');

    self:UpdateHPBarColorScroll();

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_hpbar_color_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_scale = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_scale:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -18);
    self.auras_scale:SetValues(O.db.auras_scale, 0.25, 3, 0.05);
    self.auras_scale:SetLabel(L['OPTIONS_AURAS_SCALE']);
    self.auras_scale:SetTooltip(L['OPTIONS_AURAS_SCALE_TOOLTIP']);
    self.auras_scale:AddToSearch(button, L['OPTIONS_AURAS_SCALE_TOOLTIP'], self.Tabs[1]);
    self.auras_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_offset_y:SetPosition('LEFT', self.auras_scale, 'RIGHT', 16, 0);
    self.auras_offset_y:SetValues(O.db.auras_offset_y, -50, 50, 1);
    self.auras_offset_y:SetLabel(L['OPTIONS_AURAS_OFFSET_Y']);
    self.auras_offset_y:SetTooltip(L['OPTIONS_AURAS_OFFSET_Y_TOOLTIP']);
    self.auras_offset_y:AddToSearch(button, L['OPTIONS_AURAS_OFFSET_Y_TOOLTIP'], self.Tabs[1]);
    self.auras_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_scale, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_countdown_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_countdown_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.auras_countdown_enabled:SetLabel(L['OPTIONS_AURAS_COUNTDOWN_ENABLED']);
    self.auras_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_countdown_enabled:SetChecked(O.db.auras_countdown_enabled);
    self.auras_countdown_enabled.Callback = function(self)
        O.db.auras_countdown_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_omnicc_suppress = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_omnicc_suppress:SetPosition('LEFT', self.auras_countdown_enabled.Label, 'RIGHT', 12, 0);
    self.auras_omnicc_suppress:SetLabel(L['OPTIONS_AURAS_OMNICC_SUPPRESS']);
    self.auras_omnicc_suppress:SetTooltip(L['OPTIONS_AURAS_OMNICC_SUPPRESS_TOOLTIP']);
    self.auras_omnicc_suppress:AddToSearch(button, L['OPTIONS_AURAS_OMNICC_SUPPRESS_TOOLTIP'], self.Tabs[1]);
    self.auras_omnicc_suppress:SetChecked(O.db.auras_omnicc_suppress);
    self.auras_omnicc_suppress.Callback = function(self)
        O.db.auras_omnicc_suppress = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_countdown_text = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_countdown_text:SetPosition('TOPLEFT', self.auras_countdown_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_value:SetPosition('TOPLEFT', self.auras_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_cooldown_font_value:SetSize(160, 20);
    self.auras_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_cooldown_font_value:SetValue(O.db.auras_cooldown_font_value);
    self.auras_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_VALUE']);
    self.auras_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_VALUE'], self.Tabs[1]);
    self.auras_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_cooldown_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_size:SetPosition('LEFT', self.auras_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_cooldown_font_size:SetValues(O.db.auras_cooldown_font_size, 2, 28, 1);
    self.auras_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_SIZE']);
    self.auras_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_SIZE'], self.Tabs[1]);
    self.auras_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_font_shadow:SetPosition('LEFT', self.auras_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_cooldown_font_shadow:SetChecked(O.db.auras_cooldown_font_shadow);
    self.auras_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW']);
    self.auras_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW'], self.Tabs[1]);
    self.auras_cooldown_font_shadow.Callback = function(self)
        O.db.auras_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_cooldown_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_offset_x:SetPosition('LEFT', self.auras_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_cooldown_offset_x:SetSize(120, 18);
    self.auras_cooldown_offset_x:SetValues(O.db.auras_cooldown_offset_x, -50, 50, 1);
    self.auras_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_cooldown_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_cooldown_offset_y:SetPosition('LEFT', self.auras_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_cooldown_offset_y:SetSize(120, 18);
    self.auras_cooldown_offset_y:SetValues(O.db.auras_cooldown_offset_y, -50, 50, 1);
    self.auras_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_cooldown_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_count_text = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_count_text:SetPosition('TOPLEFT', self.auras_cooldown_point, 'BOTTOMLEFT', 0, -16);
    self.auras_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_count_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_value:SetPosition('TOPLEFT', self.auras_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_count_font_value:SetSize(160, 20);
    self.auras_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_count_font_value:SetValue(O.db.auras_count_font_value);
    self.auras_count_font_value:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_VALUE']);
    self.auras_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_VALUE'], self.Tabs[1]);
    self.auras_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_count_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_count_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_size:SetPosition('LEFT', self.auras_count_font_value, 'RIGHT', 12, 0);
    self.auras_count_font_size:SetValues(O.db.auras_count_font_size, 2, 28, 1);
    self.auras_count_font_size:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_SIZE']);
    self.auras_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_SIZE'], self.Tabs[1]);
    self.auras_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_count_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_count_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_count_font_shadow:SetPosition('LEFT', self.auras_count_font_flag, 'RIGHT', 12, 0);
    self.auras_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_count_font_shadow:SetChecked(O.db.auras_count_font_shadow);
    self.auras_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_SHADOW']);
    self.auras_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_SHADOW'], self.Tabs[1]);
    self.auras_count_font_shadow.Callback = function(self)
        O.db.auras_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_count_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_offset_x:SetPosition('LEFT', self.auras_count_relative_point, 'RIGHT', 8, 0);
    self.auras_count_offset_x:SetSize(120, 18);
    self.auras_count_offset_x:SetValues(O.db.auras_count_offset_x, -50, 50, 1);
    self.auras_count_offset_x:SetTooltip(L['OPTIONS_AURAS_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_count_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_count_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_count_offset_y:SetPosition('LEFT', self.auras_count_offset_x, 'RIGHT', 12, 0);
    self.auras_count_offset_y:SetSize(120, 18);
    self.auras_count_offset_y:SetValues(O.db.auras_count_offset_y, -50, 50, 1);
    self.auras_count_offset_y:SetTooltip(L['OPTIONS_AURAS_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_count_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_count_point, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.auras_expire_glow_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
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

        Handler:UpdateAll();
    end

    self.auras_expire_glow_type = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_type:SetPosition('LEFT', self.auras_expire_glow_enabled.Label, 'RIGHT', 12, 0);
    self.auras_expire_glow_type:SetSize(220, 20);
    self.auras_expire_glow_type:SetList(O.Lists.glow_type);
    self.auras_expire_glow_type:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_TYPE_TOOLTIP']);
    self.auras_expire_glow_type:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_TYPE_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_type:SetValue(O.db.auras_expire_glow_type);
    self.auras_expire_glow_type:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_type.OnValueChangedCallback = function(_, value)
        O.db.auras_expire_glow_type = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_expire_glow_percent = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_percent:SetPosition('TOPLEFT', self.auras_expire_glow_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_expire_glow_percent:SetValues(O.db.auras_expire_glow_percent, 1, 100, 1);
    self.auras_expire_glow_percent:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_PERCENT_TOOLTIP']);
    self.auras_expire_glow_percent:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_PERCENT_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_percent:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_percent.OnValueChangedCallback = function(_, value)
        O.db.auras_expire_glow_percent = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_expire_glow_percent_sign = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_percent_sign:SetPosition('LEFT', self.auras_expire_glow_percent, 'RIGHT', 2, 0);
    self.auras_expire_glow_percent_sign:SetText('%');
    self.auras_expire_glow_percent_sign:SetFontObject(O.db.auras_expire_glow_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');

    self.auras_expire_glow_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.auras_expire_glow_color:SetPosition('LEFT', self.auras_expire_glow_percent_sign, 'RIGHT', 12, 0);
    self.auras_expire_glow_color:SetTooltip(L['OPTIONS_AURAS_EXPIRE_GLOW_COLOR_TOOLTIP']);
    self.auras_expire_glow_color:AddToSearch(button, L['OPTIONS_AURAS_EXPIRE_GLOW_COLOR_TOOLTIP'], self.Tabs[1]);
    self.auras_expire_glow_color:SetValue(unpack(O.db.auras_expire_glow_color));
    self.auras_expire_glow_color:SetEnabled(O.db.auras_expire_glow_enabled);
    self.auras_expire_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.auras_expire_glow_color[1] = r;
        O.db.auras_expire_glow_color[2] = g;
        O.db.auras_expire_glow_color[3] = b;
        O.db.auras_expire_glow_color[4] = a or 1;

        Handler:UpdateAll();
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
        Handler:UpdateAll();
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

        Handler:UpdateAll();
    end

    self.auras_spellsteal_countdown_enabled = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_countdown_enabled:SetPosition('TOPLEFT', self.auras_spellsteal_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_spellsteal_countdown_enabled:SetLabel(L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED']);
    self.auras_spellsteal_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_spellsteal_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.auras_spellsteal_countdown_enabled:SetChecked(O.db.auras_spellsteal_countdown_enabled);
    self.auras_spellsteal_countdown_enabled.Callback = function(self)
        O.db.auras_spellsteal_countdown_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_spellsteal_countdown_text = E.CreateFontString(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_countdown_text:SetPosition('TOPLEFT', self.auras_spellsteal_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_spellsteal_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_spellsteal_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_value:SetPosition('TOPLEFT', self.auras_spellsteal_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_spellsteal_cooldown_font_value:SetSize(160, 20);
    self.auras_spellsteal_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_spellsteal_cooldown_font_value:SetValue(O.db.auras_spellsteal_cooldown_font_value);
    self.auras_spellsteal_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_VALUE']);
    self.auras_spellsteal_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_VALUE'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_size = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_size:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_font_size:SetValues(O.db.auras_spellsteal_cooldown_font_size, 2, 28, 1);
    self.auras_spellsteal_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SIZE']);
    self.auras_spellsteal_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SIZE'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_spellsteal_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_font_shadow:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_spellsteal_cooldown_font_shadow:SetChecked(O.db.auras_spellsteal_cooldown_font_shadow);
    self.auras_spellsteal_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW']);
    self.auras_spellsteal_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_spellsteal_cooldown_offset_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_offset_x:SetPosition('LEFT', self.auras_spellsteal_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_spellsteal_cooldown_offset_x:SetSize(120, 18);
    self.auras_spellsteal_cooldown_offset_x:SetValues(O.db.auras_spellsteal_cooldown_offset_x, -50, 50, 1);
    self.auras_spellsteal_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_spellsteal_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_spellsteal_cooldown_offset_y = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_cooldown_offset_y:SetPosition('LEFT', self.auras_spellsteal_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_spellsteal_cooldown_offset_y:SetSize(120, 18);
    self.auras_spellsteal_cooldown_offset_y:SetValues(O.db.auras_spellsteal_cooldown_offset_y, -50, 50, 1);
    self.auras_spellsteal_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_spellsteal_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_cooldown_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_text = E.CreateFontString(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_text:SetPosition('TOPLEFT', self.auras_spellsteal_cooldown_point, 'BOTTOMLEFT', 0, -16);
    self.auras_spellsteal_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_spellsteal_count_font_value = E.CreateDropdown('font', self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_value:SetPosition('TOPLEFT', self.auras_spellsteal_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_spellsteal_count_font_value:SetSize(160, 20);
    self.auras_spellsteal_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_spellsteal_count_font_value:SetValue(O.db.auras_spellsteal_count_font_value);
    self.auras_spellsteal_count_font_value:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_VALUE']);
    self.auras_spellsteal_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_VALUE'], self.Tabs[2]);
    self.auras_spellsteal_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_font_size = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_size:SetPosition('LEFT', self.auras_spellsteal_count_font_value, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_font_size:SetValues(O.db.auras_spellsteal_count_font_size, 2, 28, 1);
    self.auras_spellsteal_count_font_size:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SIZE']);
    self.auras_spellsteal_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SIZE'], self.Tabs[2]);
    self.auras_spellsteal_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_font_shadow:SetPosition('LEFT', self.auras_spellsteal_count_font_flag, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_spellsteal_count_font_shadow:SetChecked(O.db.auras_spellsteal_count_font_shadow);
    self.auras_spellsteal_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW']);
    self.auras_spellsteal_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_count_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_offset_x = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_offset_x:SetPosition('LEFT', self.auras_spellsteal_count_relative_point, 'RIGHT', 8, 0);
    self.auras_spellsteal_count_offset_x:SetSize(120, 18);
    self.auras_spellsteal_count_offset_x:SetValues(O.db.auras_spellsteal_count_offset_x, -50, 50, 1);
    self.auras_spellsteal_count_offset_x:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_spellsteal_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_offset_y = E.CreateSlider(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_offset_y:SetPosition('LEFT', self.auras_spellsteal_count_offset_x, 'RIGHT', 12, 0);
    self.auras_spellsteal_count_offset_y:SetSize(120, 18);
    self.auras_spellsteal_count_offset_y:SetValues(O.db.auras_spellsteal_count_offset_y, -50, 50, 1);
    self.auras_spellsteal_count_offset_y:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_spellsteal_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_spellsteal_count_offset_y = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_mythicplus_countdown_enabled = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_countdown_enabled:SetPosition('TOPLEFT', self.auras_mythicplus_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_mythicplus_countdown_enabled:SetLabel(L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED']);
    self.auras_mythicplus_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_mythicplus_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_countdown_enabled:SetChecked(O.db.auras_mythicplus_countdown_enabled);
    self.auras_mythicplus_countdown_enabled.Callback = function(self)
        O.db.auras_mythicplus_countdown_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_mythicplus_countdown_text = E.CreateFontString(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_countdown_text:SetPosition('TOPLEFT', self.auras_mythicplus_countdown_enabled, 'BOTTOMLEFT', 0, -16);
    self.auras_mythicplus_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_mythicplus_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_value:SetPosition('TOPLEFT', self.auras_mythicplus_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_mythicplus_cooldown_font_value:SetSize(160, 20);
    self.auras_mythicplus_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_mythicplus_cooldown_font_value:SetValue(O.db.auras_mythicplus_cooldown_font_value);
    self.auras_mythicplus_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_VALUE']);
    self.auras_mythicplus_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_VALUE'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_size = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_size:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_font_size:SetValues(O.db.auras_mythicplus_cooldown_font_size, 2, 28, 1);
    self.auras_mythicplus_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SIZE']);
    self.auras_mythicplus_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SIZE'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_mythicplus_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_font_shadow:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_mythicplus_cooldown_font_shadow:SetChecked(O.db.auras_mythicplus_cooldown_font_shadow);
    self.auras_mythicplus_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW']);
    self.auras_mythicplus_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_mythicplus_cooldown_offset_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_offset_x:SetPosition('LEFT', self.auras_mythicplus_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_mythicplus_cooldown_offset_x:SetSize(120, 18);
    self.auras_mythicplus_cooldown_offset_x:SetValues(O.db.auras_mythicplus_cooldown_offset_x, -50, 50, 1);
    self.auras_mythicplus_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_mythicplus_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_mythicplus_cooldown_offset_y = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_cooldown_offset_y:SetPosition('LEFT', self.auras_mythicplus_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_mythicplus_cooldown_offset_y:SetSize(120, 18);
    self.auras_mythicplus_cooldown_offset_y:SetValues(O.db.auras_mythicplus_cooldown_offset_y, -50, 50, 1);
    self.auras_mythicplus_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_mythicplus_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_cooldown_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_text = E.CreateFontString(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_text:SetPosition('TOPLEFT', self.auras_mythicplus_cooldown_point, 'BOTTOMLEFT', 0, -16);
    self.auras_mythicplus_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_mythicplus_count_font_value = E.CreateDropdown('font', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_value:SetPosition('TOPLEFT', self.auras_mythicplus_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_mythicplus_count_font_value:SetSize(160, 20);
    self.auras_mythicplus_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_mythicplus_count_font_value:SetValue(O.db.auras_mythicplus_count_font_value);
    self.auras_mythicplus_count_font_value:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_VALUE']);
    self.auras_mythicplus_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_VALUE'], self.Tabs[3]);
    self.auras_mythicplus_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_font_size = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_size:SetPosition('LEFT', self.auras_mythicplus_count_font_value, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_font_size:SetValues(O.db.auras_mythicplus_count_font_size, 2, 28, 1);
    self.auras_mythicplus_count_font_size:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SIZE']);
    self.auras_mythicplus_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SIZE'], self.Tabs[3]);
    self.auras_mythicplus_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_font_shadow = E.CreateCheckButton(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_font_shadow:SetPosition('LEFT', self.auras_mythicplus_count_font_flag, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_mythicplus_count_font_shadow:SetChecked(O.db.auras_mythicplus_count_font_shadow);
    self.auras_mythicplus_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW']);
    self.auras_mythicplus_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_count_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_relative_point = E.CreateDropdown('plain', self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_relative_point:SetPosition('LEFT', self.auras_mythicplus_count_point, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_relative_point:SetSize(120, 20);
    self.auras_mythicplus_count_relative_point:SetList(O.Lists.frame_points_localized);
    self.auras_mythicplus_count_relative_point:SetValue(O.db.auras_mythicplus_count_relative_point);
    self.auras_mythicplus_count_relative_point:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_RELATIVE_POINT_TOOLTIP']);
    self.auras_mythicplus_count_relative_point:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_RELATIVE_POINT_TOOLTIP'], self.Tabs[3]);
    self.auras_mythicplus_count_relative_point.OnValueChangedCallback = function(_, value)
        O.db.auras_count_relative_point = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_offset_x = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_offset_x:SetPosition('LEFT', self.auras_mythicplus_count_relative_point, 'RIGHT', 8, 0);
    self.auras_mythicplus_count_offset_x:SetSize(120, 18);
    self.auras_mythicplus_count_offset_x:SetValues(O.db.auras_mythicplus_count_offset_x, -50, 50, 1);
    self.auras_mythicplus_count_offset_x:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_mythicplus_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_offset_y = E.CreateSlider(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_offset_y:SetPosition('LEFT', self.auras_mythicplus_count_offset_x, 'RIGHT', 12, 0);
    self.auras_mythicplus_count_offset_y:SetSize(120, 18);
    self.auras_mythicplus_count_offset_y:SetValues(O.db.auras_mythicplus_count_offset_y, -50, 50, 1);
    self.auras_mythicplus_count_offset_y:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_mythicplus_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_mythicplus_count_offset_y = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_countdown_enabled = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_countdown_enabled:SetPosition('TOPLEFT', self.auras_important_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_important_countdown_enabled:SetLabel(L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED']);
    self.auras_important_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_important_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.auras_important_countdown_enabled:SetChecked(O.db.auras_important_countdown_enabled);
    self.auras_important_countdown_enabled.Callback = function(self)
        O.db.auras_important_countdown_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_important_scale = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_scale:SetPosition('TOPLEFT', self.auras_important_countdown_enabled, 'BOTTOMLEFT', 0, -28);
    self.auras_important_scale:SetValues(O.db.auras_important_scale, 0.25, 4, 0.05);
    self.auras_important_scale:SetLabel(L['OPTIONS_AURAS_IMPORTANT_SCALE']);
    self.auras_important_scale:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP']);
    self.auras_important_scale:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_important_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_important_countdown_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_countdown_text:SetPosition('TOPLEFT', self.auras_important_scale, 'BOTTOMLEFT', 0, -16);
    self.auras_important_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_important_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_value:SetPosition('TOPLEFT', self.auras_important_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_important_cooldown_font_value:SetSize(160, 20);
    self.auras_important_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_important_cooldown_font_value:SetValue(O.db.auras_important_cooldown_font_value);
    self.auras_important_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_VALUE']);
    self.auras_important_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_VALUE'], self.Tabs[4]);
    self.auras_important_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_important_cooldown_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_size:SetPosition('LEFT', self.auras_important_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_important_cooldown_font_size:SetValues(O.db.auras_important_cooldown_font_size, 2, 28, 1);
    self.auras_important_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SIZE']);
    self.auras_important_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_font_shadow:SetPosition('LEFT', self.auras_important_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_important_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_cooldown_font_shadow:SetChecked(O.db.auras_important_cooldown_font_shadow);
    self.auras_important_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW']);
    self.auras_important_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_cooldown_font_shadow.Callback = function(self)
        O.db.auras_important_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_cooldown_offset_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_offset_x:SetPosition('LEFT', self.auras_important_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_important_cooldown_offset_x:SetSize(120, 18);
    self.auras_important_cooldown_offset_x:SetValues(O.db.auras_important_cooldown_offset_x, -50, 50, 1);
    self.auras_important_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_important_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_important_cooldown_offset_y = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_cooldown_offset_y:SetPosition('LEFT', self.auras_important_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_important_cooldown_offset_y:SetSize(120, 18);
    self.auras_important_cooldown_offset_y:SetValues(O.db.auras_important_cooldown_offset_y, -50, 50, 1);
    self.auras_important_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_important_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_important_cooldown_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_important_count_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_text:SetPosition('TOPLEFT', self.auras_important_cooldown_point, 'BOTTOMLEFT', 0, -16);
    self.auras_important_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_important_count_font_value = E.CreateDropdown('font', self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_value:SetPosition('TOPLEFT', self.auras_important_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_important_count_font_value:SetSize(160, 20);
    self.auras_important_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_important_count_font_value:SetValue(O.db.auras_important_count_font_value);
    self.auras_important_count_font_value:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_VALUE']);
    self.auras_important_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_VALUE'], self.Tabs[4]);
    self.auras_important_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_important_count_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_size:SetPosition('LEFT', self.auras_important_count_font_value, 'RIGHT', 12, 0);
    self.auras_important_count_font_size:SetValues(O.db.auras_important_count_font_size, 2, 28, 1);
    self.auras_important_count_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SIZE']);
    self.auras_important_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_count_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_font_shadow:SetPosition('LEFT', self.auras_important_count_font_flag, 'RIGHT', 12, 0);
    self.auras_important_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_count_font_shadow:SetChecked(O.db.auras_important_count_font_shadow);
    self.auras_important_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW']);
    self.auras_important_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_count_font_shadow.Callback = function(self)
        O.db.auras_important_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_count_offset_x = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_offset_x:SetPosition('LEFT', self.auras_important_count_relative_point, 'RIGHT', 8, 0);
    self.auras_important_count_offset_x:SetSize(120, 18);
    self.auras_important_count_offset_x:SetValues(O.db.auras_important_count_offset_x, -50, 50, 1);
    self.auras_important_count_offset_x:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_important_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_important_count_offset_y = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_offset_y:SetPosition('LEFT', self.auras_important_count_offset_x, 'RIGHT', 12, 0);
    self.auras_important_count_offset_y:SetSize(120, 18);
    self.auras_important_count_offset_y:SetValues(O.db.auras_important_count_offset_y, -50, 50, 1);
    self.auras_important_count_offset_y:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_important_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_important_count_offset_y = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_castername_font_size = E.CreateSlider(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_size:SetPosition('LEFT', self.auras_important_castername_font_value, 'RIGHT', 12, 0);
    self.auras_important_castername_font_size:SetValues(O.db.auras_important_castername_font_size, 2, 28, 1);
    self.auras_important_castername_font_size:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SIZE']);
    self.auras_important_castername_font_size:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SIZE'], self.Tabs[4]);
    self.auras_important_castername_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_important_castername_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_important_castername_font_shadow = E.CreateCheckButton(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_castername_font_shadow:SetPosition('LEFT', self.auras_important_castername_font_flag, 'RIGHT', 12, 0);
    self.auras_important_castername_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_important_castername_font_shadow:SetChecked(O.db.auras_important_castername_font_shadow);
    self.auras_important_castername_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW']);
    self.auras_important_castername_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_castername_font_shadow.Callback = function(self)
        O.db.auras_important_castername_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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

        Handler:UpdateAll();
    end

    self.auras_custom_countdown_enabled = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_countdown_enabled:SetPosition('TOPLEFT', self.auras_custom_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_custom_countdown_enabled:SetLabel(L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED']);
    self.auras_custom_countdown_enabled:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED_TOOLTIP']);
    self.auras_custom_countdown_enabled:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_countdown_enabled:SetChecked(O.db.auras_custom_countdown_enabled);
    self.auras_custom_countdown_enabled.Callback = function(self)
        O.db.auras_custom_countdown_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_custom_scale = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_scale:SetPosition('TOPLEFT', self.auras_custom_countdown_enabled, 'BOTTOMLEFT', 0, -28);
    self.auras_custom_scale:SetValues(O.db.auras_custom_scale, 0.25, 4, 0.05);
    self.auras_custom_scale:SetLabel(L['OPTIONS_AURAS_CUSTOM_SCALE']);
    self.auras_custom_scale:SetTooltip(L['OPTIONS_AURAS_CUSTOM_SCALE_TOOLTIP']);
    self.auras_custom_scale:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_SCALE_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_custom_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_offset_y:SetPosition('LEFT', self.auras_custom_scale, 'RIGHT', 16, 0);
    self.auras_custom_offset_y:SetValues(O.db.auras_custom_offset_y, -50, 50, 1);
    self.auras_custom_offset_y:SetLabel(L['OPTIONS_AURAS_CUSTOM_OFFSET_Y']);
    self.auras_custom_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_OFFSET_Y_TOOLTIP']);
    self.auras_custom_offset_y:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_OFFSET_Y_TOOLTIP'], self.Tabs[5]);
    self.auras_custom_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_custom_countdown_text = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_countdown_text:SetPosition('TOPLEFT', self.auras_custom_scale, 'BOTTOMLEFT', 0, -16);
    self.auras_custom_countdown_text:SetText(L['OPTIONS_AURAS_COUNTDOWN_TEXT']);

    self.auras_custom_cooldown_font_value = E.CreateDropdown('font', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_value:SetPosition('TOPLEFT', self.auras_custom_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.auras_custom_cooldown_font_value:SetSize(160, 20);
    self.auras_custom_cooldown_font_value:SetList(LSM:HashTable('font'));
    self.auras_custom_cooldown_font_value:SetValue(O.db.auras_custom_cooldown_font_value);
    self.auras_custom_cooldown_font_value:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_VALUE']);
    self.auras_custom_cooldown_font_value:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_VALUE'], self.Tabs[5]);
    self.auras_custom_cooldown_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_custom_cooldown_font_size = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_size:SetPosition('LEFT', self.auras_custom_cooldown_font_value, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_font_size:SetValues(O.db.auras_custom_cooldown_font_size, 2, 28, 1);
    self.auras_custom_cooldown_font_size:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SIZE']);
    self.auras_custom_cooldown_font_size:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SIZE'], self.Tabs[5]);
    self.auras_custom_cooldown_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_custom_cooldown_font_shadow = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_font_shadow:SetPosition('LEFT', self.auras_custom_cooldown_font_flag, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_custom_cooldown_font_shadow:SetChecked(O.db.auras_custom_cooldown_font_shadow);
    self.auras_custom_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SHADOW']);
    self.auras_custom_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SHADOW'], self.Tabs[5]);
    self.auras_custom_cooldown_font_shadow.Callback = function(self)
        O.db.auras_custom_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_custom_cooldown_offset_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_offset_x:SetPosition('LEFT', self.auras_custom_cooldown_relative_point, 'RIGHT', 8, 0);
    self.auras_custom_cooldown_offset_x:SetSize(120, 18);
    self.auras_custom_cooldown_offset_x:SetValues(O.db.auras_custom_cooldown_offset_x, -50, 50, 1);
    self.auras_custom_cooldown_offset_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_OFFSET_X_TOOLTIP']);
    self.auras_custom_cooldown_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_custom_cooldown_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_cooldown_offset_y:SetPosition('LEFT', self.auras_custom_cooldown_offset_x, 'RIGHT', 12, 0);
    self.auras_custom_cooldown_offset_y:SetSize(120, 18);
    self.auras_custom_cooldown_offset_y:SetValues(O.db.auras_custom_cooldown_offset_y, -50, 50, 1);
    self.auras_custom_cooldown_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COOLDOWN_OFFSET_Y_TOOLTIP']);
    self.auras_custom_cooldown_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_cooldown_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_custom_count_text = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_text:SetPosition('TOPLEFT', self.auras_custom_cooldown_point, 'BOTTOMLEFT', 0, -16);
    self.auras_custom_count_text:SetText(L['OPTIONS_AURAS_COUNT_TEXT']);

    self.auras_custom_count_font_value = E.CreateDropdown('font', self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_value:SetPosition('TOPLEFT', self.auras_custom_count_text, 'BOTTOMLEFT', 0, -4);
    self.auras_custom_count_font_value:SetSize(160, 20);
    self.auras_custom_count_font_value:SetList(LSM:HashTable('font'));
    self.auras_custom_count_font_value:SetValue(O.db.auras_custom_count_font_value);
    self.auras_custom_count_font_value:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_VALUE']);
    self.auras_custom_count_font_value:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_VALUE'], self.Tabs[5]);
    self.auras_custom_count_font_value.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_font_value = value;
        Handler:UpdateAll();
    end

    self.auras_custom_count_font_size = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_size:SetPosition('LEFT', self.auras_custom_count_font_value, 'RIGHT', 12, 0);
    self.auras_custom_count_font_size:SetValues(O.db.auras_custom_count_font_size, 2, 28, 1);
    self.auras_custom_count_font_size:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SIZE']);
    self.auras_custom_count_font_size:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SIZE'], self.Tabs[5]);
    self.auras_custom_count_font_size.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_font_size = tonumber(value);
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_custom_count_font_shadow = E.CreateCheckButton(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_font_shadow:SetPosition('LEFT', self.auras_custom_count_font_flag, 'RIGHT', 12, 0);
    self.auras_custom_count_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.auras_custom_count_font_shadow:SetChecked(O.db.auras_custom_count_font_shadow);
    self.auras_custom_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SHADOW']);
    self.auras_custom_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SHADOW'], self.Tabs[5]);
    self.auras_custom_count_font_shadow.Callback = function(self)
        O.db.auras_custom_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
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
        Handler:UpdateAll();
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
        Handler:UpdateAll();
    end

    self.auras_custom_count_offset_x = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_offset_x:SetPosition('LEFT', self.auras_custom_count_relative_point, 'RIGHT', 8, 0);
    self.auras_custom_count_offset_x:SetSize(120, 18);
    self.auras_custom_count_offset_x:SetValues(O.db.auras_custom_count_offset_x, -50, 50, 1);
    self.auras_custom_count_offset_x:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_OFFSET_X_TOOLTIP']);
    self.auras_custom_count_offset_x.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_offset_x = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_custom_count_offset_y = E.CreateSlider(self.TabsFrames['CustomTab'].Content);
    self.auras_custom_count_offset_y:SetPosition('LEFT', self.auras_custom_count_offset_x, 'RIGHT', 12, 0);
    self.auras_custom_count_offset_y:SetSize(120, 18);
    self.auras_custom_count_offset_y:SetValues(O.db.auras_custom_count_offset_y, -50, 50, 1);
    self.auras_custom_count_offset_y:SetTooltip(L['OPTIONS_AURAS_CUSTOM_COUNT_OFFSET_Y_TOOLTIP']);
    self.auras_custom_count_offset_y.OnValueChangedCallback = function(_, value)
        O.db.auras_custom_count_offset_y = tonumber(value);
        Handler:UpdateAll();
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

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            saveId = tonumber(select(7, GetSpellInfo(text)) or '');
        end

        if not saveId then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddCustomAura(tonumber(saveId));

        panel:UpdateScroll();
        self:SetText('');

        Handler:UpdateAll();
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
            self:SetValue(0);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].auras_custom_data);
            StripesDB.profiles[O.activeProfileId].auras_custom_data = U.DeepCopy(StripesDB.profiles[index].auras_custom_data);
        else
            StripesDB.profiles[O.activeProfileId].auras_custom_data = U.Merge(StripesDB.profiles[index].auras_custom_data, StripesDB.profiles[O.activeProfileId].auras_custom_data);
        end

        self:SetValue(0);

        panel:UpdateScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self.TabsFrames['CustomTab'].Content);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_AURAS_CUSTOM_COPY_FROM_PROFILE']);
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');

    self:UpdateProfilesDropdown();
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    self:UpdateScroll();
    self:UpdateBlackListScroll();
    self:UpdateHPBarColorScroll();
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_CUSTOM_COLOR_COPY_FROM_PROFILE_SHIFT']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_CUSTOM_COLOR_COPY_FROM_PROFILE']);
    end
end