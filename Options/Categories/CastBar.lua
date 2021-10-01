local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CastBar');

-- WoW API
local GetSpellInfo = GetSpellInfo;

local LSM = S.Libraries.LSM;

O.frame.Left.CastBar, O.frame.Right.CastBar = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CASTBAR']), 'castbar', 5);
local button = O.frame.Left.CastBar;
local panel = O.frame.Right.CastBar;

panel.TabsData = {
    [1] = {
        name  = 'CommonTab',
        title = string.upper(L['OPTIONS_CAST_BAR_TAB_COMMON']),
    },
    [2] = {
        name  = 'TimerTab',
        title = string.upper(L['OPTIONS_CAST_BAR_TAB_TIMER']),
    },
    [3] = {
        name  = 'CustomCastsTab',
        title = string.upper(L['OPTIONS_CAST_BAR_TAB_CUSTOMCASTS']),
    },
};

local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local BACKDROP_BORDER_2 = { bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Buttons\\WHITE8x8', edgeSize = 2 };
local NAME_WIDTH = 410;
local CATEGORY_MAX_LETTERS = 10;

panel.categoryId = 0;

local function AddCustomCast(spellId)
    if O.db.castbar_custom_casts_data[spellId] then
        return;
    end

    O.db.castbar_custom_casts_data[spellId] = {
        id             = spellId,
        enabled        = true,
        color_enabled  = false,
        color_category = 0,
        color          = { 0.1, 0.1, 0.1, 1 },
        glow_enabled   = true,
        glow_type      = 1,
        category_id    = 0,
    };
end

local profilesList = {};
panel.UpdateProfilesDropdown = function(self)
    wipe(profilesList);

    for _, data in pairs(StripesDB.profiles) do
        if data.profileName ~= O.activeProfileName then
            table.insert(profilesList, data.profileName);
        end
    end

    table.sort(profilesList, function(a, b)
        if a == b then
            return true;
        end

        if a == L['OPTIONS_PROFILE_DEFAULT_NAME'] then
            return true;
        end

        if b == L['OPTIONS_PROFILE_DEFAULT_NAME'] then
            return false;
        end

        return a < b;
    end);

    if self.ProfilesDropdown then
        self.ProfilesDropdown:SetEnabled(#profilesList > 1);
        self.ProfilesDropdown:SetList(profilesList);
        self.ProfilesDropdown:SetValue(nil);
    end
end

local DataCustomCastsRow = {};

local ExtendedOptions = CreateFrame('Frame', nil, panel, 'BackdropTemplate');
ExtendedOptions:SetFrameLevel(100);
ExtendedOptions:SetSize(260, 220);
ExtendedOptions:SetBackdrop(BACKDROP_BORDER_2);
ExtendedOptions:SetClampedToScreen(true);
ExtendedOptions:SetShown(false);

ExtendedOptions.Icon = ExtendedOptions:CreateTexture(nil, 'ARTWORK');
ExtendedOptions.Icon:SetPoint('TOPLEFT', ExtendedOptions, 'TOPLEFT', 16, -10);
ExtendedOptions.Icon:SetSize(ROW_HEIGHT - 8, ROW_HEIGHT - 8);
ExtendedOptions.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

ExtendedOptions.NameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
ExtendedOptions.NameText:SetPoint('LEFT', ExtendedOptions.Icon, 'RIGHT', 8, 0);
ExtendedOptions.NameText:SetPoint('RIGHT', ExtendedOptions, 'RIGHT', -8, 0);

ExtendedOptions.Delimiter = E.CreateDelimiter(ExtendedOptions);
ExtendedOptions.Delimiter:SetPosition('TOPLEFT', ExtendedOptions.Icon, 'BOTTOMLEFT', -7, 0);
ExtendedOptions.Delimiter:SetW(ExtendedOptions:GetWidth() - 16);

ExtendedOptions.CategoryText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.CategoryText:SetPoint('TOPLEFT', ExtendedOptions.Delimiter, 'BOTTOMLEFT', 7, -2);
ExtendedOptions.CategoryText:SetText(L['CATEGORY']);

ExtendedOptions.Category = E.CreateDropdown('plain', ExtendedOptions);
ExtendedOptions.Category:SetPosition('TOPLEFT', ExtendedOptions.CategoryText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.Category:SetSize(140, 20);
ExtendedOptions.Category.OnValueChangedCallback = function(_, value)
    value = tonumber(value);

    if O.db.castbar_custom_casts_data[ExtendedOptions.id] then
        O.db.castbar_custom_casts_data[ExtendedOptions.id].category_id = value;
        panel:UpdateCustomCastsScroll();
    end
end

ExtendedOptions.ColorCategoryText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.ColorCategoryText:SetPoint('TOPLEFT', ExtendedOptions.Category, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.ColorCategoryText:SetText(L['COLOR_CATEGORY']);

ExtendedOptions.ColorCategory = E.CreateDropdown('color', ExtendedOptions);
ExtendedOptions.ColorCategory:SetPosition('TOPLEFT', ExtendedOptions.ColorCategoryText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.ColorCategory:SetSize(140, 20);
ExtendedOptions.ColorCategory.OnValueChangedCallback = function(_, index)
    index = tonumber(index);
    local combinedList = S:GetModule('Options_ColorCategory'):GetCombinedList();

    O.db.castbar_custom_casts_data[ExtendedOptions.id].color_enabled  = index ~= 0;
    O.db.castbar_custom_casts_data[ExtendedOptions.id].color_category = index;

    if combinedList[index] then
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[1] = combinedList[index].color[1];
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[2] = combinedList[index].color[2];
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[3] = combinedList[index].color[3];
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[4] = combinedList[index].color[4] or 1;
    else
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[1] = 0.1;
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[2] = 0.1;
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[3] = 0.1;
        O.db.castbar_custom_casts_data[ExtendedOptions.id].color[4] = 1;
    end

    panel:UpdateCustomCastsScroll();
    S:GetNameplateModule('Handler'):UpdateAll();

    ExtendedOptions:SetBackdropBorderColor(ExtendedOptions.anchor.highlightColor[1], ExtendedOptions.anchor.highlightColor[2], ExtendedOptions.anchor.highlightColor[3], ExtendedOptions.anchor.highlightColor[4]);
end

ExtendedOptions.GlowTypeText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.GlowTypeText:SetPoint('TOPLEFT', ExtendedOptions.ColorCategory, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.GlowTypeText:SetText(L['GLOW_TYPE']);

ExtendedOptions.GlowType = E.CreateDropdown('plain', ExtendedOptions);
ExtendedOptions.GlowType:SetPosition('TOPLEFT', ExtendedOptions.GlowTypeText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.GlowType:SetSize(140, 20);
ExtendedOptions.GlowType:SetList(O.Lists.glow_type_short_with_none);
ExtendedOptions.GlowType.OnValueChangedCallback = function(_, value)
    value = tonumber(value);

    O.db.castbar_custom_casts_data[ExtendedOptions.id].glow_enabled = value ~= 0;
    O.db.castbar_custom_casts_data[ExtendedOptions.id].glow_type    = value;

    panel:UpdateCustomCastsScroll();
    S:GetNameplateModule('Handler'):UpdateAll();
end

ExtendedOptions.RemoveButton = E.CreateTextureButton(ExtendedOptions, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.TRASH_WHITE, { 1, 0.2, 0.2, 1});
ExtendedOptions.RemoveButton:SetPosition('BOTTOMRIGHT', ExtendedOptions, 'BOTTOMRIGHT', -6, 8);
ExtendedOptions.RemoveButton:SetSize(16, 16);
ExtendedOptions.RemoveButton:SetScript('OnClick', function(_)
    if O.db.castbar_custom_casts_data[ExtendedOptions.id] then
        O.db.castbar_custom_casts_data[ExtendedOptions.id] = nil;

        ExtendedOptions:SetShown(false);
        ExtendedOptions.anchor.isHighlighted = false;
        ExtendedOptions.anchor.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

        panel:UpdateCustomCastsScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
end);

local function ExtendedOptionsHide()
    ExtendedOptions:SetShown(false);
    ExtendedOptions.anchor.isHighlighted = false;
    ExtendedOptions.anchor:SetBackdropColor(ExtendedOptions.anchor.backgroundColor[1], ExtendedOptions.anchor.backgroundColor[2], ExtendedOptions.anchor.backgroundColor[3], ExtendedOptions.anchor.backgroundColor[4]);
    ExtendedOptions.anchor.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
end

if UIDropDownMenu_HandleGlobalMouseEvent then
    local function ExtendedOptions_CloseNotActive()
        if not (O.frame and O.frame:IsShown()) then
            return;
        end

        if ExtendedOptions:IsShown() and not ExtendedOptions:IsMouseOver() and not ExtendedOptions.anchor:IsMouseOver() and not ExtendedOptions.ColorCategory.holderButton.list:IsMouseOver() then
            ExtendedOptionsHide();
        end
    end

    hooksecurefunc('UIDropDownMenu_HandleGlobalMouseEvent', function(b, event)
        if event == 'GLOBAL_MOUSE_DOWN' and (b == 'LeftButton' or b == 'RightButton') then
            ExtendedOptions_CloseNotActive();
        end
    end);
end

local function CreateCustomCastRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};
    frame.highlightColor  = frame.highlightColor or {};

    frame.ColorLine = frame:CreateTexture(nil, 'ARTWORK');
    frame.ColorLine:SetPoint('TOPLEFT', 0, -1);
    frame.ColorLine:SetPoint('BOTTOMLEFT', 0, 1);
    frame.ColorLine:SetWidth(4);

    frame.ToggleExtendedOptions = frame:CreateTexture(nil, 'ARTWORK');
    frame.ToggleExtendedOptions:SetPoint('RIGHT', frame, 'RIGHT', -8, 0);
    frame.ToggleExtendedOptions:SetSize(16, 16);
    frame.ToggleExtendedOptions:SetTexture(S.Media.Icons.TEXTURE);
    frame.ToggleExtendedOptions:SetTexCoord(unpack(S.Media.Icons.COORDS.GEAR_WHITE));
    frame.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

    frame:SetScript('OnClick', function(self)
        if IsShiftKeyDown() then
            if O.db.castbar_custom_casts_data[frame.id] then
                O.db.castbar_custom_casts_data[frame.id] = nil;

                self.isHighlighted = false;
                self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

                ExtendedOptions:SetShown(false);

                panel:UpdateCustomCastsScroll();
                S:GetNameplateModule('Handler'):UpdateAll();
            end

            return;
        end

        if not self:IsMouseOver() then
            ExtendedOptionsHide();
        end

        if ExtendedOptions:IsShown() then
            ExtendedOptions:SetShown(false);

            self.isHighlighted = false;
            self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        else
            ExtendedOptions.id = frame.id;
            ExtendedOptions.anchor = frame;
            ExtendedOptions:SetPoint('TOPLEFT', ExtendedOptions.anchor, 'TOPRIGHT', 0, 0);
            ExtendedOptions.ColorCategory:SetList();
            ExtendedOptions.ColorCategory:SetValue(frame.color_category);
            ExtendedOptions.GlowType:SetValue(frame.glow_type);
            ExtendedOptions.GlowType:UpdateScrollArea();
            ExtendedOptions.Category:SetList(frame.category_list);
            ExtendedOptions.Category:SetValue(frame.category_id);
            ExtendedOptions.Icon:SetTexture(frame.icon);
            ExtendedOptions.NameText:SetText(frame.name .. '  |cffaaaaaa[' .. frame.id .. ']|r');
            ExtendedOptions:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
            ExtendedOptions:SetBackdropBorderColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);
            ExtendedOptions:SetShown(true);

            self.isHighlighted = true;
            self:SetBackdropColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);
            self.ToggleExtendedOptions:SetVertexColor(1, 0.85, 0, 1);
        end
    end);

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 10, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.castbar_custom_casts_data[self:GetParent().id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4]);
    end);
    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        if not frame.isHighlighted then
            self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
        end
    end);

    frame.CategoryNameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.CategoryNameText:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.CategoryNameText:SetSize(60, ROW_HEIGHT);
    frame.CategoryNameText:SetTextColor(0.67, 0.67, 0.67);
    frame.CategoryNameText:SetJustifyH('RIGHT');

    frame.Icon = frame:CreateTexture(nil, 'ARTWORK');
    frame.Icon:SetPoint('LEFT', frame.CategoryNameText, 'RIGHT', 8, 0);
    frame.Icon:SetSize(ROW_HEIGHT - 8, ROW_HEIGHT - 8);
    frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.Icon, 'RIGHT', 8, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);
        self.ToggleExtendedOptions:SetVertexColor(1, 0.85, 0, 1);

        self.NameText:SetText(self.name .. '    |cffaaaaaa' .. self.id .. ' | ' .. self.list[self.color_category] .. ' | ' .. O.Lists.glow_type_short_with_none[self.glow_type] .. '|r');

        if self.id then
            GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT');
            GameTooltip:SetHyperlink('spell:' .. self.id);
            GameTooltip:Show();
        end
    end);

    frame:HookScript('OnLeave', function(self)
        if not self.isHighlighted then
            self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        end

        self.NameText:SetText(self.name);

        GameTooltip_Hide();
    end);
