local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CustomColor');

O.frame.Left.CustomColor, O.frame.Right.CustomColor = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CUSTOMCOLOR']), 'customcolor', 7);
local button = O.frame.Left.CustomColor;
local panel = O.frame.Right.CustomColor;

local framePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local BACKDROP_BORDER_2 = { bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = 'Interface\\Buttons\\WHITE8x8', edgeSize = 2 };
local NAME_WIDTH = 420;
local CATEGORY_MAX_LETTERS = 10;
local DELAY_SECONDS = 0.25;

local DEFAULT_LIST_VALUE = 1;
local LIST_TOOLTIP_PATTERN = '|cffff6666%s|r  |cffffffff| |r |cffffb833%s|r';

panel.categoryId = 0;

local modelBlacklist = {
    [120651] = true,
};

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

local function Add(id, name)
    if O.db.custom_color_data[id] then
        O.db.custom_color_data[id].npc_name = name;
    else
        O.db.custom_color_data[id] = {
            npc_id   = id,
            npc_name = name,
            enabled  = true,
            color    = { 0.1, 0.1, 0.1, 1 },
            color_category = 0,
            color_enabled = false,
            glow_enabled = false,
            glow_type = 0,
            category_id = 0,
        };
    end
end

local DataRows = {};
local ExtendedOptionsFrames = {};

local function HideAllExtendedOptionsFrames()
    for _, frame in ipairs(ExtendedOptionsFrames) do
        if not frame:IsMouseOver() and not frame.ToggleExtendedOptions:IsMouseOver() then
            frame.ExtendedOptions:SetShown(false);
            frame.ToggleExtendedOptions:UnlockHighlight();
        end
    end
end

