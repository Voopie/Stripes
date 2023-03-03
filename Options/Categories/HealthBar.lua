local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_HealthBar');

local LSM = S.Libraries.LSM;

O.frame.Left.HealthBar, O.frame.Right.HealthBar = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_HEALTHBAR']), 'healthbar', 4);
local button = O.frame.Left.HealthBar;
local panel = O.frame.Right.HealthBar;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_HEALTHBAR_TAB_COMMON']),
    },
    [2] = {
        name = 'ColorsTab',
        title = string.upper(L['OPTIONS_HEALTHBAR_TAB_COLORS']),
    },
    [3] = {
        name  = 'TargetIndicatorTab',
        title = string.upper(L['OPTIONS_HEALTHBAR_TAB_TARGET_INDICATOR']),
    },
    [4] = {
        name  = 'ThreatTab',
        title = string.upper(L['OPTIONS_HEALTHBAR_TAB_THREAT']),
    },
    [5] = {
        name  = 'ExecutionTab',
        title = string.upper(L['OPTIONS_HEALTHBAR_TAB_EXECUTION']),
    },
};

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.health_bar_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['CommonTab'].Content);
    self.health_bar_texture_value:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -8);
    self.health_bar_texture_value:SetSize(185, 20);
    self.health_bar_texture_value:SetList(LSM:HashTable('statusbar'));
    self.health_bar_texture_value:SetValue(O.db.health_bar_texture_value);
    self.health_bar_texture_value:SetLabel(L['OPTIONS_TEXTURE']);
    self.health_bar_texture_value:SetTooltip(L['OPTIONS_HEALTH_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.health_bar_texture_value:AddToSearch(button, L['OPTIONS_HEALTH_BAR_TEXTURE_VALUE_TOOLTIP'], self.Tabs[1]);
    self.health_bar_texture_value.OnValueChangedCallback = function(_, value)
        O.db.health_bar_texture_value = value;
        Stripes:UpdateAll();
    end

    self.health_bar_background_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['CommonTab'].Content);
    self.health_bar_background_texture_value:SetPosition('LEFT', self.health_bar_texture_value, 'RIGHT', 16, 0);
    self.health_bar_background_texture_value:SetSize(185, 20);
    self.health_bar_background_texture_value:SetList(LSM:HashTable('statusbar'));
    self.health_bar_background_texture_value:SetValue(O.db.health_bar_background_texture_value);
    self.health_bar_background_texture_value:SetLabel(L['BACKGROUND']);
    self.health_bar_background_texture_value:SetTooltip(L['OPTIONS_HEALTH_BAR_BACKGROUND_TEXTURE_VALUE_TOOLTIP']);
    self.health_bar_background_texture_value:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BACKGROUND_TEXTURE_VALUE_TOOLTIP'], self.Tabs[1]);
    self.health_bar_background_texture_value.OnValueChangedCallback = function(_, value)
        O.db.health_bar_background_texture_value = value;
        Stripes:UpdateAll();
    end

    self.health_bar_background_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.health_bar_background_color:SetPosition('LEFT', self.health_bar_background_texture_value, 'RIGHT', 16, 0);
    self.health_bar_background_color:SetTooltip(L['OPTIONS_HEALTH_BAR_BACKGROUND_COLOR_TOOLTIP']);
    self.health_bar_background_color:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BACKGROUND_COLOR_TOOLTIP'], self.Tabs[1]);
    self.health_bar_background_color:SetValue(unpack(O.db.health_bar_background_color));
    self.health_bar_background_color.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_background_color[1] = r;
        O.db.health_bar_background_color[2] = g;
        O.db.health_bar_background_color[3] = b;
        O.db.health_bar_background_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    local BorderHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_HEADER_BORDER']);
    BorderHeader:SetPosition('TOPLEFT', self.health_bar_texture_value, 'BOTTOMLEFT', 0, -8);
    BorderHeader:SetW(self:GetWidth());

    self.health_bar_border_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.health_bar_border_color:SetPosition('TOPLEFT', BorderHeader, 'BOTTOMLEFT', -5, -4);
    self.health_bar_border_color:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_COLOR']);
    self.health_bar_border_color:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_COLOR_TOOLTIP']);
    self.health_bar_border_color:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BORDER_COLOR_TOOLTIP'], self.Tabs[2]);
    self.health_bar_border_color:SetValue(unpack(O.db.health_bar_border_color));
    self.health_bar_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_border_color[1] = r;
        O.db.health_bar_border_color[2] = g;
        O.db.health_bar_border_color[3] = b;
        O.db.health_bar_border_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_border_selected_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.health_bar_border_selected_color:SetPosition('LEFT', self.health_bar_border_color.Label, 'RIGHT', 12, 0);
    self.health_bar_border_selected_color:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_SELECTED_COLOR']);
    self.health_bar_border_selected_color:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_SELECTED_COLOR_TOOLTIP']);
    self.health_bar_border_selected_color:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BORDER_SELECTED_COLOR_TOOLTIP'], self.Tabs[2]);
    self.health_bar_border_selected_color:SetValue(unpack(O.db.health_bar_border_selected_color));
    self.health_bar_border_selected_color.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_border_selected_color[1] = r;
        O.db.health_bar_border_selected_color[2] = g;
        O.db.health_bar_border_selected_color[3] = b;
        O.db.health_bar_border_selected_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_border_hide = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.health_bar_border_hide:SetPosition('LEFT', self.health_bar_border_selected_color.Label, 'RIGHT', 12, 0);
    self.health_bar_border_hide:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_HIDE']);
    self.health_bar_border_hide:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_HIDE_TOOLTIP']);
    self.health_bar_border_hide:SetChecked(O.db.health_bar_border_hide);
    self.health_bar_border_hide:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BORDER_HIDE_TOOLTIP'], self.Tabs[1]);
    self.health_bar_border_hide.Callback = function(self)
        O.db.health_bar_border_hide = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_border_same_color = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.health_bar_border_same_color:SetPosition('LEFT', self.health_bar_border_hide.Label, 'RIGHT', 12, 0);
    self.health_bar_border_same_color:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_SAME_COLOR']);
    self.health_bar_border_same_color:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_SAME_COLOR_TOOLTIP']);
    self.health_bar_border_same_color:SetChecked(O.db.health_bar_border_hide);
    self.health_bar_border_same_color:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BORDER_SAME_COLOR_TOOLTIP'], self.Tabs[1]);
    self.health_bar_border_same_color.Callback = function(self)
        O.db.health_bar_border_same_color = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_border_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_border_size:SetPosition('LEFT', self.health_bar_border_same_color.Label, 'RIGHT', 12, 0);
    self.health_bar_border_size:SetValues(O.db.health_bar_border_size, 0.5, 10, 0.5);
    self.health_bar_border_size:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_SIZE_TOOLTIP']);
    self.health_bar_border_size:AddToSearch(button, L['OPTIONS_HEALTH_BAR_BORDER_SIZE_TOOLTIP'], self.Tabs[1]);
    self.health_bar_border_size.OnValueChangedCallback = function(_, value)
        O.db.health_bar_border_size = tonumber(value);
        Stripes:UpdateAll();
    end

    local CustomBorderHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_HEADER_CUSTOM_BORDER']);
    CustomBorderHeader:SetPosition('TOPLEFT', self.health_bar_border_color, 'BOTTOMLEFT', 5, -4);
    CustomBorderHeader:SetW(self:GetWidth());

    self.health_bar_custom_border_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_enabled:SetPosition('TOPLEFT', CustomBorderHeader, 'BOTTOMLEFT', 0, -8);
    self.health_bar_custom_border_enabled:SetLabel(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_ENABLED']);
    self.health_bar_custom_border_enabled:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_ENABLED_TOOLTIP']);
    self.health_bar_custom_border_enabled:SetChecked(O.db.health_bar_custom_border_enabled);
    self.health_bar_custom_border_enabled:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_enabled.Callback = function(self)
        O.db.health_bar_custom_border_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_path = E.CreateEditBox(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_path:SetPosition('LEFT', self.health_bar_custom_border_enabled.Label, 'RIGHT', 24, 0);
    self.health_bar_custom_border_path:SetSize(420, 22);
    self.health_bar_custom_border_path:SetText(O.db.health_bar_custom_border_path);
    self.health_bar_custom_border_path:SetInstruction(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_PATH']);
    self.health_bar_custom_border_path:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_PATH']);
    self.health_bar_custom_border_path:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_PATH'], self.Tabs[1]);
    self.health_bar_custom_border_path.Callback = function(self)
        local path = strtrim(self:GetText());

        if not path or path == '' then
            path = O.DefaultValues.health_bar_custom_border_path;
        end

        O.db.health_bar_custom_border_path = path;

        self:SetText(path);

        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_width = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_width:SetPosition('TOPLEFT', self.health_bar_custom_border_enabled, 'BOTTOMLEFT', 0, -28);
    self.health_bar_custom_border_width:SetValues(O.db.health_bar_custom_border_width, 25, 300, 1);
    self.health_bar_custom_border_width:SetLabel(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_WIDTH']);
    self.health_bar_custom_border_width:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_WIDTH_TOOLTIP']);
    self.health_bar_custom_border_width:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_WIDTH_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_width.OnValueChangedCallback = function(_, value)
        O.db.health_bar_custom_border_width = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_height = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_height:SetPosition('LEFT', self.health_bar_custom_border_width, 'RIGHT', 12, 0);
    self.health_bar_custom_border_height:SetValues(O.db.health_bar_custom_border_height, 2, 300, 1);
    self.health_bar_custom_border_height:SetLabel(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT']);
    self.health_bar_custom_border_height:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT_TOOLTIP']);
    self.health_bar_custom_border_height:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_height.OnValueChangedCallback = function(_, value)
        O.db.health_bar_custom_border_height = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_height_minus = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_height_minus:SetPosition('LEFT', self.health_bar_custom_border_height, 'RIGHT', 12, 0);
    self.health_bar_custom_border_height_minus:SetValues(O.db.health_bar_custom_border_height_minus, 2, 300, 1);
    self.health_bar_custom_border_height_minus:SetLabel(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT_MINUS']);
    self.health_bar_custom_border_height_minus:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT_MINUS_TOOLTIP']);
    self.health_bar_custom_border_height_minus:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_HEIGHT_MINUS_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_height_minus.OnValueChangedCallback = function(_, value)
        O.db.health_bar_custom_border_height_minus = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_x_offset = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_x_offset:SetPosition('TOPLEFT', self.health_bar_custom_border_width, 'BOTTOMLEFT', 0, -28);
    self.health_bar_custom_border_x_offset:SetValues(O.db.health_bar_custom_border_x_offset, -50, 50, 1);
    self.health_bar_custom_border_x_offset:SetLabel(L['OFFSET_X_SHORT']);
    self.health_bar_custom_border_x_offset:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_X_OFFSET_TOOLTIP']);
    self.health_bar_custom_border_x_offset:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_X_OFFSET_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_x_offset.OnValueChangedCallback = function(_, value)
        O.db.health_bar_custom_border_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_bar_custom_border_y_offset = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_custom_border_y_offset:SetPosition('LEFT', self.health_bar_custom_border_x_offset, 'RIGHT', 12, 0);
    self.health_bar_custom_border_y_offset:SetValues(O.db.health_bar_custom_border_y_offset, -50, 50, 1);
    self.health_bar_custom_border_y_offset:SetLabel(L['OFFSET_Y_SHORT']);
    self.health_bar_custom_border_y_offset:SetTooltip(L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_Y_OFFSET_TOOLTIP']);
    self.health_bar_custom_border_y_offset:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CUSTOM_BORDER_Y_OFFSET_TOOLTIP'], self.Tabs[1]);
    self.health_bar_custom_border_y_offset.OnValueChangedCallback = function(_, value)
        O.db.health_bar_custom_border_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    local SparkHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_HEADER_SPARK']);
    SparkHeader:SetPosition('TOPLEFT', self.health_bar_custom_border_x_offset, 'BOTTOMLEFT', 0, -8);
    SparkHeader:SetW(self:GetWidth());

    self.health_bar_spark_show = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.health_bar_spark_show:SetPosition('TOPLEFT', SparkHeader, 'BOTTOMLEFT', 0, -4);
    self.health_bar_spark_show:SetLabel(L['OPTIONS_SHOW']);
    self.health_bar_spark_show:SetTooltip(L['OPTIONS_HEALTH_BAR_SPARK_SHOW_TOOLTIP']);
    self.health_bar_spark_show:SetChecked(O.db.health_bar_spark_show);
    self.health_bar_spark_show:AddToSearch(button, L['OPTIONS_HEALTH_BAR_SPARK_SHOW_TOOLTIP'], self.Tabs[1]);
    self.health_bar_spark_show.Callback = function(self)
        O.db.health_bar_spark_show = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_spark_hide_at_max = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.health_bar_spark_hide_at_max:SetPosition('LEFT', self.health_bar_spark_show.Label, 'RIGHT', 12, 0);
    self.health_bar_spark_hide_at_max:SetLabel(L['OPTIONS_HEALTH_BAR_SPARK_HIDE_AT_MAX_HEALTH']);
    self.health_bar_spark_hide_at_max:SetTooltip(L['OPTIONS_HEALTH_BAR_SPARK_HIDE_AT_MAX_HEALTH_TOOLTIP']);
    self.health_bar_spark_hide_at_max:SetChecked(O.db.health_bar_spark_hide_at_max);
    self.health_bar_spark_hide_at_max:AddToSearch(button, L['OPTIONS_HEALTH_BAR_SPARK_HIDE_AT_MAX_HEALTH_TOOLTIP'], self.Tabs[1]);
    self.health_bar_spark_hide_at_max.Callback = function(self)
        O.db.health_bar_spark_hide_at_max = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_spark_width = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_spark_width:SetPosition('LEFT', self.health_bar_spark_hide_at_max.Label, 'RIGHT', 12, 0);
    self.health_bar_spark_width:SetValues(O.db.health_bar_spark_width, 1, 32, 1);
    self.health_bar_spark_width:SetTooltip(L['OPTIONS_HEALTH_BAR_SPARK_WIDTH_TOOLTIP']);
    self.health_bar_spark_width:AddToSearch(button, L['OPTIONS_HEALTH_BAR_SPARK_WIDTH_TOOLTIP'], self.Tabs[1]);
    self.health_bar_spark_width.OnValueChangedCallback = function(_, value)
        O.db.health_bar_spark_width = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_bar_spark_height = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.health_bar_spark_height:SetPosition('LEFT', self.health_bar_spark_width, 'RIGHT', 12, 0);
    self.health_bar_spark_height:SetValues(O.db.health_bar_spark_height, 1, 32, 1);
    self.health_bar_spark_height:SetTooltip(L['OPTIONS_HEALTH_BAR_SPARK_HEIGHT_TOOLTIP']);
    self.health_bar_spark_height:AddToSearch(button, L['OPTIONS_HEALTH_BAR_SPARK_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.health_bar_spark_height.OnValueChangedCallback = function(_, value)
        O.db.health_bar_spark_height = tonumber(value);
        Stripes:UpdateAll();
    end

    local AbsorbHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_HEADER_ABSORB']);
    AbsorbHeader:SetPosition('TOPLEFT', self.health_bar_spark_show, 'BOTTOMLEFT', 0, -8);
    AbsorbHeader:SetW(self:GetWidth());

    self.absorb_bar_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.absorb_bar_enabled:SetPosition('TOPLEFT', AbsorbHeader, 'BOTTOMLEFT', 0, -4);
    self.absorb_bar_enabled:SetLabel(L['OPTIONS_ABSORB_BAR_ENABLED']);
    self.absorb_bar_enabled:SetTooltip(L['OPTIONS_ABSORB_BAR_ENABLED_TOOLTIP']);
    self.absorb_bar_enabled:SetChecked(O.db.absorb_bar_enabled);
    self.absorb_bar_enabled:AddToSearch(button, L['OPTIONS_ABSORB_BAR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.absorb_bar_enabled.Callback = function(self)
        O.db.absorb_bar_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.absorb_bar_at_top = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.absorb_bar_at_top:SetPosition('LEFT', self.absorb_bar_enabled.Label, 'RIGHT', 12, 0);
    self.absorb_bar_at_top:SetLabel(L['OPTIONS_ABSORB_BAR_AT_TOP']);
    self.absorb_bar_at_top:SetTooltip(L['OPTIONS_ABSORB_BAR_AT_TOP_TOOLTIP']);
    self.absorb_bar_at_top:SetChecked(O.db.absorb_bar_at_top);
    self.absorb_bar_at_top:AddToSearch(button, L['OPTIONS_ABSORB_BAR_AT_TOP_TOOLTIP'], self.Tabs[1]);
    self.absorb_bar_at_top.Callback = function(self)
        O.db.absorb_bar_at_top = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.absorb_text_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_enabled:SetPosition('TOPLEFT', self.absorb_bar_enabled, 'BOTTOMLEFT', 0, -8);
    self.absorb_text_enabled:SetLabel(L['OPTIONS_ABSORB_TEXT_ENABLED']);
    self.absorb_text_enabled:SetTooltip(L['OPTIONS_ABSORB_TEXT_ENABLED_TOOLTIP']);
    self.absorb_text_enabled:SetChecked(O.db.absorb_text_enabled);
    self.absorb_text_enabled:AddToSearch(button, L['OPTIONS_ABSORB_TEXT_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.absorb_text_enabled.Callback = function(self)
        O.db.absorb_text_enabled = self:GetChecked();

        panel.absorb_text_color:SetEnabled(O.db.absorb_text_enabled);

        Stripes:UpdateAll();
    end

    self.absorb_text_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_color:SetPosition('LEFT', self.absorb_text_enabled.Label, 'RIGHT', 12, 0);
    self.absorb_text_color:SetTooltip(L['OPTIONS_ABSORB_TEXT_COLOR_TOOLTIP']);
    self.absorb_text_color:AddToSearch(button, L['OPTIONS_ABSORB_TEXT_COLOR_TOOLTIP'], self.Tabs[1]);
    self.absorb_text_color:SetValue(unpack(O.db.absorb_text_color));
    self.absorb_text_color:SetEnabled(O.db.absorb_text_enabled);
    self.absorb_text_color.OnValueChanged = function(_, r, g, b, a)
        O.db.absorb_text_color[1] = r;
        O.db.absorb_text_color[2] = g;
        O.db.absorb_text_color[3] = b;
        O.db.absorb_text_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.absorb_text_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.absorb_text_font_value:SetSize(160, 20);
    self.absorb_text_font_value:SetList(LSM:HashTable('font'));
    self.absorb_text_font_value:SetValue(O.db.absorb_text_font_value);
    self.absorb_text_font_value:SetTooltip(L['OPTIONS_ABSORB_TEXT_FONT_VALUE']);
    self.absorb_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_font_value = value;
        Stripes:UpdateAll();
    end

    self.absorb_text_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_font_size:SetValues(O.db.absorb_text_font_size, 3, 28, 1);
    self.absorb_text_font_size:SetTooltip(L['OPTIONS_ABSORB_TEXT_FONT_SIZE']);
    self.absorb_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.absorb_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.absorb_text_font_flag:SetSize(160, 20);
    self.absorb_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.absorb_text_font_flag:SetValue(O.db.absorb_text_font_flag);
    self.absorb_text_font_flag:SetTooltip(L['OPTIONS_ABSORB_TEXT_FONT_FLAG']);
    self.absorb_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.absorb_text_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.absorb_text_font_shadow:SetChecked(O.db.absorb_text_font_shadow);
    self.absorb_text_font_shadow:SetTooltip(L['OPTIONS_ABSORB_TEXT_FONT_SHADOW']);
    self.absorb_text_font_shadow.Callback = function(self)
        O.db.absorb_text_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.AbsorbTextFontOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.AbsorbTextFontOptions:SetH(60);
    self.AbsorbTextFontOptions:Add(self.absorb_text_font_value):SetPosition('TOPLEFT', self.AbsorbTextFontOptions, 'TOPLEFT', 8, -20);
    self.AbsorbTextFontOptions:Add(self.absorb_text_font_size):SetPosition('LEFT', self.absorb_text_font_value, 'RIGHT', 12, 0);
    self.AbsorbTextFontOptions:Add(self.absorb_text_font_flag):SetPosition('LEFT', self.absorb_text_font_size, 'RIGHT', 12, 0);
    self.AbsorbTextFontOptions:Add(self.absorb_text_font_shadow):SetPosition('LEFT', self.absorb_text_font_flag, 'RIGHT', 12, 0);
    self.AbsorbTextFontOptions.OpenButton:SetPosition('TOPLEFT', self.absorb_text_enabled, 'BOTTOMLEFT', 0, -8);
    self.AbsorbTextFontOptions.OpenButton:SetLabel(L['FONT_OPTIONS']);

    self.absorb_text_anchor = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.absorb_text_anchor:SetSize(120, 20);
    self.absorb_text_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.absorb_text_anchor:SetValue(O.db.absorb_text_anchor);
    self.absorb_text_anchor:SetLabel(L['POSITION']);
    self.absorb_text_anchor:SetTooltip(L['OPTIONS_ABSORB_TEXT_ANCHOR_TOOLTIP']);
    self.absorb_text_anchor.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.absorb_text_x_offset = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_x_offset:SetW(137);
    self.absorb_text_x_offset:SetLabel(L['OFFSET_X_SHORT']);
    self.absorb_text_x_offset:SetTooltip(L['OPTIONS_ABSORB_TEXT_X_OFFSET_TOOLTIP']);
    self.absorb_text_x_offset:SetValues(O.db.absorb_text_x_offset, -99, 100, 1);
    self.absorb_text_x_offset.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.absorb_text_y_offset = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.absorb_text_y_offset:SetW(137);
    self.absorb_text_y_offset:SetLabel(L['OFFSET_Y_SHORT']);
    self.absorb_text_y_offset:SetTooltip(L['OPTIONS_ABSORB_TEXT_Y_OFFSET_TOOLTIP']);
    self.absorb_text_y_offset:SetValues(O.db.absorb_text_y_offset, -99, 100, 1);
    self.absorb_text_y_offset.OnValueChangedCallback = function(_, value)
        O.db.absorb_text_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.AbsorbTextPositionOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.AbsorbTextPositionOptions:SetH(72);
    self.AbsorbTextPositionOptions:Add(self.absorb_text_anchor):SetPosition('TOPLEFT', self.AbsorbTextPositionOptions, 'TOPLEFT', 12, -24);
    self.AbsorbTextPositionOptions:Add(self.absorb_text_x_offset):SetPosition('LEFT', self.absorb_text_anchor, 'RIGHT', 16, 0);
    self.AbsorbTextPositionOptions:Add(self.absorb_text_y_offset):SetPosition('LEFT', self.absorb_text_x_offset, 'RIGHT', 16, 0);
    self.AbsorbTextPositionOptions.OpenButton:SetPosition('LEFT', self.AbsorbTextFontOptions.OpenButton, 'RIGHT', 16, 0);
    self.AbsorbTextPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.AbsorbTextFontOptions.OpenButton, 'BOTTOMLEFT', 0, -2);
    Delimiter:SetW(self:GetWidth());

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Colors Tab ------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.health_bar_class_color_enemy = E.CreateCheckButton(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_class_color_enemy:SetPosition('TOPLEFT', self.TabsFrames['ColorsTab'].Content, 'TOPLEFT', 5, -4);
    self.health_bar_class_color_enemy:SetLabel(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY']);
    self.health_bar_class_color_enemy:SetTooltip(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY_TOOLTIP']);
    self.health_bar_class_color_enemy:SetChecked(O.db.health_bar_class_color_enemy);
    self.health_bar_class_color_enemy:AddToSearch(button, nil, self.Tabs[2]);
    self.health_bar_class_color_enemy.Callback = function(self)
        O.db.health_bar_class_color_enemy = self:GetChecked();
        C_CVar.SetCVar('ShowClassColorInNameplate', O.db.health_bar_class_color_enemy and 1 or 0);
        Stripes:UpdateAll();
    end

    self.health_bar_class_color_friendly = E.CreateCheckButton(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_class_color_friendly:SetPosition('LEFT', self.health_bar_class_color_enemy.Label, 'RIGHT', 12, 0);
    self.health_bar_class_color_friendly:SetLabel(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY']);
    self.health_bar_class_color_friendly:SetTooltip(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY_TOOLTIP']);
    self.health_bar_class_color_friendly:SetChecked(O.db.health_bar_class_color_friendly);
    self.health_bar_class_color_friendly:AddToSearch(button, nil, self.Tabs[2]);
    self.health_bar_class_color_friendly.Callback = function(self)
        O.db.health_bar_class_color_friendly = self:GetChecked();
        C_CVar.SetCVar('ShowClassColorInFriendlyNameplate', O.db.health_bar_class_color_friendly and 1 or 0);
        Stripes:UpdateAll();
    end

    self.health_bar_color_enemy_npc = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_enemy_npc:SetPosition('TOPLEFT', self.health_bar_class_color_enemy, 'BOTTOMLEFT', -5, -8);
    self.health_bar_color_enemy_npc:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_NPC']);
    self.health_bar_color_enemy_npc:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_NPC_TOOLTIP']);
    self.health_bar_color_enemy_npc:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_NPC_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_enemy_npc:SetValue(unpack(O.db.health_bar_color_enemy_npc));
    self.health_bar_color_enemy_npc.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_enemy_npc[1] = r;
        O.db.health_bar_color_enemy_npc[2] = g;
        O.db.health_bar_color_enemy_npc[3] = b;
        O.db.health_bar_color_enemy_npc[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_enemy_player = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_enemy_player:SetPosition('LEFT', self.health_bar_color_enemy_npc.Label, 'RIGHT', 12, 0);
    self.health_bar_color_enemy_player:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PLAYER']);
    self.health_bar_color_enemy_player:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PLAYER_TOOLTIP']);
    self.health_bar_color_enemy_player:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PLAYER_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_enemy_player:SetValue(unpack(O.db.health_bar_color_enemy_player));
    self.health_bar_color_enemy_player.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_enemy_player[1] = r;
        O.db.health_bar_color_enemy_player[2] = g;
        O.db.health_bar_color_enemy_player[3] = b;
        O.db.health_bar_color_enemy_player[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_enemy_pet = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_enemy_pet:SetPosition('LEFT', self.health_bar_color_enemy_player.Label, 'RIGHT', 12, 0);
    self.health_bar_color_enemy_pet:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PET']);
    self.health_bar_color_enemy_pet:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PET_TOOLTIP']);
    self.health_bar_color_enemy_pet:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_ENEMY_PET_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_enemy_pet:SetValue(unpack(O.db.health_bar_color_enemy_pet));
    self.health_bar_color_enemy_pet.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_enemy_pet[1] = r;
        O.db.health_bar_color_enemy_pet[2] = g;
        O.db.health_bar_color_enemy_pet[3] = b;
        O.db.health_bar_color_enemy_pet[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_friendly_npc = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_friendly_npc:SetPosition('TOPLEFT', self.health_bar_color_enemy_npc, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_friendly_npc:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_NPC']);
    self.health_bar_color_friendly_npc:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_NPC_TOOLTIP']);
    self.health_bar_color_friendly_npc:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_NPC_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_friendly_npc:SetValue(unpack(O.db.health_bar_color_friendly_npc));
    self.health_bar_color_friendly_npc.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_friendly_npc[1] = r;
        O.db.health_bar_color_friendly_npc[2] = g;
        O.db.health_bar_color_friendly_npc[3] = b;
        O.db.health_bar_color_friendly_npc[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_friendly_player = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_friendly_player:SetPosition('LEFT', self.health_bar_color_friendly_npc.Label, 'RIGHT', 12, 0);
    self.health_bar_color_friendly_player:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PLAYER']);
    self.health_bar_color_friendly_player:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PLAYER_TOOLTIP']);
    self.health_bar_color_friendly_player:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PLAYER_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_friendly_player:SetValue(unpack(O.db.health_bar_color_friendly_player));
    self.health_bar_color_friendly_player.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_friendly_player[1] = r;
        O.db.health_bar_color_friendly_player[2] = g;
        O.db.health_bar_color_friendly_player[3] = b;
        O.db.health_bar_color_friendly_player[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_friendly_pet = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_friendly_pet:SetPosition('LEFT', self.health_bar_color_friendly_player.Label, 'RIGHT', 12, 0);
    self.health_bar_color_friendly_pet:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PET']);
    self.health_bar_color_friendly_pet:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PET_TOOLTIP']);
    self.health_bar_color_friendly_pet:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_FRIENDLY_PET_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_friendly_pet:SetValue(unpack(O.db.health_bar_color_friendly_pet));
    self.health_bar_color_friendly_pet.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_friendly_pet[1] = r;
        O.db.health_bar_color_friendly_pet[2] = g;
        O.db.health_bar_color_friendly_pet[3] = b;
        O.db.health_bar_color_friendly_pet[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_neutral_npc = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_neutral_npc:SetPosition('TOPLEFT', self.health_bar_color_friendly_npc, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_neutral_npc:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_NEUTRAL_NPC']);
    self.health_bar_color_neutral_npc:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_NEUTRAL_NPC_TOOLTIP']);
    self.health_bar_color_neutral_npc:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_NEUTRAL_NPC_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_neutral_npc:SetValue(unpack(O.db.health_bar_color_neutral_npc));
    self.health_bar_color_neutral_npc.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_neutral_npc[1] = r;
        O.db.health_bar_color_neutral_npc[2] = g;
        O.db.health_bar_color_neutral_npc[3] = b;
        O.db.health_bar_color_neutral_npc[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_tapped = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_tapped:SetPosition('TOPLEFT', self.health_bar_color_neutral_npc, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_tapped:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_TAPPED']);
    self.health_bar_color_tapped:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_TAPPED_TOOLTIP']);
    self.health_bar_color_tapped:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_TAPPED_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_tapped:SetValue(unpack(O.db.health_bar_color_tapped));
    self.health_bar_color_tapped.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_tapped[1] = r;
        O.db.health_bar_color_tapped[2] = g;
        O.db.health_bar_color_tapped[3] = b;
        O.db.health_bar_color_tapped[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_dc = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_dc:SetPosition('LEFT', self.health_bar_color_tapped.Label, 'RIGHT', 12, 0);
    self.health_bar_color_dc:SetLabel(L['OPTIONS_HEALTH_BAR_COLOR_DC']);
    self.health_bar_color_dc:SetTooltip(L['OPTIONS_HEALTH_BAR_COLOR_DC_TOOLTIP']);
    self.health_bar_color_dc:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLOR_DC_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_dc:SetValue(unpack(O.db.health_bar_color_dc));
    self.health_bar_color_dc.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_dc[1] = r;
        O.db.health_bar_color_dc[2] = g;
        O.db.health_bar_color_dc[3] = b;
        O.db.health_bar_color_dc[4] = a or 1;

        Stripes:UpdateAll();
    end

    local ResetHealthBarColorsButton = E.CreateTextureButton(self.TabsFrames['ColorsTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetHealthBarColorsButton:SetPosition('TOPRIGHT', self.TabsFrames['ColorsTab'].Content, 'TOPRIGHT', -8, -4);
    ResetHealthBarColorsButton:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_RESET_TOOLTIP']);
    ResetHealthBarColorsButton:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_RESET_TOOLTIP'], self.Tabs[2]);
    ResetHealthBarColorsButton.Callback = function()
        panel.health_bar_color_enemy_npc:SetValue(unpack(O.DefaultValues.health_bar_color_enemy_npc));
        panel.health_bar_color_enemy_player:SetValue(unpack(O.DefaultValues.health_bar_color_enemy_player));
        panel.health_bar_color_enemy_pet:SetValue(unpack(O.DefaultValues.health_bar_color_enemy_pet));
        panel.health_bar_color_friendly_npc:SetValue(unpack(O.DefaultValues.health_bar_color_friendly_npc));
        panel.health_bar_color_friendly_player:SetValue(unpack(O.DefaultValues.health_bar_color_friendly_player));
        panel.health_bar_color_friendly_pet:SetValue(unpack(O.DefaultValues.health_bar_color_friendly_pet));
        panel.health_bar_color_neutral_npc:SetValue(unpack(O.DefaultValues.health_bar_color_neutral_npc));
        panel.health_bar_color_tapped:SetValue(unpack(O.DefaultValues.health_bar_color_tapped));
        panel.health_bar_color_dc:SetValue(unpack(O.DefaultValues.health_bar_color_dc));
    end

    local ClassColorsHeader = E.CreateHeader(self.TabsFrames['ColorsTab'].Content, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_HEADER']);
    ClassColorsHeader:SetPosition('TOPLEFT', self.health_bar_color_tapped, 'BOTTOMLEFT', 0, -4);
    ClassColorsHeader:SetW(self:GetWidth());

    self.health_bar_color_class_use = E.CreateCheckButton(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_use:SetPosition('TOPLEFT', ClassColorsHeader, 'BOTTOMLEFT', 5, -4);
    self.health_bar_color_class_use:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_USE']);
    self.health_bar_color_class_use:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_USE_TOOLTIP']);
    self.health_bar_color_class_use:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_USE_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_use:SetChecked(O.db.health_bar_color_class_use);
    self.health_bar_color_class_use.Callback = function(self)
        O.db.health_bar_color_class_use = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_bar_color_class_DEATHKNIGHT = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_DEATHKNIGHT:SetPosition('TOPLEFT', self.health_bar_color_class_use, 'BOTTOMLEFT', -5, -12);
    self.health_bar_color_class_DEATHKNIGHT:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEATHKNIGHT']);
    self.health_bar_color_class_DEATHKNIGHT:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEATHKNIGHT_TOOLTIP']);
    self.health_bar_color_class_DEATHKNIGHT:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEATHKNIGHT_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_DEATHKNIGHT:SetValue(unpack(O.db.health_bar_color_class_DEATHKNIGHT));
    self.health_bar_color_class_DEATHKNIGHT.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_DEATHKNIGHT[1] = r;
        O.db.health_bar_color_class_DEATHKNIGHT[2] = g;
        O.db.health_bar_color_class_DEATHKNIGHT[3] = b;
        O.db.health_bar_color_class_DEATHKNIGHT[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_DEMONHUNTER = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_DEMONHUNTER:SetPosition('LEFT', self.health_bar_color_class_DEATHKNIGHT.Label, 'RIGHT', 48, 0);
    self.health_bar_color_class_DEMONHUNTER:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEMONHUNTER']);
    self.health_bar_color_class_DEMONHUNTER:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEMONHUNTER_TOOLTIP']);
    self.health_bar_color_class_DEMONHUNTER:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DEMONHUNTER_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_DEMONHUNTER:SetValue(unpack(O.db.health_bar_color_class_DEMONHUNTER));
    self.health_bar_color_class_DEMONHUNTER.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_DEMONHUNTER[1] = r;
        O.db.health_bar_color_class_DEMONHUNTER[2] = g;
        O.db.health_bar_color_class_DEMONHUNTER[3] = b;
        O.db.health_bar_color_class_DEMONHUNTER[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_DRUID = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_DRUID:SetPosition('LEFT', self.health_bar_color_class_DEMONHUNTER.Label, 'RIGHT', 48, 0);
    self.health_bar_color_class_DRUID:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DRUID']);
    self.health_bar_color_class_DRUID:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DRUID_TOOLTIP']);
    self.health_bar_color_class_DRUID:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_DRUID_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_DRUID:SetValue(unpack(O.db.health_bar_color_class_DRUID));
    self.health_bar_color_class_DRUID.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_DRUID[1] = r;
        O.db.health_bar_color_class_DRUID[2] = g;
        O.db.health_bar_color_class_DRUID[3] = b;
        O.db.health_bar_color_class_DRUID[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_HUNTER = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_HUNTER:SetPosition('TOPLEFT', self.health_bar_color_class_DEATHKNIGHT, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_HUNTER:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_HUNTER']);
    self.health_bar_color_class_HUNTER:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_HUNTER_TOOLTIP']);
    self.health_bar_color_class_HUNTER:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_HUNTER_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_HUNTER:SetValue(unpack(O.db.health_bar_color_class_HUNTER));
    self.health_bar_color_class_HUNTER.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_HUNTER[1] = r;
        O.db.health_bar_color_class_HUNTER[2] = g;
        O.db.health_bar_color_class_HUNTER[3] = b;
        O.db.health_bar_color_class_HUNTER[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_MAGE = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_MAGE:SetPosition('TOPLEFT', self.health_bar_color_class_DEMONHUNTER, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_MAGE:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MAGE']);
    self.health_bar_color_class_MAGE:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MAGE_TOOLTIP']);
    self.health_bar_color_class_MAGE:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MAGE_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_MAGE:SetValue(unpack(O.db.health_bar_color_class_MAGE));
    self.health_bar_color_class_MAGE.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_MAGE[1] = r;
        O.db.health_bar_color_class_MAGE[2] = g;
        O.db.health_bar_color_class_MAGE[3] = b;
        O.db.health_bar_color_class_MAGE[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_MONK = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_MONK:SetPosition('TOPLEFT', self.health_bar_color_class_DRUID, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_MONK:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MONK']);
    self.health_bar_color_class_MONK:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MONK_TOOLTIP']);
    self.health_bar_color_class_MONK:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_MONK_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_MONK:SetValue(unpack(O.db.health_bar_color_class_MONK));
    self.health_bar_color_class_MONK.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_MONK[1] = r;
        O.db.health_bar_color_class_MONK[2] = g;
        O.db.health_bar_color_class_MONK[3] = b;
        O.db.health_bar_color_class_MONK[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_PALADIN = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_PALADIN:SetPosition('TOPLEFT', self.health_bar_color_class_HUNTER, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_PALADIN:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PALADIN']);
    self.health_bar_color_class_PALADIN:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PALADIN_TOOLTIP']);
    self.health_bar_color_class_PALADIN:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PALADIN_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_PALADIN:SetValue(unpack(O.db.health_bar_color_class_PALADIN));
    self.health_bar_color_class_PALADIN.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_PALADIN[1] = r;
        O.db.health_bar_color_class_PALADIN[2] = g;
        O.db.health_bar_color_class_PALADIN[3] = b;
        O.db.health_bar_color_class_PALADIN[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_PRIEST = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_PRIEST:SetPosition('TOPLEFT', self.health_bar_color_class_MAGE, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_PRIEST:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PRIEST']);
    self.health_bar_color_class_PRIEST:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PRIEST_TOOLTIP']);
    self.health_bar_color_class_PRIEST:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_PRIEST_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_PRIEST:SetValue(unpack(O.db.health_bar_color_class_PRIEST));
    self.health_bar_color_class_PRIEST.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_PRIEST[1] = r;
        O.db.health_bar_color_class_PRIEST[2] = g;
        O.db.health_bar_color_class_PRIEST[3] = b;
        O.db.health_bar_color_class_PRIEST[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_ROGUE = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_ROGUE:SetPosition('TOPLEFT', self.health_bar_color_class_MONK, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_ROGUE:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_ROGUE']);
    self.health_bar_color_class_ROGUE:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_ROGUE_TOOLTIP']);
    self.health_bar_color_class_ROGUE:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_ROGUE_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_ROGUE:SetValue(unpack(O.db.health_bar_color_class_ROGUE));
    self.health_bar_color_class_ROGUE.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_ROGUE[1] = r;
        O.db.health_bar_color_class_ROGUE[2] = g;
        O.db.health_bar_color_class_ROGUE[3] = b;
        O.db.health_bar_color_class_ROGUE[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_SHAMAN = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_SHAMAN:SetPosition('TOPLEFT', self.health_bar_color_class_PALADIN, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_SHAMAN:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_SHAMAN']);
    self.health_bar_color_class_SHAMAN:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_SHAMAN_TOOLTIP']);
    self.health_bar_color_class_SHAMAN:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_SHAMAN_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_SHAMAN:SetValue(unpack(O.db.health_bar_color_class_SHAMAN));
    self.health_bar_color_class_SHAMAN.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_SHAMAN[1] = r;
        O.db.health_bar_color_class_SHAMAN[2] = g;
        O.db.health_bar_color_class_SHAMAN[3] = b;
        O.db.health_bar_color_class_SHAMAN[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_WARLOCK = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_WARLOCK:SetPosition('TOPLEFT', self.health_bar_color_class_PRIEST, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_WARLOCK:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARLOCK']);
    self.health_bar_color_class_WARLOCK:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARLOCK_TOOLTIP']);
    self.health_bar_color_class_WARLOCK:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARLOCK_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_WARLOCK:SetValue(unpack(O.db.health_bar_color_class_WARLOCK));
    self.health_bar_color_class_WARLOCK.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_WARLOCK[1] = r;
        O.db.health_bar_color_class_WARLOCK[2] = g;
        O.db.health_bar_color_class_WARLOCK[3] = b;
        O.db.health_bar_color_class_WARLOCK[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_WARRIOR = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_WARRIOR:SetPosition('TOPLEFT', self.health_bar_color_class_ROGUE, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_WARRIOR:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARRIOR']);
    self.health_bar_color_class_WARRIOR:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARRIOR_TOOLTIP']);
    self.health_bar_color_class_WARRIOR:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_WARRIOR_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_WARRIOR:SetValue(unpack(O.db.health_bar_color_class_WARRIOR));
    self.health_bar_color_class_WARRIOR.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_WARRIOR[1] = r;
        O.db.health_bar_color_class_WARRIOR[2] = g;
        O.db.health_bar_color_class_WARRIOR[3] = b;
        O.db.health_bar_color_class_WARRIOR[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.health_bar_color_class_EVOKER = E.CreateColorPicker(self.TabsFrames['ColorsTab'].Content);
    self.health_bar_color_class_EVOKER:SetPosition('TOPLEFT', self.health_bar_color_class_SHAMAN, 'BOTTOMLEFT', 0, -8);
    self.health_bar_color_class_EVOKER:SetLabel(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_EVOKER']);
    self.health_bar_color_class_EVOKER:SetTooltip(L['OPTIONS_HEALTH_BAR_COLORS_CLASS_EVOKER_TOOLTIP']);
    self.health_bar_color_class_EVOKER:AddToSearch(button, L['OPTIONS_HEALTH_BAR_COLORS_CLASS_EVOKER_TOOLTIP'], self.Tabs[2]);
    self.health_bar_color_class_EVOKER:SetValue(unpack(O.db.health_bar_color_class_EVOKER));
    self.health_bar_color_class_EVOKER.OnValueChanged = function(_, r, g, b, a)
        O.db.health_bar_color_class_EVOKER[1] = r;
        O.db.health_bar_color_class_EVOKER[2] = g;
        O.db.health_bar_color_class_EVOKER[3] = b;
        O.db.health_bar_color_class_EVOKER[4] = a or 1;

        Stripes:UpdateAll();
    end


    local ResetHealthBarClassColorsButton = E.CreateTextureButton(self.TabsFrames['ColorsTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetHealthBarClassColorsButton:SetPosition('TOPRIGHT', ClassColorsHeader, 'BOTTOMRIGHT', -8, -4);
    ResetHealthBarClassColorsButton:SetTooltip(L['OPTIONS_HEALTH_BAR_CLASS_COLORS_RESET_TOOLTIP']);
    ResetHealthBarClassColorsButton:AddToSearch(button, L['OPTIONS_HEALTH_BAR_CLASS_COLORS_RESET_TOOLTIP'], self.Tabs[2]);
    ResetHealthBarClassColorsButton.Callback = function()
        panel.health_bar_color_class_DEATHKNIGHT:SetValue(unpack(O.DefaultValues.health_bar_color_class_DEATHKNIGHT));
        panel.health_bar_color_class_DEMONHUNTER:SetValue(unpack(O.DefaultValues.health_bar_color_class_DEMONHUNTER));
        panel.health_bar_color_class_DRUID:SetValue(unpack(O.DefaultValues.health_bar_color_class_DRUID));
        panel.health_bar_color_class_HUNTER:SetValue(unpack(O.DefaultValues.health_bar_color_class_HUNTER));
        panel.health_bar_color_class_MAGE:SetValue(unpack(O.DefaultValues.health_bar_color_class_MAGE));
        panel.health_bar_color_class_MONK:SetValue(unpack(O.DefaultValues.health_bar_color_class_MONK));
        panel.health_bar_color_class_PALADIN:SetValue(unpack(O.DefaultValues.health_bar_color_class_PALADIN));
        panel.health_bar_color_class_PRIEST:SetValue(unpack(O.DefaultValues.health_bar_color_class_PRIEST));
        panel.health_bar_color_class_ROGUE:SetValue(unpack(O.DefaultValues.health_bar_color_class_ROGUE));
        panel.health_bar_color_class_SHAMAN:SetValue(unpack(O.DefaultValues.health_bar_color_class_SHAMAN));
        panel.health_bar_color_class_WARLOCK:SetValue(unpack(O.DefaultValues.health_bar_color_class_WARLOCK));
        panel.health_bar_color_class_WARRIOR:SetValue(unpack(O.DefaultValues.health_bar_color_class_WARRIOR));
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Target Indicator Tab ------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.target_indicator_enabled = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_enabled:SetPosition('TOPLEFT', self.TabsFrames['TargetIndicatorTab'].Content, 'TOPLEFT', 0, -4);
    self.target_indicator_enabled:SetLabel(L['OPTIONS_TARGET_INDICATOR_ENABLED']);
    self.target_indicator_enabled:SetTooltip(L['OPTIONS_TARGET_INDICATOR_ENABLED_TOOLTIP']);
    self.target_indicator_enabled:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_enabled:SetChecked(O.db.target_indicator_enabled);
    self.target_indicator_enabled.Callback = function(self)
        O.db.target_indicator_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_indicator_texture = E.CreateDropdown('texture', self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_texture:SetPosition('LEFT', self.target_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.target_indicator_texture:SetSize(87, 20);
    self.target_indicator_texture:SetList(O.Lists.target_indicator_texture_path);
    self.target_indicator_texture:SetLabel(L['OPTIONS_TARGET_INDICATOR_TEXTURE']);
    self.target_indicator_texture:SetTooltip(L['OPTIONS_TARGET_INDICATOR_TEXTURE_TOOLTIP']);
    self.target_indicator_texture:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_TEXTURE_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_texture:SetValue(O.db.target_indicator_texture);
    self.target_indicator_texture.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_texture = tonumber(value);
        Stripes:UpdateAll();
    end

    self.target_indicator_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_color:SetPosition('LEFT', self.target_indicator_texture, 'RIGHT', 12, 0);
    self.target_indicator_color:SetTooltip(L['OPTIONS_TARGET_INDICATOR_COLOR_TOOLTIP']);
    self.target_indicator_color:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_COLOR_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_color:SetValue(unpack(O.db.target_indicator_color));
    self.target_indicator_color.OnValueChanged = function(_, r, g, b, a)
        O.db.target_indicator_color[1] = r;
        O.db.target_indicator_color[2] = g;
        O.db.target_indicator_color[3] = b;
        O.db.target_indicator_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.target_indicator_color_as_class = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_color_as_class:SetPosition('LEFT', self.target_indicator_color, 'RIGHT', 12, 0);
    self.target_indicator_color_as_class:SetLabel(L['OPTIONS_TARGET_INDICATOR_COLOR_AS_CLASS']);
    self.target_indicator_color_as_class:SetTooltip(L['OPTIONS_TARGET_INDICATOR_COLOR_AS_CLASS_TOOLTIP']);
    self.target_indicator_color_as_class:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_COLOR_AS_CLASS_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_color_as_class:SetChecked(O.db.target_indicator_color_as_class);
    self.target_indicator_color_as_class.Callback = function(self)
        O.db.target_indicator_color_as_class = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_indicator_size = E.CreateSlider(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_size:SetPosition('TOPLEFT', self.target_indicator_enabled, 'BOTTOMLEFT', 0, -12);
    self.target_indicator_size:SetValues(O.db.target_indicator_size, 1, 64, 1);
    self.target_indicator_size:SetTooltip(L['OPTIONS_TARGET_INDICATOR_SIZE_TOOLTIP']);
    self.target_indicator_size:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_SIZE_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_size.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.target_indicator_x_offset = E.CreateSlider(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_x_offset:SetPosition('LEFT', self.target_indicator_size, 'RIGHT', 12, 0);
    self.target_indicator_x_offset:SetValues(O.db.target_indicator_x_offset, -50, 50, 1);
    self.target_indicator_x_offset:SetTooltip(L['OPTIONS_TARGET_INDICATOR_X_OFFSET_TOOLTIP']);
    self.target_indicator_x_offset:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_X_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_x_offset.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.target_indicator_y_offset = E.CreateSlider(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_indicator_y_offset:SetPosition('LEFT', self.target_indicator_x_offset, 'RIGHT', 12, 0);
    self.target_indicator_y_offset:SetValues(O.db.target_indicator_y_offset, -50, 50, 1);
    self.target_indicator_y_offset:SetTooltip(L['OPTIONS_TARGET_INDICATOR_Y_OFFSET_TOOLTIP']);
    self.target_indicator_y_offset:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_Y_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.target_indicator_y_offset.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.target_glow_enabled = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_glow_enabled:SetPosition('TOPLEFT', self.target_indicator_size, 'BOTTOMLEFT', 0, -12);
    self.target_glow_enabled:SetLabel(L['OPTIONS_TARGET_GLOW_ENABLED']);
    self.target_glow_enabled:SetTooltip(L['OPTIONS_TARGET_GLOW_ENABLED_TOOLTIP']);
    self.target_glow_enabled:AddToSearch(button, nil, self.Tabs[3]);
    self.target_glow_enabled:SetChecked(O.db.target_glow_enabled);
    self.target_glow_enabled.Callback = function(self)
        O.db.target_glow_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.hover_glow_enabled = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.hover_glow_enabled:SetPosition('LEFT', self.target_glow_enabled.Label, 'RIGHT', 12, 0);
    self.hover_glow_enabled:SetLabel(L['OPTIONS_HOVER_GLOW_ENABLED']);
    self.hover_glow_enabled:SetTooltip(L['OPTIONS_HOVER_GLOW_ENABLED_TOOLTIP']);
    self.hover_glow_enabled:AddToSearch(button, L['OPTIONS_HOVER_GLOW_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.hover_glow_enabled:SetChecked(O.db.hover_glow_enabled);
    self.hover_glow_enabled.Callback = function(self)
        O.db.hover_glow_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_glow_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_glow_color:SetPosition('LEFT', self.hover_glow_enabled.Label, 'RIGHT', 12, 0);
    self.target_glow_color:SetTooltip(L['OPTIONS_TARGET_GLOW_COLOR_TOOLTIP']);
    self.target_glow_color:AddToSearch(button, L['OPTIONS_TARGET_GLOW_COLOR_TOOLTIP'], self.Tabs[3]);
    self.target_glow_color:SetValue(unpack(O.db.target_glow_color));
    self.target_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.target_glow_color[1] = r;
        O.db.target_glow_color[2] = g;
        O.db.target_glow_color[3] = b;
        O.db.target_glow_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.target_glow_color_as_class = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_glow_color_as_class:SetPosition('LEFT', self.target_glow_color, 'RIGHT', 12, 0);
    self.target_glow_color_as_class:SetLabel(L['OPTIONS_TARGET_GLOW_COLOR_AS_CLASS']);
    self.target_glow_color_as_class:SetTooltip(L['OPTIONS_TARGET_GLOW_COLOR_AS_CLASS_TOOLTIP']);
    self.target_glow_color_as_class:AddToSearch(button, L['OPTIONS_TARGET_GLOW_COLOR_AS_CLASS_TOOLTIP'], self.Tabs[3]);
    self.target_glow_color_as_class:SetChecked(O.db.target_glow_color_as_class);
    self.target_glow_color_as_class.Callback = function(self)
        O.db.target_glow_color_as_class = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_glow_size = E.CreateSlider(self.TabsFrames['TargetIndicatorTab'].Content);
    self.target_glow_size:SetPosition('LEFT', self.target_glow_color_as_class.Label, 'RIGHT', 12, 0);
    self.target_glow_size:SetValues(O.db.target_glow_size, 1, 64, 1);
    self.target_glow_size:SetTooltip(L['OPTIONS_TARGET_GLOW_SIZE_TOOLTIP']);
    self.target_glow_size:AddToSearch(button, L['OPTIONS_TARGET_GLOW_SIZE_TOOLTIP'], self.Tabs[3]);
    self.target_glow_size.OnValueChangedCallback = function(_, value)
        O.db.target_glow_size = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['TargetIndicatorTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.target_glow_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.current_target_health_bar_coloring = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_health_bar_coloring:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.current_target_health_bar_coloring:SetLabel(L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_COLORING']);
    self.current_target_health_bar_coloring:SetTooltip(L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_COLORING_TOOLTIP']);
    self.current_target_health_bar_coloring:AddToSearch(button, nil, self.Tabs[3]);
    self.current_target_health_bar_coloring:SetChecked(O.db.current_target_health_bar_coloring);
    self.current_target_health_bar_coloring.Callback = function(self)
        O.db.current_target_health_bar_coloring = self:GetChecked();

        panel.current_target_health_bar_color:SetEnabled(O.db.current_target_health_bar_coloring);
        panel.current_target_health_bar_use_class_color:SetEnabled(O.db.current_target_health_bar_coloring);

        Stripes:UpdateAll();
    end

    self.current_target_health_bar_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_health_bar_color:SetPosition('LEFT', self.current_target_health_bar_coloring.Label, 'RIGHT', 12, 0);
    self.current_target_health_bar_color:SetTooltip(L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_COLOR_TOOLTIP']);
    self.current_target_health_bar_color:AddToSearch(button, L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_target_health_bar_color:SetValue(unpack(O.db.current_target_health_bar_color));
    self.current_target_health_bar_color:SetEnabled(O.db.current_target_health_bar_coloring);
    self.current_target_health_bar_color.OnValueChanged = function(_, r, g, b, a)
        O.db.current_target_health_bar_color[1] = r;
        O.db.current_target_health_bar_color[2] = g;
        O.db.current_target_health_bar_color[3] = b;
        O.db.current_target_health_bar_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.current_target_health_bar_use_class_color = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_health_bar_use_class_color:SetPosition('LEFT', self.current_target_health_bar_color, 'RIGHT', 16, 0);
    self.current_target_health_bar_use_class_color:SetLabel(L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_USE_CLASS_COLOR']);
    self.current_target_health_bar_use_class_color:SetTooltip(L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_USE_CLASS_COLOR_TOOLTIP']);
    self.current_target_health_bar_use_class_color:AddToSearch(button, L['OPTIONS_CURRENT_TARGET_HEALTH_BAR_USE_CLASS_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_target_health_bar_use_class_color:SetChecked(O.db.current_target_health_bar_use_class_color);
    self.current_target_health_bar_use_class_color:SetEnabled(O.db.current_target_health_bar_coloring);
    self.current_target_health_bar_use_class_color.Callback = function(self)
        O.db.current_target_health_bar_use_class_color = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.current_target_custom_texture_enabled = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_custom_texture_enabled:SetPosition('TOPLEFT', self.current_target_health_bar_coloring, 'BOTTOMLEFT', 0, -12);
    self.current_target_custom_texture_enabled:SetLabel(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED']);
    self.current_target_custom_texture_enabled:SetTooltip(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_ENABLED_TOOLTIP']);
    self.current_target_custom_texture_enabled:AddToSearch(button, nil, self.Tabs[3]);
    self.current_target_custom_texture_enabled:SetChecked(O.db.current_target_custom_texture_enabled);
    self.current_target_custom_texture_enabled.Callback = function(self)
        O.db.current_target_custom_texture_enabled = self:GetChecked();

        panel.current_target_custom_texture_value:SetEnabled(O.db.current_target_custom_texture_enabled);
        panel.current_target_custom_texture_overlay:SetEnabled(O.db.current_target_custom_texture_enabled);
        panel.current_target_custom_texture_overlay_color:SetEnabled(O.db.current_target_custom_texture_enabled and O.db.current_target_custom_texture_enabled);

        Stripes:UpdateAll();
    end

    self.current_target_custom_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_custom_texture_value:SetPosition('LEFT', self.current_target_custom_texture_enabled.Label, 'RIGHT', 12, 0);
    self.current_target_custom_texture_value:SetSize(200, 20);
    self.current_target_custom_texture_value:SetList(LSM:HashTable('statusbar'));
    self.current_target_custom_texture_value:SetValue(O.db.current_target_custom_texture_value);
    self.current_target_custom_texture_value:SetTooltip(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_VALUE_TOOLTIP']);
    self.current_target_custom_texture_value:AddToSearch(button, L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_VALUE_TOOLTIP'], self.Tabs[3]);
    self.current_target_custom_texture_value:SetEnabled(O.db.current_target_custom_texture_enabled);
    self.current_target_custom_texture_value.OnValueChangedCallback = function(_, value)
        O.db.current_target_custom_texture_value = value;
        Stripes:UpdateAll();
    end

    self.current_target_custom_texture_overlay = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_custom_texture_overlay:SetPosition('TOPLEFT', self.current_target_custom_texture_enabled, 'BOTTOMLEFT', 0, -12);
    self.current_target_custom_texture_overlay:SetLabel(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY']);
    self.current_target_custom_texture_overlay:SetTooltip(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_TOOLTIP']);
    self.current_target_custom_texture_overlay:AddToSearch(button, L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_TOOLTIP'], self.Tabs[3]);
    self.current_target_custom_texture_overlay:SetChecked(O.db.current_target_custom_texture_overlay);
    self.current_target_custom_texture_overlay:SetEnabled(O.db.current_target_custom_texture_enabled);
    self.current_target_custom_texture_overlay.Callback = function(self)
        O.db.current_target_custom_texture_overlay = self:GetChecked();

        panel.current_target_custom_texture_overlay_color:SetEnabled(O.db.current_target_custom_texture_overlay);

        Stripes:UpdateAll();
    end

    self.current_target_custom_texture_overlay_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_target_custom_texture_overlay_color:SetPosition('LEFT', self.current_target_custom_texture_overlay.Label, 'RIGHT', 12, 0);
    self.current_target_custom_texture_overlay_color:SetTooltip(L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR_TOOLTIP']);
    self.current_target_custom_texture_overlay_color:AddToSearch(button, L['OPTIONS_CURRENT_TARGET_CUSTOM_TEXTURE_OVERLAY_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_target_custom_texture_overlay_color:SetValue(unpack(O.db.current_target_custom_texture_overlay_color));
    self.current_target_custom_texture_overlay_color:SetEnabled(O.db.current_target_custom_texture_overlay);
    self.current_target_custom_texture_overlay_color.OnValueChanged = function(_, r, g, b, a)
        O.db.current_target_custom_texture_overlay_color[1] = r;
        O.db.current_target_custom_texture_overlay_color[2] = g;
        O.db.current_target_custom_texture_overlay_color[3] = b;
        O.db.current_target_custom_texture_overlay_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['TargetIndicatorTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.current_target_custom_texture_overlay, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.current_focus_health_bar_coloring = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_health_bar_coloring:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.current_focus_health_bar_coloring:SetLabel(L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_COLORING']);
    self.current_focus_health_bar_coloring:SetTooltip(L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_COLORING_TOOLTIP']);
    self.current_focus_health_bar_coloring:AddToSearch(button, nil, self.Tabs[3]);
    self.current_focus_health_bar_coloring:SetChecked(O.db.current_focus_health_bar_coloring);
    self.current_focus_health_bar_coloring.Callback = function(self)
        O.db.current_focus_health_bar_coloring = self:GetChecked();

        panel.current_focus_health_bar_color:SetEnabled(O.db.current_focus_health_bar_coloring);
        panel.current_focus_health_bar_use_class_color:SetEnabled(O.db.current_focus_health_bar_coloring);

        Stripes:UpdateAll();
    end

    self.current_focus_health_bar_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_health_bar_color:SetPosition('LEFT', self.current_focus_health_bar_coloring.Label, 'RIGHT', 12, 0);
    self.current_focus_health_bar_color:SetTooltip(L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_COLOR_TOOLTIP']);
    self.current_focus_health_bar_color:AddToSearch(button, L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_focus_health_bar_color:SetValue(unpack(O.db.current_focus_health_bar_color));
    self.current_focus_health_bar_color:SetEnabled(O.db.current_focus_health_bar_coloring);
    self.current_focus_health_bar_color.OnValueChanged = function(_, r, g, b, a)
        O.db.current_focus_health_bar_color[1] = r;
        O.db.current_focus_health_bar_color[2] = g;
        O.db.current_focus_health_bar_color[3] = b;
        O.db.current_focus_health_bar_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.current_focus_health_bar_use_class_color = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_health_bar_use_class_color:SetPosition('LEFT', self.current_focus_health_bar_color, 'RIGHT', 16, 0);
    self.current_focus_health_bar_use_class_color:SetLabel(L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_USE_CLASS_COLOR']);
    self.current_focus_health_bar_use_class_color:SetTooltip(L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_USE_CLASS_COLOR_TOOLTIP']);
    self.current_focus_health_bar_use_class_color:AddToSearch(button, L['OPTIONS_CURRENT_FOCUS_HEALTH_BAR_USE_CLASS_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_focus_health_bar_use_class_color:SetChecked(O.db.current_focus_health_bar_use_class_color);
    self.current_focus_health_bar_use_class_color:SetEnabled(O.db.current_focus_health_bar_coloring);
    self.current_focus_health_bar_use_class_color.Callback = function(self)
        O.db.current_focus_health_bar_use_class_color = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.current_focus_custom_texture_enabled = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_custom_texture_enabled:SetPosition('TOPLEFT', self.current_focus_health_bar_coloring, 'BOTTOMLEFT', 0, -12);
    self.current_focus_custom_texture_enabled:SetLabel(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED']);
    self.current_focus_custom_texture_enabled:SetTooltip(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_ENABLED_TOOLTIP']);
    self.current_focus_custom_texture_enabled:AddToSearch(button, nil, self.Tabs[3]);
    self.current_focus_custom_texture_enabled:SetChecked(O.db.current_focus_custom_texture_enabled);
    self.current_focus_custom_texture_enabled.Callback = function(self)
        O.db.current_focus_custom_texture_enabled = self:GetChecked();

        panel.current_focus_custom_texture_value:SetEnabled(O.db.current_focus_custom_texture_enabled);
        panel.current_focus_custom_texture_overlay:SetEnabled(O.db.current_focus_custom_texture_enabled);
        panel.current_focus_custom_texture_overlay_color:SetEnabled(O.db.current_focus_custom_texture_enabled and O.db.current_focus_custom_texture_overlay);

        Stripes:UpdateAll();
    end

    self.current_focus_custom_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_custom_texture_value:SetPosition('LEFT', self.current_focus_custom_texture_enabled.Label, 'RIGHT', 12, 0);
    self.current_focus_custom_texture_value:SetSize(200, 20);
    self.current_focus_custom_texture_value:SetList(LSM:HashTable('statusbar'));
    self.current_focus_custom_texture_value:SetValue(O.db.current_focus_custom_texture_value);
    self.current_focus_custom_texture_value:SetTooltip(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE_TOOLTIP']);
    self.current_focus_custom_texture_value:AddToSearch(button, L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_VALUE_TOOLTIP'], self.Tabs[3]);
    self.current_focus_custom_texture_value:SetEnabled(O.db.current_focus_custom_texture_enabled);
    self.current_focus_custom_texture_value.OnValueChangedCallback = function(_, value)
        O.db.current_focus_custom_texture_value = value;
        Stripes:UpdateAll();
    end

    self.current_focus_custom_texture_overlay = E.CreateCheckButton(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_custom_texture_overlay:SetPosition('TOPLEFT', self.current_focus_custom_texture_enabled, 'BOTTOMLEFT', 0, -12);
    self.current_focus_custom_texture_overlay:SetLabel(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY']);
    self.current_focus_custom_texture_overlay:SetTooltip(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_TOOLTIP']);
    self.current_focus_custom_texture_overlay:AddToSearch(button, L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_TOOLTIP'], self.Tabs[3]);
    self.current_focus_custom_texture_overlay:SetChecked(O.db.current_focus_custom_texture_overlay);
    self.current_focus_custom_texture_overlay:SetEnabled(O.db.current_focus_custom_texture_enabled);
    self.current_focus_custom_texture_overlay.Callback = function(self)
        O.db.current_focus_custom_texture_overlay = self:GetChecked();

        panel.current_focus_custom_texture_overlay_color:SetEnabled(O.db.current_focus_custom_texture_overlay);

        Stripes:UpdateAll();
    end

    self.current_focus_custom_texture_overlay_color = E.CreateColorPicker(self.TabsFrames['TargetIndicatorTab'].Content);
    self.current_focus_custom_texture_overlay_color:SetPosition('LEFT', self.current_focus_custom_texture_overlay.Label, 'RIGHT', 12, 0);
    self.current_focus_custom_texture_overlay_color:SetTooltip(L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR_TOOLTIP']);
    self.current_focus_custom_texture_overlay_color:AddToSearch(button, L['OPTIONS_CURRENT_FOCUS_CUSTOM_TEXTURE_OVERLAY_COLOR_TOOLTIP'], self.Tabs[3]);
    self.current_focus_custom_texture_overlay_color:SetValue(unpack(O.db.current_focus_custom_texture_overlay_color));
    self.current_focus_custom_texture_overlay_color:SetEnabled(O.db.current_focus_custom_texture_overlay);
    self.current_focus_custom_texture_overlay_color.OnValueChanged = function(_, r, g, b, a)
        O.db.current_focus_custom_texture_overlay_color[1] = r;
        O.db.current_focus_custom_texture_overlay_color[2] = g;
        O.db.current_focus_custom_texture_overlay_color[3] = b;
        O.db.current_focus_custom_texture_overlay_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Threat Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.threat_color_enabled = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_enabled:SetPosition('TOPLEFT', self.TabsFrames['ThreatTab'].Content, 'TOPLEFT', 0, -4);
    self.threat_color_enabled:SetLabel(L['OPTIONS_THREAT_COLOR_ENABLED']);
    self.threat_color_enabled:SetTooltip(L['OPTIONS_THREAT_COLOR_ENABLED_TOOLTIP']);
    self.threat_color_enabled:SetChecked(O.db.threat_color_enabled);
    self.threat_color_enabled:AddToSearch(button, nil, self.Tabs[4]);
    self.threat_color_enabled.Callback = function(self)
        O.db.threat_color_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.threat_color_reversed = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_reversed:SetPosition('LEFT', self.threat_color_enabled.Label, 'RIGHT', 12, 0);
    self.threat_color_reversed:SetLabel(L['OPTIONS_THREAT_COLOR_REVERSED']);
    self.threat_color_reversed:SetTooltip(L['OPTIONS_THREAT_COLOR_REVERSED_TOOLTIP']);
    self.threat_color_reversed:SetChecked(O.db.threat_color_reversed);
    self.threat_color_reversed:AddToSearch(button, L['OPTIONS_THREAT_COLOR_REVERSED_TOOLTIP'], self.Tabs[4]);
    self.threat_color_reversed.Callback = function(self)
        O.db.threat_color_reversed = self:GetChecked();

        panel.threat_color_reversed_spec:SetEnabled(O.db.threat_color_reversed);

        Stripes:UpdateAll();
    end

    self.threat_color_reversed_spec = E.CreateDropdown('plain', self.TabsFrames['ThreatTab'].Content);
    self.threat_color_reversed_spec:SetPosition('LEFT', self.threat_color_reversed.Label, 'RIGHT', 12, 0);
    self.threat_color_reversed_spec:SetSize(180, 20);
    self.threat_color_reversed_spec:SetList(O.Lists.threat_color_reversed_spec);
    self.threat_color_reversed_spec:SetValue(O.db.threat_color_reversed_spec);
    self.threat_color_reversed_spec:SetTooltip(L['OPTIONS_THREAT_COLOR_REVERSED_SPEC_TOOLTIP']);
    self.threat_color_reversed_spec:AddToSearch(button, L['OPTIONS_THREAT_COLOR_REVERSED_SPEC_TOOLTIP'], self.Tabs[4]);
    self.threat_color_reversed_spec:SetEnabled(O.db.threat_color_reversed);
    self.threat_color_reversed_spec.OnValueChangedCallback = function(_, value)
        O.db.threat_color_reversed_spec = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_color_istapped_border = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_istapped_border:SetPosition('TOPLEFT', self.threat_color_enabled, 'BOTTOMLEFT', 0, -8);
    self.threat_color_istapped_border:SetLabel(L['OPTIONS_THREAT_COLOR_ISTAPPED_BORDER']);
    self.threat_color_istapped_border:SetTooltip(L['OPTIONS_THREAT_COLOR_ISTAPPED_BORDER_TOOLTIP']);
    self.threat_color_istapped_border:SetChecked(O.db.threat_color_istapped_border);
    self.threat_color_istapped_border:AddToSearch(button, L['OPTIONS_THREAT_COLOR_ISTAPPED_BORDER_TOOLTIP'], self.Tabs[4]);
    self.threat_color_istapped_border.Callback = function(self)
        O.db.threat_color_istapped_border = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.threat_color_name = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_name:SetPosition('LEFT', self.threat_color_istapped_border.Label, 'RIGHT', 12, 0);
    self.threat_color_name:SetLabel(L['OPTIONS_THREAT_COLOR_NAME']);
    self.threat_color_name:SetTooltip(L['OPTIONS_THREAT_COLOR_NAME_TOOLTIP']);
    self.threat_color_name:SetChecked(O.db.threat_color_name);
    self.threat_color_name:AddToSearch(button, L['OPTIONS_THREAT_COLOR_NAME_TOOLTIP'], self.Tabs[4]);
    self.threat_color_name.Callback = function(self)
        O.db.threat_color_name = self:GetChecked();

        panel.threat_color_name_only:SetEnabled(O.db.threat_color_name);

        Stripes:UpdateAll();
    end

    self.threat_color_name_only = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_name_only:SetPosition('LEFT', self.threat_color_name.Label, 'RIGHT', 12, 0);
    self.threat_color_name_only:SetLabel(L['OPTIONS_THREAT_COLOR_NAME_ONLY']);
    self.threat_color_name_only:SetTooltip(L['OPTIONS_THREAT_COLOR_NAME_ONLY_TOOLTIP']);
    self.threat_color_name_only:SetChecked(O.db.threat_color_name_only);
    self.threat_color_name_only:AddToSearch(button, L['OPTIONS_THREAT_COLOR_NAME_ONLY_TOOLTIP'], self.Tabs[4]);
    self.threat_color_name_only:SetEnabled(O.db.threat_color_name);
    self.threat_color_name_only.Callback = function(self)
        O.db.threat_color_name_only = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.threat_color_prio_high = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_prio_high:SetPosition('TOPLEFT', self.threat_color_istapped_border, 'BOTTOMLEFT', 0, -8);
    self.threat_color_prio_high:SetLabel(L['OPTIONS_THREAT_COLOR_PRIO_HIGH']);
    self.threat_color_prio_high:SetTooltip(L['OPTIONS_THREAT_COLOR_PRIO_HIGH_TOOLTIP']);
    self.threat_color_prio_high:SetChecked(O.db.threat_color_prio_high);
    self.threat_color_prio_high:AddToSearch(button, L['OPTIONS_THREAT_COLOR_PRIO_HIGH_TOOLTIP'], self.Tabs[4]);
    self.threat_color_prio_high.Callback = function(self)
        O.db.threat_color_prio_high = self:GetChecked();

        panel.threat_color_prio_high_exclude_tank_role:SetEnabled(O.db.threat_color_prio_high);

        Stripes:UpdateAll();
    end

    self.threat_color_prio_high_exclude_tank_role = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_prio_high_exclude_tank_role:SetPosition('LEFT', self.threat_color_prio_high.Label, 'RIGHT', 12, 0);
    self.threat_color_prio_high_exclude_tank_role:SetLabel(L['OPTIONS_THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE']);
    self.threat_color_prio_high_exclude_tank_role:SetTooltip(L['OPTIONS_THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE_TOOLTIP']);
    self.threat_color_prio_high_exclude_tank_role:SetChecked(O.db.threat_color_prio_high_exclude_tank_role);
    self.threat_color_prio_high_exclude_tank_role:AddToSearch(button, L['OPTIONS_THREAT_COLOR_PRIO_HIGH_EXCLUDE_TANK_ROLE_TOOLTIP'], self.Tabs[4]);
    self.threat_color_prio_high_exclude_tank_role:SetEnabled(O.db.threat_color_prio_high);
    self.threat_color_prio_high_exclude_tank_role.Callback = function(self)
        O.db.threat_color_prio_high_exclude_tank_role = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ThreatTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.threat_color_prio_high, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    local ResetThreatColorsButton = E.CreateTextureButton(self.TabsFrames['ThreatTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetThreatColorsButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 4, -4);
    ResetThreatColorsButton:SetTooltip(L['OPTIONS_RESET_THREAT_COLORS_TOOLTIP']);
    ResetThreatColorsButton:AddToSearch(button, L['OPTIONS_RESET_THREAT_COLORS_TOOLTIP'], self.Tabs[4]);
    ResetThreatColorsButton.Callback = function()
        local defaultStatusColors = S:GetNameplateModule('HealthBar').defaultStatusColors;
        local defaultOffTankColor = S:GetNameplateModule('HealthBar').defaultOffTankColor;

        panel.threat_color_status_0:SetValue(unpack(defaultStatusColors[0]));
        panel.threat_color_status_1:SetValue(unpack(defaultStatusColors[1]));
        panel.threat_color_status_2:SetValue(unpack(defaultStatusColors[2]));
        panel.threat_color_status_3:SetValue(unpack(defaultStatusColors[3]));
        panel.threat_color_offtank:SetValue(unpack(defaultOffTankColor));
        panel.threat_color_pettank:SetValue(unpack(O.DefaultValues.threat_color_pettank));
        panel.threat_color_playerpettank:SetValue(unpack(O.DefaultValues.threat_color_playerpettank));
    end

    self.threat_color_status_0 = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_status_0:SetPosition('LEFT', ResetThreatColorsButton, 'RIGHT', 16, 0);
    self.threat_color_status_0:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_0_TOOLTIP']);
    self.threat_color_status_0:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_0_TOOLTIP'], self.Tabs[4]);
    self.threat_color_status_0:SetValue(unpack(O.db.threat_color_status_0));
    self.threat_color_status_0.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_0[1] = r;
        O.db.threat_color_status_0[2] = g;
        O.db.threat_color_status_0[3] = b;
        O.db.threat_color_status_0[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_status_1 = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_status_1:SetPosition('LEFT', self.threat_color_status_0, 'RIGHT', 12, 0);
    self.threat_color_status_1:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_1_TOOLTIP']);
    self.threat_color_status_1:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_1_TOOLTIP'], self.Tabs[4]);
    self.threat_color_status_1:SetValue(unpack(O.db.threat_color_status_1));
    self.threat_color_status_1.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_1[1] = r;
        O.db.threat_color_status_1[2] = g;
        O.db.threat_color_status_1[3] = b;
        O.db.threat_color_status_1[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_status_2 = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_status_2:SetPosition('LEFT', self.threat_color_status_1, 'RIGHT', 12, 0);
    self.threat_color_status_2:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_2_TOOLTIP']);
    self.threat_color_status_2:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_2_TOOLTIP'], self.Tabs[4]);
    self.threat_color_status_2:SetValue(unpack(O.db.threat_color_status_2));
    self.threat_color_status_2.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_2[1] = r;
        O.db.threat_color_status_2[2] = g;
        O.db.threat_color_status_2[3] = b;
        O.db.threat_color_status_2[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_status_3 = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_status_3:SetPosition('LEFT', self.threat_color_status_2, 'RIGHT', 12, 0);
    self.threat_color_status_3:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_3_TOOLTIP']);
    self.threat_color_status_3:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_3_TOOLTIP'], self.Tabs[4]);
    self.threat_color_status_3:SetValue(unpack(O.db.threat_color_status_3));
    self.threat_color_status_3.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_3[1] = r;
        O.db.threat_color_status_3[2] = g;
        O.db.threat_color_status_3[3] = b;
        O.db.threat_color_status_3[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_pettank = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_pettank:SetPosition('LEFT', self.threat_color_status_3, 'RIGHT', 12, 0);
    self.threat_color_pettank:SetTooltip(L['OPTIONS_THREAT_COLOR_PETTANK_TOOLTIP']);
    self.threat_color_pettank:AddToSearch(button, L['OPTIONS_THREAT_COLOR_PETTANK_TOOLTIP'], self.Tabs[4]);
    self.threat_color_pettank:SetValue(unpack(O.db.threat_color_pettank));
    self.threat_color_pettank.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_pettank[1] = r;
        O.db.threat_color_pettank[2] = g;
        O.db.threat_color_pettank[3] = b;
        O.db.threat_color_pettank[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_playerpettank = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_playerpettank:SetPosition('LEFT', self.threat_color_pettank, 'RIGHT', 12, 0);
    self.threat_color_playerpettank:SetTooltip(L['OPTIONS_THREAT_COLOR_PLAYERPETTANK_TOOLTIP']);
    self.threat_color_playerpettank:AddToSearch(button, L['OPTIONS_THREAT_COLOR_PLAYERPETTANK_TOOLTIP'], self.Tabs[4]);
    self.threat_color_playerpettank:SetValue(unpack(O.db.threat_color_playerpettank));
    self.threat_color_playerpettank.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_playerpettank[1] = r;
        O.db.threat_color_playerpettank[2] = g;
        O.db.threat_color_playerpettank[3] = b;
        O.db.threat_color_playerpettank[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.threat_color_offtank = E.CreateColorPicker(self.TabsFrames['ThreatTab'].Content);
    self.threat_color_offtank:SetPosition('LEFT', self.threat_color_playerpettank, 'RIGHT', 12, 0);
    self.threat_color_offtank:SetTooltip(L['OPTIONS_THREAT_COLOR_OFFTANK_TOOLTIP']);
    self.threat_color_offtank:AddToSearch(button, L['OPTIONS_THREAT_COLOR_OFFTANK_TOOLTIP'], self.Tabs[4]);
    self.threat_color_offtank:SetValue(unpack(O.db.threat_color_offtank));
    self.threat_color_offtank.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_offtank[1] = r;
        O.db.threat_color_offtank[2] = g;
        O.db.threat_color_offtank[3] = b;
        O.db.threat_color_offtank[4] = a or 1;

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ThreatTab'].Content);
    Delimiter:SetPosition('TOPLEFT', ResetThreatColorsButton, 'BOTTOMLEFT', -4, -4);
    Delimiter:SetW(self:GetWidth());

    self.threat_percentage_enabled = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.threat_percentage_enabled:SetLabel(L['OPTIONS_THREAT_PERCENTAGE_ENABLED']);
    self.threat_percentage_enabled:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_ENABLED_TOOLTIP']);
    self.threat_percentage_enabled:SetChecked(O.db.threat_percentage_enabled);
    self.threat_percentage_enabled:AddToSearch(button, L['OPTIONS_THREAT_PERCENTAGE_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.threat_percentage_enabled.Callback = function(self)
        O.db.threat_percentage_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.threat_percentage_coloring = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_coloring:SetPosition('LEFT', self.threat_percentage_enabled.Label, 'RIGHT', 12, 0);
    self.threat_percentage_coloring:SetLabel(L['OPTIONS_THREAT_PERCENTAGE_COLORING']);
    self.threat_percentage_coloring:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_COLORING_TOOLTIP']);
    self.threat_percentage_coloring:SetChecked(O.db.threat_percentage_coloring);
    self.threat_percentage_coloring:AddToSearch(button, L['OPTIONS_THREAT_PERCENTAGE_COLORING_TOOLTIP'], self.Tabs[4]);
    self.threat_percentage_coloring.Callback = function(self)
        O.db.threat_percentage_coloring = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.threat_percentage_font_value = E.CreateDropdown('font', self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_font_value:SetSize(160, 20);
    self.threat_percentage_font_value:SetList(LSM:HashTable('font'));
    self.threat_percentage_font_value:SetValue(O.db.threat_percentage_font_value);
    self.threat_percentage_font_value:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_FONT_VALUE_TOOLTIP']);
    self.threat_percentage_font_value.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_font_value = value;
        Stripes:UpdateAll();
    end

    self.threat_percentage_font_size = E.CreateSlider(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_font_size:SetValues(O.db.threat_percentage_font_size, 3, 28, 1);
    self.threat_percentage_font_size:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_FONT_SIZE_TOOLTIP']);
    self.threat_percentage_font_size.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_percentage_font_flag = E.CreateDropdown('plain', self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_font_flag:SetSize(160, 20);
    self.threat_percentage_font_flag:SetList(O.Lists.font_flags_localized);
    self.threat_percentage_font_flag:SetValue(O.db.threat_percentage_font_flag);
    self.threat_percentage_font_flag:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_FONT_FLAG_TOOLTIP']);
    self.threat_percentage_font_flag.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_percentage_font_shadow = E.CreateCheckButton(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.threat_percentage_font_shadow:SetChecked(O.db.threat_percentage_font_shadow);
    self.threat_percentage_font_shadow:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_FONT_SHADOW_TOOLTIP']);
    self.threat_percentage_font_shadow.Callback = function(self)
        O.db.threat_percentage_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.ThreatTextFontOptions = E.CreatePopOptions(self.TabsFrames['ThreatTab'].Content);
    self.ThreatTextFontOptions:SetH(60);
    self.ThreatTextFontOptions:Add(self.threat_percentage_font_value):SetPosition('TOPLEFT', self.ThreatTextFontOptions, 'TOPLEFT', 8, -20);
    self.ThreatTextFontOptions:Add(self.threat_percentage_font_size):SetPosition('LEFT', self.threat_percentage_font_value, 'RIGHT', 12, 0);
    self.ThreatTextFontOptions:Add(self.threat_percentage_font_flag):SetPosition('LEFT', self.threat_percentage_font_size, 'RIGHT', 12, 0);
    self.ThreatTextFontOptions:Add(self.threat_percentage_font_shadow):SetPosition('LEFT', self.threat_percentage_font_flag, 'RIGHT', 12, 0);
    self.ThreatTextFontOptions.OpenButton:SetPosition('TOPLEFT', self.threat_percentage_enabled, 'BOTTOMLEFT', 0, -8);
    self.ThreatTextFontOptions.OpenButton:SetLabel(L['FONT_OPTIONS']);

    self.threat_percentage_point = E.CreateDropdown('plain', self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_point:SetSize(120, 20);
    self.threat_percentage_point:SetList(O.Lists.frame_points_localized);
    self.threat_percentage_point:SetValue(O.db.threat_percentage_point);
    self.threat_percentage_point:SetLabel(L['POSITION']);
    self.threat_percentage_point:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_POINT_TOOLTIP']);
    self.threat_percentage_point.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_percentage_relative_point = E.CreateDropdown('plain', self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_relative_point:SetSize(120, 20);
    self.threat_percentage_relative_point:SetList(O.Lists.frame_points_localized);
    self.threat_percentage_relative_point:SetValue(O.db.threat_percentage_relative_point);
    self.threat_percentage_relative_point:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_RELATIVE_POINT_TOOLTIP']);
    self.threat_percentage_relative_point.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_percentage_offset_x = E.CreateSlider(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_offset_x:SetSize(120, 18);
    self.threat_percentage_offset_x:SetValues(O.db.threat_percentage_offset_x, -50, 50, 1);
    self.threat_percentage_offset_x:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_OFFSET_X_TOOLTIP']);
    self.threat_percentage_offset_x.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.threat_percentage_offset_y = E.CreateSlider(self.TabsFrames['ThreatTab'].Content);
    self.threat_percentage_offset_y:SetSize(120, 18);
    self.threat_percentage_offset_y:SetValues(O.db.threat_percentage_offset_y, -50, 50, 1);
    self.threat_percentage_offset_y:SetTooltip(L['OPTIONS_THREAT_PERCENTAGE_OFFSET_Y_TOOLTIP']);
    self.threat_percentage_offset_y.OnValueChangedCallback = function(_, value)
        O.db.threat_percentage_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.ThreatTextPositionOptions = E.CreatePopOptions(self.TabsFrames['ThreatTab'].Content);
    self.ThreatTextPositionOptions:SetH(60);
    self.ThreatTextPositionOptions:Add(self.threat_percentage_point):SetPosition('TOPLEFT', self.ThreatTextPositionOptions, 'TOPLEFT', 12, -20);
    self.ThreatTextPositionOptions:Add(self.threat_percentage_relative_point):SetPosition('LEFT', self.threat_percentage_point, 'RIGHT', 12, 0);
    self.ThreatTextPositionOptions:Add(self.threat_percentage_offset_x):SetPosition('LEFT', self.threat_percentage_relative_point, 'RIGHT', 8, 0);
    self.ThreatTextPositionOptions:Add(self.threat_percentage_offset_y):SetPosition('LEFT', self.threat_percentage_offset_x, 'RIGHT', 12, 0);
    self.ThreatTextPositionOptions.OpenButton:SetPosition('LEFT', self.ThreatTextFontOptions.OpenButton, 'RIGHT', 16, 0);
    self.ThreatTextPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['ThreatTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.ThreatTextFontOptions.OpenButton, 'BOTTOMLEFT', 0, -2);
    Delimiter:SetW(self:GetWidth());

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Execution Tab -------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.execution_enabled = E.CreateCheckButton(self.TabsFrames['ExecutionTab'].Content);
    self.execution_enabled:SetPosition('TOPLEFT', self.TabsFrames['ExecutionTab'].Content, 'TOPLEFT', 0, -4);
    self.execution_enabled:SetLabel(L['OPTIONS_EXECUTION_ENABLED']);
    self.execution_enabled:SetTooltip(L['OPTIONS_EXECUTION_ENABLED_TOOLTIP']);
    self.execution_enabled:SetChecked(O.db.execution_enabled);
    self.execution_enabled:AddToSearch(button, L['OPTIONS_EXECUTION_ENABLED_TOOLTIP'], self.Tabs[5]);
    self.execution_enabled.Callback = function(self)
        O.db.execution_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.execution_color = E.CreateColorPicker(self.TabsFrames['ExecutionTab'].Content);
    self.execution_color:SetPosition('LEFT', self.execution_enabled.Label, 'RIGHT', 12, 0);
    self.execution_color:SetTooltip(L['OPTIONS_EXECUTION_COLOR_TOOLTIP']);
    self.execution_color:AddToSearch(button, L['OPTIONS_EXECUTION_COLOR_TOOLTIP'], self.Tabs[5]);
    self.execution_color:SetValue(unpack(O.db.execution_color));
    self.execution_color.OnValueChanged = function(_, r, g, b, a)
        O.db.execution_color[1] = r;
        O.db.execution_color[2] = g;
        O.db.execution_color[3] = b;
        O.db.execution_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.execution_glow = E.CreateCheckButton(self.TabsFrames['ExecutionTab'].Content);
    self.execution_glow:SetPosition('LEFT', self.execution_color, 'RIGHT', 12, 0);
    self.execution_glow:SetLabel(L['OPTIONS_EXECUTION_GLOW']);
    self.execution_glow:SetTooltip(L['OPTIONS_EXECUTION_GLOW_TOOLTIP']);
    self.execution_glow:SetChecked(O.db.execution_glow);
    self.execution_glow:AddToSearch(button, L['OPTIONS_EXECUTION_GLOW_TOOLTIP'], self.Tabs[5]);
    self.execution_glow.Callback = function(self)
        O.db.execution_glow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.execution_high_enabled = E.CreateCheckButton(self.TabsFrames['ExecutionTab'].Content);
    self.execution_high_enabled:SetPosition('LEFT', self.execution_glow.Label, 'RIGHT', 12, 0);
    self.execution_high_enabled:SetLabel(L['OPTIONS_EXECUTION_HIGH_ENABLED']);
    self.execution_high_enabled:SetTooltip(L['OPTIONS_EXECUTION_HIGH_ENABLED_TOOLTIP']);
    self.execution_high_enabled:SetChecked(O.db.execution_high_enabled);
    self.execution_high_enabled:AddToSearch(button, L['OPTIONS_EXECUTION_HIGH_ENABLED_TOOLTIP'], self.Tabs[5]);
    self.execution_high_enabled.Callback = function(self)
        O.db.execution_high_enabled = self:GetChecked();

        if not O.db.execution_high_enabled then
            panel.execution_high_text:SetFontObject('StripesOptionsDisabledFont');
            panel.execution_high_percent_sign:SetFontObject('StripesOptionsDisabledFont');
            panel.execution_high_percent:SetEnabled(false);
        else
            panel.execution_high_text:SetFontObject('StripesOptionsHighlightFont');
            panel.execution_high_percent_sign:SetFontObject('StripesOptionsHighlightFont');
            panel.execution_high_percent:SetEnabled(true);
        end

        Stripes:UpdateAll();
    end

    self.execution_low_text = E.CreateFontString(self.TabsFrames['ExecutionTab'].Content);
    self.execution_low_text:SetPosition('TOPLEFT', self.execution_enabled, 'BOTTOMLEFT', 0, -8);
    self.execution_low_text:SetText(L['OPTIONS_EXECUTION_LOW_TEXT']);

    self.execution_low_percent = E.CreateSlider(self.TabsFrames['ExecutionTab'].Content);
    self.execution_low_percent:SetPosition('LEFT', self.execution_low_text, 'RIGHT', 12, -1);
    self.execution_low_percent:SetValues(O.db.execution_low_percent, 1, 100, 1);
    self.execution_low_percent:SetTooltip(L['OPTIONS_EXECUTION_LOW_PERCENT_TOOLTIP']);
    self.execution_low_percent:AddToSearch(button, L['OPTIONS_EXECUTION_LOW_PERCENT_TOOLTIP'], self.Tabs[5]);
    self.execution_low_percent.OnValueChangedCallback = function(_, value)
        O.db.execution_low_percent = tonumber(value);
        Stripes:UpdateAll();
    end

    self.execution_low_percent_sign = E.CreateFontString(self.TabsFrames['ExecutionTab'].Content);
    self.execution_low_percent_sign:SetPosition('LEFT', self.execution_low_percent, 'RIGHT', 2, 0);
    self.execution_low_percent_sign:SetText('%');

    self.execution_high_text = E.CreateFontString(self.TabsFrames['ExecutionTab'].Content);
    self.execution_high_text:SetPosition('TOPLEFT', self.execution_low_text, 'BOTTOMLEFT', 0, -8);
    self.execution_high_text:SetText(L['OPTIONS_EXECUTION_HIGH_TEXT']);
    self.execution_high_text:SetFontObject(O.db.execution_high_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');

    self.execution_high_percent = E.CreateSlider(self.TabsFrames['ExecutionTab'].Content);
    self.execution_high_percent:SetPosition('LEFT', self.execution_high_text, 'RIGHT', 12, -1);
    self.execution_high_percent:SetValues(O.db.execution_high_percent, 1, 100, 1);
    self.execution_high_percent:SetTooltip(L['OPTIONS_EXECUTION_HIGH_PERCENT_TOOLTIP']);
    self.execution_high_percent:AddToSearch(button, L['OPTIONS_EXECUTION_HIGH_PERCENT_TOOLTIP'], self.Tabs[5]);
    self.execution_high_percent:SetEnabled(O.db.execution_high_enabled);
    self.execution_high_percent.OnValueChangedCallback = function(_, value)
        O.db.execution_high_percent = tonumber(value);
        Stripes:UpdateAll();
    end

    self.execution_high_percent_sign = E.CreateFontString(self.TabsFrames['ExecutionTab'].Content);
    self.execution_high_percent_sign:SetPosition('LEFT', self.execution_high_percent, 'RIGHT', 2, 0);
    self.execution_high_percent_sign:SetText('%');
    self.execution_high_percent_sign:SetFontObject(O.db.execution_high_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');
end