end

local function UpdateCustomCastRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.castbar_custom_casts_scrollarea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.castbar_custom_casts_scrollarea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataCustomCastsRow[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataCustomCastsRow[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.CategoryNameText:SetText(frame.category_list[frame.category_id]);
    frame.Icon:SetTexture(frame.icon);
    frame.NameText:SetText(frame.name);
    frame.ColorLine:SetColorTexture(frame.color[1], frame.color[2], frame.color[3], frame.color[4]);
    frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4] = frame.color[1], frame.color[2], frame.color[3], 0.5;

    if frame.isHighlighted then
        frame:SetBackdropColor(frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4]);
    end
end

local sortedData = {};
panel.UpdateCustomCastsScroll = function()
    wipe(DataCustomCastsRow);
    wipe(sortedData);

    for id in pairs(O.db.castbar_custom_casts_data) do
        table.insert(sortedData, id);
    end

    table.sort(sortedData, function(a, b)
        return (GetSpellInfo(a)) < (GetSpellInfo(b));
    end);

    local combinedList = S:GetModule('Options_ColorCategory'):GetCombinedList();

    panel.CastBarCustomCastsFramePool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local name, icon, data;
    local found;

    for _, id in ipairs(sortedData) do
        name, _, icon = GetSpellInfo(id);
        data = O.db.castbar_custom_casts_data[id];

        if panel.searchWordLower then
            found = string.find(string.lower(name), panel.searchWordLower, 1, true);
        elseif panel.categoryId then
            found = (panel.categoryId == 0 or (panel.categoryId == 0 and not data.category_id) or data.category_id == panel.categoryId);
        else
            found = true;
        end

        if found then
            index = index + 1;

            frame, isNew = panel.CastBarCustomCastsFramePool:Acquire();

            table.insert(DataCustomCastsRow, frame);

            if isNew then
                CreateCustomCastRow(frame);
            end

            frame.index          = index;
            frame.id             = id;
            frame.name           = name;
            frame.icon           = icon;
            frame.enabled        = data.enabled;
            frame.glow_enabled   = data.glow_type ~= 0;
            frame.glow_type      = data.glow_type;

            if combinedList[data.color_category] then
                O.db.castbar_custom_casts_data[id].color_enabled  = true;
                O.db.castbar_custom_casts_data[id].color_category = data.color_category;

                O.db.castbar_custom_casts_data[id].color[1] = combinedList[data.color_category].color[1];
                O.db.castbar_custom_casts_data[id].color[2] = combinedList[data.color_category].color[2];
                O.db.castbar_custom_casts_data[id].color[3] = combinedList[data.color_category].color[3];
                O.db.castbar_custom_casts_data[id].color[4] = combinedList[data.color_category].color[4] or 1;
            else
                O.db.castbar_custom_casts_data[id].color_enabled  = false;
                O.db.castbar_custom_casts_data[id].color_category = 0;

                O.db.castbar_custom_casts_data[id].color[1] = 0.1;
                O.db.castbar_custom_casts_data[id].color[2] = 0.1;
                O.db.castbar_custom_casts_data[id].color[3] = 0.1;
                O.db.castbar_custom_casts_data[id].color[4] = 1;
            end

            frame.color_enabled  = O.db.castbar_custom_casts_data[id].color_enabled;
            frame.color_category = O.db.castbar_custom_casts_data[id].color_category;
            frame.color = O.db.castbar_custom_casts_data[id].color;
            frame.list  = S:GetModule('Options_ColorCategory'):GetDropdownList();

            if O.db.castbar_custom_casts_category_data[data.category_id] then
                O.db.castbar_custom_casts_data[id].category_id = data.category_id;
            else
                O.db.castbar_custom_casts_data[id].category_id = 0;
            end

            frame.category_id   = O.db.castbar_custom_casts_data[id].category_id;
            frame.category_list = panel:GetCategoriesDropdown();

            UpdateCustomCastRow(frame);

            frame:SetShown(true);
        end
    end

    PixelUtil.SetSize(panel.castbar_custom_casts_scrollchild, panel.castbar_custom_casts_editframe:GetWidth(), panel.castbar_custom_casts_editframe:GetHeight() - (panel.castbar_custom_casts_editframe:GetHeight() % ROW_HEIGHT + 8));
