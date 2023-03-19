local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('Options_Categories_Global');

local LSM = S.Libraries.LSM;

O.frame.Left.Global, O.frame.Right.Global = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_GLOBAL']), 'global', 10);
local button = O.frame.Left.Global;
local panel = O.frame.Right.Global;

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    local FontHeader = E.CreateHeader(self, L['OPTIONS_GLOBAL_FONT_HEADER']);
    FontHeader:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    FontHeader:SetW(self:GetWidth());

    self.use_global_font_value = E.CreateCheckButton(self);
    self.use_global_font_value:SetPosition('TOPLEFT', FontHeader, 'BOTTOMLEFT', 0, -8);
    self.use_global_font_value:SetLabel(L['USE']);
    self.use_global_font_value:SetChecked(O.db.use_global_font_value);
    self.use_global_font_value:SetTooltip(L['OPTIONS_USE_GLOBAL_FONT_VALUE_TOOLTIP']);
    self.use_global_font_value:AddToSearch(button, L['OPTIONS_USE_GLOBAL_FONT_VALUE_TOOLTIP']);
    self.use_global_font_value.Callback = function(self)
        O.db.use_global_font_value = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.global_font_value = E.CreateDropdown('font', self);
    self.global_font_value:SetPosition('LEFT', self.use_global_font_value.Label, 'RIGHT', 16, 0);
    self.global_font_value:SetSize(160, 20);
    self.global_font_value:SetList(LSM:HashTable('font'));
    self.global_font_value:SetValue(O.db.global_font_value);
    self.global_font_value:SetTooltip(L['FONT_VALUE']);
    self.global_font_value.OnValueChangedCallback = function(_, value)
        O.db.global_font_value = value;
        Stripes:UpdateAll();
    end

    self.use_global_font_size = E.CreateCheckButton(self);
    self.use_global_font_size:SetPosition('TOPLEFT', self.use_global_font_value, 'BOTTOMLEFT', 0, -10);
    self.use_global_font_size:SetLabel(L['USE']);
    self.use_global_font_size:SetChecked(O.db.use_global_font_size);
    self.use_global_font_size:SetTooltip(L['OPTIONS_USE_GLOBAL_FONT_SIZE_TOOLTIP']);
    self.use_global_font_size:AddToSearch(button, L['OPTIONS_USE_GLOBAL_FONT_SIZE_TOOLTIP']);
    self.use_global_font_size.Callback = function(self)
        O.db.use_global_font_size = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.global_font_size = E.CreateSlider(self);
    self.global_font_size:SetPosition('LEFT', self.use_global_font_size.Label, 'RIGHT', 16, 0);
    self.global_font_size:SetW(162);
    self.global_font_size:SetValues(O.db.global_font_size, 3, 28, 1);
    self.global_font_size:SetTooltip(L['FONT_SIZE']);
    self.global_font_size.OnValueChangedCallback = function(_, value)
        O.db.global_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.use_global_font_flag = E.CreateCheckButton(self);
    self.use_global_font_flag:SetPosition('TOPLEFT', self.use_global_font_size, 'BOTTOMLEFT', 0, -10);
    self.use_global_font_flag:SetLabel(L['USE']);
    self.use_global_font_flag:SetChecked(O.db.use_global_font_flag);
    self.use_global_font_flag:SetTooltip(L['OPTIONS_USE_GLOBAL_FONT_FLAG_TOOLTIP']);
    self.use_global_font_flag:AddToSearch(button, L['OPTIONS_USE_GLOBAL_FONT_FLAG_TOOLTIP']);
    self.use_global_font_flag.Callback = function(self)
        O.db.use_global_font_flag = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.global_font_flag = E.CreateDropdown('plain', self);
    self.global_font_flag:SetPosition('LEFT', self.use_global_font_flag.Label, 'RIGHT', 16, 0);
    self.global_font_flag:SetSize(160, 20);
    self.global_font_flag:SetList(O.Lists.font_flags_localized);
    self.global_font_flag:SetValue(O.db.global_font_flag);
    self.global_font_flag:SetTooltip(L['FONT_FLAG']);
    self.global_font_flag.OnValueChangedCallback = function(_, value)
        O.db.global_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.use_global_font_shadow = E.CreateCheckButton(self);
    self.use_global_font_shadow:SetPosition('TOPLEFT', self.use_global_font_flag, 'BOTTOMLEFT', 0, -10);
    self.use_global_font_shadow:SetLabel(L['USE']);
    self.use_global_font_shadow:SetChecked(O.db.use_global_font_shadow);
    self.use_global_font_shadow:SetTooltip(L['OPTIONS_USE_GLOBAL_FONT_SHADOW_TOOLTIP']);
    self.use_global_font_shadow:AddToSearch(button, L['OPTIONS_USE_GLOBAL_FONT_SHADOW_TOOLTIP']);
    self.use_global_font_shadow.Callback = function(self)
        O.db.use_global_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.global_font_shadow = E.CreateCheckButton(self);
    self.global_font_shadow:SetPosition('LEFT', self.use_global_font_shadow.Label, 'RIGHT', 16, 0);
    self.global_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.global_font_shadow:SetChecked(O.db.global_font_shadow);
    self.global_font_shadow:SetTooltip(L['FONT_SHADOW']);
    self.global_font_shadow.Callback = function(self)
        O.db.global_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end
end