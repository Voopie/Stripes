local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('Options_Search');

-- Lua API
local string_find, string_lower = string.find, string.lower;

local LCG = S.Libraries.LCG;

local USE_FUZZY = true; -- very good but too much garbage...
local MAX_NUM_RESULTS = 5;
local GLOW_TIME_SECONDS = 5;
local BUTTON_HEIGHT = 28;

local glowColor = { 1, 0.33, 0 };

local searchIndex = {};
local frame;
local buttons = {};

Module.numResults = 0;

function Module:GetList()
    return searchIndex;
end

function Module:FindLocString(str)
    for name, text in pairs(L) do
        if text == str then
            return name;
        end
    end
end

function Module:AddOption(option, button, tab)
    if not option.SearchText then
        error('Search.AddOption: option.SearchText not found!');
    end

    if searchIndex[option.SearchText] then
        error('Search.AddOption: field '.. option.SearchText .. ' already exists!');
    end

    local index = self:FindLocString(option.SearchText);
    if not index then
        error('Search.AddOption: unknown string "'.. option.SearchText .. '"');
    end

    searchIndex[index] = function()
        O.ExpandOptions();

        button:Click();

        if tab then
            tab:Click();
        end

        if option.Glow then
            LCG.PixelGlow_Start(option.Glow, glowColor, 10, nil, 8, 2, 1, 1);

            C_Timer.After(GLOW_TIME_SECONDS, function()
                LCG.PixelGlow_Stop(option.Glow);
            end);
        end
    end
end

function Module:GetFrame()
    if not frame then
        frame = Mixin(CreateFrame('Frame', nil, UIParent, 'BackdropTemplate'), E.PixelPerfectMixin);
        frame:SetBackdrop({
            bgFile = 'Interface\\Buttons\\WHITE8x8',
            insets = { top = 0, left = 0, bottom = 0, right = 0 },
        });
        frame:SetBackdropColor(0, 0, 0, 1);
        frame:Hide();

        frame.buttonPool = CreateFramePool('Button', frame, 'BackdropTemplate');
    end

    return frame;
end

function Module:ShowFrame()
    if not frame then
        return;
    end

    frame:Show();
end

function Module:HideFrame()
    if not frame then
        return;
    end

    frame:Hide();
end

