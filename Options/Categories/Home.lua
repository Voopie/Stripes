local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Home');

O.frame.Left.Home, O.frame.Right.Home = O.CreateCategory('', 'home', 0, true);
local panel = O.frame.Right.Home;

local MAX_BUTTONS = 15;
local BUTTON_HEIGHT = 20;

local buttons = {};

local function CreateButton(button)
    button:RegisterForClicks('LeftButtonUp', 'RightButtonUp');

    button.Text = Mixin(button:CreateFontString(nil, 'ARTWORK', 'StripesOptionsTabGreyedFont'), E.PixelPerfectMixin);
    button.Text:SetPosition('LEFT', button, 'LEFT', 0, 0);
    button.Text:SetPosition('RIGHT', button, 'RIGHT', 0, 0);
    button.Text:SetH(BUTTON_HEIGHT);
    button.Text:SetJustifyH('LEFT');
    button.Text:SetJustifyV('MIDDLE');

    button.Icon = Mixin(button:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    button.Icon:SetPosition('RIGHT', button, 'RIGHT', 0, 0);
    button.Icon:SetSize(14, 14);
    button.Icon:SetTexture(S.Media.Icons.TEXTURE);
    button.Icon:SetTexCoord(unpack(S.Media.Icons.COORDS.NEW_WINDOW_WHITE));
    button.Icon:SetVertexColor(0.75, 0.75, 0.75);
    button.Icon:Hide();

    button.BottomLine = Mixin(button:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    button.BottomLine:SetPosition('TOPLEFT', button, 'BOTTOMLEFT', 0, 0);
    button.BottomLine:SetPosition('TOPRIGHT', button, 'BOTTOMRIGHT', 0, 0);
    button.BottomLine:SetH(2);
    button.BottomLine:SetTexture('Interface\\Buttons\\WHITE8x8');
    button.BottomLine:SetVertexColor(0.75, 0.75, 0.75);

    button:SetScript('OnClick', function(self, b)
        if b == 'LeftButton' then
            local callback = S:GetModule('Options_Search'):GetList()[self.name];
            if callback then
                callback();
            end
        elseif b == 'RightButton' then
            StripesDB.freqUsed[self.name] = nil;
            panel.UpdateButtons();
        end
    end);

    button:SetScript('OnEnter', function(self)
        self:SetSize(math.min(panel:GetWidth() - 38, self.Text:GetStringWidth()) + 20, BUTTON_HEIGHT);

        self.Text:SetFontObject('StripesOptionsTabHighlightFont');
        self.Text:SetPosition('RIGHT', self.Icon, 'LEFT', 0, 0);

        self.Icon:Show();
        self.Icon:SetVertexColor(1, 0.4, 0.4);

        self.BottomLine:SetVertexColor(1, 0.4, 0.4);

        if self.Text:IsTruncated() then
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
            GameTooltip:AddLine(L[self.name], 1, 0.85, 0, true);
            GameTooltip:Show();
        end
    end);

    button:SetScript('OnLeave', function(self)
        self:SetSize(math.min(panel:GetWidth() - 18, self.Text:GetStringWidth()) - 0.5, BUTTON_HEIGHT);

        self.Text:SetFontObject('StripesOptionsTabGreyedFont');
        self.Text:SetPosition('RIGHT', self, 'RIGHT', 0, 0);

        self.Icon:Hide();
        self.Icon:SetVertexColor(0.75, 0.75, 0.75);

        self.BottomLine:SetVertexColor(0.75, 0.75, 0.75);

        GameTooltip_Hide();
    end);
end

local function UpdateButton(button)
    if button.index == 1 then
        PixelUtil.SetPoint(button, 'TOPLEFT', panel, 'TOPLEFT', 6, -2);
    else
        PixelUtil.SetPoint(button, 'TOPLEFT', buttons[button.index - 1], 'BOTTOMLEFT', 0, -14);
    end

    local text = L[button.name];

    text = string.upper(text);
    text = string.gsub(text, '(:%d+|)T', '%1t');
    text = string.gsub(text, '(:%d+|)N', '%1n');
    text = string.gsub(text, '(:%d+|)C', '%1c');

    text = strsplit('|n', text);

    button.Text:SetText(text);
    button:SetSize(math.min(panel:GetWidth() - 18, button.Text:GetStringWidth()) - 0.5, BUTTON_HEIGHT);
end

local sorted = {};
panel.UpdateButtons = function()
    wipe(buttons);
    wipe(sorted);

    panel.buttonPool:ReleaseAll();

    local index = 0;
    local button, isNew;
    local searchIndex = S:GetModule('Options_Search'):GetList();

    for name, data in pairs(StripesDB.freqUsed) do
        table.insert(sorted, {name = name, count = data.count});
    end

    table.sort(sorted, function(a, b)
        return a.count > b.count;
    end);

    for _, data in ipairs(sorted) do
        if index == MAX_BUTTONS then
            break;
        end

        if searchIndex[data.name] then
            index = index + 1;

            button, isNew = panel.buttonPool:Acquire();

            table.insert(buttons, button);

            if isNew then
                CreateButton(button);
            end

            button.index = index;
            button.name  = data.name;

            UpdateButton(button);

            button:Show();
        end
    end

    panel.FreqUsedOptionsTip:SetShown(index == 0);
    panel.ResetButton:SetShown(index > 0);
    panel.EXmarkButton:SetShown(index > 0);
end

panel.Load = function(self)
    self.buttonPool = CreateFramePool('Button', self, 'BackdropTemplate');

    self.FreqUsedOptionsTip = Mixin(self:CreateFontString(nil, 'ARTWORK'), E.PixelPerfectMixin);
    self.FreqUsedOptionsTip:SetPosition('TOPLEFT', self, 'TOPLEFT', 10, 20);
    self.FreqUsedOptionsTip:SetPosition('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -10, 0);
    self.FreqUsedOptionsTip:SetFont(S.Media.Fonts['BigNoodleToo Oblique'], 36, 'OUTLINE');
    self.FreqUsedOptionsTip:SetJustifyH('CENTER');
    self.FreqUsedOptionsTip:SetTextColor(0.8, 0.8, 0.8);
    self.FreqUsedOptionsTip:SetText(L['OPTIONS_HOME_FREQUENTLY_USED_OPTIONS_TIP']);

    self.EXmarkButton = Mixin(CreateFrame('Button', nil, self), E.PixelPerfectMixin);
    self.EXmarkButton:SetPosition('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, 0);
    self.EXmarkButton:SetSize(16, 16);
    self.EXmarkButton:SetNormalTexture(S.Media.Icons64.TEXTURE);
    self.EXmarkButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons64.COORDS.EXMARK_WHITE));
    self.EXmarkButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    self.EXmarkButton:SetHighlightTexture(S.Media.Icons64.TEXTURE, 'BLEND');
    self.EXmarkButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons64.COORDS.EXMARK_WHITE));
    self.EXmarkButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    self.EXmarkButton:Hide();
    self.EXmarkButton:SetScript('OnEnter', function(self)
        self.Text:Show();
    end);
    self.EXmarkButton:SetScript('OnLeave', function(self)
        self.Text:Hide();
    end);

    self.EXmarkButton.Text = Mixin(self.EXmarkButton:CreateFontString(nil, 'ARTWORK'), E.PixelPerfectMixin);
    self.EXmarkButton.Text:SetPosition('LEFT', self.EXmarkButton, 'RIGHT', 8, 0);
    self.EXmarkButton.Text:SetFont(S.Media.Fonts['Systopie Semi Bold Italic'], 12, 'OUTLINE');
    self.EXmarkButton.Text:SetTextColor(0.85, 0.85, 0.85);
    self.EXmarkButton.Text:SetText(L['OPTIONS_HOME_DELETE_TIP']);
    self.EXmarkButton.Text:Hide();

    self.ResetButton = E.CreateButton(self);
    self.ResetButton:SetPosition('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0);
    self.ResetButton:SetLabel(L['OPTIONS_RESET']);
    self.ResetButton:Hide();
    self.ResetButton:SetScript('OnClick', function()
        wipe(StripesDB.freqUsed);
        panel.UpdateButtons();
    end);
end

panel.OnShow = function(self)
    self.UpdateButtons();
end