end

panel.CategoriesDropdown = {};
panel.GetCategoriesDropdown = function(self)
    wipe(self.CategoriesDropdown);

    for index, data in ipairs(O.db.castbar_custom_casts_category_data) do
        self.CategoriesDropdown[index] = data.name;
    end

    self.CategoriesDropdown[0] = L['OPTIONS_CATEGORY_ALL'];

    return self.CategoriesDropdown;
end

local DataCategoryListRows = {};
panel.CreateCategoryListRow = function(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame, 'LEFT', 6, 0);
    frame.NameText:SetSize(170, ROW_HEIGHT);

    frame.EditBox = E.CreateEditBox(frame);
    frame.EditBox:SetPosition('LEFT', frame, 'LEFT', 6, 0);
    frame.EditBox:SetFrameLevel(frame.EditBox:GetFrameLevel() + 10);
    frame.EditBox:SetSize(170, ROW_HEIGHT);
    frame.EditBox:SetMaxLetters(CATEGORY_MAX_LETTERS);
    frame.EditBox:SetShown(false);
    frame.EditBox:SetScript('OnEnterPressed', function(self)
        local index   = self:GetParent().index;
        local newName = strtrim(self:GetText());

        if not newName or newName == '' then
            return self:SetShown(false);
        end

        if not index or not O.db.castbar_custom_casts_category_data[index] then
            return self:SetShown(false);
        end

        if O.db.castbar_custom_casts_category_data[index].name == newName then
            return self:SetShown(false);
        end

        for _, data in ipairs(O.db.castbar_custom_casts_category_data) do
            if data.name == newName then
                return self:SetShown(false);
            end
        end

        O.db.castbar_custom_casts_category_data[index].name = newName;

        panel.UpdateCustomCastsScroll();
        panel.UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown());
        panel.CategoryDropdown:SetValue(panel.CategoryDropdown:GetValue());

        self:SetShown(false);
    end);
    frame.EditBox.FocusLostCallback = function(self)
        self:SetShown(false);
    end

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -8, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        table.remove(O.db.castbar_custom_casts_category_data, self:GetParent().index);

        panel.UpdateCustomCastsScroll();
        panel.UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown());
        panel.CategoryDropdown:SetValue(0);
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame.EditButton = E.CreateTextureButton(frame, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.PENCIL_WHITE);
    frame.EditButton:SetPosition('RIGHT', frame.RemoveButton, 'LEFT', -8, 0);
    frame.EditButton:SetSize(14, 14);
    frame.EditButton:SetScript('OnClick', function(self)
        self:GetParent().EditBox:SetText(self:GetParent().name);
        self:GetParent().EditBox:SetShown(true);
        self:GetParent().EditBox:SetFocus();
        self:GetParent().EditBox:SetCursorPosition(0);
    end);
    frame.EditButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EditButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame:HookScript('OnDoubleClick', function(self)
        self.EditBox:SetText(self.name);
        self.EditBox:SetShown(true);
        self.EditBox:SetFocus();
        self.EditBox:SetCursorPosition(0);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);
end

panel.UpdateCategoryListRow = function(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.CategoryListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.CategoryListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataCategoryListRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataCategoryListRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.NameText:SetText(frame.name);
end

panel.UpdateCategoryListScroll = function()
    wipe(DataCategoryListRows);
    panel.CategoryListButtonPool:ReleaseAll();

    local frame, isNew;

    for index, data in ipairs(O.db.castbar_custom_casts_category_data) do
        frame, isNew = panel.CategoryListButtonPool:Acquire();

        table.insert(DataCategoryListRows, frame);

        if isNew then
            panel.CreateCategoryListRow(frame);
        end

        frame.index = index;
        frame.name  = data.name;

        panel.UpdateCategoryListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.CategoryListScrollArea.scrollChild, panel.CategoryListScroll:GetWidth(), panel.CategoryListScroll:GetHeight() - (panel.CategoryListScroll:GetHeight() % ROW_HEIGHT));
