local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Panel');

local isNeedReload, isFirstTimeOpened = false, false;
local wasHidedInCombat, wasNotified = false, false;

local needReloadTable = {};

StaticPopupDialogs['STRIPES_OPTIONS_NEED_RELOAD'] = {
    text    = L['OPTIONS_NEED_RELOAD'],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        C_UI.Reload();
    end,
    hideOnEscape = true,
    whileDead = 1,
    preferredIndex = STATICPOPUPS_NUMDIALOGS,
};

local function BetterOnDragStop(frame, saveTable)
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint();

    saveTable[1] = point;
    saveTable[2] = relativeTo
    saveTable[3] = relativePoint;
    saveTable[4] = xOfs;
    saveTable[5] = yOfs;

    frame:StopMovingOrSizing();

    frame:ClearAllPoints();
    frame:SetPosition(point, UIParent, relativePoint, xOfs, yOfs);
    frame:SetUserPlaced(true);
end

O.frame = Mixin(CreateFrame('Frame', 'Stripes_Options', UIParent, 'BackdropTemplate'), E.PixelPerfectMixin);
O.frame.config = { width = 800, height = 600 };
O.frame:SetPosition('TOP', UIParent, 'TOP', 0, -120);
O.frame:SetSize(O.frame.config.width, O.frame.config.height);
O.frame:SetFrameStrata('DIALOG');
O.frame:Hide();
O.frame.isMin = false;

O.frame:SetClampedToScreen(true);
O.frame:EnableMouse(true);
O.frame:SetMovable(true);
O.frame:RegisterForDrag('LeftButton');

O.frame:SetScript('OnDragStart', function(self)
    if self:IsMovable() then
        self:StartMoving();
    end
end);

O.frame:SetScript('OnDragStop', function(self)
    BetterOnDragStop(self, StripesDB.optionsPosition);
end);

O.frame:EnableKeyboard(true);
O.frame:SetPropagateKeyboardInput(true);
O.frame:SetScript('OnKeyDown', function(self, key)
    self:SetPropagateKeyboardInput(true);

    if IsControlKeyDown() then
        self:SetPropagateKeyboardInput(false);
    end

    if key == 'F' and IsControlKeyDown() then
        O.frame.SearchButton:Hide();
        O.frame.SearchEditbox:Show();
        O.frame.SearchEditbox:SetFocus();

        self:SetPropagateKeyboardInput(false);

        return;
    end

    if GetBindingFromClick(key) == 'TOGGLEGAMEMENU' then
        O.CloseOptions();

        if isNeedReload then
            StaticPopup_Show('STRIPES_OPTIONS_NEED_RELOAD');
        else
            StaticPopup_Hide('STRIPES_OPTIONS_NEED_RELOAD');
        end

        self:SetPropagateKeyboardInput(false);
    end
end);

O.OpenOptions = function()
    if U.PlayerInCombat() then
        if not wasNotified then
            U.Print(L['OPTIONS_WILL_BE_OPENED_AFTER_COMBAT']);
            wasNotified = true;
        end

        wasHidedInCombat = true;

        return;
    end

    if O.frame:IsShown() then
        return;
    end

    if not isFirstTimeOpened then
        O.frame.Left.Home:Click();
        isFirstTimeOpened = true;
    end

    wasNotified = false;

    O.frame:Show();
end

O.CloseOptions = function()
    if not O.frame:IsShown() then
        return;
    end

    O.frame.SearchButton:Show();
    O.frame.SearchEditbox:Hide();
    O.frame:SetPropagateKeyboardInput(false);
    O.frame:Hide();

    if isNeedReload then
        StaticPopup_Show('STRIPES_OPTIONS_NEED_RELOAD');
    else
        StaticPopup_Hide('STRIPES_OPTIONS_NEED_RELOAD');
    end

    E.DropDown_CloseNotActive();
    S:GetModule('Options_Colors'):HideListFrame();
end

O.ToggleOptions = function()
    if O.frame:IsShown() then
        O.CloseOptions();
    else
        O.OpenOptions();
    end
end

