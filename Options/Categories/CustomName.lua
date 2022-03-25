local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_CustomName');
local Profile = S:GetModule('Options_Categories_Profiles');

O.frame.Left.CustomName, O.frame.Right.CustomName = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_CUSTOMNAME']), 'customname', 8);
local button = O.frame.Left.CustomName;
local panel = O.frame.Right.CustomName;

local framePool;
local ROW_HEIGHT = 28;
local BACKDROP = { bgFile = 'Interface\\Buttons\\WHITE8x8' };
local NAME_WIDTH = 400;
local DELAY_SECONDS = 0.2;

local DEFAULT_LIST_VALUE = 1;
local LIST_TOOLTIP_PATTERN = '|cffff6666%s|r  |cffffffff| |r |cffffb833%s|r';

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

local function Add(id, name, new_name)
    if O.db.custom_name_data[id] then
        O.db.custom_name_data[id].npc_name = name;
    else
        O.db.custom_name_data[id] = {
            npc_id   = id,
            npc_name = name,
            new_name = new_name or name,
            enabled  = true,
        };
    end
end

local DataRows = {};

local function UpdateNewName(editbox, npcId, oldName, newName)
    newName = strtrim(newName);

    if not newName or newName == '' then
        return editbox:SetShown(false);
    end

    if not npcId or not O.db.custom_name_data[npcId] then
        return editbox:SetShown(false);
    end

    if oldName == newName then
        return editbox:SetShown(false);
    end

    O.db.custom_name_data[npcId].new_name = newName;

    panel:UpdateScroll();
    S:GetNameplateModule('Handler'):UpdateAll();

    editbox:SetShown(false);
end