end

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Common Tab ----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.castbar_texture_value = E.CreateDropdown('statusbar', self.TabsFrames['CommonTab'].Content);
    self.castbar_texture_value:SetPosition('TOPLEFT', self.TabsFrames['CommonTab'].Content, 'TOPLEFT', 0, -4);
    self.castbar_texture_value:SetSize(200, 20);
    self.castbar_texture_value:SetList(LSM:HashTable('statusbar'));
    self.castbar_texture_value:SetValue(O.db.castbar_texture_value);
    self.castbar_texture_value:SetLabel(L['OPTIONS_TEXTURE']);
    self.castbar_texture_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP']);
    self.castbar_texture_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP'], self.Tabs[1]);
    self.castbar_texture_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_texture_value = value;
        Stripes:UpdateAll();
    end

    local Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_texture_value, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.castbar_text_offset_y = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_text_offset_y:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.castbar_text_offset_y:SetValues(O.db.castbar_text_offset_y, -50, 50, 1);
    self.castbar_text_offset_y:SetLabel(L['OPTIONS_CAST_BAR_TEXT_OFFSET_Y']);
    self.castbar_text_offset_y:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_OFFSET_Y_TOOLTIP']);
    self.castbar_text_offset_y:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_OFFSET_Y_TOOLTIP'], self.Tabs[1]);
    self.castbar_text_offset_y.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_text_font_value = E.CreateDropdown('font', self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_value:SetPosition('TOPLEFT', self.castbar_text_offset_y, 'BOTTOMLEFT', 0, -14);
    self.castbar_text_font_value:SetSize(160, 20);
    self.castbar_text_font_value:SetList(LSM:HashTable('font'));
    self.castbar_text_font_value:SetValue(O.db.castbar_text_font_value);
    self.castbar_text_font_value:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE']);
    self.castbar_text_font_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE'], self.Tabs[1]);
    self.castbar_text_font_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_value = value;
        Stripes:UpdateAll();
    end

    self.castbar_text_font_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_size:SetPosition('LEFT', self.castbar_text_font_value, 'RIGHT', 12, 0);
    self.castbar_text_font_size:SetValues(O.db.castbar_text_font_size, 3, 28, 1);
    self.castbar_text_font_size:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE']);
    self.castbar_text_font_size:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE'], self.Tabs[1]);
    self.castbar_text_font_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_text_font_flag = E.CreateDropdown('plain', self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_flag:SetPosition('LEFT', self.castbar_text_font_size, 'RIGHT', 12, 0);
    self.castbar_text_font_flag:SetSize(160, 20);
    self.castbar_text_font_flag:SetList(O.Lists.font_flags_localized);
    self.castbar_text_font_flag:SetValue(O.db.castbar_text_font_flag);
    self.castbar_text_font_flag:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG']);
    self.castbar_text_font_flag:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG'], self.Tabs[1]);
    self.castbar_text_font_flag.OnValueChangedCallback = function(_, value)
        O.db.castbar_text_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_text_font_shadow = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_text_font_shadow:SetPosition('LEFT', self.castbar_text_font_flag, 'RIGHT', 12, 0);
    self.castbar_text_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.castbar_text_font_shadow:SetChecked(O.db.castbar_text_font_shadow);
    self.castbar_text_font_shadow:SetTooltip(L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW']);
    self.castbar_text_font_shadow:AddToSearch(button, L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW'], self.Tabs[1]);
    self.castbar_text_font_shadow.Callback = function(self)
        O.db.castbar_text_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_text_font_value, 'BOTTOMLEFT', 0, -6);
    Delimiter:SetW(self:GetWidth());

    self.castbar_height = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_height:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -20);
    self.castbar_height:SetLabel(L['OPTIONS_CAST_BAR_HEIGHT']);
    self.castbar_height:SetTooltip(L['OPTIONS_CAST_BAR_HEIGHT_TOOLTIP']);
    self.castbar_height:AddToSearch(button, L['OPTIONS_CAST_BAR_HEIGHT_TOOLTIP'], self.Tabs[1]);
    self.castbar_height:SetValues(O.db.castbar_height, 1, 40, 1);
    self.castbar_height.OnValueChangedCallback = function(_, value)
        O.db.castbar_height = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_border_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_enabled:SetPosition('LEFT', self.castbar_height, 'RIGHT', 20, 0);
    self.castbar_border_enabled:SetLabel(L['OPTIONS_CAST_BAR_BORDER_ENABLED']);
    self.castbar_border_enabled:SetChecked(O.db.castbar_border_enabled);
    self.castbar_border_enabled:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_ENABLED_TOOLTIP']);
    self.castbar_border_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_enabled.Callback = function(self)
        O.db.castbar_border_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_border_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_color:SetPosition('LEFT', self.castbar_border_enabled.Label, 'RIGHT', 12, 0);
    self.castbar_border_color:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_COLOR_TOOLTIP']);
    self.castbar_border_color:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_color:SetValue(unpack(O.db.castbar_border_color));
    self.castbar_border_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_border_color[1] = r;
        O.db.castbar_border_color[2] = g;
        O.db.castbar_border_color[3] = b;
        O.db.castbar_border_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_border_size = E.CreateSlider(self.TabsFrames['CommonTab'].Content);
    self.castbar_border_size:SetPosition('LEFT', self.castbar_border_color, 'RIGHT', 12, 0);
    self.castbar_border_size:SetValues(O.db.castbar_border_size, 0.5, 10, 0.5);
    self.castbar_border_size:SetTooltip(L['OPTIONS_CAST_BAR_BORDER_SIZE_TOOLTIP']);
    self.castbar_border_size:AddToSearch(button, L['OPTIONS_CAST_BAR_BORDER_SIZE_TOOLTIP'], self.Tabs[1]);
    self.castbar_border_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_border_size = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_height, 'BOTTOMLEFT', 0, -6);
    Delimiter:SetW(self:GetWidth());

    local ResetCastBarColorsButton = E.CreateTextureButton(self.TabsFrames['CommonTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE);
    ResetCastBarColorsButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 4, -4);
    ResetCastBarColorsButton:SetTooltip(L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP']);
    ResetCastBarColorsButton:AddToSearch(button, L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP'], self.Tabs[1]);
    ResetCastBarColorsButton.Callback = function()
        panel.castbar_start_cast_color:SetValue(unpack(O.DefaultValues.castbar_start_cast_color));
        panel.castbar_start_channel_color:SetValue(unpack(O.DefaultValues.castbar_start_channel_color));
        panel.castbar_noninterruptible_color:SetValue(unpack(O.DefaultValues.castbar_noninterruptible_color));
        panel.castbar_failed_cast_color:SetValue(unpack(O.DefaultValues.castbar_failed_cast_color));
        panel.castbar_interrupt_ready_tick_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_tick_color));
        panel.castbar_interrupt_ready_in_time_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_ready_in_time_color));
        panel.castbar_interrupt_not_ready_color:SetValue(unpack(O.DefaultValues.castbar_interrupt_not_ready_color));
    end

    self.castbar_start_cast_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_start_cast_color:SetPosition('LEFT', ResetCastBarColorsButton, 'RIGHT', 16, 0);
    self.castbar_start_cast_color:SetLabel(L['OPTIONS_CAST_BAR_START_CAST_COLOR']);
    self.castbar_start_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP']);
    self.castbar_start_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_start_cast_color:SetValue(unpack(O.db.castbar_start_cast_color));
    self.castbar_start_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_cast_color[1] = r;
        O.db.castbar_start_cast_color[2] = g;
        O.db.castbar_start_cast_color[3] = b;
        O.db.castbar_start_cast_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_start_channel_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_start_channel_color:SetPosition('LEFT', self.castbar_start_cast_color.Label, 'RIGHT', 12, 0);
    self.castbar_start_channel_color:SetLabel(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR']);
    self.castbar_start_channel_color:SetTooltip(L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP']);
    self.castbar_start_channel_color:AddToSearch(button, L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_start_channel_color:SetValue(unpack(O.db.castbar_start_channel_color));
    self.castbar_start_channel_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_start_channel_color[1] = r;
        O.db.castbar_start_channel_color[2] = g;
        O.db.castbar_start_channel_color[3] = b;
        O.db.castbar_start_channel_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_noninterruptible_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_noninterruptible_color:SetPosition('LEFT', self.castbar_start_channel_color.Label, 'RIGHT', 12, 0);
    self.castbar_noninterruptible_color:SetLabel(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR']);
    self.castbar_noninterruptible_color:SetTooltip(L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP']);
    self.castbar_noninterruptible_color:AddToSearch(button, L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_noninterruptible_color:SetValue(unpack(O.db.castbar_noninterruptible_color));
    self.castbar_noninterruptible_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_noninterruptible_color[1] = r;
        O.db.castbar_noninterruptible_color[2] = g;
        O.db.castbar_noninterruptible_color[3] = b;
        O.db.castbar_noninterruptible_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_failed_cast_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_failed_cast_color:SetPosition('LEFT', self.castbar_noninterruptible_color.Label, 'RIGHT', 12, 0);
    self.castbar_failed_cast_color:SetLabel(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR']);
    self.castbar_failed_cast_color:SetTooltip(L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP']);
    self.castbar_failed_cast_color:AddToSearch(button, L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_failed_cast_color:SetValue(unpack(O.db.castbar_failed_cast_color));
    self.castbar_failed_cast_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_failed_cast_color[1] = r;
        O.db.castbar_failed_cast_color[2] = g;
        O.db.castbar_failed_cast_color[3] = b;
        O.db.castbar_failed_cast_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_show_interrupt_ready_tick = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_interrupt_ready_tick:SetPosition('TOPLEFT', ResetCastBarColorsButton, 'BOTTOMLEFT', -1, -12);
    self.castbar_show_interrupt_ready_tick:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP']);
    self.castbar_show_interrupt_ready_tick:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_interrupt_ready_tick:SetChecked(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_show_interrupt_ready_tick.Callback = function(self)
        O.db.castbar_show_interrupt_ready_tick = self:GetChecked();

        panel.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);

        Stripes:UpdateAll();
    end

    self.castbar_interrupt_ready_tick_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_ready_tick_color:SetPosition('LEFT', self.castbar_show_interrupt_ready_tick.Label, 'RIGHT', 10, 0);
    self.castbar_interrupt_ready_tick_color:SetLabel(L['OPTIONS_CAST_BAR_SHOW_INTERRUPT_READY_TICK']);
    self.castbar_interrupt_ready_tick_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_tick_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_TICK_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_ready_tick_color:SetValue(unpack(O.db.castbar_interrupt_ready_tick_color));
    self.castbar_interrupt_ready_tick_color:SetEnabled(O.db.castbar_show_interrupt_ready_tick);
    self.castbar_interrupt_ready_tick_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_tick_color[1] = r;
        O.db.castbar_interrupt_ready_tick_color[2] = g;
        O.db.castbar_interrupt_ready_tick_color[3] = b;
        O.db.castbar_interrupt_ready_tick_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_use_interrupt_ready_in_time_color = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_use_interrupt_ready_in_time_color:SetPosition('TOPLEFT', self.castbar_show_interrupt_ready_tick, 'BOTTOMLEFT', 0, -12);
    self.castbar_use_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_use_interrupt_ready_in_time_color:SetChecked(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_use_interrupt_ready_in_time_color.Callback = function(self)
        O.db.castbar_use_interrupt_ready_in_time_color = self:GetChecked();

        panel.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);

        Stripes:UpdateAll();
    end

    self.castbar_interrupt_ready_in_time_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_ready_in_time_color:SetPosition('LEFT', self.castbar_use_interrupt_ready_in_time_color.Label, 'RIGHT', 10, 0);
    self.castbar_interrupt_ready_in_time_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR']);
    self.castbar_interrupt_ready_in_time_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP']);
    self.castbar_interrupt_ready_in_time_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_READY_IN_TIME_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_ready_in_time_color:SetValue(unpack(O.db.castbar_interrupt_ready_in_time_color));
    self.castbar_interrupt_ready_in_time_color:SetEnabled(O.db.castbar_use_interrupt_ready_in_time_color);
    self.castbar_interrupt_ready_in_time_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_ready_in_time_color[1] = r;
        O.db.castbar_interrupt_ready_in_time_color[2] = g;
        O.db.castbar_interrupt_ready_in_time_color[3] = b;
        O.db.castbar_interrupt_ready_in_time_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    self.castbar_use_interrupt_not_ready_color = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_use_interrupt_not_ready_color:SetPosition('TOPLEFT', self.castbar_use_interrupt_ready_in_time_color, 'BOTTOMLEFT', 0, -12);
    self.castbar_use_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_use_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_USE_INTERRUPT_NOT_READY_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_use_interrupt_not_ready_color:SetChecked(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_use_interrupt_not_ready_color.Callback = function(self)
        O.db.castbar_use_interrupt_not_ready_color = self:GetChecked();

        panel.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);

        Stripes:UpdateAll();
    end

    self.castbar_interrupt_not_ready_color = E.CreateColorPicker(self.TabsFrames['CommonTab'].Content);
    self.castbar_interrupt_not_ready_color:SetPosition('LEFT', self.castbar_use_interrupt_not_ready_color.Label, 'RIGHT', 10, 0)
    self.castbar_interrupt_not_ready_color:SetLabel(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR']);
    self.castbar_interrupt_not_ready_color:SetTooltip(L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP']);
    self.castbar_interrupt_not_ready_color:AddToSearch(button, L['OPTIONS_CAST_BAR_INTERRUPT_NOT_READY_COLOR_TOOLTIP'], self.Tabs[1]);
    self.castbar_interrupt_not_ready_color:SetValue(unpack(O.db.castbar_interrupt_not_ready_color));
    self.castbar_interrupt_not_ready_color:SetEnabled(O.db.castbar_use_interrupt_not_ready_color);
    self.castbar_interrupt_not_ready_color.OnValueChanged = function(_, r, g, b, a)
        O.db.castbar_interrupt_not_ready_color[1] = r;
        O.db.castbar_interrupt_not_ready_color[2] = g;
        O.db.castbar_interrupt_not_ready_color[3] = b;
        O.db.castbar_interrupt_not_ready_color[4] = a or 1;

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['CommonTab'].Content);
    Delimiter:SetPosition('TOPLEFT', ResetCastBarColorsButton, 'BOTTOMLEFT', -4, -100);
    Delimiter:SetW(self:GetWidth());

    self.castbar_on_hp_bar = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_on_hp_bar:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -8);
    self.castbar_on_hp_bar:SetLabel(L['OPTIONS_CAST_BAR_ON_HP_BAR']);
    self.castbar_on_hp_bar:SetTooltip(L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP']);
    self.castbar_on_hp_bar:AddToSearch(button, L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP'], self.Tabs[1]);
    self.castbar_on_hp_bar:SetChecked(O.db.castbar_on_hp_bar);
    self.castbar_on_hp_bar.Callback = function(self)
        O.db.castbar_on_hp_bar = self:GetChecked();

        panel.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);

        Stripes:UpdateAll();
    end

    self.castbar_icon_large = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_icon_large:SetPosition('TOPLEFT', self.castbar_on_hp_bar, 'BOTTOMLEFT', 0, -8);
    self.castbar_icon_large:SetLabel(L['OPTIONS_CAST_BAR_ICON_LARGE']);
    self.castbar_icon_large:SetTooltip(L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP']);
    self.castbar_icon_large:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP'], self.Tabs[1]);
    self.castbar_icon_large:SetChecked(O.db.castbar_icon_large);
    self.castbar_icon_large:SetEnabled(not O.db.castbar_on_hp_bar);
    self.castbar_icon_large.Callback = function(self)
        O.db.castbar_icon_large = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_icon_right_side = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_icon_right_side:SetPosition('LEFT', self.castbar_icon_large.Label, 'RIGHT', 12, 0);
    self.castbar_icon_right_side:SetLabel(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE']);
    self.castbar_icon_right_side:SetTooltip(L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP']);
    self.castbar_icon_right_side:AddToSearch(button, L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP'], self.Tabs[1]);
    self.castbar_icon_right_side:SetChecked(O.db.castbar_icon_right_side);
    self.castbar_icon_right_side.Callback = function(self)
        O.db.castbar_icon_right_side = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_show_icon_notinterruptible = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_icon_notinterruptible:SetPosition('TOPLEFT', self.castbar_icon_large, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_icon_notinterruptible:SetLabel(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE']);
    self.castbar_show_icon_notinterruptible:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP']);
    self.castbar_show_icon_notinterruptible:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_icon_notinterruptible:SetChecked(O.db.castbar_show_icon_notinterruptible);
    self.castbar_show_icon_notinterruptible.Callback = function(self)
        O.db.castbar_show_icon_notinterruptible = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_show_shield = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_shield:SetPosition('LEFT', self.castbar_show_icon_notinterruptible.Label, 'RIGHT', 12, 0);
    self.castbar_show_shield:SetLabel(L['OPTIONS_CAST_BAR_SHOW_SHIELD']);
    self.castbar_show_shield:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP']);
    self.castbar_show_shield:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_shield:SetChecked(O.db.castbar_show_shield);
    self.castbar_show_shield.Callback = function(self)
        O.db.castbar_show_shield = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.who_interrupted_enabled = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.who_interrupted_enabled:SetPosition('TOPLEFT', self.castbar_show_icon_notinterruptible, 'BOTTOMLEFT', 0, -8);
    self.who_interrupted_enabled:SetLabel(L['OPTIONS_WHO_INTERRUPTED_ENABLED']);
    self.who_interrupted_enabled:SetTooltip(L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP']);
    self.who_interrupted_enabled:AddToSearch(button, L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP'], self.Tabs[1]);
    self.who_interrupted_enabled:SetChecked(O.db.who_interrupted_enabled);
    self.who_interrupted_enabled.Callback = function(self)
        O.db.who_interrupted_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_show_tradeskills = E.CreateCheckButton(self.TabsFrames['CommonTab'].Content);
    self.castbar_show_tradeskills:SetPosition('TOPLEFT', self.who_interrupted_enabled, 'BOTTOMLEFT', 0, -8);
    self.castbar_show_tradeskills:SetLabel(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS']);
    self.castbar_show_tradeskills:SetTooltip(L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP']);
    self.castbar_show_tradeskills:AddToSearch(button, L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP'], self.Tabs[1]);
    self.castbar_show_tradeskills:SetChecked(O.db.castbar_show_tradeskills);
    self.castbar_show_tradeskills.Callback = function(self)
        O.db.castbar_show_tradeskills = self:GetChecked();
        Stripes:UpdateAll();
    end

   ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Timer Tab -----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.castbar_timer_enabled = E.CreateCheckButton(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_enabled:SetPosition('TOPLEFT', self.TabsFrames['TimerTab'].Content, 'TOPLEFT', 0, -4);
    self.castbar_timer_enabled:SetLabel(L['ENABLE']);
    self.castbar_timer_enabled:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP']);
    self.castbar_timer_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_enabled:SetChecked(O.db.castbar_timer_enabled);
    self.castbar_timer_enabled.Callback = function(self)
        O.db.castbar_timer_enabled = self:GetChecked();

        panel.castbar_timer_format:SetEnabled(O.db.castbar_timer_enabled);

        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['TimerTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_timer_enabled, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.castbar_timer_format = E.CreateDropdown('plain', self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_format:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.castbar_timer_format:SetSize(200, 20);
    self.castbar_timer_format:SetList(O.Lists.castbar_timer_format);
    self.castbar_timer_format:SetValue(O.db.castbar_timer_format);
    self.castbar_timer_format:SetLabel(L['FORMAT']);
    self.castbar_timer_format:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FORMAT_TOOLTIP']);
    self.castbar_timer_format:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FORMAT_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_format:SetEnabled(O.db.castbar_timer_enabled);
    self.castbar_timer_format.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_format = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_only_remaining = E.CreateCheckButton(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_only_remaining:SetPosition('LEFT', self.castbar_timer_format, 'RIGHT', 12, 0);
    self.castbar_timer_only_remaining:SetLabel(L['OPTIONS_CAST_BAR_TIMER_ONLY_REMAINING_TIME']);
    self.castbar_timer_only_remaining:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_ONLY_REMAINING_TIME_TOOLTIP']);
    self.castbar_timer_only_remaining:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_ONLY_REMAINING_TIME_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_only_remaining:SetChecked(O.db.castbar_timer_only_remaining);
    self.castbar_timer_only_remaining.Callback = function(self)
        O.db.castbar_timer_only_remaining = self:GetChecked();
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['TimerTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_timer_format, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.castbar_timer_xside = E.CreateDropdown('plain', self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_xside:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.castbar_timer_xside:SetSize(116, 20);
    self.castbar_timer_xside:SetList(O.Lists.frame_position_xside);
    self.castbar_timer_xside:SetValue(O.db.castbar_timer_xside);
    self.castbar_timer_xside:SetLabel(L['POSITION']);
    self.castbar_timer_xside:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_XSIDE_TOOLTIP']);
    self.castbar_timer_xside:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_XSIDE_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_xside.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_xside = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_anchor = E.CreateDropdown('plain', self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_anchor:SetPosition('LEFT', self.castbar_timer_xside, 'RIGHT', 12, 0);
    self.castbar_timer_anchor:SetSize(116, 20);
    self.castbar_timer_anchor:SetList(O.Lists.frame_points_simple_localized);
    self.castbar_timer_anchor:SetValue(O.db.castbar_timer_anchor);
    self.castbar_timer_anchor:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_ANCHOR_TOOLTIP']);
    self.castbar_timer_anchor:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_ANCHOR_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_anchor.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_anchor = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_offset_x = E.CreateSlider(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_offset_x:SetPosition('LEFT', self.castbar_timer_anchor, 'RIGHT', 16, 0);
    self.castbar_timer_offset_x:SetW(116);
    self.castbar_timer_offset_x:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_OFFSET_X_TOOLTIP']);
    self.castbar_timer_offset_x:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_OFFSET_X_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_offset_x:SetValues(O.db.castbar_timer_offset_x, -99, 100, 1);
    self.castbar_timer_offset_x.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_offset_x = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_offset_y = E.CreateSlider(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_offset_y:SetPosition('LEFT', self.castbar_timer_offset_x, 'RIGHT', 16, 0);
    self.castbar_timer_offset_y:SetW(116);
    self.castbar_timer_offset_y:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_OFFSET_Y_TOOLTIP']);
    self.castbar_timer_offset_y:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_OFFSET_Y_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_offset_y:SetValues(O.db.castbar_timer_offset_y, -99, 100, 1);
    self.castbar_timer_offset_y.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_offset_y = tonumber(value);
        Stripes:UpdateAll();
    end

    Delimiter = E.CreateDelimiter(self.TabsFrames['TimerTab'].Content);
    Delimiter:SetPosition('TOPLEFT', self.castbar_timer_xside, 'BOTTOMLEFT', 0, -4);
    Delimiter:SetW(self:GetWidth());

    self.castbar_timer_font_value = E.CreateDropdown('font', self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_font_value:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 0, -4);
    self.castbar_timer_font_value:SetSize(160, 20);
    self.castbar_timer_font_value:SetList(LSM:HashTable('font'));
    self.castbar_timer_font_value:SetValue(O.db.castbar_timer_font_value);
    self.castbar_timer_font_value:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FONT_VALUE_TOOLTIP']);
    self.castbar_timer_font_value:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FONT_VALUE_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_font_value.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_font_value = value;
        Stripes:UpdateAll();
    end

    self.castbar_timer_font_size = E.CreateSlider(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_font_size:SetPosition('LEFT', self.castbar_timer_font_value, 'RIGHT', 12, 0);
    self.castbar_timer_font_size:SetValues(O.db.castbar_timer_font_size, 3, 28, 1);
    self.castbar_timer_font_size:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FONT_SIZE_TOOLTIP']);
    self.castbar_timer_font_size:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FONT_SIZE_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_font_size.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_font_size = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_font_flag = E.CreateDropdown('plain', self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_font_flag:SetPosition('LEFT', self.castbar_timer_font_size, 'RIGHT', 12, 0);
    self.castbar_timer_font_flag:SetSize(160, 20);
    self.castbar_timer_font_flag:SetList(O.Lists.font_flags_localized);
    self.castbar_timer_font_flag:SetValue(O.db.castbar_timer_font_flag);
    self.castbar_timer_font_flag:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FONT_FLAG_TOOLTIP']);
    self.castbar_timer_font_flag:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FONT_FLAG_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_font_flag.OnValueChangedCallback = function(_, value)
        O.db.castbar_timer_font_flag = tonumber(value);
        Stripes:UpdateAll();
    end

    self.castbar_timer_font_shadow = E.CreateCheckButton(self.TabsFrames['TimerTab'].Content);
    self.castbar_timer_font_shadow:SetPosition('LEFT', self.castbar_timer_font_flag, 'RIGHT', 12, 0);
    self.castbar_timer_font_shadow:SetLabel(L['FONT_SHADOW_SHORT']);
    self.castbar_timer_font_shadow:SetChecked(O.db.castbar_timer_font_shadow);
    self.castbar_timer_font_shadow:SetTooltip(L['OPTIONS_CAST_BAR_TIMER_FONT_SHADOW_TOOLTIP']);
    self.castbar_timer_font_shadow:AddToSearch(button, L['OPTIONS_CAST_BAR_TIMER_FONT_SHADOW_TOOLTIP'], self.Tabs[2]);
    self.castbar_timer_font_shadow.Callback = function(self)
        O.db.castbar_timer_font_shadow = self:GetChecked();
        Stripes:UpdateAll();
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    -- Custom Cast Tab -----------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    self.castbar_custom_casts_enabled = E.CreateCheckButton(self.TabsFrames['CustomCastsTab'].Content);
    self.castbar_custom_casts_enabled:SetPosition('TOPLEFT', self.TabsFrames['CustomCastsTab'].Content, 'TOPLEFT', 0, -4);
    self.castbar_custom_casts_enabled:SetLabel(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED']);
    self.castbar_custom_casts_enabled:SetTooltip(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED_TOOLTIP']);
    self.castbar_custom_casts_enabled:AddToSearch(button, L['OPTIONS_CAST_BAR_CUSTOM_CASTS_ENABLED_TOOLTIP'], self.Tabs[3]);
    self.castbar_custom_casts_enabled:SetChecked(O.db.castbar_custom_casts_enabled);
    self.castbar_custom_casts_enabled.Callback = function(self)
        O.db.castbar_custom_casts_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    self.castbar_custom_casts_editbox = E.CreateEditBox(self.TabsFrames['CustomCastsTab'].Content);
    self.castbar_custom_casts_editbox:SetPosition('TOPLEFT', self.castbar_custom_casts_enabled, 'BOTTOMLEFT', 5, -8);
    self.castbar_custom_casts_editbox:SetSize(327, 22);
    self.castbar_custom_casts_editbox.useLastValue = false;
    self.castbar_custom_casts_editbox:SetInstruction(L['OPTIONS_CAST_BAR_CUSTOM_CASTS_EDITBOX_ENTER_ID']);
    self.castbar_custom_casts_editbox:SetScript('OnEnterPressed', function(self)
        local text = strtrim(self:GetText());
        local saveId;
        local id = tonumber(text);

        if id and id ~= 0 and GetSpellInfo(id) then
            saveId = id;
        else
            saveId = tonumber(select(7, GetSpellInfo(text)) or '');
        end

        if not saveId then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        AddCustomCast(tonumber(saveId));

        panel:UpdateCustomCastsScroll();

        self:SetText('');

        Stripes:UpdateAll();
    end);

    self.SearchEditBox = E.CreateEditBox(self.TabsFrames['CustomCastsTab'].Content);
    self.SearchEditBox:SetPosition('TOPLEFT', self.castbar_custom_casts_editbox, 'BOTTOMLEFT', 0, -11);
    self.SearchEditBox:SetSize(160, 22);
    self.SearchEditBox:SetUseLastValue(false);
    self.SearchEditBox:SetInstruction(L['SEARCH']);
    self.SearchEditBox:SetScript('OnEnterPressed', function(self)
        panel.searchWordLower = string.lower(strtrim(self:GetText()) or '');

        if panel.searchWordLower == '' then
            panel.searchWordLower = nil;
            panel.ResetSearchEditBox:SetShown(false);
        end

        if panel.searchWordLower then
            panel.ResetSearchEditBox:SetShown(true);
        end

        panel:UpdateCustomCastsScroll();
    end);
    self.SearchEditBox.FocusGainedCallback = function()
        panel.ResetSearchEditBox:SetShown(true);
    end
    self.SearchEditBox.FocusLostCallback = function(self)
        panel.ResetSearchEditBox:SetShown(self:GetText() ~= '');
    end
    self.SearchEditBox.OnTextChangedCallback = function(self)
        if self:GetText() ~= '' then
            panel.ResetSearchEditBox:SetShown(true);
        else
            panel.ResetSearchEditBox:SetShown(false);
        end
    end

    self.ResetSearchEditBox = E.CreateTextureButton(self.SearchEditBox, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.CROSS_WHITE);
    self.ResetSearchEditBox:SetPosition('RIGHT', self.SearchEditBox, 'RIGHT', 0, 0);
    self.ResetSearchEditBox:SetSize(12, 12);
    self.ResetSearchEditBox:SetShown(false);
    self.ResetSearchEditBox:SetScript('OnClick', function(self)
        panel.searchWordLower = nil;

        panel.SearchEditBox:SetText('');
        panel.SearchEditBox.Instruction:SetShown(true);
        panel:UpdateCustomCastsScroll();

        self:SetShown(false);
    end);

    self.CategoryDropdown = E.CreateDropdown('plain', self.TabsFrames['CustomCastsTab'].Content);
    self.CategoryDropdown:SetPosition('LEFT', self.SearchEditBox, 'RIGHT', 11, 0);
    self.CategoryDropdown:SetSize(160, 22);
    self.CategoryDropdown:SetList(self:GetCategoriesDropdown());
    self.CategoryDropdown:SetValue(0);
    self.CategoryDropdown.OnValueChangedCallback = function(_, value)
        panel.categoryId = tonumber(value);
        panel:UpdateCustomCastsScroll();
    end

    self.OpenCategoryList = E.CreateTextureButton(self.TabsFrames['CustomCastsTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.LIST_WHITE, { 1, 1, 1, 1 });
    self.OpenCategoryList:SetPosition('LEFT', self.CategoryDropdown, 'RIGHT', 12, 0);
    self.OpenCategoryList:SetSize(18, 18);
    self.OpenCategoryList:SetTooltip(L['OPTIONS_CATEGORY_OPEN_TOOLTIP']);
    self.OpenCategoryList.Callback = function()
        panel.CategoryList:SetShown(not panel.CategoryList:IsShown());

        S:GetModule('Options_ColorCategory'):HideListFrame();
    end

    self.castbar_custom_casts_editframe = CreateFrame('Frame', nil, self.TabsFrames['CustomCastsTab'].Content, 'BackdropTemplate');
    self.castbar_custom_casts_editframe:SetPoint('TOPLEFT', self.SearchEditBox, 'BOTTOMLEFT', -5, -8);
    self.castbar_custom_casts_editframe:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 0);
    self.castbar_custom_casts_editframe:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.castbar_custom_casts_editframe:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.castbar_custom_casts_scrollchild, self.castbar_custom_casts_scrollarea = E.CreateScrollFrame(self.castbar_custom_casts_editframe, ROW_HEIGHT);
    PixelUtil.SetPoint(self.castbar_custom_casts_scrollarea.ScrollBar, 'TOPLEFT', self.castbar_custom_casts_scrollarea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.castbar_custom_casts_scrollarea.ScrollBar, 'BOTTOMLEFT', self.castbar_custom_casts_scrollarea, 'BOTTOMRIGHT', -8, 0);

    self.CastBarCustomCastsFramePool = CreateFramePool('Button', self.castbar_custom_casts_scrollchild, 'BackdropTemplate');

    self.ProfilesDropdown = E.CreateDropdown('plain', self.TabsFrames['CustomCastsTab'].Content);
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.castbar_custom_casts_editframe, 'TOPRIGHT', 0, 40);
    self.ProfilesDropdown:SetSize(157, 22);
    self.ProfilesDropdown:SetTooltip(L['OPTIONS_COPY_REPLACE_FROM_PROFILE_TOOLTIP']);
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);
        if not index then
            self:SetValue(nil);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].color_category_data);
            wipe(StripesDB.profiles[O.activeProfileId].castbar_custom_casts_category_data);
            wipe(StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data);

            StripesDB.profiles[O.activeProfileId].color_category_data                = U.DeepCopy(StripesDB.profiles[index].color_category_data);
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_category_data = U.DeepCopy(StripesDB.profiles[index].castbar_custom_casts_category_data);
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data          = U.DeepCopy(StripesDB.profiles[index].castbar_custom_casts_data);
        else
            StripesDB.profiles[O.activeProfileId].color_category_data                = U.Merge(StripesDB.profiles[index].color_category_data, StripesDB.profiles[O.activeProfileId].color_category_data);
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_category_data = U.Merge(StripesDB.profiles[index].castbar_custom_casts_category_data, StripesDB.profiles[O.activeProfileId].castbar_custom_casts_category_data);
            StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data          = U.Merge(StripesDB.profiles[index].castbar_custom_casts_data, StripesDB.profiles[O.activeProfileId].castbar_custom_casts_data);
        end

        self:SetValue(nil);

        S:GetModule('Options_ColorCategory'):UpdateAllLists();
        S:GetModule('Options_ColorCategory'):UpdateListScroll();
        panel:UpdateCategoryListScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self.TabsFrames['CustomCastsTab'].Content);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);

    self.ColorCategoryToggleButton = E.CreateTextureButton(self.TabsFrames['CustomCastsTab'].Content, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.PALETTE_COLOR, { 1, 1, 1, 1 }, { 1, 1, 0.5, 1 });
    self.ColorCategoryToggleButton:SetPosition('TOPRIGHT', self.ProfilesDropdown, 'BOTTOMRIGHT', -2, -12);
    self.ColorCategoryToggleButton:SetTooltip(L['OPTIONS_COLOR_CATEGORY_TOGGLE_FRAME']);
    self.ColorCategoryToggleButton:SetSize(19, 18);
    self.ColorCategoryToggleButton.Callback = function()
        S:GetModule('Options_ColorCategory'):ToggleListFrame();

        panel.CategoryList:SetShown(false);
    end

    self.HelpTipButton = E.CreateHelpTipButton(self.TabsFrames['CustomCastsTab'].Content);
    self.HelpTipButton:SetPosition('TOPLEFT', self.ProfilesDropdown, 'BOTTOMLEFT', 2, -12);
    self.HelpTipButton:SetTooltip(L['OPTIONS_SHIFT_CLICK_TO_DELETE']);

    self.CategoryList = Mixin(CreateFrame('Frame', nil, self.TabsFrames['CustomCastsTab'].Content, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.CategoryList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.CategoryList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.CategoryList:SetWidth(250);
    self.CategoryList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CategoryList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.CategoryList:SetShown(false);

    self.CategoryEditbox = E.CreateEditBox(self.CategoryList);
    self.CategoryEditbox:SetPosition('TOP', self.CategoryList, 'TOP', 0, -10);
    self.CategoryEditbox:SetFrameLevel(self.CategoryList:GetFrameLevel() + 10);
    self.CategoryEditbox:SetSize(228, 20);
    self.CategoryEditbox:SetMaxLetters(CATEGORY_MAX_LETTERS);
    self.CategoryEditbox.useLastValue = false;
    self.CategoryEditbox:SetInstruction(L['OPTIONS_CATEGORY_ENTER_NAME']);
    self.CategoryEditbox:SetScript('OnEnterPressed', function(self)
        local name = strtrim(self:GetText());

        if not name or name == ''  then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        table.insert(O.db.castbar_custom_casts_category_data, { name = name });

        self:SetText('');
        self:ClearFocus();

        panel.UpdateCustomCastsScroll();
        panel.UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown());
        panel.CategoryDropdown:SetValue(panel.CategoryDropdown:GetValue());
    end);

    self.CategoryListScroll = Mixin(CreateFrame('Frame', nil, self.CategoryList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.CategoryListScroll:SetPoint('TOPLEFT', self.CategoryList , 'TOPLEFT', 6, -40);
    self.CategoryListScroll:SetPoint('BOTTOMRIGHT', self.CategoryList, 'BOTTOMRIGHT', -6, 6);
    self.CategoryListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CategoryListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.CategoryListScrollChild, self.CategoryListScrollArea = E.CreateScrollFrame(self.CategoryListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.CategoryListScrollArea.ScrollBar, 'TOPLEFT', self.CategoryListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.CategoryListScrollArea.ScrollBar, 'BOTTOMLEFT', self.CategoryListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.CategoryListButtonPool = CreateFramePool('Button', self.CategoryListScrollChild, 'BackdropTemplate');
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');

    self:UpdateProfilesDropdown();
end

panel.OnShowOnce = function(self)
    self:UpdateCustomCastsScroll();
    self:UpdateCategoryListScroll();
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    S:GetModule('Options_ColorCategory'):UpdateAllLists();
    S:GetModule('Options_ColorCategory'):UpdateListScroll();

    self:UpdateCategoryListScroll();
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end