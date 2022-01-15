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
    local Stripes = S:GetNameplateModule('Handler');

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
        Stripes:UpdateAll();
    end

    self.name_without_realm = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_without_realm:SetPosition('LEFT', self.name_text_enabled.Label, 'RIGHT', 12, 0);
    self.name_without_realm:SetLabel(L['OPTIONS_NAME_WITHOUT_REALM']);
    self.name_without_realm:SetChecked(O.db.name_without_realm);
    self.name_without_realm:SetTooltip(L['OPTIONS_NAME_WITHOUT_REALM_TOOLTIP']);
    self.name_without_realm:AddToSearch(button, L['OPTIONS_NAME_WITHOUT_REALM_TOOLTIP'], self.Tabs[1]);
    self.name_without_realm.Callback = function(self)
        O.db.name_without_realm = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_text_with_title = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_with_title:SetPosition('LEFT', self.name_without_realm.Label, 'RIGHT', 12, 0);
    self.name_text_with_title:SetLabel(L['OPTIONS_NAME_TEXT_WITH_TITLE']);
    self.name_text_with_title:SetTooltip(L['OPTIONS_NAME_TEXT_WITH_TITLE_TOOLTIP']);
    self.name_text_with_title:AddToSearch(button, L['OPTIONS_NAME_TEXT_WITH_TITLE_TOOLTIP'], self.Tabs[1]);
    self.name_text_with_title:SetChecked(O.db.name_text_with_title);
    self.name_text_with_title.Callback = function(self)
        O.db.name_text_with_title = self:GetChecked();

        panel.name_text_with_title_mode:SetEnabled(O.db.name_text_with_title);

        Stripes:UpdateAll();
    end

    self.name_text_with_title_mode = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_with_title_mode:SetPosition('LEFT', self.name_text_with_title.Label, 'RIGHT', 12, 0);
    self.name_text_with_title_mode:SetSize(170, 20);
    self.name_text_with_title_mode:SetList(O.Lists.name_text_with_title_mode);
    self.name_text_with_title_mode:SetValue(O.db.name_text_with_title_mode);
    self.name_text_with_title_mode:SetTooltip(L['OPTIONS_NAME_TEXT_WITH_TITLE_MODE_TOOLTIP']);
    self.name_text_with_title_mode:AddToSearch(button, L['OPTIONS_NAME_TEXT_WITH_TITLE_MODE_TOOLTIP'], self.Tabs[1]);
    self.name_text_with_title_mode:SetEnabled(O.db.name_text_with_title);
    self.name_text_with_title_mode.OnValueChangedCallback = function(_, value)
        O.db.name_text_with_title_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_translit = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_translit:SetPosition('TOPLEFT', self.name_text_enabled, 'BOTTOMLEFT', 0, -8);
    self.name_text_translit:SetLabel(L['OPTIONS_NAME_TEXT_TRANSLIT']);
    self.name_text_translit:SetChecked(O.db.name_text_translit);
    self.name_text_translit:SetTooltip(L['OPTIONS_NAME_TEXT_TRANSLIT_TOOLTIP']);
    self.name_text_translit:AddToSearch(button, L['OPTIONS_NAME_TEXT_TRANSLIT_TOOLTIP'], self.Tabs[1]);
    self.name_text_translit.Callback = function(self)
        O.db.name_text_translit = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_text_replace_diacritics = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_replace_diacritics:SetPosition('LEFT', self.name_text_translit.Label, 'RIGHT', 12, 0);
    self.name_text_replace_diacritics:SetLabel(L['OPTIONS_NAME_TEXT_REPLACE_DIACRITICS']);
    self.name_text_replace_diacritics:SetChecked(O.db.name_text_replace_diacritics);
    self.name_text_replace_diacritics:SetTooltip(L['OPTIONS_NAME_TEXT_REPLACE_DIACRITICS_TOOLTIP']);
    self.name_text_replace_diacritics:AddToSearch(button, L['OPTIONS_NAME_TEXT_REPLACE_DIACRITICS_TOOLTIP'], self.Tabs[1]);
    self.name_text_replace_diacritics.Callback = function(self)
        O.db.name_text_replace_diacritics = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_text_abbreviated = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_abbreviated:SetPosition('TOPLEFT', self.name_text_translit, 'BOTTOMLEFT', 0, -8);
    self.name_text_abbreviated:SetLabel(L['OPTIONS_NAME_TEXT_ABBREVIATED']);
    self.name_text_abbreviated:SetChecked(O.db.name_text_abbreviated);
    self.name_text_abbreviated:AddToSearch(button, L['OPTIONS_NAME_TEXT_ABBREVIATED'], self.Tabs[1]);
    self.name_text_abbreviated.Callback = function(self)
        O.db.name_text_abbreviated = self:GetChecked();

        panel.name_text_abbreviated_mode:SetEnabled(O.db.name_text_abbreviated);

        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_abbreviated, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.name_text_font_value = E.CreateDropdown('font', self.TabsFrames['NameTab'].Content);
    self.name_text_font_value:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.name_text_font_value:SetSize(160, 20);
    self.name_text_font_value:SetList(LSM:HashTable('font'));
    self.name_text_font_value:SetValue(O.db.name_text_font_value);
    self.name_text_font_value:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_VALUE']);
    self.name_text_font_value:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_VALUE'], self.Tabs[1]);
    self.name_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.name_text_font_value = value;
        Stripes:UpdateAll();
    end

    self.name_text_font_size = E.CreateSlider(self.TabsFrames['NameTab'].Content);
    self.name_text_font_size:SetPosition('LEFT', self.name_text_font_value, 'RIGHT', 12, 0);
    self.name_text_font_size:SetValues(O.db.name_text_font_size, 3, 28, 1);
    self.name_text_font_size:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_SIZE']);
    self.name_text_font_size:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_SIZE'], self.Tabs[1]);
    self.name_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.name_text_font_size = tonumber(value);
        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    self.name_text_font_shadow = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_font_shadow:SetPosition('LEFT', self.name_text_font_flag, 'RIGHT', 12, 0);
    self.name_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.name_text_font_shadow:SetChecked(O.db.name_text_font_shadow);
    self.name_text_font_shadow:SetTooltip(L['OPTIONS_NAME_TEXT_FONT_SHADOW']);
    self.name_text_font_shadow:AddToSearch(button, L['OPTIONS_NAME_TEXT_FONT_SHADOW'], self.Tabs[1]);
    self.name_text_font_shadow.Callback = function(self)
        O.db.name_text_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.name_text_position_v = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_position_v:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.name_text_position_v:SetSize(100, 20);
    self.name_text_position_v:SetList(O.Lists.name_position_v);
    self.name_text_position_v:SetValue(O.db.name_text_position_v);
    self.name_text_position_v:SetLabel(L['POSITION']);
    self.name_text_position_v:SetTooltip(L['OPTIONS_NAME_TEXT_POSITION_V_TOOLTIP']);
    self.name_text_position_v:AddToSearch(button, L['OPTIONS_NAME_TEXT_POSITION_V_TOOLTIP'], self.Tabs[1]);
    self.name_text_position_v.OnValueChangedCallback = function(_, value)
        O.db.name_text_position_v = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_position = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_position:SetPosition('LEFT', self.name_text_position_v, 'RIGHT', 12, 0);
    self.name_text_position:SetSize(100, 20);
    self.name_text_position:SetList(O.Lists.name_position);
    self.name_text_position:SetValue(O.db.name_text_position);
    self.name_text_position:SetTooltip(L['OPTIONS_NAME_TEXT_POSITION_TOOLTIP']);
    self.name_text_position:AddToSearch(button, L['OPTIONS_NAME_TEXT_POSITION_TOOLTIP'], self.Tabs[1]);
    self.name_text_position.OnValueChangedCallback = function(_, value)
        O.db.name_text_position = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_offset_x = E.CreateSlider(self.TabsFrames['NameTab'].Content);
    self.name_text_offset_x:SetPosition('LEFT', self.name_text_position, 'RIGHT', 12, 0);
    self.name_text_offset_x:SetW(80);
    self.name_text_offset_x:SetValues(O.db.name_text_offset_x, -100, 100, 1);
    self.name_text_offset_x:SetTooltip(L['OPTIONS_NAME_TEXT_OFFSET_X_TOOLTIP']);
    self.name_text_offset_x:AddToSearch(button, L['OPTIONS_NAME_TEXT_OFFSET_X_TOOLTIP'], self.Tabs[1]);
    self.name_text_offset_x.OnValueChangedCallback = function(_, value)
        O.db.name_text_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_offset_y = E.CreateSlider(self.TabsFrames['NameTab'].Content);
    self.name_text_offset_y:SetPosition('LEFT', self.name_text_offset_x, 'RIGHT', 12, 0);
    self.name_text_offset_y:SetW(80);
    self.name_text_offset_y:SetValues(O.db.name_text_offset_y, -100, 100, 1);
    self.name_text_offset_y:SetTooltip(L['OPTIONS_NAME_TEXT_OFFSET_Y_TOOLTIP']);
    self.name_text_offset_y:AddToSearch(button, L['OPTIONS_NAME_TEXT_OFFSET_Y_TOOLTIP'], self.Tabs[1]);
    self.name_text_offset_y.OnValueChangedCallback = function(_, value)
        O.db.name_text_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_truncate = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.name_text_truncate:SetPosition('LEFT', self.name_text_offset_y, 'RIGHT', 12, 0);
    self.name_text_truncate:SetLabel(L['OPTIONS_NAME_TEXT_TRUNCATE']);
    self.name_text_truncate:SetTooltip(L['OPTIONS_NAME_TEXT_TRUNCATE_TOOLTIP']);
    self.name_text_truncate:SetChecked(O.db.name_text_truncate);
    self.name_text_truncate:AddToSearch(button, L['OPTIONS_NAME_TEXT_TRUNCATE_TOOLTIP'], self.Tabs[1]);
    self.name_text_truncate.Callback = function(self)
        O.db.name_text_truncate = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_position_v, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.name_text_coloring_mode = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_coloring_mode:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.name_text_coloring_mode:SetSize(160, 20);
    self.name_text_coloring_mode:SetList(O.Lists.name_text_coloring_mode);
    self.name_text_coloring_mode:SetValue(O.db.name_text_coloring_mode);
    self.name_text_coloring_mode:SetLabel(L['OPTIONS_NAME_TEXT_COLORING']);
    self.name_text_coloring_mode:SetTooltip(L['OPTIONS_NAME_TEXT_COLORING_MODE_TOOLTIP']);
    self.name_text_coloring_mode:AddToSearch(button, L['OPTIONS_NAME_TEXT_COLORING_MODE_TOOLTIP'], self.Tabs[1]);
    self.name_text_coloring_mode.OnValueChangedCallback = function(_, value)
        O.db.name_text_coloring_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.name_text_coloring_mode_npc = E.CreateDropdown('plain', self.TabsFrames['NameTab'].Content);
    self.name_text_coloring_mode_npc:SetPosition('LEFT', self.name_text_coloring_mode, 'RIGHT', 12, 0);
    self.name_text_coloring_mode_npc:SetSize(160, 20);
    self.name_text_coloring_mode_npc:SetList(O.Lists.name_text_coloring_mode_npc);
    self.name_text_coloring_mode_npc:SetValue(O.db.name_text_coloring_mode_npc);
    self.name_text_coloring_mode_npc:SetLabel(L['OPTIONS_NAME_TEXT_COLORING_NPC']);
    self.name_text_coloring_mode_npc:SetTooltip(L['OPTIONS_NAME_TEXT_COLORING_NPC_TOOLTIP']);
    self.name_text_coloring_mode_npc:AddToSearch(button, L['OPTIONS_NAME_TEXT_COLORING_NPC_TOOLTIP'], self.Tabs[1]);
    self.name_text_coloring_mode_npc.OnValueChangedCallback = function(_, value)
        O.db.name_text_coloring_mode_npc = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['NameTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.name_text_coloring_mode, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.faction_icon_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.faction_icon_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.faction_icon_enabled:SetLabel(L['OPTIONS_FACTION_ICON_ENABLED']);
    self.faction_icon_enabled:SetTooltip(L['OPTIONS_FACTION_ICON_ENABLED_TOOLTIP']);
    self.faction_icon_enabled:SetChecked(O.db.faction_icon_enabled);
    self.faction_icon_enabled:AddToSearch(button, L['OPTIONS_FACTION_ICON_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.faction_icon_enabled.Callback = function(self)
        O.db.faction_icon_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.class_icon_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.class_icon_enabled:SetPosition('TOPLEFT', self.faction_icon_enabled, 'BOTTOMLEFT', 0, -8);
    self.class_icon_enabled:SetLabel(L['OPTIONS_CLASS_ICON_ENABLED']);
    self.class_icon_enabled:SetTooltip(L['OPTIONS_CLASS_ICON_ENABLED_TOOLTIP']);
    self.class_icon_enabled:SetChecked(O.db.class_icon_enabled);
    self.class_icon_enabled:AddToSearch(button, L['OPTIONS_CLASS_ICON_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.class_icon_enabled.Callback = function(self)
        O.db.class_icon_enabled = self:GetChecked();

        panel.class_icon_arena_only:SetEnabled(O.db.class_icon_enabled);
        panel.class_icon_enemy_only:SetEnabled(O.db.class_icon_enabled);

        Stripes:UpdateAll();
    end

    self.class_icon_enemy_only = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.class_icon_enemy_only:SetPosition('LEFT', self.class_icon_enabled.Label, 'RIGHT', 12, 0);
    self.class_icon_enemy_only:SetLabel(L['OPTIONS_CLASS_ICON_ENEMY_ONLY']);
    self.class_icon_enemy_only:SetTooltip(L['OPTIONS_CLASS_ICON_ENEMY_ONLY_TOOLTIP']);
    self.class_icon_enemy_only:SetChecked(O.db.class_icon_enemy_only);
    self.class_icon_enemy_only:AddToSearch(button, L['OPTIONS_CLASS_ICON_ENEMY_ONLY_TOOLTIP'], self.Tabs[1]);
    self.class_icon_enemy_only:SetEnabled(O.db.class_icon_enabled);
    self.class_icon_enemy_only.Callback = function(self)
        O.db.class_icon_enemy_only = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.class_icon_arena_only = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.class_icon_arena_only:SetPosition('LEFT', self.class_icon_enemy_only.Label, 'RIGHT', 12, 0);
    self.class_icon_arena_only:SetLabel(L['OPTIONS_CLASS_ICON_ARENA_ONLY']);
    self.class_icon_arena_only:SetTooltip(L['OPTIONS_CLASS_ICON_ARENA_ONLY_TOOLTIP']);
    self.class_icon_arena_only:SetChecked(O.db.class_icon_arena_only);
    self.class_icon_arena_only:AddToSearch(button, L['OPTIONS_CLASS_ICON_ARENA_ONLY_TOOLTIP'], self.Tabs[1]);
    self.class_icon_arena_only:SetEnabled(O.db.class_icon_enabled);
    self.class_icon_arena_only.Callback = function(self)
        O.db.class_icon_arena_only = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_name_enabled = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.target_name_enabled:SetPosition('TOPLEFT', self.class_icon_enabled, 'BOTTOMLEFT', 0, -8);
    self.target_name_enabled:SetLabel(L['OPTIONS_TARGET_NAME_ENABLED']);
    self.target_name_enabled:SetTooltip(L['OPTIONS_TARGET_NAME_ENABLED_TOOLTIP']);
    self.target_name_enabled:SetChecked(O.db.target_name_enabled);
    self.target_name_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.target_name_enabled.Callback = function(self)
        O.db.target_name_enabled = self:GetChecked();

        panel.target_name_only_enemy:SetEnabled(O.db.target_name_enabled);
        panel.target_name_not_me:SetEnabled(O.db.target_name_enabled);
        panel.target_name_role_icon:SetEnabled(O.db.target_name_enabled);

        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    self.target_name_not_me = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.target_name_not_me:SetPosition('LEFT', self.target_name_only_enemy.Label, 'RIGHT', 12, 0);
    self.target_name_not_me:SetLabel(L['OPTIONS_TARGET_NAME_NOT_ME']);
    self.target_name_not_me:SetTooltip(L['OPTIONS_TARGET_NAME_NOT_ME_TOOLTIP']);
    self.target_name_not_me:SetChecked(O.db.target_name_not_me);
    self.target_name_not_me:AddToSearch(button, L['OPTIONS_TARGET_NAME_NOT_ME_TOOLTIP'], self.Tabs[1]);
    self.target_name_not_me:SetEnabled(O.db.target_name_enabled);
    self.target_name_not_me.Callback = function(self)
        O.db.target_name_not_me = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.target_name_role_icon = E.CreateCheckButton(self.TabsFrames['NameTab'].Content);
    self.target_name_role_icon:SetPosition('LEFT', self.target_name_not_me.Label, 'RIGHT', 12, 0);
    self.target_name_role_icon:SetLabel(L['OPTIONS_TARGET_NAME_ROLE_ICON']);
    self.target_name_role_icon:SetTooltip(L['OPTIONS_TARGET_NAME_ROLE_ICON_TOOLTIP']);
    self.target_name_role_icon:SetChecked(O.db.target_name_role_icon);
    self.target_name_role_icon:AddToSearch(button, L['OPTIONS_TARGET_NAME_ROLE_ICON_TOOLTIP'], self.Tabs[1]);
    self.target_name_role_icon:SetEnabled(O.db.target_name_enabled);
    self.target_name_role_icon.Callback = function(self)
        O.db.target_name_role_icon = self:GetChecked();
        Stripes:UpdateAll();
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

        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    self.health_text_show_only_on_target = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_show_only_on_target:SetPosition('LEFT', self.health_text_enabled.Label, 'RIGHT', 12, 0);
    self.health_text_show_only_on_target:SetLabel(L['OPTIONS_HEALTH_TEXT_SHOW_ONLY_ON_TARGET']);
    self.health_text_show_only_on_target:SetTooltip(L['OPTIONS_HEALTH_TEXT_SHOW_ONLY_ON_TARGET_TOOLTIP']);
    self.health_text_show_only_on_target:SetChecked(O.db.health_text_show_only_on_target);
    self.health_text_show_only_on_target:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_SHOW_ONLY_ON_TARGET_TOOLTIP'], self.Tabs[2]);
    self.health_text_show_only_on_target.Callback = function(self)
        O.db.health_text_show_only_on_target = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_text_hide_full = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_hide_full:SetPosition('LEFT', self.health_text_show_only_on_target.Label, 'RIGHT', 12, 0);
    self.health_text_hide_full:SetLabel(L['OPTIONS_HEALTH_TEXT_HIDE_FULL']);
    self.health_text_hide_full:SetTooltip(L['OPTIONS_HEALTH_TEXT_HIDE_FULL_TOOLTIP']);
    self.health_text_hide_full:SetChecked(O.db.health_text_hide_full);
    self.health_text_hide_full:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_HIDE_FULL_TOOLTIP'], self.Tabs[2]);
    self.health_text_hide_full.Callback = function(self)
        O.db.health_text_hide_full = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_text_show_pct_sign = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_show_pct_sign:SetPosition('TOPLEFT', self.health_text_enabled, 'BOTTOMLEFT', 0, -8);
    self.health_text_show_pct_sign:SetLabel(L['OPTIONS_HEALTH_TEXT_SHOW_PCT_SIGN']);
    self.health_text_show_pct_sign:SetTooltip(L['OPTIONS_HEALTH_TEXT_SHOW_PCT_SIGN_TOOLTIP']);
    self.health_text_show_pct_sign:SetChecked(O.db.health_text_show_pct_sign);
    self.health_text_show_pct_sign:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_SHOW_PCT_SIGN_TOOLTIP'], self.Tabs[2]);
    self.health_text_show_pct_sign.Callback = function(self)
        O.db.health_text_show_pct_sign = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.health_text_custom_color_enabled = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_custom_color_enabled:SetPosition('TOPLEFT', self.health_text_show_pct_sign, 'BOTTOMLEFT', 0, -8);
    self.health_text_custom_color_enabled:SetLabel(L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED']);
    self.health_text_custom_color_enabled:SetChecked(O.db.health_text_custom_color_enabled);
    self.health_text_custom_color_enabled:SetTooltip(L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP']);
    self.health_text_custom_color_enabled:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.health_text_custom_color_enabled.Callback = function(self)
        O.db.health_text_custom_color_enabled = self:GetChecked();
        Stripes:UpdateAll();
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

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['HealthTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.health_text_custom_color_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.health_text_font_value = E.CreateDropdown('font', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_value:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.health_text_font_value:SetSize(160, 20);
    self.health_text_font_value:SetList(LSM:HashTable('font'));
    self.health_text_font_value:SetValue(O.db.health_text_font_value);
    self.health_text_font_value:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_VALUE']);
    self.health_text_font_value:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_VALUE'], self.Tabs[2]);
    self.health_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.health_text_font_value = value;
        Stripes:UpdateAll();
    end

    self.health_text_font_size = E.CreateSlider(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_size:SetPosition('LEFT', self.health_text_font_value, 'RIGHT', 12, 0);
    self.health_text_font_size:SetValues(O.db.health_text_font_size, 3, 28, 1);
    self.health_text_font_size:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_SIZE']);
    self.health_text_font_size:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_SIZE'], self.Tabs[2]);
    self.health_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.health_text_font_size = tonumber(value);
        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    self.health_text_font_shadow = E.CreateCheckButton(self.TabsFrames['HealthTextTab'].Content);
    self.health_text_font_shadow:SetPosition('LEFT', self.health_text_font_flag, 'RIGHT', 12, 0);
    self.health_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.health_text_font_shadow:SetChecked(O.db.health_text_font_shadow);
    self.health_text_font_shadow:SetTooltip(L['OPTIONS_HEALTH_TEXT_FONT_SHADOW']);
    self.health_text_font_shadow:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_FONT_SHADOW'], self.Tabs[2]);
    self.health_text_font_shadow.Callback = function(self)
        O.db.health_text_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['HealthTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.health_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.health_text_block_mode = E.CreateDropdown('plain', self.TabsFrames['HealthTextTab'].Content);
    self.health_text_block_mode:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.health_text_block_mode:SetSize(180, 20);
    self.health_text_block_mode:SetList(O.Lists.health_text_block_mode);
    self.health_text_block_mode:SetValue(O.db.health_text_block_mode);
    self.health_text_block_mode:SetLabel(L['OPTIONS_HEALTH_TEXT_BLOCK_MODE']);
    self.health_text_block_mode:SetTooltip(L['OPTIONS_HEALTH_TEXT_BLOCK_MODE_TOOLTIP']);
    self.health_text_block_mode:AddToSearch(button, L['OPTIONS_HEALTH_TEXT_BLOCK_MODE_TOOLTIP'], self.Tabs[2]);
    self.health_text_block_mode:SetEnabled(O.db.health_text_enabled);
    self.health_text_block_mode.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_mode = tonumber(value);

        panel.SingleBlockHolder:SetShown(O.db.health_text_block_mode == 1);
        panel.DoubleBlockHolder:SetShown(O.db.health_text_block_mode == 2);

        Stripes:UpdateAll();
    end

    self.SingleBlockHolder = Mixin(CreateFrame('Frame', nil, self.TabsFrames['HealthTextTab'].Content), E.PixelPerfectMixin);
    self.SingleBlockHolder:SetPosition('TOPLEFT', self.health_text_block_mode, 'BOTTOMLEFT', 0, -4);
    self.SingleBlockHolder:SetW(self:GetWidth());
    self.SingleBlockHolder:SetShown(O.db.health_text_block_mode == 1);

    self.DoubleBlockHolder = Mixin(CreateFrame('Frame', nil, self.TabsFrames['HealthTextTab'].Content), E.PixelPerfectMixin);
    self.DoubleBlockHolder:SetPosition('TOPLEFT', self.health_text_block_mode, 'BOTTOMLEFT', 0, -4);
    self.DoubleBlockHolder:SetW(self:GetWidth());
    self.DoubleBlockHolder:SetShown(O.db.health_text_block_mode == 2);

    local SingleBlockHeader = E.CreateHeader(self.SingleBlockHolder, L['OPTIONS_HEALTH_TEXT_SINGLE_BLOCK_HEADER']);
    SingleBlockHeader:SetPosition('TOPLEFT', self.health_text_block_mode, 'BOTTOMLEFT', 0, -4);
    SingleBlockHeader:SetW(self:GetWidth());

    self.health_text_display_mode = E.CreateDropdown('plain', self.SingleBlockHolder);
    self.health_text_display_mode:SetPosition('TOPLEFT', SingleBlockHeader, 'BOTTOMLEFT', 0, -8);
    self.health_text_display_mode:SetSize(120, 20);
    self.health_text_display_mode:SetList(O.Lists.health_text_display_mode);
    self.health_text_display_mode:SetValue(O.db.health_text_display_mode);
    self.health_text_display_mode:SetLabel(L['FORMAT']);
    self.health_text_display_mode:SetTooltip(L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP']);
    self.health_text_display_mode.OnValueChangedCallback = function(_, value)
        O.db.health_text_display_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_anchor = E.CreateDropdown('plain', self.SingleBlockHolder);
    self.health_text_anchor:SetPosition('TOPLEFT', self.health_text_display_mode, 'BOTTOMLEFT', 0, -16);
    self.health_text_anchor:SetSize(120, 20);
    self.health_text_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.health_text_anchor:SetValue(O.db.health_text_anchor);
    self.health_text_anchor:SetLabel(L['POSITION']);
    self.health_text_anchor:SetTooltip(L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP']);
    self.health_text_anchor.OnValueChangedCallback = function(_, value)
        O.db.health_text_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_x_offset = E.CreateSlider(self.SingleBlockHolder);
    self.health_text_x_offset:SetPosition('LEFT', self.health_text_anchor, 'RIGHT', 16, 0);
    self.health_text_x_offset:SetW(137);
    self.health_text_x_offset:SetLabel(L['OFFSET_X_SHORT']);
    self.health_text_x_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP']);
    self.health_text_x_offset:SetValues(O.db.health_text_x_offset, -99, 100, 1);
    self.health_text_x_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_y_offset = E.CreateSlider(self.SingleBlockHolder);
    self.health_text_y_offset:SetPosition('LEFT', self.health_text_x_offset, 'RIGHT', 16, 0);
    self.health_text_y_offset:SetW(137);
    self.health_text_y_offset:SetLabel(L['OFFSET_Y_SHORT']);
    self.health_text_y_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP']);
    self.health_text_y_offset:SetValues(O.db.health_text_y_offset, -99, 100, 1);
    self.health_text_y_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    local FirstBlockHeader = E.CreateHeader(self.DoubleBlockHolder, L['OPTIONS_HEALTH_TEXT_FIRST_BLOCK_HEADER']);
    FirstBlockHeader:SetPosition('TOPLEFT', self.health_text_block_mode, 'BOTTOMLEFT', 0, -4);
    FirstBlockHeader:SetW(self:GetWidth());

    self.health_text_block_1_display_mode = E.CreateDropdown('plain', self.DoubleBlockHolder);
    self.health_text_block_1_display_mode:SetPosition('TOPLEFT', FirstBlockHeader, 'BOTTOMLEFT', 0, -8);
    self.health_text_block_1_display_mode:SetSize(120, 20);
    self.health_text_block_1_display_mode:SetList(O.Lists.health_text_display_mode);
    self.health_text_block_1_display_mode:SetValue(O.db.health_text_block_1_display_mode);
    self.health_text_block_1_display_mode:SetLabel(L['FORMAT']);
    self.health_text_block_1_display_mode:SetTooltip(L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP']);
    self.health_text_block_1_display_mode.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_1_display_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_1_anchor = E.CreateDropdown('plain', self.DoubleBlockHolder);
    self.health_text_block_1_anchor:SetPosition('TOPLEFT', self.health_text_block_1_display_mode, 'BOTTOMLEFT', 0, -16);
    self.health_text_block_1_anchor:SetSize(120, 20);
    self.health_text_block_1_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.health_text_block_1_anchor:SetValue(O.db.health_text_block_1_anchor);
    self.health_text_block_1_anchor:SetLabel(L['POSITION']);
    self.health_text_block_1_anchor:SetTooltip(L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP']);
    self.health_text_block_1_anchor.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_1_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_1_x_offset = E.CreateSlider(self.DoubleBlockHolder);
    self.health_text_block_1_x_offset:SetPosition('LEFT', self.health_text_block_1_anchor, 'RIGHT', 16, 0);
    self.health_text_block_1_x_offset:SetW(137);
    self.health_text_block_1_x_offset:SetLabel(L['OFFSET_X_SHORT']);
    self.health_text_block_1_x_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP']);
    self.health_text_block_1_x_offset:SetValues(O.db.health_text_block_1_x_offset, -99, 100, 1);
    self.health_text_block_1_x_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_1_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_1_y_offset = E.CreateSlider(self.DoubleBlockHolder);
    self.health_text_block_1_y_offset:SetPosition('LEFT', self.health_text_block_1_x_offset, 'RIGHT', 16, 0);
    self.health_text_block_1_y_offset:SetW(137);
    self.health_text_block_1_y_offset:SetLabel(L['OFFSET_Y_SHORT']);
    self.health_text_block_1_y_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP']);
    self.health_text_block_1_y_offset:SetValues(O.db.health_text_block_1_y_offset, -99, 100, 1);
    self.health_text_block_1_y_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_1_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    local SecondBlockHeader = E.CreateHeader(self.DoubleBlockHolder, L['OPTIONS_HEALTH_TEXT_SECOND_BLOCK_HEADER']);
    SecondBlockHeader:SetPosition('TOPLEFT', self.health_text_block_1_anchor, 'BOTTOMLEFT', 0, -8);
    SecondBlockHeader:SetW(self:GetWidth());

    self.health_text_block_2_display_mode = E.CreateDropdown('plain', self.DoubleBlockHolder);
    self.health_text_block_2_display_mode:SetPosition('TOPLEFT', SecondBlockHeader, 'BOTTOMLEFT', 0, -8);
    self.health_text_block_2_display_mode:SetSize(120, 20);
    self.health_text_block_2_display_mode:SetList(O.Lists.health_text_display_mode);
    self.health_text_block_2_display_mode:SetValue(O.db.health_text_block_2_display_mode);
    self.health_text_block_2_display_mode:SetLabel(L['FORMAT']);
    self.health_text_block_2_display_mode:SetTooltip(L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP']);
    self.health_text_block_2_display_mode.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_2_display_mode = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_2_anchor = E.CreateDropdown('plain', self.DoubleBlockHolder);
    self.health_text_block_2_anchor:SetPosition('TOPLEFT', self.health_text_block_2_display_mode, 'BOTTOMLEFT', 0, -16);
    self.health_text_block_2_anchor:SetSize(120, 20);
    self.health_text_block_2_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.health_text_block_2_anchor:SetValue(O.db.health_text_block_2_anchor);
    self.health_text_block_2_anchor:SetLabel(L['POSITION']);
    self.health_text_block_2_anchor:SetTooltip(L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP']);
    self.health_text_block_2_anchor.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_2_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_2_x_offset = E.CreateSlider(self.DoubleBlockHolder);
    self.health_text_block_2_x_offset:SetPosition('LEFT', self.health_text_block_2_anchor, 'RIGHT', 16, 0);
    self.health_text_block_2_x_offset:SetW(137);
    self.health_text_block_2_x_offset:SetLabel(L['OFFSET_X_SHORT']);
    self.health_text_block_2_x_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP']);
    self.health_text_block_2_x_offset:SetValues(O.db.health_text_block_2_x_offset, -99, 100, 1);
    self.health_text_block_2_x_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_2_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.health_text_block_2_y_offset = E.CreateSlider(self.DoubleBlockHolder);
    self.health_text_block_2_y_offset:SetPosition('LEFT', self.health_text_block_2_x_offset, 'RIGHT', 16, 0);
    self.health_text_block_2_y_offset:SetW(137);
    self.health_text_block_2_y_offset:SetLabel(L['OFFSET_Y_SHORT']);
    self.health_text_block_2_y_offset:SetTooltip(L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP']);
    self.health_text_block_2_y_offset:SetValues(O.db.health_text_block_2_y_offset, -99, 100, 1);
    self.health_text_block_2_y_offset.OnValueChangedCallback = function(_, value)
        O.db.health_text_block_2_y_offset = tonumber(value);
        Stripes:UpdateAll();
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

        panel.level_text_hide_max:SetEnabled(O.db.level_text_enabled);

        Stripes:UpdateAll();
    end

    self.level_text_show_only_on_target = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_show_only_on_target:SetPosition('LEFT', self.level_text_enabled.Label, 'RIGHT', 12, 0);
    self.level_text_show_only_on_target:SetLabel(L['OPTIONS_LEVEL_TEXT_SHOW_ONLY_ON_TARGET']);
    self.level_text_show_only_on_target:SetTooltip(L['OPTIONS_LEVEL_TEXT_SHOW_ONLY_ON_TARGET_TOOLTIP']);
    self.level_text_show_only_on_target:SetChecked(O.db.level_text_show_only_on_target);
    self.level_text_show_only_on_target:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_SHOW_ONLY_ON_TARGET_TOOLTIP'], self.Tabs[3]);
    self.level_text_show_only_on_target.Callback = function(self)
        O.db.level_text_show_only_on_target = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.level_text_hide_max = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_hide_max:SetPosition('LEFT', self.level_text_show_only_on_target.Label, 'RIGHT', 12, 0);
    self.level_text_hide_max:SetLabel(L['OPTIONS_LEVEL_TEXT_HIDE_MAX']);
    self.level_text_hide_max:SetTooltip(L['OPTIONS_LEVEL_TEXT_HIDE_MAX_TOOLTIP'] .. ' (' .. GetMaxLevelForLatestExpansion() .. ')');
    self.level_text_hide_max:SetChecked(O.db.level_text_hide_max);
    self.level_text_hide_max:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_HIDE_MAX_TOOLTIP'], self.Tabs[3]);
    self.level_text_hide_max:SetEnabled(O.db.level_text_enabled);
    self.level_text_hide_max.Callback = function(self)
        O.db.level_text_hide_max = self:GetChecked();
        Stripes:UpdateAll();
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

        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
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

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['LevelTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.level_text_use_diff_color, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.level_text_font_value = E.CreateDropdown('font', self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_value:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.level_text_font_value:SetSize(160, 20);
    self.level_text_font_value:SetList(LSM:HashTable('font'));
    self.level_text_font_value:SetValue(O.db.level_text_font_value);
    self.level_text_font_value:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_VALUE']);
    self.level_text_font_value:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_VALUE'], self.Tabs[3]);
    self.level_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.level_text_font_value = value;
        Stripes:UpdateAll();
    end

    self.level_text_font_size = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_size:SetPosition('LEFT', self.level_text_font_value, 'RIGHT', 12, 0);
    self.level_text_font_size:SetValues(O.db.level_text_font_size, 3, 28, 1);
    self.level_text_font_size:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_SIZE']);
    self.level_text_font_size:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_SIZE'], self.Tabs[3]);
    self.level_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.level_text_font_size = tonumber(value);
        Stripes:UpdateAll();
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
        Stripes:UpdateAll();
    end

    self.level_text_font_shadow = E.CreateCheckButton(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_font_shadow:SetPosition('LEFT', self.level_text_font_flag, 'RIGHT', 12, 0);
    self.level_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.level_text_font_shadow:SetChecked(O.db.level_text_font_shadow);
    self.level_text_font_shadow:SetTooltip(L['OPTIONS_LEVEL_TEXT_FONT_SHADOW']);
    self.level_text_font_shadow:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_FONT_SHADOW'], self.Tabs[3]);
    self.level_text_font_shadow.Callback = function(self)
        O.db.level_text_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['LevelTextTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.level_text_font_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.level_text_anchor = E.CreateDropdown('plain', self.TabsFrames['LevelTextTab'].Content);
    self.level_text_anchor:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.level_text_anchor:SetSize(120, 20);
    self.level_text_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.level_text_anchor:SetValue(O.db.level_text_anchor);
    self.level_text_anchor:SetLabel(L['POSITION']);
    self.level_text_anchor:SetTooltip(L['OPTIONS_LEVEL_TEXT_ANCHOR_TOOLTIP']);
    self.level_text_anchor:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_ANCHOR_TOOLTIP'], self.Tabs[3]);
    self.level_text_anchor.OnValueChangedCallback = function(_, value)
        O.db.level_text_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.level_text_x_offset = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_x_offset:SetPosition('LEFT', self.level_text_anchor, 'RIGHT', 16, 0);
    self.level_text_x_offset:SetW(137);
    self.level_text_x_offset:SetTooltip(L['OPTIONS_LEVEL_TEXT_X_OFFSET_TOOLTIP']);
    self.level_text_x_offset:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_X_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.level_text_x_offset:SetValues(O.db.level_text_x_offset, -99, 100, 1);
    self.level_text_x_offset.OnValueChangedCallback = function(_, value)
        O.db.level_text_x_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    self.level_text_y_offset = E.CreateSlider(self.TabsFrames['LevelTextTab'].Content);
    self.level_text_y_offset:SetPosition('LEFT', self.level_text_x_offset, 'RIGHT', 16, 0);
    self.level_text_y_offset:SetW(137);
    self.level_text_y_offset:SetTooltip(L['OPTIONS_LEVEL_TEXT_Y_OFFSET_TOOLTIP']);
    self.level_text_y_offset:AddToSearch(button, L['OPTIONS_LEVEL_TEXT_Y_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.level_text_y_offset:SetValues(O.db.level_text_y_offset, -99, 100, 1);
    self.level_text_y_offset.OnValueChangedCallback = function(_, value)
        O.db.level_text_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end
end