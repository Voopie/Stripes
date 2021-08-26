local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_MythicPlus');

local LSM = S.Libraries.LSM;

O.frame.Left.MythicPlus, O.frame.Right.MythicPlus = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_MYTHIC_PLUS']), 'mythicplus', 8);
local button = O.frame.Left.MythicPlus;
local panel  = O.frame.Right.MythicPlus;

local isMDTLoaded = false;

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    local PercentHeader = E.CreateHeader(self, L['OPTIONS_HEADER_PERCENTAGE']);
    PercentHeader:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    PercentHeader:SetW(self:GetWidth());

    self.mythic_plus_percentage_enabled = E.CreateCheckButton(self);
    self.mythic_plus_percentage_enabled:SetPosition('TOPLEFT', PercentHeader, 'BOTTOMLEFT', 0, -4);
    self.mythic_plus_percentage_enabled:SetLabel(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_ENABLED']);
    self.mythic_plus_percentage_enabled:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_ENABLED_TOOLTIP']);
    self.mythic_plus_percentage_enabled:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_ENABLED_TOOLTIP']);
    self.mythic_plus_percentage_enabled:SetChecked(O.db.mythic_plus_percentage_enabled);
    self.mythic_plus_percentage_enabled.Callback = function(self)
        O.db.mythic_plus_percentage_enabled = self:GetChecked();

        panel.mythic_plus_percentage_use_mode:SetEnabled(O.db.mythic_plus_percentage_enabled and isMDTLoaded);

        Handler:UpdateAll();
    end

    self.mythic_plus_percentage_use_mode = E.CreateDropdown('plain', self);
    self.mythic_plus_percentage_use_mode:SetPosition('LEFT', self.mythic_plus_percentage_enabled.Label, 'RIGHT', 12, 0);
    self.mythic_plus_percentage_use_mode:SetSize(200, 20);
    self.mythic_plus_percentage_use_mode:SetList(O.Lists.mythic_plus_percentage_use_mode);
    self.mythic_plus_percentage_use_mode:SetValue(O.db.mythic_plus_percentage_use_mode);
    self.mythic_plus_percentage_use_mode:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_USE_MODE_TOOLTIP']);
    self.mythic_plus_percentage_use_mode:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_USE_MODE_TOOLTIP']);
    self.mythic_plus_percentage_use_mode:SetEnabled(O.db.mythic_plus_percentage_enabled);
    self.mythic_plus_percentage_use_mode.OnValueChangedCallback = function(_, value)
        O.db.mythic_plus_percentage_use_mode = tonumber(value);
        Handler:UpdateAll();
    end

    if not isMDTLoaded then
        self.mythic_plus_percentage_use_mode:SetEnabled(false);
        self.mythic_plus_percentage_use_mode:SetValue(1);
    end

    self.mythic_plus_percentage_font_value = E.CreateDropdown('font', self);
    self.mythic_plus_percentage_font_value:SetPosition('TOPLEFT', self.mythic_plus_percentage_enabled, 'BOTTOMLEFT', 0, -12);
    self.mythic_plus_percentage_font_value:SetSize(160, 20);
    self.mythic_plus_percentage_font_value:SetList(LSM:HashTable('font'));
    self.mythic_plus_percentage_font_value:SetValue(O.db.mythic_plus_percentage_font_value);
    self.mythic_plus_percentage_font_value:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_VALUE']);
    self.mythic_plus_percentage_font_value:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_VALUE']);
    self.mythic_plus_percentage_font_value.OnValueChangedCallback = function(_, value)
        O.db.mythic_plus_percentage_font_value = value;
        Handler:UpdateAll();
    end

    self.mythic_plus_percentage_font_size = E.CreateSlider(self);
    self.mythic_plus_percentage_font_size:SetPosition('LEFT', self.mythic_plus_percentage_font_value, 'RIGHT', 12, 0);
    self.mythic_plus_percentage_font_size:SetValues(O.db.mythic_plus_percentage_font_size, 3, 28, 1);
    self.mythic_plus_percentage_font_size:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SIZE']);
    self.mythic_plus_percentage_font_size:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SIZE']);
    self.mythic_plus_percentage_font_size.OnValueChangedCallback = function(_, value)
        O.db.mythic_plus_percentage_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.mythic_plus_percentage_font_flag = E.CreateDropdown('plain', self);
    self.mythic_plus_percentage_font_flag:SetPosition('LEFT', self.mythic_plus_percentage_font_size, 'RIGHT', 12, 0);
    self.mythic_plus_percentage_font_flag:SetSize(160, 20);
    self.mythic_plus_percentage_font_flag:SetList(O.Lists.font_flags_localized);
    self.mythic_plus_percentage_font_flag:SetValue(O.db.mythic_plus_percentage_font_flag);
    self.mythic_plus_percentage_font_flag:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_FLAG']);
    self.mythic_plus_percentage_font_flag:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_FLAG']);
    self.mythic_plus_percentage_font_flag.OnValueChangedCallback = function(_, value)
        O.db.mythic_plus_percentage_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.mythic_plus_percentage_font_shadow = E.CreateCheckButton(self);
    self.mythic_plus_percentage_font_shadow:SetPosition('LEFT', self.mythic_plus_percentage_font_flag, 'RIGHT', 12, 0);
    self.mythic_plus_percentage_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.mythic_plus_percentage_font_shadow:SetChecked(O.db.mythic_plus_percentage_font_shadow);
    self.mythic_plus_percentage_font_shadow:SetTooltip(L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SHADOW']);
    self.mythic_plus_percentage_font_shadow:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SHADOW']);
    self.mythic_plus_percentage_font_shadow.Callback = function(self)
        O.db.mythic_plus_percentage_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    local ExplosiveOrbsHeader = E.CreateHeader(self, L['OPTIONS_HEADER_EXPLOSIVE_ORBS']);
    ExplosiveOrbsHeader:SetPosition('TOPLEFT', self.mythic_plus_percentage_font_value, 'BOTTOMLEFT', 0, -8);
    ExplosiveOrbsHeader:SetW(self:GetWidth());

    self.explosive_orbs_crosshair = E.CreateCheckButton(self);
    self.explosive_orbs_crosshair:SetPosition('TOPLEFT', ExplosiveOrbsHeader, 'BOTTOMLEFT', 0, -4);
    self.explosive_orbs_crosshair:SetLabel(L['OPTIONS_EXPLOSIVE_ORBS_CROSSHAIR']);
    self.explosive_orbs_crosshair:SetTooltip(L['OPTIONS_EXPLOSIVE_ORBS_CROSSHAIR_TOOLTIP']);
    self.explosive_orbs_crosshair:AddToSearch(button, L['OPTIONS_EXPLOSIVE_ORBS_CROSSHAIR_TOOLTIP']);
    self.explosive_orbs_crosshair:SetChecked(O.db.explosive_orbs_crosshair);
    self.explosive_orbs_crosshair.Callback = function(self)
        O.db.explosive_orbs_crosshair = self:GetChecked();
        Handler:UpdateAll();
    end

    self.explosive_orbs_glow = E.CreateCheckButton(self);
    self.explosive_orbs_glow:SetPosition('LEFT', self.explosive_orbs_crosshair.Label, 'RIGHT', 12, 0);
    self.explosive_orbs_glow:SetLabel(L['OPTIONS_EXPLOSIVE_ORBS_GLOW']);
    self.explosive_orbs_glow:SetTooltip(L['OPTIONS_EXPLOSIVE_ORBS_GLOW_TOOLTIP']);
    self.explosive_orbs_glow:AddToSearch(button, L['OPTIONS_EXPLOSIVE_ORBS_GLOW_TOOLTIP']);
    self.explosive_orbs_glow:SetChecked(O.db.explosive_orbs_glow);
    self.explosive_orbs_glow.Callback = function(self)
        O.db.explosive_orbs_glow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.explosive_orbs_counter = E.CreateCheckButton(self);
    self.explosive_orbs_counter:SetPosition('LEFT', self.explosive_orbs_glow.Label, 'RIGHT', 12, 0);
    self.explosive_orbs_counter:SetLabel(L['OPTIONS_EXPLOSIVE_ORBS_COUNTER']);
    self.explosive_orbs_counter:SetTooltip(L['OPTIONS_EXPLOSIVE_ORBS_COUNTER_TOOLTIP']);
    self.explosive_orbs_counter:AddToSearch(button, L['OPTIONS_EXPLOSIVE_ORBS_COUNTER_TOOLTIP']);
    self.explosive_orbs_counter:SetChecked(O.db.explosive_orbs_counter);
    self.explosive_orbs_counter.Callback = function(self)
        O.db.explosive_orbs_counter = self:GetChecked();

        if O.db.explosive_orbs_counter then
            S:GetNameplateModule('MythicPlusExplosiveOrbs').OrbsCounter:CountOrbs();
        else
            S:GetNameplateModule('MythicPlusExplosiveOrbs').OrbsCounter:Hide();
        end

        Handler:UpdateAll();
    end

    local OtherHeader = E.CreateHeader(self, L['OPTIONS_OTHER']);
    OtherHeader:SetPosition('TOPLEFT', self.explosive_orbs_crosshair, 'BOTTOMLEFT', 0, -4);
    OtherHeader:SetW(self:GetWidth());

    self.mythic_plus_auto_slot_keystone = E.CreateCheckButton(self);
    self.mythic_plus_auto_slot_keystone:SetPosition('TOPLEFT', OtherHeader, 'BOTTOMLEFT', 0, -8);
    self.mythic_plus_auto_slot_keystone:SetLabel(L['OPTIONS_MYTHIC_PLUS_AUTO_SLOT_KEYSTONE']);
    self.mythic_plus_auto_slot_keystone:SetTooltip(L['OPTIONS_MYTHIC_PLUS_AUTO_SLOT_KEYSTONE_TOOLTIP']);
    self.mythic_plus_auto_slot_keystone:AddToSearch(button, L['OPTIONS_MYTHIC_PLUS_AUTO_SLOT_KEYSTONE_TOOLTIP']);
    self.mythic_plus_auto_slot_keystone:SetChecked(O.db.mythic_plus_auto_slot_keystone);
    self.mythic_plus_auto_slot_keystone.Callback = function(self)
        O.db.mythic_plus_auto_slot_keystone = self:GetChecked();
    end

    self.spiteful_enabled = E.CreateCheckButton(self);
    self.spiteful_enabled:SetPosition('TOPLEFT', self.mythic_plus_auto_slot_keystone, 'BOTTOMLEFT', 0, -8);
    self.spiteful_enabled:SetLabel(L['OPTIONS_SPITEFUL_ICON']);
    self.spiteful_enabled:SetTooltip(L['OPTIONS_SPITEFUL_ICON_TOOLTIP']);
    self.spiteful_enabled:AddToSearch(button);
    self.spiteful_enabled:SetChecked(O.db.spiteful_enabled);
    self.spiteful_enabled.Callback = function(self)
        O.db.spiteful_enabled = self:GetChecked();

        panel.spiteful_show_only_on_me:SetEnabled(O.db.spiteful_enabled);
        panel.spiteful_glow:SetEnabled(O.db.spiteful_enabled);
        panel.spiteful_glow_color:SetEnabled(O.db.spiteful_enabled);

        Handler:UpdateAll();
    end

    self.spiteful_show_only_on_me = E.CreateCheckButton(self);
    self.spiteful_show_only_on_me:SetPosition('LEFT', self.spiteful_enabled.Label, 'RIGHT', 12, 0);
    self.spiteful_show_only_on_me:SetLabel(L['OPTIONS_SPITEFUL_SHOW_ONLY_ON_ME']);
    self.spiteful_show_only_on_me:SetTooltip(L['OPTIONS_SPITEFUL_SHOW_ONLY_ON_ME_TOOLTIP']);
    self.spiteful_show_only_on_me:AddToSearch(button, L['OPTIONS_SPITEFUL_SHOW_ONLY_ON_ME_TOOLTIP']);
    self.spiteful_show_only_on_me:SetChecked(O.db.spiteful_show_only_on_me);
    self.spiteful_show_only_on_me:SetEnabled(O.db.spiteful_enabled);
    self.spiteful_show_only_on_me.Callback = function(self)
        O.db.spiteful_show_only_on_me = self:GetChecked();
        Handler:UpdateAll();
    end

    self.spiteful_glow = E.CreateCheckButton(self);
    self.spiteful_glow:SetPosition('LEFT', self.spiteful_show_only_on_me.Label, 'RIGHT', 12, 0);
    self.spiteful_glow:SetLabel(L['OPTIONS_SPITEFUL_GLOW']);
    self.spiteful_glow:SetTooltip(L['OPTIONS_SPITEFUL_GLOW_TOOLTIP']);
    self.spiteful_glow:AddToSearch(button, L['OPTIONS_SPITEFUL_GLOW_TOOLTIP']);
    self.spiteful_glow:SetChecked(O.db.spiteful_glow);
    self.spiteful_glow:SetEnabled(O.db.spiteful_enabled);
    self.spiteful_glow.Callback = function(self)
        O.db.spiteful_glow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.spiteful_glow_color = E.CreateColorPicker(self);
    self.spiteful_glow_color:SetPosition('LEFT', self.spiteful_glow.Label, 'RIGHT', 12, 0);
    self.spiteful_glow_color:SetTooltip(L['OPTIONS_SPITEFUL_GLOW_COLOR_TOOLTIP']);
    self.spiteful_glow_color:AddToSearch(button, L['OPTIONS_SPITEFUL_GLOW_COLOR_TOOLTIP']);
    self.spiteful_glow_color:SetValue(unpack(O.db.spiteful_glow_color));
    self.spiteful_glow_color:SetEnabled(O.db.spiteful_enabled);
    self.spiteful_glow_color.OnValueChanged = function(_, r, g, b, a)
        O.db.spiteful_glow_color[1] = r;
        O.db.spiteful_glow_color[2] = g;
        O.db.spiteful_glow_color[3] = b;
        O.db.spiteful_glow_color[4] = a or 1;

        Handler:UpdateAll();
    end

    self.mythic_plus_questunwatch_enabled = E.CreateCheckButton(self);
    self.mythic_plus_questunwatch_enabled:SetPosition('TOPLEFT', self.spiteful_enabled, 'BOTTOMLEFT', 0, -8);
    self.mythic_plus_questunwatch_enabled:SetLabel(L['OPTIONS_MYTHIC_PLUS_QUESTUNWATCH_ENABLED']);
    self.mythic_plus_questunwatch_enabled:SetTooltip(L['OPTIONS_MYTHIC_PLUS_QUESTUNWATCH_ENABLED_TOOLTIP']);
    self.mythic_plus_questunwatch_enabled:AddToSearch(button);
    self.mythic_plus_questunwatch_enabled:SetChecked(O.db.mythic_plus_questunwatch_enabled);
    self.mythic_plus_questunwatch_enabled.Callback = function(self)
        O.db.mythic_plus_questunwatch_enabled = self:GetChecked();
        Handler:UpdateAll();
    end
end

function Module:MythicDungeonTools()
    isMDTLoaded = true;

    panel.mythic_plus_percentage_use_mode:SetEnabled(O.db.mythic_plus_percentage_enabled);
    panel.mythic_plus_percentage_use_mode:SetList(O.Lists.mythic_plus_percentage_use_mode);
    panel.mythic_plus_percentage_use_mode:SetValue(O.db.mythic_plus_percentage_use_mode);
end

function Module:StartUp()
    self:RegisterAddon('MythicDungeonTools');
end