local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Useful');

local LSM = S.Libraries.LSM;

O.frame.Left.Useful, O.frame.Right.Useful = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_USEFUL']), 'useful', 9);
local button = O.frame.Left.Useful;
local panel = O.frame.Right.Useful;

panel.Load = function(self)
    local Handler = S:GetNameplateModule('Handler');

    self.quest_indicator_enabled = E.CreateCheckButton(self);
    self.quest_indicator_enabled:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.quest_indicator_enabled:SetLabel(L['OPTIONS_QUEST_INDICATOR_ENABLED']);
    self.quest_indicator_enabled:SetTooltip(L['OPTIONS_QUEST_INDICATOR_ENABLED_TOOLTIP']);
    self.quest_indicator_enabled:AddToSearch(button);
    self.quest_indicator_enabled:SetChecked(O.db.quest_indicator_enabled);
    self.quest_indicator_enabled.Callback = function(self)
        O.db.quest_indicator_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.quest_indicator_position = E.CreateDropdown('plain', self);
    self.quest_indicator_position:SetPosition('LEFT', self.quest_indicator_enabled.Label, 'RIGHT', 12, 0);
    self.quest_indicator_position:SetSize(110, 20);
    self.quest_indicator_position:SetList(O.Lists.quest_indicator_position);
    self.quest_indicator_position:SetValue(O.db.quest_indicator_position);
    self.quest_indicator_position:SetLabel(L['OPTIONS_QUEST_INDICATOR_POSITION']);
    self.quest_indicator_position:SetTooltip(L['OPTIONS_QUEST_INDICATOR_POSITION_TOOLTIP']);
    self.quest_indicator_position:AddToSearch(button, L['OPTIONS_QUEST_INDICATOR_POSITION_TOOLTIP']);
    self.quest_indicator_position.OnValueChangedCallback = function(_, value)
        O.db.quest_indicator_position = tonumber(value);
        Handler:UpdateAll();
    end

    self.stealth_detect_enabled = E.CreateCheckButton(self);
    self.stealth_detect_enabled:SetPosition('TOPLEFT', self.quest_indicator_enabled, 'BOTTOMLEFT', 0, -8);
    self.stealth_detect_enabled:SetLabel(L['OPTIONS_STEALTH_DETECT_ENABLED']);
    self.stealth_detect_enabled:SetTooltip(L['OPTIONS_STEALTH_DETECT_ENABLED_TOOLTIP']);
    self.stealth_detect_enabled:AddToSearch(button);
    self.stealth_detect_enabled:SetChecked(O.db.stealth_detect_enabled);
    self.stealth_detect_enabled.Callback = function(self)
        O.db.stealth_detect_enabled = self:GetChecked();

        panel.stealth_detect_always:SetEnabled(O.db.stealth_detect_enabled);

        Handler:UpdateAll();
    end

    self.stealth_detect_always = E.CreateCheckButton(self);
    self.stealth_detect_always:SetPosition('LEFT', self.stealth_detect_enabled.Label, 'RIGHT', 12, 0);
    self.stealth_detect_always:SetLabel(L['OPTIONS_STEALTH_DETECT_ALWAYS']);
    self.stealth_detect_always:SetTooltip(L['OPTIONS_STEALTH_DETECT_ALWAYS_TOOLTIP']);
    self.stealth_detect_always:AddToSearch(button, L['OPTIONS_STEALTH_DETECT_ALWAYS_TOOLTIP']);
    self.stealth_detect_always:SetChecked(O.db.stealth_detect_always);
    self.stealth_detect_always:SetEnabled(O.db.stealth_detect_enabled);
    self.stealth_detect_always.Callback = function(self)
        O.db.stealth_detect_always = self:GetChecked();
        Handler:UpdateAll();
    end

    self.totem_icon_enabled = E.CreateCheckButton(self);
    self.totem_icon_enabled:SetPosition('TOPLEFT', self.stealth_detect_enabled, 'BOTTOMLEFT', 0, -8);
    self.totem_icon_enabled:SetLabel(L['OPTIONS_TOTEM_ICON_ENABLED']);
    self.totem_icon_enabled:SetTooltip(L['OPTIONS_TOTEM_ICON_ENABLED_TOOLTIP']);
    self.totem_icon_enabled:AddToSearch(button, L['OPTIONS_TOTEM_ICON_ENABLED']);
    self.totem_icon_enabled:SetChecked(O.db.totem_icon_enabled);
    self.totem_icon_enabled.Callback = function(self)
        O.db.totem_icon_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.talking_head_suppress = E.CreateCheckButton(self);
    self.talking_head_suppress:SetPosition('TOPLEFT', self.totem_icon_enabled, 'BOTTOMLEFT', 0, -8);
    self.talking_head_suppress:SetLabel(L['OPTIONS_TALKING_HEAD_SUPPRESS']);
    self.talking_head_suppress:SetTooltip(L['OPTIONS_TALKING_HEAD_SUPPRESS_TOOLTIP']);
    self.talking_head_suppress:AddToSearch(button, L['OPTIONS_TALKING_HEAD_SUPPRESS_TOOLTIP']);
    self.talking_head_suppress:SetChecked(O.db.talking_head_suppress);
    self.talking_head_suppress.Callback = function(self)
        O.db.talking_head_suppress = self:GetChecked();

        panel.talking_head_suppress_always:SetEnabled(O.db.talking_head_suppress);

        Handler:UpdateAll();
    end

    self.talking_head_suppress_always = E.CreateCheckButton(self);
    self.talking_head_suppress_always:SetPosition('LEFT', self.talking_head_suppress.Label, 'RIGHT', 12, 0);
    self.talking_head_suppress_always:SetLabel(L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS']);
    self.talking_head_suppress_always:SetTooltip(L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS_TOOLTIP']);
    self.talking_head_suppress_always:AddToSearch(button, L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS_TOOLTIP']);
    self.talking_head_suppress_always:SetChecked(O.db.talking_head_suppress_always);
    self.talking_head_suppress_always:SetEnabled(O.db.talking_head_suppress);
    self.talking_head_suppress_always.Callback = function(self)
        O.db.talking_head_suppress_always = self:GetChecked();
        Handler:UpdateAll();
    end

    local SpellInterruptedHeader = E.CreateHeader(self, L['OPTIONS_SPELL_INTERRUPTED_ICON_HEADER']);
    SpellInterruptedHeader:SetPosition('TOPLEFT', self.talking_head_suppress, 'BOTTOMLEFT', 0, -8);
    SpellInterruptedHeader:SetW(self:GetWidth());

    self.spell_interrupted_icon = E.CreateCheckButton(self);
    self.spell_interrupted_icon:SetPosition('TOPLEFT', SpellInterruptedHeader, 'BOTTOMLEFT', 0, -4);
    self.spell_interrupted_icon:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON']);
    self.spell_interrupted_icon:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_TOOLTIP']);
    self.spell_interrupted_icon:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_TOOLTIP']);
    self.spell_interrupted_icon:SetChecked(O.db.spell_interrupted_icon);
    self.spell_interrupted_icon.Callback = function(self)
        O.db.spell_interrupted_icon = self:GetChecked();
        Handler:UpdateAll();
    end

    self.spell_interrupted_countdown_text = E.CreateFontString(self);
    self.spell_interrupted_countdown_text:SetPosition('TOPLEFT', self.spell_interrupted_icon, 'BOTTOMLEFT', 0, -8);
    self.spell_interrupted_countdown_text:SetText(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_TEXT']);

    self.spell_interrupted_icon_countdown_font_value = E.CreateDropdown('font', self);
    self.spell_interrupted_icon_countdown_font_value:SetPosition('TOPLEFT', self.spell_interrupted_countdown_text, 'BOTTOMLEFT', 0, -4);
    self.spell_interrupted_icon_countdown_font_value:SetSize(160, 20);
    self.spell_interrupted_icon_countdown_font_value:SetList(LSM:HashTable('font'));
    self.spell_interrupted_icon_countdown_font_value:SetValue(O.db.spell_interrupted_icon_countdown_font_value);
    self.spell_interrupted_icon_countdown_font_value:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_VALUE']);
    self.spell_interrupted_icon_countdown_font_value:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_VALUE']);
    self.spell_interrupted_icon_countdown_font_value.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_value = value;
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_size = E.CreateSlider(self);
    self.spell_interrupted_icon_countdown_font_size:SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_value, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_countdown_font_size:SetValues(O.db.spell_interrupted_icon_countdown_font_size, 2, 28, 1);
    self.spell_interrupted_icon_countdown_font_size:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SIZE']);
    self.spell_interrupted_icon_countdown_font_size:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SIZE']);
    self.spell_interrupted_icon_countdown_font_size.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_flag = E.CreateDropdown('plain', self);
    self.spell_interrupted_icon_countdown_font_flag:SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_size, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_countdown_font_flag:SetSize(160, 20);
    self.spell_interrupted_icon_countdown_font_flag:SetList(O.Lists.font_flags_localized);
    self.spell_interrupted_icon_countdown_font_flag:SetValue(O.db.spell_interrupted_icon_countdown_font_flag);
    self.spell_interrupted_icon_countdown_font_flag:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_FLAG']);
    self.spell_interrupted_icon_countdown_font_flag:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_FLAG']);
    self.spell_interrupted_icon_countdown_font_flag.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_countdown_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_countdown_font_shadow = E.CreateCheckButton(self);
    self.spell_interrupted_icon_countdown_font_shadow:SetPosition('LEFT', self.spell_interrupted_icon_countdown_font_flag, 'RIGHT', 8, 0);
    self.spell_interrupted_icon_countdown_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.spell_interrupted_icon_countdown_font_shadow:SetChecked(O.db.spell_interrupted_icon_countdown_font_shadow);
    self.spell_interrupted_icon_countdown_font_shadow:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SHADOW']);
    self.spell_interrupted_icon_countdown_font_shadow:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SHADOW']);
    self.spell_interrupted_icon_countdown_font_shadow.Callback = function(self)
        O.db.spell_interrupted_icon_countdown_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_show = E.CreateCheckButton(self);
    self.spell_interrupted_icon_caster_name_show:SetPosition('TOPLEFT', self.spell_interrupted_icon_countdown_font_value, 'BOTTOMLEFT', 0, -12);
    self.spell_interrupted_icon_caster_name_show:SetLabel(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW']);
    self.spell_interrupted_icon_caster_name_show:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW_TOOLTIP']);
    self.spell_interrupted_icon_caster_name_show:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW_TOOLTIP']);
    self.spell_interrupted_icon_caster_name_show:SetChecked(O.db.spell_interrupted_icon_caster_name_show);
    self.spell_interrupted_icon_caster_name_show.Callback = function(self)
        O.db.spell_interrupted_icon_caster_name_show = self:GetChecked();
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_value = E.CreateDropdown('font', self);
    self.spell_interrupted_icon_caster_name_font_value:SetPosition('TOPLEFT', self.spell_interrupted_icon_caster_name_show, 'BOTTOMLEFT', 0, -8);
    self.spell_interrupted_icon_caster_name_font_value:SetSize(160, 20);
    self.spell_interrupted_icon_caster_name_font_value:SetList(LSM:HashTable('font'));
    self.spell_interrupted_icon_caster_name_font_value:SetValue(O.db.spell_interrupted_icon_caster_name_font_value);
    self.spell_interrupted_icon_caster_name_font_value:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_VALUE']);
    self.spell_interrupted_icon_caster_name_font_value:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_VALUE']);
    self.spell_interrupted_icon_caster_name_font_value.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_value = value;
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_size = E.CreateSlider(self);
    self.spell_interrupted_icon_caster_name_font_size:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_value, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_caster_name_font_size:SetValues(O.db.spell_interrupted_icon_caster_name_font_size, 2, 28, 1);
    self.spell_interrupted_icon_caster_name_font_size:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SIZE']);
    self.spell_interrupted_icon_caster_name_font_size:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SIZE']);
    self.spell_interrupted_icon_caster_name_font_size.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_size = tonumber(value);
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_flag = E.CreateDropdown('plain', self);
    self.spell_interrupted_icon_caster_name_font_flag:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_size, 'RIGHT', 12, 0);
    self.spell_interrupted_icon_caster_name_font_flag:SetSize(160, 20);
    self.spell_interrupted_icon_caster_name_font_flag:SetList(O.Lists.font_flags_localized);
    self.spell_interrupted_icon_caster_name_font_flag:SetValue(O.db.spell_interrupted_icon_caster_name_font_flag);
    self.spell_interrupted_icon_caster_name_font_flag:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_FLAG']);
    self.spell_interrupted_icon_caster_name_font_flag:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_FLAG']);
    self.spell_interrupted_icon_caster_name_font_flag.OnValueChangedCallback = function(_, value)
        O.db.spell_interrupted_icon_caster_name_font_flag = tonumber(value);
        Handler:UpdateAll();
    end

    self.spell_interrupted_icon_caster_name_font_shadow = E.CreateCheckButton(self);
    self.spell_interrupted_icon_caster_name_font_shadow:SetPosition('LEFT', self.spell_interrupted_icon_caster_name_font_flag, 'RIGHT', 8, 0);
    self.spell_interrupted_icon_caster_name_font_shadow:SetLabel(L['OPTIONS_FONT_SHADOW']);
    self.spell_interrupted_icon_caster_name_font_shadow:SetChecked(O.db.spell_interrupted_icon_caster_name_font_shadow);
    self.spell_interrupted_icon_caster_name_font_shadow:SetTooltip(L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SHADOW']);
    self.spell_interrupted_icon_caster_name_font_shadow:AddToSearch(button, L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SHADOW']);
    self.spell_interrupted_icon_caster_name_font_shadow.Callback = function(self)
        O.db.spell_interrupted_icon_caster_name_font_shadow = self:GetChecked();
        Handler:UpdateAll();
    end

    local HealersMarksHeader = E.CreateHeader(self, L['OPTIONS_HEADER_HEALERS_MARKS']);
    HealersMarksHeader:SetPosition('TOPLEFT', self.spell_interrupted_icon_caster_name_font_value, 'BOTTOMLEFT', 0, -8);
    HealersMarksHeader:SetW(self:GetWidth());

    self.pvp_healers_enabled = E.CreateCheckButton(self);
    self.pvp_healers_enabled:SetPosition('TOPLEFT', HealersMarksHeader, 'BOTTOMLEFT', 0, -4);
    self.pvp_healers_enabled:SetLabel(L['OPTIONS_PVP_HEALERS_ENABLED']);
    self.pvp_healers_enabled:SetTooltip(L['OPTIONS_PVP_HEALERS_ENABLED_TOOLTIP']);
    self.pvp_healers_enabled:AddToSearch(button, L['OPTIONS_PVP_HEALERS_ENABLED_TOOLTIP']);
    self.pvp_healers_enabled:SetChecked(O.db.pvp_healers_enabled);
    self.pvp_healers_enabled.Callback = function(self)
        O.db.pvp_healers_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.pvp_healers_icon_scale = E.CreateSlider(self);
    self.pvp_healers_icon_scale:SetPosition('LEFT', self.pvp_healers_enabled.Label, 'RIGHT', 12, 0);
    self.pvp_healers_icon_scale:SetValues(O.db.pvp_healers_icon_scale, 0.25, 4, 0.05);
    self.pvp_healers_icon_scale:SetTooltip(L['OPTIONS_PVP_HEALERS_SCALE_TOOLTIP']);
    self.pvp_healers_icon_scale:AddToSearch(button, L['OPTIONS_PVP_HEALERS_SCALE_TOOLTIP']);
    self.pvp_healers_icon_scale.OnValueChangedCallback = function(_, value)
        O.db.pvp_healers_icon_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.pvp_healers_sound = E.CreateCheckButton(self);
    self.pvp_healers_sound:SetPosition('LEFT', self.pvp_healers_icon_scale, 'RIGHT', 12, 0);
    self.pvp_healers_sound:SetLabel(L['OPTIONS_PVP_HEALERS_SOUND']);
    self.pvp_healers_sound:SetTooltip(L['OPTIONS_PVP_HEALERS_SOUND_TOOLTIP']);
    self.pvp_healers_sound:AddToSearch(button, L['OPTIONS_PVP_HEALERS_SOUND_TOOLTIP']);
    self.pvp_healers_sound:SetChecked(O.db.pvp_healers_sound);
    self.pvp_healers_sound.Callback = function(self)
        O.db.pvp_healers_sound = self:GetChecked();
        Handler:UpdateAll();
    end

    self.pve_healers_enabled = E.CreateCheckButton(self);
    self.pve_healers_enabled:SetPosition('TOPLEFT', self.pvp_healers_enabled, 'BOTTOMLEFT', 0, -8);
    self.pve_healers_enabled:SetLabel(L['OPTIONS_PVE_HEALERS_ENABLED']);
    self.pve_healers_enabled:SetTooltip(L['OPTIONS_PVE_HEALERS_ENABLED_TOOLTIP']);
    self.pve_healers_enabled:AddToSearch(button, L['OPTIONS_PVE_HEALERS_ENABLED_TOOLTIP']);
    self.pve_healers_enabled:SetChecked(O.db.pve_healers_enabled);
    self.pve_healers_enabled.Callback = function(self)
        O.db.pve_healers_enabled = self:GetChecked();
        Handler:UpdateAll();
    end

    self.pve_healers_icon_scale = E.CreateSlider(self);
    self.pve_healers_icon_scale:SetPosition('LEFT', self.pve_healers_enabled.Label, 'RIGHT', 12, 0);
    self.pve_healers_icon_scale:SetValues(O.db.pve_healers_icon_scale, 0.25, 4, 0.05);
    self.pve_healers_icon_scale:SetTooltip(L['OPTIONS_PVE_HEALERS_SCALE_TOOLTIP']);
    self.pve_healers_icon_scale:AddToSearch(button, L['OPTIONS_PVE_HEALERS_SCALE_TOOLTIP']);
    self.pve_healers_icon_scale.OnValueChangedCallback = function(_, value)
        O.db.pve_healers_icon_scale = tonumber(value);
        Handler:UpdateAll();
    end

    self.pve_healers_sound = E.CreateCheckButton(self);
    self.pve_healers_sound:SetPosition('LEFT', self.pve_healers_icon_scale, 'RIGHT', 12, 0);
    self.pve_healers_sound:SetLabel(L['OPTIONS_PVE_HEALERS_SOUND']);
    self.pve_healers_sound:SetTooltip(L['OPTIONS_PVE_HEALERS_SOUND_TOOLTIP']);
    self.pve_healers_sound:AddToSearch(button, L['OPTIONS_PVE_HEALERS_SOUND_TOOLTIP']);
    self.pve_healers_sound:SetChecked(O.db.pve_healers_sound);
    self.pve_healers_sound.Callback = function(self)
        O.db.pve_healers_sound = self:GetChecked();
        Handler:UpdateAll();
    end
end