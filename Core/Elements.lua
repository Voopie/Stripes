local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Elements');

local MEDIA_PATH = 'Interface\\AddOns\\' .. S.AddonName .. '\\Media\\';

local LSM = S.Libraries.LSM;
local LCG = S.Libraries.LCG;

local function AddToSearch(self, button, searchText, tab)
    if searchText then
        self.SearchText = searchText;
    end

    S:GetModule('Options_Search'):AddOption(self, button, tab);
end

local function AddToFreqUsed(self, searchText)
    searchText = searchText or self.SearchText;

    if not searchText then
        return;
    end

    local index = S:GetModule('Options_Search'):FindLocString(searchText);
    if not index then
        return;
    end

    StripesDB.freqUsed[index]       = StripesDB.freqUsed[index] or {};
    StripesDB.freqUsed[index].count = StripesDB.freqUsed[index].count or 0;
    StripesDB.freqUsed[index].count = StripesDB.freqUsed[index].count + 1;
end

E.PixelPerfectMixin = {
    SetPosition = function(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
        PixelUtil.SetPoint(self, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels);
    end,

    SetSize = function(self, width, height)
        PixelUtil.SetSize(self, width, height);
    end,

    SetW = function(self, width)
        PixelUtil.SetWidth(self, width);
    end,

    SetH = function(self, height)
        PixelUtil.SetHeight(self, height);
    end
};

E.CreateTooltip = function(frame, tooltip, anchor, noWrap)
    if not frame then
        return;
    end

    frame.tooltip = tooltip;

    frame:HookScript('OnEnter', function(self)
        if not self.tooltip then
            return;
        end

        GameTooltip:SetOwner(self, anchor or 'ANCHOR_RIGHT');

        if noWrap then
            GameTooltip:AddLine(self.tooltip, 1, 0.85, 0, nil);
        else
            GameTooltip:AddLine(self.tooltip, 1, 0.85, 0, true);
        end

        GameTooltip:Show();
    end);

    frame:HookScript('OnLeave', GameTooltip_Hide);
end

E.CreateFontString = function(parent, layer, template)
    layer    = layer    or 'ARTWORK';
    template = template or 'StripesOptionsHighlightFont';

    local frame = Mixin(CreateFrame('Frame', nil, parent), E.PixelPerfectMixin);
    local fontString = Mixin(frame:CreateFontString(nil, layer, template), E.PixelPerfectMixin);
    fontString:SetAllPoints(frame);

    frame.Text = fontString;

    frame.Glow = Mixin(CreateFrame('Frame', nil, frame), E.PixelPerfectMixin);
    frame.Glow:SetAllPoints();

    frame:HookScript('OnEnter', function(self)
        LCG.PixelGlow_Stop(self.Glow);
    end);

    frame.AddToSearch = AddToSearch;

    frame.SetText = function(self, text)
        self.Text:SetText(text);
        self:SetSize(self.Text:GetStringWidth() + 6, 18);
    end

    frame.SetFontObject = function(self, fontObject)
        self.Text:SetFontObject(fontObject);
        self:SetSize(self.Text:GetStringWidth() + 6, 18);
    end

    return frame;
end

do
    local BUTTON_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    E.CreateButton = function(parent)
        local b = Mixin(CreateFrame('Button', nil, parent, 'BackdropTemplate'), E.PixelPerfectMixin);

        b:SetNormalFontObject('StripesOptionsButtonNormalFont');
        b:SetHighlightFontObject('StripesOptionsButtonHighlightFont');

        b:SetBackdrop(BUTTON_BACKDROP);

        b.Glow = Mixin(CreateFrame('Frame', nil, b), E.PixelPerfectMixin);
        b.Glow:SetPosition('TOPLEFT', b, 'TOPLEFT', -2, 2);
        b.Glow:SetPosition('BOTTOMRIGHT', b, 'BOTTOMRIGHT', 2, -2);

        b.NormalColor    = { U.HEX2RGB('404040') };
        b.HighlightColor = { U.HEX2RGB('A74DFF') };

        b.SetLabel = function(self, label)
            label = string.gsub(label, '(:%d+|)T', '%1t');

            self:SetText(string.upper(label));
            self:SetSize(self:GetTextWidth() + 16, 22);

            self.SearchText = label;
        end

        b.SetNormalColor = function(self, hexColor)
            self.NormalColor = { U.HEX2RGB(hexColor) };
        end

        b.SetHighlightColor = function(self, hexColor)
            self.HighlightColor = { U.HEX2RGB(hexColor) };
        end

        b:SetBackdropColor(unpack(b.NormalColor));
        b:SetBackdropBorderColor(0.3, 0.3, 0.33, 1);

        b.OnLeave = function(self)
            self:SetBackdropColor(unpack(self.NormalColor));
        end

        b:HookScript('OnEnter', function(self)
            if self.isLocked then
                return;
            end

            self:SetBackdropColor(unpack(self.HighlightColor));
            self:SetHighlightFontObject('StripesOptionsButtonHighlightFont');
            LCG.PixelGlow_Stop(self.Glow);
        end);

        b:HookScript('OnLeave', function(self)
            if self.isLocked then
                return;
            end

            self:SetBackdropColor(unpack(self.NormalColor));
        end);

        b:SetScript('OnMouseDown', function(self)
            if self.isLocked then
                return;
            end

            if self:IsEnabled() then
                self:SetBackdropColor(unpack(self.HighlightColor));

                self.OnLeavePrev = self:GetScript('OnLeave');
                self:SetScript('OnLeave', nil);

                if U.CanAccessObject(GameTooltip) and GameTooltip:IsShown() then
                    GameTooltip_Hide();
                end

                self:SetNormalFontObject('StripesOptionsButtonHighlightFont');
                self:SetHighlightFontObject('StripesOptionsButtonHighlightFont');
            end
        end);

        b:SetScript('OnMouseUp', function(self)
            if self.isLocked then
                return;
            end

            if self:IsEnabled() then
                self:SetNormalFontObject('StripesOptionsButtonNormalFont');
                self:SetHighlightFontObject('StripesOptionsButtonNormalFont');

                self:SetBackdropColor(unpack(self.NormalColor));

                self:SetScript('OnLeave', self.OnLeavePrev or self.OnLeave);

                if self:IsMouseOver() then
                    self:GetScript('OnEnter')(self);
                end
            end
        end);

        hooksecurefunc(b, 'LockHighlight', function(self)
            self.isLocked = true;
            self:SetNormalFontObject('StripesOptionsButtonHighlightFont');
            self:SetHighlightFontObject('StripesOptionsButtonHighlightFont');
            self:SetBackdropColor(unpack(self.HighlightColor));
        end);

        hooksecurefunc(b, 'UnlockHighlight', function(self)
            self.isLocked = false;
            self:SetNormalFontObject('StripesOptionsButtonNormalFont');
            self:SetHighlightFontObject('StripesOptionsButtonNormalFont');
            self:SetBackdropColor(unpack(self.NormalColor));
        end);

        b.AddToSearch = AddToSearch;

        b.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        E.CreateTooltip(b);

        return b;
    end
end

E.CreateCheckButton = function(parent)
    local b = Mixin(CreateFrame('CheckButton', nil, parent), E.PixelPerfectMixin);
    b:SetHitRectInsets(0, 0, 0, 0);

    b.Label = b:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    PixelUtil.SetPoint(b.Label, 'LEFT', b, 'RIGHT', 4, 0);
    PixelUtil.SetHeight(b.Label, 12);
    b.Label:SetJustifyH('LEFT');

    b.Glow = Mixin(CreateFrame('Frame', nil, b), E.PixelPerfectMixin);
    b.Glow:SetAllPoints();

    b:SetNormalTexture(S.Media.Icons.TEXTURE);
    b:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKBOX_EMPTY));
    b:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    b:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKBOX_EMPTY));
    b:GetHighlightTexture():SetVertexColor(1, 0.85, 0);
    b:SetCheckedTexture(S.Media.Icons.TEXTURE, 'BLEND');
    b:GetCheckedTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKBOX_CHECKED));
    b:SetDisabledCheckedTexture(S.Media.Icons.TEXTURE, 'BLEND');
    b:GetDisabledCheckedTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKBOX_CHECKED));
    b:GetDisabledCheckedTexture():SetVertexColor(0.1, 0.1, 0.1);

    b.SetLabel = function(self, label)
        self.Label:SetText(label);
        self:SetHitRectInsets(0, -(self.Label:GetStringWidth() + 8), 0, 0);

        self.Glow:ClearAllPoints();
        self.Glow:SetPosition('TOPLEFT', self, 'TOPLEFT', -2, 2);
        self.Glow:SetPosition('TOPRIGHT', self.Label, 'TOPRIGHT', 2, 2);
        self.Glow:SetPosition('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, -2);
        self.Glow:SetPosition('BOTTOMRIGHT', self.Label, 'BOTTOMRIGHT', 0, -2);

        self.SearchText = label;
    end

    b.SetTooltip = function(self, tooltip)
        self.tooltip = tooltip;
    end

    b.AddToSearch = AddToSearch;

    E.CreateTooltip(b);

    b:HookScript('OnEnter', function(self)
        LCG.PixelGlow_Stop(self.Glow);
    end);

    hooksecurefunc(b, 'SetEnabled', function(self, state)
        if state then
            self.Label:SetTextColor(1, 1, 1);
            self:GetNormalTexture():SetVertexColor(1, 1, 1);
        else
            self.Label:SetTextColor(0.35, 0.35, 0.35);
            self:GetNormalTexture():SetVertexColor(0.35, 0.35, 0.35);
        end
    end);

    hooksecurefunc(b, 'Enable', function(self)
        self.Label:SetTextColor(1, 1, 1);
        self:GetNormalTexture():SetVertexColor(1, 1, 1);
    end);

    hooksecurefunc(b, 'Disable', function(self)
        self.Label:SetTextColor(0.35, 0.35, 0.35);
        self:GetNormalTexture():SetVertexColor(0.35, 0.35, 0.35);
    end);

    b:SetScript('OnClick', function(self)
        ChatConfigFrame_PlayCheckboxSound(self:GetChecked());

        AddToFreqUsed(self);

        if self.Callback then
            self:Callback();
        end
    end);

    b:SetSize(18, 18);

    b.type = 'CheckButton';

    return b;
end

E.CreateTextureButton = function(parent, texturePath, textureCoord)
    local b = Mixin(CreateFrame('Button', nil, parent), E.PixelPerfectMixin);

    b:SetSize(16, 16);

    b:SetNormalTexture(texturePath);
    b:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    b:SetHighlightTexture(texturePath, 'BLEND')
    b:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);

    if textureCoord then
        b:GetNormalTexture():SetTexCoord(unpack(textureCoord));
        b:GetHighlightTexture():SetTexCoord(unpack(textureCoord));
    end

    b.Glow = Mixin(CreateFrame('Frame', nil, b), E.PixelPerfectMixin);
    b.Glow:SetPosition('TOPLEFT', b, 'TOPLEFT', -6, 6);
    b.Glow:SetPosition('BOTTOMRIGHT', b, 'BOTTOMRIGHT', 6, -6);

    b.SetTooltip = function(self, tooltip)
        self.tooltip = tooltip;
    end

    E.CreateTooltip(b);

    b.AddToSearch = AddToSearch;

    b:HookScript('OnEnter', function(self)
        LCG.PixelGlow_Stop(self.Glow);
    end);

    b:SetScript('OnClick', function(self)
        AddToFreqUsed(self);

        if self.Callback then
            self:Callback();
        end
    end);

    return b;