O.frame.TopBar = Mixin(CreateFrame('Frame', nil, O.frame, 'BackdropTemplate'), E.PixelPerfectMixin);
O.frame.TopBar:SetPosition('TOPLEFT', O.frame, 'TOPLEFT', 0, 0);
O.frame.TopBar:SetPosition('TOPRIGHT', O.frame, 'TOPRIGHT', 0, 0);
O.frame.TopBar:SetH(40);
O.frame.TopBar:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
O.frame.TopBar:SetBackdropColor(0.05, 0.05, 0.05, 1);

O.frame.TopBar.Logo = Mixin(CreateFrame('Button', nil, O.frame.TopBar), E.PixelPerfectMixin);
O.frame.TopBar.Logo:SetPosition('TOP', O.frame.TopBar, 'TOP', 0, 0);
O.frame.TopBar.Logo:SetSize(128, 32);

O.frame.TopBar.Logo.Texture = Mixin(O.frame.TopBar.Logo:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
O.frame.TopBar.Logo.Texture:SetAllPoints();
O.frame.TopBar.Logo.Texture:SetSize(128, 32);
O.frame.TopBar.Logo.Texture:SetTexture(S.Media.StripesArt.TEXTURE);
O.frame.TopBar.Logo.Texture:SetTexCoord(unpack(S.Media.StripesArt.COORDS.WORD_WHITE));

O.frame.TopBar.Logo:SetScript('OnEnter', function(self)
    self.Texture:SetTexCoord(unpack(S.Media.StripesArt.COORDS.WORD_GRADIENT));
end);

O.frame.TopBar.Logo:SetScript('OnLeave', function(self)
    self.Texture:SetTexCoord(unpack(S.Media.StripesArt.COORDS.WORD_WHITE));
end);

O.frame.TopBar.Logo:SetScript('OnClick', function()
    O.frame.Left.Home:Click();
end);

O.frame.TopBar.CurrentProfileName = Mixin(O.frame.TopBar:CreateFontString(nil, 'ARTWORK', 'StripesSmallNormalFont'), E.PixelPerfectMixin);
O.frame.TopBar.CurrentProfileName:SetPosition('TOP', O.frame.TopBar.Logo, 'BOTTOM', 0, 6);

O.frame.TopBar.CloseButton = Mixin(CreateFrame('Button', nil, O.frame.TopBar), E.PixelPerfectMixin);
O.frame.TopBar.CloseButton:SetPosition('RIGHT', O.frame.TopBar, 'RIGHT', -13, 0);
O.frame.TopBar.CloseButton:SetSize(14, 14);
O.frame.TopBar.CloseButton:SetNormalTexture(S.Media.Icons.TEXTURE);
O.frame.TopBar.CloseButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CROSS_WHITE));
O.frame.TopBar.CloseButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
O.frame.TopBar.CloseButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
O.frame.TopBar.CloseButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CROSS_WHITE));
O.frame.TopBar.CloseButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
O.frame.TopBar.CloseButton:SetScript('OnClick', O.CloseOptions);

local function CollapseOptions()
    if not O.frame.isMin then
        O.frame:SetH(40);
        O.frame.Main:Hide();

        O.frame.isMin = true;
    end
end

local function ExpandOptions()
    if O.frame.isMin then
        O.frame:SetH(600);
        O.frame.Main:Show();

        O.frame.isMin = false;
    end
end

local function ToggleMinimizedOptions()
    O.frame.isMin = not O.frame.isMin;

    if O.frame.isMin then
        O.frame:SetH(40);
        O.frame.Main:Hide();

        S:GetModule('Options_Colors'):HideListFrame();
    else
        O.frame:SetH(600);
        O.frame.Main:Show();
    end
end

O.CollapseOptions        = CollapseOptions;
O.ExpandOptions          = ExpandOptions;
O.ToggleMinimizedOptions = ToggleMinimizedOptions;

