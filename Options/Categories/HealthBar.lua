local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_HealthBar');

local LSM = S.Libraries.LSM;

O.frame.Left.HealthBar, O.frame.Right.HealthBar = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_HEALTHBAR']), 'healthbar', 4);
local button = O.frame.Left.HealthBar;
local panel = O.frame.Right.HealthBar;

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    self.health_bar_texture_value = E.CreateDropdown('statusbar', self);
    self.health_bar_texture_value:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.health_bar_texture_value:SetSize(200, 20);
    self.health_bar_texture_value:SetList(LSM:HashTable('statusbar'));
    self.health_bar_texture_value:SetValue(O.db.health_bar_texture_value);
    self.health_bar_texture_value:SetLabel(L['OPTIONS_TEXTURE']);
    self.health_bar_texture_value:SetTooltip(L['OPTIONS_HEALTH_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.health_bar_texture_value:AddToSearch(button, L['OPTIONS_HEALTH_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.health_bar_texture_value.OnValueChangedCallback = function(_, value)
        O.db.health_bar_texture_value = value;
        Handler:UpdateAll();
    end

    self.health_bar_class_color_friendly = E.CreateCheckButton(self);
    self.health_bar_class_color_friendly:SetPosition('TOPLEFT', self.health_bar_texture_value, 'BOTTOMLEFT', 0, -8);
    self.health_bar_class_color_friendly:SetLabel(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY']);
    self.health_bar_class_color_friendly:SetTooltip(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY_TOOLTIP']);
    self.health_bar_class_color_friendly:SetChecked(O.db.health_bar_class_color_friendly);
    self.health_bar_class_color_friendly:AddToSearch(button);
    self.health_bar_class_color_friendly.Callback = function(self)
        O.db.health_bar_class_color_friendly = self:GetChecked();
        C_CVar.SetCVar('ShowClassColorInFriendlyNameplate', O.db.health_bar_class_color_friendly and 1 or 0);
        Handler:UpdateAll();
    end

    self.health_bar_class_color_enemy = E.CreateCheckButton(self);
    self.health_bar_class_color_enemy:SetPosition('LEFT', self.health_bar_class_color_friendly.Label, 'RIGHT', 12, 0);
    self.health_bar_class_color_enemy:SetLabel(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY']);
    self.health_bar_class_color_enemy:SetTooltip(L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY_TOOLTIP']);
    self.health_bar_class_color_enemy:SetChecked(O.db.health_bar_class_color_enemy);
    self.health_bar_class_color_enemy:AddToSearch(button);
    self.health_bar_class_color_enemy.Callback = function(self)
        O.db.health_bar_class_color_enemy = self:GetChecked();
        C_CVar.SetCVar('ShowClassColorInNameplate', O.db.health_bar_class_color_enemy and 1 or 0);
        Handler:UpdateAll();
    end

    self.health_bar_border_thin = E.CreateCheckButton(self);
    self.health_bar_border_thin:SetPosition('TOPLEFT', self.health_bar_class_color_friendly, 'BOTTOMLEFT', 0, -8);
    self.health_bar_border_thin:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_THIN']);
    self.health_bar_border_thin:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_THIN_TOOLTIP']);
    self.health_bar_border_thin:SetChecked(O.db.health_bar_border_thin);
    self.health_bar_border_thin:AddToSearch(button);
    self.health_bar_border_thin.Callback = function(self)
        O.db.health_bar_border_thin = self:GetChecked();
        Handler:UpdateAll();
    end

    self.health_bar_border_hide = E.CreateCheckButton(self);
    self.health_bar_border_hide:SetPosition('LEFT', self.health_bar_border_thin.Label, 'RIGHT', 12, 0);
    self.health_bar_border_hide:SetLabel(L['OPTIONS_HEALTH_BAR_BORDER_HIDE']);
    self.health_bar_border_hide:SetTooltip(L['OPTIONS_HEALTH_BAR_BORDER_HIDE_TOOLTIP']);
    self.health_bar_border_hide:SetChecked(O.db.health_bar_border_hide);
    self.health_bar_border_hide:AddToSearch(button);
    self.health_bar_border_hide.Callback = function(self)
        O.db.health_bar_border_hide = self:GetChecked();
        Handler:UpdateAll();
    end

    local AbsorbHeader = E.CreateHeader(self, L['OPTIONS_HEADER_ABSORB']);
    AbsorbHeader:SetPosition('TOPLEFT', self.health_bar_border_thin, 'BOTTOMLEFT', 0, -4);
    AbsorbHeader:SetW(self:GetWidth());

    self.absorb_bar_enabled = E.CreateCheckButton(self);
    self.absorb_bar_enabled:SetPosition('TOPLEFT', AbsorbHeader, 'BOTTOMLEFT', 0, -4);
    self.absorb_bar_enabled:SetLabel(L['OPTIONS_ABSORB_BAR_ENABLED']);
    self.absorb_bar_enabled:SetTooltip(L['OPTIONS_ABSORB_BAR_ENABLED_TOOLTIP']);
    self.absorb_bar_enabled:SetChecked(O.db.absorb_bar_enabled);
    self.absorb_bar_enabled:AddToSearch(button, L['OPTIONS_ABSORB_BAR_ENABLED_TOOLTIP']);
    self.absorb_bar_enabled.Callback = function(self)
        O.db.absorb_bar_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.absorb_bar_at_top = E.CreateCheckButton(self);
    self.absorb_bar_at_top:SetPosition('LEFT', self.absorb_bar_enabled.Label, 'RIGHT', 12, 0);
    self.absorb_bar_at_top:SetLabel(L['OPTIONS_ABSORB_BAR_AT_TOP']);
    self.absorb_bar_at_top:SetTooltip(L['OPTIONS_ABSORB_BAR_AT_TOP_TOOLTIP']);
    self.absorb_bar_at_top:SetChecked(O.db.absorb_bar_at_top);
    self.absorb_bar_at_top:AddToSearch(button, L['OPTIONS_ABSORB_BAR_AT_TOP_TOOLTIP']);
    self.absorb_bar_at_top.Callback = function(self)
        O.db.absorb_bar_at_top = self:GetChecked();
        Handler:UpdateAll();
    end

    local TargetIndicatorHeader = E.CreateHeader(self, L['OPTIONS_HEADER_TARGET_INDICATOR']);
    TargetIndicatorHeader:SetPosition('TOPLEFT', self.absorb_bar_enabled, 'BOTTOMLEFT', 0, -4);
    TargetIndicatorHeader:SetW(self:GetWidth());

    self.target_indicator_enabled = E.CreateCheckButton(self);
    self.target_indicator_enabled:SetPosition('TOPLEFT', TargetIndicatorHeader, 'BOTTOMLEFT', 0, -4);
    self.target_indicator_enabled:SetLabel(L['OPTIONS_TARGET_INDICATOR_ENABLED']);
    self.target_indicator_enabled:SetTooltip(L['OPTIONS_TARGET_INDICATOR_ENABLED_TOOLTIP']);
    self.target_indicator_enabled:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_ENABLED_TOOLTIP']);
    self.target_indicator_enabled:SetChecked(O.db.target_indicator_enabled);
    self.target_indicator_enabled.Callback = function(self)
        O.db.target_indicator_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.target_indicator_texture = E.CreateDropdown('texture', self);
    self.target_indicator_texture:SetPosition('LEFT', self.target_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.target_indicator_texture:SetSize(87, 20);
    self.target_indicator_texture:SetList(O.Lists.target_indicator_texture_path);
    self.target_indicator_texture:SetLabel(L['OPTIONS_TARGET_INDICATOR_TEXTURE']);
    self.target_indicator_texture:SetTooltip(L['OPTIONS_TARGET_INDICATOR_TEXTURE_TOOLTIP']);
    self.target_indicator_texture:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_TEXTURE_TOOLTIP']);
    self.target_indicator_texture:SetValue(O.db.target_indicator_texture);
    self.target_indicator_texture.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_texture = tonumber(value);
        Handler:UpdateAll();
    end

    self.target_indicator_color = E.CreateColorPicker(self);
    self.target_indicator_color:SetPosition('LEFT', self.target_indicator_texture, 'RIGHT', 12, 0);
    self.target_indicator_color:SetTooltip(L['OPTIONS_TARGET_INDICATOR_COLOR_TOOLTIP']);
    self.target_indicator_color:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_COLOR_TOOLTIP']);
    self.target_indicator_color:SetValue(unpack(O.db.target_indicator_color));
    self.target_indicator_color.OnValueChanged = function(_, r, g, b, a)
        O.db.target_indicator_color[1] = r;
        O.db.target_indicator_color[2] = g;
        O.db.target_indicator_color[3] = b;
        O.db.target_indicator_color[4] = a;

        Handler:UpdateAll();
    end

    self.target_indicator_size = E.CreateSlider(self);
    self.target_indicator_size:SetPosition('TOPLEFT', self.target_indicator_enabled, 'BOTTOMLEFT', 0, -12);
    self.target_indicator_size:SetValues(O.db.target_indicator_size, 1, 64, 1);
    self.target_indicator_size:SetTooltip(L['OPTIONS_TARGET_INDICATOR_SIZE_TOOLTIP']);
    self.target_indicator_size:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_SIZE_TOOLTIP']);
    self.target_indicator_size.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.target_indicator_x_offset = E.CreateSlider(self);
    self.target_indicator_x_offset:SetPosition('LEFT', self.target_indicator_size, 'RIGHT', 12, 0);
    self.target_indicator_x_offset:SetValues(O.db.target_indicator_x_offset, -50, 50, 1);
    self.target_indicator_x_offset:SetTooltip(L['OPTIONS_TARGET_INDICATOR_X_OFFSET_TOOLTIP']);
    self.target_indicator_x_offset:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_X_OFFSET_TOOLTIP']);
    self.target_indicator_x_offset.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_x_offset = tonumber(value);
        Handler:UpdateAll();
    end

    self.target_indicator_y_offset = E.CreateSlider(self);
    self.target_indicator_y_offset:SetPosition('LEFT', self.target_indicator_x_offset, 'RIGHT', 12, 0);
    self.target_indicator_y_offset:SetValues(O.db.target_indicator_y_offset, -50, 50, 1);
    self.target_indicator_y_offset:SetTooltip(L['OPTIONS_TARGET_INDICATOR_Y_OFFSET_TOOLTIP']);
    self.target_indicator_y_offset:AddToSearch(button, L['OPTIONS_TARGET_INDICATOR_Y_OFFSET_TOOLTIP']);
    self.target_indicator_y_offset.OnValueChangedCallback = function(_, value)
        O.db.target_indicator_y_offset = tonumber(value);
        Handler:UpdateAll();
    end

    self.target_glow_enabled = E.CreateCheckButton(self);
    self.target_glow_enabled:SetPosition('TOPLEFT', self.target_indicator_size, 'BOTTOMLEFT', 0, -12);
    self.target_glow_enabled:SetLabel(L['OPTIONS_TARGET_GLOW_ENABLED']);
    self.target_glow_enabled:SetTooltip(L['OPTIONS_TARGET_GLOW_ENABLED_TOOLTIP']);
    self.target_glow_enabled:AddToSearch(button);
    self.target_glow_enabled:SetChecked(O.db.target_glow_enabled);
    self.target_glow_enabled.Callback = function(self)
        O.db.target_glow_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.hover_glow_enabled = E.CreateCheckButton(self);
    self.hover_glow_enabled:SetPosition('LEFT', self.target_glow_enabled.Label, 'RIGHT', 12, 0);
    self.hover_glow_enabled:SetLabel(L['OPTIONS_HOVER_GLOW_ENABLED']);
    self.hover_glow_enabled:SetTooltip(L['OPTIONS_HOVER_GLOW_ENABLED_TOOLTIP']);
    self.hover_glow_enabled:AddToSearch(button, L['OPTIONS_HOVER_GLOW_ENABLED_TOOLTIP']);
    self.hover_glow_enabled:SetChecked(O.db.hover_glow_enabled);
    self.hover_glow_enabled.Callback = function(self)
        O.db.hover_glow_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.target_glow_color = E.CreateColorPicker(self);
    self.target_glow_color:SetPosition('LEFT', self.hover_glow_enabled.Label, 'RIGHT', 12, 0);
    self.target_glow_color:SetTooltip(L['OPTIONS_TARGET_GLOW_COLOR_TOOLTIP']);
    self.target_glow_color:AddToSearch(button, L['OPTIONS_TARGET_GLOW_COLOR_TOOLTIP']);
    self.target_glow_color:SetValue(unpack(O.db.target_glow_color));
    self.target_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.target_glow_color[1] = r;
        O.db.target_glow_color[2] = g;
        O.db.target_glow_color[3] = b;
        O.db.target_glow_color[4] = a;

        Handler:UpdateAll();
    end

    local ThreatHeader = E.CreateHeader(self, L['OPTIONS_HEADER_THREAT']);
    ThreatHeader:SetPosition('TOPLEFT', self.target_glow_enabled, 'BOTTOMLEFT', 0, -4);
    ThreatHeader:SetW(self:GetWidth());

    self.threat_color_enabled = E.CreateCheckButton(self);
    self.threat_color_enabled:SetPosition('TOPLEFT', ThreatHeader, 'BOTTOMLEFT', 0, -4);
    self.threat_color_enabled:SetLabel(L['OPTIONS_THREAT_COLOR_ENABLED']);
    self.threat_color_enabled:SetTooltip(L['OPTIONS_THREAT_COLOR_ENABLED_TOOLTIP']);
    self.threat_color_enabled:SetChecked(O.db.threat_color_enabled);
    self.threat_color_enabled:AddToSearch(button);
    self.threat_color_enabled.Callback = function(self)
        O.db.threat_color_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.threat_color_reversed = E.CreateCheckButton(self);
    self.threat_color_reversed:SetPosition('LEFT', self.threat_color_enabled.Label, 'RIGHT', 12, 0);
    self.threat_color_reversed:SetLabel(L['OPTIONS_THREAT_COLOR_REVERSED']);
    self.threat_color_reversed:SetTooltip(L['OPTIONS_THREAT_COLOR_REVERSED_TOOLTIP']);
    self.threat_color_reversed:SetChecked(O.db.threat_color_reversed);
    self.threat_color_reversed:AddToSearch(button, L['OPTIONS_THREAT_COLOR_REVERSED_TOOLTIP']);
    self.threat_color_reversed.Callback = function(self)
        O.db.threat_color_reversed = self:GetChecked();
        Handler:UpdateAll();
    end

    local ResetThreatColorsButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetThreatColorsButton:SetPosition('TOPLEFT', self.threat_color_enabled, 'BOTTOMLEFT', 4, -12);
    ResetThreatColorsButton:SetTooltip(L['OPTIONS_RESET_THREAT_COLORS_TOOLTIP']);
    ResetThreatColorsButton:AddToSearch(button, L['OPTIONS_RESET_THREAT_COLORS_TOOLTIP']);
    ResetThreatColorsButton.Callback = function()
        local defaultStatusColors = S:GetNameplateModule('HealthBar').defaultStatusColors;
        local defaultOffTankColor = S:GetNameplateModule('HealthBar').defaultOffTankColor;

        panel.threat_color_status_0:SetValue(unpack(defaultStatusColors[0]));
        panel.threat_color_status_1:SetValue(unpack(defaultStatusColors[1]));
        panel.threat_color_status_2:SetValue(unpack(defaultStatusColors[2]));
        panel.threat_color_status_3:SetValue(unpack(defaultStatusColors[3]));
        panel.threat_color_offtank:SetValue(unpack(defaultOffTankColor));
    end

    self.threat_color_status_0 = E.CreateColorPicker(self);
    self.threat_color_status_0:SetPosition('LEFT', ResetThreatColorsButton, 'RIGHT', 16, 0);
    self.threat_color_status_0:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_0_TOOLTIP']);
    self.threat_color_status_0:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_0_TOOLTIP']);
    self.threat_color_status_0:SetValue(unpack(O.db.threat_color_status_0));
    self.threat_color_status_0.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_0[1] = r;
        O.db.threat_color_status_0[2] = g;
        O.db.threat_color_status_0[3] = b;
        O.db.threat_color_status_0[4] = a;

        Handler:UpdateAll();
    end

    self.threat_color_status_1 = E.CreateColorPicker(self);
    self.threat_color_status_1:SetPosition('LEFT', self.threat_color_status_0, 'RIGHT', 12, 0);
    self.threat_color_status_1:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_1_TOOLTIP']);
    self.threat_color_status_1:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_1_TOOLTIP']);
    self.threat_color_status_1:SetValue(unpack(O.db.threat_color_status_1));
    self.threat_color_status_1.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_1[1] = r;
        O.db.threat_color_status_1[2] = g;
        O.db.threat_color_status_1[3] = b;
        O.db.threat_color_status_1[4] = a;

        Handler:UpdateAll();
    end

    self.threat_color_status_2 = E.CreateColorPicker(self);
    self.threat_color_status_2:SetPosition('LEFT', self.threat_color_status_1, 'RIGHT', 12, 0);
    self.threat_color_status_2:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_2_TOOLTIP']);
    self.threat_color_status_2:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_2_TOOLTIP']);
    self.threat_color_status_2:SetValue(unpack(O.db.threat_color_status_2));
    self.threat_color_status_2.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_2[1] = r;
        O.db.threat_color_status_2[2] = g;
        O.db.threat_color_status_2[3] = b;
        O.db.threat_color_status_2[4] = a;

        Handler:UpdateAll();
    end

    self.threat_color_status_3 = E.CreateColorPicker(self);
    self.threat_color_status_3:SetPosition('LEFT', self.threat_color_status_2, 'RIGHT', 12, 0);
    self.threat_color_status_3:SetTooltip(L['OPTIONS_THREAT_COLOR_STATUS_3_TOOLTIP']);
    self.threat_color_status_3:AddToSearch(button, L['OPTIONS_THREAT_COLOR_STATUS_3_TOOLTIP']);
    self.threat_color_status_3:SetValue(unpack(O.db.threat_color_status_3));
    self.threat_color_status_3.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_status_3[1] = r;
        O.db.threat_color_status_3[2] = g;
        O.db.threat_color_status_3[3] = b;
        O.db.threat_color_status_3[4] = a;

        Handler:UpdateAll();
    end

    self.threat_color_offtank = E.CreateColorPicker(self);
    self.threat_color_offtank:SetPosition('LEFT', self.threat_color_status_3, 'RIGHT', 12, 0);
    self.threat_color_offtank:SetTooltip(L['OPTIONS_THREAT_COLOR_OFFTANK_TOOLTIP']);
    self.threat_color_offtank:AddToSearch(button, L['OPTIONS_THREAT_COLOR_OFFTANK_TOOLTIP']);
    self.threat_color_offtank:SetValue(unpack(O.db.threat_color_offtank));
    self.threat_color_offtank.OnValueChanged = function(_, r, g, b, a)
        O.db.threat_color_offtank[1] = r;
        O.db.threat_color_offtank[2] = g;
        O.db.threat_color_offtank[3] = b;
        O.db.threat_color_offtank[4] = a;

        Handler:UpdateAll();
    end

    local ExecutionHeader = E.CreateHeader(self, L['OPTIONS_HEADER_EXECUTION']);
    ExecutionHeader:SetPosition('TOPLEFT', ResetThreatColorsButton, 'BOTTOMLEFT', -4, -4);
    ExecutionHeader:SetW(self:GetWidth());

    self.execution_enabled = E.CreateCheckButton(self);
    self.execution_enabled:SetPosition('TOPLEFT', ExecutionHeader, 'BOTTOMLEFT', 0, -4);
    self.execution_enabled:SetLabel(L['OPTIONS_EXECUTION_ENABLED']);
    self.execution_enabled:SetTooltip(L['OPTIONS_EXECUTION_ENABLED_TOOLTIP']);
    self.execution_enabled:SetChecked(O.db.execution_enabled);
    self.execution_enabled:AddToSearch(button, L['OPTIONS_EXECUTION_ENABLED_TOOLTIP']);
    self.execution_enabled.Callback = function(self)
        O.db.execution_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.execution_color = E.CreateColorPicker(self);
    self.execution_color:SetPosition('LEFT', self.execution_enabled.Label, 'RIGHT', 12, 0);
    self.execution_color:SetTooltip(L['OPTIONS_EXECUTION_COLOR_TOOLTIP']);
    self.execution_color:AddToSearch(button, L['OPTIONS_EXECUTION_COLOR_TOOLTIP']);
    self.execution_color:SetValue(unpack(O.db.execution_color));
    self.execution_color.OnValueChanged = function(_, r, g, b, a)
        O.db.execution_color[1] = r;
        O.db.execution_color[2] = g;
        O.db.execution_color[3] = b;
        O.db.execution_color[4] = a;

        Handler:UpdateAll();
    end

    self.execution_glow = E.CreateCheckButton(self);
    self.execution_glow:SetPosition('LEFT', self.execution_color, 'RIGHT', 12, 0);
    self.execution_glow:SetLabel(L['OPTIONS_EXECUTION_GLOW']);
    self.execution_glow:SetTooltip(L['OPTIONS_EXECUTION_GLOW_TOOLTIP']);
    self.execution_glow:SetChecked(O.db.execution_glow);
    self.execution_glow:AddToSearch(button, L['OPTIONS_EXECUTION_GLOW_TOOLTIP']);
    self.execution_glow.Callback = function(self)
        O.db.execution_glow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.execution_high_enabled = E.CreateCheckButton(self);
    self.execution_high_enabled:SetPosition('LEFT', self.execution_glow.Label, 'RIGHT', 12, 0);
    self.execution_high_enabled:SetLabel(L['OPTIONS_EXECUTION_HIGH_ENABLED']);
    self.execution_high_enabled:SetTooltip(L['OPTIONS_EXECUTION_HIGH_ENABLED_TOOLTIP']);
    self.execution_high_enabled:SetChecked(O.db.execution_high_enabled);
    self.execution_high_enabled:AddToSearch(button, L['OPTIONS_EXECUTION_HIGH_ENABLED_TOOLTIP']);
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

        Handler:UpdateAll();
    end

    self.execution_low_text = E.CreateFontString(self);
    self.execution_low_text:SetPosition('TOPLEFT', self.execution_enabled, 'BOTTOMLEFT', 0, -8);
    self.execution_low_text:SetText(L['OPTIONS_EXECUTION_LOW_TEXT']);

    self.execution_low_percent = E.CreateSlider(self);
    self.execution_low_percent:SetPosition('LEFT', self.execution_low_text, 'RIGHT', 12, -1);
    self.execution_low_percent:SetValues(O.db.execution_low_percent, 1, 100, 1);
    self.execution_low_percent:SetTooltip(L['OPTIONS_EXECUTION_LOW_PERCENT_TOOLTIP']);
    self.execution_low_percent:AddToSearch(button, L['OPTIONS_EXECUTION_LOW_PERCENT_TOOLTIP']);
    self.execution_low_percent.OnValueChangedCallback = function(_, value)
        O.db.execution_low_percent = tonumber(value);
        Handler:UpdateAll();
    end

    self.execution_low_percent_sign = E.CreateFontString(self);
    self.execution_low_percent_sign:SetPosition('LEFT', self.execution_low_percent, 'RIGHT', 2, 0);
    self.execution_low_percent_sign:SetText('%');

    self.execution_high_text = E.CreateFontString(self);
    self.execution_high_text:SetPosition('TOPLEFT', self.execution_low_text, 'BOTTOMLEFT', 0, -8);
    self.execution_high_text:SetText(L['OPTIONS_EXECUTION_HIGH_TEXT']);
    self.execution_high_text:SetFontObject(O.db.execution_high_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');

    self.execution_high_percent = E.CreateSlider(self);
    self.execution_high_percent:SetPosition('LEFT', self.execution_high_text, 'RIGHT', 12, -1);
    self.execution_high_percent:SetValues(O.db.execution_high_percent, 1, 100, 1);
    self.execution_high_percent:SetTooltip(L['OPTIONS_EXECUTION_HIGH_PERCENT_TOOLTIP']);
    self.execution_high_percent:AddToSearch(button, L['OPTIONS_EXECUTION_HIGH_PERCENT_TOOLTIP']);
    self.execution_high_percent:SetEnabled(O.db.execution_high_enabled);
    self.execution_high_percent.OnValueChangedCallback = function(_, value)
        O.db.execution_high_percent = tonumber(value);
        Handler:UpdateAll();
    end

    self.execution_high_percent_sign = E.CreateFontString(self);
    self.execution_high_percent_sign:SetPosition('LEFT', self.execution_high_percent, 'RIGHT', 2, 0);
    self.execution_high_percent_sign:SetText('%');
    self.execution_high_percent_sign:SetFontObject(O.db.execution_high_enabled and 'StripesOptionsHighlightFont' or 'StripesOptionsDisabledFont');
end