end

E.CreateScrollFrame = function(parent, scrollStep, scrollChild)
    scrollStep = scrollStep or 20;

    if not scrollChild then
        scrollChild = CreateFrame('Frame', '$parentScrollChild', parent);
    end

    local scrollArea = CreateFrame('ScrollFrame', '$parentScrollFrame', parent, 'UIPanelScrollFrameTemplate');
    PixelUtil.SetPoint(scrollArea, 'TOPLEFT', parent, 'TOPLEFT', 0, 0);
    PixelUtil.SetPoint(scrollArea, 'BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, 0);

    scrollArea:SetScrollChild(scrollChild);

    PixelUtil.SetSize(scrollChild, scrollArea:GetWidth(), scrollArea:GetHeight());

    scrollArea.scrollChild = scrollChild;
    scrollArea.scrollBarHideable = true;
    scrollArea.noScrollThumb     = false;

    local scrollBar        = scrollArea.ScrollBar;
    local scrollUpButton   = scrollBar.ScrollUpButton;
    local scrollDownButton = scrollBar.ScrollDownButton;
    local scrollThumb      = scrollBar.ThumbTexture;

    PixelUtil.SetPoint(scrollBar, 'TOPLEFT', scrollArea, 'TOPRIGHT', 0, 0);
    PixelUtil.SetPoint(scrollBar, 'BOTTOMLEFT', scrollArea, 'BOTTOMRIGHT', 0, 0);

    scrollBar.scrollStep = scrollStep;

    scrollUpButton:SetSize(1, 1);
    scrollUpButton:SetAlpha(0);

    scrollDownButton:SetSize(1, 1);
    scrollDownButton:SetAlpha(0);

    scrollThumb:SetTexture('Interface\\Buttons\\WHITE8x8');
    scrollThumb:SetSize(2, 64);
    scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);

    scrollBar.isMouseIsDown = false;
    scrollBar.isMouseIsOver = false;

    scrollBar:HookScript('OnEnter', function(self)
        self.isMouseIsOver = true;
        C_Timer.After(0.1, function()
            if scrollBar:IsMouseOver() then
                scrollThumb:SetSize(6, 64)
                scrollThumb:SetVertexColor(1, 0.85, 0, 1);
            end
        end);
    end);

    scrollBar:HookScript('OnLeave', function(self)
        self.isMouseIsOver = false;
        if not self.isMouseIsDown then
            C_Timer.After(0.25, function()
                if not scrollBar:IsMouseOver() then
                    scrollThumb:SetSize(2, 64);
                    scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);
                end
            end);
        end
    end);

    scrollBar:HookScript('OnMouseDown', function(self)
        self.isMouseIsDown = true;
        scrollThumb:SetSize(6, 64)
        scrollThumb:SetVertexColor(1, 0.85, 0, 1);
    end);

    scrollBar:HookScript('OnMouseUp', function(self)
        self.isMouseIsDown = false;
        if not self.isMouseIsOver then
            C_Timer.After(0.25, function()
                scrollThumb:SetSize(2, 64);
                scrollThumb:SetVertexColor(0.7, 0.7, 0.7, 1);
            end);
        end
    end);

    scrollBar:EnableMouse(true);
    scrollBar:HookScript('OnMouseWheel', function(self, value)
        ScrollFrameTemplate_OnMouseWheel(self, value, self);
    end);

    ScrollFrame_OnLoad(scrollArea);

    return scrollChild, scrollArea;
end

