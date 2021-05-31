local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Profiles');
local Options = S:GetModule('Options');

O.frame.Left.Profiles, O.frame.Right.Profiles = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_PROFILES']), 'profiles', 19);
local panel = O.frame.Right.Profiles;

local LibSerialize = S.Libraries.LibSerialize;
local LibDeflate   = S.Libraries.LibDeflate;
local DEFLATE_CONFIG = { level = 6 };
local ENCODE_PREFIX = '!S:1!';
local PROFILE_DEFAULT_ID = '1';

local MAX_LETTERS = 42;

StaticPopupDialogs['STRIPES_RESET_PROFILE_TO_DEFAULT'] = {
	text    = L['OPTIONS_PROFILES_RESET_PROFILE_TO_DEFAULT_PROMPT'],
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function()
        if not StripesDB.profiles[O.activeProfileId] then
            return;
        end

        wipe(StripesDB.profiles[O.activeProfileId]);
        StripesDB.profiles[O.activeProfileId] = U.DeepCopy(O.DefaultValues);
        StripesDB.profiles[O.activeProfileId].profileName = O.activeProfileName;

        O.db = StripesDB.profiles[O.activeProfileId];

        O.UpdatePanelAll();
        S:GetNameplateModule('Handler'):CVarsReset();
        S:GetNameplateModule('Handler'):UpdateAll();
	end,
    hideOnEscape = true,
	whileDead = 1,
	preferredIndex = STATICPOPUPS_NUMDIALOGS,
};

local profilesList = {};
local removeProfilesList = {};
local choosen;

local function UpdateRemoveProfilesDropdown()
    wipe(removeProfilesList);

    for id, data in pairs(StripesDB.profiles) do
        if id ~= PROFILE_DEFAULT_ID then
            table.insert(removeProfilesList, data.profileName);
        end
    end

    table.sort(removeProfilesList, function(a, b)
        return a < b;
    end);

    panel.RemoveProfilesDropdown:SetEnabled(#removeProfilesList > 0);
    panel.RemoveProfilesDropdown:SetList(removeProfilesList);
    panel.RemoveProfilesDropdown:SetValue(0);
end

local function UpdateProfilesDropdown()
    wipe(profilesList);

    for _, data in pairs(StripesDB.profiles) do
        table.insert(profilesList, data.profileName);
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

    choosen = nil;
    for i, name in ipairs(profilesList) do
        if name == O.activeProfileName then
            choosen = i;
            break;
        end
    end

    panel.ProfilesDropdown:SetEnabled(#profilesList > 1);
    panel.ProfilesDropdown:SetList(profilesList);
    panel.ProfilesDropdown:SetValue(choosen);
end

local function UpdateElementsVisibility()
    panel.EditActiveProfileName:SetShown(true);

    panel.EditNameEditBox:SetShown(false);
    panel.EditNameEditBox:ClearFocus();

    panel.ActiveProfileValue:SetShown(true);
    panel.ActiveProfileValue:SetText(O.activeProfileName);

    panel.SaveProfileName:SetShown(false);
end

local function EditActiveProfileName(profileId, newProfileName)
    newProfileName = strtrim(newProfileName);
    if not newProfileName or newProfileName == '' then
        return UpdateElementsVisibility();
    end

    if not StripesDB.profiles[profileId] then
        return UpdateElementsVisibility();
    end

    if StripesDB.profiles[profileId].profileName == newProfileName then
        return UpdateElementsVisibility();
    end

    newProfileName = Options:IsNameExists(newProfileName) and string.format('%s-%s', newProfileName, date('%Y%m%d%H%M%S')) or newProfileName;

    StripesDB.profiles[profileId].profileName = newProfileName;

    O.activeProfileName = newProfileName;

    UpdateProfilesDropdown();
    UpdateRemoveProfilesDropdown();

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);

    UpdateElementsVisibility();
end

local function CopyFromActive(name)
    name = strtrim(name);
    if not name or name == '' then
        return;
    end

    local index = Options:GetNewIndex();

    StripesDB.profiles[index] = {};
    StripesDB.profiles[index] = U.Merge(O.db, StripesDB.profiles[index]);
    StripesDB.profiles[index].profileName = Options:IsNameExists(name) and string.format('%s-%s', name, date('%Y%m%d%H%M%S')) or name;

    O.db = StripesDB.profiles[index];
    O.activeProfileId   = index;
    O.activeProfileName = StripesDB.profiles[index].profileName;

    StripesDB.characters[D.Player.NameWithRealm].profileId = index;

    UpdateProfilesDropdown();
    UpdateRemoveProfilesDropdown();

    panel.CreateNewProfileEditBox:SetText('');
    panel.ActiveProfileValue:SetText(O.activeProfileName);
    panel.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);