O.frame.TopBar.MinButton = Mixin(CreateFrame('Button', nil, O.frame.TopBar), E.PixelPerfectMixin);
O.frame.TopBar.MinButton:SetPosition('RIGHT', O.frame.TopBar.CloseButton, 'LEFT', -13, 0);
O.frame.TopBar.MinButton:SetSize(14, 14);
O.frame.TopBar.MinButton.icon = O.frame.TopBar.MinButton:CreateTexture(nil, 'OVERLAY');
PixelUtil.SetPoint(O.frame.TopBar.MinButton.icon, 'BOTTOM', O.frame.TopBar.MinButton, 'BOTTOM', 0, 0);
PixelUtil.SetSize(O.frame.TopBar.MinButton.icon, 14, 2);
O.frame.TopBar.MinButton.icon:SetTexture('Interface\\Buttons\\WHITE8x8');
O.frame.TopBar.MinButton.icon:SetVertexColor(0.7, 0.7, 0.7, 1);
O.frame.TopBar.MinButton:SetScript('OnEnter', function(self) self.icon:SetVertexColor(1, 0.85, 0, 1); end);
O.frame.TopBar.MinButton:SetScript('OnLeave', function(self) self.icon:SetVertexColor(0.7, 0.7, 0.7, 1); end);
O.frame.TopBar.MinButton:SetScript('OnClick', ToggleMinimizedOptions);

local Search = S:GetModule('Options_Search');
local searchFrame = Search:GetFrame();

O.frame.SearchButton = Mixin(CreateFrame('Button', nil, O.frame.TopBar), E.PixelPerfectMixin);
O.frame.SearchButton:SetPosition('LEFT', O.frame.TopBar, 'LEFT', 13, 0);
O.frame.SearchButton:SetSize(16, 16);
O.frame.SearchButton:SetNormalTexture(S.Media.Icons.TEXTURE);
O.frame.SearchButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.MAGNIFIER_WHITE));
O.frame.SearchButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
O.frame.SearchButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
O.frame.SearchButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.MAGNIFIER_WHITE));
O.frame.SearchButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
O.frame.SearchButton:SetScript('OnClick', function(self)
    self:Hide();
    O.frame.SearchEditbox:Show();
    O.frame.SearchEditbox:SetFocus();
end);

O.frame.SearchEditbox = E.CreateEditBox(O.frame.TopBar);
O.frame.SearchEditbox:SetPosition('LEFT', O.frame.TopBar, 'LEFT', 11, 0);
O.frame.SearchEditbox:SetSize(184, 30);
O.frame.SearchEditbox:Hide();
O.frame.SearchEditbox.Background:SetBackdropColor(0.075, 0.075, 0.075, 1);
O.frame.SearchEditbox:SetTextInsets(4, 20, 0, 0);
O.frame.SearchEditbox:HookScript('OnEnterPressed', function(self)
    self:Hide();
    O.frame.SearchButton:Show();
end);

O.frame.SearchEditbox:HookScript('OnEditFocusGained', function(self)
    Search:Find(self, self:GetText());
end);

O.frame.SearchEditbox:SetScript('OnEditFocusLost', function(self)
    self.isFocused = false;

    EditBox_ClearHighlight(self);
    self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

    if searchFrame:IsMouseOver() or O.frame.CloseSearchEditbox:IsMouseOver() then
        return;
    end

    self:Hide();
    O.frame.SearchButton:Show();
end);

O.frame.SearchEditbox.ShowButton = O.frame.SearchButton;

searchFrame:SetParent(O.frame.SearchEditbox);
searchFrame:SetFrameLevel(100);
searchFrame:SetPosition('TOPLEFT', O.frame.SearchEditbox.Background, 'BOTTOMLEFT', 0, 0);
searchFrame:SetPosition('TOPRIGHT', O.frame.SearchEditbox.Background, 'BOTTOMRIGHT', 0, 0);

O.frame.SearchEditbox:HookScript('OnTextChanged', function(self)
    Search:Find(self, self:GetText());
end);

O.frame.SearchEditbox:HookScript('OnTabPressed', function(self)
    Search:TabHandling(self);
end);

