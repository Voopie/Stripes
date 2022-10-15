local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CustomNPC');
local Profile = S:GetModule('Options_Categories_Profiles');
local Colors = S:GetModule('Options_Colors');

O.frame.Left.CustomNPC, O.frame.Right.CustomNPC = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CUSTOMNPC']), 'customnpc', 7);
local button = O.frame.Left.CustomNPC;
local panel = O.frame.Right.CustomNPC;

local framePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local BACKDROP_BORDER_2 = { bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Buttons\\WHITE8x8', edgeSize = 2 };
local NAME_WIDTH = 420;
local CATEGORY_MAX_LETTERS = 20;
local DELAY_SECONDS = 0.25;

local DEFAULT_LIST_VALUE = 1;
local LIST_TOOLTIP_PATTERN = '|cffff6666%s|r  |cffffffff| |r |cffffb833%s|r';

local CATEGORY_ALL_NAME       = O.CATEGORY_ALL_NAME;
local DEFAULT_GLOW_COLOR_NAME = 'Yellow';
local DEFAULT_HB_COLOR_NAME   = 'Teal';

panel.categoryName = CATEGORY_ALL_NAME;

local HolderModelFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate');
HolderModelFrame:SetClipsChildren(true);
HolderModelFrame:SetFrameStrata('TOOLTIP');
HolderModelFrame:SetFrameLevel(1000);
HolderModelFrame:SetBackdrop({
    bgFile   = 'Interface\\Buttons\\WHITE8x8',
    insets   = { top = 1, left = 1, bottom = 1, right = 1 },
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 1,
});
HolderModelFrame:SetBackdropColor(0.1, 0.1, 0.1, 1);
HolderModelFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
HolderModelFrame:Hide();

local ModelFrame = CreateFrame('PlayerModel', nil, HolderModelFrame);
ModelFrame:SetPoint('CENTER', HolderModelFrame, 'CENTER', 0, 0);
ModelFrame:SetSize(150, 300);

local function AddEntry(id, name, new_name)
    if O.db.custom_npc[id] then
        O.db.custom_npc[id].npc_name = name;
    else
        O.db.custom_npc[id] = {
            enabled  = true,

            npc_id       = id,
            npc_name     = name,
            npc_new_name = new_name or name,

            category_name = CATEGORY_ALL_NAME,

            color_enabled = false,
            color_name    = DEFAULT_HB_COLOR_NAME,

            glow_enabled    = false,
            glow_type       = 0,
            glow_color_name = DEFAULT_GLOW_COLOR_NAME,
        };
    end
end

local function UpdateEntryName(editbox, npc_id, old_name, new_name)
    new_name = strtrim(new_name or '');

    if not npc_id or not O.db.custom_npc[npc_id] then
        return editbox:Hide();
    end

    if old_name == new_name then
        return editbox:Hide();
    end

    O.db.custom_npc[npc_id].npc_new_name = (not new_name or new_name == '') and old_name or new_name;

    panel:UpdateMainContentList();
    S:GetNameplateModule('Handler'):UpdateAll();

    editbox:Hide();
end

--------------------------
-- Categories (Folders) --
--------------------------

local CategoryListActiveRows = {};
local CategoryListSortedRows = {};
local CategoryDropdown       = {}

local function SortCategoryByName(a, b)
    return a.value < b.value;
end

panel.GetCategoryDropdown = function(self)
    wipe(CategoryDropdown);

    local index = 1;

    for name, _ in pairs(O.db.custom_npc_categories) do
        CategoryDropdown[index] = name;
        index = index + 1;
    end

    CategoryDropdown[0] = CATEGORY_ALL_NAME;

    return CategoryDropdown;
end

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
    frame.EditBox:Hide();
    frame.EditBox:SetScript('OnEnterPressed', function(self)
        local name = self:GetParent().name;

        if not name or not O.db.custom_npc_categories[name] then
            return self:Hide();
        end

        local new_name = strtrim(self:GetText());

        if not new_name or new_name == '' or string.lower(new_name) == string.lower(CATEGORY_ALL_NAME) then
            return self:Hide();
        end

        O.db.custom_npc_categories[new_name] = true;
        O.db.custom_npc_categories[name] = nil;

        for id, _ in pairs(O.db.custom_npc) do
            if O.db.custom_npc[id].category_name == name then
                O.db.custom_npc[id].category_name = new_name;
            end
        end

        if panel.categoryName == name then
            panel.categoryName = new_name;
        end

        panel:UpdateMainContentList();
        panel.UpdateCategoryList();
        panel.CategoryDropdown:SetList(panel:GetCategoryDropdown(), SortCategoryByName, true);

        if panel.CategoryDropdown:GetValue() == name then
            panel.CategoryDropdown:SetValue(new_name);
        end

        self:Hide();
    end);
    frame.EditBox.FocusLostCallback = function(self)
        self:Hide();
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
        O.db.custom_npc_categories[self:GetParent().name] = nil;

        panel:UpdateMainContentList();
        panel.UpdateCategoryList();
        panel.CategoryDropdown:SetList(panel:GetCategoryDropdown(), SortCategoryByName, true);
        panel.CategoryDropdown:SetValue(CATEGORY_ALL_NAME);
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(unpack(self:GetParent().backgroundColor));
    end);

    frame.EditButton = E.CreateTextureButton(frame, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.PENCIL_WHITE);
    frame.EditButton:SetPosition('RIGHT', frame.RemoveButton, 'LEFT', -8, 0);
    frame.EditButton:SetSize(14, 14);
    frame.EditButton:SetScript('OnClick', function(self)
        self:GetParent().EditBox:SetText(self:GetParent().name);
        self:GetParent().EditBox:Show();
        self:GetParent().EditBox:SetFocus();
        self:GetParent().EditBox:SetCursorPosition(0);
    end);
    frame.EditButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EditButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(unpack(self:GetParent().backgroundColor));
    end);

    frame:HookScript('OnDoubleClick', function(self)
        self.EditBox:SetText(self.name);
        self.EditBox:Show();
        self.EditBox:SetFocus();
        self.EditBox:SetCursorPosition(0);
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(unpack(self.backgroundColor));
    end);