do
    local SLIDER_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\UI-SliderBar-Background',
        edgeFile = MEDIA_PATH .. 'Textures\\Assets\\UI-SliderBar-Border',
        tile     = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets   = { left = 3, right = 3, top = 6, bottom = 6 },
    };

    local SLIDER_CURRENT_VALUE_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local SLIDER_EDITBOX_BACKGROUND_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local function SliderRound(val, minVal, valueStep)
        return math.floor((val - minVal) / valueStep + 0.5) * valueStep + minVal;
    end

    E.CreateSlider = function(parent)
        local slider  = Mixin(CreateFrame('Slider', nil, parent, 'OptionsSliderTemplate'), E.PixelPerfectMixin);
        local editbox = Mixin(CreateFrame('EditBox', '$parentEditBox', slider, 'InputBoxTemplate'), E.PixelPerfectMixin);

        slider:SetH(18);

        slider.Thumb:SetTexture('');

        slider:SetBackdrop(SLIDER_BACKDROP);
        slider:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        slider.Glow = Mixin(CreateFrame('Frame', nil, slider), E.PixelPerfectMixin);
        slider.Glow:SetPosition('TOPLEFT', slider, 'TOPLEFT', -2, 6);
        slider.Glow:SetPosition('BOTTOMRIGHT', slider, 'BOTTOMRIGHT', 2, -6);

        slider:SetOrientation('HORIZONTAL');

        slider.Low:ClearAllPoints();
        PixelUtil.SetPoint(slider.Low, 'LEFT', slider, 'LEFT', 0, 0);
        slider.Low:SetFontObject('StripesOptionsNormalFont');
        slider.Low:SetShown(false);

        slider.High:ClearAllPoints();
        PixelUtil.SetPoint(slider.High, 'RIGHT', slider, 'RIGHT', 0, 0);
        slider.High:SetFontObject('StripesOptionsNormalFont');
        slider.High:SetShown(false);

        slider.Text:ClearAllPoints();
        PixelUtil.SetPoint(slider.Text, 'BOTTOMLEFT', slider, 'TOPLEFT', 0, 4);
        slider.Text:SetFontObject('StripesOptionsHighlightFont');

        hooksecurefunc(slider, 'SetValue', function(self, value)
            self.currentValue = value;
        end);

        slider.AddToSearch = AddToSearch;

        slider.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        slider.SetLabel = function(self, label)
            self.Text:SetText(label);

            self.SearchText = label;
        end

        slider.SetValues = function(self, currentValue, minValue, maxValue, stepValue)
            self.currentValue = currentValue or 0;
            self.minValue     = minValue or 0;
            self.maxValue     = maxValue or 100;
            self.stepValue    = stepValue or 1;

            self:SetMinMaxValues(self.minValue, self.maxValue);
            self:SetStepsPerPage(self.stepValue);
            self:SetValueStep(self.stepValue);
            self:SetValue(SliderRound(self.currentValue, self.minValue, self.stepValue));

            self.Low:SetText(self.minValue);
            self.High:SetText(self.maxValue);

            self.editbox:SetText(SliderRound(self.currentValue, self.minValue, self.stepValue));
            self.CurrentValueBox.Text:SetText(SliderRound(self.currentValue, self.minValue, self.stepValue));
        end

        slider:SetScript('OnValueChanged', function(self, value)
            value = SliderRound(value, self.minValue, self.stepValue);
            value = math.max(value, self.minValue); -- Sometimes value goes to 0 when minValue > 0 Hmmm....

            self.currentValue = value;

            self.editbox:SetText(self.currentValue);
            self.CurrentValueBox.Text:SetText(self.currentValue);

            if slider:IsDraggingThumb() and self.editbox:HasFocus() then
                self.editbox:ClearFocus();
            end

            if self.OnValueChangedCallback then
                self:OnValueChangedCallback(self.currentValue);
            end
        end);

        slider:SetScript('OnMouseUp', function(self, button)
            if not self:IsEnabled() then
                return;
            end

            AddToFreqUsed(self);

            if button == 'RightButton' then
                self.editbox:SetShown(true);
                self.editbox:SetFocus();
                self.CurrentValueBox:SetShown(false);

                return;
            end

            if self.OnMouseUpCallback then
                self:OnMouseUpCallback(self.currentValue);
            end
        end);

        slider:HookScript('OnEnter', function(self)
            LCG.PixelGlow_Stop(self.Glow);
        end);

        slider.CurrentValueBox = Mixin(CreateFrame('Frame', nil, slider, 'BackdropTemplate'), E.PixelPerfectMixin);
        slider.CurrentValueBox:SetPosition('CENTER', slider.Thumb, 'CENTER', 0, 0);
        slider.CurrentValueBox:SetSize(34, 20);
        slider.CurrentValueBox:SetBackdrop(SLIDER_CURRENT_VALUE_BACKDROP);
        slider.CurrentValueBox:SetBackdropColor(0.05, 0.05, 0.05, 1);
        slider.CurrentValueBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        slider.CurrentValueBox.Text = Mixin(slider.CurrentValueBox:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
        slider.CurrentValueBox.Text:SetPosition('CENTER', slider.CurrentValueBox, 'CENTER', 0, 0);

        editbox:SetFrameLevel(slider:GetFrameLevel() + 3);
        editbox:SetShown(false);
        editbox:ClearAllPoints();
        editbox:SetPosition('TOPLEFT', slider.CurrentValueBox, 'TOPLEFT', 5, 0);
        editbox:SetPosition('BOTTOMRIGHT', slider.CurrentValueBox, 'BOTTOMRIGHT', 0, 0);
        editbox:SetSize(34, 20);

        editbox:SetFontObject('StripesOptionsNormalFont');
        editbox:SetAutoFocus(false);

        editbox.Left:Hide();
        editbox.Middle:Hide();
        editbox.Right:Hide();

        editbox.Background = Mixin(CreateFrame('Frame', '$parentBackground', editbox, 'BackdropTemplate'), E.PixelPerfectMixin);
        editbox.Background:SetPosition('TOPLEFT', editbox, 'TOPLEFT', -5, 0);
        editbox.Background:SetSize(34, 20);
        editbox.Background:SetFrameLevel(editbox:GetFrameLevel() - 1);
        editbox.Background:SetBackdrop(SLIDER_EDITBOX_BACKGROUND_BACKDROP);
        editbox.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);
        editbox.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        editbox:SetScript('OnEnterPressed', function(self)
            self.lastValue = nil;
            self:ClearFocus();

            local value = tonumber((string.gsub(self:GetText(), ',', '.')));
            if value then
                value = math.min(value, self:GetParent().maxValue);
                value = math.max(value, self:GetParent().minValue);
            else
                value = self:GetParent().currentValue;
            end

            value = SliderRound(value, self:GetParent().minValue, self:GetParent().stepValue);

            self:GetParent():SetValue(value);
            self:SetText(value);
            self:GetParent().CurrentValueBox.Text:SetText(value);

            if self:GetParent().OnValueChangedCallback then
                self:GetParent():OnValueChangedCallback(value);
            end

            if self:GetParent().OnMouseUpCallback then
                self:GetParent():OnMouseUpCallback(value);
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

            self:SetShown(false);
            self:GetParent().CurrentValueBox:SetShown(true);
        end);

        editbox:SetScript('OnEditFocusGained', function(self)
            self.isFocused = true;
            self.lastValue = tonumber(self:GetText());
            self:HighlightText();
            self.Background:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);
        end);

        editbox:SetScript('OnEditFocusLost', function(self)
            self.isFocused = false;
            if self.lastValue then
                self:SetText(SliderRound(self.lastValue, self:GetParent().minValue, self:GetParent().stepValue));
                self:GetParent().CurrentValueBox.Text:SetText(SliderRound(self.lastValue, self:GetParent().minValue, self:GetParent().stepValue));
            end

            EditBox_ClearHighlight(self);
            self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

            self:SetShown(false);
            self:GetParent().CurrentValueBox:SetShown(true);
        end);

        editbox:HookScript('OnEnter', function(self)
            if not self.isFocused then
                self.Background:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
            end

            LCG.PixelGlow_Stop(self:GetParent().Glow);

            if not self:GetParent().tooltip then
                return;
            end

            GameTooltip:SetOwner(self:GetParent(), 'ANCHOR_RIGHT');
            GameTooltip:AddLine(self:GetParent().tooltip, 1, 0.85, 0, true);
            GameTooltip:Show();
        end);

        editbox:HookScript('OnLeave', function(self)
            if not self.isFocused then
                self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
            end

            GameTooltip_Hide();
        end);

        local plusButton = Mixin(CreateFrame('Button', '$parentPlusButton', slider), E.PixelPerfectMixin);
        plusButton:SetPosition('RIGHT', slider, 'RIGHT', 4, 0);
        plusButton:SetSize(12, 12);
        plusButton:SetFrameLevel(slider:GetFrameLevel() + 10);
        plusButton:SetShown(false);
        plusButton.Text = Mixin(plusButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
        plusButton.Text:SetPosition('CENTER', plusButton, 'CENTER', 1, 0);
        plusButton.Text:SetText('+');
        plusButton.Background = Mixin(CreateFrame('Frame', '$parentBackground', plusButton, 'BackdropTemplate'), E.PixelPerfectMixin);
        plusButton.Background:SetPosition('TOPLEFT', plusButton, 'TOPLEFT', 0, 0);
        plusButton.Background:SetSize(12, 12);
        plusButton.Background:SetFrameLevel(plusButton:GetFrameLevel() - 1);
        plusButton.Background:SetBackdrop(SLIDER_EDITBOX_BACKGROUND_BACKDROP);
        plusButton.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);
        plusButton.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        plusButton:SetScript('OnClick', function(self)
            local value = self:GetParent().currentValue + self:GetParent().stepValue;

            if value then
                value = math.min(value, self:GetParent().maxValue);
                value = math.max(value, self:GetParent().minValue);
            else
                value = self:GetParent().currentValue;
            end

            self:GetParent():SetValue(value);
        end);
        plusButton:HookScript('OnEnter', function(self)
            self.Background:SetBackdropColor(0.5, 0.5, 0.5, 1);
        end);
        plusButton:HookScript('OnLeave', function(self)
            self.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);

            if not self:GetParent():IsMouseOver() then
                self:SetShown(false);
                self:GetParent().minusButton:SetShown(false);
            end
        end);

        local minusButton = Mixin(CreateFrame('Button', '$parentMinusButton', slider), E.PixelPerfectMixin);
        minusButton:SetPosition('LEFT', slider, 'LEFT', -4, 0);
        minusButton:SetSize(12, 12);
        minusButton:SetFrameLevel(slider:GetFrameLevel() + 10);
        minusButton:SetShown(false);
        minusButton.Text = Mixin(minusButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
        minusButton.Text:SetPosition('CENTER', minusButton, 'CENTER', 0, 1);
        minusButton.Text:SetText('-');
        minusButton.Background = Mixin(CreateFrame('Frame', '$parentBackground', minusButton, 'BackdropTemplate'), E.PixelPerfectMixin);
        minusButton.Background:SetPosition('TOPLEFT', minusButton, 'TOPLEFT', 0, 0);
        minusButton.Background:SetSize(12, 12);
        minusButton.Background:SetFrameLevel(minusButton:GetFrameLevel() - 1);
        minusButton.Background:SetBackdrop(SLIDER_EDITBOX_BACKGROUND_BACKDROP);
        minusButton.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);
        minusButton.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
        minusButton:SetScript('OnClick', function(self)
            local value = self:GetParent().currentValue - self:GetParent().stepValue;

            if value then
                value = math.min(value, self:GetParent().maxValue);
                value = math.max(value, self:GetParent().minValue);
            else
                value = self:GetParent().currentValue;
            end

            self:GetParent():SetValue(value);
        end);
        minusButton:HookScript('OnEnter', function(self)
            self.Background:SetBackdropColor(0.5, 0.5, 0.5, 1);
        end);
        minusButton:HookScript('OnLeave', function(self)
            self.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);

            if not self:GetParent():IsMouseOver() then
                self:SetShown(false);
                self:GetParent().plusButton:SetShown(false);
            end
        end);

        slider:HookScript('OnEnter', function(self)
            self.plusButton:SetShown(true);
            self.minusButton:SetShown(true);
        end);

        slider:HookScript('OnLeave', function(self)
            if not (self.plusButton:IsMouseOver() or self.minusButton:IsMouseOver()) then
                self.plusButton:SetShown(false);
                self.minusButton:SetShown(false);
            end
        end);

        slider.editbox     = editbox;
        slider.plusButton  = plusButton;
        slider.minusButton = minusButton;

        E.CreateTooltip(slider);

        hooksecurefunc(slider, 'SetEnabled', function(self, state)
            if state then
                self.CurrentValueBox.Text:SetFontObject('StripesOptionsNormalFont');
                self.Text:SetFontObject('StripesOptionsHighlightFont');
            else
                self.CurrentValueBox.Text:SetFontObject('StripesOptionsDisabledFont');
                self.Text:SetFontObject('StripesOptionsDisabledFont');
            end
        end);

        slider:Show();

        slider.type = 'Slider';

        return slider;
    end

    E.CreateEditBox = function(parent)
        local editbox = Mixin(CreateFrame('EditBox', nil, parent, 'InputBoxTemplate'), E.PixelPerfectMixin);

        editbox:SetSize(30, 25);

        editbox:SetFontObject('StripesOptionsNormalFont');
        editbox:SetAutoFocus(false);

        editbox.Left:Hide();
        editbox.Middle:Hide();
        editbox.Right:Hide();

        editbox.Background = Mixin(CreateFrame('Frame', nil, editbox, 'BackdropTemplate'), E.PixelPerfectMixin);
        editbox.Background:SetPosition('TOPLEFT', editbox, 'TOPLEFT', -5, 0);
        editbox.Background:SetPosition('BOTTOMRIGHT', editbox, 'BOTTOMRIGHT', 5, 0);
        editbox.Background:SetFrameLevel(editbox:GetFrameLevel() - 1);
        editbox.Background:SetBackdrop(SLIDER_EDITBOX_BACKGROUND_BACKDROP);
        editbox.Background:SetBackdropColor(0.05, 0.05, 0.05, 1);
        editbox.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        editbox.Label = Mixin(editbox:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
        editbox.Label:SetPosition('LEFT', editbox.Background, 'RIGHT', 4, 0);

        editbox.Glow = Mixin(CreateFrame('Frame', nil, editbox), E.PixelPerfectMixin);
        editbox.Glow:SetPosition('TOPLEFT', editbox, 'TOPLEFT', -8, 2);
        editbox.Glow:SetPosition('BOTTOMRIGHT', editbox, 'BOTTOMRIGHT', 8, -2);

        editbox.Instruction = Mixin(editbox:CreateFontString(nil, 'ARTWORK', 'StripesOptionsLightGreyedFont'), E.PixelPerfectMixin);
        editbox.Instruction:SetPosition('LEFT', editbox, 'LEFT', 0, 0);

        editbox.SetLabel = function(self, label)
            self.Label:SetText(label);

            self.Glow:SetPosition('TOPLEFT', self, 'TOPLEFT', -8, 2);
            self.Glow:SetPosition('TOPRIGHT', self.Label, 'TOPRIGHT', 4, 2);
            self.Glow:SetPosition('BOTTOMLEFT', self, 'BOTTOMLEFT', -8, -2);
            self.Glow:SetPosition('BOTTOMRIGHT', self.Label, 'BOTTOMRIGHT', 4, -2);

            self.SearchText = label;
        end

        editbox.SetInstruction = function(self, text)
            self.Instruction:SetText(text);
        end

        editbox.AddToSearch = AddToSearch;

        editbox:SetScript('OnEnterPressed', function(self)
            self.lastValue = nil;
            self:ClearFocus();

            AddToFreqUsed(self);

            if self.Callback then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
                self:Callback();
            end
        end);

        editbox:SetScript('OnEditFocusGained', function(self)
            self.isFocused = true;
            self.lastValue = self:GetText() ~= '' and self:GetText() or nil;
            self:HighlightText();
            self.Background:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);

            self.Instruction:SetShown(false);

            if self.FocusGainedCallback then
                self:FocusGainedCallback();
            end
        end);

        editbox:SetScript('OnEditFocusLost', function(self)
            self.isFocused = false;
            if self.lastValue and self.useLastValue then
                self:SetText(self.lastValue);
            end

            EditBox_ClearHighlight(self);
            self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

            self.Instruction:SetShown(self:GetText() == '');

            if self.FocusLostCallback then
                self:FocusLostCallback();
            end
        end);

        editbox:SetScript('OnTextChanged', function(self)
            if self.OnTextChangedCallback then
                self:OnTextChangedCallback();
            end
        end);

        editbox:HookScript('OnEnter', function(self)
            if not self.isFocused and self:IsEnabled() then
                self.Background:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);
            end

            LCG.PixelGlow_Stop(self.Glow);
        end);

        editbox:HookScript('OnLeave', function(self)
            if not self.isFocused and self:IsEnabled() then
                self.Background:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
            end
        end);

        hooksecurefunc(editbox, 'SetEnabled', function(self, state)
            if state then
                self:SetFontObject('StripesOptionsNormalFont');
                self.Label:SetFontObject('StripesOptionsNormalFont');
            else
                self:SetFontObject('StripesOptionsDisabledFont');
                self.Label:SetFontObject('StripesOptionsDisabledFont');
            end
        end);

        E.CreateTooltip(editbox);

        editbox.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        editbox.type = 'EditBox';

        return editbox;
    end
