local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Useful');

local LSM = S.Libraries.LSM;

O.frame.Left.Useful, O.frame.Right.Useful = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_USEFUL']), 'useful', 9);
local button = O.frame.Left.Useful;
local panel = O.frame.Right.Useful;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_USEFUL_TAB_COMMON']),
    },
    [2] = {
        name  = 'CombatIndicatorTab',
        title = string.upper(L['OPTIONS_USEFUL_TAB_COMBAT_INDICATOR']),
    },
    [3] = {
        name  = 'SpellInterruptedTab',
        title = string.upper(L['OPTIONS_USEFUL_TAB_SPELL_INTERRUPTED']),
    },
    [4] = {
        name  = 'HealersMarksTab',
        title = string.upper(L['OPTIONS_USEFUL_TAB_HEALERS_MARKS']),
    },
};

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.quest_indicator_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_enabled:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.quest_indicator_enabled:SetLabel(L['OPTIONS_QUEST_INDICATOR_ENABLED']);
    self.quest_indicator_enabled:SetTooltip(L['OPTIONS_QUEST_INDICATOR_ENABLED_TOOLTIP']);
    self.quest_indicator_enabled:AddToSearch(button, L['OPTIONS_QUEST_INDICATOR_ENABLED'], self.Tabs[1]);
    self.quest_indicator_enabled:SetChecked(O.db.quest_indicator_enabled);
    self.quest_indicator_enabled.Callback = function(self)
        O.db.quest_indicator_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.quest_indicator_position = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_position:SetPosition('LEFT', self.quest_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.quest_indicator_position:SetSize(110, 20);
    self.quest_indicator_position:SetList(O.Lists.quest_indicator_position);
    self.quest_indicator_position:SetValue(O.db.quest_indicator_position);
    self.quest_indicator_position:SetLabel(L['POSITION']);
    self.quest_indicator_position:SetTooltip(L['OPTIONS_QUEST_INDICATOR_POSITION_TOOLTIP']);
    self.quest_indicator_position:AddToSearch(button, L['OPTIONS_QUEST_INDICATOR_POSITION_TOOLTIP'], self.Tabs[1]);
    self.quest_indicator_position.OnValueChangedCallback = function(_, value)
        O.db.quest_indicator_position = tonumber(value);
        Stripes:UpdateAll();
    end

    self.quest_indicator_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_font_value:SetSize(160, 20);
    self.quest_indicator_font_value:SetList(LSM:HashTable('font'));
    self.quest_indicator_font_value:SetValue(O.db.quest_indicator_font_value);
    self.quest_indicator_font_value:SetTooltip(L['OPTIONS_QUEST_INDICATOR_FONT_VALUE_TOOLTIP']);
    self.quest_indicator_font_value.OnValueChangedCallback = function(_, value)
        O.db.quest_indicator_font_value = value;
        Stripes:UpdateAll();
    end

    self.quest_indicator_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_font_size:SetValues(O.db.quest_indicator_font_size, 3, 28, 1);
    self.quest_indicator_font_size:SetTooltip(L['OPTIONS_QUEST_INDICATOR_FONT_SIZE_TOOLTIP']);
    self.quest_indicator_font_size.OnValueChangedCallback = function(_, value)
        O.db.quest_indicator_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.quest_indicator_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_font_flag:SetSize(160, 20);
    self.quest_indicator_font_flag:SetList(O.Lists.font_flags_localized);
    self.quest_indicator_font_flag:SetValue(O.db.quest_indicator_font_flag);
    self.quest_indicator_font_flag:SetTooltip(L['OPTIONS_QUEST_INDICATOR_FONT_FLAG_TOOLTIP']);
    self.quest_indicator_font_flag.OnValueChangedCallback = function(_, value)
        O.db.quest_indicator_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.quest_indicator_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.quest_indicator_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.quest_indicator_font_shadow:SetChecked(O.db.quest_indicator_font_shadow);
    self.quest_indicator_font_shadow:SetTooltip(L['OPTIONS_QUEST_INDICATOR_FONT_SHADOW_TOOLTIP']);
    self.quest_indicator_font_shadow.Callback = function(self)
        O.db.quest_indicator_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.QuestIndicatorFontOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.QuestIndicatorFontOptions:SetH(60);
    self.QuestIndicatorFontOptions:Add(self.quest_indicator_font_value):SetPosition('TOPLEFT', self.QuestIndicatorFontOptions, 'TOPLEFT', 8, -20);
    self.QuestIndicatorFontOptions:Add(self.quest_indicator_font_size):SetPosition('LEFT', self.quest_indicator_font_value, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions:Add(self.quest_indicator_font_flag):SetPosition('LEFT', self.quest_indicator_font_size, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions:Add(self.quest_indicator_font_shadow):SetPosition('LEFT', self.quest_indicator_font_flag, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions.OpenButton:SetPosition('LEFT', self.quest_indicator_position, 'RIGHT', 16, 0);
    self.QuestIndicatorFontOptions.OpenButton:SetLabel(L['FONT_OPTIONS']);

    self.stealth_detect_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.stealth_detect_enabled:SetPosition('TOPLEFT', self.quest_indicator_enabled, 'BOTTOMLEFT', 0, -8);
    self.stealth_detect_enabled:SetLabel(L['OPTIONS_STEALTH_DETECT_ENABLED']);
    self.stealth_detect_enabled:SetTooltip(L['OPTIONS_STEALTH_DETECT_ENABLED_TOOLTIP']);
    self.stealth_detect_enabled:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_ENABLED'], self.Tabs[1]);
    self.stealth_detect_enabled:SetChecked(O.db.stealth_detect_enabled);
    self.stealth_detect_enabled.Callback = function(self)
        O.db.stealth_detect_enabled = self:GetChecked();

        panel.stealth_detect_always:SetEnabled(O.db.stealth_detect_enabled);
        panel.stealth_detect_not_in_combat:SetEnabled(O.db.stealth_detect_enabled);

        Stripes:UpdateAll();
    end

    self.stealth_detect_always = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.stealth_detect_always:SetPosition('LEFT', self.stealth_detect_enabled.Label, 'RIGHT', 12, 0);
    self.stealth_detect_always:SetLabel(L['OPTIONS_STEALTH_DETECT_ALWAYS']);
    self.stealth_detect_always:SetTooltip(L['OPTIONS_STEALTH_DETECT_ALWAYS_TOOLTIP']);
    self.stealth_detect_always:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_ALWAYS_TOOLTIP'], self.Tabs[1]);
    self.stealth_detect_always:SetChecked(O.db.stealth_detect_always);
    self.stealth_detect_always:SetEnabled(O.db.stealth_detect_enabled);
    self.stealth_detect_always.Callback = function(self)
        O.db.stealth_detect_always = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.stealth_detect_not_in_combat = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.stealth_detect_not_in_combat:SetPosition('LEFT', self.stealth_detect_always.Label, 'RIGHT', 12, 0);
    self.stealth_detect_not_in_combat:SetLabel(L['OPTIONS_STEALTH_DETECT_NOT_IN_COMBAT']);
    self.stealth_detect_not_in_combat:SetTooltip(L['OPTIONS_STEALTH_DETECT_NOT_IN_COMBAT_TOOLTIP']);
    self.stealth_detect_not_in_combat:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_NOT_IN_COMBAT_TOOLTIP'], self.Tabs[1]);
    self.stealth_detect_not_in_combat:SetChecked(O.db.stealth_detect_not_in_combat);
    self.stealth_detect_not_in_combat:SetEnabled(O.db.stealth_detect_enabled);
    self.stealth_detect_not_in_combat.Callback = function(self)
        O.db.stealth_detect_not_in_combat = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.stealth_detect_glow_type = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.stealth_detect_glow_type:SetPosition('LEFT', self.stealth_detect_not_in_combat.Label, 'RIGHT', 12, 0);
    self.stealth_detect_glow_type:SetSize(120, 20);
    self.stealth_detect_glow_type:SetList(O.Lists.glow_type_short_with_none);
    self.stealth_detect_glow_type:SetValue(O.db.stealth_detect_glow_type);
    self.stealth_detect_glow_type:SetTooltip(L['OPTIONS_STEALTH_DETECT_GLOW_TOOLTIP']);
    self.stealth_detect_glow_type:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_GLOW_TOOLTIP'], self.Tabs[1]);
    self.stealth_detect_glow_type.OnValueChangedCallback = function(_, value)
        value = tonumber(value);

        O.db.stealth_detect_glow_enabled = value ~= 0;
        O.db.stealth_detect_glow_type    = value;

        Stripes:UpdateAll();
    end

    self.stealth_detect_glow_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.stealth_detect_glow_color:SetPosition('LEFT', self.stealth_detect_glow_type, 'RIGHT', 12, 0);
    self.stealth_detect_glow_color:SetTooltip(L['OPTIONS_STEALTH_DETECT_GLOW_COLOR_TOOLTIP']);
    self.stealth_detect_glow_color:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_GLOW_COLOR_TOOLTIP'], self.Tabs[1]);
    self.stealth_detect_glow_color:SetValue(unpack(O.db.stealth_detect_glow_color));
    self.stealth_detect_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.stealth_detect_glow_color[1] = r;
        O.db.stealth_detect_glow_color[2] = g;
        O.db.stealth_detect_glow_color[3] = b;
        O.db.stealth_detect_glow_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.totem_icon_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.totem_icon_enabled:SetPosition('TOPLEFT', self.stealth_detect_enabled, 'BOTTOMLEFT', 0, -8);
    self.totem_icon_enabled:SetLabel(L['OPTIONS_TOTEM_ICON_ENABLED']);
    self.totem_icon_enabled:SetTooltip(L['OPTIONS_TOTEM_ICON_ENABLED_TOOLTIP']);
    self.totem_icon_enabled:AddToSearch(button, L['OPTIONS_TOTEM_ICON_ENABLED'], self.Tabs[1]);
    self.totem_icon_enabled:SetChecked(O.db.totem_icon_enabled);
    self.totem_icon_enabled.Callback = function(self)
        O.db.totem_icon_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.talking_head_suppress = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.talking_head_suppress:SetPosition('TOPLEFT', self.totem_icon_enabled, 'BOTTOMLEFT', 0, -8);
    self.talking_head_suppress:SetLabel(L['OPTIONS_TALKING_HEAD_SUPPRESS']);
    self.talking_head_suppress:SetTooltip(L['OPTIONS_TALKING_HEAD_SUPPRESS_TOOLTIP']);
    self.talking_head_suppress:AddToSearch(button, L['OPTIONS_TALKING_HEAD_SUPPRESS_TOOLTIP'], self.Tabs[1]);
    self.talking_head_suppress:SetChecked(O.db.talking_head_suppress);
    self.talking_head_suppress.Callback = function(self)
        O.db.talking_head_suppress = self:GetChecked();

        panel.talking_head_suppress_always:SetEnabled(O.db.talking_head_suppress);

        Stripes:UpdateAll();
    end

    self.talking_head_suppress_always = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.talking_head_suppress_always:SetPosition('LEFT', self.talking_head_suppress.Label, 'RIGHT', 12, 0);
    self.talking_head_suppress_always:SetLabel(L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS']);
    self.talking_head_suppress_always:SetTooltip(L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS_TOOLTIP']);
    self.talking_head_suppress_always:AddToSearch(button, L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS_TOOLTIP'], self.Tabs[1]);
    self.talking_head_suppress_always:SetChecked(O.db.talking_head_suppress_always);
    self.talking_head_suppress_always:SetEnabled(O.db.talking_head_suppress);
    self.talking_head_suppress_always.Callback = function(self)
        O.db.talking_head_suppress_always = self:GetChecked();
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Combat Indicator Tab ------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.combat_indicator_enabled = E.CreateCheckButton(self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_enabled:SetPosition('TOPLEFT', self.TabsFrames['CombatIndicatorTab'].Content, 'TOPLEFT', 0, -4);
    self.combat_indicator_enabled:SetLabel(L['OPTIONS_COMBAT_INDICATOR_ENABLED']);
    self.combat_indicator_enabled:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_ENABLED_TOOLTIP']);
    self.combat_indicator_enabled:AddToSearch(button, L['OPTIONS_COMBAT_INDICATOR_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.combat_indicator_enabled:SetChecked(O.db.combat_indicator_enabled);
    self.combat_indicator_enabled.Callback = function(self)
        O.db.combat_indicator_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.combat_indicator_color = E.CreateColorPicker(self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_color:SetPosition('LEFT', self.combat_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.combat_indicator_color:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_COLOR_TOOLTIP']);
    self.combat_indicator_color:AddToSearch(button, L['OPTIONS_COMBAT_INDICATOR_COLOR_TOOLTIP'], self.Tabs[2]);
    self.combat_indicator_color:SetValue(unpack(O.db.combat_indicator_color));
    self.combat_indicator_color.OnValueChanged = function(_, r, g, b, a)
        O.db.combat_indicator_color[1] = r;
        O.db.combat_indicator_color[2] = g;
        O.db.combat_indicator_color[3] = b;
        O.db.combat_indicator_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.combat_indicator_size = E.CreateSlider(self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_size:SetPosition('LEFT', self.combat_indicator_color, 'RIGHT', 12, 0);
    self.combat_indicator_size:SetValues(O.db.combat_indicator_size, 2, 32, 1);
    self.combat_indicator_size:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_SIZE_TOOLTIP']);
    self.combat_indicator_size:AddToSearch(button, L['OPTIONS_COMBAT_INDICATOR_SIZE_TOOLTIP'], self.Tabs[2]);
    self.combat_indicator_size.OnValueChangedCallback = function(_, value)
        O.db.combat_indicator_size = tonumber(value);
        Stripes:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CombatIndicatorTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.combat_indicator_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.combat_indicator_point = E.CreateDropdown('plain', self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_point:SetSize(120, 20);
    self.combat_indicator_point:SetList(O.Lists.frame_points_localized);
    self.combat_indicator_point:SetValue(O.db.combat_indicator_point);
    self.combat_indicator_point:SetLabel(L['POSITION']);
    self.combat_indicator_point:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_POINT_TOOLTIP']);
    self.combat_indicator_point.OnValueChangedCallback = function(_, value)
        O.db.combat_indicator_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.combat_indicator_relative_point = E.CreateDropdown('plain', self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_relative_point:SetSize(120, 20);
    self.combat_indicator_relative_point:SetList(O.Lists.frame_points_localized);
    self.combat_indicator_relative_point:SetValue(O.db.combat_indicator_relative_point);
    self.combat_indicator_relative_point:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_RELATIVE_POINT_TOOLTIP']);
    self.combat_indicator_relative_point.OnValueChangedCallback = function(_, value)
        O.db.combat_indicator_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.combat_indicator_offset_x = E.CreateSlider(self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_offset_x:SetSize(120, 18);
    self.combat_indicator_offset_x:SetValues(O.db.combat_indicator_offset_x, -50, 50, 1);
    self.combat_indicator_offset_x:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_OFFSET_X_TOOLTIP']);
    self.combat_indicator_offset_x.OnValueChangedCallback = function(_, value)
        O.db.combat_indicator_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.combat_indicator_offset_y = E.CreateSlider(self.TabsFrames['CombatIndicatorTab'].Content);
    self.combat_indicator_offset_y:SetSize(120, 18);
    self.combat_indicator_offset_y:SetValues(O.db.combat_indicator_offset_y, -50, 50, 1);
    self.combat_indicator_offset_y:SetTooltip(L['OPTIONS_COMBAT_INDICATOR_OFFSET_Y_TOOLTIP']);
    self.combat_indicator_offset_y.OnValueChangedCallback = function(_, value)
        O.db.combat_indicator_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.CombatIndicatorPositionOptions = E.CreatePopOptions(self.TabsFrames['CombatIndicatorTab'].Content);
    self.CombatIndicatorPositionOptions:SetH(60);
    self.CombatIndicatorPositionOptions:Add(self.combat_indicator_point):SetPosition('TOPLEFT', self.CombatIndicatorPositionOptions, 'TOPLEFT', 12, -20);
    self.CombatIndicatorPositionOptions:Add(self.combat_indicator_relative_point):SetPosition('LEFT', self.combat_indicator_point, 'RIGHT', 12, 0);
    self.CombatIndicatorPositionOptions:Add(self.combat_indicator_offset_x):SetPosition('LEFT', self.combat_indicator_relative_point, 'RIGHT', 12, 0);
    self.CombatIndicatorPositionOptions:Add(self.combat_indicator_offset_y):SetPosition('LEFT', self.combat_indicator_offset_x, 'RIGHT', 12, 0);
    self.CombatIndicatorPositionOptions.OpenButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.CombatIndicatorPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['CombatIndicatorTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.CombatIndicatorPositionOptions.OpenButton, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Spell Interrupted Tab -----------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.spell_interrupted_icon = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon:SetPosition('TOPLEFT', self.TabsFrames['SpellInterruptedTab'].Content, 'TOPLEFT', 0, -4);
    self.spell_interrupted_icon:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON']);
    self.spell_interrupted_icon:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_TOOLTIP']);
    self.spell_interrupted_icon:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon:SetChecked(O.db.spell_interrupted_icon);
    self.spell_interrupted_icon.Callback = function(self)
        O.db.spell_interrupted_icon = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_size = E.CreateSlider(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_size:SetPosition('LEFT', self.spell_interrupted_icon.Label, 'RIGHT', 16, 0);
    self.spell_interrupted_icon_size:SetValues(O.db.spell_interrupted_icon_size, 2, 40, 1);
    self.spell_interrupted_icon_size:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON_SIZE']);
    self.spell_interrupted_icon_size:SetLabelPosition('LEFT');
    self.spell_interrupted_icon_size:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_SIZE_TOOLTIP']);
    self.spell_interrupted_icon_size:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_SIZE_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_size.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_point = E.CreateDropdown('plain', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_point:SetSize(120, 20);
    self.spell_interrupted_icon_point:SetList(O.Lists.frame_points_localized);
    self.spell_interrupted_icon_point:SetValue(O.db.spell_interrupted_icon_point);
    self.spell_interrupted_icon_point:SetLabel(L['POSITION']);
    self.spell_interrupted_icon_point:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_POINT_TOOLTIP']);
    self.spell_interrupted_icon_point.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_relative_point = E.CreateDropdown('plain', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_relative_point:SetSize(120, 20);
    self.spell_interrupted_icon_relative_point:SetList(O.Lists.frame_points_localized);
    self.spell_interrupted_icon_relative_point:SetValue(O.db.spell_interrupted_icon_relative_point);
    self.spell_interrupted_icon_relative_point:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_RELATIVE_POINT_TOOLTIP']);
    self.spell_interrupted_icon_relative_point.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_offset_x = E.CreateSlider(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_offset_x:SetSize(120, 18);
    self.spell_interrupted_icon_offset_x:SetValues(O.db.spell_interrupted_icon_offset_x, -50, 50, 1);
    self.spell_interrupted_icon_offset_x:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_OFFSET_X_TOOLTIP']);
    self.spell_interrupted_icon_offset_x.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_offset_y = E.CreateSlider(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_offset_y:SetSize(120, 18);
    self.spell_interrupted_icon_offset_y:SetValues(O.db.spell_interrupted_icon_offset_y, -50, 50, 1);
    self.spell_interrupted_icon_offset_y:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_OFFSET_Y_TOOLTIP']);
    self.spell_interrupted_icon_offset_y.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_frame_strata = E.CreateDropdown('plain', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_frame_strata:SetSize(160, 20);
    self.spell_interrupted_icon_frame_strata:SetList(O.Lists.frame_strata);
    self.spell_interrupted_icon_frame_strata:SetValue(O.db.spell_interrupted_icon_frame_strata);
    self.spell_interrupted_icon_frame_strata:SetLabel(L['FRAME_STRATA']);
    self.spell_interrupted_icon_frame_strata:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_FRAME_STRATA_TOOLTIP']);
    self.spell_interrupted_icon_frame_strata.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_frame_strata = tonumber(value);
        Stripes:UpdateAll();
    end

    self.SpellInterruptedIconPositionOptions = E.CreatePopOptions(self.TabsFrames['SpellInterruptedTab'].Content);
    self.SpellInterruptedIconPositionOptions:SetH(120);
    self.SpellInterruptedIconPositionOptions:Add(self.spell_interrupted_icon_point):SetPosition('TOPLEFT', self.SpellInterruptedIconPositionOptions, 'TOPLEFT', 12, -30);
    self.SpellInterruptedIconPositionOptions:Add(self.spell_interrupted_icon_relative_point):SetPosition('LEFT', self.spell_interrupted_icon_point, 'RIGHT', 12, 0);
    self.SpellInterruptedIconPositionOptions:Add(self.spell_interrupted_icon_offset_x):SetPosition('LEFT', self.spell_interrupted_icon_relative_point, 'RIGHT', 12, 0);
    self.SpellInterruptedIconPositionOptions:Add(self.spell_interrupted_icon_offset_y):SetPosition('LEFT', self.spell_interrupted_icon_offset_x, 'RIGHT', 12, 0);
    self.SpellInterruptedIconPositionOptions:Add(self.spell_interrupted_icon_frame_strata):SetPosition('TOPLEFT', self.spell_interrupted_icon_point, 'BOTTOMLEFT', 0, -16);
    self.SpellInterruptedIconPositionOptions.OpenButton:SetPosition('LEFT', self.spell_interrupted_icon_size, 'RIGHT', 16, 0);
    self.SpellInterruptedIconPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    self.spell_interrupted_icon_show_interrupted_icon = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_show_interrupted_icon:SetPosition('TOPLEFT', self.spell_interrupted_icon, 'BOTTOMLEFT', 0, -8);
    self.spell_interrupted_icon_show_interrupted_icon:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON_SHOW_INTERRUPTED_ICON']);
    self.spell_interrupted_icon_show_interrupted_icon:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_SHOW_INTERRUPTED_ICON_TOOLTIP']);
    self.spell_interrupted_icon_show_interrupted_icon:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_SHOW_INTERRUPTED_ICON_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_show_interrupted_icon:SetChecked(O.db.spell_interrupted_icon_show_interrupted_icon);
    self.spell_interrupted_icon_show_interrupted_icon.Callback = function(self)
        O.db.spell_interrupted_icon_show_interrupted_icon = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellInterruptedTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.spell_interrupted_icon_show_interrupted_icon, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.spell_interrupted_countdown_text = E.CreateFontString(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_countdown_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, 0);
    self.spell_interrupted_countdown_text:SetText(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_TEXT']);

    self.spell_interrupted_icon_countdown_show = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_countdown_show:SetPosition('TOPLEFT', self.spell_interrupted_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.spell_interrupted_icon_countdown_show:SetLabel(L['OPTIONS_SHOW']);
    self.spell_interrupted_icon_countdown_show:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_SHOW_TOOLTIP']);
    self.spell_interrupted_icon_countdown_show:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_SHOW_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_countdown_show:SetChecked(O.db.spell_interrupted_icon_countdown_show);
    self.spell_interrupted_icon_countdown_show.Callback = function(self)
        O.db.spell_interrupted_icon_countdown_show = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_cooldown_draw_swipe = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_cooldown_draw_swipe:SetPosition('LEFT', self.spell_interrupted_icon_countdown_show.Label, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_cooldown_draw_swipe:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_SWIPE']);
    self.spell_interrupted_icon_cooldown_draw_swipe:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_SWIPE_TOOLTIP']);
    self.spell_interrupted_icon_cooldown_draw_swipe:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_SWIPE_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_cooldown_draw_swipe:SetChecked(O.db.spell_interrupted_icon_cooldown_draw_swipe);
    self.spell_interrupted_icon_cooldown_draw_swipe.Callback = function(self)
        O.db.spell_interrupted_icon_cooldown_draw_swipe = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_cooldown_draw_edge = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_cooldown_draw_edge:SetPosition('LEFT', self.spell_interrupted_icon_cooldown_draw_swipe.Label, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_cooldown_draw_edge:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_EDGE']);
    self.spell_interrupted_icon_cooldown_draw_edge:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_EDGE_TOOLTIP']);
    self.spell_interrupted_icon_cooldown_draw_edge:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COOLDOWN_DRAW_EDGE_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_cooldown_draw_edge:SetChecked(O.db.spell_interrupted_icon_cooldown_draw_edge);
    self.spell_interrupted_icon_cooldown_draw_edge.Callback = function(self)
        O.db.spell_interrupted_icon_cooldown_draw_edge = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_value = E.CreateDropdown('font', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_countdown_font_value:SetSize(160, 20);
    self.spell_interrupted_icon_countdown_font_value:SetList(LSM:HashTable('font'));
    self.spell_interrupted_icon_countdown_font_value:SetValue(O.db.spell_interrupted_icon_countdown_font_value);
    self.spell_interrupted_icon_countdown_font_value:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_VALUE']);
    self.spell_interrupted_icon_countdown_font_value.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_value = value;
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_size = E.CreateSlider(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_countdown_font_size:SetValues(O.db.spell_interrupted_icon_countdown_font_size, 3, 28, 1);
    self.spell_interrupted_icon_countdown_font_size:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SIZE']);
    self.spell_interrupted_icon_countdown_font_size.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_flag = E.CreateDropdown('plain', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_countdown_font_flag:SetSize(160, 20);
    self.spell_interrupted_icon_countdown_font_flag:SetList(O.Lists.font_flags_localized);
    self.spell_interrupted_icon_countdown_font_flag:SetValue(O.db.spell_interrupted_icon_countdown_font_flag);
    self.spell_interrupted_icon_countdown_font_flag:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_FLAG']);
    self.spell_interrupted_icon_countdown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_countdown_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.spell_interrupted_icon_countdown_font_shadow:SetChecked(O.db.spell_interrupted_icon_countdown_font_shadow);
    self.spell_interrupted_icon_countdown_font_shadow:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SHADOW']);
    self.spell_interrupted_icon_countdown_font_shadow.Callback = function(self)
        O.db.spell_interrupted_icon_countdown_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.QuestIndicatorFontOptions = E.CreatePopOptions(self.TabsFrames['SpellInterruptedTab'].Content);
    self.QuestIndicatorFontOptions:SetH(60);
    self.QuestIndicatorFontOptions:Add(self.spell_interrupted_icon_countdown_font_value):SetPosition('TOPLEFT', self.QuestIndicatorFontOptions, 'TOPLEFT', 8, -20);
    self.QuestIndicatorFontOptions:Add(self.spell_interrupted_icon_countdown_font_size):SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_value, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions:Add(self.spell_interrupted_icon_countdown_font_flag):SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_size, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions:Add(self.spell_interrupted_icon_countdown_font_shadow):SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_flag, 'RIGHT', 12, 0);
    self.QuestIndicatorFontOptions.OpenButton:SetPosition('LEFT', self.spell_interrupted_icon_cooldown_draw_edge.Label, 'RIGHT', 16, 0);
    self.QuestIndicatorFontOptions.OpenButton:SetLabel(L['FONT_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellInterruptedTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.spell_interrupted_icon_countdown_show, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.spell_interrupted_icon_caster_name_text = E.CreateFontString(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_text:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, 0);
    self.spell_interrupted_icon_caster_name_text:SetText(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_TEXT']);

    self.spell_interrupted_icon_caster_name_show = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_show:SetPosition('TOPLEFT', self.spell_interrupted_icon_caster_name_text, 'BOTTOMLEFT', 0, -4);
    self.spell_interrupted_icon_caster_name_show:SetLabel(L['OPTIONS_SHOW']);
    self.spell_interrupted_icon_caster_name_show:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW_TOOLTIP']);
    self.spell_interrupted_icon_caster_name_show:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW_TOOLTIP'], self.Tabs[3]);
    self.spell_interrupted_icon_caster_name_show:SetChecked(O.db.spell_interrupted_icon_caster_name_show);
    self.spell_interrupted_icon_caster_name_show.Callback = function(self)
        O.db.spell_interrupted_icon_caster_name_show = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_value = E.CreateDropdown('font', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_font_value:SetPosition('TOPLEFT', self.spell_interrupted_icon_caster_name_show, 'BOTTOMLEFT', 0, -8);
    self.spell_interrupted_icon_caster_name_font_value:SetSize(160, 20);
    self.spell_interrupted_icon_caster_name_font_value:SetList(LSM:HashTable('font'));
    self.spell_interrupted_icon_caster_name_font_value:SetValue(O.db.spell_interrupted_icon_caster_name_font_value);
    self.spell_interrupted_icon_caster_name_font_value:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_VALUE']);
    self.spell_interrupted_icon_caster_name_font_value:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_VALUE'], self.Tabs[3]);
    self.spell_interrupted_icon_caster_name_font_value.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_value = value;
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_size = E.CreateSlider(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_font_size:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_value, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_caster_name_font_size:SetValues(O.db.spell_interrupted_icon_caster_name_font_size, 3, 28, 1);
    self.spell_interrupted_icon_caster_name_font_size:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SIZE']);
    self.spell_interrupted_icon_caster_name_font_size:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SIZE'], self.Tabs[3]);
    self.spell_interrupted_icon_caster_name_font_size.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_flag = E.CreateDropdown('plain', self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_font_flag:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_size, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_caster_name_font_flag:SetSize(160, 20);
    self.spell_interrupted_icon_caster_name_font_flag:SetList(O.Lists.font_flags_localized);
    self.spell_interrupted_icon_caster_name_font_flag:SetValue(O.db.spell_interrupted_icon_caster_name_font_flag);
    self.spell_interrupted_icon_caster_name_font_flag:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_FLAG']);
    self.spell_interrupted_icon_caster_name_font_flag:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_FLAG'], self.Tabs[3]);
    self.spell_interrupted_icon_caster_name_font_flag.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_shadow = E.CreateCheckButton(self.TabsFrames['SpellInterruptedTab'].Content);
    self.spell_interrupted_icon_caster_name_font_shadow:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_flag, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_caster_name_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.spell_interrupted_icon_caster_name_font_shadow:SetChecked(O.db.spell_interrupted_icon_caster_name_font_shadow);
    self.spell_interrupted_icon_caster_name_font_shadow:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SHADOW']);
    self.spell_interrupted_icon_caster_name_font_shadow:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SHADOW'], self.Tabs[3]);
    self.spell_interrupted_icon_caster_name_font_shadow.Callback = function(self)
        O.db.spell_interrupted_icon_caster_name_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.SpellInterruptedIconCasterNameFontOptions = E.CreatePopOptions(self.TabsFrames['SpellInterruptedTab'].Content);
    self.SpellInterruptedIconCasterNameFontOptions:SetH(60);
    self.SpellInterruptedIconCasterNameFontOptions:Add(self.spell_interrupted_icon_caster_name_font_value):SetPosition('TOPLEFT', self.SpellInterruptedIconCasterNameFontOptions, 'TOPLEFT', 8, -20);
    self.SpellInterruptedIconCasterNameFontOptions:Add(self.spell_interrupted_icon_caster_name_font_size):SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_value, 'RIGHT', 12, 0);
    self.SpellInterruptedIconCasterNameFontOptions:Add(self.spell_interrupted_icon_caster_name_font_flag):SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_size, 'RIGHT', 12, 0);
    self.SpellInterruptedIconCasterNameFontOptions:Add(self.spell_interrupted_icon_caster_name_font_shadow):SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_flag, 'RIGHT', 12, 0);
    self.SpellInterruptedIconCasterNameFontOptions.OpenButton:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_show.Label, 'RIGHT', 16, 0);
    self.SpellInterruptedIconCasterNameFontOptions.OpenButton:SetLabel(L['FONT_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['SpellInterruptedTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.spell_interrupted_icon_caster_name_show, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Healers Marks Tab ---------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    local PVPHeader = E.CreateHeader(self.TabsFrames['HealersMarksTab'].Content, L['OPTIONS_PVP_HEALERS_HEADER']);
    PVPHeader:SetPosition('TOPLEFT', self.TabsFrames['HealersMarksTab'].Content, 'TOPLEFT', 0, -2);
    PVPHeader:SetW(self:GetWidth());

    self.pvp_healers_enabled = E.CreateCheckButton(self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_enabled:SetPosition('TOPLEFT', PVPHeader, 'BOTTOMLEFT', 0, -4);
    self.pvp_healers_enabled:SetLabel(L['OPTIONS_PVP_HEALERS_ENABLED']);
    self.pvp_healers_enabled:SetTooltip(L['OPTIONS_PVP_HEALERS_ENABLED_TOOLTIP']);
    self.pvp_healers_enabled:AddToSearch(button, L['OPTIONS_PVP_HEALERS_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.pvp_healers_enabled:SetChecked(O.db.pvp_healers_enabled);
    self.pvp_healers_enabled.Callback = function(self)
        O.db.pvp_healers_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.pvp_healers_sound = E.CreateCheckButton(self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_sound:SetPosition('LEFT', self.pvp_healers_enabled.Label, 'RIGHT', 12, 0);
    self.pvp_healers_sound:SetLabel(L['OPTIONS_PVP_HEALERS_SOUND']);
    self.pvp_healers_sound:SetTooltip(L['OPTIONS_PVP_HEALERS_SOUND_TOOLTIP']);
    self.pvp_healers_sound:AddToSearch(button, L['OPTIONS_PVP_HEALERS_SOUND_TOOLTIP'], self.Tabs[4]);
    self.pvp_healers_sound:SetChecked(O.db.pvp_healers_sound);
    self.pvp_healers_sound.Callback = function(self)
        O.db.pvp_healers_sound = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_scale = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_scale:SetPosition('TOPLEFT', self.pvp_healers_enabled, 'BOTTOMLEFT', 0, -8);
    self.pvp_healers_icon_scale:SetValues(O.db.pvp_healers_icon_scale, 0.25, 4, 0.05);
    self.pvp_healers_icon_scale:SetLabel(L['SCALE']);
    self.pvp_healers_icon_scale:SetLabelPosition('LEFT');
    self.pvp_healers_icon_scale:SetTooltip(L['OPTIONS_PVP_HEALERS_SCALE_TOOLTIP']);
    self.pvp_healers_icon_scale:AddToSearch(button, L['OPTIONS_PVP_HEALERS_SCALE_TOOLTIP'], self.Tabs[4]);
    self.pvp_healers_icon_scale.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_point = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_point:SetSize(120, 20);
    self.pvp_healers_icon_point:SetList(O.Lists.frame_points_localized);
    self.pvp_healers_icon_point:SetValue(O.db.pvp_healers_icon_point);
    self.pvp_healers_icon_point:SetLabel(L['POSITION']);
    self.pvp_healers_icon_point:SetTooltip(L['OPTIONS_PVP_HEALERS_POINT_TOOLTIP']);
    self.pvp_healers_icon_point.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_relative_point = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_relative_point:SetSize(120, 20);
    self.pvp_healers_icon_relative_point:SetList(O.Lists.frame_points_localized);
    self.pvp_healers_icon_relative_point:SetValue(O.db.pvp_healers_icon_relative_point);
    self.pvp_healers_icon_relative_point:SetTooltip(L['OPTIONS_PVP_HEALERS_RELATIVE_POINT_TOOLTIP']);
    self.pvp_healers_icon_relative_point.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_offset_x = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_offset_x:SetSize(120, 18);
    self.pvp_healers_icon_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.pvp_healers_icon_offset_x:SetTooltip(L['OPTIONS_PVP_HEALERS_OFFSET_X_TOOLTIP']);
    self.pvp_healers_icon_offset_x:SetValues(O.db.pvp_healers_icon_offset_x, -200, 200, 1);
    self.pvp_healers_icon_offset_x.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_offset_y = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_offset_y:SetSize(120, 18);
    self.pvp_healers_icon_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.pvp_healers_icon_offset_y:SetTooltip(L['OPTIONS_PVP_HEALERS_OFFSET_Y_TOOLTIP']);
    self.pvp_healers_icon_offset_y:SetValues(O.db.pvp_healers_icon_offset_y, -200, 200, 1);
    self.pvp_healers_icon_offset_y.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pvp_healers_icon_strata = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pvp_healers_icon_strata:SetSize(160, 20);
    self.pvp_healers_icon_strata:SetList(O.Lists.frame_strata);
    self.pvp_healers_icon_strata:SetValue(O.db.pvp_healers_icon_strata);
    self.pvp_healers_icon_strata:SetLabel(L['FRAME_STRATA']);
    self.pvp_healers_icon_strata:SetTooltip(L['OPTIONS_PVP_HEALERS_ICON_STRATA_TOOLTIP']);
    self.pvp_healers_icon_strata.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_strata = tonumber(value);
        Stripes:UpdateAll();
    end

    self.PvPHealersIconPositionOptions = E.CreatePopOptions(self.TabsFrames['HealersMarksTab'].Content);
    self.PvPHealersIconPositionOptions:SetH(120);
    self.PvPHealersIconPositionOptions:Add(self.pvp_healers_icon_point):SetPosition('TOPLEFT', self.PvPHealersIconPositionOptions, 'TOPLEFT', 12, -30);
    self.PvPHealersIconPositionOptions:Add(self.pvp_healers_icon_relative_point):SetPosition('LEFT', self.pvp_healers_icon_point, 'RIGHT', 12, 0);
    self.PvPHealersIconPositionOptions:Add(self.pvp_healers_icon_offset_x):SetPosition('LEFT', self.pvp_healers_icon_relative_point, 'RIGHT', 12, 0);
    self.PvPHealersIconPositionOptions:Add(self.pvp_healers_icon_offset_y):SetPosition('LEFT', self.pvp_healers_icon_offset_x, 'RIGHT', 12, 0);
    self.PvPHealersIconPositionOptions:Add(self.pvp_healers_icon_strata):SetPosition('TOPLEFT', self.pvp_healers_icon_point, 'BOTTOMLEFT', 0, -16);
    self.PvPHealersIconPositionOptions.OpenButton:SetPosition('LEFT', self.pvp_healers_icon_scale, 'RIGHT', 16, 0);
    self.PvPHealersIconPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    local PVEHeader = E.CreateHeader(self.TabsFrames['HealersMarksTab'].Content, L['OPTIONS_PVE_HEALERS_HEADER']);
    PVEHeader:SetPosition('TOPLEFT', self.pvp_healers_icon_scale, 'BOTTOMLEFT', 0 - self.pvp_healers_icon_scale.Text:GetStringWidth() - 6, -8);
    PVEHeader:SetW(self:GetWidth());

    self.pve_healers_enabled = E.CreateCheckButton(self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_enabled:SetPosition('TOPLEFT', PVEHeader, 'BOTTOMLEFT', 0, -8);
    self.pve_healers_enabled:SetLabel(L['OPTIONS_PVE_HEALERS_ENABLED']);
    self.pve_healers_enabled:SetTooltip(L['OPTIONS_PVE_HEALERS_ENABLED_TOOLTIP']);
    self.pve_healers_enabled:AddToSearch(button, L['OPTIONS_PVE_HEALERS_ENABLED_TOOLTIP'], self.Tabs[4]);
    self.pve_healers_enabled:SetChecked(O.db.pve_healers_enabled);
    self.pve_healers_enabled.Callback = function(self)
        O.db.pve_healers_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.pve_healers_sound = E.CreateCheckButton(self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_sound:SetPosition('LEFT', self.pve_healers_enabled.Label, 'RIGHT', 12, 0);
    self.pve_healers_sound:SetLabel(L['OPTIONS_PVE_HEALERS_SOUND']);
    self.pve_healers_sound:SetTooltip(L['OPTIONS_PVE_HEALERS_SOUND_TOOLTIP']);
    self.pve_healers_sound:AddToSearch(button, L['OPTIONS_PVE_HEALERS_SOUND_TOOLTIP'], self.Tabs[4]);
    self.pve_healers_sound:SetChecked(O.db.pve_healers_sound);
    self.pve_healers_sound.Callback = function(self)
        O.db.pve_healers_sound = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_scale = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_scale:SetPosition('TOPLEFT', self.pve_healers_enabled, 'BOTTOMLEFT', 0, -8);
    self.pve_healers_icon_scale:SetValues(O.db.pve_healers_icon_scale, 0.25, 4, 0.05);
    self.pve_healers_icon_scale:SetLabel(L['SCALE']);
    self.pve_healers_icon_scale:SetLabelPosition('LEFT');
    self.pve_healers_icon_scale:SetTooltip(L['OPTIONS_PVE_HEALERS_SCALE_TOOLTIP']);
    self.pve_healers_icon_scale:AddToSearch(button, L['OPTIONS_PVE_HEALERS_SCALE_TOOLTIP'], self.Tabs[4]);
    self.pve_healers_icon_scale.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_point = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_point:SetSize(120, 20);
    self.pve_healers_icon_point:SetList(O.Lists.frame_points_localized);
    self.pve_healers_icon_point:SetValue(O.db.pve_healers_icon_point);
    self.pve_healers_icon_point:SetLabel(L['POSITION']);
    self.pve_healers_icon_point:SetTooltip(L['OPTIONS_PVE_HEALERS_POINT_TOOLTIP']);
    self.pve_healers_icon_point.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_relative_point = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_relative_point:SetSize(120, 20);
    self.pve_healers_icon_relative_point:SetList(O.Lists.frame_points_localized);
    self.pve_healers_icon_relative_point:SetValue(O.db.pve_healers_icon_relative_point);
    self.pve_healers_icon_relative_point:SetTooltip(L['OPTIONS_PVE_HEALERS_RELATIVE_POINT_TOOLTIP']);
    self.pve_healers_icon_relative_point.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_offset_x = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_offset_x:SetSize(120, 18);
    self.pve_healers_icon_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.pve_healers_icon_offset_x:SetTooltip(L['OPTIONS_PVE_HEALERS_OFFSET_X_TOOLTIP']);
    self.pve_healers_icon_offset_x:SetValues(O.db.pve_healers_icon_offset_x, -200, 200, 1);
    self.pve_healers_icon_offset_x.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_offset_y = E.CreateSlider(self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_offset_y:SetSize(120, 18);
    self.pve_healers_icon_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.pve_healers_icon_offset_y:SetTooltip(L['OPTIONS_PVE_HEALERS_OFFSET_Y_TOOLTIP']);
    self.pve_healers_icon_offset_y:SetValues(O.db.pve_healers_icon_offset_y, -200, 200, 1);
    self.pve_healers_icon_offset_y.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.pve_healers_icon_strata = E.CreateDropdown('plain', self.TabsFrames['HealersMarksTab'].Content);
    self.pve_healers_icon_strata:SetSize(160, 20);
    self.pve_healers_icon_strata:SetList(O.Lists.frame_strata);
    self.pve_healers_icon_strata:SetValue(O.db.pve_healers_icon_strata);
    self.pve_healers_icon_strata:SetLabel(L['FRAME_STRATA']);
    self.pve_healers_icon_strata:SetTooltip(L['OPTIONS_PVE_HEALERS_ICON_STRATA_TOOLTIP']);
    self.pve_healers_icon_strata.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_strata = tonumber(value);
        Stripes:UpdateAll();
    end

    self.PvEHealersIconPositionOptions = E.CreatePopOptions(self.TabsFrames['HealersMarksTab'].Content);
    self.PvEHealersIconPositionOptions:SetH(120);
    self.PvEHealersIconPositionOptions:Add(self.pve_healers_icon_point):SetPosition('TOPLEFT', self.PvEHealersIconPositionOptions, 'TOPLEFT', 12, -30);
    self.PvEHealersIconPositionOptions:Add(self.pve_healers_icon_relative_point):SetPosition('LEFT', self.pve_healers_icon_point, 'RIGHT', 12, 0);
    self.PvEHealersIconPositionOptions:Add(self.pve_healers_icon_offset_x):SetPosition('LEFT', self.pve_healers_icon_relative_point, 'RIGHT', 12, 0);
    self.PvEHealersIconPositionOptions:Add(self.pve_healers_icon_offset_y):SetPosition('LEFT', self.pve_healers_icon_offset_x, 'RIGHT', 12, 0);
    self.PvEHealersIconPositionOptions:Add(self.pve_healers_icon_strata):SetPosition('TOPLEFT', self.pve_healers_icon_point, 'BOTTOMLEFT', 0, -16);
    self.PvEHealersIconPositionOptions.OpenButton:SetPosition('LEFT', self.pve_healers_icon_scale, 'RIGHT', 16, 0);
    self.PvEHealersIconPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);
end