local function CreateRow(frame)
    frame:SetBackdrop(BACKDROP);
    frame.backgroundColor = frame.backgroundColor or {};

    frame.EnableCheckBox = E.CreateCheckButton(frame);
    frame.EnableCheckBox:SetPosition('LEFT', frame, 'LEFT', 8, 0);
    frame.EnableCheckBox.Callback = function(self)
        O.db.custom_name_data[self:GetParent().npc_id].enabled = self:GetChecked();
        S:GetNameplateModule('Handler'):UpdateAll();
    end
    frame.EnableCheckBox:HookScript('OnEnter', function(self)
        self:GetParent():SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame.EnableCheckBox:HookScript('OnLeave', function(self)
        self:GetParent():SetBackdropColor(frame.backgroundColor[1], frame.backgroundColor[2], frame.backgroundColor[3], frame.backgroundColor[4]);
    end);

    frame.IdText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.IdText:SetPoint('LEFT', frame.EnableCheckBox, 'RIGHT', 8, 0);
    frame.IdText:SetSize(60, ROW_HEIGHT);
    frame.IdText:SetTextColor(0.67, 0.67, 0.67);

    frame.NameText = frame:CreateFontString(nil, 'ARTWORK', 'StripesOptionsNormalFont');
    frame.NameText:SetPoint('LEFT', frame.IdText, 'RIGHT', 4, 0);
    frame.NameText:SetSize(NAME_WIDTH, ROW_HEIGHT);

    frame.EditBox = E.CreateEditBox(frame);
    frame.EditBox:SetPosition('LEFT', frame.IdText, 'RIGHT', 4, 0);
    frame.EditBox:SetFrameLevel(frame.EditBox:GetFrameLevel() + 10);
    frame.EditBox:SetSize(NAME_WIDTH, ROW_HEIGHT);
    frame.EditBox:SetShown(false);
    frame.EditBox:SetScript('OnEnterPressed', function(self)
        UpdateNewName(self, self:GetParent().npc_id, self:GetParent().npc_name, self:GetText());
    end);
    frame.EditBox.FocusLostCallback = function(self)
        self:SetShown(false);
    end

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
        if O.db.custom_name_data[tonumber(self:GetParent().npc_id)] then
            O.db.custom_name_data[tonumber(self:GetParent().npc_id)] = nil;

            panel:UpdateScroll();
            S:GetNameplateModule('Handler'):UpdateAll();
        end
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
        self:GetParent().EditBox:SetText(self:GetParent().new_name);
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
        self.EditBox:SetText(self.new_name);
        self.EditBox:SetShown(true);
        self.EditBox:SetFocus();
        self.EditBox:SetCursorPosition(0);
    end);

    frame:SetScript('OnClick', function(self)
        if IsShiftKeyDown() then
            GameTooltip_Hide();

            if O.db.custom_name_data[tonumber(self.npc_id)] then
                O.db.custom_name_data[tonumber(self.npc_id)] = nil;

                panel:UpdateScroll();
                S:GetNameplateModule('Handler'):UpdateAll();
            end

            return;
        end
    end);

    frame:HookScript('OnEnter', function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1);
    end);

    frame:HookScript('OnLeave', function(self)
        self:SetBackdropColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4]);
    end);

    E.CreateTooltip(frame, nil, nil, true);

    frame:HookScript('OnEnter', function(self)
        if D.ModelBlacklist[self.npc_id] then
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
        PixelUtil.SetPoint(frame, 'TOPLEFT', panel.CustomNameScrollArea.scrollChild, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(frame, 'TOPRIGHT', panel.CustomNameScrollArea.scrollChild, 'TOPRIGHT', 0, 0);
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

    if frame.npc_name == frame.new_name then
        frame.NameText:SetText(frame.npc_name);
    else
        frame.NameText:SetText(frame.new_name .. ' |cffaaaaaa[' .. frame.npc_name .. ']|r');
    end

    frame.tooltip = string.format(LIST_TOOLTIP_PATTERN, frame.npc_name, frame.npc_id);
end

local sortedData = {};
panel.UpdateScroll = function()
    wipe(DataRows);
    wipe(sortedData);

    for _, data in pairs(O.db.custom_name_data) do
        table.insert(sortedData, data);
    end

    table.sort(sortedData, function(a, b)
        return a.new_name < b.new_name;
    end);

    framePool:ReleaseAll();

    local index = 0;
    local frame, isNew;
    local found;

    for _, data in ipairs(sortedData) do
        if panel.searchWordLower then
            found = string.find(string.lower(data.npc_name), panel.searchWordLower, 1, true);

            if not found then
                found = string.find(string.lower(data.new_name), panel.searchWordLower, 1, true);
            end

            if not found then
                found = string.find(data.npc_id, panel.searchWordLower, 1, true);
            end
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

            frame.index    = index;
            frame.npc_id   = data.npc_id;
            frame.npc_name = data.npc_name;
            frame.new_name = data.new_name;
            frame.enabled  = data.enabled;

            UpdateRow(frame);

            frame:SetShown(true);
        end
    end

    PixelUtil.SetSize(panel.CustomNameScrollArea.scrollChild, panel.CustomNameEditFrame:GetWidth(), panel.CustomNameEditFrame:GetHeight() - (panel.CustomNameEditFrame:GetHeight() % ROW_HEIGHT));
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

    E.CreateTooltip(b, nil, nil, true);
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

panel.Load = function(self)
    local Stripes = S:GetNameplateModule('Handler');

    self.custom_name_enabled = E.CreateCheckButton(self);
    self.custom_name_enabled:SetPosition('TOPLEFT', self, 'TOPLEFT', 0, 0);
    self.custom_name_enabled:SetLabel(L['OPTIONS_CUSTOM_NAME_ENABLED']);
    self.custom_name_enabled:SetTooltip(L['OPTIONS_CUSTOM_NAME_ENABLED_TOOLTIP']);
    self.custom_name_enabled:AddToSearch(button, L['OPTIONS_CUSTOM_NAME_ENABLED_TOOLTIP']);
    self.custom_name_enabled:SetChecked(O.db.custom_name_enabled);
    self.custom_name_enabled.Callback = function(self)
        O.db.custom_name_enabled = self:GetChecked();
        Stripes:UpdateAll();
    end

    local EditBox = E.CreateEditBox(self);
    EditBox:SetPosition('TOPLEFT', self.custom_name_enabled, 'BOTTOMLEFT', 5, -8);
    EditBox:SetSize(160, 22);
    EditBox.useLastValue = false;
    EditBox:SetInstruction(L['OPTIONS_CUSTOM_NAME_EDITBOX_ENTER_ID']);
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
    AddFromTargetButton:SetLabel(L['OPTIONS_CUSTOM_NAME_ADD_FROM_TARGET']);
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
    AddFromList:SetLabel(L['OPTIONS_CUSTOM_NAME_ADD_FROM_LIST']);
    AddFromList:SetScript('OnClick', function(self)
        panel.List:SetShown(not panel.List:IsShown());

        if panel.List:IsShown() then
            self:LockHighlight();
        else
            self:UnlockHighlight();
        end
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

    self.CustomNameEditFrame = CreateFrame('Frame', nil, self, 'BackdropTemplate');
    self.CustomNameEditFrame:SetPoint('TOPLEFT', self.SearchEditBox, 'BOTTOMLEFT', -5, -8);
    self.CustomNameEditFrame:SetPoint('BOTTOMRIGHT', O.frame.Right.CustomName, 'BOTTOMRIGHT', 0, 0);
    self.CustomNameEditFrame:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8' });
    self.CustomNameEditFrame:SetBackdropColor(0.15, 0.15, 0.15, 1);

    self.CustomNameScrollChild, self.CustomNameScrollArea = E.CreateScrollFrame(self.CustomNameEditFrame, ROW_HEIGHT);

    PixelUtil.SetPoint(self.CustomNameScrollArea.ScrollBar, 'TOPLEFT', self.CustomNameScrollArea, 'TOPRIGHT', -8, 0);
    PixelUtil.SetPoint(self.CustomNameScrollArea.ScrollBar, 'BOTTOMLEFT', self.CustomNameScrollArea, 'BOTTOMRIGHT', -8, 0);

    framePool = CreateFramePool('Button', self.CustomNameScrollChild, 'BackdropTemplate');

    self:UpdateScroll();

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
    self.ProfilesDropdown:SetPosition('BOTTOMRIGHT', self.CustomNameEditFrame, 'TOPRIGHT', 0, 40);
    self.ProfilesDropdown:SetSize(157, 22);
    self.ProfilesDropdown.OnValueChangedCallback = function(self, _, name, isShiftKeyDown)
        local index = S:GetModule('Options'):FindIndexByName(name);
        if not index then
            self:SetValue(nil);
            return;
        end

        if isShiftKeyDown then
            wipe(StripesDB.profiles[O.activeProfileId].custom_name_data);
            StripesDB.profiles[O.activeProfileId].custom_name_data = U.DeepCopy(StripesDB.profiles[index].custom_name_data);
        else
            StripesDB.profiles[O.activeProfileId].custom_name_data = U.Merge(StripesDB.profiles[index].custom_name_data, StripesDB.profiles[O.activeProfileId].custom_name_data);
        end

        self:SetValue(nil);

        panel:UpdateScroll();
    end

    self.CopyFromProfileText = E.CreateFontString(self);
    self.CopyFromProfileText:SetPosition('BOTTOMLEFT', self.ProfilesDropdown, 'TOPLEFT', 0, 0);
    self.CopyFromProfileText:SetText(L['OPTIONS_COPY_FROM_PROFILE']);

    self.HelpTipButton = E.CreateHelpTipButton(self);
    self.HelpTipButton:SetPosition('TOPLEFT', self.ProfilesDropdown, 'BOTTOMLEFT', 2, -12);
    self.HelpTipButton:SetTooltip(L['OPTIONS_SHIFT_CLICK_TO_DELETE']);

    self.UpdateNamesButton = E.CreateTextureButton(self, S.Media.Icons2.TEXTURE, S.Media.Icons2.COORDS.REFRESH_WHITE, { 1, 1, 1, 1 });
    self.UpdateNamesButton:SetPosition('LEFT', self.HelpTipButton, 'RIGHT', 24, 0);
    self.UpdateNamesButton:SetSize(18, 18);
    self.UpdateNamesButton:SetTooltip(L['OPTIONS_UPDATE_NPCS_NAMES_TOOLTIP']);
    self.UpdateNamesButton.Callback = function()
        local unitName;

        for npc_id, _ in pairs(O.db.custom_name_data) do
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
end

panel.OnShow = function(self)
    Module:RegisterEvent('MODIFIER_STATE_CHANGED');
    Profile.UpdateProfilesDropdown(self.ProfilesDropdown, true);
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