O.frame.SearchEditbox:HookScript('OnKeyDown', function(self, key)
    Search:KeyHandling(self, key);
end);

O.frame.SearchEditbox:HookScript('OnEnterPressed', function(self)
    Search:EnterHandling(self);
end);


O.frame.CloseSearchEditbox = Mixin(CreateFrame('Button', nil, O.frame.SearchEditbox), E.PixelPerfectMixin);
O.frame.CloseSearchEditbox:SetPosition('RIGHT', O.frame.SearchEditbox, 'RIGHT', -4, 0);
O.frame.CloseSearchEditbox:SetSize(14, 14);
O.frame.CloseSearchEditbox:SetNormalTexture(S.Media.Icons.TEXTURE);
O.frame.CloseSearchEditbox:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CROSS_WHITE));
O.frame.CloseSearchEditbox:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
O.frame.CloseSearchEditbox:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
O.frame.CloseSearchEditbox:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CROSS_WHITE));
O.frame.CloseSearchEditbox:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
O.frame.CloseSearchEditbox:SetScript('OnClick', function()
    O.frame.SearchEditbox:Hide();
    O.frame.SearchEditbox:SetText('');
    O.frame.SearchButton:Show();
end);

O.frame.Main = Mixin(CreateFrame('Frame', nil, O.frame.TopBar, 'BackdropTemplate'), E.PixelPerfectMixin);
O.frame.Main:SetPosition('TOPLEFT', O.frame.TopBar, 'BOTTOMLEFT', 0, 0);
O.frame.Main:SetPosition('BOTTOMRIGHT', O.frame, 'BOTTOMRIGHT', 0, 0);
O.frame.Main:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
O.frame.Main:SetBackdropColor(0.1, 0.1, 0.1, 1);

O.frame.Left = Mixin(CreateFrame('Frame', nil, O.frame.Main, 'BackdropTemplate'), E.PixelPerfectMixin);
O.frame.Left:SetPosition('TOPLEFT', O.frame.Main, 'TOPLEFT', 0, 0);
O.frame.Left:SetPosition('BOTTOMLEFT', O.frame.Main, 'BOTTOMLEFT', 0, 0);
O.frame.Left:SetW(200);
O.frame.Left:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
O.frame.Left:SetBackdropColor(0.075, 0.075, 0.075, 1);

O.frame.Right = Mixin(CreateFrame('Frame', nil, O.frame.Main, 'BackdropTemplate'), E.PixelPerfectMixin);
O.frame.Right:SetPosition('TOPLEFT', O.frame.Left, 'TOPRIGHT', 0, 0);
O.frame.Right:SetPosition('BOTTOMLEFT', O.frame.Left, 'BOTTOMRIGHT', 0, 0);
O.frame.Right:SetW(600);

local panels = {};

