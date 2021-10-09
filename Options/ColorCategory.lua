local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_ColorCategory');

local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local ROW_HEIGHT = 28;
local CATEGORY_MAX_LETTERS = 25;

local PREDEFINED_COLORS = {
    {
        name  = 'White',
        color = { 1, 1, 1, 1 },
    },

    {
        name  = 'Silver',
        color = { 0.75, 0.75, 0.75, 1 },
    },

    {
        name  = 'Gray',
        color = { 0.5, 0.5, 0.5, 1 },
    },

    {
        name  = 'Black',
        color = { 0, 0, 0, 1 },
    },

    {
        name  = 'Red',
        color = { 1, 0, 0, 1 },
    },

    {
        name  = 'Orange Red',
        color = { 1, 0.27, 0, 1 },
    },

    {
        name  = 'Maroon',
        color = { 0.5, 0, 0, 1},
    },

    {
        name  = 'Saddle Brown',
        color = { 0.55, 0.27, 0.07, 1 },
    },

    {
        name  = 'Yellow',
        color = { 1, 1, 0, 1},
    },

    {
        name  = 'Moccasin',
        color = { 1, 0.89, 0.71, 1 },
    },

    {
        name  = 'Meadowlark',
        color = { 0.93, 0.86, 0.33, 1 },
    },

    {
        name  = 'Olive',
        color = { 0.5, 0.5, 0, 1 },
    },

    {
        name  = 'Lime',
        color = { 0, 1, 0, 1 },
    },

    {
        name  = 'Green',
        color = { 0, 0.5, 0, 1 },
    },

    {
        name  = 'Aqua',
        color = { 0, 1, 1, 1 },
    },

    {
        name  = 'Teal',
        color = { 0, 0.5, 0.5, 1 },
    },

    {
        name  = 'Blue',
        color = { 0, 0, 1, 1 },
    },

    {
        name  = 'Navy',
        color = { 0, 0, 0.5, 1 },
    },

    {
        name  = 'Fuchsia',
        color = { 1, 0, 1, 1 },
    },

    {
        name  = 'Purple',
        color = { 0.5, 0, 0.5 },
    },

    {
        name  = 'Ultra Violet',
        color = { 0.42, 0.36, 0.58, 1  },
    },

    {
        name  = 'Dark Orange',
        color = { 1, 0.55, 0, 1  },
    },

    {
        name  = 'Coral',
        color = { 1, 0.5, 0.31, 1  },
    },

    {
        name = 'Aquamarine',
        color = { 0.5, 1, 0.83, 1  },
    },

    {
        name = 'Slate Gray',
        color = { 0.44, 0.5, 0.56, 1  },
    },
}

local List = Mixin(CreateFrame('Frame', nil, O.frame, 'BackdropTemplate'), E.PixelPerfectMixin);
List:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
List:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
List:SetWidth(250);
List:SetBackdrop(BACKDROP);
List:SetBackdropColor(0.1, 0.1, 0.1, 1);
List:SetShown(false);
Module.List = List;

local EditBox = E.CreateEditBox(List);
EditBox:SetPosition('TOP', List, 'TOP', 0, -10);
EditBox:SetFrameLevel(List:GetFrameLevel() + 10);
EditBox:SetSize(228, 20);
EditBox:SetMaxLetters(CATEGORY_MAX_LETTERS);
EditBox:SetInstruction(L['OPTIONS_COLOR_CATEGORY_ENTER_NAME']);
EditBox.useLastValue = false;
EditBox:SetScript('OnEnterPressed', function(self)
    local name = strtrim(self:GetText());

    if not name or name == '' then
        self:SetText('');
        self:ClearFocus();
        return;
    end

    Module.AddColorCategory(name);

    Module:UpdateAllLists();
    Module:UpdateListScroll();

    self:SetText('');
    self:ClearFocus();
end);

local ListScroll = Mixin(CreateFrame('Frame', nil, List, 'BackdropTemplate'), E.PixelPerfectMixin);
ListScroll:SetPoint('TOPLEFT', List , 'TOPLEFT', 6, -40);
ListScroll:SetPoint('BOTTOMRIGHT', List, 'BOTTOMRIGHT', -6, 6);
ListScroll:SetBackdrop(BACKDROP);
ListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

local ListScrollChild, ListScrollArea = E.CreateScrollFrame(ListScroll, ROW_HEIGHT);

PixelUtil.SetPoint(ListScrollArea.ScrollBar, 'TOPLEFT', ListScrollArea, 'TOPRIGHT', -8, 0);
PixelUtil.SetPoint(ListScrollArea.ScrollBar, 'BOTTOMLEFT', ListScrollArea, 'BOTTOMRIGHT', -8, 0);

local ListButtonPool = CreateFramePool('Button', ListScrollChild, 'BackdropTemplate');

Module.AddColorCategory = function(name)
    if string.lower(name) == string.lower(L['NO']) then
        return;
    end

    for _, data in ipairs(O.db.color_category_data) do
        if data.name == name then
            return;
        end
    end

    table.insert(O.db.color_category_data, { name = name, color = { 1, 1, 1, 1 } });
end

