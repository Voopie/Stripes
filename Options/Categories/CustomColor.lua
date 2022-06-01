local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CustomColor');
local Profile = S:GetModule('Options_Categories_Profiles');
local Colors = S:GetModule('Options_Colors');

O.frame.Left.CustomColor, O.frame.Right.CustomColor = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CUSTOMCOLOR']), 'customcolor', 7);
local button = O.frame.Left.CustomColor;
local panel = O.frame.Right.CustomColor;

local framePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local BACKDROP_BORDER_2 = { bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Buttons\\WHITE8x8', edgeSize = 2 };
local NAME_WIDTH = 420;
local CATEGORY_MAX_LETTERS = 20;
local DELAY_SECONDS = 0.25;

local DEFAULT_LIST_VALUE = 1;
local LIST_TOOLTIP_PATTERN = '|cffff6666%s|r  |cffffffff| |r |cffffb833%s|r';

local CATEGORY_ALL_NAME = O.CATEGORY_ALL_NAME;
local DEFAULT_GLOW_COLOR_NAME = 'Yellow';
local DEFAULT_HB_COLOR_NAME = 'Teal';

panel.categoryName = CATEGORY_ALL_NAME;

local HolderModelFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate');
HolderModelFrame:SetClipsChildren(true);
HolderModelFrame:SetFrameStrata('TOOLTIP');
HolderModelFrame:SetFrameLevel(1000);
HolderModelFrame:SetBackdrop({
    bgFile   = 'Interface\\Buttons\\WHITE8x8',
    insets   = {top = 1, left = 1, bottom = 1, right = 1},
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 1,
});
HolderModelFrame:SetBackdropColor(0.1, 0.1, 0.1, 1);
HolderModelFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1);
HolderModelFrame:SetShown(false);

local ModelFrame = CreateFrame('PlayerModel', nil, HolderModelFrame);
ModelFrame:SetPoint('CENTER', HolderModelFrame, 'CENTER', 0, 0);
ModelFrame:SetSize(150, 300);

local function SortCategoryByName(a, b)
    return a.value < b.value;
end

local function Add(id, name)
    if O.db.custom_color_data[id] then
        O.db.custom_color_data[id].npc_name = name;
    else
        O.db.custom_color_data[id] = {
            enabled  = true,

            npc_id   = id,
            npc_name = name,

            category_name = CATEGORY_ALL_NAME,

            color_enabled = true,
            color_name    = DEFAULT_HB_COLOR_NAME,

            glow_enabled    = false,
            glow_type       = 0,
            glow_color_name = DEFAULT_GLOW_COLOR_NAME,
        };
    end
end

local DataRows = {};

local ExtendedOptions = CreateFrame('Frame', nil, panel, 'BackdropTemplate');
ExtendedOptions:SetFrameLevel(100);
ExtendedOptions:SetSize(260, 300);
ExtendedOptions:SetBackdrop(BACKDROP_BORDER_2);
ExtendedOptions:SetClampedToScreen(true);
ExtendedOptions:SetShown(false);

ExtendedOptions.Update = function(self)
    self.ColorName:SetList(Colors:GetList());
    self.ColorName:SetValue(self.anchor.color_name);
    self.GlowColorName:SetList(Colors:GetList());
    self.GlowColorName:SetValue(self.anchor.glow_color_name);
end

ExtendedOptions.UpdateAll = function(self, frame)
    self.id     = frame.npc_id;
    self.anchor = frame;

    self.NameText:SetText(frame.name .. '  |cffaaaaaa[' .. frame.npc_id .. ']|r');

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
    if O.db.custom_color_data[ExtendedOptions.id] then
        O.db.custom_color_data[ExtendedOptions.id].category_name = value;
        panel:UpdateScroll();
    end
end

