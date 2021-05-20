local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Auras');

local LSM = S.Libraries.LSM;

O.frame.Left.Auras, O.frame.Right.Auras = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_AURAS']), 'auras', 6);
local button = O.frame.Left.Auras;
local panel = O.frame.Right.Auras;

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
};

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

    self.auras_pandemic_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_pandemic_enabled:SetPosition('TOPLEFT', self.auras_filter_player_enabled, 'BOTTOMLEFT', 0, -8);
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
        O.db.auras_pandemic_color[4] = a;

        Handler:UpdateAll();
    end

    self.auras_border_color_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_border_color_enabled:SetPosition('TOPLEFT', self.auras_pandemic_enabled, 'BOTTOMLEFT', 0, -8);
    self.auras_border_color_enabled:SetLabel(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED']);
    self.auras_border_color_enabled:SetTooltip(L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP']);
    self.auras_border_color_enabled:AddToSearch(button, L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.auras_border_color_enabled:SetChecked(O.db.auras_border_color_enabled);
    self.auras_border_color_enabled.Callback = function(self)
        O.db.auras_border_color_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_show_debuffs_on_friendly = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.auras_show_debuffs_on_friendly:SetPosition('TOPLEFT', self.auras_border_color_enabled, 'BOTTOMLEFT', 0, -8);
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

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_sort_enabled, 'BOTTOMLEFT', 0, -4);
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
    self.auras_cooldown_font_shadow:SetPosition('LEFT', self.auras_cooldown_font_flag, 'RIGHT', 8, 0);
    self.auras_cooldown_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_cooldown_font_shadow:SetChecked(O.db.auras_cooldown_font_shadow);
    self.auras_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW']);
    self.auras_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW'], self.Tabs[1]);
    self.auras_cooldown_font_shadow.Callback = function(self)
        O.db.auras_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_count_text = E.CreateFontString(self.TabsFrames['CommonTab'].Content);
    self.auras_count_text:SetPosition('TOPLEFT', self.auras_cooldown_font_value, 'BOTTOMLEFT', 0, -8);
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
    self.auras_count_font_shadow:SetPosition('LEFT', self.auras_count_font_flag, 'RIGHT', 8, 0);
    self.auras_count_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_count_font_shadow:SetChecked(O.db.auras_count_font_shadow);
    self.auras_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_COUNT_FONT_SHADOW']);
    self.auras_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_COUNT_FONT_SHADOW'], self.Tabs[1]);
    self.auras_count_font_shadow.Callback = function(self)
        O.db.auras_count_font_shadow = self:GetChecked();
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
    self.auras_spellsteal_countdown_text:SetPosition('TOPLEFT', self.auras_spellsteal_countdown_enabled, 'BOTTOMLEFT', 0, -8);
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
    self.auras_spellsteal_cooldown_font_shadow:SetPosition('LEFT', self.auras_spellsteal_cooldown_font_flag, 'RIGHT', 8, 0);
    self.auras_spellsteal_cooldown_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_spellsteal_cooldown_font_shadow:SetChecked(O.db.auras_spellsteal_cooldown_font_shadow);
    self.auras_spellsteal_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW']);
    self.auras_spellsteal_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_cooldown_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_spellsteal_count_text = E.CreateFontString(self.TabsFrames['SpellstealTab'].Content);
    self.auras_spellsteal_count_text:SetPosition('TOPLEFT', self.auras_spellsteal_cooldown_font_value, 'BOTTOMLEFT', 0, -8);
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
    self.auras_spellsteal_count_font_shadow:SetPosition('LEFT', self.auras_spellsteal_count_font_flag, 'RIGHT', 8, 0);
    self.auras_spellsteal_count_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_spellsteal_count_font_shadow:SetChecked(O.db.auras_spellsteal_count_font_shadow);
    self.auras_spellsteal_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW']);
    self.auras_spellsteal_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW'], self.Tabs[2]);
    self.auras_spellsteal_count_font_shadow.Callback = function(self)
        O.db.auras_spellsteal_count_font_shadow = self:GetChecked();
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
    self.auras_mythicplus_countdown_text:SetPosition('TOPLEFT', self.auras_mythicplus_countdown_enabled, 'BOTTOMLEFT', 0, -8);
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
    self.auras_mythicplus_cooldown_font_shadow:SetPosition('LEFT', self.auras_mythicplus_cooldown_font_flag, 'RIGHT', 8, 0);
    self.auras_mythicplus_cooldown_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_mythicplus_cooldown_font_shadow:SetChecked(O.db.auras_mythicplus_cooldown_font_shadow);
    self.auras_mythicplus_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW']);
    self.auras_mythicplus_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_cooldown_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_mythicplus_count_text = E.CreateFontString(self.TabsFrames['MythicPlusTab'].Content);
    self.auras_mythicplus_count_text:SetPosition('TOPLEFT', self.auras_mythicplus_cooldown_font_value, 'BOTTOMLEFT', 0, -8);
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
    self.auras_mythicplus_count_font_shadow:SetPosition('LEFT', self.auras_mythicplus_count_font_flag, 'RIGHT', 8, 0);
    self.auras_mythicplus_count_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_mythicplus_count_font_shadow:SetChecked(O.db.auras_mythicplus_count_font_shadow);
    self.auras_mythicplus_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW']);
    self.auras_mythicplus_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW'], self.Tabs[3]);
    self.auras_mythicplus_count_font_shadow.Callback = function(self)
        O.db.auras_mythicplus_count_font_shadow = self:GetChecked();
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
    self.auras_important_scale:SetPosition('TOPLEFT', self.auras_important_countdown_enabled, 'BOTTOMLEFT', 0, -24);
    self.auras_important_scale:SetValues(O.db.auras_important_scale, 0.25, 4, 0.05);
    self.auras_important_scale:SetLabel(L['OPTIONS_AURAS_IMPORTANT_SCALE']);
    self.auras_important_scale:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP']);
    self.auras_important_scale:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP'], self.Tabs[4]);
    self.auras_important_scale.OnValueChangedCallback = function(_, value)
        O.db.auras_important_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.auras_important_countdown_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_countdown_text:SetPosition('TOPLEFT', self.auras_important_scale, 'BOTTOMLEFT', 0, -8);
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
    self.auras_important_cooldown_font_shadow:SetPosition('LEFT', self.auras_important_cooldown_font_flag, 'RIGHT', 8, 0);
    self.auras_important_cooldown_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_important_cooldown_font_shadow:SetChecked(O.db.auras_important_cooldown_font_shadow);
    self.auras_important_cooldown_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW']);
    self.auras_important_cooldown_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_cooldown_font_shadow.Callback = function(self)
        O.db.auras_important_cooldown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.auras_important_count_text = E.CreateFontString(self.TabsFrames['ImportantTab'].Content);
    self.auras_important_count_text:SetPosition('TOPLEFT', self.auras_important_cooldown_font_value, 'BOTTOMLEFT', 0, -8);
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
    self.auras_important_count_font_shadow:SetPosition('LEFT', self.auras_important_count_font_flag, 'RIGHT', 8, 0);
    self.auras_important_count_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_important_count_font_shadow:SetChecked(O.db.auras_important_count_font_shadow);
    self.auras_important_count_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW']);
    self.auras_important_count_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_count_font_shadow.Callback = function(self)
        O.db.auras_important_count_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['ImportantTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.auras_important_count_font_value, 'BOTTOMLEFT', 0, -4);
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
    self.auras_important_castername_font_shadow:SetPosition('LEFT', self.auras_important_castername_font_flag, 'RIGHT', 8, 0);
    self.auras_important_castername_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.auras_important_castername_font_shadow:SetChecked(O.db.auras_important_castername_font_shadow);
    self.auras_important_castername_font_shadow:SetTooltip(L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW']);
    self.auras_important_castername_font_shadow:AddToSearch(button, L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW'], self.Tabs[4]);
    self.auras_important_castername_font_shadow.Callback = function(self)
        O.db.auras_important_castername_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end
end