O.CreateTab = function(parentPanel, name, text, callback)
    local tab = Mixin(CreateFrame('Button', '$parent_Tab_' .. name, parentPanel), E.PixelPerfectMixin);

    tab:SetNormalFontObject('StripesOptionsTabGreyedFont');
    tab:SetHighlightFontObject('StripesOptionsTabHighlightFont');

    tab:SetText(text);

    if text ~= '' then
        tab:SetSize(tonumber(tab:GetTextWidth()) + 16, 22);
    else
        tab:SetSize(25, 22);
    end

    tab.BottomLine = Mixin(tab:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    tab.BottomLine:SetPosition('TOPLEFT', tab, 'BOTTOMLEFT', 0, 0);
    tab.BottomLine:SetPosition('TOPRIGHT', tab, 'BOTTOMRIGHT', 0, 0);
    tab.BottomLine:SetH(2);
    tab.BottomLine:SetTexture('Interface\\Buttons\\WHITE8x8');
    tab.BottomLine:SetVertexColor(0.75, 0.75, 0.75);

    tab:SetScript('OnClick', function(self)
        for _, t in ipairs(parentPanel.Tabs) do
            t:UnlockHighlight();
            t.BottomLine:SetVertexColor(0.75, 0.75, 0.75);
            t.Content:Hide();
        end

        self:LockHighlight();
        self.BottomLine:SetVertexColor(1, 0.85, 0);
        self.Content:Show();

        parentPanel.tabClicked = true;

        S:GetModule('Options_Colors'):HideListFrame();
    end);

    if callback then
        tab:HookScript('OnClick', callback);
    end

    tab.Content = Mixin(CreateFrame('Frame', nil, tab), E.PixelPerfectMixin);
    tab.Content:SetPosition('TOPLEFT', parentPanel.TabsHolder, 'BOTTOMLEFT', 0, 0);
    tab.Content:SetPosition('BOTTOMRIGHT', parentPanel, 'BOTTOMRIGHT', 0, 0);
    tab.Content:Hide();

    table.insert(parentPanel.Tabs, tab);

    return tab;
end

O.CreateRightPanel = function(name)
    local panel = Mixin(CreateFrame('Frame', 'Stripes_Options_Right_' .. name, O.frame.Right), E.PixelPerfectMixin);
    panel:SetPosition('TOPLEFT', O.frame.Right, 'TOPLEFT', 6, -6);
    panel:SetPosition('BOTTOMRIGHT', O.frame.Right, 'BOTTOMRIGHT', -6, 6);

    panel.Tabs = {};
    panel.TabsFrames = {};
    panel.TabsData = {};

    panel.CreateTabs = function(self)
        self.TabsHolder = Mixin(CreateFrame('Frame', nil, self), E.PixelPerfectMixin);
        self.TabsHolder:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
        self.TabsHolder:SetPosition('TOPRIGHT', self, 'TOPRIGHT', 0, 0);
        self.TabsHolder:SetH(30);

        for i, data in ipairs(panel.TabsData) do
            self.TabsFrames[data.name] = O.CreateTab(self, data.name, data.title);

            if i == 1 then
                self.TabsFrames[data.name]:SetPosition('TOPLEFT', self.TabsHolder, 'TOPLEFT', 0, 0);
            else
                self.TabsFrames[data.name]:SetPosition('LEFT', self.TabsFrames[panel.TabsData[i - 1].name], 'RIGHT', 6, 0);
            end
        end
    end

    panel:Hide();

    return panel;
end

O.ShowRightPanel = function(panel)
    if not panel:IsShown() then
        panel:Show();

        if panel.OnShow then
            panel:OnShow();
        end

        if not panel.wasShowedOnce and panel.OnShowOnce then
            panel:OnShowOnce();
            panel.wasShowedOnce = true;
        end
    end
end

O.HideRightPanel = function(panel)
    if panel:IsShown() then
        panel:Hide();

        if panel.OnHide then
            panel:OnHide();
        end
    end
end

O.HideAllPanels = function()
    for _, panel in pairs(panels) do
        O.HideRightPanel(panel);
    end
end

O.ClearLeftHighlight = function()
    for _, v in pairs(O.frame.Left) do
        if type(v) == 'table' and v.SetNormalFontObject and v.Background and not v.isDisabled then
            v:UnlockHighlight();
            v.Background:Hide();
        end
    end
end

O.CreateLeftButton = function(text, name, order, panel, hideButton)
    local button = Mixin(CreateFrame('Button', 'Stripes_Options_Left_' .. name, O.frame.Left), E.PixelPerfectMixin);
    button:SetPosition('TOPLEFT', O.frame.Left, 'TOPLEFT', 0, -(28*order-28));
    button:SetSize(O.frame.config.width * 1/4, 28);

    if hideButton then
        button:Hide();
    end

    button:SetNormalFontObject('StripesCategoryButtonNormalFont');
    button:SetHighlightFontObject('StripesCategoryButtonHighlightFont');

    text = string.gsub(text, '(:%d+|)T', '%1t');
    button:SetText('   ' .. text);

    button.Background = button:CreateTexture(nil, 'BACKGROUND');
    button.Background:SetAllPoints();
    button.Background:SetColorTexture(1, 1, 1, 1);
    button.Background:SetGradient('HORIZONTAL', CreateColor(0.9, 0.9, 0.9, 1), CreateColor(0.1, 0.1, 0.1, 1));
    button.Background:Hide();

    button:SetScript('OnClick', function(self)
        O.ClearLeftHighlight();
        O.HideAllPanels();

        self:LockHighlight();
        self.Background:Show();

        if panel.Tabs and panel.Tabs[1] and not panel.tabClicked then
            panel.Tabs[1]:Click();
        end

        O.ShowRightPanel(panel);

        S:GetModule('Options_Colors'):HideListFrame();

        if self.Callback then
            self:Callback();
        end
    end);

    return button;
end

O.RegisterPanel = function(name, panel)
    if not panels[name] then
        panels[name] = panel;

        return panel;
    end
end

O.CreateCategory = function(title, name, order, hideButton)
    local panel = O.CreateRightPanel(name);
    local button = O.CreateLeftButton(title, name, order, panel, hideButton);

    O.RegisterPanel(name, panel);

    return button, panel;
end

O.GetPanel = function(name)
    return panels[string.lower(name)] or error('Invalid panel name: ' .. name);
end

O.LoadPanelAll = function()
    for _, panel in pairs(panels) do
        if #panel.TabsData > 0 then
            panel:CreateTabs();
        end

        if panel.Load then
            panel:Load();
        end
    end
end

O.UpdatePanel = function(panel)
    for name, option in pairs(panel) do
        if option ~= 0 and option ~= '0' and type(option) == 'table' then
            if O.db[name] ~= nil then
                if option.type == 'CheckButton' then
                    option:SetChecked(O.db[name]);

                    if option.Callback then
                        option:Callback();
                    end
                elseif option.type == 'EditBox' then
                    option:SetText(O.db[name]);

                    if option.Callback then
                        option:Callback();
                    end
                elseif option.type == 'Slider' then
                    option:SetValue(tonumber(O.db[name]));
                elseif option.type == 'DropDown' then
                    if option.subType == 'number' then
                        option:SetValue(tonumber(O.db[name]));
                    elseif option.subType == 'string' then
                        option:SetValue(tostring(O.db[name]));
                    end
                elseif option.type == 'ColorPicker' then
                    option:SetValue(unpack(O.db[name]));
                end
            end
        end
    end
end

O.UpdatePanelAll = function()
    if U.PlayerInCombat() then
        return;
    end

    for _, panel in pairs(panels) do
        O.UpdatePanel(panel);

        if panel.Update then
            panel:Update();
        end
    end
end

O.NeedReload = function(name, need)
    needReloadTable[name] = need;

    isNeedReload = false;

    for _, value in pairs(needReloadTable) do
        if value then
            isNeedReload = true;
            break;
        end
    end

    if isNeedReload then
        StaticPopup_Show('STRIPES_OPTIONS_NEED_RELOAD');
    else
        StaticPopup_Hide('STRIPES_OPTIONS_NEED_RELOAD');
    end
end

function Module:PLAYER_LOGIN()
    if StripesDB.optionsPosition and #StripesDB.optionsPosition > 1 then
        O.frame:ClearAllPoints();
        O.frame:SetPosition(StripesDB.optionsPosition[1], UIParent, StripesDB.optionsPosition[3], StripesDB.optionsPosition[4], StripesDB.optionsPosition[5]);
        O.frame:SetUserPlaced(true);
    end
end

function Module:PLAYER_REGEN_ENABLED()
    if wasHidedInCombat then
        if not O.frame:IsShown() then
            wasHidedInCombat = false;
            O.OpenOptions();
        end
    end
end

function Module:PLAYER_REGEN_DISABLED()
    if O.frame:IsShown() then
        O.CloseOptions();
        U.Print(L['OPTIONS_HIDED_IN_COMBAT']);

        wasHidedInCombat = true;
        wasNotified = true;
    end
end

function Module:StartUp()
    StripesDB.optionsPosition = StripesDB.optionsPosition or {};

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_REGEN_ENABLED');
    self:RegisterEvent('PLAYER_REGEN_DISABLED');

    O.LoadPanelAll();

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);
end