ExtendedOptions.ColorNameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.ColorNameText:SetPoint('TOPLEFT', ExtendedOptions.Category, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.ColorNameText:SetText(L['COLOR']);

ExtendedOptions.ColorName = E.CreateDropdown('color', ExtendedOptions);
ExtendedOptions.ColorName:SetPosition('TOPLEFT', ExtendedOptions.ColorNameText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.ColorName:SetSize(140, 20);
ExtendedOptions.ColorName.OnValueChangedCallback = function(_, name)
    O.db.custom_color_data[ExtendedOptions.id].color_name = name;

    panel:UpdateScroll();
    S:GetNameplateModule('Handler'):UpdateAll();

    ExtendedOptions:SetBackdropBorderColor(unpack(ExtendedOptions.anchor.highlightColor));
    ExtendedOptions:Update();
end

ExtendedOptions.ColorNameEnabled = E.CreateCheckButton(ExtendedOptions);
ExtendedOptions.ColorNameEnabled:SetPosition('LEFT', ExtendedOptions.ColorName, 'RIGHT', 12, 0);
ExtendedOptions.ColorNameEnabled.Callback = function(self)
    O.db.custom_color_data[ExtendedOptions.id].color_enabled = self:GetChecked();

    panel:UpdateScroll();
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

    O.db.custom_color_data[ExtendedOptions.id].glow_enabled = value ~= 0;
    O.db.custom_color_data[ExtendedOptions.id].glow_type    = value;

    panel:UpdateScroll();
    S:GetNameplateModule('Handler'):UpdateAll();
end

ExtendedOptions.GlowColorNameText = ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
ExtendedOptions.GlowColorNameText:SetPoint('TOPLEFT', ExtendedOptions.GlowType, 'BOTTOMLEFT', 0, -12);
ExtendedOptions.GlowColorNameText:SetText(L['GLOW_COLOR']);

ExtendedOptions.GlowColorName = E.CreateDropdown('color', ExtendedOptions);
ExtendedOptions.GlowColorName:SetPosition('TOPLEFT', ExtendedOptions.GlowColorNameText, 'BOTTOMLEFT', 0, -4);
ExtendedOptions.GlowColorName:SetSize(140, 20);
ExtendedOptions.GlowColorName.OnValueChangedCallback = function(_, name)
    O.db.custom_color_data[ExtendedOptions.id].glow_color_name = name;

    S:GetNameplateModule('Handler'):UpdateAll();
end

ExtendedOptions.RemoveButton = E.CreateTextureButton(ExtendedOptions, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.TRASH_WHITE, { 1, 0.2, 0.2, 1});
ExtendedOptions.RemoveButton:SetPosition('BOTTOMRIGHT', ExtendedOptions, 'BOTTOMRIGHT', -6, 8);
ExtendedOptions.RemoveButton:SetSize(16, 16);
ExtendedOptions.RemoveButton:SetScript('OnClick', function(_)
    if O.db.custom_color_data[ExtendedOptions.id] then
        O.db.custom_color_data[ExtendedOptions.id] = nil;

        ExtendedOptions:SetShown(false);
        ExtendedOptions.anchor.isHighlighted = false;
        ExtendedOptions.anchor.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

        panel:UpdateScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
end);

local function ExtendedOptionsHide()
    ExtendedOptions:SetShown(false);
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

local function CreateRow(frame)
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
        GameTooltip_Hide();

        if IsShiftKeyDown() then
            if O.db.custom_color_data[self.npc_id] then
                O.db.custom_color_data[self.npc_id] = nil;

                self.isHighlighted = false;
                self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);

                ExtendedOptions:SetShown(false);

                panel:UpdateScroll();
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
            self:SetBackdropColor(unpack(self.backgroundColor));
            self.ToggleExtendedOptions:SetVertexColor(0.7, 0.7, 0.7, 1);
        else
            ExtendedOptions:UpdateAll(self);
        end
    end);

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 10, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.custom_color_data[self:GetParent().npc_id].enabled = self:GetChecked();
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

    E.CreateTooltip(frame, nil, nil, true);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);
        self.ToggleExtendedOptions:SetVertexColor(1, 0.85, 0, 1);

        self.NameText:SetText(self.name .. '    |cffaaaaaa' .. self.npc_id .. ' | ' .. (self.color_enabled and self.color_name or L['NO']) .. ' | ' .. O.Lists.glow_type_short_with_none[self.glow_type] .. '|r');

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

        self.NameText:SetText(self.name);
    end);
end