end

local function CreateDefaultProfile(name)
    name = strtrim(name);
    if not name or name == '' then
        return;
    end

    local index = Options:GetNewIndex();

    StripesDB.profiles[index] = {};
    StripesDB.profiles[index] = U.DeepCopy(O.DefaultValues);
    StripesDB.profiles[index].profileName = Options:IsNameExists(name) and string.format('%s-%s', name, date('%Y%m%d%H%M%S')) or name;

    O.db = StripesDB.profiles[index];
    O.activeProfileId   = index;
    O.activeProfileName = StripesDB.profiles[index].profileName;

    StripesDB.characters[D.Player.NameWithRealm].profileId = index;

    UpdateProfilesDropdown();
    UpdateRemoveProfilesDropdown();

    panel.CreateNewProfileEditBox:SetText('');
    panel.ActiveProfileValue:SetText(O.activeProfileName);
    panel.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);

    O.UpdatePanelAll();
    S:GetNameplateModule('Handler'):CVarsUpdate();
    S:GetNameplateModule('Handler'):UpdateAll();

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);
end

local function ImportProfile(name, data)
    local index = Options:GetNewIndex();

    StripesDB.profiles[index] = {};
    StripesDB.profiles[index] = U.Merge(O.db, data);
    StripesDB.profiles[index].profileName = Options:IsNameExists(name) and string.format('%s-%s', name, date('%Y%m%d%H%M%S')) or name;

    O.db = StripesDB.profiles[index];
    O.activeProfileId   = index;
    O.activeProfileName = StripesDB.profiles[index].profileName;

    StripesDB.characters[D.Player.NameWithRealm].profileId = index;

    UpdateProfilesDropdown();
    UpdateRemoveProfilesDropdown();

    panel.CreateNewProfileEditBox:SetText('');
    panel.ActiveProfileValue:SetText(O.activeProfileName);
    panel.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);

    O.UpdatePanelAll();
    S:GetNameplateModule('Handler'):CVarsUpdate();
    S:GetNameplateModule('Handler'):UpdateAll();

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);
end

local function ChooseProfileByName(name)
    if not name then
        return false;
    end

    local index = Options:FindIndexByName(name);

    if not index then
        return false;
    end

    if not StripesDB.profiles[index] then
        return false;
    end

    O.db = StripesDB.profiles[index];
    O.activeProfileId   = index;
    O.activeProfileName = StripesDB.profiles[index].profileName;

    StripesDB.characters[D.Player.NameWithRealm].profileId = index;

    UpdateProfilesDropdown();
    panel.ActiveProfileValue:SetText(O.activeProfileName);
    panel.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);

    O.UpdatePanelAll();
    S:GetNameplateModule('Handler'):CVarsUpdate();
    S:GetNameplateModule('Handler'):UpdateAll();

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);
end

local function RemoveProfileByName(name)
    if not name then
        return false;
    end

    local index = Options:FindIndexByName(name);

    if not index then
        return false;
    end

    if not StripesDB.profiles[index] then
        return false;
    end

    StripesDB.profiles[index] = nil;

    for character, data in pairs(StripesDB.characters) do
        if data.profileId == index then
            StripesDB.characters[character].profileId = PROFILE_DEFAULT_ID;
        end
    end

    if O.activeProfileId == index then
        O.db = StripesDB.profiles[PROFILE_DEFAULT_ID];
        O.activeProfileId   = PROFILE_DEFAULT_ID;
        O.activeProfileName = StripesDB.profiles[PROFILE_DEFAULT_ID].profileName;

        O.UpdatePanelAll();
        S:GetNameplateModule('Handler'):CVarsUpdate();
        S:GetNameplateModule('Handler'):UpdateAll();
    end

    UpdateProfilesDropdown();
    UpdateRemoveProfilesDropdown();

    panel.ActiveProfileValue:SetText(O.activeProfileName);
    panel.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);

    O.frame.TopBar.CurrentProfileName:SetText(O.activeProfileName);

    return true;