end

panel.UpdateCategoryListRow = function(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.CategoryListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.CategoryListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', CategoryListActiveRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', CategoryListActiveRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame:SetBackdropColor(unpack(frame.backgroundColor));

    frame.NameText:SetText(frame.name);
end

panel.UpdateCategoryList = function()
    wipe(CategoryListActiveRows);
    wipe(CategoryListSortedRows);

    for name, _ in pairs(O.db.custom_npc_categories) do
        table.insert(CategoryListSortedRows, name);
    end

    table.sort(CategoryListSortedRows, function(a, b)
        return a < b;
    end);

    panel.CategoryListButtonPool:ReleaseAll();

    local frame, isNew;

    for index, name in ipairs(CategoryListSortedRows) do
        frame, isNew = panel.CategoryListButtonPool:Acquire();

        table.insert(CategoryListActiveRows, frame);

        if isNew then
            panel.CreateCategoryListRow(frame);
        end

        frame.index = index;
        frame.name  = name;

        panel.UpdateCategoryListRow(frame);

        frame:Show();
    end

    PixelUtil.SetSize(panel.CategoryListScrollArea.scrollChild, panel.CategoryListScroll:GetWidth(), panel.CategoryListScroll:GetHeight() - (panel.CategoryListScroll:GetHeight() % ROW_HEIGHT));
end

---------------------
-- Choose NPC List --
---------------------

local ChooseNPCListActiveRows = {};

panel.CreateChooseNPCListRow = function(b)
    b:SetBackdrop(BACKDROP);
    b.backgroundColor = b.backgroundColor or {};

    b.PlusSign = Mixin(b:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    b.PlusSign:SetPosition('RIGHT', b, 'RIGHT', -8, 0);
    b.PlusSign:SetSize(ROW_HEIGHT / 2, ROW_HEIGHT / 2);
    b.PlusSign:SetTexture(S.Media.Icons.TEXTURE);
    b.PlusSign:SetTexCoord(unpack(S.Media.Icons.COORDS.PLUS_SIGN_WHITE));
    b.PlusSign:Hide();

    b.NameText = Mixin(b:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
    b.NameText:SetPosition('LEFT', b, 'LEFT', 8, 0);
    b.NameText:SetPosition('RIGHT', b.PlusSign, 'LEFT', -2, 0);
    b.NameText:SetH(ROW_HEIGHT / 2);

    b:SetScript('OnClick', function(self)
        AddEntry(self.npc_id, self.npc_name);

        panel:UpdateMainContentList();
        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    E.CreateTooltip(b, nil, nil, true);

    b:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
        self.PlusSign:Show();

        if self.npc_name == UNKNOWN then
            self.npc_name = U.GetNpcNameByID(self.npc_id);
            self.tooltip = string.format(LIST_TOOLTIP_PATTERN, self.npc_name, self.npc_id);

            self.NameText:SetText(self.npc_name);
        end

        if self.npc_name ~= UNKNOWN and not D.ModelBlacklist[self.npc_id] then
            ModelFrame:SetCreature(self.npc_id);
            GameTooltip_InsertFrame(GameTooltip, HolderModelFrame, 0);
            HolderModelFrame:SetSize(GameTooltip:GetWidth(), GameTooltip:GetWidth() * 2);
            HolderModelFrame:SetPoint('TOPLEFT', GameTooltip, 'BOTTOMLEFT', 0, -1);
            ModelFrame:SetSize(GameTooltip:GetWidth() - 3, GameTooltip:GetWidth() * 2 - 3);
            ModelFrame:SetCamDistanceScale(1.2);
        end
    end);

    b:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
        self.PlusSign:Hide();

        if self.npc_name == UNKNOWN then
            self.npc_name = U.GetNpcNameByID(self.npc_id);
            self.tooltip = string.format(LIST_TOOLTIP_PATTERN, self.npc_name, self.npc_id);

            self.NameText:SetText(self.npc_name);
        end
    end);
end

panel.UpdateChooseNPCListRow = function(b)
    if b.index == 1 then
        PixelUtil.SetPoint(b, 'TOPLEFT', panel.ChooseNPCListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(b, 'TOPRIGHT', panel.ChooseNPCListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(b, 'TOPLEFT', ChooseNPCListActiveRows[b.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(b, 'TOPRIGHT', ChooseNPCListActiveRows[b.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    b:SetSize(b:GetParent():GetWidth(), ROW_HEIGHT);

    if b.index % 2 == 0 then
        b.backgroundColor[1], b.backgroundColor[2], b.backgroundColor[3], b.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        b.backgroundColor[1], b.backgroundColor[2], b.backgroundColor[3], b.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    b:SetBackdropColor(unpack(b.backgroundColor));

    b.NameText:SetText(b.npc_name);
end

panel.UpdateChooseNPCList = function(id)
    wipe(ChooseNPCListActiveRows);

    panel.ChooseNPCListButtonPool:ReleaseAll();

    local b, isNew;

    for index, npc_id in pairs(D.NPCs[id]) do
        b, isNew = panel.ChooseNPCListButtonPool:Acquire();

        table.insert(ChooseNPCListActiveRows, b);

        if isNew then
            panel.CreateChooseNPCListRow(b);
        end

        b.index    = index;
        b.npc_id   = npc_id;
        b.npc_name = U.GetNpcNameByID(b.npc_id);
        b.tooltip  = string.format(LIST_TOOLTIP_PATTERN, b.npc_name, b.npc_id);

        panel.UpdateChooseNPCListRow(b);

        b:Show();
    end

    PixelUtil.SetSize(panel.ChooseNPCListScrollArea.scrollChild, panel.ChooseNPCListScroll:GetWidth(), panel.ChooseNPCListScroll:GetHeight() - (panel.ChooseNPCListScroll:GetHeight() % ROW_HEIGHT))
end

-----------------------
-- Main Content List --
-----------------------

local MainContentActiveRows = {};
local MainContentSortedRows = {};

local ExtendedOptions = CreateFrame('Frame', nil, panel, 'BackdropTemplate');
ExtendedOptions:SetFrameLevel(100);
ExtendedOptions:SetSize(260, 300);
ExtendedOptions:SetBackdrop(BACKDROP_BORDER_2);
ExtendedOptions:SetClampedToScreen(true);
ExtendedOptions:Hide();

ExtendedOptions.Update = function(self)
    self.ColorName:SetList(Colors:GetList());
    self.ColorName:SetValue(self.anchor.color_name);
    self.GlowColorName:SetList(Colors:GetList());
    self.GlowColorName:SetValue(self.anchor.glow_color_name);
end

ExtendedOptions.UpdateAll = function(self, frame)
    self.id     = frame.npc_id;
    self.anchor = frame;

    self.NameText:SetText(frame.npc_name .. '  |cffaaaaaa[' .. frame.npc_id .. ']|r');

    self.Category:SetList(frame.category_list, nil, true);
    self.Category:SetValue(frame.category_name);

    self.ColorName:SetList(Colors:GetList());
    self.ColorName:SetValue(frame.color_name);
    self.ColorNameEnabled:SetChecked(frame.color_enabled);

    self.GlowType:SetValue(frame.glow_type);
    self.GlowColorName:SetList(Colors:GetList());
    self.GlowColorName:SetValue(frame.glow_color_name);

    self:SetPoint('TOPLEFT', self.anchor, 'TOPRIGHT', 0, 0);
    self:SetBackdropColor(unpack(frame.backgroundColor));
    self:SetBackdropBorderColor(unpack(frame.highlightColor));
    self:Show();

    frame.isHighlighted = true;
    frame:SetBackdropColor(unpack(frame.highlightColor));
    frame.ToggleExtendedOptions:SetVertexColor(1, 0.85, 0, 1);
end

ExtendedOptions.NameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
ExtendedOptions.NameText:SetPoint('TOPLEFT', ExtendedOptions, 'TOPLEFT', 16, -10);
ExtendedOptions.NameText:SetPoint('TOPRIGHT', ExtendedOptions, 'TOPRIGHT', -8, 0);

ExtendedOptions.Delimiter = E.CreateDelimiter(ExtendedOptions);
ExtendedOptions.Delimiter:SetPosition('TOPLEFT', ExtendedOptions.NameText, 'BOTTOMLEFT', -7, 0);
ExtendedOptions.Delimiter:SetW(ExtendedOptions:GetWidth() - 16);

ExtendedOptions.CategoryText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.CategoryText:SetPoint('TOPLEFT', ExtendedOptions.Delimiter, 'BOTTOMLEFT', 7, -2);
ExtendedOptions.CategoryText:SetText(L['CATEGORY']);

ExtendedOptions.Category = E.CreateDropdown('plain', ExtendedOptions);
ExtendedOptions.Category:SetPosition('TOPLEFT', ExtendedOptions.CategoryText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.Category:SetSize(140, 20);
ExtendedOptions.Category.OnValueChangedCallback = function(_, _, value)
    if O.db.custom_npc[ExtendedOptions.id] then
        O.db.custom_npc[ExtendedOptions.id].category_name = value;
        panel:UpdateMainContentList();
    end
end

ExtendedOptions.ColorNameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.ColorNameText:SetPoint('TOPLEFT', ExtendedOptions.Category, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.ColorNameText:SetText(L['COLOR']);

ExtendedOptions.ColorName = E.CreateDropdown('color', ExtendedOptions);
ExtendedOptions.ColorName:SetPosition('TOPLEFT', ExtendedOptions.ColorNameText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.ColorName:SetSize(140, 20);
ExtendedOptions.ColorName.OnValueChangedCallback = function(_, name)
    O.db.custom_npc[ExtendedOptions.id].color_name = name;

    panel:UpdateMainContentList();
    S:GetNameplateModule('Handler'):UpdateAll();

    ExtendedOptions:SetBackdropBorderColor(unpack(ExtendedOptions.anchor.highlightColor));
    ExtendedOptions:Update();
end

ExtendedOptions.ColorNameEnabled = E.CreateCheckButton(ExtendedOptions);
ExtendedOptions.ColorNameEnabled:SetPosition('LEFT', ExtendedOptions.ColorName, 'RIGHT', 12, 0);
ExtendedOptions.ColorNameEnabled.Callback = function(self)
    O.db.custom_npc[ExtendedOptions.id].color_enabled = self:GetChecked();

    panel:UpdateMainContentList();
    S:GetNameplateModule('Handler'):UpdateAll();

    ExtendedOptions:SetBackdropBorderColor(unpack(ExtendedOptions.anchor.highlightColor));
    ExtendedOptions:Update();
end

ExtendedOptions.GlowTypeText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.GlowTypeText:SetPoint('TOPLEFT', ExtendedOptions.ColorName, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.GlowTypeText:SetText(L['GLOW_TYPE']);

ExtendedOptions.GlowType = E.CreateDropdown('plain', ExtendedOptions);
ExtendedOptions.GlowType:SetPosition('TOPLEFT', ExtendedOptions.GlowTypeText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.GlowType:SetSize(140, 20);
ExtendedOptions.GlowType:SetList(O.Lists.glow_type_short_with_none);
ExtendedOptions.GlowType.OnValueChangedCallback = function(_, value)
    value = tonumber(value);

    O.db.custom_npc[ExtendedOptions.id].glow_enabled = value ~= 0;
    O.db.custom_npc[ExtendedOptions.id].glow_type    = value;

    panel:UpdateMainContentList();
    S:GetNameplateModule('Handler'):UpdateAll();
end

ExtendedOptions.GlowColorNameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.GlowColorNameText:SetPoint('TOPLEFT', ExtendedOptions.GlowType, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.GlowColorNameText:SetText(L['GLOW_COLOR']);

ExtendedOptions.GlowColorName = E.CreateDropdown('color', ExtendedOptions);
ExtendedOptions.GlowColorName:SetPosition('TOPLEFT', ExtendedOptions.GlowColorNameText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.GlowColorName:SetSize(140, 20);
ExtendedOptions.GlowColorName.OnValueChangedCallback = function(_, name)
    O.db.custom_npc[ExtendedOptions.id].glow_color_name = name;

    S:GetNameplateModule('Handler'):UpdateAll();
end

ExtendedOptions.RemoveButton = E.CreateTextureButton(ExtendedOptions, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.TRASH_WHITE, { 1, 0.2, 0.2, 1});
ExtendedOptions.RemoveButton:SetPosition('BOTTOMRIGHT', ExtendedOptions, 'BOTTOMRIGHT', -6, 8);
ExtendedOptions.RemoveButton:SetSize(16, 16);
ExtendedOptions.RemoveButton:SetScript('OnClick', function(_)
    if O.db.custom_npc[ExtendedOptions.id] then
        O.db.custom_npc[ExtendedOptions.id] = nil;

        ExtendedOptions:Hide();
        ExtendedOptions.anchor.isHighlighted = false;
        ExtendedOptions.anchor.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

        panel:UpdateMainContentList();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
end);

local function ExtendedOptionsHide()
    ExtendedOptions:Hide();
    ExtendedOptions.anchor.isHighlighted = false;
    ExtendedOptions.anchor:SetBackdropColor(unpack(ExtendedOptions.anchor.backgroundColor));
    ExtendedOptions.anchor.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
end

if UIDropDownMenu_HandleGlobalMouseEvent then
    local function ExtendedOptions_CloseNotActive()
        if not (O.frame and O.frame:IsShown()) then
            return;
        end

        if ExtendedOptions:IsShown() and not ExtendedOptions:IsMouseOver() and not ExtendedOptions.anchor:IsMouseOver() and not _G['StripesDropdownList']:IsMouseOver() then
            ExtendedOptionsHide();
        end
    end

    hooksecurefunc('UIDropDownMenu_HandleGlobalMouseEvent', function(b, event)
        if event == 'GLOBAL_MOUSE_DOWN' and (b == 'LeftButton' or b == 'RightButton') then
            ExtendedOptions_CloseNotActive();
        end
    end);
end

panel.CreateMainContentRow = function(frame)
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

    frame.EditButton = E.CreateTextureButton(frame, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.PENCIL_WHITE);
    frame.EditButton:SetPosition('RIGHT', frame.ToggleExtendedOptions, 'LEFT', -8, 0);
    frame.EditButton:SetSize(14, 14);
    frame.EditButton:SetScript('OnClick', function(self)
        self:GetParent().EditBox:SetText(self:GetParent().npc_new_name or self:GetParent().npc_name or '');
        self:GetParent().EditBox:Show();
        self:GetParent().EditBox:SetFocus();
        self:GetParent().EditBox:SetCursorPosition(0);
    end);
    frame.EditButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(unpack(self:GetParent().highlightColor));
    end);
    frame.EditButton:HookScript('OnLeave', function(self)
        if not self:GetParent().isHighlighted then
            self:GetParent():SetBackdropColor(unpack(self:GetParent().backgroundColor));
        end
    end);

    frame:HookScript('OnDoubleClick', function(self)
        self.EditBox:SetText(self.npc_new_name or self.npc_name or '');
        self.EditBox:Show();
        self.EditBox:SetFocus();
        self.EditBox:SetCursorPosition(0);

        if ExtendedOptions:IsShown() then
            ExtendedOptions:Hide();

            self.isHighlighted = false;
            self:SetBackdropColor(unpack(self.backgroundColor));
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        end
    end);

    frame:SetScript('OnClick', function(self)
        GameTooltip_Hide();

        if IsShiftKeyDown() then
            if O.db.custom_npc[self.npc_id] then
                O.db.custom_npc[self.npc_id] = nil;

                self.isHighlighted = false;
                self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

                ExtendedOptions:Hide();

                panel:UpdateMainContentList();
                S:GetNameplateModule('Handler'):UpdateAll();
            end

            return;
        end

        if not self:IsMouseOver() then
            ExtendedOptionsHide();
        end

        if ExtendedOptions:IsShown() then
            ExtendedOptions:Hide();

            self.isHighlighted = false;
            self:SetBackdropColor(unpack(self.backgroundColor));
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        else
            ExtendedOptions:UpdateAll(self);
        end
    end);

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 10, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.custom_npc[self:GetParent().npc_id].enabled = self:GetChecked();
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

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.CategoryNameText, 'RIGHT', 8, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame.EditBox = E.CreateEditBox(frame);
    frame.EditBox:SetPosition('LEFT', frame.CategoryNameText, 'RIGHT', 8, 0);
    frame.EditBox:SetFrameLevel(frame.EditBox:GetFrameLevel() + 10);
    frame.EditBox:SetSize(NAME_WIDTH, ROW_HEIGHT);
    frame.EditBox:Hide();
    frame.EditBox:SetScript('OnEnterPressed', function(self)
        UpdateEntryName(self, self:GetParent().npc_id, self:GetParent().npc_name, self:GetText());
    end);
    frame.EditBox.FocusLostCallback = function(self)
        self:Hide();
    end

    E.CreateTooltip(frame, nil, nil, true);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);
        self.ToggleExtendedOptions:SetVertexColor(1, 0.85, 0, 1);

        if not self.npc_new_name or self.npc_name == self.npc_new_name then
            self.NameText:SetText(self.npc_name .. '    |cffaaaaaa' .. self.npc_id .. ' | ' .. (self.color_enabled and self.color_name or L['NO']) .. ' | ' .. O.Lists.glow_type_short_with_none[self.glow_type] .. '|r');
        else
            self.NameText:SetText(self.npc_new_name .. ' |cffaaaaaa[' .. self.npc_name .. ']|r   |cffaaaaaa' .. self.npc_id .. ' | ' .. (self.color_enabled and self.color_name or L['NO']) .. ' | ' .. O.Lists.glow_type_short_with_none[self.glow_type] .. '|r');
        end

        if ExtendedOptions:IsShown() then
            GameTooltip_Hide();
        else
            if not D.ModelBlacklist[self.npc_id] then
                ModelFrame:SetCreature(self.npc_id);
                GameTooltip_InsertFrame(GameTooltip, HolderModelFrame, 0);
                HolderModelFrame:SetSize(GameTooltip:GetWidth(), GameTooltip:GetWidth() * 2);
                HolderModelFrame:SetPoint('TOPLEFT', GameTooltip, 'BOTTOMLEFT', 0, -1);
                ModelFrame:SetSize(GameTooltip:GetWidth() - 3, GameTooltip:GetWidth() * 2 - 3);
                ModelFrame:SetCamDistanceScale(1.2);
            end
        end
    end);

    frame:HookScript('OnLeave', function(self)
        if not self.isHighlighted then
            self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        end

        self.NameText:SetText(self.npc_name);

        if not self.npc_new_name or self.npc_name == self.npc_new_name then
            self.NameText:SetText(self.npc_name);
        else
            self.NameText:SetText(self.npc_new_name .. ' |cffaaaaaa[' .. self.npc_name .. ']|r');
        end
    end);
end

panel.UpdateMainContentRow = function(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.CustomNPCScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.CustomNPCScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', MainContentActiveRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', MainContentActiveRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    frame:SetSize(frame:GetParent():GetWidth(), ROW_HEIGHT);

    if frame.index % 2 == 0 then
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame:SetBackdropColor(unpack(frame.backgroundColor));

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.CategoryNameText:SetText(frame.category_name);

    if not frame.npc_new_name or frame.npc_name == frame.npc_new_name then
        frame.NameText:SetText(frame.npc_name);
    else
        frame.NameText:SetText(frame.npc_new_name .. ' |cffaaaaaa[' .. frame.npc_name .. ']|r');
    end

    if frame.color_enabled then
        local color = Colors:Get(frame.color_name);
        if color then
            frame.ColorLine:SetColorTexture(unpack(color));
            frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4] = color[1], color[2], color[3], 0.5;
        else
            frame.ColorLine:SetColorTexture(0.1, 0.1, 0.1, 1);
            frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4] = 0.1, 0.1, 0.1, 0.5;
        end
    else
        frame.ColorLine:SetColorTexture(0.1, 0.1, 0.1, 1);
        frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4] = 0.1, 0.1, 0.1, 0.5;
    end

    frame.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

    if ExtendedOptions:IsShown() and ExtendedOptions.id == frame.npc_id then
        ExtendedOptions:UpdateAll(frame);
    end

    frame.tooltip = string.format(LIST_TOOLTIP_PATTERN, frame.npc_name, frame.npc_id);
end

panel.UpdateMainContentList = function()
    wipe(MainContentActiveRows);
    wipe(MainContentSortedRows);

    for npc_id, data in pairs(O.db.custom_npc) do
        data.npc_id = npc_id;
        table.insert(MainContentSortedRows, data);
    end

    table.sort(MainContentSortedRows, function(a, b)
        return a.npc_name < b.npc_name;
    end);

    framePool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local found;

    for _, data in ipairs(MainContentSortedRows) do
        if panel.searchWordLower then
            found = string.find(string.lower(data.npc_name), panel.searchWordLower, 1, true);

            if not found then
                found = string.find(string.lower(data.npc_new_name or ''), panel.searchWordLower, 1, true);
            end

            if not found then
                found = string.find(data.npc_id, panel.searchWordLower, 1, true);
            end
        elseif panel.categoryName then
            found = (panel.categoryName == CATEGORY_ALL_NAME or (panel.categoryName == CATEGORY_ALL_NAME and not data.category_name) or data.category_name == panel.categoryName);
        else
            found = true;
        end

        if found then
            index = index + 1;

            frame, isNew = framePool:Acquire();

            table.insert(MainContentActiveRows, frame);

            if isNew then
                panel.CreateMainContentRow(frame);
            end

            frame.index        = index;
            frame.enabled      = data.enabled;
            frame.npc_id       = data.npc_id;
            frame.npc_name     = data.npc_name;
            frame.npc_new_name = data.npc_new_name or data.npc_name;

            frame.glow_enabled = data.glow_type ~= 0;
            frame.glow_type    = data.glow_type or 0;

            if not O.db.custom_npc[data.npc_id].glow_color_name or not Colors:Get(O.db.custom_npc[data.npc_id].glow_color_name) then
                O.db.custom_npc[data.npc_id].glow_color_name = DEFAULT_GLOW_COLOR_NAME;
            end

            frame.glow_color_name = O.db.custom_npc[data.npc_id].glow_color_name;

            frame.color_enabled  = O.db.custom_npc[data.npc_id].color_enabled;

            if not O.db.custom_npc[data.npc_id].color_name or not Colors:Get(O.db.custom_npc[data.npc_id].color_name) then
                O.db.custom_npc[data.npc_id].color_name = DEFAULT_HB_COLOR_NAME;
            end

            frame.color_name = O.db.custom_npc[data.npc_id].color_name;

            if O.db.custom_npc_categories[data.category_name] then
                O.db.custom_npc[data.npc_id].category_name = data.category_name;
            else
                O.db.custom_npc[data.npc_id].category_name = CATEGORY_ALL_NAME;
            end

            frame.category_name = O.db.custom_npc[data.npc_id].category_name;
            frame.category_list = panel:GetCategoryDropdown();

            panel.UpdateMainContentRow(frame);

            frame:Show();
        end
    end

    PixelUtil.SetSize(panel.CustomNPCScrollArea.scrollChild, panel.CustomNPCEditFrame:GetWidth(), panel.CustomNPCEditFrame:GetHeight() - (panel.CustomNPCEditFrame:GetHeight() % ROW_HEIGHT));
end

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    self.custom_npc_enabled = E.CreateCheckButton(self);
    self.custom_npc_enabled:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.custom_npc_enabled:SetLabel(L['OPTIONS_CUSTOM_NPC_ENABLED']);
    self.custom_npc_enabled:SetTooltip(L['OPTIONS_CUSTOM_NPC_ENABLED_TOOLTIP']);
    self.custom_npc_enabled:AddToSearch(button, L['OPTIONS_CUSTOM_NPC_ENABLED_TOOLTIP']);
    self.custom_npc_enabled:SetChecked(O.db.custom_npc_enabled);
    self.custom_npc_enabled.Callback = function(self)
        O.db.custom_npc_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    local EditBox = E.CreateEditBox(self);
    EditBox:SetPosition('TOPLEFT', self.custom_npc_enabled, 'BOTTOMLEFT', 5, -8);
    EditBox:SetSize(160, 22);
    EditBox.useLastValue = false;
    EditBox:SetInstruction(L['OPTIONS_CUSTOM_NPC_EDITBOX_ENTER_ID']);
    EditBox:SetScript('OnEnterPressed', function(self)
        local npc_id = tonumber(strtrim(self:GetText()));

        if type(npc_id) ~= 'number' or npc_id == 0 then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        local npc_name = U.GetNpcNameByID(npc_id);

        if not npc_name then
            C_Timer.After(DELAY_SECONDS, function()
                npc_name = U.GetNpcNameByID(npc_id);

                AddEntry(npc_id, npc_name);

                panel:UpdateMainContentList();
                self:SetText('');

                Stripes:UpdateAll();
            end);
        else
            AddEntry(npc_id, npc_name);

            panel:UpdateMainContentList();
            self:SetText('');

            Stripes:UpdateAll();
        end
    end);

    local AddFromTargetButton = E.CreateButton(self);
    AddFromTargetButton:SetPosition('LEFT', EditBox, 'RIGHT', 12, 0);
    AddFromTargetButton:SetLabel(L['OPTIONS_CUSTOM_NPC_ADD_FROM_TARGET']);
    AddFromTargetButton:SetScript('OnClick', function()
        if not UnitExists('target') or UnitIsPlayer('target') then
            return;
        end

        local npc_id   = U.GetNpcID('target');
        local npc_name = UnitName('target');

        if not npc_id or npc_id == 0 or not npc_name then
            return;
        end

        npc_id = tonumber(npc_id);

        AddEntry(npc_id, npc_name);

        panel:UpdateMainContentList();
        EditBox:SetText('');

        Stripes:UpdateAll();
    end);

    local AddFromList = E.CreateButton(self);
    AddFromList:SetPosition('LEFT', AddFromTargetButton, 'RIGHT', 8, 0);
    AddFromList:SetLabel(L['OPTIONS_CUSTOM_NPC_ADD_FROM_LIST']);
    AddFromList:SetScript('OnClick', function(self)
        panel.ChooseNPCList:SetShown(not panel.ChooseNPCList:IsShown());

        if panel.ChooseNPCList:IsShown() then
            self:LockHighlight();
        else
            self:UnlockHighlight();
        end

        Colors:HideListFrame();
        panel.CategoryList:Hide();
    end);

    self.SearchEditBox = E.CreateEditBox(self);
    self.SearchEditBox:SetPosition('TOPLEFT', EditBox, 'BOTTOMLEFT', 0, -11);
    self.SearchEditBox:SetSize(160, 22);
    self.SearchEditBox:SetUseLastValue(false);
    self.SearchEditBox:SetInstruction(L['SEARCH']);
    self.SearchEditBox:SetScript('OnEnterPressed', function(self)
        panel.searchWordLower = string.lower(strtrim(self:GetText()) or '');

        if panel.searchWordLower == '' then
            panel.searchWordLower = nil;
            panel.ResetSearchEditBox:Hide();
        end

        if panel.searchWordLower then
            panel.ResetSearchEditBox:Show();
        end

        panel:UpdateMainContentList();
    end);
    self.SearchEditBox.FocusGainedCallback = function()
        panel.ResetSearchEditBox:Show();
    end
    self.SearchEditBox.FocusLostCallback = function(self)
        panel.ResetSearchEditBox:SetShown(self:GetText() ~= '');
    end
    self.SearchEditBox.OnTextChangedCallback = function(self)
        if self:GetText() ~= '' then
            panel.ResetSearchEditBox:Show();
        else
            panel.ResetSearchEditBox:Hide();
        end
    end

    self.ResetSearchEditBox = E.CreateTextureButton(self.SearchEditBox, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.CROSS_WHITE);
    self.ResetSearchEditBox:SetPosition('RIGHT', self.SearchEditBox, 'RIGHT', 0, 0);
    self.ResetSearchEditBox:SetSize(12, 12);
    self.ResetSearchEditBox:Hide();
    self.ResetSearchEditBox:SetScript('OnClick', function(self)
        panel.searchWordLower = nil;

        panel.SearchEditBox:SetText('');
        panel.SearchEditBox.Instruction:Show();
        panel:UpdateMainContentList();

        self:Hide();
    end);

    self.CategoryDropdown = E.CreateDropdown('plain', self);
    self.CategoryDropdown:SetPosition('LEFT', self.SearchEditBox, 'RIGHT', 11, 0);
    self.CategoryDropdown:SetSize(160, 22);
    self.CategoryDropdown:SetList(self:GetCategoryDropdown(), SortCategoryByName, true);
    self.CategoryDropdown:SetValue(CATEGORY_ALL_NAME);
    self.CategoryDropdown.OnValueChangedCallback = function(_, _, value)
        panel.categoryName = value;
        panel:UpdateMainContentList();
    end

    self.OpenCategoryList = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.LIST_WHITE, { 1, 1, 1, 1 });
    self.OpenCategoryList:SetPosition('LEFT', self.CategoryDropdown, 'RIGHT', 12, 0);
    self.OpenCategoryList:SetSize(18, 18);
    self.OpenCategoryList:SetTooltip(L['OPTIONS_CATEGORY_OPEN_TOOLTIP']);
    self.OpenCategoryList.Callback = function()
        panel.CategoryList:SetShown(not panel.CategoryList:IsShown());

        Colors:HideListFrame();

        panel.ChooseNPCList:Hide();
        AddFromList:UnlockHighlight();
    end

    self.CustomNPCEditFrame = CreateFrame('Frame', nil, self, 'BackdropTemplate');
    self.CustomNPCEditFrame:SetPoint('TOPLEFT', self.SearchEditBox, 'BOTTOMLEFT', -5, -8);
    self.CustomNPCEditFrame:SetPoint('BOTTOMRIGHT', O.frame.Right.CustomNPC, 'BOTTOMRIGHT', 0, 0);
    self.CustomNPCEditFrame:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CustomNPCEditFrame:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.CustomNPCScrollChild, self.CustomNPCScrollArea = E.CreateScrollFrame(self.CustomNPCEditFrame, ROW_HEIGHT);

    PixelUtil.SetPoint(self.CustomNPCScrollArea.ScrollBar, 'TOPLEFT', self.CustomNPCScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.CustomNPCScrollArea.ScrollBar, 'BOTTOMLEFT', self.CustomNPCScrollArea, 'BOTTOMRIGHT', -8, 0);

    framePool = CreateFramePool('Button', self.CustomNPCScrollChild, 'BackdropTemplate');

    self.ChooseNPCList = Mixin(CreateFrame('Frame', nil, self, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.ChooseNPCList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.ChooseNPCList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.ChooseNPCList:SetWidth(250);
    self.ChooseNPCList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.ChooseNPCList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.ChooseNPCList:Hide();

    self.ChooseNPCListDropdown = E.CreateDropdown('plain', self.ChooseNPCList);
    self.ChooseNPCListDropdown:SetPosition('TOP', self.ChooseNPCList, 'TOP', 0, -10);
    self.ChooseNPCListDropdown:SetSize(228, 20);
    self.ChooseNPCListDropdown:SetList(O.Lists.custom_color_npcs);
    self.ChooseNPCListDropdown:SetValue(DEFAULT_LIST_VALUE);
    self.ChooseNPCListDropdown.OnValueChangedCallback = function(_, value)
        panel.UpdateChooseNPCList(value);
        panel.ChooseNPCListScrollArea.ScrollBar:SetValue(0);
    end

    self.ChooseNPCListScroll = Mixin(CreateFrame('Frame', nil, self.ChooseNPCList, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.ChooseNPCListScroll:SetPoint('TOPLEFT', self.ChooseNPCList , 'TOPLEFT', 6, -40);
    self.ChooseNPCListScroll:SetPoint('BOTTOMRIGHT', self.ChooseNPCList, 'BOTTOMRIGHT', -6, 6);
    self.ChooseNPCListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.ChooseNPCListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.ChooseNPCListScrollChild, self.ChooseNPCListScrollArea = E.CreateScrollFrame(self.ChooseNPCListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.ChooseNPCListScrollArea.ScrollBar, 'TOPLEFT', self.ChooseNPCListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.ChooseNPCListScrollArea.ScrollBar, 'BOTTOMLEFT', self.ChooseNPCListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.ChooseNPCListButtonPool = CreateFramePool('Button', self.ChooseNPCListScrollChild, 'BackdropTemplate');

    self.ProfilesDropdown = E.CreateDropdown('plain', self);
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.CustomNPCEditFrame, 'TOPRIGHT', 0, 40);
    self.ProfilesDropdown:SetSize(157, 22);
    self.ProfilesDropdown:SetTooltip(L['OPTIONS_COPY_REPLACE_FROM_PROFILE_TOOLTIP']);
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);

        if not index then
            self:SetValue(nil);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].colors_data);
            wipe(StripesDB.profiles[O.activeProfileId].custom_npc_categories);
            wipe(StripesDB.profiles[O.activeProfileId].custom_npc);

            StripesDB.profiles[O.activeProfileId].colors_data           = U.DeepCopy(StripesDB.profiles[index].colors_data);
            StripesDB.profiles[O.activeProfileId].custom_npc_categories = U.DeepCopy(StripesDB.profiles[index].custom_npc_categories);
            StripesDB.profiles[O.activeProfileId].custom_npc            = U.DeepCopy(StripesDB.profiles[index].custom_npc);
        else
            -- Colors
            for n, c in pairs(StripesDB.profiles[index].colors_data) do
                StripesDB.profiles[O.activeProfileId].colors_data[n] = { c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1 };
            end

            -- Categories
            for n, _ in pairs(StripesDB.profiles[index].custom_npc_categories) do
                StripesDB.profiles[O.activeProfileId].custom_npc_categories[n] = true;
            end

            StripesDB.profiles[O.activeProfileId].custom_npc = U.Merge(StripesDB.profiles[index].custom_npc, StripesDB.profiles[O.activeProfileId].custom_npc);
        end

        self:SetValue(nil);

        Colors:UpdateAllLists();
        Colors:UpdateListScroll();

        panel:UpdateCategoryList();
        panel.CategoryDropdown:SetList(panel:GetCategoryDropdown(), SortCategoryByName, true);

        Stripes:UpdateAll();
    end

    self.CopyFromProfileText = E.CreateFontString(self);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);

    self.ColorCategoryToggleButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.PALETTE_COLOR, { 1, 1, 1, 1 }, { 1, 1, 0.5, 1 });
    self.ColorCategoryToggleButton:SetPosition('TOPRIGHT', self.ProfilesDropdown, 'BOTTOMRIGHT', -2, -12);
    self.ColorCategoryToggleButton:SetTooltip(L['OPTIONS_COLOR_CATEGORY_TOGGLE_FRAME']);
    self.ColorCategoryToggleButton:SetSize(19, 18);
    self.ColorCategoryToggleButton.Callback = function()
        AddFromList:UnlockHighlight();

        Colors:ToggleListFrame();

        panel.ChooseNPCList:Hide();
        panel.CategoryList:Hide();
    end

    self.HelpTipButton = E.CreateHelpTipButton(self);
    self.HelpTipButton:SetPosition('TOPLEFT', self.ProfilesDropdown, 'BOTTOMLEFT', 2, -12);
    self.HelpTipButton:SetTooltip(L['OPTIONS_SHIFT_CLICK_TO_DELETE']);

    self.UpdateNamesButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE, { 1, 1, 1, 1 });
    self.UpdateNamesButton:SetPosition('LEFT', self.HelpTipButton, 'RIGHT', 24, 0);
    self.UpdateNamesButton:SetSize(18, 18);
    self.UpdateNamesButton:SetTooltip(L['OPTIONS_UPDATE_NPCS_NAMES_TOOLTIP']);
    self.UpdateNamesButton.Callback = function()
        local npc_name;

        for npc_id, _ in pairs(O.db.custom_npc) do
            npc_name = U.GetNpcNameByID(npc_id);

            if not npc_name then
                C_Timer.After(DELAY_SECONDS, function()
                    npc_name = U.GetNpcNameByID(npc_id);

                    AddEntry(npc_id, npc_name);

                    panel:UpdateMainContentList();
                    Stripes:UpdateAll();
                end);
            else
                AddEntry(npc_id, npc_name);
            end
        end

        panel:UpdateMainContentList();
        Stripes:UpdateAll();
    end

    self.CategoryList = Mixin(CreateFrame('Frame', nil, self, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.CategoryList:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.CategoryList:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.CategoryList:SetWidth(250);
    self.CategoryList:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CategoryList:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.CategoryList:Hide();

    self.CategoryEditbox = E.CreateEditBox(self.CategoryList);
    self.CategoryEditbox:SetPosition('TOP', self.CategoryList, 'TOP', 0, -10);
    self.CategoryEditbox:SetFrameLevel(self.CategoryList:GetFrameLevel() + 10);
    self.CategoryEditbox:SetSize(228, 20);
    self.CategoryEditbox:SetMaxLetters(CATEGORY_MAX_LETTERS);
    self.CategoryEditbox.useLastValue = false;
    self.CategoryEditbox:SetInstruction(L['OPTIONS_CATEGORY_ENTER_NAME']);
    self.CategoryEditbox:SetScript('OnEnterPressed', function(self)
        local name = strtrim(self:GetText());

        if not name or name == '' or string.lower(name) == string.lower(CATEGORY_ALL_NAME) then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        O.db.custom_npc_categories[name] = true;

        self:SetText('');
        self:ClearFocus();

        panel:UpdateMainContentList();
        panel:UpdateCategoryList();

        panel.CategoryDropdown:SetList(panel:GetCategoryDropdown(), SortCategoryByName, true);
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

    Colors:AddScroll(self.UpdateMainContentList);
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');
    Profile.UpdateProfilesDropdown(self.ProfilesDropdown, true);
end

panel.OnShowOnce = function(self)
    self:UpdateMainContentList();
    self:UpdateCategoryList();

    for i = 1, #O.Lists.custom_color_npcs do
        self.UpdateChooseNPCList(i);
        self.UpdateChooseNPCList(i);
    end

    self.UpdateChooseNPCList(DEFAULT_LIST_VALUE);
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    Colors:UpdateAllLists();
    Colors:UpdateListScroll();

    self:UpdateMainContentList();
    self:UpdateCategoryList();
    self.CategoryDropdown:SetList(self:GetCategoryDropdown(), SortCategoryByName, true);
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end