local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Common');

local LSM = S.Libraries.LSM;

O.frame.Left.Common, O.frame.Right.Common = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_COMMON']), 'common', 1);
local button = O.frame.Left.Common;
local panel  = O.frame.Right.Common;

panel.TabsData = {
    [1] = {
        name  = 'NameTab',
        title = string.upper(L['OPTIONS_COMMON_TAB_NAME']),
    },
    [2] = {
        name  = 'HealthTextTab',
        title = string.upper(L['OPTIONS_COMMON_TAB_HEALTHTEXT']),
    },
    [3] = {
        name  = 'LevelTextTab',
        title = string.upper(L['OPTIONS_COMMON_TAB_LEVELTEXT']),
    },
};

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Name text Tab -------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.name_text_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_enabled:SetPosition('TOPLEFT', self.TabsFrames['NameTab'].Content, 'TOPLEFT', 0, -4);
    self.name_text_enabled:SetLabel(L['OPTIONS_SHOW']);
    self.name_text_enabled:SetChecked(O.db.name_text_enabled);
    self.name_text_enabled:SetTooltip(L['OPTIONS_NAME_TEXT_SHOW']);
    self.name_text_enabled:AddToSearch(button, L['OPTIONS_NAME_TEXT_SHOW'], self.Tabs[1]);
    self.name_text_enabled.Callback = function(self)
        O.db.name_text_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.name_without_realm = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_without_realm:SetPosition('LEFT', self.name_text_enabled.Label, 'RIGHT', 12, 0);
    self.name_without_realm:SetLabel(L['OPTIONS_NAME_WITHOUT_REALM']);
    self.name_without_realm:SetChecked(O.db.name_without_realm);
    self.name_without_realm:SetTooltip(L['OPTIONS_NAME_WITHOUT_REALM_TOOLTIP']);
    self.name_without_realm:AddToSearch(button, L['OPTIONS_NAME_WITHOUT_REALM_TOOLTIP'], self.Tabs[1]);
    self.name_without_realm.Callback = function(self)
        O.db.name_without_realm = self:GetChecked();
        Handler:UpdateAll();
    end

    self.name_text_font_value = E.CreateDropdown('font', self.TabsFrames['NameTab'].Content);
    self.name_text_font_value:SetPosition('TOPLEFT', self.name_text_enabled, 'BOTTOMLEFT', 0, -12);
    self.name_text_font_value:SetSize(160, 20);
    self.name_text_font_value:SetList(LSM:HashTable('font'));
    self.name_text_font_value:SetValue(O.db.name_text_font_value);
    self.name_text_font_value:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_VALUE']);
    self.name_text_font_value:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_VALUE'], self.Tabs[1]);
    self.name_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.name_text_font_value = value;
        Handler:UpdateAll();
    end

    self.name_text_font_size = E.CreateSlider(self.TabsFrames['NameTab'].Content);
    self.name_text_font_size:SetPosition('LEFT', self.name_text_font_value, 'RIGHT', 12, 0);
    self.name_text_font_size:SetValues(O.db.name_text_font_size, 2, 28, 1);
    self.name_text_font_size:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_SIZE']);
    self.name_text_font_size:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_SIZE'], self.Tabs[1]);
    self.name_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.name_text_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_font_flag:SetPosition('LEFT', self.name_text_font_size, 'RIGHT', 12, 0);
    self.name_text_font_flag:SetSize(160, 20);
    self.name_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.name_text_font_flag:SetValue(O.db.name_text_font_flag);
    self.name_text_font_flag:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_FLAG']);
    self.name_text_font_flag:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_FLAG'], self.Tabs[1]);
    self.name_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.name_text_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_font_shadow = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_font_shadow:SetPosition('LEFT', self.name_text_font_flag, 'RIGHT', 8, 0);
    self.name_text_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.name_text_font_shadow:SetChecked(O.db.name_text_font_shadow);
    self.name_text_font_shadow:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_SHADOW']);
    self.name_text_font_shadow:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_SHADOW'], self.Tabs[1]);
    self.name_text_font_shadow.Callback = function(self)
        O.db.name_text_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.name_text_position_v = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_position_v:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.name_text_position_v:SetSize(100, 20);
    self.name_text_position_v:SetList(O.Lists.name_position_v);
    self.name_text_position_v:SetValue(O.db.name_text_position_v);
    self.name_text_position_v:SetLabel(L['OPTIONS_NAME_TEXT_POSITION']);
    self.name_text_position_v:SetTooltip(L['OPTIONS_NAME_TEXT_POSITION_V_TOOLTIP']);
    self.name_text_position_v:AddToSearch(button, L['OPTIONS_NAME_TEXT_POSITION_V_TOOLTIP'], self.Tabs[1]);
    self.name_text_position_v.OnValueChangedCallback = function(_, value)
        O.db.name_text_position_v = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_position = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_position:SetPosition('LEFT', self.name_text_position_v, 'RIGHT', 6, 0);
    self.name_text_position:SetSize(100, 20);
    self.name_text_position:SetList(O.Lists.name_position);
    self.name_text_position:SetValue(O.db.name_text_position);
    self.name_text_position:SetTooltip(L['OPTIONS_NAME_TEXT_POSITION_TOOLTIP']);
    self.name_text_position:AddToSearch(button, L['OPTIONS_NAME_TEXT_POSITION_TOOLTIP'], self.Tabs[1]);
    self.name_text_position.OnValueChangedCallback = function(_, value)
        O.db.name_text_position = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_offset_y = E.CreateSlider(self.TabsFrames['NameTab'].Content);
    self.name_text_offset_y:SetPosition('LEFT', self.name_text_position, 'RIGHT', 4, 0);
    self.name_text_offset_y:SetW(120);
    self.name_text_offset_y:SetValues(O.db.name_text_offset_y, -50, 50, 1);
    self.name_text_offset_y:SetTooltip(L['OPTIONS_NAME_TEXT_OFFSET_Y_TOOLTIP']);
    self.name_text_offset_y:AddToSearch(button, L['OPTIONS_NAME_TEXT_OFFSET_Y_TOOLTIP'], self.Tabs[1]);
    self.name_text_offset_y.OnValueChangedCallback = function(_, value)
        O.db.name_text_offset_y = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_truncate = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_truncate:SetPosition('LEFT', self.name_text_offset_y, 'RIGHT', 10, 0);
    self.name_text_truncate:SetLabel(L['OPTIONS_NAME_TEXT_TRUNCATE']);
    self.name_text_truncate:SetTooltip(L['OPTIONS_NAME_TEXT_TRUNCATE_TOOLTIP']);
    self.name_text_truncate:SetChecked(O.db.name_text_truncate);
    self.name_text_truncate:AddToSearch(button, L['OPTIONS_NAME_TEXT_TRUNCATE_TOOLTIP'], self.Tabs[1]);
    self.name_text_truncate.Callback = function(self)
        O.db.name_text_truncate = self:GetChecked();
        Handler:UpdateAll();
    end

    self.coloring_name_text = E.CreateFontString(self.TabsFrames['NameTab'].Content);
    self.coloring_name_text:SetPosition('TOPLEFT', self.name_text_position_v, 'BOTTOMLEFT', 0, -8);
    self.coloring_name_text:SetText(L['OPTIONS_NAME_TEXT_COLORING']);
    self.coloring_name_text:AddToSearch(button, L['OPTIONS_NAME_TEXT_COLORING'], self.Tabs[1]);

    self.name_text_coloring_mode = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_coloring_mode:SetPosition('LEFT', self.coloring_name_text, 'RIGHT', 12, 0);
    self.name_text_coloring_mode:SetSize(160, 20);
    self.name_text_coloring_mode:SetList(O.Lists.name_text_coloring_mode);
    self.name_text_coloring_mode:SetValue(O.db.name_text_coloring_mode);
    self.name_text_coloring_mode:SetTooltip(L['OPTIONS_NAME_TEXT_COLORING_MODE_TOOLTIP']);
    self.name_text_coloring_mode:AddToSearch(button, L['OPTIONS_NAME_TEXT_COLORING_MODE_TOOLTIP'], self.Tabs[1]);
    self.name_text_coloring_mode.OnValueChangedCallback = function(_, value)
        O.db.name_text_coloring_mode = tonumber(value);
        Handler:UpdateAll();
    end

    self.name_text_abbreviated = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_abbreviated:SetPosition('TOPLEFT', self.coloring_name_text, 'BOTTOMLEFT', 0, -12);
    self.name_text_abbreviated:SetLabel(L['OPTIONS_NAME_TEXT_ABBREVIATED']);
    self.name_text_abbreviated:SetChecked(O.db.name_text_abbreviated);
    self.name_text_abbreviated:AddToSearch(button, L['OPTIONS_NAME_TEXT_ABBREVIATED'], self.Tabs[1]);
    self.name_text_abbreviated.Callback = function(self)
        O.db.name_text_abbreviated = self:GetChecked();

        panel.name_text_abbreviated_mode:SetEnabled(O.db.name_text_abbreviated);

        Handler:UpdateAll();
    end

    self.name_text_abbreviated_mode = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_abbreviated_mode:SetPosition('LEFT', self.name_text_abbreviated.Label, 'RIGHT', 12, 0);
    self.name_text_abbreviated_mode:SetSize(160, 20);
    self.name_text_abbreviated_mode:SetList(O.Lists.name_text_abbreviation_mode);
    self.name_text_abbreviated_mode:SetValue(O.db.name_text_abbreviated_mode);
    self.name_text_abbreviated_mode:SetTooltip(L['OPTIONS_NAME_TEXT_ABBREVIATED_MODE_TOOLTIP']);
    self.name_text_abbreviated_mode:AddToSearch(button, L['OPTIONS_NAME_TEXT_ABBREVIATED_MODE_TOOLTIP'], self.Tabs[1]);
    self.name_text_abbreviated_mode:SetEnabled(O.db.name_text_abbreviated);
    self.name_text_abbreviated_mode.OnValueChangedCallback = function(_, value)
        O.db.name_text_abbreviated_mode = tonumber(value);
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_abbreviated, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.faction_icon_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.faction_icon_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.faction_icon_enabled:SetLabel(L['OPTIONS_FACTION_ICON_ENABLED']);
    self.faction_icon_enabled:SetTooltip(L['OPTIONS_FACTION_ICON_ENABLED_TOOLTIP']);
    self.faction_icon_enabled:SetChecked(O.db.faction_icon_enabled);
    self.faction_icon_enabled:AddToSearch(button, L['OPTIONS_FACTION_ICON_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.faction_icon_enabled.Callback = function(self)
        O.db.faction_icon_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.class_icon_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.class_icon_enabled:SetPosition('LEFT', self.faction_icon_enabled.Label, 'RIGHT', 12, 0);
    self.class_icon_enabled:SetLabel(L['OPTIONS_CLASS_ICON_ENABLED']);
    self.class_icon_enabled:SetTooltip(L['OPTIONS_CLASS_ICON_ENABLED_TOOLTIP']);
    self.class_icon_enabled:SetChecked(O.db.class_icon_enabled);
    self.class_icon_enabled:AddToSearch(button, L['OPTIONS_CLASS_ICON_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.class_icon_enabled.Callback = function(self)
        O.db.class_icon_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.target_name_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.target_name_enabled:SetPosition('TOPLEFT', self.faction_icon_enabled, 'BOTTOMLEFT', 0, -8);
    self.target_name_enabled:SetLabel(L['OPTIONS_TARGET_NAME_ENABLED']);
    self.target_name_enabled:SetTooltip(L['OPTIONS_TARGET_NAME_ENABLED_TOOLTIP']);
    self.target_name_enabled:SetChecked(O.db.target_name_enabled);
    self.target_name_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.target_name_enabled.Callback = function(self)
        O.db.target_name_enabled = self:GetChecked();

        panel.target_name_only_enemy:SetEnabled(O.db.target_name_enabled);

        Handler:UpdateAll();
    end

    self.target_name_only_enemy = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.target_name_only_enemy:SetPosition('LEFT', self.target_name_enabled.Label, 'RIGHT', 12, 0);
    self.target_name_only_enemy:SetLabel(L['OPTIONS_TARGET_NAME_ONLY_ENEMY']);
    self.target_name_only_enemy:SetTooltip(L['OPTIONS_TARGET_NAME_ONLY_ENEMY_TOOLTIP']);
    self.target_name_only_enemy:SetChecked(O.db.target_name_only_enemy);
    self.target_name_only_enemy:AddToSearch(button, L['OPTIONS_TARGET_NAME_ONLY_ENEMY_TOOLTIP'], self.Tabs[1]);
    self.target_name_only_enemy:SetEnabled(O.db.target_name_enabled);
    self.target_name_only_enemy.Callback = function(self)
        O.db.target_name_only_enemy = self:GetChecked();
        Handler:UpdateAll();
    end

    self.name_text_show_arenaid = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_show_arenaid:SetPosition('TOPLEFT', self.target_name_enabled, 'BOTTOMLEFT', 0, -8);
    self.name_text_show_arenaid:SetLabel(L['OPTIONS_NAME_TEXT_SHOW_ARENAID']);
    self.name_text_show_arenaid:SetTooltip(L['OPTIONS_NAME_TEXT_SHOW_ARENAID_TOOLTIP']);
    self.name_text_show_arenaid:SetChecked(O.db.name_text_show_arenaid);
    self.name_text_show_arenaid:AddToSearch(button, L['OPTIONS_NAME_TEXT_SHOW_ARENAID_TOOLTIP'], self.Tabs[1]);
    self.name_text_show_arenaid.Callback = function(self)
        O.db.name_text_show_arenaid = self:GetChecked();

        panel.name_text_show_arenaid_solo:SetEnabled(O.db.name_text_show_arenaid);

        Handler:UpdateAll();
    end

    self.name_text_show_arenaid_solo = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_show_arenaid_solo:SetPosition('LEFT', self.name_text_show_arenaid.Label, 'RIGHT', 12, 0);
    self.name_text_show_arenaid_solo:SetLabel(L['OPTIONS_NAME_TEXT_SHOW_ARENAID_SOLO']);
    self.name_text_show_arenaid_solo:SetTooltip(L['OPTIONS_NAME_TEXT_SHOW_ARENAID_SOLO_TOOLTIP']);
    self.name_text_show_arenaid_solo:SetChecked(O.db.name_text_show_arenaid_solo);
    self.name_text_show_arenaid_solo:AddToSearch(button, L['OPTIONS_NAME_TEXT_SHOW_ARENAID_SOLO_TOOLTIP'], self.Tabs[1]);
    self.name_text_show_arenaid_solo:SetEnabled(O.db.name_text_show_arenaid);
    self.name_text_show_arenaid_solo.Callback = function(self)
        O.db.name_text_show_arenaid_solo = self:GetChecked();
        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Health text Tab -----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.health_text_enabled = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_enabled:SetPosition('TOPLEFT', self.TabsFrames['HealthTextTab'].Content, 'TOPLEFT', 0, -4);
    self.health_text_enabled:SetLabel(L['OPTIONS_SHOW']);
    self.health_text_enabled:SetChecked(O.db.health_text_enabled);
    self.health_text_enabled:SetTooltip(L['OPTIONS_SHOW_HEALTH_TEXT']);
    self.health_text_enabled:AddToSearch(button, L['OPTIONS_SHOW_HEALTH_TEXT'], self.Tabs[2]);
    self.health_text_enabled.Callback = function(self)
        O.db.health_text_enabled = self:GetChecked();

        panel.health_text_hide_full:SetEnabled(O.db.health_text_enabled);
        panel.health_text_display_mode:SetEnabled(O.db.health_text_enabled);

        Handler:UpdateAll();
    end

    self.health_text_hide_full = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_hide_full:SetPosition('LEFT', self.health_text_enabled.Label, 'RIGHT', 12, 0);
    self.health_text_hide_full:SetLabel(L['OPTIONS_HEALTH_TEXT_HIDE_FULL']);
    self.health_text_hide_full:SetTooltip(L['OPTIONS_HEALTH_TEXT_HIDE_FULL_TOOLTIP']);
    self.health_text_hide_full:SetChecked(O.db.health_text_hide_full);
    self.health_text_hide_full:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_HIDE_FULL_TOOLTIP'], self.Tabs[2]);
    self.health_text_hide_full:SetEnabled(O.db.health_text_enabled);
    self.health_text_hide_full.Callback = function(self)
        O.db.health_text_hide_full = self:GetChecked();
        Handler:UpdateAll();
    end

    self.health_text_display_mode = E.CreateDropdown('plain', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_display_mode:SetPosition('LEFT', self.health_text_hide_full.Label, 'RIGHT', 12, 0);
    self.health_text_display_mode:SetSize(120, 20);
    self.health_text_display_mode:SetList(O.Lists.health_text_display_mode);
    self.health_text_display_mode:SetValue(O.db.health_text_display_mode);
    self.health_text_display_mode:SetLabel(L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE']);
    self.health_text_display_mode:SetTooltip(L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP']);
    self.health_text_display_mode:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP'], self.Tabs[2]);
    self.health_text_display_mode:SetEnabled(O.db.health_text_enabled);
    self.health_text_display_mode.OnValueChangedCallback = function(_, value)
        O.db.health_text_display_mode = tonumber(value);
        Handler:UpdateAll();
    end

    self.health_text_custom_color_enabled = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_custom_color_enabled:SetPosition('TOPLEFT', self.health_text_enabled, 'BOTTOMLEFT', 0, -8);
    self.health_text_custom_color_enabled:SetLabel(L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED']);
    self.health_text_custom_color_enabled:SetChecked(O.db.health_text_custom_color_enabled);
    self.health_text_custom_color_enabled:SetTooltip(L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP']);
    self.health_text_custom_color_enabled:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.health_text_custom_color_enabled.Callback = function(self)
        O.db.health_text_custom_color_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.health_text_custom_color = E.CreateColorPicker(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_custom_color:SetPosition('LEFT', self.health_text_custom_color_enabled.Label, 'RIGHT', 12, 0);
    self.health_text_custom_color:SetTooltip(L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_TOOLTIP']);
    self.health_text_custom_color:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_TOOLTIP'], self.Tabs[2]);
    self.health_text_custom_color:SetValue(unpack(O.db.health_text_custom_color));
    self.health_text_custom_color.OnValueChanged = function(_, r, g, b, a)
        O.db.health_text_custom_color[1] = r;
        O.db.health_text_custom_color[2] = g;
        O.db.health_text_custom_color[3] = b;
        O.db.health_text_custom_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.health_text_font_value = E.CreateDropdown('font', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_value:SetPosition('TOPLEFT', self.health_text_custom_color_enabled, 'BOTTOMLEFT', 0, -12);
    self.health_text_font_value:SetSize(160, 20);
    self.health_text_font_value:SetList(LSM:HashTable('font'));
    self.health_text_font_value:SetValue(O.db.health_text_font_value);
    self.health_text_font_value:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_VALUE']);
    self.health_text_font_value:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_VALUE'], self.Tabs[2]);
    self.health_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.health_text_font_value = value;
        Handler:UpdateAll();
    end

    self.health_text_font_size = E.CreateSlider(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_size:SetPosition('LEFT', self.health_text_font_value, 'RIGHT', 12, 0);
    self.health_text_font_size:SetValues(O.db.health_text_font_size, 2, 28, 1);
    self.health_text_font_size:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_SIZE']);
    self.health_text_font_size:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_SIZE'], self.Tabs[2]);
    self.health_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.health_text_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.health_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_flag:SetPosition('LEFT', self.health_text_font_size, 'RIGHT', 12, 0);
    self.health_text_font_flag:SetSize(160, 20);
    self.health_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.health_text_font_flag:SetValue(O.db.health_text_font_flag);
    self.health_text_font_flag:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_FLAG']);
    self.health_text_font_flag:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_FLAG'], self.Tabs[2]);
    self.health_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.health_text_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.health_text_font_shadow = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_shadow:SetPosition('LEFT', self.health_text_font_flag, 'RIGHT', 8, 0);
    self.health_text_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.health_text_font_shadow:SetChecked(O.db.health_text_font_shadow);
    self.health_text_font_shadow:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_SHADOW']);
    self.health_text_font_shadow:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_SHADOW'], self.Tabs[2]);
    self.health_text_font_shadow.Callback = function(self)
        O.db.health_text_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['HealthTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.health_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.health_text_anchor = E.CreateDropdown('plain', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_anchor:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.health_text_anchor:SetSize(120, 20);
    self.health_text_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.health_text_anchor:SetValue(O.db.health_text_anchor);
    self.health_text_anchor:SetLabel(L['OPTIONS_HEALTH_TEXT_ANCHOR']);
    self.health_text_anchor:SetTooltip(L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP']);
    self.health_text_anchor:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP'], self.Tabs[2]);
    self.health_text_anchor.OnValueChangedCallback = function(_, value)
        O.db.health_text_anchor = tonumber(value);
        Handler:UpdateAll();
    end

    self.health_text_x_offset = E.CreateSlider(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_x_offset:SetPosition('LEFT', self.health_text_anchor, 'RIGHT', 16, 0);
    self.health_text_x_offset:SetW(137);
    self.health_text_x_offset:SetLabel(L['OPTIONS_HEALTH_TEXT_X_OFFSET']);
    self.health_text_x_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP']);
    self.health_text_x_offset:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP'], self.Tabs[2]);
    self.health_text_x_offset:SetValues(O.db.health_text_x_offset, -99, 100, 1);
    self.health_text_x_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_x_offset = tonumber(value);
        Handler:UpdateAll();
    end

    self.health_text_y_offset = E.CreateSlider(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_y_offset:SetPosition('LEFT', self.health_text_x_offset, 'RIGHT', 16, 0);
    self.health_text_y_offset:SetW(137);
    self.health_text_y_offset:SetLabel(L['OPTIONS_HEALTH_TEXT_Y_OFFSET']);
    self.health_text_y_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP']);
    self.health_text_y_offset:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP'], self.Tabs[2]);
    self.health_text_y_offset:SetValues(O.db.health_text_y_offset, -99, 100, 1);
    self.health_text_y_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_y_offset = tonumber(value);
        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Level text Tab ------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.level_text_enabled = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_enabled:SetPosition('TOPLEFT', self.TabsFrames['LevelTextTab'].Content, 'TOPLEFT', 0, -4);
    self.level_text_enabled:SetLabel(L['OPTIONS_SHOW']);
    self.level_text_enabled:SetChecked(O.db.level_text_enabled);
    self.level_text_enabled:SetTooltip(L['OPTIONS_SHOW_LEVEL_TEXT']);
    self.level_text_enabled:AddToSearch(button, L['OPTIONS_SHOW_LEVEL_TEXT'], self.Tabs[3]);
    self.level_text_enabled.Callback = function(self)
        O.db.level_text_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.level_text_use_diff_color = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_use_diff_color:SetPosition('TOPLEFT', self.level_text_enabled, 'BOTTOMLEFT', 0, -8);
    self.level_text_use_diff_color:SetLabel(L['OPTIONS_LEVEL_TEXT_USE_DIFF_COLOR']);
    self.level_text_use_diff_color:SetChecked(O.db.level_text_use_diff_color);
    self.level_text_use_diff_color:SetTooltip(L['OPTIONS_LEVEL_TEXT_USE_DIFF_COLOR_TOOLTIP']);
    self.level_text_use_diff_color:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_USE_DIFF_COLOR_TOOLTIP'], self.Tabs[3]);
    self.level_text_use_diff_color.Callback = function(self)
        O.db.level_text_use_diff_color = self:GetChecked();

        panel.level_text_custom_color_enabled:SetEnabled(not O.db.level_text_use_diff_color);

        Handler:UpdateAll();
    end

    self.level_text_custom_color_enabled = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_custom_color_enabled:SetPosition('LEFT', self.level_text_use_diff_color.Label, 'RIGHT', 12, 0);
    self.level_text_custom_color_enabled:SetLabel(L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_ENABLED']);
    self.level_text_custom_color_enabled:SetChecked(O.db.level_text_custom_color_enabled);
    self.level_text_custom_color_enabled:SetTooltip(L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP']);
    self.level_text_custom_color_enabled:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.level_text_custom_color_enabled:SetEnabled(not O.db.level_text_use_diff_color);
    self.level_text_custom_color_enabled.Callback = function(self)
        O.db.level_text_custom_color_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.level_text_custom_color = E.CreateColorPicker(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_custom_color:SetPosition('LEFT', self.level_text_custom_color_enabled.Label, 'RIGHT', 12, 0);
    self.level_text_custom_color:SetTooltip(L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_TOOLTIP']);
    self.level_text_custom_color:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_TOOLTIP'], self.Tabs[3]);
    self.level_text_custom_color:SetValue(unpack(O.db.level_text_custom_color));
    self.level_text_custom_color.OnValueChanged = function(_, r, g, b, a)
        O.db.level_text_custom_color[1] = r;
        O.db.level_text_custom_color[2] = g;
        O.db.level_text_custom_color[3] = b;
        O.db.level_text_custom_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.level_text_font_value = E.CreateDropdown('font', self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_value:SetPosition('TOPLEFT', self.level_text_use_diff_color, 'BOTTOMLEFT', 0, -12);
    self.level_text_font_value:SetSize(160, 20);
    self.level_text_font_value:SetList(LSM:HashTable('font'));
    self.level_text_font_value:SetValue(O.db.level_text_font_value);
    self.level_text_font_value:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_VALUE']);
    self.level_text_font_value:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_VALUE'], self.Tabs[3]);
    self.level_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.level_text_font_value = value;
        Handler:UpdateAll();
    end

    self.level_text_font_size = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_size:SetPosition('LEFT', self.level_text_font_value, 'RIGHT', 12, 0);
    self.level_text_font_size:SetValues(O.db.level_text_font_size, 2, 28, 1);
    self.level_text_font_size:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_SIZE']);
    self.level_text_font_size:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_SIZE'], self.Tabs[3]);
    self.level_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.level_text_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.level_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_flag:SetPosition('LEFT', self.level_text_font_size, 'RIGHT', 12, 0);
    self.level_text_font_flag:SetSize(160, 20);
    self.level_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.level_text_font_flag:SetValue(O.db.level_text_font_flag);
    self.level_text_font_flag:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_FLAG']);
    self.level_text_font_flag:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_FLAG'], self.Tabs[3]);
    self.level_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.level_text_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.level_text_font_shadow = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_shadow:SetPosition('LEFT', self.level_text_font_flag, 'RIGHT', 8, 0);
    self.level_text_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.level_text_font_shadow:SetChecked(O.db.level_text_font_shadow);
    self.level_text_font_shadow:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_SHADOW']);
    self.level_text_font_shadow:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_SHADOW'], self.Tabs[3]);
    self.level_text_font_shadow.Callback = function(self)
        O.db.level_text_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['LevelTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.level_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.level_text_anchor = E.CreateDropdown('plain', self.TabsFrames['LevelTextTab'].Content);
    self.level_text_anchor:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.level_text_anchor:SetSize(120, 20);
    self.level_text_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.level_text_anchor:SetValue(O.db.level_text_anchor);
    self.level_text_anchor:SetLabel(L['OPTIONS_LEVEL_TEXT_ANCHOR']);
    self.level_text_anchor:SetTooltip(L['OPTIONS_LEVEL_TEXT_ANCHOR_TOOLTIP']);
    self.level_text_anchor:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_ANCHOR_TOOLTIP'], self.Tabs[3]);
    self.level_text_anchor.OnValueChangedCallback = function(_, value)
        O.db.level_text_anchor = tonumber(value);
        Handler:UpdateAll();
    end

    self.level_text_x_offset = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_x_offset:SetPosition('LEFT', self.level_text_anchor, 'RIGHT', 16, 0);
    self.level_text_x_offset:SetW(137);
    self.level_text_x_offset:SetLabel(L['OPTIONS_LEVEL_TEXT_X_OFFSET']);
    self.level_text_x_offset:SetTooltip(L['OPTIONS_LEVEL_TEXT_X_OFFSET_TOOLTIP']);
    self.level_text_x_offset:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_X_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.level_text_x_offset:SetValues(O.db.level_text_x_offset, -99, 100, 1);
    self.level_text_x_offset.OnValueChangedCallback = function(_, value)
        O.db.level_text_x_offset = tonumber(value);
        Handler:UpdateAll();
    end

    self.level_text_y_offset = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_y_offset:SetPosition('LEFT', self.level_text_x_offset, 'RIGHT', 16, 0);
    self.level_text_y_offset:SetW(137);
    self.level_text_y_offset:SetLabel(L['OPTIONS_LEVEL_TEXT_Y_OFFSET']);
    self.level_text_y_offset:SetTooltip(L['OPTIONS_LEVEL_TEXT_Y_OFFSET_TOOLTIP']);
    self.level_text_y_offset:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_Y_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.level_text_y_offset:SetValues(O.db.level_text_y_offset, -99, 100, 1);
    self.level_text_y_offset.OnValueChangedCallback = function(_, value)
        O.db.level_text_y_offset = tonumber(value);
        Handler:UpdateAll();
    end
end