if UIDropDownMenu_HandleGlobalMouseEvent then
    local function ExtendedOptions_CloseNotActive()
        if not (O.frame and O.frame:IsShown()) then
            return;
        end

        for _, frame in ipairs(ExtendedOptionsFrames) do
            if frame.ExtendedOptions:IsShown() and not frame.ExtendedOptions:IsMouseOver() and not frame:IsMouseOver() and not frame.ToggleExtendedOptions:IsMouseOver() then
                frame.ExtendedOptions:SetShown(false);
                frame.ToggleExtendedOptions:UnlockHighlight();
            end
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

    frame.ExtendedOptions = CreateFrame('Frame', nil, panel, 'BackdropTemplate');
    frame.ExtendedOptions:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 0, 0);
    frame.ExtendedOptions:SetFrameLevel(100);
    frame.ExtendedOptions:SetSize(260, 220);
    frame.ExtendedOptions:SetBackdrop(BACKDROP_BORDER_2);
    frame.ExtendedOptions:SetShown(false);

    frame.ToggleExtendedOptions = E.CreateTextureButton(frame, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.GEAR_WHITE);
    frame.ToggleExtendedOptions:SetPosition('RIGHT', frame, 'RIGHT', -8, 0);
    frame.ToggleExtendedOptions:SetScript('OnClick', function(self)
        GameTooltip_Hide();

        HideAllExtendedOptionsFrames();

        if frame.ExtendedOptions:IsShown() then
            frame.ExtendedOptions:SetShown(false);
            self:UnlockHighlight();
        else
            frame.ExtendedOptions:SetShown(true);
            self:LockHighlight();
        end
    end);
    frame.ToggleExtendedOptions:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4]);
    end);
    frame.ToggleExtendedOptions:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame:SetScript('OnClick', function(self)
        GameTooltip_Hide();

        if IsShiftKeyDown() then
            self.RemoveButton:Click();
            return;
        end

        HideAllExtendedOptionsFrames();

        if self.ExtendedOptions:IsShown() then
            self.ExtendedOptions:SetShown(false);
            self.ToggleExtendedOptions:UnlockHighlight();
        else
            self.ExtendedOptions:SetShown(true);
            self.ToggleExtendedOptions:LockHighlight();
        end
    end);

    table.insert(ExtendedOptionsFrames, frame);

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
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.CategoryNameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.CategoryNameText:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.CategoryNameText:SetSize(60, ROW_HEIGHT);
    frame.CategoryNameText:SetTextColor(0.67, 0.67, 0.67);
    frame.CategoryNameText:SetJustifyH('RIGHT');

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.CategoryNameText, 'RIGHT', 8, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    -- Extended frame
    frame.ColorLineExtended = frame.ExtendedOptions:CreateTexture(nil, 'ARTWORK');
    frame.ColorLineExtended:SetPoint('TOPRIGHT', frame.ExtendedOptions, 'TOPLEFT', 0, 0);
    frame.ColorLineExtended:SetSize(4, ROW_HEIGHT);

    frame.NameExtendedText = frame.ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameExtendedText:SetPoint('TOPLEFT', frame.ExtendedOptions, 'TOPLEFT', 16, -10);
    frame.NameExtendedText:SetPoint('TOPRIGHT', frame.ExtendedOptions, 'TOPRIGHT', -8, 0);

    frame.ExtendedDelimiter = E.CreateDelimiter(frame.ExtendedOptions);
    frame.ExtendedDelimiter:SetPosition('TOPLEFT', frame.NameExtendedText, 'BOTTOMLEFT', -7, 0);
    frame.ExtendedDelimiter:SetW(frame.ExtendedOptions:GetWidth() - 16);

    frame.CategoryText = frame.ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
    frame.CategoryText:SetPoint('TOPLEFT', frame.ExtendedDelimiter, 'BOTTOMLEFT', 7, -2);
    frame.CategoryText:SetText(L['CATEGORY']);

    frame.Category = E.CreateDropdown('plain', frame.ExtendedOptions);
    frame.Category:SetPosition('TOPLEFT', frame.CategoryText, 'BOTTOMLEFT', 0, -4);
    frame.Category:SetSize(120, 20);
    frame.Category.OnValueChangedCallback = function(_, value)
        value = tonumber(value);

        if O.db.custom_color_data[frame.id] then
            O.db.custom_color_data[frame.id].category_id = value;
            panel:UpdateScroll();
        end
    end

    frame.ColorCategoryText = frame.ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
    frame.ColorCategoryText:SetPoint('TOPLEFT', frame.Category, 'BOTTOMLEFT', 0, -12);
    frame.ColorCategoryText:SetText(L['COLOR_CATEGORY']);

    frame.ColorCategory = E.CreateDropdown('plain', frame.ExtendedOptions);
    frame.ColorCategory:SetPosition('TOPLEFT', frame.ColorCategoryText, 'BOTTOMLEFT', 0, -4);
    frame.ColorCategory:SetSize(120, 20);
    frame.ColorCategory.OnValueChangedCallback = function(_, value)
        value = tonumber(value);

        O.db.custom_color_data[frame.npc_id].color_enabled  = value ~= 0;
        O.db.custom_color_data[frame.npc_id].color_category = value;

        if O.db.color_category_data[value] then
            O.db.custom_color_data[frame.npc_id].color[1] = O.db.color_category_data[value].color[1];
            O.db.custom_color_data[frame.npc_id].color[2] = O.db.color_category_data[value].color[2];
            O.db.custom_color_data[frame.npc_id].color[3] = O.db.color_category_data[value].color[3];
            O.db.custom_color_data[frame.npc_id].color[4] = O.db.color_category_data[value].color[4] or 1;
        else
            O.db.custom_color_data[frame.npc_id].color[1] = 0.1;
            O.db.custom_color_data[frame.npc_id].color[2] = 0.1;
            O.db.custom_color_data[frame.npc_id].color[3] = 0.1;
            O.db.custom_color_data[frame.npc_id].color[4] = 1;
        end

        panel:UpdateScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end

    frame.GlowTypeText = frame.ExtendedOptions:CreateFontString(nil, 'ARTWORK', 'StripesOptionsHighlightFont');
    frame.GlowTypeText:SetPoint('TOPLEFT', frame.ColorCategory, 'BOTTOMLEFT', 0, -12);
    frame.GlowTypeText:SetText(L['GLOW_TYPE']);

    frame.GlowType = E.CreateDropdown('plain', frame.ExtendedOptions);
    frame.GlowType:SetPosition('TOPLEFT', frame.GlowTypeText, 'BOTTOMLEFT', 0, -4);
    frame.GlowType:SetSize(120, 20);
    frame.GlowType:SetList(O.Lists.glow_type_short_with_none);
    frame.GlowType.OnValueChangedCallback = function(_, value)
        value = tonumber(value);

        O.db.custom_color_data[frame.npc_id].glow_enabled = value ~= 0;
        O.db.custom_color_data[frame.npc_id].glow_type = value;

        panel:UpdateScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end

    frame.RemoveButton = E.CreateTextureButton(frame.ExtendedOptions, S.Media.Icons.TEXTURE, S.Media.Icons.COORDS.TRASH_WHITE, { 1, 0.2, 0.2, 1});
    frame.RemoveButton:SetPosition('BOTTOMRIGHT', frame.ExtendedOptions, 'BOTTOMRIGHT', -6, 8);
    frame.RemoveButton:SetSize(16, 16);
    frame.RemoveButton:SetScript('OnClick', function(_)
        if O.db.custom_color_data[frame.npc_id] then
            O.db.custom_color_data[frame.npc_id] = nil;

            frame.ExtendedOptions:SetShown(false);
            frame.ToggleExtendedOptions:UnlockHighlight();

            panel:UpdateScroll();
            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);

    E.CreateTooltip(frame, nil, nil, true);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(self.highlightColor[1], self.highlightColor[2], self.highlightColor[3], self.highlightColor[4]);

        self.NameText:SetText(self.name .. '    |cffaaaaaa' .. self.npc_id .. ' | ' .. self.list[self.color_category] .. ' | ' .. O.Lists.glow_type_short_with_none[self.glow_type] .. '|r');

        if frame.ExtendedOptions:IsShown() then
            GameTooltip_Hide();
        else
            if not modelBlacklist[self.npc_id] then
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
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);

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
        frame.ExtendedOptions:SetBackdropColor(0.15, 0.15, 0.15, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.15, 0.15, 0.15, 1;
    else
        frame:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.ExtendedOptions:SetBackdropColor(0.075, 0.075, 0.075, 1);
        frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4] = 0.075, 0.075, 0.075, 1;
    end

    frame.EnableCheckBox:SetChecked(frame.enabled);
    frame.CategoryNameText:SetText(frame.category_list[frame.category_id]);
    frame.NameText:SetText(frame.name);
    frame.ColorCategory:SetList(frame.list);
    frame.ColorCategory:SetValue(frame.color_category);
    frame.GlowType:SetValue(frame.glow_type);
    frame.GlowType:UpdateScrollArea();
    frame.Category:SetList(frame.category_list);
    frame.Category:SetValue(frame.category_id);

    frame.NameExtendedText:SetText(frame.name .. '  |cffaaaaaa[' .. frame.npc_id .. ']|r');
    frame.ColorLine:SetColorTexture(unpack(frame.color));
    frame.ColorLineExtended:SetColorTexture(unpack(frame.color));
    frame.highlightColor[1], frame.highlightColor[2], frame.highlightColor[3], frame.highlightColor[4] = frame.color[1], frame.color[2], frame.color[3], 0.5;
    frame.ExtendedOptions:SetBackdropBorderColor(frame.color[1], frame.color[2], frame.color[3], frame.color[4]);

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
        elseif panel.categoryId then
            found = (panel.categoryId == 0 or (panel.categoryId == 0 and not data.category_id) or data.category_id == panel.categoryId);
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
            frame.color        = data.color;
            frame.glow_enabled = data.glow_type ~= 0;
            frame.glow_type    = data.glow_type or 0;

            if O.db.color_category_data[data.color_category] then
                O.db.custom_color_data[data.npc_id].color_enabled  = true;
                O.db.custom_color_data[data.npc_id].color_category = data.color_category;

                O.db.custom_color_data[data.npc_id].color[1] = O.db.color_category_data[data.color_category].color[1];
                O.db.custom_color_data[data.npc_id].color[2] = O.db.color_category_data[data.color_category].color[2];
                O.db.custom_color_data[data.npc_id].color[3] = O.db.color_category_data[data.color_category].color[3];
                O.db.custom_color_data[data.npc_id].color[4] = O.db.color_category_data[data.color_category].color[4] or 1;
            else
                O.db.custom_color_data[data.npc_id].color_enabled  = false;
                O.db.custom_color_data[data.npc_id].color_category = 0;

                O.db.custom_color_data[data.npc_id].color[1] = 0.1;
                O.db.custom_color_data[data.npc_id].color[2] = 0.1;
                O.db.custom_color_data[data.npc_id].color[3] = 0.1;
                O.db.custom_color_data[data.npc_id].color[4] = 1;
            end

            frame.color_enabled  = O.db.custom_color_data[data.npc_id].color_enabled;
            frame.color_category = O.db.custom_color_data[data.npc_id].color_category;
            frame.color = O.db.custom_color_data[data.npc_id].color;
            frame.list  = S:GetModule('Options_ColorCategory'):GetDropdownList();

            if O.db.custom_color_category_data[data.category_id] then
                O.db.custom_color_data[data.npc_id].category_id = data.category_id;
            else
                O.db.custom_color_data[data.npc_id].category_id = 0;
            end

            frame.category_id   = O.db.custom_color_data[data.npc_id].category_id;
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
        Add(self.npc_id, self.name);

        panel.UpdateScroll();
        S:GetNameplateModule('Handler'):UpdateAll();
    end);

    b:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
        self.PlusSign:SetShown(true);

        if self.name == UNKNOWN then
            self.name = U.GetNpcNameByID(self.npc_id);
            self.tooltip = string.format(LIST_TOOLTIP_PATTERN, self.name, self.npc_id);

            self.NameText:SetText(self.name);
        end
    end);

    b:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
        self.PlusSign:SetShown(false);

        if self.name == UNKNOWN then
            self.name = U.GetNpcNameByID(self.npc_id);
            self.tooltip = string.format(LIST_TOOLTIP_PATTERN, self.name, self.npc_id);

            self.NameText:SetText(self.name);
        end
    end);

    E.CreateTooltip(b, nil, nil, true);

    b:HookScript('OnEnter', function(self)
        if self.name == UNKNOWN then
            return;
        end

        if modelBlacklist[self.npc_id] then
            return;
        end

        ModelFrame:SetCreature(self.npc_id);
        GameTooltip_InsertFrame(GameTooltip, HolderModelFrame, 0);
        HolderModelFrame:SetSize(GameTooltip:GetWidth(), GameTooltip:GetWidth() * 2);
        HolderModelFrame:SetPoint('TOPLEFT', GameTooltip, 'BOTTOMLEFT', 0, -1);
        ModelFrame:SetSize(GameTooltip:GetWidth() - 3, GameTooltip:GetWidth() * 2 - 3);
        ModelFrame:SetCamDistanceScale(1.2);
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

    b.name = U.GetNpcNameByID(b.npc_id);
    b.tooltip = string.format(LIST_TOOLTIP_PATTERN, b.name, b.npc_id);

    b.NameText:SetText(b.name);
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

        b.index   = index;
        b.npc_id  = npc_id;

        UpdateListRow(b);

        b:SetShown(true);
    end

    PixelUtil.SetSize(panel.ListScrollArea.scrollChild, panel.ListScroll:GetWidth(), panel.ListScroll:GetHeight() - (panel.ListScroll:GetHeight() % ROW_HEIGHT));
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

panel.CategoriesDropdown = {};
panel.GetCategoriesDropdown = function(self)
    wipe(self.CategoriesDropdown);

    for index, data in ipairs(O.db.custom_color_category_data) do
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

        if not index or not O.db.custom_color_category_data[index] then
            return self:SetShown(false);
        end

        if O.db.custom_color_category_data[index].name == newName then
            return self:SetShown(false);
        end

        for _, data in ipairs(O.db.custom_color_category_data) do
            if data.name == newName then
                return self:SetShown(false);
            end
        end

        O.db.custom_color_category_data[index].name = newName;

        panel.UpdateScroll();
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
        table.remove(O.db.custom_color_category_data, self:GetParent().index);

        panel.UpdateScroll();
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

    for index, data in ipairs(O.db.custom_color_category_data) do
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

        U.GetNpcNameByID(unitID);

        C_Timer.After(DELAY_SECONDS, function()
            local unitName = U.GetNpcNameByID(unitID);
            Add(unitID, unitName);

            panel.UpdateScroll();
            self:SetText('');

            Stripes:UpdateAll();
        end);
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

        panel.UpdateScroll();
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

        S:GetModule('Options_ColorCategory'):HideListFrame();
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

        panel.UpdateScroll();
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
        panel.UpdateScroll();

        self:SetShown(false);
    end);

    self.CategoryDropdown = E.CreateDropdown('plain', self);
    self.CategoryDropdown:SetPosition('LEFT', self.SearchEditBox, 'RIGHT', 11, 0);
    self.CategoryDropdown:SetSize(160, 22);
    self.CategoryDropdown:SetList(self:GetCategoriesDropdown());
    self.CategoryDropdown:SetValue(0);
    self.CategoryDropdown.OnValueChangedCallback = function(_, value)
        panel.categoryId = tonumber(value);
        panel.UpdateScroll();
    end

    self.OpenCategoryList = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.LIST_WHITE, { 1, 1, 1, 1 });
    self.OpenCategoryList:SetPosition('LEFT', self.CategoryDropdown, 'RIGHT', 12, 0);
    self.OpenCategoryList:SetSize(18, 18);
    self.OpenCategoryList:SetTooltip(L['OPTIONS_CATEGORY_OPEN_TOOLTIP']);
    self.OpenCategoryList.Callback = function()
        panel.CategoryList:SetShown(not panel.CategoryList:IsShown());

        S:GetModule('Options_ColorCategory'):HideListFrame();

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

    self.UpdateScroll();

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
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);
        if not index then
            self:SetValue(nil);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].custom_color_data);
            StripesDB.profiles[O.activeProfileId].custom_color_data = U.DeepCopy(StripesDB.profiles[index].custom_color_data);
        else
            StripesDB.profiles[O.activeProfileId].custom_color_data = U.Merge(StripesDB.profiles[index].custom_color_data, StripesDB.profiles[O.activeProfileId].custom_color_data);
        end

        self:SetValue(nil);

        panel.UpdateScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);

    self.ColorCategoryToggleButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.PALETTE_COLOR, { 1, 1, 1, 1 }, { 1, 1, 0.5, 1 });
    self.ColorCategoryToggleButton:SetPosition('TOPRIGHT', self.ProfilesDropdown, 'BOTTOMRIGHT', -2, -12);
    self.ColorCategoryToggleButton:SetTooltip(L['OPTIONS_COLOR_CATEGORY_TOGGLE_FRAME']);
    self.ColorCategoryToggleButton:SetSize(19, 18);
    self.ColorCategoryToggleButton.Callback = function()
        S:GetModule('Options_ColorCategory'):ToggleListFrame();

        panel.List:SetShown(false);
        AddFromList:UnlockHighlight();

        panel.CategoryList:SetShown(false);
    end

    self.HelpTipButton = E.CreateHelpTipButton(self);
    self.HelpTipButton:SetPosition('TOPLEFT', self.ProfilesDropdown, 'BOTTOMLEFT', 2, -12);
    self.HelpTipButton:SetTooltip(L['OPTIONS_SHIFT_CLICK_TO_DELETE']);

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

        if not name or name == ''  then
            self:SetText('');
            self:ClearFocus();
            return;
        end

        table.insert(O.db.custom_color_category_data, { name = name });

        self:SetText('');
        self:ClearFocus();

        panel.UpdateScroll();
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

    self.UpdateCategoryListScroll();
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');

    self:UpdateProfilesDropdown();
end

panel.OnShowOnce = function(self)
    for i = 1, #O.Lists.custom_color_npcs do
        self.UpdateListScroll(i);
        self.UpdateListScroll(i);
    end

    self.UpdateListScroll(DEFAULT_LIST_VALUE);
    self.UpdateCategoryListScroll();
end

panel.OnHide = function()
    Module:UnregisterEvent('MODIFIER_STATE_CHANGED');
end

panel.Update = function(self)
    self:UpdateScroll();
end

function Module:MODIFIER_STATE_CHANGED(key, down)
    if down == 1 and (key == 'LSHIFT' or key == 'RSHIFT') then
        panel.CopyFromProfileText:SetText(L['OPTIONS_REPLACE_FROM_PROFILE']);
    else
        panel.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);
    end
end