function Module:UpdateFrameSize()
    if not frame then
        return;
    end

    frame:SetHeight(#buttons * BUTTON_HEIGHT);

    for button, _ in frame.buttonPool:EnumerateActive() do
        PixelUtil.SetWidth(button, frame:GetWidth());
        PixelUtil.SetWidth(button.Text, frame:GetWidth());
    end
end

function Module:EnterHandling()
    for i = 1, #buttons do
        if buttons[i].selected then
            buttons[i]:Click();
            return;
        end
    end
end

function Module:TabHandling(editbox)
    if #buttons <= 0 then
        return;
    end

    editbox.tabIndex = editbox.tabIndex or 0;

    if IsShiftKeyDown() then
        editbox.tabIndex = editbox.tabIndex - 1;
    else
        editbox.tabIndex = editbox.tabIndex + 1;
    end

    if editbox.tabIndex <= 0 then
        editbox.tabIndex = #buttons;
    elseif editbox.tabIndex > #buttons then
        editbox.tabIndex = 1;
    end

    buttons[editbox.tabIndex]:SetFocus();
end

function Module:KeyHandling(editbox, key)
    if key ~= 'UP' and key ~= 'DOWN' and key ~= 'RIGHT' then
        return;
    end

    if #buttons <= 0 then
        return;
    end

    editbox.tabIndex = editbox.tabIndex or 0;

    if key == 'UP' then
        editbox.tabIndex = editbox.tabIndex - 1;
    elseif key == 'DOWN' then
        editbox.tabIndex = editbox.tabIndex + 1;
    else
        self:EnterHandling();
    end

    if editbox.tabIndex <= 0 then
        editbox.tabIndex = #buttons;
    elseif editbox.tabIndex > #buttons then
        editbox.tabIndex = 1;
    end

    buttons[editbox.tabIndex]:SetFocus();
end

function Module:AddButton(name, func, editbox)
    if not frame then
        return;
    end

    local button, isNew = frame.buttonPool:Acquire();

    table.insert(buttons, button);

    button:ClearAllPoints();

    if self.numResults == 1 then
        PixelUtil.SetPoint(button, 'TOPLEFT', frame, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(button, 'TOPRIGHT', frame, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(button, 'TOPLEFT', buttons[self.numResults - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(button, 'TOPRIGHT', buttons[self.numResults - 1], 'BOTTOMRIGHT', 0, 0);
    end

    if isNew then
        button:SetBackdrop({
            bgFile = 'Interface\\Buttons\\WHITE8x8',
            insets = { top = 0, left = 0, bottom = 0, right = 0 },
        });
        button:SetBackdropColor(0.1, 0.1, 0.1, 1);

        button.Text = button:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight');
        PixelUtil.SetPoint(button.Text, 'LEFT', button, 'LEFT', 8, 0);
        PixelUtil.SetPoint(button.Text, 'RIGHT', button, 'RIGHT', -22, 0);
        button.Text:SetJustifyH('LEFT');
        button.Text:SetJustifyV('MIDDLE');

        button.Arrow = button:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(button.Arrow, 'RIGHT', button, 'RIGHT', -4, 0);
        button.Arrow:SetTexture(S.Media.Icons.TEXTURE);
        button.Arrow:SetTexCoord(unpack(S.Media.Icons.COORDS.ARROW_DOWN_WHITE));
        button.Arrow:SetRotation(math.rad(90));
        button.Arrow:Hide();

        button.BottomLine = button:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(button.BottomLine, 'BOTTOMLEFT', button, 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(button.BottomLine, 'BOTTOMRIGHT', button, 'BOTTOMRIGHT', 0, 0);
        PixelUtil.SetHeight(button.BottomLine, 1);
        button.BottomLine:SetTexture('Interface\\Buttons\\WHITE8x8');
        button.BottomLine:SetVertexColor(0.3, 0.3, 0.3);

        button.LeftLine = button:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(button.LeftLine, 'TOPLEFT', button, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(button.LeftLine, 'BOTTOMLEFT', button, 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetWidth(button.LeftLine, 1);
        button.LeftLine:SetTexture('Interface\\Buttons\\WHITE8x8');
        button.LeftLine:SetVertexColor(0.3, 0.3, 0.3);

        button.RightLine = button:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(button.RightLine, 'TOPRIGHT', button, 'TOPRIGHT', 0, 0);
        PixelUtil.SetPoint(button.RightLine, 'BOTTOMRIGHT', button, 'BOTTOMRIGHT', 0, 0);
        PixelUtil.SetWidth(button.RightLine, 1);
        button.RightLine:SetTexture('Interface\\Buttons\\WHITE8x8');
        button.RightLine:SetVertexColor(0.3, 0.3, 0.3);

        button.ClearFocus = function(self)
            self.selected = false;
            self:SetBackdropColor(0.1, 0.1, 0.1, 1);
            self.Arrow:Hide();
        end

        button.SetFocus = function(self)
            for i = 1, #buttons do
                buttons[i]:ClearFocus();
            end

            self.selected = true;
            self:SetBackdropColor(0.45, 0.45, 0.5, 1);
            self.Arrow:Show();
        end

        button:HookScript('OnEnter', function(self)
            self:SetFocus();

            if editbox then
                editbox.tabIndex = 0;
            end
        end);

        button:HookScript('OnLeave', function(self)
            self:ClearFocus();
        end);
    end

    button:SetScript('OnClick', function()
        frame:Hide();
        func();

        editbox:ClearFocus();
        editbox:Hide();

        if editbox.ShowButton then
            editbox.ShowButton:Show();
        end
    end);

    PixelUtil.SetHeight(button, BUTTON_HEIGHT);
    PixelUtil.SetHeight(button.Text, BUTTON_HEIGHT);
    PixelUtil.SetSize(button.Arrow, BUTTON_HEIGHT / 1.5, BUTTON_HEIGHT / 1.5);
    button.Text:SetText(name);

    button:ClearFocus();
    button:Show();
end

function Module:ClearSearchData(editbox)
    self.numResults = 0;

    wipe(buttons);
    editbox.tabIndex = 0;
    frame.buttonPool:ReleaseAll();
end

function Module:PerformExactSearch(searchString, editbox)
    for name, func in pairs(self:GetList()) do
        if L[name] and string_find(string_lower(L[name]), searchString, 1, true) then
            self.numResults = self.numResults + 1;

            self:AddButton(L[name], func, editbox);

            if self.numResults == MAX_NUM_RESULTS then
                break;
            end
        end
    end
end

local prepareFuzzy = {};

local function GetFuzzyCallback(searchString)
    for name, func in pairs(searchIndex) do
        if L[name] == searchString then
            return func;
        end
    end
end

function Module:PerformFuzzySearch(searchString, editbox)
    wipe(prepareFuzzy);

    for name, _ in pairs(self:GetList()) do
        if L[name] then
            table.insert(prepareFuzzy, L[name]);
        end
    end

    local filtered = FZY.filter(searchString, prepareFuzzy);
    table.sort(filtered, function(a, b) return a[3] > b[3]; end);

    for _, result in ipairs(filtered) do
        self.numResults = self.numResults + 1;

        self:AddButton(prepareFuzzy[result[1]], GetFuzzyCallback(prepareFuzzy[result[1]]), editbox);

        if self.numResults == MAX_NUM_RESULTS then
            break;
        end
    end
end

function Module:Find(editbox, searchString)
    assert(type(searchString) == 'string', string.format('bad argument to %s (string expected, got %s)', 'Find', type(searchString)));
    searchString = string_lower(searchString);

    self:ClearSearchData(editbox);

    if strlenutf8(searchString) > 2 then
        if USE_FUZZY then
            self:PerformFuzzySearch(searchString, editbox);
        else
            self:PerformExactSearch(searchString, editbox);
        end
    end

    if self.numResults > 0 then
        self:UpdateFrameSize();
        self:ShowFrame();
    else
        self:HideFrame();
    end
end