end

panel.ImportExportFrame = Mixin(CreateFrame('Frame', nil, panel, 'BackdropTemplate'), E.PixelPerfectMixin);
panel.ImportExportFrame:SetPosition('TOPLEFT', panel, 'TOPLEFT', 0, 0);
panel.ImportExportFrame:SetPosition('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 0, 0);
panel.ImportExportFrame:SetFrameStrata('DIALOG');
panel.ImportExportFrame:SetFrameLevel(O.frame:GetFrameLevel() + 20);
panel.ImportExportFrame:EnableMouse(true);
panel.ImportExportFrame:SetBackdrop({ bgFile = 'Interface\\ChatFrame\\ChatFrameBackground' });
panel.ImportExportFrame:SetBackdropColor(0.1, 0.1, 0.1, 1);
panel.ImportExportFrame:SetShown(false);

panel.ImportExportFrame.editBox = CreateFrame('EditBox', nil, panel.ImportExportFrame);
panel.ImportExportFrame.editBox:SetFrameLevel(panel.ImportExportFrame:GetFrameLevel() + 20);
panel.ImportExportFrame.editBox:SetTextInsets(4, 4, 4, 4);
panel.ImportExportFrame.editBox:SetMultiLine(true);
panel.ImportExportFrame.editBox:SetMaxLetters(99999);
panel.ImportExportFrame.editBox:EnableMouse(true);
panel.ImportExportFrame.editBox:SetAutoFocus(true);
panel.ImportExportFrame.editBox:SetFontObject(ChatFontNormal);
panel.ImportExportFrame.editBox:SetSize(620, 496);
panel.ImportExportFrame.editBox:SetScript('OnEscapePressed', function(f) f:GetParent():GetParent():Hide(); f:SetText(''); end);

local scrollChild, scrollArea = E.CreateScrollFrame(panel.ImportExportFrame, 20, panel.ImportExportFrame.editBox);
scrollArea:SetPoint('TOPLEFT', panel.ImportExportFrame, 'TOPLEFT', 0, 0);
scrollArea:SetPoint('BOTTOMRIGHT', panel.ImportExportFrame, 'BOTTOMRIGHT', 0, 30);
PixelUtil.SetSize(scrollChild, scrollArea:GetWidth(), scrollArea:GetHeight());

panel.ImportExportFrame.okButton = E.CreateButton(panel.ImportExportFrame);
panel.ImportExportFrame.okButton:SetPosition('BOTTOMLEFT', panel.ImportExportFrame, 'BOTTOMLEFT', 0, 4);

panel.ImportExportFrame.CloseButton = E.CreateButton(panel.ImportExportFrame);
panel.ImportExportFrame.CloseButton:SetPosition('BOTTOMRIGHT', panel.ImportExportFrame, 'BOTTOMRIGHT', 0, 4);
panel.ImportExportFrame.CloseButton:SetLabel(L['OPTIONS_CLOSE']);
panel.ImportExportFrame.CloseButton:SetShown(false);
panel.ImportExportFrame.CloseButton:SetScript('OnClick', function()
    panel.ImportExportFrame.editBox:SetText('');
    panel.ImportExportFrame:SetShown(false);
end);

panel.Load = function(self)
    self.ActiveProfile = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesMediumNormalSemiBoldFont'), E.PixelPerfectMixin);
    self.ActiveProfile:SetPosition('TOPLEFT', self, 'TOPLEFT', 12, -12);
    self.ActiveProfile:SetJustifyH('LEFT');
    self.ActiveProfile:SetTextColor(0.85, 0.85, 0.85);
    self.ActiveProfile:SetText(L['OPTIONS_PROFILES_ACTIVE_PROFILE']);

    self.ActiveProfileValue = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesMediumNormalSemiBoldFont'), E.PixelPerfectMixin);
    self.ActiveProfileValue:SetPosition('LEFT', self.ActiveProfile, 'RIGHT', 6, 0);
    self.ActiveProfileValue:SetJustifyH('LEFT');
    self.ActiveProfileValue:SetTextColor(1, 1, 1);
    self.ActiveProfileValue:SetText(O.activeProfileName);

    self.EditNameEditBox = E.CreateEditBox(self);
    self.EditNameEditBox:SetPosition('TOPLEFT', self.ActiveProfileValue, 'TOPLEFT', 0, self.ActiveProfileValue:GetLineHeight() / 2);
    self.EditNameEditBox:SetPosition('BOTTOMRIGHT', self.ActiveProfileValue, 'BOTTOMRIGHT', 6, -(self.ActiveProfileValue:GetLineHeight() / 2));
    self.EditNameEditBox:SetFont(self.ActiveProfileValue:GetFont());
    self.EditNameEditBox:SetText(O.activeProfileName);
    self.EditNameEditBox:SetMaxLetters(MAX_LETTERS);
    self.EditNameEditBox:SetShown(false);
    self.EditNameEditBox.useLastValue = false;
    self.EditNameEditBox.profileId = O.activeProfileId;
    self.EditNameEditBox.Callback = function(self)
        EditActiveProfileName(self.profileId, self:GetText());
    end

    self.EditNameEditBox:SetTextInsets(0, 0, 0, 0);

    self.EditNameEditBox.FocusLostCallback = function()
        if panel.SaveProfileName:IsMouseOver() then
            return;
        end

        UpdateElementsVisibility();
    end

    self.EditActiveProfileName = Mixin(CreateFrame('Button', nil, self), E.PixelPerfectMixin);
    self.EditActiveProfileName:SetPosition('LEFT', self.EditNameEditBox, 'RIGHT', 12, 0);
    self.EditActiveProfileName:SetSize(13, 13);
    self.EditActiveProfileName:SetNormalTexture(S.Media.Icons.TEXTURE);
    self.EditActiveProfileName:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.PENCIL_WHITE));
    self.EditActiveProfileName:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    self.EditActiveProfileName:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    self.EditActiveProfileName:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.PENCIL_WHITE));
    self.EditActiveProfileName:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    E.CreateTooltip(self.EditActiveProfileName, L['RENAME']);
    self.EditActiveProfileName:SetShown(O.activeProfileId ~= PROFILE_DEFAULT_ID);
    self.EditActiveProfileName:SetScript('OnClick', function()
        panel.EditActiveProfileName:SetShown(false);

        panel.ActiveProfileValue:SetShown(false);
        panel.SaveProfileName:SetShown(true);

        panel.EditNameEditBox:SetText(O.activeProfileName);
        panel.EditNameEditBox.profileId = O.activeProfileId;
        panel.EditNameEditBox:SetShown(true);
        panel.EditNameEditBox:SetFocus();
        panel.EditNameEditBox:SetCursorPosition(0);
    end);

    self.SaveProfileName = Mixin(CreateFrame('Button', nil, self), E.PixelPerfectMixin);
    self.SaveProfileName:SetPosition('LEFT', self.EditNameEditBox, 'RIGHT', 12, 0);
    self.SaveProfileName:SetSize(16, 16);
    self.SaveProfileName:SetNormalTexture(S.Media.Icons.TEXTURE);
    self.SaveProfileName:GetNormalTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKMARK_WHITE));
    self.SaveProfileName:GetNormalTexture():SetVertexColor(0.7, 0.7, 0.7, 1);
    self.SaveProfileName:SetHighlightTexture(S.Media.Icons.TEXTURE, 'BLEND');
    self.SaveProfileName:GetHighlightTexture():SetTexCoord(unpack(S.Media.Icons.COORDS.CHECKMARK_WHITE));
    self.SaveProfileName:GetHighlightTexture():SetVertexColor(1, 0.85, 0, 1);
    self.SaveProfileName:SetShown(false);
    E.CreateTooltip(self.SaveProfileName, L['SAVE']);
    self.SaveProfileName:SetScript('OnClick', function()
        EditActiveProfileName(panel.EditNameEditBox.profileId, panel.EditNameEditBox:GetText());
    end);


    self.ChooseProfileText = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesMediumNormalSemiBoldFont'), E.PixelPerfectMixin);
    self.ChooseProfileText:SetPosition('TOPLEFT', self.ActiveProfile, 'BOTTOMLEFT', 0, -16);
    self.ChooseProfileText:SetJustifyH('LEFT');
    self.ChooseProfileText:SetTextColor(0.85, 0.85, 0.85);
    self.ChooseProfileText:SetText(L['OPTIONS_PROFILES_CHOOSE_PROFILE']);

    self.ProfilesDropdown = E.CreateDropdown('plain', self);
    self.ProfilesDropdown:SetPosition('LEFT', self.ChooseProfileText, 'RIGHT', 12, 0);
    self.ProfilesDropdown:SetSize(200, 20);
    UpdateProfilesDropdown();
    self.ProfilesDropdown.OnValueChangedCallback = function(_, _, name)
        ChooseProfileByName(name);
    end

    local Delimiter = E.CreateDelimiter(self);
    Delimiter:SetPosition('TOPLEFT', self.ChooseProfileText, 'BOTTOMLEFT', -12, -8);
    Delimiter:SetW(self:GetWidth());

    self.CreateNewProfileEditBox = E.CreateEditBox(self);
    self.CreateNewProfileEditBox:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 17, -8);
    self.CreateNewProfileEditBox:SetSize(180, 22)
    self.CreateNewProfileEditBox:SetFont(self.ActiveProfileValue:GetFont());
    self.CreateNewProfileEditBox:SetInstruction(L['OPTIONS_PROFILES_CREATE_NEW_ENTER_NAME']);
    self.CreateNewProfileEditBox:SetMaxLetters(MAX_LETTERS);
    self.CreateNewProfileEditBox.useLastValue = false;

    self.CopyFromActiveButton = E.CreateButton(self);
    self.CopyFromActiveButton:SetPosition('LEFT', self.CreateNewProfileEditBox, 'RIGHT', 12, 0);
    self.CopyFromActiveButton:SetLabel(L['OPTIONS_PROFILES_COPY_FROM_ACTIVE_BUTTON_LABEL']);
    self.CopyFromActiveButton:SetHighlightColor('10b095');
    self.CopyFromActiveButton:SetScript('OnClick', function()
        CopyFromActive(panel.CreateNewProfileEditBox:GetText());
        panel.CreateNewProfileEditBox.Instruction:SetShown(true);
    end);

    self.CreateDefaultProfileButton = E.CreateButton(self);
    self.CreateDefaultProfileButton:SetPosition('LEFT', self.CopyFromActiveButton, 'RIGHT', 12, 0);
    self.CreateDefaultProfileButton:SetLabel(L['OPTIONS_PROFILES_CREATE_DEFAULT_PROFILE_BUTTON_LABEL']);
    self.CreateDefaultProfileButton:SetHighlightColor('62bd35');
    self.CreateDefaultProfileButton:SetScript('OnClick', function()
        CreateDefaultProfile(panel.CreateNewProfileEditBox:GetText());
        panel.CreateNewProfileEditBox.Instruction:SetShown(true);
    end);

    Delimiter = E.CreateDelimiter(self);
    Delimiter:SetPosition('TOPLEFT', self.CreateNewProfileEditBox, 'BOTTOMLEFT', -17, -8);
    Delimiter:SetW(self:GetWidth());

    self.ImportProfileButton = E.CreateButton(self);
    self.ImportProfileButton:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 12, -8);
    self.ImportProfileButton:SetLabel(L['OPTIONS_PROFILES_IMPORT_BUTTON_LABEL']);
    self.ImportProfileButton:SetHighlightColor('ff884d');
    self.ImportProfileButton:SetScript('OnClick', function()
        panel.ImportExportFrame.editBox:SetText('');

        panel.ImportExportFrame.okButton:SetScript('OnClick', function()
            local importString = panel.ImportExportFrame.editBox:GetText();
            if not importString or importString == '' then
                panel.ImportExportFrame:SetShown(false);
                return;
            end

            -- encodeVersion
            -- 1 - Full profile
            local _, _, encodeVersion, encoded = importString:find('^(!S:%d+!)(.+)$');
            if encodeVersion then
                encodeVersion = tonumber(encodeVersion:match('%d+'));
            end

            if not encodeVersion then
                U.Print(L['OPTIONS_PROFILES_IMPORT_FAILED']);
                return;
            end

            local printable_compressed = LibDeflate:DecodeForPrint(encoded);
            local decompress_deflate = LibDeflate:DecompressDeflate(printable_compressed);
            if decompress_deflate == nil then
                U.Print(L['OPTIONS_PROFILES_IMPORT_FAILED_DECOMPRESSION']);
            else
                local success, importTable = LibSerialize:Deserialize(decompress_deflate);
                if not success then
                    U.Print(L['OPTIONS_PROFILES_IMPORT_FAILED_DESERIALIZATION']);
                else
                    ImportProfile(importTable.profileName, importTable);

                    panel.ImportExportFrame:SetShown(false);
                end
            end
        end);

        panel.ImportExportFrame.CloseButton:SetShown(true);
        panel.ImportExportFrame.okButton:SetLabel(L['OPTIONS_PROFILES_IMPORT_BUTTON_LABEL']);
        panel.ImportExportFrame:SetShown(true);
    end);

    self.ExportProfileButton = E.CreateButton(self);
    self.ExportProfileButton:SetPosition('LEFT', self.ImportProfileButton, 'RIGHT', 16, 0);
    self.ExportProfileButton:SetLabel(L['OPTIONS_PROFILES_EXPORT_BUTTON_LABEL']);
    self.ExportProfileButton:SetHighlightColor('4d6fff');
    self.ExportProfileButton:SetScript('OnClick', function()
        panel.ImportExportFrame.okButton:SetScript('OnClick', function()
            panel.ImportExportFrame.editBox:SetText('');
            panel.ImportExportFrame:SetShown(false);
        end);

        local exportTable = LibSerialize:Serialize(StripesDB.profiles[O.activeProfileId]);
        local compress_deflate = LibDeflate:CompressDeflate(exportTable, DEFLATE_CONFIG);
        local printable_compressed = ENCODE_PREFIX .. LibDeflate:EncodeForPrint(compress_deflate);

        panel.ImportExportFrame.editBox:SetText(printable_compressed);
        panel.ImportExportFrame.editBox:HighlightText(0,-1)

        panel.ImportExportFrame.CloseButton:SetShown(true);
        panel.ImportExportFrame.okButton:SetLabel(L['OPTIONS_PROFILES_EXPORT_COPIED']);
        panel.ImportExportFrame:SetShown(true);
    end);


    Delimiter = E.CreateDelimiter(self);
    Delimiter:SetPosition('TOPLEFT', self.ImportProfileButton, 'BOTTOMLEFT', -12, -8);
    Delimiter:SetW(self:GetWidth());

    self.RemoveProfile = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesMediumNormalSemiBoldFont'), E.PixelPerfectMixin);
    self.RemoveProfile:SetPosition('TOPLEFT', Delimiter, 'BOTTOMLEFT', 12, -8);
    self.RemoveProfile:SetJustifyH('LEFT');
    self.RemoveProfile:SetTextColor(1, 0.3, 0.3);
    self.RemoveProfile:SetText(L['OPTIONS_PROFILES_REMOVE_PROFILE']);

    self.RemoveProfilesDropdown = E.CreateDropdown('plain', self);
    self.RemoveProfilesDropdown:SetPosition('LEFT', self.RemoveProfile, 'RIGHT', 12, 0);
    self.RemoveProfilesDropdown:SetSize(200, 20);
    UpdateRemoveProfilesDropdown();
    self.RemoveProfilesDropdown.OnValueChangedCallback = function(_, _, name)
        RemoveProfileByName(name);
    end

    self.ResetProfileButton = E.CreateButton(self);
    self.ResetProfileButton:SetPosition('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 0, 4);
    self.ResetProfileButton:SetLabel(L['OPTIONS_PROFILES_RESET_PROFILE_BUTTON']);
    self.ResetProfileButton:SetHighlightColor('cccccc');
    self.ResetProfileButton:SetScript('OnClick', function()
        StaticPopup_Show('STRIPES_RESET_PROFILE_TO_DEFAULT');
    end);
end