Module.UpdateName = function(editbox, index, newName)
    newName = strtrim(newName);

    if not newName or newName == '' or string.lower(newName) == string.lower(L['NO']) then
        return editbox:SetShown(false);
    end

    if not index or not O.db.color_category_data[index] then
        return editbox:SetShown(false);
    end

    if O.db.color_category_data[index].name == newName then
        return editbox:SetShown(false);
    end

    for _, data in ipairs(O.db.color_category_data) do
        if data.name == newName then
            return editbox:SetShown(false);
        end
    end

    O.db.color_category_data[index].name = newName;

    Module:UpdateAllLists();
    Module:UpdateListScroll();
    editbox:SetShown(false);
end

local DataListRows = {};

local CreateListRow = function(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.ColorPicker = E.CreateColorPicker(frame);
    frame.ColorPicker:SetPosition('LEFT', frame, 'LEFT', 4, 0);
    frame.ColorPicker.OnValueChanged = function(self, r, g, b, a)
        local index = self:GetParent().dbIndex;
        if not index then
            return;
        end

        O.db.color_category_data[index].color[1] = r;
        O.db.color_category_data[index].color[2] = g;
        O.db.color_category_data[index].color[3] = b;
        O.db.color_category_data[index].color[4] = a or 1;

        Module:UpdateAllLists();
        Module:UpdateOtherScrolls();
    end
    frame.ColorPicker:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);
    frame.ColorPicker:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.ColorPicker, 'RIGHT', 8, 0);
    frame.NameText:SetSize(170, ROW_HEIGHT);

    frame.EditBox = E.CreateEditBox(frame);
    frame.EditBox:SetPosition('LEFT', frame.ColorPicker, 'RIGHT', 8, 0);
    frame.EditBox:SetFrameLevel(frame.EditBox:GetFrameLevel() + 10);
    frame.EditBox:SetSize(170, ROW_HEIGHT);
    frame.EditBox:SetShown(false);
    frame.EditBox:SetScript('OnEnterPressed', function(self)
        local index = self:GetParent().dbIndex;
        if not index then
            return;
        end

        Module.UpdateName(self, index, self:GetText());
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
        local index = self:GetParent().dbIndex;
        if not index then
            return;
        end

        table.remove(O.db.color_category_data, index);

        Module:UpdateAllLists();
        Module:UpdateListScroll();
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

local UpdateListRow = function(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', ListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', ListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataListRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataListRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
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
    frame.ColorPicker:SetValue(unpack(frame.color));
end

local colorCategorySortedData = {};
Module.UpdateListScroll = function()
    wipe(DataListRows);
    wipe(colorCategorySortedData);

    for index, data in pairs(O.db.color_category_data) do
        data.index = index;
        table.insert(colorCategorySortedData, data);
    end

    table.sort(colorCategorySortedData, function(a, b)
        return a.name < b.name;
    end);

    ListButtonPool:ReleaseAll();

    local frame, isNew;

    for index, data in ipairs(colorCategorySortedData) do
        frame, isNew = ListButtonPool:Acquire();

        table.insert(DataListRows, frame);

        if isNew then
            CreateListRow(frame);
        end

        frame.index   = index;
        frame.dbIndex = data.index;
        frame.name    = data.name;
        frame.color   = data.color;

        UpdateListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(ListScrollArea.scrollChild, ListScroll:GetWidth(), ListScroll:GetHeight() - (ListScroll:GetHeight() % ROW_HEIGHT));

    Module:UpdateOtherScrolls();
end

local OtherScrollsTable = {};

function Module:AddScroll(func)
    table.insert(OtherScrollsTable, func);
end

function Module:UpdateOtherScrolls()
    for _, func in ipairs(OtherScrollsTable) do
        func();
    end
end

function Module:GetPredefinedList()
    return PREDEFINED_COLORS;
end

Module.PredefinedDropdownList = {};
function Module:UpdatePredefinedDropdownList()
    wipe(self.PredefinedDropdownList);

    for index, data in ipairs(PREDEFINED_COLORS) do
        self.PredefinedDropdownList[index] = data.name;
    end

    self.PredefinedDropdownList[0] = L['NO'];
end

function Module:GetPredefinedDropdownList()
    return self.PredefinedDropdownList;
end

Module.CustomList = {};
function Module:UpdateCustomList()
    wipe(self.CustomList);

    for _, data in ipairs(O.db.color_category_data) do
        table.insert(self.CustomList, { name = data.name, color = data.color });
    end
end

function Module:GetCustomList()
    return self.CustomList;
end

Module.CustomDropdownList = {};
function Module:UpdateCustomDropdownList()
    wipe(self.CustomDropdownList);

    for index, data in ipairs(O.db.color_category_data) do
        self.CustomDropdownList[index] = data.name;
    end

    self.CustomDropdownList[0] = L['NO'];
end

function Module:GetCustomDropdownList()
    return self.CustomDropdownList;
end

function Module:UpdateAllLists()
    self:UpdatePredefinedDropdownList();

    self:UpdateCustomList();
    self:UpdateCustomDropdownList();
end

function Module:ToggleListFrame()
    List:SetShown(not List:IsShown());
end

function Module:ShowListFrame()
    List:Show();
end

function Module:HideListFrame()
    List:Hide();
end

function Module:StartUp()
    self:UpdateAllLists();
    self:UpdateListScroll();
end