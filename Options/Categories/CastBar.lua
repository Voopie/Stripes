local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CastBar');

local LSM = S.Libraries.LSM;

O.frame.Left.CastBar, O.frame.Right.CastBar = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CASTBAR']), 'castbar', 5);
local button = O.frame.Left.CastBar;
local panel = O.frame.Right.CastBar;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_CAST_BAR_TAB_COMMON']),
    },
    [2] = {
        name  = 'CustomCastsTab',
        title = string.upper(L['OPTIONS_CAST_BAR_TAB_CUSTOMCASTS']),
    },
};

local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local NAME_WIDTH = 200;

local function AddCustomCast(spellId)
    if O.db.castbar_custom_casts_data[spellId] then
        return;
    end

    O.db.castbar_custom_casts_data[spellId] = {
        id            = spellId,
        enabled       = true,
        color_enabled = false,
        color         = { 0, 0.9, 1, 1 },
        glow_enabled  = true,
        glow_type     = 1,
    };
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

local DataCustomCastsRow = {};

local function CreateCustomCastRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.castbar_custom_casts_data[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.IdText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.IdText:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.IdText:SetSize(60, ROW_HEIGHT);
    frame.IdText:SetTextColor(0.67, 0.67, 0.67);

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.IdText, 'RIGHT', 2, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 8, ROW_HEIGHT - 8);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.Icon, 'RIGHT', 8, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame.ColorEnabled = E.CreateCheckButton(frame);
    frame.ColorEnabled:SetPosition('LEFT', frame.NameText, 'RIGHT', 4, 0);
    frame.ColorEnabled.Callback = function(self)
        O.db.castbar_custom_casts_data[self:GetParent().id].color_enabled = self:GetChecked();
        frame.ColorPicker:SetEnabled(self:GetChecked());
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.ColorEnabled:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.ColorEnabled:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.ColorPicker = E.CreateColorPicker(frame);
    frame.ColorPicker:SetPosition('LEFT', frame.ColorEnabled, 'RIGHT', 2, 0);
    frame.ColorPicker.OnValueChanged = function(self, r, g, b, a)
        O.db.castbar_custom_casts_data[self:GetParent().id].color[1] = r;
        O.db.castbar_custom_casts_data[self:GetParent().id].color[2] = g;
        O.db.castbar_custom_casts_data[self:GetParent().id].color[3] = b;
        O.db.castbar_custom_casts_data[self:GetParent().id].color[4] = a or 1;

        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.ColorPicker:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.ColorPicker:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.GlowEnabled = E.CreateCheckButton(frame);
    frame.GlowEnabled:SetPosition('LEFT', frame.ColorPicker, 'RIGHT', 8, 0);
    frame.GlowEnabled.Callback = function(self)
        O.db.castbar_custom_casts_data[self:GetParent().id].glow_enabled = self:GetChecked();
        frame.GlowType:SetEnabled(self:GetChecked());
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.GlowEnabled:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.GlowEnabled:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.GlowType = E.CreateDropdown('plain', frame);
    frame.GlowType:SetPosition('LEFT', frame.GlowEnabled, 'RIGHT', 4, 0);
    frame.GlowType:SetSize(130, 20);
    frame.GlowType:SetList(O.Lists.glow_type_short);
    frame.GlowType.OnValueChangedCallback = function(self, value)
        O.db.castbar_custom_casts_data[self:GetParent().id].glow_type = tonumber(value);
        S:GetNameplateModule('Handler'):UpdateAll();
    end

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
        local id = tonumber(self:GetParent().id);

        if not id then
            return;
        end

        if O.db.castbar_custom_casts_data[id] then
            O.db.castbar_custom_casts_data[id] = nil;

            panel:UpdateCustomCastsScroll();

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

