local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Visibility');

O.frame.Left.Visibility, O.frame.Right.Visibility = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_VISIBILITY']), 'visibility', 3);
local button = O.frame.Left.Visibility;
local panel = O.frame.Right.Visibility;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_VISIBILITY_TAB_COMMON']),
    },
    [2] = {
        name  = 'EnemyTab',
        title = string.upper(L['OPTIONS_VISIBILITY_TAB_ENEMY']),
    },
    [3] = {
        name  = 'FriendlyTab',
        title = string.upper(L['OPTIONS_VISIBILITY_TAB_FRIENDLY']),
    },
    [4] = {
        name  = 'SelfTab',
        title = string.upper(L['OPTIONS_VISIBILITY_TAB_SELF']),
    },
};

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.motion = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.motion:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.motion:SetSize(170, 20);
    self.motion:SetList(O.Lists.motion);
    self.motion:SetValue(O.db.motion);
    self.motion:SetLabel(L['OPTIONS_VISIBILITY_MOTION']);
    self.motion:SetTooltip(L['OPTIONS_VISIBILITY_MOTION_TOOLTIP']);
    self.motion:AddToSearch(button, L['OPTIONS_VISIBILITY_MOTION_TOOLTIP'], self.Tabs[1]);
    self.motion.OnValueChangedCallback = function(_, value)
        O.db.motion = tonumber(value);

        C_CVar.SetCVar('nameplateMotion', O.db.motion - 1);
    end

    self.motion_speed = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.motion_speed:SetPosition('LEFT', self.motion, 'RIGHT', 12, 0);
    self.motion_speed:SetValues(O.db.motion_speed, 0, 0.5, 0.01);
    self.motion_speed:SetTooltip(L['OPTIONS_VISIBILITY_MOTION_SPEED_TOOLTIP']);
    self.motion_speed:AddToSearch(button, L['OPTIONS_VISIBILITY_MOTION_SPEED_TOOLTIP'], self.Tabs[1]);
    self.motion_speed.OnValueChangedCallback = function(_, value)
        O.db.motion_speed = tonumber(value);

        C_CVar.SetCVar('nameplateMotionSpeed', O.db.motion_speed);
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.motion, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.show_always_openworld = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.show_always_openworld:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.show_always_openworld:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ALWAYS_OPENWORLD']);
    self.show_always_openworld:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ALWAYS_OPENWORLD_TOOLTIP']);
    self.show_always_openworld:AddToSearch(button, nil, self.Tabs[1]);
    self.show_always_openworld:SetChecked(O.db.show_always_openworld);
    self.show_always_openworld.Callback = function(self)
        O.db.show_always_openworld = self:GetChecked();

        if not U.IsInInstance() then
            C_CVar.SetCVar('nameplateShowAll', O.db.show_always_openworld and 1 or 0);
        end

        Stripes:UpdateAll();
    end

    self.show_always_instance = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.show_always_instance:SetPosition('LEFT', self.show_always_openworld.Label, 'RIGHT', 12, 0);
    self.show_always_instance:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ALWAYS_INSTANCE']);
    self.show_always_instance:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ALWAYS_INSTANCE_TOOLTIP']);
    self.show_always_instance:AddToSearch(button, nil, self.Tabs[1]);
    self.show_always_instance:SetChecked(O.db.show_always_instance);
    self.show_always_instance.Callback = function(self)
        O.db.show_always_instance = self:GetChecked();

        if U.IsInInstance() then
            C_CVar.SetCVar('nameplateShowAll', O.db.show_always_instance and 1 or 0);
        end

        Stripes:UpdateAll();
    end

    self.max_distance_openworld = E.CreateEditBox(self.TabsFrames['CommonTab'].Content);
    self.max_distance_openworld:SetPosition('TOPLEFT', self.show_always_openworld, 'BOTTOMLEFT', 5, -8);
    self.max_distance_openworld:SetLabel(L['OPTIONS_VISIBILITY_MAX_DISTANCE_OPENWORLD']);
    self.max_distance_openworld:SetTooltip(L['OPTIONS_VISIBILITY_MAX_DISTANCE_OPENWORLD_TOOLTIP']);
    self.max_distance_openworld:AddToSearch(button, L['OPTIONS_VISIBILITY_MAX_DISTANCE_OPENWORLD_TOOLTIP'], self.Tabs[1]);
    self.max_distance_openworld:SetText(O.db.max_distance_openworld);
    self.max_distance_openworld:SetEnabled(false);
    self.max_distance_openworld:SetJustifyH('CENTER');
    self.max_distance_openworld.Callback = function(self)
        local number = tonumber(self:GetText());

        if not number then
            number = O.DefaultValues.max_distance_openworld;
        else
            number = math.min(number, 100);
            number = math.max(number, 1);
        end

        O.db.max_distance_openworld = number;
        self:SetText(number);

        if not U.IsInInstance() then
            C_CVar.SetCVar('nameplateMaxDistance', number);
        end
    end

    self.max_distance_instance = E.CreateEditBox(self.TabsFrames['CommonTab'].Content);
    self.max_distance_instance:SetPosition('TOPLEFT', self.show_always_instance, 'BOTTOMLEFT', 5, -8);
    self.max_distance_instance:SetLabel(L['OPTIONS_VISIBILITY_MAX_DISTANCE_INSTANCE']);
    self.max_distance_instance:SetTooltip(L['OPTIONS_VISIBILITY_MAX_DISTANCE_INSTANCE_TOOLTIP']);
    self.max_distance_instance:AddToSearch(button, L['OPTIONS_VISIBILITY_MAX_DISTANCE_INSTANCE_TOOLTIP'], self.Tabs[1]);
    self.max_distance_instance:SetText(O.db.max_distance_instance);
    self.max_distance_instance:SetEnabled(false);
    self.max_distance_instance:SetJustifyH('CENTER');
    self.max_distance_instance.Callback = function(self)
        local number = tonumber(self:GetText());

        if not number then
            number = O.DefaultValues.max_distance_instance;
        else
            number = math.min(number, 100);
            number = math.max(number, 1);
        end

        O.db.max_distance_instance = number;
        self:SetText(number);

        if U.IsInInstance() then
            C_CVar.SetCVar('nameplateMaxDistance', number);
        end
    end

    local AlphaHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_VISIBILITY_ALPHA_HEADER']);
    AlphaHeader:SetPosition('TOPLEFT', self.max_distance_openworld, 'BOTTOMLEFT', -5, -4);
    AlphaHeader:SetW(self:GetWidth());

    self.selected_alpha = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.selected_alpha:SetPosition('TOPLEFT', AlphaHeader, 'BOTTOMLEFT', 0, -20);
    self.selected_alpha:SetW(137);
    self.selected_alpha:SetLabel(L['OPTIONS_VISIBILITY_SELECTED_ALPHA']);
    self.selected_alpha:SetTooltip(L['OPTIONS_VISIBILITY_SELECTED_ALPHA_TOOLTIP']);
    self.selected_alpha:AddToSearch(button, L['OPTIONS_VISIBILITY_SELECTED_ALPHA_TOOLTIP'], self.Tabs[1]);
    self.selected_alpha:SetValues(O.db.selected_alpha, 0.1, 1, 0.05);
    self.selected_alpha.OnValueChangedCallback = function(_, value)
        O.db.selected_alpha = tonumber(value);

        C_CVar.SetCVar('nameplateSelectedAlpha', O.db.selected_alpha);
    end

    self.occluded_alpha_mult = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.occluded_alpha_mult:SetPosition('TOPLEFT', self.selected_alpha, 'BOTTOMLEFT', 0, -28);
    self.occluded_alpha_mult:SetW(137);
    self.occluded_alpha_mult:SetLabel(L['OPTIONS_VISIBILITY_OCCLUDED_ALPHA_MULT']);
    self.occluded_alpha_mult:SetTooltip(L['OPTIONS_VISIBILITY_OCCLUDED_ALPHA_MULT_TOOLTIP']);
    self.occluded_alpha_mult:AddToSearch(button, L['OPTIONS_VISIBILITY_OCCLUDED_ALPHA_MULT_TOOLTIP'], self.Tabs[1]);
    self.occluded_alpha_mult:SetValues(O.db.occluded_alpha_mult, 0.1, 1, 0.05);
    self.occluded_alpha_mult.OnValueChangedCallback = function(_, value)
        O.db.occluded_alpha_mult = tonumber(value);

        C_CVar.SetCVar('nameplateOccludedAlphaMult', O.db.occluded_alpha_mult);
    end

    self.max_alpha = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.max_alpha:SetPosition('LEFT', self.selected_alpha, 'RIGHT', 12, 0);
    self.max_alpha:SetW(137);
    self.max_alpha:SetLabel(L['OPTIONS_VISIBILITY_MAX_ALPHA']);
    self.max_alpha:SetTooltip(L['OPTIONS_VISIBILITY_MAX_ALPHA_TOOLTIP']);
    self.max_alpha:AddToSearch(button, L['OPTIONS_VISIBILITY_MAX_ALPHA_TOOLTIP'], self.Tabs[1]);
    self.max_alpha:SetValues(O.db.max_alpha, 0.1, 1, 0.05);
    self.max_alpha.OnValueChangedCallback = function(_, value)
        O.db.max_alpha = tonumber(value);

        C_CVar.SetCVar('nameplateMaxAlpha', O.db.max_alpha);
    end

    self.max_alpha_distance = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.max_alpha_distance:SetPosition('TOPLEFT', self.max_alpha, 'BOTTOMLEFT', 0, -28);
    self.max_alpha_distance:SetW(137);
    self.max_alpha_distance:SetLabel(L['OPTIONS_VISIBILITY_MAX_ALPHA_DISTANCE']);
    self.max_alpha_distance:SetTooltip(L['OPTIONS_VISIBILITY_MAX_ALPHA_DISTANCE_TOOLTIP']);
    self.max_alpha_distance:AddToSearch(button, L['OPTIONS_VISIBILITY_MAX_ALPHA_DISTANCE_TOOLTIP'], self.Tabs[1]);
    self.max_alpha_distance:SetValues(O.db.max_alpha_distance, 8, 60, 1);
    self.max_alpha_distance.OnValueChangedCallback = function(_, value)
        O.db.max_alpha_distance = tonumber(value);

        C_CVar.SetCVar('nameplateMaxAlphaDistance', O.db.max_alpha_distance);
    end

    self.min_alpha = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.min_alpha:SetPosition('LEFT', self.max_alpha, 'RIGHT', 12, 0);
    self.min_alpha:SetW(137);
    self.min_alpha:SetLabel(L['OPTIONS_VISIBILITY_MIN_ALPHA']);
    self.min_alpha:SetTooltip(L['OPTIONS_VISIBILITY_MIN_ALPHA_TOOLTIP']);
    self.min_alpha:AddToSearch(button, L['OPTIONS_VISIBILITY_MIN_ALPHA_TOOLTIP'], self.Tabs[1]);
    self.min_alpha:SetValues(O.db.min_alpha, 0.1, 1, 0.05);
    self.min_alpha.OnValueChangedCallback = function(_, value)
        O.db.min_alpha = tonumber(value);

        C_CVar.SetCVar('nameplateMinAlpha', O.db.min_alpha);
    end

    self.min_alpha_distance = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.min_alpha_distance:SetPosition('TOPLEFT', self.min_alpha, 'BOTTOMLEFT', 0, -28);
    self.min_alpha_distance:SetW(137);
    self.min_alpha_distance:SetLabel(L['OPTIONS_VISIBILITY_MIN_ALPHA_DISTANCE']);
    self.min_alpha_distance:SetTooltip(L['OPTIONS_VISIBILITY_MIN_ALPHA_DISTANCE_TOOLTIP']);
    self.min_alpha_distance:AddToSearch(button, L['OPTIONS_VISIBILITY_MIN_ALPHA_DISTANCE_TOOLTIP'], self.Tabs[1]);
    self.min_alpha_distance:SetValues(O.db.min_alpha_distance, 8, 60, 1);
    self.min_alpha_distance.OnValueChangedCallback = function(_, value)
        O.db.min_alpha_distance = tonumber(value);

        C_CVar.SetCVar('nameplateMinAlphaDistance', O.db.min_alpha_distance);
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.occluded_alpha_mult, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.show_personal_resource_ontarget = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.show_personal_resource_ontarget:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -12);
    self.show_personal_resource_ontarget:SetLabel(L['OPTIONS_VISIBILITY_SHOW_PERSONAL_RESOURCE_ONTARGET']);
    self.show_personal_resource_ontarget:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_PERSONAL_RESOURCE_ONTARGET_TOOLTIP']);
    self.show_personal_resource_ontarget:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_PERSONAL_RESOURCE_ONTARGET_TOOLTIP'], self.Tabs[1]);
    self.show_personal_resource_ontarget:SetChecked(O.db.show_personal_resource_ontarget);
    self.show_personal_resource_ontarget.Callback = function(self)
        O.db.show_personal_resource_ontarget = self:GetChecked();

        C_CVar.SetCVar('nameplateResourceOnTarget', O.db.show_personal_resource_ontarget and 1 or 0);

        Stripes:UpdateAll();
    end

    self.class_bar_alpha = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.class_bar_alpha:SetPosition('LEFT', self.show_personal_resource_ontarget.Label, 'RIGHT', 12, 0);
    self.class_bar_alpha:SetW(100);
    self.class_bar_alpha:SetValues(O.db.class_bar_alpha, 0, 1, 0.05);
    self.class_bar_alpha:SetLabel(L['ALPHA']);
    self.class_bar_alpha:SetTooltip(L['OPTIONS_CLASS_BAR_ALPHA_TOOLTIP']);
    self.class_bar_alpha:AddToSearch(button, L['OPTIONS_CLASS_BAR_ALPHA_TOOLTIP'], self.Tabs[1]);
    self.class_bar_alpha.OnValueChangedCallback = function(_, value)
        O.db.class_bar_alpha = tonumber(value);
        Stripes:UpdateAll();
    end

    self.class_bar_scale = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.class_bar_scale:SetPosition('LEFT', self.class_bar_alpha, 'RIGHT', 12, 0);
    self.class_bar_scale:SetW(100);
    self.class_bar_scale:SetValues(O.db.class_bar_scale, 0.25, 3, 0.05);
    self.class_bar_scale:SetLabel(L['SCALE']);
    self.class_bar_scale:SetTooltip(L['OPTIONS_CLASS_BAR_SCALE_TOOLTIP']);
    self.class_bar_scale:AddToSearch(button, L['OPTIONS_CLASS_BAR_SCALE_TOOLTIP'], self.Tabs[1]);
    self.class_bar_scale.OnValueChangedCallback = function(_, value)
        O.db.class_bar_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.class_bar_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.class_bar_point:SetSize(120, 20);
    self.class_bar_point:SetList(O.Lists.frame_points_localized);
    self.class_bar_point:SetValue(O.db.class_bar_point);
    self.class_bar_point:SetLabel(L['POSITION']);
    self.class_bar_point:SetTooltip(L['OPTIONS_CLASS_BAR_POINT_TOOLTIP']);
    self.class_bar_point.OnValueChangedCallback = function(_, value)
        O.db.class_bar_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.class_bar_relative_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.class_bar_relative_point:SetSize(120, 20);
    self.class_bar_relative_point:SetList(O.Lists.frame_points_localized);
    self.class_bar_relative_point:SetValue(O.db.class_bar_relative_point);
    self.class_bar_relative_point:SetTooltip(L['OPTIONS_CLASS_BAR_RELATIVE_POINT_TOOLTIP']);
    self.class_bar_relative_point.OnValueChangedCallback = function(_, value)
        O.db.class_bar_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.class_bar_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.class_bar_offset_x:SetSize(120, 18);
    self.class_bar_offset_x:SetValues(O.db.class_bar_offset_x, -50, 50, 1);
    self.class_bar_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.class_bar_offset_x:SetTooltip(L['OPTIONS_CLASS_BAR_OFFSET_X_TOOLTIP']);
    self.class_bar_offset_x.OnValueChangedCallback = function(_, value)
        O.db.class_bar_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.class_bar_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.class_bar_offset_y:SetSize(120, 18);
    self.class_bar_offset_y:SetValues(O.db.class_bar_offset_y, -50, 50, 1);
    self.class_bar_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.class_bar_offset_y:SetTooltip(L['OPTIONS_CLASS_BAR_OFFSET_Y_TOOLTIP']);
    self.class_bar_offset_y.OnValueChangedCallback = function(_, value)
        O.db.class_bar_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.ClassBarPositionOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.ClassBarPositionOptions:SetH(80);
    self.ClassBarPositionOptions:Add(self.class_bar_point):SetPosition('TOPLEFT', self.ClassBarPositionOptions, 'TOPLEFT', 12, -32);
    self.ClassBarPositionOptions:Add(self.class_bar_relative_point):SetPosition('LEFT', self.class_bar_point, 'RIGHT', 12, 0);
    self.ClassBarPositionOptions:Add(self.class_bar_offset_x):SetPosition('LEFT', self.class_bar_relative_point, 'RIGHT', 12, 0);
    self.ClassBarPositionOptions:Add(self.class_bar_offset_y):SetPosition('LEFT', self.class_bar_offset_x, 'RIGHT', 12, 0);
    self.ClassBarPositionOptions.OpenButton:SetPosition('LEFT', self.class_bar_scale, 'RIGHT', 16, 0);
    self.ClassBarPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.show_personal_resource_ontarget, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.classification_indicator_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -12);
    self.classification_indicator_enabled:SetLabel(L['OPTIONS_CLASSIFICATION_INDICATOR_ENABLED']);
    self.classification_indicator_enabled:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_ENABLED_TOOLTIP']);
    self.classification_indicator_enabled:AddToSearch(button, L['OPTIONS_CLASSIFICATION_INDICATOR_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.classification_indicator_enabled:SetChecked(O.db.classification_indicator_enabled);
    self.classification_indicator_enabled.Callback = function(self)
        O.db.classification_indicator_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.classification_indicator_star = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_star:SetPosition('LEFT', self.classification_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.classification_indicator_star:SetLabel(L['OPTIONS_CLASSIFICATION_INDICATOR_STAR']);
    self.classification_indicator_star:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_STAR_TOOLTIP']);
    self.classification_indicator_star:AddToSearch(button, L['OPTIONS_CLASSIFICATION_INDICATOR_STAR_TOOLTIP'], self.Tabs[1]);
    self.classification_indicator_star:SetChecked(O.db.classification_indicator_star);
    self.classification_indicator_star.Callback = function(self)
        O.db.classification_indicator_star = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.classification_indicator_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_size:SetPosition('LEFT', self.classification_indicator_star.Label, 'RIGHT', 16, 0);
    self.classification_indicator_size:SetValues(O.db.classification_indicator_size, 2, 40, 1);
    self.classification_indicator_size:SetLabel(L['OPTIONS_CLASSIFICATION_INDICATOR_SIZE']);
    self.classification_indicator_size:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_SIZE_TOOLTIP']);
    self.classification_indicator_size:AddToSearch(button, L['OPTIONS_CLASSIFICATION_INDICATOR_SIZE_TOOLTIP'], self.Tabs[1]);
    self.classification_indicator_size.OnValueChangedCallback = function(_, value)
        O.db.classification_indicator_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.classification_indicator_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_point:SetSize(120, 20);
    self.classification_indicator_point:SetList(O.Lists.frame_points_localized);
    self.classification_indicator_point:SetValue(O.db.classification_indicator_point);
    self.classification_indicator_point:SetLabel(L['POSITION']);
    self.classification_indicator_point:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_POINT_TOOLTIP']);
    self.classification_indicator_point.OnValueChangedCallback = function(_, value)
        O.db.classification_indicator_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.classification_indicator_relative_point = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_relative_point:SetSize(120, 20);
    self.classification_indicator_relative_point:SetList(O.Lists.frame_points_localized);
    self.classification_indicator_relative_point:SetValue(O.db.classification_indicator_relative_point);
    self.classification_indicator_relative_point:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_RELATIVE_POINT_TOOLTIP']);
    self.classification_indicator_relative_point.OnValueChangedCallback = function(_, value)
        O.db.classification_indicator_relative_point = tonumber(value);
        Stripes:UpdateAll();
    end

    self.classification_indicator_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_offset_x:SetSize(120, 18);
    self.classification_indicator_offset_x:SetValues(O.db.classification_indicator_offset_x, -50, 50, 1);
    self.classification_indicator_offset_x:SetLabel(L['OFFSET_X_SHORT']);
    self.classification_indicator_offset_x:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_OFFSET_X_TOOLTIP']);
    self.classification_indicator_offset_x.OnValueChangedCallback = function(_, value)
        O.db.classification_indicator_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.classification_indicator_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.classification_indicator_offset_y:SetSize(120, 18);
    self.classification_indicator_offset_y:SetValues(O.db.classification_indicator_offset_y, -50, 50, 1);
    self.classification_indicator_offset_y:SetLabel(L['OFFSET_Y_SHORT']);
    self.classification_indicator_offset_y:SetTooltip(L['OPTIONS_CLASSIFICATION_INDICATOR_OFFSET_Y_TOOLTIP']);
    self.classification_indicator_offset_y.OnValueChangedCallback = function(_, value)
        O.db.classification_indicator_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.ClassificationIndicatorPositionOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.ClassificationIndicatorPositionOptions:SetH(80);
    self.ClassificationIndicatorPositionOptions:Add(self.classification_indicator_point):SetPosition('TOPLEFT', self.ClassificationIndicatorPositionOptions, 'TOPLEFT', 12, -32);
    self.ClassificationIndicatorPositionOptions:Add(self.classification_indicator_relative_point):SetPosition('LEFT', self.classification_indicator_point, 'RIGHT', 12, 0);
    self.ClassificationIndicatorPositionOptions:Add(self.classification_indicator_offset_x):SetPosition('LEFT', self.classification_indicator_relative_point, 'RIGHT', 12, 0);
    self.ClassificationIndicatorPositionOptions:Add(self.classification_indicator_offset_y):SetPosition('LEFT', self.classification_indicator_offset_x, 'RIGHT', 12, 0);
    self.ClassificationIndicatorPositionOptions.OpenButton:SetPosition('LEFT', self.classification_indicator_size, 'RIGHT', 16, 0);
    self.ClassificationIndicatorPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.classification_indicator_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.hide_non_casting_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.hide_non_casting_enabled:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -8);
    self.hide_non_casting_enabled:SetLabel(L['OPTIONS_VISIBILITY_HIDE_NON_CAST_ENABLED']);
    self.hide_non_casting_enabled:SetTooltip(L['OPTIONS_VISIBILITY_HIDE_NON_CAST_ENABLED_TOOLTIP']);
    self.hide_non_casting_enabled:AddToSearch(button, nil, self.Tabs[1]);
    self.hide_non_casting_enabled:SetChecked(O.db.hide_non_casting_enabled);
    self.hide_non_casting_enabled.Callback = function(self)
        O.db.hide_non_casting_enabled = self:GetChecked();

        panel.hide_non_casting_modifier:SetEnabled(O.db.hide_non_casting_enabled);
        panel.hide_non_casting_show_uninterruptible:SetEnabled(O.db.hide_non_casting_enabled);

        Stripes:UpdateAll();
    end

    self.hide_non_casting_modifier = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.hide_non_casting_modifier:SetPosition('LEFT', self.hide_non_casting_enabled.Label, 'RIGHT', 12, 0);
    self.hide_non_casting_modifier:SetSize(110, 20);
    self.hide_non_casting_modifier:SetList(O.Lists.hide_non_casting_modifiers);
    self.hide_non_casting_modifier:SetValue(O.db.hide_non_casting_modifier);
    self.hide_non_casting_modifier:SetTooltip(L['OPTIONS_VISIBILITY_HIDE_NON_CAST_MODIFIER_TOOLTIP']);
    self.hide_non_casting_modifier:AddToSearch(button, L['OPTIONS_VISIBILITY_HIDE_NON_CAST_MODIFIER_TOOLTIP'], self.Tabs[1]);
    self.hide_non_casting_modifier:SetEnabled(O.db.hide_non_casting_enabled);
    self.hide_non_casting_modifier.OnValueChangedCallback = function(_, value)
        O.db.hide_non_casting_modifier = tonumber(value);
        Stripes:UpdateAll();
    end

    self.hide_non_casting_show_uninterruptible = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.hide_non_casting_show_uninterruptible:SetPosition('LEFT', self.hide_non_casting_modifier, 'RIGHT', 12, 0);
    self.hide_non_casting_show_uninterruptible:SetLabel(L['OPTIONS_VISIBILITY_HIDE_NON_CAST_SHOW_UNINTERRUPTIBLE']);
    self.hide_non_casting_show_uninterruptible:SetTooltip(L['OPTIONS_VISIBILITY_HIDE_NON_CAST_SHOW_UNINTERRUPTIBLE_TOOLTIP']);
    self.hide_non_casting_show_uninterruptible:AddToSearch(button, nil, self.Tabs[1]);
    self.hide_non_casting_show_uninterruptible:SetChecked(O.db.hide_non_casting_show_uninterruptible);
    self.hide_non_casting_show_uninterruptible:SetEnabled(O.db.hide_non_casting_enabled);
    self.hide_non_casting_show_uninterruptible.Callback = function(self)
        O.db.hide_non_casting_show_uninterruptible = self:GetChecked();
        Stripes:UpdateAll();
    end

    local RaidTargetIconHeader = E.CreateHeader(self.TabsFrames['CommonTab'].Content, L['OPTIONS_HEADER_RAID_TARGET_ICON']);
    RaidTargetIconHeader:SetPosition('TOPLEFT', self.hide_non_casting_enabled, 'BOTTOMLEFT', 0, -8);
    RaidTargetIconHeader:SetW(self:GetWidth());

    self.raid_target_icon_show = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_show:SetPosition('TOPLEFT', RaidTargetIconHeader, 'BOTTOMLEFT', 0, -12);
    self.raid_target_icon_show:SetLabel(L['OPTIONS_RAID_TARGET_ICON_SHOW']);
    self.raid_target_icon_show:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_SHOW_TOOLTIP']);
    self.raid_target_icon_show:AddToSearch(button, L['OPTIONS_RAID_TARGET_ICON_SHOW_TOOLTIP'], self.Tabs[1]);
    self.raid_target_icon_show:SetChecked(O.db.raid_target_icon_show);
    self.raid_target_icon_show.Callback = function(self)
        O.db.raid_target_icon_show = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.raid_target_icon_scale = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_scale:SetPosition('LEFT', self.raid_target_icon_show.Label, 'RIGHT', 16, 0);
    self.raid_target_icon_scale:SetW(137);
    self.raid_target_icon_scale:SetLabel(L['SCALE']);
    self.raid_target_icon_scale:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_SCALE_TOOLTIP']);
    self.raid_target_icon_scale:AddToSearch(button, L['OPTIONS_RAID_TARGET_ICON_SCALE_TOOLTIP'], self.Tabs[1]);
    self.raid_target_icon_scale:SetValues(O.db.raid_target_icon_scale, 0.1, 2, 0.05);
    self.raid_target_icon_scale.OnValueChangedCallback = function(_, value)
        O.db.raid_target_icon_scale = tonumber(value);
        Stripes:UpdateAll();
    end

    self.raid_target_hpbar_coloring = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.raid_target_hpbar_coloring:SetPosition('TOPLEFT', self.raid_target_icon_show, 'BOTTOMLEFT', 0, -8);
    self.raid_target_hpbar_coloring:SetLabel(L['OPTIONS_RAID_TARGET_HPBAR_COLORING']);
    self.raid_target_hpbar_coloring:SetTooltip(L['OPTIONS_RAID_TARGET_HPBAR_COLORING_TOOLTIP']);
    self.raid_target_hpbar_coloring:AddToSearch(button, L['OPTIONS_RAID_TARGET_HPBAR_COLORING_TOOLTIP'], self.Tabs[1]);
    self.raid_target_hpbar_coloring:SetChecked(O.db.raid_target_hpbar_coloring);
    self.raid_target_hpbar_coloring.Callback = function(self)
        O.db.raid_target_hpbar_coloring = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.raid_target_icon_position = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_position:SetSize(100, 20);
    self.raid_target_icon_position:SetList(O.Lists.raid_target_icon_position);
    self.raid_target_icon_position:SetValue(O.db.raid_target_icon_position);
    self.raid_target_icon_position:SetLabel(L['POSITION']);
    self.raid_target_icon_position:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_POSITION_TOOLTIP']);
    self.raid_target_icon_position.OnValueChangedCallback = function(_, value)
        O.db.raid_target_icon_position = tonumber(value);
        Stripes:UpdateAll();
    end

    self.raid_target_icon_position_offset_x = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_position_offset_x:SetValues(O.db.raid_target_icon_position_offset_x, -50, 50, 1);
    self.raid_target_icon_position_offset_x:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_POSITION_OFFSET_X_TOOLTIP']);
    self.raid_target_icon_position_offset_x.OnValueChangedCallback = function(_, value)
        O.db.raid_target_icon_position_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.raid_target_icon_position_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_position_offset_y:SetValues(O.db.raid_target_icon_position_offset_y, -50, 50, 1);
    self.raid_target_icon_position_offset_y:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_POSITION_OFFSET_Y_TOOLTIP']);
    self.raid_target_icon_position_offset_y.OnValueChangedCallback = function(_, value)
        O.db.raid_target_icon_position_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.raid_target_icon_frame_strata = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.raid_target_icon_frame_strata:SetSize(160, 20);
    self.raid_target_icon_frame_strata:SetList(O.Lists.frame_strata);
    self.raid_target_icon_frame_strata:SetValue(O.db.raid_target_icon_frame_strata);
    self.raid_target_icon_frame_strata:SetLabel(L['FRAME_STRATA']);
    self.raid_target_icon_frame_strata:SetTooltip(L['OPTIONS_RAID_TARGET_ICON_FRAME_STRATA_TOOLTIP']);
    self.raid_target_icon_frame_strata.OnValueChangedCallback = function(_, value)
        O.db.raid_target_icon_frame_strata = tonumber(value);
        Stripes:UpdateAll();
    end

    self.RaidTargetPositionOptions = E.CreatePopOptions(self.TabsFrames['CommonTab'].Content);
    self.RaidTargetPositionOptions:SetH(120);
    self.RaidTargetPositionOptions:Add(self.raid_target_icon_position):SetPosition('TOPLEFT', self.RaidTargetPositionOptions, 'TOPLEFT', 12, -30);
    self.RaidTargetPositionOptions:Add(self.raid_target_icon_position_offset_x):SetPosition('LEFT', self.raid_target_icon_position, 'RIGHT', 12, 0);
    self.RaidTargetPositionOptions:Add(self.raid_target_icon_position_offset_y):SetPosition('LEFT', self.raid_target_icon_position_offset_x, 'RIGHT', 12, 0);
    self.RaidTargetPositionOptions:Add(self.raid_target_icon_frame_strata):SetPosition('TOPLEFT', self.raid_target_icon_position, 'BOTTOMLEFT', 0, -12);
    self.RaidTargetPositionOptions.OpenButton:SetPosition('LEFT', self.raid_target_icon_scale, 'RIGHT', 16, 0);
    self.RaidTargetPositionOptions.OpenButton:SetLabel(L['POSITION_OPTIONS']);

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Enemy Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.show_enemy = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy:SetPosition('TOPLEFT', self.TabsFrames['EnemyTab'].Content, 'TOPLEFT', 0, -4);
    self.show_enemy:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY']);
    self.show_enemy:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOOLTIP']);
    self.show_enemy:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOOLTIP'], self.Tabs[2]);
    self.show_enemy:SetChecked(O.db.show_enemy);
    self.show_enemy:SetEnabled(not O.db.show_enemy_only_in_combat);
    self.show_enemy.LastValue = O.db.show_enemy;
    self.show_enemy.Callback = function(self)
        O.db.show_enemy = self:GetChecked();

        self.LastValue = O.db.show_enemy;

        panel.show_enemy_minions:SetEnabled(O.db.show_enemy);
        panel.show_enemy_guardians:SetEnabled(O.db.show_enemy);
        panel.show_enemy_minus:SetEnabled(O.db.show_enemy);
        panel.show_enemy_pets:SetEnabled(O.db.show_enemy);
        panel.show_enemy_totems:SetEnabled(O.db.show_enemy);

        C_CVar.SetCVar('nameplateShowEnemies', O.db.show_enemy and 1 or 0);

        Stripes:UpdateAll();
    end

    self.show_enemy_only_in_combat = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_only_in_combat:SetPosition('LEFT', self.show_enemy.Label, 'RIGHT', 12, 0);
    self.show_enemy_only_in_combat:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_ONLY_IN_COMBAT']);
    self.show_enemy_only_in_combat:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_ONLY_IN_COMBAT_TOOLTIP']);
    self.show_enemy_only_in_combat:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_ONLY_IN_COMBAT_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_only_in_combat:SetChecked(O.db.show_enemy_only_in_combat);
    self.show_enemy_only_in_combat.Callback = function(self)
        O.db.show_enemy_only_in_combat = self:GetChecked();

        if O.db.show_enemy_only_in_combat then
            C_CVar.SetCVar('nameplateShowEnemies', 0);
            panel.show_enemy:SetChecked(panel.show_enemy.LastValue);
        else
            C_CVar.SetCVar('nameplateShowEnemies', panel.show_enemy.LastValue and 1 or 0);
        end

        panel.show_enemy:SetEnabled(not O.db.show_enemy_only_in_combat);

        Stripes:UpdateAll();
    end

    self.show_enemy_minions = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_minions:SetPosition('TOPLEFT', self.show_enemy, 'BOTTOMLEFT', 0, -8);
    self.show_enemy_minions:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINIONS']);
    self.show_enemy_minions:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINIONS_TOOLTIP']);
    self.show_enemy_minions:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINIONS_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_minions:SetChecked(O.db.show_enemy_minions);
    self.show_enemy_minions:SetEnabled(O.db.show_enemy);
    self.show_enemy_minions.Callback = function(self)
        O.db.show_enemy_minions = self:GetChecked();

        C_CVar.SetCVar('nameplateShowEnemyMinions', O.db.show_enemy_minions and 1 or 0);
    end

    self.show_enemy_guardians = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_guardians:SetPosition('LEFT', self.show_enemy_minions.Label, 'RIGHT', 12, 0);
    self.show_enemy_guardians:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_GUARDIANS']);
    self.show_enemy_guardians:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_GUARDIANS_TOOLTIP']);
    self.show_enemy_guardians:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_GUARDIANS_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_guardians:SetChecked(O.db.show_enemy_guardians);
    self.show_enemy_guardians:SetEnabled(O.db.show_enemy);
    self.show_enemy_guardians.Callback = function(self)
        O.db.show_enemy_guardians = self:GetChecked();

        C_CVar.SetCVar('nameplateShowEnemyGuardians', O.db.show_enemy_guardians and 1 or 0);
    end

    self.show_enemy_minus = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_minus:SetPosition('LEFT', self.show_enemy_guardians.Label, 'RIGHT', 12, 0);
    self.show_enemy_minus:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINUS']);
    self.show_enemy_minus:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINUS_TOOLTIP']);
    self.show_enemy_minus:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINUS_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_minus:SetChecked(O.db.show_enemy_minus);
    self.show_enemy_minus:SetEnabled(O.db.show_enemy);
    self.show_enemy_minus.Callback = function(self)
        O.db.show_enemy_minus = self:GetChecked();

        C_CVar.SetCVar('nameplateShowEnemyMinus', O.db.show_enemy_minus and 1 or 0);
    end

    self.show_enemy_pets = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_pets:SetPosition('LEFT', self.show_enemy_minus.Label, 'RIGHT', 12, 0);
    self.show_enemy_pets:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_PETS']);
    self.show_enemy_pets:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_PETS_TOOLTIP']);
    self.show_enemy_pets:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_PETS_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_pets:SetChecked(O.db.show_enemy_pets);
    self.show_enemy_pets:SetEnabled(O.db.show_enemy);
    self.show_enemy_pets.Callback = function(self)
        O.db.show_enemy_pets = self:GetChecked();

        C_CVar.SetCVar('nameplateShowEnemyPets', O.db.show_enemy_pets and 1 or 0);
    end

    self.show_enemy_totems = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.show_enemy_totems:SetPosition('LEFT', self.show_enemy_pets.Label, 'RIGHT', 12, 0);
    self.show_enemy_totems:SetLabel(L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOTEMS']);
    self.show_enemy_totems:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOTEMS_TOOLTIP']);
    self.show_enemy_totems:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOTEMS_TOOLTIP'], self.Tabs[2]);
    self.show_enemy_totems:SetChecked(O.db.show_enemy_totems);
    self.show_enemy_totems:SetEnabled(O.db.show_enemy);
    self.show_enemy_totems.Callback = function(self)
        O.db.show_enemy_totems = self:GetChecked();

        C_CVar.SetCVar('nameplateShowEnemyTotems', O.db.show_enemy_totems and 1 or 0);
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Friendly Tab --------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.show_friendly = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly:SetPosition('TOPLEFT', self.TabsFrames['FriendlyTab'].Content, 'TOPLEFT', 0, -4);
    self.show_friendly:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY']);
    self.show_friendly:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOOLTIP']);
    self.show_friendly:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOOLTIP'], self.Tabs[3]);
    self.show_friendly:SetChecked(O.db.show_friendly);
    self.show_friendly:SetEnabled(not O.db.show_friendly_only_in_combat);
    self.show_friendly.LastValue = O.db.show_friendly;
    self.show_friendly.Callback = function(self)
        O.db.show_friendly = self:GetChecked();

        self.LastValue = O.db.show_friendly;

        panel.show_friendly_minions:SetEnabled(O.db.show_friendly);
        panel.show_friendly_guardians:SetEnabled(O.db.show_friendly);
        panel.show_friendly_npcs:SetEnabled(O.db.show_friendly);
        panel.show_friendly_pets:SetEnabled(O.db.show_friendly);
        panel.show_friendly_totems:SetEnabled(O.db.show_friendly);

        C_CVar.SetCVar('nameplateShowFriends', O.db.show_friendly and 1 or 0);

        Stripes:UpdateAll();
    end

    self.show_friendly_only_in_combat = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_only_in_combat:SetPosition('LEFT', self.show_friendly.Label, 'RIGHT', 12, 0);
    self.show_friendly_only_in_combat:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_ONLY_IN_COMBAT']);
    self.show_friendly_only_in_combat:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_ONLY_IN_COMBAT_TOOLTIP']);
    self.show_friendly_only_in_combat:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_ONLY_IN_COMBAT_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_only_in_combat:SetChecked(O.db.show_friendly_only_in_combat);
    self.show_friendly_only_in_combat.Callback = function(self)
        O.db.show_friendly_only_in_combat = self:GetChecked();

        if O.db.show_friendly_only_in_combat then
            C_CVar.SetCVar('nameplateShowFriends', 0);
            panel.show_friendly:SetChecked(panel.show_friendly.LastValue);
        else
            C_CVar.SetCVar('nameplateShowFriends', panel.show_friendly.LastValue and 1 or 0);
        end

        panel.show_friendly:SetEnabled(not O.db.show_friendly_only_in_combat);

        Stripes:UpdateAll();
    end

    self.show_friendly_minions = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_minions:SetPosition('TOPLEFT', self.show_friendly, 'BOTTOMLEFT', 0, -8);
    self.show_friendly_minions:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_MINIONS']);
    self.show_friendly_minions:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_MINIONS_TOOLTIP']);
    self.show_friendly_minions:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_MINIONS_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_minions:SetChecked(O.db.show_friendly_minions);
    self.show_friendly_minions:SetEnabled(O.db.show_friendly);
    self.show_friendly_minions.Callback = function(self)
        O.db.show_friendly_minions = self:GetChecked();

        C_CVar.SetCVar('nameplateShowFriendlyMinions', O.db.show_friendly_minions and 1 or 0);
    end

    self.show_friendly_guardians = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_guardians:SetPosition('LEFT', self.show_friendly_minions.Label, 'RIGHT', 12, 0);
    self.show_friendly_guardians:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_GUARDIANS']);
    self.show_friendly_guardians:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_GUARDIANS_TOOLTIP']);
    self.show_friendly_guardians:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_GUARDIANS_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_guardians:SetChecked(O.db.show_friendly_guardians);
    self.show_friendly_guardians:SetEnabled(O.db.show_friendly);
    self.show_friendly_guardians.Callback = function(self)
        O.db.show_friendly_guardians = self:GetChecked();

        C_CVar.SetCVar('nameplateShowFriendlyGuardians', O.db.show_friendly_guardians and 1 or 0);
    end

    self.show_friendly_npcs = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_npcs:SetPosition('LEFT', self.show_friendly_guardians.Label, 'RIGHT', 12, 0);
    self.show_friendly_npcs:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_NPCS']);
    self.show_friendly_npcs:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_NPCS_TOOLTIP']);
    self.show_friendly_npcs:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_NPCS_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_npcs:SetChecked(O.db.show_friendly_npcs);
    self.show_friendly_npcs:SetEnabled(O.db.show_friendly);
    self.show_friendly_npcs.Callback = function(self)
        O.db.show_friendly_npcs = self:GetChecked();

        C_CVar.SetCVar('nameplateShowFriendlyNPCs', O.db.show_friendly_npcs and 1 or 0);
    end

    self.show_friendly_pets = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_pets:SetPosition('LEFT', self.show_friendly_npcs.Label, 'RIGHT', 12, 0);
    self.show_friendly_pets:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_PETS']);
    self.show_friendly_pets:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_PETS_TOOLTIP']);
    self.show_friendly_pets:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_PETS_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_pets:SetChecked(O.db.show_friendly_pets);
    self.show_friendly_pets:SetEnabled(O.db.show_friendly);
    self.show_friendly_pets.Callback = function(self)
        O.db.show_friendly_pets = self:GetChecked();

        C_CVar.SetCVar('nameplateShowFriendlyPets', O.db.show_friendly_pets and 1 or 0);
    end

    self.show_friendly_totems = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.show_friendly_totems:SetPosition('LEFT', self.show_friendly_pets.Label, 'RIGHT', 12, 0);
    self.show_friendly_totems:SetLabel(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOTEMS']);
    self.show_friendly_totems:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOTEMS_TOOLTIP']);
    self.show_friendly_totems:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOTEMS_TOOLTIP'], self.Tabs[3]);
    self.show_friendly_totems:SetChecked(O.db.show_friendly_totems);
    self.show_friendly_totems:SetEnabled(O.db.show_friendly);
    self.show_friendly_totems.Callback = function(self)
        O.db.show_friendly_totems = self:GetChecked();

        C_CVar.SetCVar('nameplateShowFriendlyTotems', O.db.show_friendly_totems and 1 or 0);
    end

    local NameOnlyHeader = E.CreateHeader(self.TabsFrames['FriendlyTab'].Content, L['OPTIONS_HEADER_NAME_ONLY']);
    NameOnlyHeader:SetPosition('TOPLEFT', self.show_friendly_minions, 'BOTTOMLEFT', 0, -8);
    NameOnlyHeader:SetW(self:GetWidth());

    self.name_only_friendly_enabled = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_enabled:SetPosition('TOPLEFT', NameOnlyHeader, 'BOTTOMLEFT', 0, -4);
    self.name_only_friendly_enabled:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_ENABLED'] .. S.Media.ASTERISK);
    self.name_only_friendly_enabled:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_ENABLED_TOOLTIP']);
    self.name_only_friendly_enabled:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_enabled:SetChecked(O.db.name_only_friendly_enabled);
    self.name_only_friendly_enabled.LastSessionValue = O.db.name_only_friendly_enabled;
    self.name_only_friendly_enabled.Callback = function(self)
        O.NeedReload('name_only_friendly_enabled', self.LastSessionValue ~= self:GetChecked());

        O.db.name_only_friendly_enabled = self:GetChecked();

        panel.name_only_friendly_mode:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_players_only:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_color_name_by_health:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_color_name_by_class:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_show_level:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_guild_name:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_guild_name_color:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_guild_name_same_color:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_y_offset:SetEnabled(O.db.name_only_friendly_enabled);
        panel.name_only_friendly_stacking:SetEnabled(O.db.name_only_friendly_enabled);

        if O.db.name_only_friendly_enabled and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Stripes:UpdateAll();
    end

    self.name_only_friendly_mode = E.CreateDropdown('plain', self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_mode:SetPosition('LEFT', self.name_only_friendly_enabled.Label, 'RIGHT', 12, 0);
    self.name_only_friendly_mode:SetSize(200, 20);
    self.name_only_friendly_mode:SetList(O.Lists.name_only_friendly_mode);
    self.name_only_friendly_mode:SetValue(O.db.name_only_friendly_mode);
    self.name_only_friendly_mode:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_FRIENDLY_MODE_TOOLTIP']);
    self.name_only_friendly_mode:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_FRIENDLY_MODE_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_mode:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_mode.LastSessionValue = O.db.name_only_friendly_mode;
    self.name_only_friendly_mode.OnValueChangedCallback = function(_, value)
        O.NeedReload('name_only_friendly_mode', self.LastSessionValue ~= tonumber(value));

        O.db.name_only_friendly_mode = tonumber(value);

        if O.db.name_only_friendly_mode == 1 then -- Anywhere
            C_CVar.SetCVar('nameplateShowOnlyNames', 1);
        else
            C_CVar.SetCVar('nameplateShowOnlyNames', 0);
        end

        if O.db.name_only_friendly_enabled and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Stripes:UpdateAll();
    end

    self.name_only_friendly_players_only = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_players_only:SetPosition('TOPLEFT', self.name_only_friendly_enabled, 'BOTTOMLEFT', 0, -8);
    self.name_only_friendly_players_only:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_PLAYERS_ONLY']);
    self.name_only_friendly_players_only:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_PLAYERS_ONLY_TOOLTIP']);
    self.name_only_friendly_players_only:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_PLAYERS_ONLY_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_players_only:SetChecked(O.db.name_only_friendly_players_only);
    self.name_only_friendly_players_only:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_players_only.Callback = function(self)
        O.db.name_only_friendly_players_only = self:GetChecked();

        panel.name_only_friendly_stacking:SetEnabled(O.db.name_only_friendly_enabled);

        if O.db.name_only_friendly_enabled and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Stripes:UpdateAll();
    end

    -- overlapping not stacking
    self.name_only_friendly_stacking = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_stacking:SetPosition('LEFT', self.name_only_friendly_players_only.Label, 'RIGHT', 12, 0);
    self.name_only_friendly_stacking:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_OVERLAPPING']);
    self.name_only_friendly_stacking:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_OVERLAPPING_TOOLTIP']);
    self.name_only_friendly_stacking:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_OVERLAPPING_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_stacking:SetChecked(O.db.name_only_friendly_stacking);
    self.name_only_friendly_stacking:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_stacking.Callback = function(self)
        O.db.name_only_friendly_stacking = self:GetChecked();

        if O.db.name_only_friendly_enabled and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Stripes:UpdateAll();
    end

    self.name_only_friendly_color_name_by_health = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_color_name_by_health:SetPosition('TOPLEFT', self.name_only_friendly_players_only, 'BOTTOMLEFT', 0, -8);
    self.name_only_friendly_color_name_by_health:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_HEALTH']);
    self.name_only_friendly_color_name_by_health:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_HEALTH_TOOLTIP']);
    self.name_only_friendly_color_name_by_health:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_HEALTH_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_color_name_by_health:SetChecked(O.db.name_only_friendly_color_name_by_health);
    self.name_only_friendly_color_name_by_health:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_color_name_by_health.Callback = function(self)
        O.db.name_only_friendly_color_name_by_health = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_only_friendly_color_name_by_class = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_color_name_by_class:SetPosition('LEFT', self.name_only_friendly_color_name_by_health.Label, 'RIGHT', 12, 0);
    self.name_only_friendly_color_name_by_class:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_CLASS']);
    self.name_only_friendly_color_name_by_class:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_CLASS_TOOLTIP']);
    self.name_only_friendly_color_name_by_class:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_CLASS_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_color_name_by_class:SetChecked(O.db.name_only_friendly_color_name_by_class);
    self.name_only_friendly_color_name_by_class:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_color_name_by_class.Callback = function(self)
        O.db.name_only_friendly_color_name_by_class = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_only_friendly_show_level = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_show_level:SetPosition('LEFT', self.name_only_friendly_color_name_by_class.Label, 'RIGHT', 12, 0);
    self.name_only_friendly_show_level:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_SHOW_LEVEL']);
    self.name_only_friendly_show_level:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_SHOW_LEVEL_TOOLTIP']);
    self.name_only_friendly_show_level:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_SHOW_LEVEL_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_show_level:SetChecked(O.db.name_only_friendly_show_level);
    self.name_only_friendly_show_level:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_show_level.Callback = function(self)
        O.db.name_only_friendly_show_level = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_only_friendly_guild_name = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_guild_name:SetPosition('TOPLEFT', self.name_only_friendly_color_name_by_health, 'BOTTOMLEFT', 0, -8);
    self.name_only_friendly_guild_name:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME']);
    self.name_only_friendly_guild_name:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_TOOLTIP']);
    self.name_only_friendly_guild_name:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_guild_name:SetChecked(O.db.name_only_friendly_guild_name);
    self.name_only_friendly_guild_name:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_guild_name.Callback = function(self)
        O.db.name_only_friendly_guild_name = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.name_only_friendly_guild_name_color = E.CreateColorPicker(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_guild_name_color:SetPosition('LEFT', self.name_only_friendly_guild_name.Label, 'RIGHT', 12, 0);
    self.name_only_friendly_guild_name_color:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_COLOR_TOOLTIP']);
    self.name_only_friendly_guild_name_color:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_COLOR_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_guild_name_color:SetValue(unpack(O.db.name_only_friendly_guild_name_color));
    self.name_only_friendly_guild_name_color:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_guild_name_color.OnValueChanged = function(_, r, g, b, a)
        O.db.name_only_friendly_guild_name_color[1] = r;
        O.db.name_only_friendly_guild_name_color[2] = g;
        O.db.name_only_friendly_guild_name_color[3] = b;
        O.db.name_only_friendly_guild_name_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.name_only_friendly_guild_name_same_color = E.CreateColorPicker(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_guild_name_same_color:SetPosition('LEFT', self.name_only_friendly_guild_name_color, 'RIGHT', 12, 0);
    self.name_only_friendly_guild_name_same_color:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_SAME_COLOR_TOOLTIP']);
    self.name_only_friendly_guild_name_same_color:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_SAME_COLOR_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_guild_name_same_color:SetValue(unpack(O.db.name_only_friendly_guild_name_same_color));
    self.name_only_friendly_guild_name_same_color:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_guild_name_same_color.OnValueChanged = function(_, r, g, b, a)
        O.db.name_only_friendly_guild_name_same_color[1] = r;
        O.db.name_only_friendly_guild_name_same_color[2] = g;
        O.db.name_only_friendly_guild_name_same_color[3] = b;
        O.db.name_only_friendly_guild_name_same_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.name_only_friendly_y_offset = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.name_only_friendly_y_offset:SetPosition('TOPLEFT', self.name_only_friendly_guild_name, 'BOTTOMLEFT', 0, -28);
    self.name_only_friendly_y_offset:SetW(137);
    self.name_only_friendly_y_offset:SetLabel(L['OPTIONS_VISIBILITY_NAME_ONLY_Y_OFFSET']);
    self.name_only_friendly_y_offset:SetTooltip(L['OPTIONS_VISIBILITY_NAME_ONLY_Y_OFFSET_TOOLTIP']);
    self.name_only_friendly_y_offset:AddToSearch(button, L['OPTIONS_VISIBILITY_NAME_ONLY_Y_OFFSET_TOOLTIP'], self.Tabs[3]);
    self.name_only_friendly_y_offset:SetValues(O.db.name_only_friendly_y_offset, -33, 34, 1);
    self.name_only_friendly_y_offset:SetEnabled(O.db.name_only_friendly_enabled);
    self.name_only_friendly_y_offset.OnValueChangedCallback = function(_, value)
        O.db.name_only_friendly_y_offset = tonumber(value);
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Self Tab ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.show_personal = E.CreateCheckButton(self.TabsFrames['SelfTab'].Content);
    self.show_personal:SetPosition('TOPLEFT', self.TabsFrames['SelfTab'].Content, 'TOPLEFT', 0, -4);
    self.show_personal:SetLabel(L['OPTIONS_VISIBILITY_SHOW_PERSONAL']);
    self.show_personal:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_PERSONAL_TOOLTIP']);
    self.show_personal:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_PERSONAL_TOOLTIP'], self.Tabs[4]);
    self.show_personal:SetChecked(O.db.show_personal);
    self.show_personal.Callback = function(self)
        O.db.show_personal = self:GetChecked();

        panel.show_personal_always:SetEnabled(O.db.show_personal);

        C_CVar.SetCVar('nameplateShowSelf', O.db.show_personal and 1 or 0);

        Stripes:UpdateAll();
    end

    self.show_personal_always = E.CreateCheckButton(self.TabsFrames['SelfTab'].Content);
    self.show_personal_always:SetPosition('LEFT', self.show_personal.Label, 'RIGHT', 12, 0);
    self.show_personal_always:SetLabel(L['OPTIONS_VISIBILITY_SHOW_PERSONAL_ALWAYS']);
    self.show_personal_always:SetTooltip(L['OPTIONS_VISIBILITY_SHOW_PERSONAL_ALWAYS_TOOLTIP']);
    self.show_personal_always:AddToSearch(button, L['OPTIONS_VISIBILITY_SHOW_PERSONAL_ALWAYS_TOOLTIP'], self.Tabs[4]);
    self.show_personal_always:SetChecked(O.db.show_personal_always);
    self.show_personal_always:SetEnabled(O.db.show_personal);
    self.show_personal_always.Callback = function(self)
        O.db.show_personal_always = self:GetChecked();

        C_CVar.SetCVar('NameplatePersonalShowAlways', O.db.show_personal_always and 1 or 0);

        Stripes:UpdateAll();
    end
end