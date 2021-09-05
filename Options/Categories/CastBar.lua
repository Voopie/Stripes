local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CastBar');

local LSM = S.Libraries.LSM;

O.frame.Left.CastBar, O.frame.Right.CastBar = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CASTBAR']), 'castbar', 5);
local button = O.frame.Left.CastBar;
local panel = O.frame.Right.CastBar;

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    self.castbar_texture_value = E.CreateDropdown('statusbar', self);
    self.castbar_texture_value:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.castbar_texture_value:SetSize(200, 20);
    self.castbar_texture_value:SetList(LSM:HashTable('statusbar'));
    self.castbar_texture_value:SetValue(O.db.castbar_texture_value);
    self.castbar_texture_value:SetLabel(L['OPTIONS_TEXTURE']);
    self.castbar_texture_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.castbar_texture_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.castbar_texture_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_texture_value = value;
        Handler:UpdateAll();
    end

    self.castbar_text_font_value = E.CreateDropdown('font', self);
    self.castbar_text_font_value:SetPosition('TOPLEFT', self.castbar_texture_value, 'BOTTOMLEFT', 0, -12);
    self.castbar_text_font_value:SetSize(160, 20);
    self.castbar_text_font_value:SetList(LSM:HashTable('font'));
    self.castbar_text_font_value:SetValue(O.db.castbar_text_font_value);
    self.castbar_text_font_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE']);
    self.castbar_text_font_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE']);
    self.castbar_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_value = value;
        Handler:UpdateAll();
    end

    self.castbar_text_font_size = E.CreateSlider(self);
    self.castbar_text_font_size:SetPosition('LEFT', self.castbar_text_font_value, 'RIGHT', 12, 0);
    self.castbar_text_font_size:SetValues(O.db.castbar_text_font_size, 3, 28, 1);
    self.castbar_text_font_size:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE']);
    self.castbar_text_font_size:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE']);
    self.castbar_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.castbar_text_font_flag = E.CreateDropdown('plain', self);
    self.castbar_text_font_flag:SetPosition('LEFT', self.castbar_text_font_size, 'RIGHT', 12, 0);
    self.castbar_text_font_flag:SetSize(160, 20);
    self.castbar_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.castbar_text_font_flag:SetValue(O.db.castbar_text_font_flag);
    self.castbar_text_font_flag:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG']);
    self.castbar_text_font_flag:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG']);
    self.castbar_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.castbar_text_font_shadow = E.CreateCheckButton(self);
    self.castbar_text_font_shadow:SetPosition('LEFT', self.castbar_text_font_flag, 'RIGHT', 12, 0);
    self.castbar_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.castbar_text_font_shadow:SetChecked(O.db.castbar_text_font_shadow);
    self.castbar_text_font_shadow:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW']);
    self.castbar_text_font_shadow:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW']);
    self.castbar_text_font_shadow.Callback = function(self)
        O.db.castbar_text_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self);
    Delimiter:SetPosition('TOPLEFT', self.castbar_text_font_value, 'BOTTOMLEFT', 0, -8);
    Delimiter:SetW(self:GetWidth());

    local ResetCastBarColorsButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetCastBarColorsButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 4, -4);
    ResetCastBarColorsButton:SetTooltip(L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP']);
    ResetCastBarColorsButton:AddToSearch(button, L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP']);
    ResetCastBarColorsButton.Callback = function()
        panel.castbar_start_cast_color:SetValue(unpack(O.DefaultValues.castbar_start_cast_color));
        panel.castbar_start_channel_color:SetValue(unpack(O.DefaultValues.castbar_start_channel_color));
        panel.castbar_noninterruptible_color:SetValue(unpack(O.DefaultValues.castbar_noninterruptible_color));
        panel.castbar_failed_cast_color:SetValue(unpack(O.DefaultValues.castbar_failed_cast_color));
        panel.castbar_interrupt_ready_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_color));
        panel.castbar_interrupt_ready_tick_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_tick_color));
    end

    self.castbar_start_cast_color = E.CreateColorPicker(self);
    self.castbar_start_cast_color:SetPosition('LEFT', ResetCastBarColorsButton, 'RIGHT', 16, 0);
    self.castbar_start_cast_color:SetLabel(L['OPTIONS_CAST_BAR_START_CAST_COLOR']);
    self.castbar_start_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP']);
    self.castbar_start_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP']);
    self.castbar_start_cast_color:SetValue(unpack(O.db.castbar_start_cast_color));
    self.castbar_start_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_cast_color[1] = r;
        O.db.castbar_start_cast_color[2] = g;
        O.db.castbar_start_cast_color[3] = b;
        O.db.castbar_start_cast_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_start_channel_color = E.CreateColorPicker(self);
    self.castbar_start_channel_color:SetPosition('LEFT', self.castbar_start_cast_color.Label, 'RIGHT', 12, 0);
    self.castbar_start_channel_color:SetLabel(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR']);
    self.castbar_start_channel_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP']);
    self.castbar_start_channel_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP']);
    self.castbar_start_channel_color:SetValue(unpack(O.db.castbar_start_channel_color));
    self.castbar_start_channel_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_channel_color[1] = r;
        O.db.castbar_start_channel_color[2] = g;
        O.db.castbar_start_channel_color[3] = b;
        O.db.castbar_start_channel_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_noninterruptible_color = E.CreateColorPicker(self);
    self.castbar_noninterruptible_color:SetPosition('LEFT', self.castbar_start_channel_color.Label, 'RIGHT', 12, 0);
    self.castbar_noninterruptible_color:SetLabel(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR']);
    self.castbar_noninterruptible_color:SetTooltip(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP']);
    self.castbar_noninterruptible_color:AddToSearch(button, L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP']);
    self.castbar_noninterruptible_color:SetValue(unpack(O.db.castbar_noninterruptible_color));
    self.castbar_noninterruptible_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_noninterruptible_color[1] = r;
        O.db.castbar_noninterruptible_color[2] = g;
        O.db.castbar_noninterruptible_color[3] = b;
        O.db.castbar_noninterruptible_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_failed_cast_color = E.CreateColorPicker(self);
    self.castbar_failed_cast_color:SetPosition('LEFT', self.castbar_noninterruptible_color.Label, 'RIGHT', 12, 0);
    self.castbar_failed_cast_color:SetLabel(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR']);
    self.castbar_failed_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP']);
    self.castbar_failed_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP']);
    self.castbar_failed_cast_color:SetValue(unpack(O.db.castbar_failed_cast_color));
    self.castbar_failed_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_failed_cast_color[1] = r;
        O.db.castbar_failed_cast_color[2] = g;
        O.db.castbar_failed_cast_color[3] = b;
        O.db.castbar_failed_cast_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_interrupt_ready_color = E.CreateColorPicker(self);
    self.castbar_interrupt_ready_color:SetPosition('TOPLEFT', self.castbar_start_cast_color, 'BOTTOMLEFT', 0, -8);
    self.castbar_interrupt_ready_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_READY_COLOR']);
    self.castbar_interrupt_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_color:SetValue(unpack(O.db.castbar_interrupt_ready_color));
    self.castbar_interrupt_ready_color:SetEnabled(O.db.castbar_use_interrupt_ready_color);
    self.castbar_interrupt_ready_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_color[1] = r;
        O.db.castbar_interrupt_ready_color[2] = g;
        O.db.castbar_interrupt_ready_color[3] = b;
        O.db.castbar_interrupt_ready_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_use_interrupt_ready_color = E.CreateCheckButton(self);
    self.castbar_use_interrupt_ready_color:SetPosition('RIGHT', self.castbar_interrupt_ready_color, 'LEFT', -14, 0);
    self.castbar_use_interrupt_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_color:SetChecked(O.db.castbar_use_interrupt_ready_color);
    self.castbar_use_interrupt_ready_color.Callback = function(self)
        O.db.castbar_use_interrupt_ready_color = self:GetChecked();

        panel.castbar_interrupt_ready_color:SetEnabled(O.db.castbar_use_interrupt_ready_color);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_ready_in_time_color = E.CreateColorPicker(self);
    self.castbar_interrupt_ready_in_time_color:SetPosition('TOPLEFT', self.castbar_interrupt_ready_color, 'BOTTOMLEFT', 0, -8);
    self.castbar_interrupt_ready_in_time_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR']);
    self.castbar_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_in_time_color:SetValue(unpack(O.db.castbar_interrupt_ready_in_time_color));
    self.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_interrupt_ready_in_time_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_in_time_color[1] = r;
        O.db.castbar_interrupt_ready_in_time_color[2] = g;
        O.db.castbar_interrupt_ready_in_time_color[3] = b;
        O.db.castbar_interrupt_ready_in_time_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_use_interrupt_ready_in_time_color = E.CreateCheckButton(self);
    self.castbar_use_interrupt_ready_in_time_color:SetPosition('RIGHT', self.castbar_interrupt_ready_in_time_color, 'LEFT', -14, 0);
    self.castbar_use_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_in_time_color:SetChecked(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_use_interrupt_ready_in_time_color.Callback = function(self)
        O.db.castbar_use_interrupt_ready_in_time_color = self:GetChecked();

        panel.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_not_ready_color = E.CreateColorPicker(self);
    self.castbar_interrupt_not_ready_color:SetPosition('TOPLEFT', self.castbar_interrupt_ready_in_time_color, 'BOTTOMLEFT', 0, -8);
    self.castbar_interrupt_not_ready_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR']);
    self.castbar_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_not_ready_color:SetValue(unpack(O.db.castbar_interrupt_not_ready_color));
    self.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_interrupt_not_ready_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_not_ready_color[1] = r;
        O.db.castbar_interrupt_not_ready_color[2] = g;
        O.db.castbar_interrupt_not_ready_color[3] = b;
        O.db.castbar_interrupt_not_ready_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.castbar_use_interrupt_not_ready_color = E.CreateCheckButton(self);
    self.castbar_use_interrupt_not_ready_color:SetPosition('RIGHT', self.castbar_interrupt_not_ready_color, 'LEFT', -14, 0);
    self.castbar_use_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_not_ready_color:SetChecked(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_use_interrupt_not_ready_color.Callback = function(self)
        O.db.castbar_use_interrupt_not_ready_color = self:GetChecked();

        panel.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);

        Handler:UpdateAll();
    end

    self.castbar_show_interrupt_ready_tick = E.CreateCheckButton(self);
    self.castbar_show_interrupt_ready_tick:SetPosition('LEFT', self.castbar_interrupt_ready_color.Label, 'RIGHT', 12, 0);
    self.castbar_show_interrupt_ready_tick:SetLabel(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK']);
    self.castbar_show_interrupt_ready_tick:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP']);
    self.castbar_show_interrupt_ready_tick:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP']);
    self.castbar_show_interrupt_ready_tick:SetChecked(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_show_interrupt_ready_tick.Callback = function(self)
        O.db.castbar_show_interrupt_ready_tick = self:GetChecked();

        panel.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);

        Handler:UpdateAll();
    end

    self.castbar_interrupt_ready_tick_color = E.CreateColorPicker(self);
    self.castbar_interrupt_ready_tick_color:SetPosition('LEFT', self.castbar_show_interrupt_ready_tick.Label, 'RIGHT', 12, 0);
    self.castbar_interrupt_ready_tick_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_tick_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_tick_color:SetValue(unpack(O.db.castbar_interrupt_ready_tick_color));
    self.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_interrupt_ready_tick_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_tick_color[1] = r;
        O.db.castbar_interrupt_ready_tick_color[2] = g;
        O.db.castbar_interrupt_ready_tick_color[3] = b;
        O.db.castbar_interrupt_ready_tick_color[4] = a or 1;

        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self);
    Delimiter:SetPosition('TOPLEFT', ResetCastBarColorsButton, 'BOTTOMLEFT', -4, -110);
    Delimiter:SetW(self:GetWidth());

    self.castbar_on_hp_bar = E.CreateCheckButton(self);
    self.castbar_on_hp_bar:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -8);
    self.castbar_on_hp_bar:SetLabel(L['OPTIONS_CAST_BAR_ON_HP_BAR']);
    self.castbar_on_hp_bar:SetTooltip(L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP']);
    self.castbar_on_hp_bar:AddToSearch(button, L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP']);
    self.castbar_on_hp_bar:SetChecked(O.db.castbar_on_hp_bar);
    self.castbar_on_hp_bar.Callback = function(self)
        O.db.castbar_on_hp_bar = self:GetChecked();

        panel.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);

        Handler:UpdateAll();
    end

    self.castbar_icon_large = E.CreateCheckButton(self);
    self.castbar_icon_large:SetPosition('TOPLEFT', self.castbar_on_hp_bar, 'BOTTOMLEFT', 0, -8);
    self.castbar_icon_large:SetLabel(L['OPTIONS_CAST_BAR_ICON_LARGE']);
    self.castbar_icon_large:SetTooltip(L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP']);
    self.castbar_icon_large:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP']);
    self.castbar_icon_large:SetChecked(O.db.castbar_icon_large);
    self.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);
    self.castbar_icon_large.Callback = function(self)
        O.db.castbar_icon_large = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_icon_right_side = E.CreateCheckButton(self);
    self.castbar_icon_right_side:SetPosition('LEFT', self.castbar_icon_large.Label, 'RIGHT', 12, 0);
    self.castbar_icon_right_side:SetLabel(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE']);
    self.castbar_icon_right_side:SetTooltip(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP']);
    self.castbar_icon_right_side:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP']);
    self.castbar_icon_right_side:SetChecked(O.db.castbar_icon_right_side);
    self.castbar_icon_right_side.Callback = function(self)
        O.db.castbar_icon_right_side = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_icon_notinterruptible = E.CreateCheckButton(self);
    self.castbar_show_icon_notinterruptible:SetPosition('TOPLEFT', self.castbar_icon_large, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_icon_notinterruptible:SetLabel(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE']);
    self.castbar_show_icon_notinterruptible:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP']);
    self.castbar_show_icon_notinterruptible:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP']);
    self.castbar_show_icon_notinterruptible:SetChecked(O.db.castbar_show_icon_notinterruptible);
    self.castbar_show_icon_notinterruptible.Callback = function(self)
        O.db.castbar_show_icon_notinterruptible = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_shield = E.CreateCheckButton(self);
    self.castbar_show_shield:SetPosition('LEFT', self.castbar_show_icon_notinterruptible.Label, 'RIGHT', 12, 0);
    self.castbar_show_shield:SetLabel(L['OPTIONS_CAST_BAR_SHOW_SHIELD']);
    self.castbar_show_shield:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP']);
    self.castbar_show_shield:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP']);
    self.castbar_show_shield:SetChecked(O.db.castbar_show_shield);
    self.castbar_show_shield.Callback = function(self)
        O.db.castbar_show_shield = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_timer_enabled = E.CreateCheckButton(self);
    self.castbar_timer_enabled:SetPosition('TOPLEFT', self.castbar_show_icon_notinterruptible, 'BOTTOMLEFT', 0, -8);
    self.castbar_timer_enabled:SetLabel(L['OPTIONS_CAST_BAR_TIMER_ENABLED']);
    self.castbar_timer_enabled:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP']);
    self.castbar_timer_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP']);
    self.castbar_timer_enabled:SetChecked(O.db.castbar_timer_enabled);
    self.castbar_timer_enabled.Callback = function(self)
        O.db.castbar_timer_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.who_interrupted_enabled = E.CreateCheckButton(self);
    self.who_interrupted_enabled:SetPosition('TOPLEFT', self.castbar_timer_enabled, 'BOTTOMLEFT', 0, -8);
    self.who_interrupted_enabled:SetLabel(L['OPTIONS_WHO_INTERRUPTED_ENABLED']);
    self.who_interrupted_enabled:SetTooltip(L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP']);
    self.who_interrupted_enabled:AddToSearch(button, L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP']);
    self.who_interrupted_enabled:SetChecked(O.db.who_interrupted_enabled);
    self.who_interrupted_enabled.Callback = function(self)
        O.db.who_interrupted_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.castbar_show_tradeskills = E.CreateCheckButton(self);
    self.castbar_show_tradeskills:SetPosition('TOPLEFT', self.who_interrupted_enabled, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_tradeskills:SetLabel(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS']);
    self.castbar_show_tradeskills:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP']);
    self.castbar_show_tradeskills:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP']);
    self.castbar_show_tradeskills:SetChecked(O.db.castbar_show_tradeskills);
    self.castbar_show_tradeskills.Callback = function(self)
        O.db.castbar_show_tradeskills = self:GetChecked();
        Handler:UpdateAll();
    end
end