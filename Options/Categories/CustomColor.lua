local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CustomColor');

O.frame.Left.CustomColor, O.frame.Right.CustomColor = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CUSTOMCOLOR']), 'customcolor', 7);
local button = O.frame.Left.CustomColor;
local panel = O.frame.Right.CustomColor;

local framePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local NAME_WIDTH = 300;
local DELAY_SECONDS = 0.2;

local DEFAULT_LIST_VALUE = 1;
local LIST_TOOLTIP_PATTERN = '|cffff6666%s|r  |cffffffff| |r |cffffb833%s|r';

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
            color    = { 0.45, 0, 1, 1 };
            glow_enabled = false,
            glow_type = 0,
        };
    end
end

local DataRows = {};

local function CreateRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.custom_color_data[self:GetParent().npc_id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.ColorPicker = E.CreateColorPicker(frame);
    frame.ColorPicker:SetPosition('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.ColorPicker.OnValueChanged = function(self, r, g, b, a)
        O.db.custom_color_data[self:GetParent().npc_id].color[1] = r;
        O.db.custom_color_data[self:GetParent().npc_id].color[2] = g;
        O.db.custom_color_data[self:GetParent().npc_id].color[3] = b;
        O.db.custom_color_data[self:GetParent().npc_id].color[4] = a or 1;

        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.ColorPicker:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.ColorPicker:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.IdText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.IdText:SetPoint('LEFT', frame.ColorPicker, 'RIGHT', 8, 0);
    frame.IdText:SetSize(60, ROW_HEIGHT);
    frame.IdText:SetTextColor(0.67, 0.67, 0.67);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.IdText, 'RIGHT', 4, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame.RemoveButton = Mixin(CreateFrame('Button', nil, frame), E.PixelPerfectMixin);
    frame.RemoveButton:SetPosition('RIGHT', frame, 'RIGHT', -16, 0);
    frame.RemoveButton:SetSize(14, 14);
    frame.RemoveButton:SetNormalTexture(S.Media.Icons.TEXTURE);
    frame.RemoveButton:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    frame.RemoveButton:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    frame.RemoveButton:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.TRASH_WHITE));
    frame.RemoveButton:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    frame.RemoveButton:SetScript('OnClick', function(self)
        if O.db.custom_color_data[tonumber(self:GetParent().npc_id)] then
            O.db.custom_color_data[tonumber(self:GetParent().npc_id)] = nil;

            panel.UpdateScroll();
            S:GetNameplateModule('Handler'):UpdateAll();
        end
    end);
    frame.RemoveButton:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.RemoveButton:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(self:GetParent().backgroundColor[1], self:GetParent().backgroundColor[2], self:GetParent().backgroundColor[3], self:GetParent().backgroundColor[4]);
    end);

    frame.GlowType = E.CreateDropdown('plain', frame);
    frame.GlowType:SetPosition('RIGHT', frame.RemoveButton, 'LEFT', -16, 0);
    frame.GlowType:SetSize(100, 20);
    frame.GlowType:SetList(O.Lists.glow_type_short_with_none);
    frame.GlowType:SetTooltip(L['GLOW']);
    frame.GlowType.OnValueChangedCallback = function(self, value)
        value = tonumber(value);

        O.db.custom_color_data[self:GetParent().npc_id].glow_enabled = value ~= 0;
        O.db.custom_color_data[self:GetParent().npc_id].glow_type = value;

        S:GetNameplateModule('Handler'):UpdateAll();
    end

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    E.CreateTooltip(frame, nil, nil, true);

    frame:HookScript('OnEnter', function(self)
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
    frame.IdText:SetText(frame.npc_id);
    frame.NameText:SetText(frame.name);
    frame.ColorPicker:SetValue(unpack(frame.color));
    frame.GlowType:SetValue(frame.glow_type);
    frame.GlowType:UpdateScrollArea();

    frame.tooltip = string.format(LIST_TOOLTIP_PATTERN, frame.name, frame.npc_id);
end

panel.UpdateScroll = function()
    wipe(DataRows);
    framePool:ReleaseAll();

    local index = 0;
    local frame, isNew;

    for npc_id, data in pairs(O.db.custom_color_data) do
        index = index + 1;

        frame, isNew = framePool:Acquire();

        table.insert(DataRows, frame);

        if isNew then
            CreateRow(frame);
        end

        frame.index        = index;
        frame.npc_id       = npc_id;
        frame.name         = data.npc_name;
        frame.enabled      = data.enabled;
        frame.color        = data.color;
        frame.glow_enabled = data.glow_type ~= 0;
        frame.glow_type    = data.glow_type or 0;

        UpdateRow(frame);

        frame:SetShown(true);
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
    end);

    self.CustomColorEditFrame = CreateFrame('Frame', nil, self, 'BackdropTemplate');
    self.CustomColorEditFrame:SetPoint('TOPLEFT', EditBox, 'BOTTOMLEFT', -5, -8);
    self.CustomColorEditFrame:SetPoint('BOTTOMRIGHT', O.frame.Right.CustomColor, 'BOTTOMRIGHT', 0, 0);
    self.CustomColorEditFrame:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CustomColorEditFrame:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.CustomColorScrollChild, self.CustomColorScrollArea = E.CreateScrollFrame(self.CustomColorEditFrame, ROW_HEIGHT);

    PixelUtil.SetPoint(self.CustomColorScrollArea.ScrollBar, 'TOPLEFT', self.CustomColorScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.CustomColorScrollArea.ScrollBar, 'BOTTOMLEFT', self.CustomColorScrollArea, 'BOTTOMRIGHT', -8, 0);

    framePool = CreateFramePool('Frame', self.CustomColorScrollChild, 'BackdropTemplate');

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
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.CustomColorEditFrame, 'TOPRIGHT', 0, 8);
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