local function UpdateCustomCastRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.castbar_custom_casts_scrollarea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.castbar_custom_casts_scrollarea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataCustomCastsRow[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataCustomCastsRow[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
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
    frame.ColorEnabled:SetChecked(frame.color_enabled);
    frame.ColorPicker:SetValue(unpack(frame.color));
    frame.ColorPicker:SetEnabled(frame.color_enabled);
    frame.GlowEnabled:SetChecked(frame.glow_enabled);
    frame.GlowType:SetEnabled(frame.glow_enabled);
    frame.GlowType:SetValue(frame.glow_type);
    frame.GlowType:UpdateScrollArea();
end

panel.UpdateCustomCastsScroll = function()
    wipe(DataCustomCastsRow);
    panel.CastBarCustomCastsFramePool:ReleaseAll();

    local index = 0;
    local frame, isNew;

    for id, data in pairs(O.db.castbar_custom_casts_data) do
        index = index + 1;

        frame, isNew = panel.CastBarCustomCastsFramePool:Acquire();

        table.insert(DataCustomCastsRow, frame);

        if isNew then
            CreateCustomCastRow(frame);
        end

        frame.index         = index;
        frame.id            = id;
        frame.enabled       = data.enabled;
        frame.glow_enabled  = data.glow_enabled;
        frame.glow_type     = data.glow_type;
        frame.color_enabled = data.color_enabled;
        frame.color         = data.color;

        UpdateCustomCastRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.castbar_custom_casts_scrollchild, panel.castbar_custom_casts_editframe:GetWidth(), panel.castbar_custom_casts_editframe:GetHeight() - (panel.castbar_custom_casts_editframe:GetHeight() % ROW_HEIGHT + 8));
end

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.castbar_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['CommonTab'].Content);
    self.castbar_texture_value:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.castbar_texture_value:SetSize(200, 20);
    self.castbar_texture_value:SetList(LSM:HashTable('statusbar'));
    self.castbar_texture_value:SetValue(O.db.castbar_texture_value);
    self.castbar_texture_value:SetLabel(L['OPTIONS_TEXTURE']);
    self.castbar_texture_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.castbar_texture_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP'], self.Tabs[1]);
    self.castbar_texture_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_texture_value = value;
        Handler:UpdateAll();
    end

    self.castbar_text_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_value:SetPosition('TOPLEFT', self.castbar_texture_value, 'BOTTOMLEFT', 0, -12);
    self.castbar_text_font_value:SetSize(160, 20);
    self.castbar_text_font_value:SetList(LSM:HashTable('font'));
    self.castbar_text_font_value:SetValue(O.db.castbar_text_font_value);
    self.castbar_text_font_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE']);
    self.castbar_text_font_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE'], self.Tabs[1]);
    self.castbar_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_value = value;
        Handler:UpdateAll();
    end

    self.castbar_text_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_size:SetPosition('LEFT', self.castbar_text_font_value, 'RIGHT', 12, 0);
    self.castbar_text_font_size:SetValues(O.db.castbar_text_font_size, 3, 28, 1);
    self.castbar_text_font_size:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE']);
    self.castbar_text_font_size:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE'], self.Tabs[1]);
    self.castbar_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.castbar_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_flag:SetPosition('LEFT', self.castbar_text_font_size, 'RIGHT', 12, 0);
    self.castbar_text_font_flag:SetSize(160, 20);
    self.castbar_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.castbar_text_font_flag:SetValue(O.db.castbar_text_font_flag);
    self.castbar_text_font_flag:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG']);
    self.castbar_text_font_flag:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG'], self.Tabs[1]);
    self.castbar_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.castbar_text_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_shadow:SetPosition('LEFT', self.castbar_text_font_flag, 'RIGHT', 12, 0);
    self.castbar_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.castbar_text_font_shadow:SetChecked(O.db.castbar_text_font_shadow);
    self.castbar_text_font_shadow:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW']);
    self.castbar_text_font_shadow:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW'], self.Tabs[1]);
    self.castbar_text_font_shadow.Callback = function(self)
        O.db.castbar_text_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_border_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_enabled:SetPosition('TOPLEFT', self.castbar_text_font_value, 'BOTTOMLEFT', 0, -12);
    self.castbar_border_enabled:SetLabel(L['OPTIONS_CAST_BAR_BORDER_ENABLED']);
    self.castbar_border_enabled:SetChecked(O.db.castbar_border_enabled);
    self.castbar_border_enabled:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_ENABLED_TOOLTIP']);
    self.castbar_border_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_enabled.Callback = function(self)
        O.db.castbar_border_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_border_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_color:SetPosition('LEFT', self.castbar_border_enabled.Label, 'RIGHT', 12, 0);
    self.castbar_border_color:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_COLOR_TOOLTIP']);
    self.castbar_border_color:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_color:SetValue(unpack(O.db.castbar_border_color));
    self.castbar_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_border_color[1] = r;
        O.db.castbar_border_color[2] = g;
        O.db.castbar_border_color[3] = b;
        O.db.castbar_border_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_border_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_size:SetPosition('LEFT', self.castbar_border_color, 'RIGHT', 12, 0);
    self.castbar_border_size:SetValues(O.db.castbar_border_size, 0.5, 10, 0.5);
    self.castbar_border_size:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_SIZE_TOOLTIP']);
    self.castbar_border_size:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_SIZE_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_border_size = tonumber(value);
        Handler:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_border_enabled, 'BOTTOMLEFT', 0, -6);
    Delimiter:SetW(self:GetWidth());

    local ResetCastBarColorsButton = E.CreateTextureButton(self.TabsFrames['CommonTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetCastBarColorsButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 4, -4);
    ResetCastBarColorsButton:SetTooltip(L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP']);
    ResetCastBarColorsButton:AddToSearch(button, L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP'], self.Tabs[1]);
    ResetCastBarColorsButton.Callback = function()
        panel.castbar_start_cast_color:SetValue(unpack(O.DefaultValues.castbar_start_cast_color));
        panel.castbar_start_channel_color:SetValue(unpack(O.DefaultValues.castbar_start_channel_color));
        panel.castbar_noninterruptible_color:SetValue(unpack(O.DefaultValues.castbar_noninterruptible_color));
        panel.castbar_failed_cast_color:SetValue(unpack(O.DefaultValues.castbar_failed_cast_color));
        panel.castbar_interrupt_ready_tick_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_tick_color));
        panel.castbar_interrupt_ready_in_time_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_in_time_color));
        panel.castbar_interrupt_not_ready_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_not_ready_color));
    end

    self.castbar_start_cast_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_start_cast_color:SetPosition('LEFT', ResetCastBarColorsButton, 'RIGHT', 16, 0);
    self.castbar_start_cast_color:SetLabel(L['OPTIONS_CAST_BAR_START_CAST_COLOR']);
    self.castbar_start_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP']);
    self.castbar_start_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_start_cast_color:SetValue(unpack(O.db.castbar_start_cast_color));
    self.castbar_start_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_cast_color[1] = r;
        O.db.castbar_start_cast_color[2] = g;
        O.db.castbar_start_cast_color[3] = b;
        O.db.castbar_start_cast_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_start_channel_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_start_channel_color:SetPosition('LEFT', self.castbar_start_cast_color.Label, 'RIGHT', 12, 0);
    self.castbar_start_channel_color:SetLabel(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR']);
    self.castbar_start_channel_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP']);
    self.castbar_start_channel_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_start_channel_color:SetValue(unpack(O.db.castbar_start_channel_color));
    self.castbar_start_channel_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_channel_color[1] = r;
        O.db.castbar_start_channel_color[2] = g;
        O.db.castbar_start_channel_color[3] = b;
        O.db.castbar_start_channel_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_noninterruptible_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_noninterruptible_color:SetPosition('LEFT', self.castbar_start_channel_color.Label, 'RIGHT', 12, 0);
    self.castbar_noninterruptible_color:SetLabel(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR']);
    self.castbar_noninterruptible_color:SetTooltip(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP']);
    self.castbar_noninterruptible_color:AddToSearch(button, L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_noninterruptible_color:SetValue(unpack(O.db.castbar_noninterruptible_color));
    self.castbar_noninterruptible_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_noninterruptible_color[1] = r;
        O.db.castbar_noninterruptible_color[2] = g;
        O.db.castbar_noninterruptible_color[3] = b;
        O.db.castbar_noninterruptible_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_failed_cast_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_failed_cast_color:SetPosition('LEFT', self.castbar_noninterruptible_color.Label, 'RIGHT', 12, 0);
    self.castbar_failed_cast_color:SetLabel(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR']);
    self.castbar_failed_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP']);
    self.castbar_failed_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_failed_cast_color:SetValue(unpack(O.db.castbar_failed_cast_color));
    self.castbar_failed_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_failed_cast_color[1] = r;
        O.db.castbar_failed_cast_color[2] = g;
        O.db.castbar_failed_cast_color[3] = b;
        O.db.castbar_failed_cast_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_show_interrupt_ready_tick = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_interrupt_ready_tick:SetPosition('TOPLEFT', ResetCastBarColorsButton, 'BOTTOMLEFT', -1, -12);
    self.castbar_show_interrupt_ready_tick:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP']);
    self.castbar_show_interrupt_ready_tick:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_interrupt_ready_tick:SetChecked(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_show_interrupt_ready_tick.Callback = function(self)
        O.db.castbar_show_interrupt_ready_tick = self:GetChecked();

        panel.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_ready_tick_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_ready_tick_color:SetPosition('LEFT', self.castbar_show_interrupt_ready_tick.Label, 'RIGHT', 10, 0);
    self.castbar_interrupt_ready_tick_color:SetLabel(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK']);
    self.castbar_interrupt_ready_tick_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_tick_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_ready_tick_color:SetValue(unpack(O.db.castbar_interrupt_ready_tick_color));
    self.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_interrupt_ready_tick_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_tick_color[1] = r;
        O.db.castbar_interrupt_ready_tick_color[2] = g;
        O.db.castbar_interrupt_ready_tick_color[3] = b;
        O.db.castbar_interrupt_ready_tick_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_use_interrupt_ready_in_time_color = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_use_interrupt_ready_in_time_color:SetPosition('TOPLEFT', self.castbar_show_interrupt_ready_tick, 'BOTTOMLEFT', 0, -12);
    self.castbar_use_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_use_interrupt_ready_in_time_color:SetChecked(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_use_interrupt_ready_in_time_color.Callback = function(self)
        O.db.castbar_use_interrupt_ready_in_time_color = self:GetChecked();

        panel.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_ready_in_time_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_ready_in_time_color:SetPosition('LEFT', self.castbar_use_interrupt_ready_in_time_color.Label, 'RIGHT', 10, 0);
    self.castbar_interrupt_ready_in_time_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR']);
    self.castbar_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_ready_in_time_color:SetValue(unpack(O.db.castbar_interrupt_ready_in_time_color));
    self.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_interrupt_ready_in_time_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_in_time_color[1] = r;
        O.db.castbar_interrupt_ready_in_time_color[2] = g;
        O.db.castbar_interrupt_ready_in_time_color[3] = b;
        O.db.castbar_interrupt_ready_in_time_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_use_interrupt_not_ready_color = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_use_interrupt_not_ready_color:SetPosition('TOPLEFT', self.castbar_use_interrupt_ready_in_time_color, 'BOTTOMLEFT', 0, -12);
    self.castbar_use_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_use_interrupt_not_ready_color:SetChecked(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_use_interrupt_not_ready_color.Callback = function(self)
        O.db.castbar_use_interrupt_not_ready_color = self:GetChecked();

        panel.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_not_ready_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_not_ready_color:SetPosition('LEFT', self.castbar_use_interrupt_not_ready_color.Label, 'RIGHT', 10, 0)
    self.castbar_interrupt_not_ready_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR']);
    self.castbar_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_not_ready_color:SetValue(unpack(O.db.castbar_interrupt_not_ready_color));
    self.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_interrupt_not_ready_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_not_ready_color[1] = r;
        O.db.castbar_interrupt_not_ready_color[2] = g;
        O.db.castbar_interrupt_not_ready_color[3] = b;
        O.db.castbar_interrupt_not_ready_color[4] = a or 1;

        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', ResetCastBarColorsButton, 'BOTTOMLEFT', -4, -100);
    Delimiter:SetW(self:GetWidth());

    self.castbar_on_hp_bar = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_on_hp_bar:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -8);
    self.castbar_on_hp_bar:SetLabel(L['OPTIONS_CAST_BAR_ON_HP_BAR']);
    self.castbar_on_hp_bar:SetTooltip(L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP']);
    self.castbar_on_hp_bar:AddToSearch(button, L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP'], self.Tabs[1]);
    self.castbar_on_hp_bar:SetChecked(O.db.castbar_on_hp_bar);
    self.castbar_on_hp_bar.Callback = function(self)
        O.db.castbar_on_hp_bar = self:GetChecked();

        panel.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);

        Handler:UpdateAll();
    end

    self.castbar_icon_large = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_icon_large:SetPosition('TOPLEFT', self.castbar_on_hp_bar, 'BOTTOMLEFT', 0, -8);
    self.castbar_icon_large:SetLabel(L['OPTIONS_CAST_BAR_ICON_LARGE']);
    self.castbar_icon_large:SetTooltip(L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP']);
    self.castbar_icon_large:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP'], self.Tabs[1]);
    self.castbar_icon_large:SetChecked(O.db.castbar_icon_large);
    self.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);
    self.castbar_icon_large.Callback = function(self)
        O.db.castbar_icon_large = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_icon_right_side = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_icon_right_side:SetPosition('LEFT', self.castbar_icon_large.Label, 'RIGHT', 12, 0);
    self.castbar_icon_right_side:SetLabel(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE']);
    self.castbar_icon_right_side:SetTooltip(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP']);
    self.castbar_icon_right_side:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP'], self.Tabs[1]);
    self.castbar_icon_right_side:SetChecked(O.db.castbar_icon_right_side);
    self.castbar_icon_right_side.Callback = function(self)
        O.db.castbar_icon_right_side = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_icon_notinterruptible = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_icon_notinterruptible:SetPosition('TOPLEFT', self.castbar_icon_large, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_icon_notinterruptible:SetLabel(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE']);
    self.castbar_show_icon_notinterruptible:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP']);
    self.castbar_show_icon_notinterruptible:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_icon_notinterruptible:SetChecked(O.db.castbar_show_icon_notinterruptible);
    self.castbar_show_icon_notinterruptible.Callback = function(self)
        O.db.castbar_show_icon_notinterruptible = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_shield = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_shield:SetPosition('LEFT', self.castbar_show_icon_notinterruptible.Label, 'RIGHT', 12, 0);
    self.castbar_show_shield:SetLabel(L['OPTIONS_CAST_BAR_SHOW_SHIELD']);
    self.castbar_show_shield:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP']);
    self.castbar_show_shield:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_shield:SetChecked(O.db.castbar_show_shield);
    self.castbar_show_shield.Callback = function(self)
        O.db.castbar_show_shield = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_timer_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_timer_enabled:SetPosition('TOPLEFT', self.castbar_show_icon_notinterruptible, 'BOTTOMLEFT', 0, -8);
    self.castbar_timer_enabled:SetLabel(L['OPTIONS_CAST_BAR_TIMER_ENABLED']);
    self.castbar_timer_enabled:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP']);
    self.castbar_timer_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.castbar_timer_enabled:SetChecked(O.db.castbar_timer_enabled);
    self.castbar_timer_enabled.Callback = function(self)
        O.db.castbar_timer_enabled = self:GetChecked();

        panel.castbar_timer_format:SetEnabled(O.db.castbar_timer_enabled);

        Handler:UpdateAll();
    end

    self.castbar_timer_format = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.castbar_timer_format:SetPosition('LEFT', self.castbar_timer_enabled.Label, 'RIGHT', 12, 0);
    self.castbar_timer_format:SetSize(200, 20);
    self.castbar_timer_format:SetList(O.Lists.castbar_timer_format);
    self.castbar_timer_format:SetValue(O.db.castbar_timer_format);
    self.castbar_timer_format:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FORMAT_TOOLTIP']);
    self.castbar_timer_format:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FORMAT_TOOLTIP'], self.Tabs[1]);
    self.castbar_timer_format:SetEnabled(O.db.castbar_timer_enabled);
    self.castbar_timer_format.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_format = tonumber(value);
        Handler:UpdateAll();
    end

    self.who_interrupted_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.who_interrupted_enabled:SetPosition('TOPLEFT', self.castbar_timer_enabled, 'BOTTOMLEFT', 0, -8);
    self.who_interrupted_enabled:SetLabel(L['OPTIONS_WHO_INTERRUPTED_ENABLED']);
    self.who_interrupted_enabled:SetTooltip(L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP']);
    self.who_interrupted_enabled:AddToSearch(button, L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.who_interrupted_enabled:SetChecked(O.db.who_interrupted_enabled);
    self.who_interrupted_enabled.Callback = function(self)
        O.db.who_interrupted_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_tradeskills = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_tradeskills:SetPosition('TOPLEFT', self.who_interrupted_enabled, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_tradeskills:SetLabel(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS']);
    self.castbar_show_tradeskills:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP']);
    self.castbar_show_tradeskills:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_tradeskills:SetChecked(O.db.castbar_show_tradeskills);
    self.castbar_show_tradeskills.Callback = function(self)
        O.db.castbar_show_tradeskills = self:GetChecked();
        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Custom Cast Tab -----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.castbar_custom_casts_enabled = E.CreateCheckButton(self.TabsFrames['CustomCastsTab'].Content);
    self.castbar_custom_casts_enabled:SetPosition('TOPLEFT', self.TabsFrames['CustomCastsTab'].Content, 'TOPLEFT', 0, -4);
    self.castbar_custom_casts_enabled:SetLabel(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED']);
    self.castbar_custom_casts_enabled:SetTooltip(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED_TOOLTIP']);
    self.castbar_custom_casts_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.castbar_custom_casts_enabled:SetChecked(O.db.castbar_custom_casts_enabled);
    self.castbar_custom_casts_enabled.Callback = function(self)
        O.db.castbar_custom_casts_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_custom_casts_editbox = E.CreateEditBox(self.TabsFrames['CustomCastsTab'].Content);
    self.castbar_custom_casts_editbox:SetPosition('TOPLEFT', self.castbar_custom_casts_enabled, 'BOTTOMLEFT', 5, -8);
    self.castbar_custom_casts_editbox:SetSize(220, 22);
    self.castbar_custom_casts_editbox.useLastValue = false;
    self.castbar_custom_casts_editbox:SetInstruction(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_EDITBOX_ENTER_ID']);
    self.castbar_custom_casts_editbox:SetScript('OnEnterPressed', function(self)
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

        AddCustomCast(tonumber(saveId));

        panel:UpdateCustomCastsScroll();

        self:SetText('');

        Handler:UpdateAll();
    end);

    self.castbar_custom_casts_editframe = CreateFrame('Frame', nil, self.TabsFrames['CustomCastsTab'].Content, 'BackdropTemplate');
    self.castbar_custom_casts_editframe:SetPoint('TOPLEFT', self.castbar_custom_casts_editbox, 'BOTTOMLEFT', -5, -8);
    self.castbar_custom_casts_editframe:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0);
    self.castbar_custom_casts_editframe:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.castbar_custom_casts_editframe:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.castbar_custom_casts_scrollchild, self.castbar_custom_casts_scrollarea = E.CreateScrollFrame(self.castbar_custom_casts_editframe, ROW_HEIGHT);
    PixelUtil.SetPoint(self.castbar_custom_casts_scrollarea.ScrollBar, 'TOPLEFT', self.castbar_custom_casts_scrollarea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.castbar_custom_casts_scrollarea.ScrollBar, 'BOTTOMLEFT', self.castbar_custom_casts_scrollarea, 'BOTTOMRIGHT', -8, 0);

    self.CastBarCustomCastsFramePool = CreateFramePool('Frame', self.castbar_custom_casts_scrollchild, 'BackdropTemplate');

    self:UpdateCustomCastsScroll();

    self.ProfilesDropdown = E.CreateDropdown('plain', self.TabsFrames['CustomCastsTab'].Content);
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.castbar_custom_casts_editframe, 'TOPRIGHT', 0, 8);
    self.ProfilesDropdown:SetSize(157, 22);
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);
        if not index then
            self:SetValue(0);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data);
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data = U.DeepCopy(StripesDB.profiles[index].castbar_custom_casts_data);
        else
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data = U.Merge(StripesDB.profiles[index].castbar_custom_casts_data, StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data);
        end

        self:SetValue(0);

        panel:UpdateCustomCastsScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self.TabsFrames['CustomCastsTab'].Content);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');

    self:UpdateProfilesDropdown();
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    self:UpdateCustomCastsScroll();
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end