local function UpdateRow(frame)
    if frame.index == 1 then
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.CustomColorScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.CustomColorScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(frame, 'TOPLEFT', DataRows[frame.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', DataRows[frame.index - 1], 'BOTTOMRIGHT', 0, 0);
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
    frame.CategoryNameText:SetText(frame.category_name);
    frame.NameText:SetText(frame.name);

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

    frame.tooltip = string.format(LIST_TOOLTIP_PATTERN, frame.name, frame.npc_id);
end

local sortedData = {};
panel.UpdateScroll = function()
    wipe(DataRows);
    wipe(sortedData);

    for npc_id, data in pairs(O.db.custom_color_data) do
        data.npc_id = npc_id;
        table.insert(sortedData, data);
    end

    table.sort(sortedData, function(a, b)
        return a.npc_name < b.npc_name;
    end);

    framePool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local found;

    for _, data in ipairs(sortedData) do
        if panel.searchWordLower then
            found = string.find(string.lower(data.npc_name), panel.searchWordLower, 1, true);

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

            table.insert(DataRows, frame);

            if isNew then
                CreateRow(frame);
            end

            frame.index        = index;
            frame.npc_id       = data.npc_id;
            frame.name         = data.npc_name;
            frame.enabled      = data.enabled;

            frame.glow_enabled = data.glow_type ~= 0;
            frame.glow_type    = data.glow_type or 0;

            if not O.db.custom_color_data[data.npc_id].glow_color_name or not Colors:Get(O.db.custom_color_data[data.npc_id].glow_color_name) then
                O.db.custom_color_data[data.npc_id].glow_color_name = DEFAULT_GLOW_COLOR_NAME;
            end

            frame.glow_color_name = O.db.custom_color_data[data.npc_id].glow_color_name;

            frame.color_enabled  = O.db.custom_color_data[data.npc_id].color_enabled;

            if not O.db.custom_color_data[data.npc_id].color_name or not Colors:Get(O.db.custom_color_data[data.npc_id].color_name) then
                O.db.custom_color_data[data.npc_id].color_name = DEFAULT_HB_COLOR_NAME;
            end

            frame.color_name = O.db.custom_color_data[data.npc_id].color_name;

            if O.db.custom_color_categories_data[data.category_name] then
                O.db.custom_color_data[data.npc_id].category_name = data.category_name;
            else
                O.db.custom_color_data[data.npc_id].category_name = CATEGORY_ALL_NAME;
            end

            frame.category_name = O.db.custom_color_data[data.npc_id].category_name;
            frame.category_list = panel:GetCategoriesDropdown();

            UpdateRow(frame);

            frame:SetShown(true);
        end
    end

    PixelUtil.SetSize(panel.CustomColorScrollArea.scrollChild, panel.CustomColorEditFrame:GetWidth(), panel.CustomColorEditFrame:GetHeight() - (panel.CustomColorEditFrame:GetHeight() % ROW_HEIGHT));
end

local DataListRows = {};

local function CreateListRow(b)
    b:SetBackdrop(BACKDROP);
    b.backgroundColor = b.backgroundColor or {};

    b.PlusSign = Mixin(b:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    b.PlusSign:SetPosition('RIGHT', b, 'RIGHT', -8, 0);
    b.PlusSign:SetSize(ROW_HEIGHT / 2, ROW_HEIGHT / 2);
    b.PlusSign:SetTexture(S.Media.Icons.TEXTURE);
    b.PlusSign:SetTexCoord(unpack(S.Media.Icons.COORDS.PLUS_SIGN_WHITE));
    b.PlusSign:SetShown(false);

    b.NameText = Mixin(b:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont'), E.PixelPerfectMixin);
    b.NameText:SetPosition('LEFT', b, 'LEFT', 8, 0);
    b.NameText:SetPosition('RIGHT', b.PlusSign, 'LEFT', -2, 0);
    b.NameText:SetH(ROW_HEIGHT / 2);

    b:SetScript('OnClick', function(self)
        Add(self.npc_id, self.npc_name);

        panel:UpdateScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    E.CreateTooltip(b, nil, nil, true);

    b:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
        self.PlusSign:SetShown(true);

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
        self.PlusSign:SetShown(false);

        if self.npc_name == UNKNOWN then
            self.npc_name = U.GetNpcNameByID(self.npc_id);
            self.tooltip = string.format(LIST_TOOLTIP_PATTERN, self.npc_name, self.npc_id);

            self.NameText:SetText(self.npc_name);
        end
    end);
end

local function UpdateListRow(b)
    if b.index == 1 then
        PixelUtil.SetPoint(b, 'TOPLEFT', panel.ListScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(b, 'TOPRIGHT', panel.ListScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
    else
        PixelUtil.SetPoint(b, 'TOPLEFT', DataListRows[b.index - 1], 'BOTTOMLEFT', 0, 0);
        PixelUtil.SetPoint(b, 'TOPRIGHT', DataListRows[b.index - 1], 'BOTTOMRIGHT', 0, 0);
    end

    b:SetSize(b:GetParent():GetWidth(), ROW_HEIGHT);

    if b.index % 2 == 0 then
        b:SetBackdropColor(0.15, 0.15, 0.15, 1);
        b.backgroundColor[1], b.backgroundColor[2], b.backgroundColor[3], b.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        b:SetBackdropColor(0.075, 0.075, 0.075, 1);
        b.backgroundColor[1], b.backgroundColor[2], b.backgroundColor[3], b.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    b.NameText:SetText(b.npc_name);
end

panel.UpdateListScroll = function(id)
    wipe(DataListRows);
    panel.ListButtonPool:ReleaseAll();

    local b, isNew;

    for index, npc_id in pairs(D.NPCs[id]) do
        b, isNew = panel.ListButtonPool:Acquire();

        table.insert(DataListRows, b);

        if isNew then
            CreateListRow(b);
        end

        b.index    = index;
        b.npc_id   = npc_id;
        b.npc_name = U.GetNpcNameByID(b.npc_id);
        b.tooltip  = string.format(LIST_TOOLTIP_PATTERN, b.npc_name, b.npc_id);

        UpdateListRow(b);

        b:SetShown(true);
    end

    PixelUtil.SetSize(panel.ListScrollArea.scrollChild, panel.ListScroll:GetWidth(), panel.ListScroll:GetHeight() - (panel.ListScroll:GetHeight() % ROW_HEIGHT));
end

panel.CategoriesDropdown = {};
panel.GetCategoriesDropdown = function(self)
    wipe(self.CategoriesDropdown);

    local index = 1;
    for name, _ in pairs(O.db.custom_color_categories_data) do
        self.CategoriesDropdown[index] = name;
        index = index + 1;
    end

    self.CategoriesDropdown[0] = CATEGORY_ALL_NAME;

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
        local name = self:GetParent().name;

        if not name or not O.db.custom_color_categories_data[name] then
            return self:SetShown(false);
        end

        local newName = strtrim(self:GetText());

        if not newName or newName == '' or string.lower(newName) == string.lower(CATEGORY_ALL_NAME) then
            return self:SetShown(false);
        end

        O.db.custom_color_categories_data[newName] = true;
        O.db.custom_color_categories_data[name] = nil;

        for id, _ in pairs(O.db.custom_color_data) do
            if O.db.custom_color_data[id].category_name == name then
                O.db.custom_color_data[id].category_name = newName;
            end
        end

        if panel.categoryName == name then
            panel.categoryName = newName;
        end

        panel:UpdateScroll();
        panel.UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown(), SortCategoryByName, true);
        if panel.CategoryDropdown:GetValue() == name then
            panel.CategoryDropdown:SetValue(newName);
        end

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
        O.db.custom_color_categories_data[self:GetParent().name] = nil;

        panel:UpdateScroll();
        panel.UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown(), SortCategoryByName, true);
        panel.CategoryDropdown:SetValue(CATEGORY_ALL_NAME);
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

local categorySortedData = {};
panel.UpdateCategoryListScroll = function()
    wipe(DataCategoryListRows);
    wipe(categorySortedData);

    for name, _ in pairs(O.db.custom_color_categories_data) do
        table.insert(categorySortedData, name);
    end

    table.sort(categorySortedData, function(a, b)
        return a < b;
    end);

    panel.CategoryListButtonPool:ReleaseAll();

    local frame, isNew;

    for index, name in ipairs(categorySortedData) do
        frame, isNew = panel.CategoryListButtonPool:Acquire();

        table.insert(DataCategoryListRows, frame);

        if isNew then
            panel.CreateCategoryListRow(frame);
        end

        frame.index = index;
        frame.name  = name;

        panel.UpdateCategoryListRow(frame);

        frame:SetShown(true);
    end

    PixelUtil.SetSize(panel.CategoryListScrollArea.scrollChild, panel.CategoryListScroll:GetWidth(), panel.CategoryListScroll:GetHeight() - (panel.CategoryListScroll:GetHeight() % ROW_HEIGHT));
end

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    self.custom_color_enabled = E.CreateCheckButton(self);
    self.custom_color_enabled:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.custom_color_enabled:SetLabel(L['OPTIONS_CUSTOM_COLOR_ENABLED']);
    self.custom_color_enabled:SetTooltip(L['OPTIONS_CUSTOM_COLOR_ENABLED_TOOLTIP']);
    self.custom_color_enabled:AddToSearch(button, L['OPTIONS_CUSTOM_COLOR_ENABLED_TOOLTIP']);
    self.custom_color_enabled:SetChecked(O.db.custom_color_enabled);
    self.custom_color_enabled.Callback = function(self)
        O.db.custom_color_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    local EditBox = E.CreateEditBox(self);
    EditBox:SetPosition('TOPLEFT', self.custom_color_enabled, 'BOTTOMLEFT', 5, -8);
    EditBox:SetSize(160, 22);
    EditBox.useLastValue = false;
    EditBox:SetInstruction(L['OPTIONS_CUSTOM_COLOR_EDITBOX_ENTER_ID']);
    EditBox:SetScript('OnEnterPressed', function(self)
        local unitID = tonumber(strtrim(self:GetText()));

        if type(unitID) ~= 'number' or unitID == 0 then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        local unitName = U.GetNpcNameByID(unitID);

        if not unitName then
            C_Timer.After(DELAY_SECONDS, function()
                unitName = U.GetNpcNameByID(unitID);
                Add(unitID, unitName);

                panel:UpdateScroll();
                self:SetText('');

                Stripes:UpdateAll();
            end);
        else
            Add(unitID, unitName);

            panel:UpdateScroll();
            self:SetText('');

            Stripes:UpdateAll();
        end
    end);

    local AddFromTargetButton = E.CreateButton(self);
    AddFromTargetButton:SetPosition('LEFT', EditBox, 'RIGHT', 12, 0);
    AddFromTargetButton:SetLabel(L['OPTIONS_CUSTOM_COLOR_ADD_FROM_TARGET']);
    AddFromTargetButton:SetScript('OnClick', function()
        if not UnitExists('target') or UnitIsPlayer('target') then
            return;
        end

        local unitID   = U.GetNpcID('target');
        local unitName = UnitName('target');

        if not unitID or unitID == 0 or not unitName then
            return;
        end

        unitID = tonumber(unitID);

        Add(unitID, unitName);

        panel:UpdateScroll();
        EditBox:SetText('');

        Stripes:UpdateAll();
    end);

    local AddFromList = E.CreateButton(self);
    AddFromList:SetPosition('LEFT', AddFromTargetButton, 'RIGHT', 8, 0);
    AddFromList:SetLabel(L['OPTIONS_CUSTOM_COLOR_ADD_FROM_LIST']);
    AddFromList:SetScript('OnClick', function(self)
        panel.List:SetShown(not panel.List:IsShown());

        if panel.List:IsShown() then
            self:LockHighlight();
        else
            self:UnlockHighlight();
        end

        Colors:HideListFrame();
        panel.CategoryList:SetShown(false);
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
            panel.ResetSearchEditBox:SetShown(false);
        end

        if panel.searchWordLower then
            panel.ResetSearchEditBox:SetShown(true);
        end

        panel:UpdateScroll();
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
        panel:UpdateScroll();

        self:SetShown(false);
    end);

    self.CategoryDropdown = E.CreateDropdown('plain', self);
    self.CategoryDropdown:SetPosition('LEFT', self.SearchEditBox, 'RIGHT', 11, 0);
    self.CategoryDropdown:SetSize(160, 22);
    self.CategoryDropdown:SetList(self:GetCategoriesDropdown(), SortCategoryByName, true);
    self.CategoryDropdown:SetValue(CATEGORY_ALL_NAME);
    self.CategoryDropdown.OnValueChangedCallback = function(_, _, value)
        panel.categoryName = value;
        panel:UpdateScroll();
    end

    self.OpenCategoryList = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.LIST_WHITE, { 1, 1, 1, 1 });
    self.OpenCategoryList:SetPosition('LEFT', self.CategoryDropdown, 'RIGHT', 12, 0);
    self.OpenCategoryList:SetSize(18, 18);
    self.OpenCategoryList:SetTooltip(L['OPTIONS_CATEGORY_OPEN_TOOLTIP']);
    self.OpenCategoryList.Callback = function()
        panel.CategoryList:SetShown(not panel.CategoryList:IsShown());

        Colors:HideListFrame();

        panel.List:SetShown(false);
        AddFromList:UnlockHighlight();
    end

    self.CustomColorEditFrame = CreateFrame('Frame', nil, self, 'BackdropTemplate');
    self.CustomColorEditFrame:SetPoint('TOPLEFT', self.SearchEditBox, 'BOTTOMLEFT', -5, -8);
    self.CustomColorEditFrame:SetPoint('BOTTOMRIGHT', O.frame.Right.CustomColor, 'BOTTOMRIGHT', 0, 0);
    self.CustomColorEditFrame:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CustomColorEditFrame:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.CustomColorScrollChild, self.CustomColorScrollArea = E.CreateScrollFrame(self.CustomColorEditFrame, ROW_HEIGHT);

    PixelUtil.SetPoint(self.CustomColorScrollArea.ScrollBar, 'TOPLEFT', self.CustomColorScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.CustomColorScrollArea.ScrollBar, 'BOTTOMLEFT', self.CustomColorScrollArea, 'BOTTOMRIGHT', -8, 0);

    framePool = CreateFramePool('Button', self.CustomColorScrollChild, 'BackdropTemplate');

    self.List = Mixin(CreateFrame('Frame', nil, self, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.List:SetPosition('TOPLEFT', O.frame, 'TOPRIGHT', 0, 0);
    self.List:SetPosition('BOTTOMLEFT', O.frame, 'BOTTOMRIGHT', 0, 0);
    self.List:SetWidth(250);
    self.List:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.List:SetBackdropColor(0.1, 0.1, 0.1, 1);
    self.List:SetShown(false);

    self.ListDropdown = E.CreateDropdown('plain', self.List);
    self.ListDropdown:SetPosition('TOP', self.List, 'TOP', 0, -10);
    self.ListDropdown:SetSize(228, 20);
    self.ListDropdown:SetList(O.Lists.custom_color_npcs);
    self.ListDropdown:SetValue(DEFAULT_LIST_VALUE);
    self.ListDropdown.OnValueChangedCallback = function(_, value)
        panel.UpdateListScroll(value);
        panel.ListScrollArea.ScrollBar:SetValue(0);
    end

    self.ListScroll = Mixin(CreateFrame('Frame', nil, self.List, 'BackdropTemplate'), E.PixelPerfectMixin);
    self.ListScroll:SetPoint('TOPLEFT', self.List , 'TOPLEFT', 6, -40);
    self.ListScroll:SetPoint('BOTTOMRIGHT', self.List, 'BOTTOMRIGHT', -6, 6);
    self.ListScroll:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.ListScroll:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.ListScrollChild, self.ListScrollArea = E.CreateScrollFrame(self.ListScroll, ROW_HEIGHT);

    PixelUtil.SetPoint(self.ListScrollArea.ScrollBar, 'TOPLEFT', self.ListScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.ListScrollArea.ScrollBar, 'BOTTOMLEFT', self.ListScrollArea, 'BOTTOMRIGHT', -8, 0);

    self.ListButtonPool = CreateFramePool('Button', self.ListScrollChild, 'BackdropTemplate');

    self.ProfilesDropdown = E.CreateDropdown('plain', self);
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.CustomColorEditFrame, 'TOPRIGHT', 0, 40);
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
            wipe(StripesDB.profiles[O.activeProfileId].custom_color_categories_data);
            wipe(StripesDB.profiles[O.activeProfileId].custom_color_data);

            StripesDB.profiles[O.activeProfileId].colors_data                  = U.DeepCopy(StripesDB.profiles[index].colors_data);
            StripesDB.profiles[O.activeProfileId].custom_color_categories_data = U.DeepCopy(StripesDB.profiles[index].custom_color_categories_data);
            StripesDB.profiles[O.activeProfileId].custom_color_data            = U.DeepCopy(StripesDB.profiles[index].custom_color_data);
        else
            -- Colors
            for n, c in pairs(StripesDB.profiles[index].colors_data) do
                StripesDB.profiles[O.activeProfileId].colors_data[n] = { c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1 };
            end

            -- Categories
            for n, _ in pairs(StripesDB.profiles[index].custom_color_categories_data) do
                StripesDB.profiles[O.activeProfileId].custom_color_categories_data[n] = true;
            end

            StripesDB.profiles[O.activeProfileId].custom_color_data = U.Merge(StripesDB.profiles[index].custom_color_data, StripesDB.profiles[O.activeProfileId].custom_color_data);
        end

        self:SetValue(nil);

        Colors:UpdateAllLists();
        Colors:UpdateListScroll();

        panel:UpdateCategoryListScroll();
        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown(), SortCategoryByName, true);

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
        Colors:ToggleListFrame();

        panel.List:SetShown(false);
        AddFromList:UnlockHighlight();

        panel.CategoryList:SetShown(false);
    end

    self.HelpTipButton = E.CreateHelpTipButton(self);
    self.HelpTipButton:SetPosition('TOPLEFT', self.ProfilesDropdown, 'BOTTOMLEFT', 2, -12);
    self.HelpTipButton:SetTooltip(L['OPTIONS_SHIFT_CLICK_TO_DELETE']);

    self.UpdateNamesButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE, { 1, 1, 1, 1 });
    self.UpdateNamesButton:SetPosition('LEFT', self.HelpTipButton, 'RIGHT', 24, 0);
    self.UpdateNamesButton:SetSize(18, 18);
    self.UpdateNamesButton:SetTooltip(L['OPTIONS_UPDATE_NPCS_NAMES_TOOLTIP']);
    self.UpdateNamesButton.Callback = function()
        local unitName;

        for npc_id, _ in pairs(O.db.custom_color_data) do
            unitName = U.GetNpcNameByID(npc_id);

            if not unitName then
                C_Timer.After(DELAY_SECONDS, function()
                    unitName = U.GetNpcNameByID(npc_id);
                    Add(npc_id, unitName);
                    panel:UpdateScroll();
                    Stripes:UpdateAll();
                end);
            else
                Add(npc_id, unitName);
            end
        end

        panel:UpdateScroll();
        Stripes:UpdateAll();
    end

    self.CategoryList = Mixin(CreateFrame('Frame', nil, self, 'BackdropTemplate'), E.PixelPerfectMixin);
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

        if not name or name == '' or string.lower(name) == string.lower(CATEGORY_ALL_NAME) then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        O.db.custom_color_categories_data[name] = true;

        self:SetText('');
        self:ClearFocus();

        panel:UpdateScroll();
        panel:UpdateCategoryListScroll();

        panel.CategoryDropdown:SetList(panel:GetCategoriesDropdown(), SortCategoryByName, true);
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

    Colors:AddScroll(self.UpdateScroll);
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');
    Profile.UpdateProfilesDropdown(self.ProfilesDropdown, true);
end

panel.OnShowOnce = function(self)
    self:UpdateScroll();
    self:UpdateCategoryListScroll();

    for i = 1, #O.Lists.custom_color_npcs do
        self.UpdateListScroll(i);
        self.UpdateListScroll(i);
    end

    self.UpdateListScroll(DEFAULT_LIST_VALUE);
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    Colors:UpdateAllLists();
    Colors:UpdateListScroll();

    self:UpdateCategoryListScroll();
    self.CategoryDropdown:SetList(self:GetCategoriesDropdown(), SortCategoryByName, true);
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end