end

E.CreateHeader = function(parent, text)
    local frame = Mixin(CreateFrame('Frame', nil, parent), E.PixelPerfectMixin);
    frame:SetH(20);

    local label = Mixin(frame:CreateFontString(nil, 'BACKGROUND', 'StripesMediumHighlightFont'), E.PixelPerfectMixin);
    label:SetPosition('TOP', frame, 'TOP', 0, 0);
    label:SetPosition('BOTTOM', frame, 'BOTTOM', 0, 0);
    label:SetJustifyH('CENTER');

    local left = Mixin(frame:CreateTexture(nil, 'BACKGROUND'), E.PixelPerfectMixin);
    left:SetPosition('LEFT', frame, 'LEFT', 0, 0);
    left:SetPosition('RIGHT', label, 'LEFT', -5, 0);
    left:SetH(2);
    left:SetTexture('Interface\\Buttons\\WHITE8x8');
    left:SetVertexColor(0.4, 0.4, 0.4, 1);

    local right = Mixin(frame:CreateTexture(nil, 'BACKGROUND'), E.PixelPerfectMixin);
    right:SetPosition('RIGHT', frame, 'RIGHT', 0, 0);
    right:SetPosition('LEFT', label, 'RIGHT', 5, 0);
	right:SetH(2);
    right:SetTexture('Interface\\Buttons\\WHITE8x8');
    right:SetVertexColor(0.4, 0.4, 0.4, 1);

    if text and text ~= '' then
        label:SetText(text);
        PixelUtil.SetPoint(left, 'RIGHT', label, 'LEFT', -5, 0);
        right:Show();
    else
        PixelUtil.SetPoint(left, 'RIGHT', frame, 'RIGHT', -3, 0);
        right:Hide();
    end

    frame.Label = label;

    return frame;
end

E.CreateDelimiter = function(parent)
    return E.CreateHeader(parent);
end

