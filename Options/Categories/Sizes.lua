local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Sizes');

-- C_NamePlate.SetNamePlateEnemySize(154, 64); -- Large
-- C_NamePlate.SetNamePlateEnemySize(110, 45); -- Small

O.frame.Left.Sizes, O.frame.Right.Sizes = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_SIZES']), 'sizes', 2);
local button = O.frame.Left.Sizes;
local panel = O.frame.Right.Sizes;

panel.TabsData = {
    [1] = {
        name  = 'EnemyTab',
        title = string.upper(L['OPTIONS_SIZES_TAB_ENEMY']),
    },
    [2] = {
        name  = 'FriendlyTab',
        title = string.upper(L['OPTIONS_SIZES_TAB_FRIENDLY']),
    },
    [3] = {
        name  = 'SelfTab',
        title = string.upper(L['OPTIONS_SIZES_TAB_SELF']),
    },
    [4] = {
        name  = 'OtherTab',
        title = string.upper(L['OPTIONS_SIZES_TAB_OTHER']),
    },
};

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    self.TabsHolder:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, -28);
    self.TabsHolder:SetPosition('TOPRIGHT', self, 'TOPRIGHT', 0, -28);

    self.size_clickable_area_show = E.CreateCheckButton(self);
    self.size_clickable_area_show:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.size_clickable_area_show:SetLabel(L['OPTIONS_SIZES_SHOW_CLICKABLE_AREA']);
    self.size_clickable_area_show:SetTooltip(L['OPTIONS_SIZES_SHOW_CLICKABLE_AREA']);
    self.size_clickable_area_show:AddToSearch(button);
    self.size_clickable_area_show:SetChecked(O.db.size_clickable_area_show);
    self.size_clickable_area_show.Callback = function(self)
        O.db.size_clickable_area_show = self:GetChecked();
        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Enemy Tab -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.size_enemy_click_through = E.CreateCheckButton(self.TabsFrames['EnemyTab'].Content);
    self.size_enemy_click_through:SetPosition('TOPLEFT', self.TabsFrames['EnemyTab'].Content, 'TOPLEFT', 0, -12);
    self.size_enemy_click_through:SetLabel(L['OPTIONS_SIZES_ENEMY_CLICK_THROUGH']);
    self.size_enemy_click_through:SetTooltip(L['OPTIONS_SIZES_ENEMY_CLICK_THROUGH_TOOLTIP']);
    self.size_enemy_click_through:AddToSearch(button, L['OPTIONS_SIZES_ENEMY_CLICK_THROUGH_TOOLTIP'], self.Tabs[1]);
    self.size_enemy_click_through:SetChecked(O.db.size_enemy_click_through);
    self.size_enemy_click_through.Callback = function(self)
        O.db.size_enemy_click_through = self:GetChecked();

        C_NamePlate.SetNamePlateEnemyClickThrough(O.db.size_enemy_click_through);
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['EnemyTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.size_enemy_click_through, 'BOTTOMLEFT', 0, -8);
    Delimiter:SetW(self:GetWidth());

    self.size_enemy_clickable_width = E.CreateSlider(self.TabsFrames['EnemyTab'].Content);
    self.size_enemy_clickable_width:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.size_enemy_clickable_width:SetW(137);
    self.size_enemy_clickable_width:SetLabel(L['OPTIONS_SIZES_ENEMY_CLICKABLE_WIDTH']);
    self.size_enemy_clickable_width:SetTooltip(L['OPTIONS_SIZES_ENEMY_CLICKABLE_WIDTH_TOOLTIP']);
    self.size_enemy_clickable_width:AddToSearch(button, L['OPTIONS_SIZES_ENEMY_CLICKABLE_WIDTH_TOOLTIP'], self.Tabs[1]);
    self.size_enemy_clickable_width:SetValues(O.db.size_enemy_clickable_width, 40, 300, 1);
    self.size_enemy_clickable_width.OnValueChangedCallback = function(_, value)
        O.db.size_enemy_clickable_width = tonumber(value);

        C_NamePlate.SetNamePlateEnemySize(O.db.size_enemy_clickable_width, O.db.size_enemy_clickable_height);

        Handler:UpdateAll();
    end

    self.size_enemy_clickable_height = E.CreateSlider(self.TabsFrames['EnemyTab'].Content);
    self.size_enemy_clickable_height:SetPosition('LEFT', self.size_enemy_clickable_width, 'RIGHT', 12, 0);
    self.size_enemy_clickable_height:SetW(137);
    self.size_enemy_clickable_height:SetValues(O.db.size_enemy_clickable_height, 2, 300, 1);
    self.size_enemy_clickable_height:SetLabel(L['OPTIONS_SIZES_ENEMY_CLICKABLE_HEIGHT']);
    self.size_enemy_clickable_height:SetTooltip(L['OPTIONS_SIZES_ENEMY_CLICKABLE_HEIGHT_TOOLTIP']);
    self.size_enemy_clickable_height:AddToSearch(button, L['OPTIONS_SIZES_ENEMY_CLICKABLE_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.size_enemy_clickable_height.OnValueChangedCallback = function(_, value)
        O.db.size_enemy_clickable_height = tonumber(value);

        C_NamePlate.SetNamePlateEnemySize(O.db.size_enemy_clickable_width, O.db.size_enemy_clickable_height);

        Handler:UpdateAll();
    end

    self.size_enemy_height = E.CreateSlider(self.TabsFrames['EnemyTab'].Content);
    self.size_enemy_height:SetPosition('LEFT', self.size_enemy_clickable_height, 'RIGHT', 12, 0);
    self.size_enemy_height:SetW(137);
    self.size_enemy_height:SetLabel(L['OPTIONS_SIZES_ENEMY_HEIGHT']);
    self.size_enemy_height:SetTooltip(L['OPTIONS_SIZES_ENEMY_HEIGHT_TOOLTIP']);
    self.size_enemy_height:AddToSearch(button, L['OPTIONS_SIZES_ENEMY_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.size_enemy_height:SetValues(O.db.size_enemy_height, 2, 300, 1);
    self.size_enemy_height.OnValueChangedCallback = function(_, value)
        O.db.size_enemy_height = tonumber(value);
        Handler:UpdateAll();
    end

    self.size_enemy_minus_height = E.CreateSlider(self.TabsFrames['EnemyTab'].Content);
    self.size_enemy_minus_height:SetPosition('LEFT', self.size_enemy_height, 'RIGHT', 12, 0);
    self.size_enemy_minus_height:SetW(138);
    self.size_enemy_minus_height:SetLabel(L['OPTIONS_SIZES_ENEMY_MINUS_HEIGHT']);
    self.size_enemy_minus_height:SetTooltip(L['OPTIONS_SIZES_ENEMY_MINUS_HEIGHT_TOOLTIP']);
    self.size_enemy_minus_height:AddToSearch(button, L['OPTIONS_SIZES_ENEMY_MINUS_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.size_enemy_minus_height:SetValues(O.db.size_enemy_minus_height, 2, 300, 1);
    self.size_enemy_minus_height.OnValueChangedCallback = function(_, value)
        O.db.size_enemy_minus_height = tonumber(value);
        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Friendly Tab --------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.size_friendly_click_through = E.CreateCheckButton(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_click_through:SetPosition('TOPLEFT', self.TabsFrames['FriendlyTab'].Content, 'TOPLEFT', 0, -12);
    self.size_friendly_click_through:SetLabel(L['OPTIONS_SIZES_FRIENDLY_CLICK_THROUGH']);
    self.size_friendly_click_through:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_CLICK_THROUGH_TOOLTIP']);
    self.size_friendly_click_through:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_CLICK_THROUGH_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_click_through:SetChecked(O.db.size_friendly_click_through);
    self.size_friendly_click_through.Callback = function(self)
        O.db.size_friendly_click_through = self:GetChecked();

        C_NamePlate.SetNamePlateFriendlyClickThrough(O.db.size_friendly_click_through);
    end


    local OpenWorldHeader = E.CreateHeader(self.TabsFrames['FriendlyTab'].Content, L['OPTIONS_SIZES_OPEN_WORLD_HEADER']);
    OpenWorldHeader:SetPosition('TOPLEFT', self.size_friendly_click_through, 'BOTTOMLEFT', 0, -8);
    OpenWorldHeader:SetW(self:GetWidth());

    self.size_friendly_clickable_width = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_clickable_width:SetPosition('TOPLEFT', OpenWorldHeader, 'BOTTOMLEFT', 0, -20);
    self.size_friendly_clickable_width:SetW(137);
    self.size_friendly_clickable_width:SetLabel(L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_WIDTH']);
    self.size_friendly_clickable_width:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_WIDTH_TOOLTIP']);
    self.size_friendly_clickable_width:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_WIDTH_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_clickable_width:SetValues(O.db.size_friendly_clickable_width, 40, 300, 1);
    self.size_friendly_clickable_width.OnValueChangedCallback = function(_, value)
        O.db.size_friendly_clickable_width = tonumber(value);

        if Handler:IsNameOnlyMode() and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if not U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Handler:UpdateAll();
    end

    self.size_friendly_clickable_height = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_clickable_height:SetPosition('LEFT', self.size_friendly_clickable_width, 'RIGHT', 12, 0);
    self.size_friendly_clickable_height:SetW(137);
    self.size_friendly_clickable_height:SetValues(O.db.size_friendly_clickable_height, 2, 300, 1);
    self.size_friendly_clickable_height:SetLabel(L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_HEIGHT']);
    self.size_friendly_clickable_height:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_HEIGHT_TOOLTIP']);
    self.size_friendly_clickable_height:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_HEIGHT_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_clickable_height.OnValueChangedCallback = function(_, value)
        O.db.size_friendly_clickable_height = tonumber(value);

        if Handler:IsNameOnlyMode() and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if not U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, O.db.size_friendly_clickable_height);
            end
        end

        Handler:UpdateAll();
    end

    self.size_friendly_height = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_height:SetPosition('LEFT', self.size_friendly_clickable_height, 'RIGHT', 12, 0);
    self.size_friendly_height:SetW(137);
    self.size_friendly_height:SetLabel(L['OPTIONS_SIZES_FRIENDLY_HEIGHT']);
    self.size_friendly_height:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_HEIGHT_TOOLTIP']);
    self.size_friendly_height:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_HEIGHT_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_height:SetValues(O.db.size_friendly_height, 2, 300, 1);
    self.size_friendly_height.OnValueChangedCallback = function(_, value)
        O.db.size_friendly_height = tonumber(value);
        Handler:UpdateAll();
    end

    local InstancesHeader = E.CreateHeader(self.TabsFrames['FriendlyTab'].Content, L['OPTIONS_SIZES_INSTANCES_HEADER']);
    InstancesHeader:SetPosition('TOPLEFT', self.size_friendly_clickable_width, 'BOTTOMLEFT', 0, -8);
    InstancesHeader:SetW(self:GetWidth());

    self.size_friendly_instance_clickable_width = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_instance_clickable_width:SetPosition('TOPLEFT', InstancesHeader, 'BOTTOMLEFT', 0, -20);
    self.size_friendly_instance_clickable_width:SetW(137);
    self.size_friendly_instance_clickable_width:SetLabel(L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_WIDTH']);
    self.size_friendly_instance_clickable_width:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_WIDTH_TOOLTIP']);
    self.size_friendly_instance_clickable_width:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_WIDTH_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_instance_clickable_width:SetValues(O.db.size_friendly_instance_clickable_width, 25, 300, 1);
    self.size_friendly_instance_clickable_width.OnValueChangedCallback = function(_, value)
        O.db.size_friendly_instance_clickable_width = tonumber(value);

        if Handler:IsNameOnlyMode() and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            end
        end

        Handler:UpdateAll();
    end

    self.size_friendly_instance_clickable_height = E.CreateSlider(self.TabsFrames['FriendlyTab'].Content);
    self.size_friendly_instance_clickable_height:SetPosition('LEFT', self.size_friendly_instance_clickable_width, 'RIGHT', 12, 0);
    self.size_friendly_instance_clickable_height:SetW(137);
    self.size_friendly_instance_clickable_height:SetValues(O.db.size_friendly_instance_clickable_height, 2, 300, 1);
    self.size_friendly_instance_clickable_height:SetLabel(L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_HEIGHT']);
    self.size_friendly_instance_clickable_height:SetTooltip(L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_HEIGHT_TOOLTIP']);
    self.size_friendly_instance_clickable_height:AddToSearch(button, L['OPTIONS_SIZES_FRIENDLY_INSTANCE_CLICKABLE_HEIGHT_TOOLTIP'], self.Tabs[2]);
    self.size_friendly_instance_clickable_height.OnValueChangedCallback = function(_, value)
        O.db.size_friendly_instance_clickable_height = tonumber(value);

        if Handler:IsNameOnlyMode() and O.db.name_only_friendly_stacking then
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, 1);
            else
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_clickable_width, 1);
            end
        else
            if U.IsInInstance() then
                C_NamePlate.SetNamePlateFriendlySize(O.db.size_friendly_instance_clickable_width, O.db.size_friendly_instance_clickable_height);
            end
        end

        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Self Tab ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.size_self_click_through = E.CreateCheckButton(self.TabsFrames['SelfTab'].Content);
    self.size_self_click_through:SetPosition('TOPLEFT', self.TabsFrames['SelfTab'].Content, 'TOPLEFT', 0, -12);
    self.size_self_click_through:SetLabel(L['OPTIONS_SIZES_SELF_CLICK_THROUGH']);
    self.size_self_click_through:SetTooltip(L['OPTIONS_SIZES_SELF_CLICK_THROUGH_TOOLTIP']);
    self.size_self_click_through:AddToSearch(button, L['OPTIONS_SIZES_SELF_CLICK_THROUGH_TOOLTIP'], self.Tabs[3]);
    self.size_self_click_through:SetChecked(O.db.size_self_click_through);
    self.size_self_click_through.Callback = function(self)
        O.db.size_self_click_through = self:GetChecked();

        C_CVar.SetCVar('NameplatePersonalClickThrough', O.db.size_self_click_through and 1 or 0);
        C_NamePlate.SetNamePlateSelfClickThrough(O.db.size_self_click_through);
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['SelfTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.size_self_click_through, 'BOTTOMLEFT', 0, -8);
    Delimiter:SetW(self:GetWidth());

    self.size_self_width = E.CreateSlider(self.TabsFrames['SelfTab'].Content);
    self.size_self_width:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.size_self_width:SetW(137);
    self.size_self_width:SetLabel(L['OPTIONS_SIZES_SELF_WIDTH']);
    self.size_self_width:SetTooltip(L['OPTIONS_SIZES_SELF_WIDTH_TOOLTIP']);
    self.size_self_width:AddToSearch(button, L['OPTIONS_SIZES_SELF_WIDTH_TOOLTIP'], self.Tabs[3]);
    self.size_self_width:SetValues(O.db.size_self_width, 40, 300, 1);
    self.size_self_width.OnValueChangedCallback = function(_, value)
        O.db.size_self_width = tonumber(value);

        C_NamePlate.SetNamePlateSelfSize(O.db.size_self_width, O.db.size_self_height);

        Handler:UpdateAll();
    end

    self.size_self_height = E.CreateSlider(self.TabsFrames['SelfTab'].Content);
    self.size_self_height:SetPosition('LEFT', self.size_self_width, 'RIGHT', 12, 0);
    self.size_self_height:SetW(137);
    self.size_self_height:SetValues(O.db.size_self_height, 2, 300, 1);
    self.size_self_height:SetLabel(L['OPTIONS_SIZES_SELF_HEIGHT']);
    self.size_self_height:SetTooltip(L['OPTIONS_SIZES_SELF_HEIGHT_TOOLTIP']);
    self.size_self_height:AddToSearch(button, L['OPTIONS_SIZES_SELF_HEIGHT_TOOLTIP'], self.Tabs[3]);
    self.size_self_height.OnValueChangedCallback = function(_, value)
        O.db.size_self_height = tonumber(value);

        C_NamePlate.SetNamePlateSelfSize(O.db.size_self_width, O.db.size_self_height);

        Handler:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Other Tab -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.scale_large = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.scale_large:SetPosition('TOPLEFT', self.TabsFrames['OtherTab'].Content, 'TOPLEFT', 0, -20);
    self.scale_large:SetW(137);
    self.scale_large:SetLabel(L['OPTIONS_SIZES_SCALE_LARGE']);
    self.scale_large:SetTooltip(L['OPTIONS_SIZES_SCALE_LARGE_TOOLTIP']);
    self.scale_large:AddToSearch(button, L['OPTIONS_SIZES_SCALE_LARGE_TOOLTIP'], self.Tabs[4]);
    self.scale_large:SetValues(O.db.scale_large, 0.1, 3, 0.1);
    self.scale_large.OnValueChangedCallback = function(_, value)
        O.db.scale_large = tonumber(value);

        C_CVar.SetCVar('nameplateLargerScale', O.db.scale_large);

        Handler:UpdateAll();
    end

    self.scale_global = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.scale_global:SetPosition('LEFT', self.scale_large, 'RIGHT', 12, 0);
    self.scale_global:SetW(137);
    self.scale_global:SetLabel(L['OPTIONS_SIZES_SCALE_GLOBAL']);
    self.scale_global:SetTooltip(L['OPTIONS_SIZES_SCALE_GLOBAL']);
    self.scale_global:AddToSearch(button, L['OPTIONS_SIZES_SCALE_GLOBAL_TOOLTIP'], self.Tabs[4]);
    self.scale_global:SetValues(O.db.scale_global, 0.1, 3, 0.1);
    self.scale_global.OnValueChangedCallback = function(_, value)
        O.db.scale_global = tonumber(value);

        C_CVar.SetCVar('nameplateGlobalScale', O.db.scale_global);

        Handler:UpdateAll();
    end

    self.scale_selected = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.scale_selected:SetPosition('LEFT', self.scale_global, 'RIGHT', 12, 0);
    self.scale_selected:SetW(137);
    self.scale_selected:SetLabel(L['OPTIONS_SIZES_SCALE_SELECTED']);
    self.scale_selected:SetTooltip(L['OPTIONS_SIZES_SCALE_SELECTED_TOOLTIP']);
    self.scale_selected:AddToSearch(button, L['OPTIONS_SIZES_SCALE_SELECTED_TOOLTIP'], self.Tabs[4]);
    self.scale_selected:SetValues(O.db.scale_selected, 0.1, 3, 0.1);
    self.scale_selected.OnValueChangedCallback = function(_, value)
        O.db.scale_selected = tonumber(value);

        C_CVar.SetCVar('nameplateSelectedScale', O.db.scale_selected);

        Handler:UpdateAll();
    end

    self.scale_self = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.scale_self:SetPosition('LEFT', self.scale_selected, 'RIGHT', 12, 0);
    self.scale_self:SetW(137);
    self.scale_self:SetLabel(L['OPTIONS_SIZES_SCALE_SELF']);
    self.scale_self:SetTooltip(L['OPTIONS_SIZES_SCALE_SELF_TOOLTIP']);
    self.scale_self:AddToSearch(button, L['OPTIONS_SIZES_SCALE_SELF_TOOLTIP'], self.Tabs[4]);
    self.scale_self:SetValues(O.db.scale_self, 0.1, 3, 0.1);
    self.scale_self.OnValueChangedCallback = function(_, value)
        O.db.scale_self = tonumber(value);

        C_CVar.SetCVar('nameplateSelfScale', O.db.scale_self);

        Handler:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['OtherTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.scale_large, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.overlap_h = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.overlap_h:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -16);
    self.overlap_h:SetW(137);
    self.overlap_h:SetLabel(L['OPTIONS_SIZES_OVERLAP_H']);
    self.overlap_h:SetTooltip(L['OPTIONS_SIZES_OVERLAP_H_TOOLTIP']);
    self.overlap_h:AddToSearch(button, L['OPTIONS_SIZES_OVERLAP_H_TOOLTIP'], self.Tabs[4]);
    self.overlap_h:SetValues(O.db.overlap_h, 0.1, 3, 0.1);
    self.overlap_h.OnValueChangedCallback = function(_, value)
        O.db.overlap_h = tonumber(value);

        C_CVar.SetCVar('nameplateOverlapH', O.db.overlap_h);

        Handler:UpdateAll();
    end

    self.overlap_v = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.overlap_v:SetPosition('LEFT', self.overlap_h, 'RIGHT', 12, 0);
    self.overlap_v:SetW(137);
    self.overlap_v:SetLabel(L['OPTIONS_SIZES_OVERLAP_V']);
    self.overlap_v:SetTooltip(L['OPTIONS_SIZES_OVERLAP_V_TOOLTIP']);
    self.overlap_v:AddToSearch(button, L['OPTIONS_SIZES_OVERLAP_V_TOOLTIP'], self.Tabs[4]);
    self.overlap_v:SetValues(O.db.overlap_v, 0.1, 3, 0.1);
    self.overlap_v.OnValueChangedCallback = function(_, value)
        O.db.overlap_v = tonumber(value);

        C_CVar.SetCVar('nameplateOverlapV', O.db.overlap_v);

        Handler:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['OtherTab'].Content);
    Delimiter:SetPosition('LEFT', self.overlap_h, 'LEFT', 0, -24);
    Delimiter:SetW(self:GetWidth());

    self.large_top_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.large_top_inset:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -16);
    self.large_top_inset:SetW(137);
    self.large_top_inset:SetLabel(L['OPTIONS_SIZES_LARGE_TOP_INSET']);
    self.large_top_inset:SetTooltip(L['OPTIONS_SIZES_LARGE_TOP_INSET_TOOLTIP']);
    self.large_top_inset:AddToSearch(button, L['OPTIONS_SIZES_LARGE_TOP_INSET_TOOLTIP'], self.Tabs[4]);
    self.large_top_inset:SetValues(O.db.large_top_inset, 0.01, 1, 0.01);
    self.large_top_inset.OnValueChangedCallback = function(_, value)
        O.db.large_top_inset = tonumber(value);

        C_CVar.SetCVar('nameplateLargeTopInset', O.db.large_top_inset);
    end

    self.other_top_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.other_top_inset:SetPosition('LEFT', self.large_top_inset, 'RIGHT', 44, 0);
    self.other_top_inset:SetW(137);
    self.other_top_inset:SetLabel(L['OPTIONS_SIZES_OTHER_TOP_INSET']);
    self.other_top_inset:SetTooltip(L['OPTIONS_SIZES_OTHER_TOP_INSET_TOOLTIP']);
    self.other_top_inset:AddToSearch(button, L['OPTIONS_SIZES_OTHER_TOP_INSET_TOOLTIP'], self.Tabs[4]);
    self.other_top_inset:SetValues(O.db.other_top_inset, 0.01, 1, 0.01);
    self.other_top_inset.OnValueChangedCallback = function(_, value)
        O.db.other_top_inset = tonumber(value);

        C_CVar.SetCVar('nameplateOtherTopInset', O.db.other_top_inset);
    end

    self.self_top_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.self_top_inset:SetPosition('LEFT', self.other_top_inset, 'RIGHT', 44, 0);
    self.self_top_inset:SetW(137);
    self.self_top_inset:SetLabel(L['OPTIONS_SIZES_SELF_TOP_INSET']);
    self.self_top_inset:SetTooltip(L['OPTIONS_SIZES_SELF_TOP_INSET_TOOLTIP']);
    self.self_top_inset:AddToSearch(button, L['OPTIONS_SIZES_SELF_TOP_INSET_TOOLTIP'], self.Tabs[4]);
    self.self_top_inset:SetValues(O.db.self_top_inset, 0.01, 1, 0.01);
    self.self_top_inset.OnValueChangedCallback = function(_, value)
        O.db.self_top_inset = tonumber(value);

        C_CVar.SetCVar('nameplateSelfTopInset', O.db.self_top_inset);
    end

    self.large_bottom_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.large_bottom_inset:SetPosition('TOPLEFT', self.large_top_inset, 'BOTTOMLEFT', 0, -30);
    self.large_bottom_inset:SetW(137);
    self.large_bottom_inset:SetLabel(L['OPTIONS_SIZES_LARGE_BOTTOM_INSET']);
    self.large_bottom_inset:SetTooltip(L['OPTIONS_SIZES_LARGE_BOTTOM_INSET_TOOLTIP']);
    self.large_bottom_inset:AddToSearch(button, L['OPTIONS_SIZES_LARGE_BOTTOM_INSET_TOOLTIP'], self.Tabs[4]);
    self.large_bottom_inset:SetValues(O.db.large_bottom_inset, 0.01, 1, 0.01);
    self.large_bottom_inset.OnValueChangedCallback = function(_, value)
        O.db.large_bottom_inset = tonumber(value);

        C_CVar.SetCVar('nameplateLargeBottomInset', O.db.large_bottom_inset);
    end

    self.other_bottom_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.other_bottom_inset:SetPosition('LEFT', self.large_bottom_inset, 'RIGHT', 44, 0);
    self.other_bottom_inset:SetW(137);
    self.other_bottom_inset:SetLabel(L['OPTIONS_SIZES_OTHER_BOTTOM_INSET']);
    self.other_bottom_inset:SetTooltip(L['OPTIONS_SIZES_OTHER_BOTTOM_INSET_TOOLTIP']);
    self.other_bottom_inset:AddToSearch(button, L['OPTIONS_SIZES_OTHER_BOTTOM_INSET_TOOLTIP'], self.Tabs[4]);
    self.other_bottom_inset:SetValues(O.db.other_bottom_inset, 0.01, 1, 0.01);
    self.other_bottom_inset.OnValueChangedCallback = function(_, value)
        O.db.other_bottom_inset = tonumber(value);

        C_CVar.SetCVar('nameplateOtherBottomInset', O.db.other_bottom_inset);
    end

    self.self_bottom_inset = E.CreateSlider(self.TabsFrames['OtherTab'].Content);
    self.self_bottom_inset:SetPosition('LEFT', self.other_bottom_inset, 'RIGHT', 44, 0);
    self.self_bottom_inset:SetW(137);
    self.self_bottom_inset:SetLabel(L['OPTIONS_SIZES_SELF_BOTTOM_INSET']);
    self.self_bottom_inset:SetTooltip(L['OPTIONS_SIZES_SELF_BOTTOM_INSET_TOOLTIP']);
    self.self_bottom_inset:AddToSearch(button, L['OPTIONS_SIZES_SELF_BOTTOM_INSET_TOOLTIP'], self.Tabs[4]);
    self.self_bottom_inset:SetValues(O.db.self_bottom_inset, 0.01, 1, 0.01);
    self.self_bottom_inset.OnValueChangedCallback = function(_, value)
        O.db.self_bottom_inset = tonumber(value);

        C_CVar.SetCVar('nameplateSelfBottomInset', O.db.self_bottom_inset);
    end
end