-- Reinventing the wheel
do
    local activeLists = {};

    local DROPDOWN_WIDTH, DROPDOWN_HEIGHT = 100, 24;

    local DROPDOWN_HOLDER_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local DROPDOWN_ARROWBUTTON_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    local DROPDOWN_LIST_BACKDROP = {
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    };

    local DROPDOWN_ITEMBUTTON_BACKDROP = {
        bgFile = 'Interface\\Buttons\\WHITE8x8',
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    };

    local function UpdateScrollArea(scrollArea, height, heightValue, counter)
        scrollArea:UpdateScrollChildRect();
        scrollArea.ScrollBar:SetMinMaxValues(0, math.floor(math.abs(height - counter * heightValue - 0.5)));
        if select(2, scrollArea.ScrollBar:GetMinMaxValues()) == 0 then
            scrollArea.ScrollBar:Hide();
        end
    end

    local sortedList = {};
    local function textSort(a, b)
        return string.upper(a) < string.upper(b)
    end

    local kinds = {
        ['plain'] = {
            SetList = function(self, itemsTable)
                self.itemsTable = itemsTable;

                local itemButton, isNew, lastButton;
                local itemCounter = 0;

                local container    = self;
                container.subType = 'string';

                local holderButton = self.holderButton;
                local listFrame    = self.holderButton.list;

                holderButton.buttonPool:ReleaseAll();

                for key, value in ipairs(itemsTable) do
                    itemCounter = itemCounter + 1;
                    itemButton, isNew = holderButton.buttonPool:Acquire();

                    itemButton:ClearAllPoints();

                    if itemCounter == 1 then
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', holderButton.scrollChild, 'TOPLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', holderButton.scrollChild, 'TOPRIGHT', 0, 0);
                    else
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', lastButton, 'BOTTOMLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', lastButton, 'BOTTOMRIGHT', 0, 0);
                    end

                    lastButton = itemButton;

                    if isNew then
                        itemButton:SetBackdrop(DROPDOWN_ITEMBUTTON_BACKDROP);
                        itemButton:SetBackdropColor(0, 0, 0, 1);

                        itemButton.SelectedIcon = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.SelectedIcon, 'LEFT', itemButton, 'LEFT', 2, 0);
                        itemButton.SelectedIcon:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');
                        itemButton.SelectedIcon:SetShown(false);

                        itemButton.Text = itemButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
                        PixelUtil.SetPoint(itemButton.Text, 'TOPLEFT', itemButton.SelectedIcon, 'TOPRIGHT', 2, 4);
                        PixelUtil.SetPoint(itemButton.Text, 'BOTTOMRIGHT', itemButton, 'BOTTOMRIGHT', -2, 0);
                        itemButton.Text:SetJustifyH('LEFT');
                        itemButton.Text:SetJustifyV('MIDDLE');

                        itemButton:HookScript('OnEnter', function(self)
                            self:SetBackdropColor(0.6, 0.5, 0.2, 1);
                        end);

                        itemButton:HookScript('OnLeave', function(self)
                            self:SetBackdropColor(0, 0, 0, 1);
                        end);

                        itemButton:SetScript('OnClick', function(self)
                            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

                            container:SetValue(self.Key);
                            listFrame:SetShown(false);

                            if container.OnValueChangedCallback then
                                container:OnValueChangedCallback(self.Key, self.Value, IsShiftKeyDown());
                            end
                        end);
                    end

                    PixelUtil.SetHeight(itemButton, self.HeightValue);
                    PixelUtil.SetSize(itemButton.SelectedIcon, self.HeightValue / 1.5, self.HeightValue / 1.5);
                    itemButton.Text:SetText(value);

                    itemButton.Key   = key;
                    itemButton.Value = value;

                    itemButton:SetShown(true);
                end

                PixelUtil.SetHeight(listFrame, math.min(15 * self.HeightValue, itemCounter * self.HeightValue));
                PixelUtil.SetSize(holderButton.scrollChild, self.WidthValue, listFrame:GetHeight());

                self.UpdateScrollArea = function()
                    UpdateScrollArea(holderButton.scrollArea, listFrame:GetHeight(), container.HeightValue, itemCounter);
                end

                self:UpdateScrollArea();
            end,

            SetValue = function(self, value)
                if value == 0 then
                    self.holderButton.Text:SetText('');

                    for button, _ in self.holderButton.buttonPool:EnumerateActive() do
                        button.SelectedIcon:SetShown(false);
                    end

                    return;
                end

                for button, _ in self.holderButton.buttonPool:EnumerateActive() do
                    button.SelectedIcon:SetShown(false);

                    if button.Key == value then
                        button.SelectedIcon:SetShown(true);
                        self.holderButton.Text:SetText(button.Value);
                        self.currentValue = value;
                    end
                end
            end
        },

        ['texture'] = {
            SetList = function(self, itemsTable)
                self.itemsTable = itemsTable;

                local itemButton, isNew, lastButton;
                local itemCounter = 0;

                local container    = self;
                container.subType = 'number';

                local holderButton = self.holderButton;
                local listFrame    = self.holderButton.list;

                holderButton.buttonPool:ReleaseAll();

                for key, value in ipairs(itemsTable) do
                    itemCounter = itemCounter + 1;
                    itemButton, isNew = holderButton.buttonPool:Acquire();

                    itemButton:ClearAllPoints();

                    if itemCounter == 1 then
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', holderButton.scrollChild, 'TOPLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', holderButton.scrollChild, 'TOPRIGHT', 0, 0);
                    else
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', lastButton, 'BOTTOMLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', lastButton, 'BOTTOMRIGHT', 0, 0);
                    end

                    lastButton = itemButton;

                    if isNew then
                        itemButton:SetBackdrop(DROPDOWN_ITEMBUTTON_BACKDROP);
                        itemButton:SetBackdropColor(0, 0, 0, 1);

                        itemButton.SelectedIcon = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.SelectedIcon, 'LEFT', itemButton, 'LEFT', 2, 0);
                        itemButton.SelectedIcon:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');
                        itemButton.SelectedIcon:SetShown(false);

                        itemButton.Text = itemButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
                        PixelUtil.SetPoint(itemButton.Text, 'TOPLEFT', itemButton.SelectedIcon, 'TOPRIGHT', 2, 4);
                        PixelUtil.SetPoint(itemButton.Text, 'BOTTOMRIGHT', itemButton, 'BOTTOMRIGHT', -2, 0);
                        itemButton.Text:SetJustifyH('LEFT');
                        itemButton.Text:SetJustifyV('MIDDLE');

                        itemButton.Texture = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.Texture, 'LEFT', itemButton.Text , 'LEFT', 22, 0);

                        itemButton:HookScript('OnEnter', function(self)
                            self:SetBackdropColor(0.6, 0.5, 0.2, 1);
                        end);

                        itemButton:HookScript('OnLeave', function(self)
                            self:SetBackdropColor(0, 0, 0, 1);
                        end);

                        itemButton:SetScript('OnClick', function(self)
                            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

                            container:SetValue(self.Key);
                            listFrame:SetShown(false);

                            if container.OnValueChangedCallback then
                                container:OnValueChangedCallback(self.Key);
                            end
                        end);
                    end

                    PixelUtil.SetHeight(itemButton, self.HeightValue);
                    PixelUtil.SetSize(itemButton.SelectedIcon, self.HeightValue / 1.5, self.HeightValue / 1.5);
                    PixelUtil.SetSize(itemButton.Texture, self.HeightValue - 2, self.HeightValue - 2);

                    itemButton.Text:SetText(key);
                    itemButton.Texture:SetTexture(value);

                    itemButton.Key   = key;
                    itemButton.Value = value;

                    itemButton:SetShown(true);
                end

                PixelUtil.SetHeight(listFrame, math.min(15 * self.HeightValue, itemCounter * self.HeightValue));
                PixelUtil.SetSize(holderButton.scrollChild, self.WidthValue, listFrame:GetHeight());

                self.UpdateScrollArea = function()
                    UpdateScrollArea(holderButton.scrollArea, listFrame:GetHeight(), container.HeightValue, itemCounter);
                end

                self:UpdateScrollArea();
            end,

            SetValue = function(self, value)
                for button, _ in self.holderButton.buttonPool:EnumerateActive() do
                    button.SelectedIcon:SetShown(false);

                    if button.Key == value then
                        button.SelectedIcon:SetShown(true);
                        self.holderButton.Text:SetText(value);
                        self.holderButton.Texture:SetTexture(self.itemsTable[value]);
                        self.currentValue = value;
                    end
                end
            end,
        },

        ['statusbar'] = {
            SetList = function(self, itemsTable)
                itemsTable = itemsTable or LSM:HashTable('statusbar');
                self.itemsTable = itemsTable;

                local itemButton, isNew, lastButton;
                local itemCounter = 0;

                local container    = self;
                container.subType = 'string';

                local holderButton = self.holderButton;
                local listFrame    = self.holderButton.list;

                holderButton.buttonPool:ReleaseAll();

                for k, _ in pairs(itemsTable) do
                    sortedList[#sortedList + 1] = k;
                end

                table.sort(sortedList, textSort)

                for key, value in ipairs(sortedList) do
                    itemCounter = itemCounter + 1;
                    itemButton, isNew = holderButton.buttonPool:Acquire();

                    itemButton:ClearAllPoints();

                    if itemCounter == 1 then
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', holderButton.scrollChild, 'TOPLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', holderButton.scrollChild, 'TOPRIGHT', 0, 0);
                    else
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', lastButton, 'BOTTOMLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', lastButton, 'BOTTOMRIGHT', 0, 0);
                    end

                    lastButton = itemButton;

                    if isNew then
                        itemButton:SetBackdrop(DROPDOWN_ITEMBUTTON_BACKDROP);
                        itemButton:SetBackdropColor(0, 0, 0, 1);

                        itemButton.SelectedIcon = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.SelectedIcon, 'LEFT', itemButton, 'LEFT', 2, 0);
                        itemButton.SelectedIcon:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');
                        itemButton.SelectedIcon:SetShown(false);

                        itemButton.Text = itemButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
                        PixelUtil.SetPoint(itemButton.Text, 'TOPLEFT', itemButton.SelectedIcon, 'TOPRIGHT', 2, 4);
                        PixelUtil.SetPoint(itemButton.Text, 'BOTTOMRIGHT', itemButton, 'BOTTOMRIGHT', -2, 0);
                        itemButton.Text:SetJustifyH('LEFT');
                        itemButton.Text:SetJustifyV('MIDDLE');

                        itemButton.StatusBar = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.StatusBar, 'TOPLEFT', itemButton.SelectedIcon, 'TOPRIGHT', 2, 4);
                        PixelUtil.SetPoint(itemButton.StatusBar, 'BOTTOMRIGHT', itemButton, 'BOTTOMRIGHT', 0, 0);

                        itemButton:HookScript('OnEnter', function(self)
                            self:SetBackdropColor(0.6, 0.5, 0.2, 1);
                        end);

                        itemButton:HookScript('OnLeave', function(self)
                            self:SetBackdropColor(0, 0, 0, 1);
                        end);

                        itemButton:SetScript('OnClick', function(self)
                            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

                            container:SetValue(self.Value);
                            listFrame:SetShown(false);

                            if container.OnValueChangedCallback then
                                container:OnValueChangedCallback(self.Value);
                            end
                        end);
                    end

                    PixelUtil.SetHeight(itemButton, self.HeightValue);
                    PixelUtil.SetSize(itemButton.SelectedIcon, self.HeightValue / 1.5, self.HeightValue / 1.5);

                    itemButton.Text:SetText(value);
                    itemButton.StatusBar:SetTexture(LSM:Fetch('statusbar', value));

                    itemButton.Key   = key;
                    itemButton.Value = value;

                    itemButton:SetShown(true);
                end

                PixelUtil.SetHeight(listFrame, math.min(15 * self.HeightValue, itemCounter * self.HeightValue));
                PixelUtil.SetSize(holderButton.scrollChild, self.WidthValue, listFrame:GetHeight());

                self.UpdateScrollArea = function()
                    UpdateScrollArea(holderButton.scrollArea, listFrame:GetHeight(), container.HeightValue, itemCounter);
                end

                self:UpdateScrollArea();

                wipe(sortedList);
            end,

            SetValue = function(self, value)
                for button, _ in self.holderButton.buttonPool:EnumerateActive() do
                    button.SelectedIcon:SetShown(false);

                    if button.Value == value then
                        button.SelectedIcon:SetShown(true);
                        self.holderButton.Text:SetText(button.Value);
                        self.holderButton.StatusBar:SetTexture(LSM:Fetch('statusbar', value));
                        self.currentValue = value;
                    end
                end
            end,
        },

        ['font'] = {
            SetList = function(self, itemsTable)
                itemsTable = itemsTable or LSM:HashTable('font');
                self.itemsTable = itemsTable;

                local itemButton, isNew, lastButton;
                local itemCounter = 0;

                local container    = self;
                container.subType = 'string';

                local holderButton = self.holderButton;
                local listFrame    = self.holderButton.list;

                holderButton.buttonPool:ReleaseAll();

                for k, _ in pairs(itemsTable) do
                    sortedList[#sortedList+1] = k
                end

                table.sort(sortedList, textSort)

                for key, value in ipairs(sortedList) do
                    itemCounter = itemCounter + 1;
                    itemButton, isNew  = holderButton.buttonPool:Acquire();

                    itemButton:ClearAllPoints();

                    if itemCounter == 1 then
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', holderButton.scrollChild, 'TOPLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', holderButton.scrollChild, 'TOPRIGHT', 0, 0);
                    else
                        PixelUtil.SetPoint(itemButton, 'TOPLEFT', lastButton, 'BOTTOMLEFT', 0, 0);
                        PixelUtil.SetPoint(itemButton, 'TOPRIGHT', lastButton, 'BOTTOMRIGHT', 0, 0);
                    end

                    lastButton = itemButton;

                    if isNew then
                        itemButton:SetBackdrop(DROPDOWN_ITEMBUTTON_BACKDROP);
                        itemButton:SetBackdropColor(0, 0, 0, 1);

                        itemButton.SelectedIcon = itemButton:CreateTexture(nil, 'ARTWORK');
                        PixelUtil.SetPoint(itemButton.SelectedIcon, 'LEFT', itemButton, 'LEFT', 2, 0);
                        itemButton.SelectedIcon:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');
                        itemButton.SelectedIcon:SetShown(false);

                        itemButton.Text = itemButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
                        PixelUtil.SetPoint(itemButton.Text, 'TOPLEFT', itemButton.SelectedIcon, 'TOPRIGHT', 2, 4);
                        PixelUtil.SetPoint(itemButton.Text, 'BOTTOMRIGHT', itemButton, 'BOTTOMRIGHT', -2, 0);
                        itemButton.Text:SetJustifyH('LEFT');
                        itemButton.Text:SetJustifyV('MIDDLE');

                        itemButton:HookScript('OnEnter', function(self)
                            self:SetBackdropColor(0.6, 0.5, 0.2, 1);
                        end);

                        itemButton:HookScript('OnLeave', function(self)
                            self:SetBackdropColor(0, 0, 0, 1);
                        end);

                        itemButton:SetScript('OnClick', function(self)
                            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

                            container:SetValue(self.Value);
                            listFrame:SetShown(false);

                            if container.OnValueChangedCallback then
                                container:OnValueChangedCallback(self.Value);
                            end
                        end);
                    end

                    PixelUtil.SetSize(itemButton, self.WidthValue, self.HeightValue);
                    PixelUtil.SetSize(itemButton.SelectedIcon, self.HeightValue / 1.5, self.HeightValue / 1.5);
                    itemButton.Text:SetText(value);

                    local _, size, outline = itemButton.Text:GetFont();
                    itemButton.Text:SetFont(LSM:Fetch('font', value), size, outline);

                    itemButton.Key   = key;
                    itemButton.Value = value;

                    itemButton:SetShown(true);
                end

                PixelUtil.SetHeight(listFrame, math.min(15 * self.HeightValue, itemCounter * self.HeightValue));
                PixelUtil.SetSize(holderButton.scrollChild, self.WidthValue, listFrame:GetHeight());

                self.UpdateScrollArea = function()
                    UpdateScrollArea(holderButton.scrollArea, listFrame:GetHeight(), container.HeightValue, itemCounter);
                end

                self:UpdateScrollArea();

                wipe(sortedList);
            end,

            SetValue = function(self, value)
                for button, _ in self.holderButton.buttonPool:EnumerateActive() do
                    button.SelectedIcon:SetShown(false);

                    if button.Value == value then
                        button.SelectedIcon:SetShown(true);

                        self.holderButton.Text:SetText(button.Value);
                        local _, size, outline = self.holderButton.Text:GetFont();
                        self.holderButton.Text:SetFont(LSM:Fetch('font', value), size, outline);

                        self.currentValue = value;
                    end
                end
            end,
        },
    };

    E.CreateDropdown = function(kind, parent)
        if not kinds[kind] then
            error('Unknown dropdown type: ' .. kind);
        end

        local holderButton = Mixin(CreateFrame('Button', nil, parent, 'BackdropTemplate'), E.PixelPerfectMixin);

        local container = Mixin(CreateFrame('Frame', nil, parent), E.PixelPerfectMixin);
        container.Label = container:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
        PixelUtil.SetPoint(container.Label, 'LEFT', container, 'LEFT', 0, 0);
        container.Label:SetJustifyH('LEFT');

        container.holderButton = holderButton;
        container.holderButton:SetPosition('LEFT', container.Label, 'RIGHT', 0, 0);

        container.SetLabel = function(self, label)
            self.Label:SetText(label);
            self.holderButton:SetPosition('LEFT', container.Label, 'RIGHT', 12, 0);
            self:SetW(self.Label:GetStringWidth() + self:GetWidth() + 12);

            self.SearchText = label;
        end

        container.Glow = Mixin(CreateFrame('Frame', nil, container), E.PixelPerfectMixin);
        container.Glow:SetPosition('TOPLEFT', container, 'TOPLEFT', -2, 2);
        container.Glow:SetPosition('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 2, -2);

        container.WidthValue  = DROPDOWN_WIDTH;
        container.HeightValue = DROPDOWN_HEIGHT;

        PixelUtil.SetSize(holderButton, container.WidthValue, container.HeightValue);
        holderButton:SetBackdrop(DROPDOWN_HOLDER_BACKDROP);
        holderButton:SetBackdropColor(0.05, 0.05, 0.05, 1);
        holderButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);

        holderButton:SetScript('OnClick', function(self)
            self.list:SetShown(not self.list:IsShown());
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

            AddToFreqUsed(self, container.SearchText);
        end);

        holderButton.Text = holderButton:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
        PixelUtil.SetPoint(holderButton.Text, 'TOPLEFT', holderButton, 'TOPLEFT', 6, 0);
        PixelUtil.SetPoint(holderButton.Text, 'BOTTOMRIGHT', holderButton, 'BOTTOMRIGHT', -6, 0);
        holderButton.Text:SetJustifyH('LEFT');

        holderButton.StatusBar = holderButton:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(holderButton.StatusBar, 'TOPLEFT', holderButton, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(holderButton.StatusBar, 'BOTTOMRIGHT', holderButton, 'BOTTOMRIGHT', 0, 0);

        holderButton.Texture = holderButton:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(holderButton.Texture, 'LEFT', holderButton.Text, 'LEFT', 22, 0);
        PixelUtil.SetSize(holderButton.Texture, container.HeightValue - 2, container.HeightValue - 2);

        local arrowButton = CreateFrame('Button', nil, holderButton, 'BackdropTemplate');
        PixelUtil.SetPoint(arrowButton, 'TOPRIGHT', holderButton, 'TOPRIGHT', 0, 0);
        PixelUtil.SetSize(arrowButton, container.HeightValue, container.HeightValue);
        arrowButton.Icon = arrowButton:CreateTexture(nil, 'ARTWORK');
        PixelUtil.SetPoint(arrowButton.Icon, 'CENTER', arrowButton, 'CENTER', 0, 0);
        PixelUtil.SetSize(arrowButton.Icon, container.HeightValue / 1.2, container.HeightValue / 1.2);
        arrowButton.Icon:SetTexture(S.Media.Icons.TEXTURE);
        arrowButton.Icon:SetTexCoord(unpack(S.Media.Icons.COORDS.ARROW_DOWN_WHITE));
        arrowButton:SetBackdrop(DROPDOWN_ARROWBUTTON_BACKDROP);
        arrowButton:SetBackdropColor(0.1, 0.1, 0.1, 1);
        arrowButton:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

        arrowButton:SetScript('OnClick', function(self)
            self:GetParent().list:SetShown(not self:GetParent().list:IsShown());
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

            AddToFreqUsed(self, container.SearchText);
        end);

        arrowButton:HookScript('OnEnter', function(self)
            self.Icon:SetVertexColor(1, 0.72, 0.2);
            self:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);

            LCG.PixelGlow_Stop(container.Glow);

            if container.tooltip then
                GameTooltip:SetOwner(container, 'ANCHOR_RIGHT');
                GameTooltip:AddLine(container.tooltip, 1, 0.85, 0, true);
                GameTooltip:Show();
            end
        end);

        arrowButton:HookScript('OnLeave', function(self)
            self.Icon:SetVertexColor(1, 1, 1);
            self:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

            GameTooltip:Hide();
        end);

        local list = CreateFrame('Frame', 'Stripes_DDList_' .. (#activeLists + 1), holderButton, 'BackdropTemplate');
        PixelUtil.SetPoint(list, 'TOPLEFT', holderButton, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(list, 'TOPRIGHT', holderButton, 'TOPRIGHT', 0, 0);
        list:SetFrameLevel(arrowButton:GetFrameLevel() + 1);
        list:SetClampedToScreen(true);
        list:SetBackdrop(DROPDOWN_LIST_BACKDROP);
        list:SetBackdropColor(0, 0, 0, 1);
        list:SetShown(false);

        holderButton.scrollChild, holderButton.scrollArea = E.CreateScrollFrame(list, container.HeightValue);
        holderButton.buttonPool = CreateFramePool('Button', holderButton.scrollChild, 'BackdropTemplate');

        list.scrollBar = holderButton.scrollArea.ScrollBar;

        table.insert(activeLists, list);

        holderButton.arrowButton = arrowButton;
        holderButton.list        = list;

        holderButton:HookScript('OnEnter', function()
            arrowButton.Icon:SetVertexColor(1, 0.72, 0.2);
            arrowButton:SetBackdropBorderColor(0.8, 0.8, 0.8, 1);

            LCG.PixelGlow_Stop(container.Glow);

            if container.tooltip then
                GameTooltip:SetOwner(container, 'ANCHOR_RIGHT');
                GameTooltip:AddLine(container.tooltip, 1, 0.85, 0, true);
                GameTooltip:Show();
            end
        end);

        holderButton:HookScript('OnLeave', function()
            arrowButton.Icon:SetVertexColor(1, 1, 1);
            arrowButton:SetBackdropBorderColor(0.5, 0.5, 0.5, 1);

            GameTooltip:Hide();
        end);

        hooksecurefunc(holderButton, 'SetScale', function(self, value)
            self.list:SetScale(value);
        end);

        hooksecurefunc(holderButton, 'SetEnabled', function(self, state)
            if state then
                self.Text:SetFontObject('StripesOptionsNormalFont');
                self.arrowButton:Enable();
                self.arrowButton.Icon:SetVertexColor(1, 1, 1, 1);
            else
                self.Text:SetFontObject('StripesOptionsDisabledFont');
                self.arrowButton:Disable();
                self.arrowButton.Icon:SetVertexColor(0.5, 0.5, 0.5, 1);
            end
        end);

        container.SetList  = kinds[kind].SetList;
        container.SetValue = kinds[kind].SetValue;

        container.SetSize = function(self, width, height)
            if not width or not height then
                return;
            end

            if self.Label:GetStringWidth() > 0 then
                PixelUtil.SetSize(self, self.Label:GetStringWidth() + width + 12, height);
            else
                PixelUtil.SetSize(self, width, height);
            end

            PixelUtil.SetSize(self.holderButton, width, height);
            PixelUtil.SetSize(self.holderButton.arrowButton, height, height);
            PixelUtil.SetSize(self.holderButton.arrowButton.Icon, height / 1.2, height / 1.2);
            PixelUtil.SetPoint(self.holderButton.Text, 'BOTTOMRIGHT', self.holderButton, 'BOTTOMRIGHT', -(height + 6.5), 0);
            PixelUtil.SetSize(self.holderButton.Texture, height - 2, height - 2);

            self.holderButton.scrollArea.ScrollBar.scrollStep = height;
            self.holderButton.scrollChild:SetSize(width, self.holderButton.list:GetHeight());

            self.WidthValue  = width;
            self.HeightValue = height;
        end

        container.GetValue = function(self)
            return self.currentValue;
        end

        container.AddToSearch = AddToSearch;

        hooksecurefunc(container, 'SetScale', function(self, value)
            self.holderButton:SetScale(value);
        end);

        container.SetEnabled = function(self, state)
            self.holderButton:SetEnabled(state);
        end

        container.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        container:HookScript('OnEnter', function(self)
            LCG.PixelGlow_Stop(self.Glow);

            if self.tooltip then
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
                GameTooltip:AddLine(self.tooltip, 1, 0.85, 0, true);
                GameTooltip:Show();
            end
        end);

        container:HookScript('OnLeave', GameTooltip_Hide);

        container.type = 'DropDown';

        return container;
    end

    if UIDropDownMenu_HandleGlobalMouseEvent then
        local function DropDown_CloseNotActive()
            for _, list in ipairs(activeLists) do
                if list:IsShown() and not list:IsMouseOver() and not (list.scrollBar and list.scrollBar:IsMouseOver()) then
                    list:SetShown(false);
                end
            end
        end

        hooksecurefunc('UIDropDownMenu_HandleGlobalMouseEvent', function(button, event)
            if event == 'GLOBAL_MOUSE_DOWN' and (button == 'LeftButton' or button == 'RightButton') then
               DropDown_CloseNotActive();
            end
        end);
    end
end

-- Based on Phanx's LibColorPicker-1.0
-- https://github.com/Phanx/PhanxConfig-ColorPicker
local ColorPickerButtons, CreateColorButton, LastUsedColorButton;
local NewColorPicker do
    local NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR, GRAY_FONT_COLOR = NORMAL_FONT_COLOR, HIGHLIGHT_FONT_COLOR, GRAY_FONT_COLOR;

    ColorPickerButtons = Mixin(CreateFrame('Frame', nil, ColorPickerFrame, 'BackdropTemplate'), E.PixelPerfectMixin);
    ColorPickerButtons:SetPosition('TOPRIGHT', ColorPickerFrame, 'TOPLEFT', 0, -6);
    ColorPickerButtons:SetPosition('BOTTOMRIGHT', ColorPickerFrame, 'BOTTOMLEFT', 0, 6)
    ColorPickerButtons:SetW(80);
    ColorPickerButtons:SetShown(false);
    ColorPickerButtons.colors = {
        'ffffff',
        'ff4d4d',
        'ff6666',
        'ff8400',
        'ffb833',
        'ffd900',
        '00ff00',
        '7300ff',
        '9900d9',
    };

    local COLOR_BUTTON_BACKDROP = {
        bgFile   = 'Interface\\Buttons\\WHITE8x8',
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        edgeFile = 'Interface\\Buttons\\WHITE8x8',
        edgeSize = 1,
    };

    function CreateColorButton(hexColor)
        local b = Mixin(CreateFrame('Button', nil, ColorPickerButtons, 'BackdropTemplate'), E.PixelPerfectMixin);
        b:SetSize(80, 20);
        b:SetNormalFontObject('StripesOptionsButtonNormalFont');

        b.hexColor = hexColor or 'ffffff';

        b:SetBackdrop(COLOR_BUTTON_BACKDROP);
        b:SetBackdropColor(U.HEX2RGB(b.hexColor));
        b:SetBackdropBorderColor(0.3, 0.3, 0.33, 1);

        b:SetText('#' .. b.hexColor);

        b:SetScript('OnClick', function(self)
            ColorPickerFrame:SetColorRGB(U.HEX2RGB(self.hexColor));
            ColorPickerFrame.opacity = 1;
        end);

        b.SetColor = function(self, hColor)
            self.hexColor = hColor;
            self:SetBackdropColor(U.HEX2RGB(self.hexColor));
            self:SetText('#' .. self.hexColor);
        end

        return b;
    end

    local function GetFloorValue(value)
        return math.floor(value * 100 + 0.5) / 100;
    end

    function NewColorPicker(parent, hasOpacity)
        local holder = Mixin(CreateFrame('Button', nil, parent), E.PixelPerfectMixin);
        holder:SetSize(28, 28);

        local background = holder:CreateTexture(nil, 'BACKGROUND');
        background:SetTexture(S.Media.Icons.TEXTURE);
        background:SetTexCoord(unpack(S.Media.Icons.COORDS.FULL_CIRCLE_WHITE));
        background:SetVertexColor(0.8, 0.8, 0.8);
        PixelUtil.SetPoint(background, 'CENTER', holder, 'CENTER', 0, 0);
        PixelUtil.SetSize(background, 18, 18);
        holder.background = background;

        local border = holder:CreateTexture(nil, 'BORDER');
        border:SetTexture(S.Media.Icons.TEXTURE);
        border:SetTexCoord(unpack(S.Media.Icons.COORDS.FULL_CIRCLE_WHITE));
        border:SetVertexColor(0, 0, 0);
        PixelUtil.SetPoint(border, 'TOPLEFT', background, 'TOPLEFT', 2, -2);
        PixelUtil.SetPoint(border, 'BOTTOMRIGHT', background, 'BOTTOMRIGHT', -2, 2);
        holder.border = border;

        local sample = holder:CreateTexture(nil, 'OVERLAY');
        sample:SetTexture(S.Media.Icons.TEXTURE);
        sample:SetTexCoord(unpack(S.Media.Icons.COORDS.FULL_CIRCLE_WHITE));
        PixelUtil.SetPoint(sample, 'TOPLEFT', border, 'TOPLEFT', 1, -1);
        PixelUtil.SetPoint(sample, 'BOTTOMRIGHT', border, 'BOTTOMRIGHT', -1, 1);
        holder.sample = sample;

        local label = holder:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
        PixelUtil.SetPoint(label, 'LEFT', sample, 'RIGHT', 8, 0);
        holder.Label = label;

        holder.Glow = Mixin(CreateFrame('Frame', nil, holder), E.PixelPerfectMixin);
        holder.Glow:SetPosition('TOPLEFT', holder, 'TOPLEFT', -2, 2);
        holder.Glow:SetPosition('BOTTOMRIGHT', holder, 'BOTTOMRIGHT', 2, -2);

        holder:SetScript('OnEnter', function(self)
            if not self.disabled then
                self.background:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            end

            LCG.PixelGlow_Stop(self.Glow);
        end);

        holder:SetScript('OnLeave', function(self)
            if not self.disabled then
                self.background:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
            end
        end);

        holder:SetScript('OnClick', function(self)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

            if ColorPickerFrame:IsShown() then
                ColorPickerFrame:Hide();
                ColorPickerButtons:Hide();
                return;
            end

            self.r, self.g, self.b, self.opacity = self:GetValue();
            self.opacity = 1 - self.opacity;
            self.opening = true;

            OpenColorPicker(self);
            ColorPickerFrame:SetFrameStrata('TOOLTIP');
            ColorPickerFrame:Raise();

            ColorPickerButtons:Show();
            ColorPickerButtons:SetFrameStrata('TOOLTIP');
            ColorPickerButtons:Raise();

            self.opening = false;

            AddToFreqUsed(self);
        end);

        holder:SetScript('OnDisable', function(self)
            self.background:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
            self.Label:SetFontObject(GameFontDisable);

            self.disabled = true;
        end);

        holder:SetScript('OnEnable', function(self)
            local color = self:IsMouseOver() and NORMAL_FONT_COLOR or HIGHLIGHT_FONT_COLOR;

            self.background:SetVertexColor(color.r, color.g, color.b);
            self.Label:SetFontObject(GameFontHighlight);

            self.disabled = false;
        end);

        holder.GetValue = function(self)
            local r, g, b, a = self.sample:GetVertexColor();
            return GetFloorValue(r), GetFloorValue(g), GetFloorValue(b), GetFloorValue(a);
        end

        holder.SetValue = function(self, r, g, b, a)
            if type(r) == 'table' then
                r, g, b, a = r.r or r[1], r.g or r[2], r.b or r[3], r.a or r[4];
            end

            r, g, b = GetFloorValue(r), GetFloorValue(g), GetFloorValue(b);
            a       = a and self.hasOpacity and GetFloorValue(a) or 1;

            self.sample:SetVertexColor(r, g, b, a);
            self.background:SetAlpha(a);

            if self.OnValueChanged then
                self:OnValueChanged(r, g, b, a);
            end
        end

        holder.hasOpacity = hasOpacity;

        holder.cancelFunc = function()
            holder:SetValue(holder.r, holder.g, holder.b, holder.hasOpacity and (1 - holder.opacity) or 1);
            ColorPickerButtons:Hide();
        end

        holder.opacityFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB();
            local a = 1 - OpacitySliderFrame:GetValue();

            holder:SetValue(r, g, b, a);
        end

        holder.swatchFunc = function()
            if holder.opening then
                return;
            end

            local r, g, b = ColorPickerFrame:GetColorRGB();
            local a = 1 - OpacitySliderFrame:GetValue();

            holder:SetValue(r, g, b, a);
        end

        holder.SetLabel = function(self, text)
            self.Label:SetText(text);
            self:SetHitRectInsets(0, -(self.Label:GetStringWidth() + 2), 0, 0);
        end

        holder.SetTooltip = function(self, tooltip)
            self.tooltip = tooltip;
        end

        holder.AddToSearch = AddToSearch;

        E.CreateTooltip(holder);

        return holder;
    end

    ColorPickerFrame:HookScript('OnHide', function()
        ColorPickerButtons:Hide();
    end);

    ColorPickerOkayButton:HookScript('OnClick', function()
        StripesDB.last_used_hex_color = U.RGB2HEX(ColorPickerFrame:GetColorRGB());

        LastUsedColorButton:SetColor(StripesDB.last_used_hex_color);
        LastUsedColorButton:SetShown(true);
    end);
end

E.CreateColorPicker = function(parent, color)
    if type(color) ~= 'table' then
        color = {1, 1, 1, 1};
    end

    local hasOpacity = false;

    if not color.r and color[4] then
        hasOpacity = color[4];
        color = color;
    elseif color.a then
        hasOpacity = color.a;
        color = { color.r, color.g, color.b, color.a };
    elseif color.r and color.g and color.b then
        hasOpacity = false;
        color = { color.r, color.g, color.b };
    end

    local colorpicker = NewColorPicker(parent, hasOpacity);
    colorpicker:SetValue(unpack(color));

    colorpicker.type = 'ColorPicker';

    return colorpicker;
end

E.CreatePseudoLink = function(parent)
    local link = Mixin(CreateFrame('EditBox', nil, parent), E.PixelPerfectMixin);
    link:SetH(16);

    link:SetFontObject('StripesCategoryButtonNormalFont');

    link:SetBlinkSpeed(0);
    link:SetAutoFocus(false);
    link:EnableKeyboard(false);
    link:SetHitRectInsets(0, 0, 0, 0);
    link:SetCursorPosition(0);

    link:SetScript('OnKeyDown', function() end);
    link:SetScript('OnMouseUp', function(self)
        if self:IsEnabled() then
            if self:IsMouseOver() then
                self:HighlightText();
            else
                self:HighlightText(0, 0);
            end
        end
    end);

    link.tooltip = L['PSEUDOLINK_TOOLTIP'];

    link.hidden = link:CreateFontString(nil, 'ARTWORK', 'StripesCategoryButtonNormalFont');
    link.hidden:Hide();

    link:SetScript('OnTextChanged', function(self)
        self.hidden:SetText(self:GetText());
        self:SetWidth(self.hidden:GetStringWidth() + 0.5);
        self:SetCursorPosition(0);
    end);

    link:HookScript('OnEnter', function(self)
        if self:IsEnabled() then
            self:HighlightText();
            self:SetFocus();

            if self.tooltip then
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 0, 4);
                GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true);
                GameTooltip:Show();
            end
        end
    end);

    link:HookScript('OnLeave', function(self)
        if self:IsEnabled() then
            self:HighlightText(0, 0);
            self:ClearFocus();

            GameTooltip_Hide();
        end
    end);

    return link;
end

function Module:StartUp()
    local colorButton;
    for i, hexColor in ipairs(ColorPickerButtons.colors) do
        colorButton = CreateColorButton(hexColor);
        colorButton:SetPosition('TOPRIGHT', ColorPickerButtons, 'TOPRIGHT', 0, -((i-1) * 21));
    end

    LastUsedColorButton = CreateColorButton();
    LastUsedColorButton:SetPosition('TOPLEFT', ColorPickerFrame, 'TOPRIGHT', 0, -6);
    if StripesDB.last_used_hex_color then
        LastUsedColorButton:SetColor(StripesDB.last_used_hex_color);
        LastUsedColorButton:SetShown(true);
    else
        LastUsedColorButton:SetShown(false);
    end
end