local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Custom');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local math_max = math.max;

-- WoW API
local CooldownFrame_Set, UnitIsUnit, AuraUtil_ForEachAura = CooldownFrame_Set, UnitIsUnit, AuraUtil.ForEachAura;

-- Stripes API
local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE, OFFSET_X, OFFSET_Y, BUFFFRAME_OFFSET_Y;
local BORDER_HIDE, BORDER_COLOR;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local AURAS_DIRECTION, AURAS_MAX_DISPLAY;

local StripesAurasCustomCooldownFont = CreateFont('StripesAurasCustomCooldownFont');
local StripesAurasCustomCountFont    = CreateFont('StripesAurasCustomCountFont');

local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

local playerUnits = {
    ['player']  = true,
    ['pet']     = true,
    ['vehicle'] = true,
};

local MAX_OFFSET_Y = -9;

local function CreateBuffFrame(unitframe)
    if unitframe.AurasCustom then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasCustom', unitframe);
    frame:SetPoint('RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};

    frame.AuraComparator = function(a, b)
        return AuraUtil.DefaultAuraCompare(a, b);
    end

    frame.UpdateAnchor = function(self)
        self:ClearAllPoints();

        local uf = self:GetParent();

        if uf.AurasMythicPlus and uf.AurasMythicPlus:IsShown() then
            self:SetPoint('BOTTOM', uf.AurasMythicPlus, 'TOP', 0, 4);
        else
            local unit = uf.data.unit or uf.unit;

            if unit and ShouldShowName(uf) then
                local offset = NAME_TEXT_POSITION_V == 1 and (uf.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
                self:SetPoint('BOTTOM', uf.healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            else
                local offset = uf.BuffFrame:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and uf.BuffFrame:GetTargetYOffset() or 0.0);
                self:SetPoint('BOTTOM', uf.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            end
        end

        if AURAS_DIRECTION == 1 then
            self:SetPoint('LEFT', uf.healthBar, 'LEFT', OFFSET_X, 0);
        elseif AURAS_DIRECTION == 2 then
            self:SetPoint('RIGHT', uf.healthBar, 'RIGHT', OFFSET_X, 0);
        else
            self:SetWidth(uf.healthBar:GetWidth());
        end
    end

    frame.ShouldShowBuff = function(self, aura, forceAll, isSelf)
        local name    = aura.name;
        local spellId = aura.spellID;
        local caster  = aura.sourceUnit;

        local spellData = O.db.auras_custom_data[spellId] or O.db.auras_custom_data[name];

        if spellData and spellData.enabled and (not spellData.own_only or (playerUnits[caster] and spellData.own_only)) then
            return true;
        end

        return false;
    end

    frame.ParseAllAuras = function(self, forceAll)
        if self.auras == nil then
            self.auras = TableUtil.CreatePriorityTable(self.AuraComparator, TableUtil.Constants.AssociativePriorityTable);
        else
            self.auras:Clear();
        end

        local function HandleAura(aura)
            if self:ShouldShowBuff(aura, forceAll) then
                self.auras[aura.auraInstanceID] = aura;
            end

            return false;
        end

        local batchCount = nil;
        local usePackedAura = true;

        AuraUtil_ForEachAura(self.unit, filterHarmful, batchCount, HandleAura, usePackedAura);
        AuraUtil_ForEachAura(self.unit, filterHelpful, batchCount, HandleAura, usePackedAura);
    end

    frame.UpdateBuffs = function(self, unit, unitAuraUpdateInfo, auraSettings)
        local uf = self:GetParent();

        if not ENABLED or uf.data.unitType == 'SELF' or unitframe.data.isUnimportantUnit then
            self:Hide();
            return;
        end

        unit = unit or uf.data.unit;

        local isSelf = uf.data.unitType == 'SELF';

        local filterString = filterHarmful;

        local previousFilter = self.filter;
        local previousUnit   = self.unit;

        local showAll = auraSettings and auraSettings.showAll; 

        self.unit   = unit;
        self.filter = filterHarmful;

        local aurasChanged = false;
        if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter then
            self:ParseAllAuras(showAll);
            aurasChanged = true;
        else
            if unitAuraUpdateInfo.addedAuras ~= nil then
                for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                    if self:ShouldShowBuff(aura, showAll, isSelf) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filterString) then
                        self.auras[aura.auraInstanceID] = aura;
                        aurasChanged = true;
                    end
                end
            end

            if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
                for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
                    if self.auras[auraInstanceID] ~= nil then
                        local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
                        self.auras[auraInstanceID] = newAura;
                        aurasChanged = true;
                    end
                end
            end

            if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
                for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
                    if self.auras[auraInstanceID] ~= nil then
                        self.auras[auraInstanceID] = nil;
                        aurasChanged = true;
                    end
                end
            end
        end

        self:UpdateAnchor();

        if not aurasChanged then
            return;
        end

        local buffIndex = 1;
        self.auras:Iterate(function(auraInstanceID, aura)
            local buff = self.buffList[buffIndex];

            if not buff then
                buff = CreateFrame('Frame', nil, self, 'NameplateBuffButtonTemplate');
                buff:SetMouseClickEnabled(false);
                buff:SetScale(SCALE);

                if SQUARE then
                    buff:SetSize(20, 20);
                    buff.Icon:SetSize(18, 18);
                    buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
                end

                buff.Cooldown:SetDrawEdge(DRAW_EDGE);
                buff.Cooldown:SetDrawSwipe(DRAW_SWIPE);
                buff.Cooldown:SetCountdownFont('StripesAurasCustomCooldownFont');
                buff.Cooldown:GetRegions():ClearAllPoints();
                buff.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                buff.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                buff.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
                buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                buff.CountFrame.Count:ClearAllPoints();
                buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                buff.CountFrame.Count:SetFontObject(StripesAurasCustomCountFont);
                buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                buff.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                buff.Border:SetShown(not BORDER_HIDE);

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasCustomGroup:RemoveButton(buff);
                    Stripes.MasqueAurasCustomGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);
                end

                self.buffList[buffIndex] = buff;
            end

            buff.auraInstanceID = auraInstanceID;
            buff.isBuff = aura.isHelpful;
            buff.layoutIndex = buffIndex;
            buff.spellID = aura.spellId;
            buff.expirationTime = aura.expirationTime;
            buff.sourceUnit = aura.sourceUnit;

            buff:ClearAllPoints();

            if AURAS_DIRECTION == 1 then
                buff:SetPoint('TOPLEFT', (buffIndex - 1) * (20 + SPACING_X), 0);
            elseif AURAS_DIRECTION == 2 then
                buff:SetPoint('TOPRIGHT', -((buffIndex - 1) * (20 + SPACING_X)), 0);
            else
                self.buffList[1]:SetPoint('TOP', -(buff:GetWidth()/2)*(buffIndex-1), 0);

                if buffIndex > 1 then
                    buff:SetPoint('TOPLEFT', self.buffList[buffIndex - 1], 'TOPRIGHT', SPACING_X, 0);
                end
            end

            buff.Icon:SetTexture(aura.icon);

            if aura.applications > 1 then
                buff.CountFrame.Count:SetText(aura.applications);
                buff.CountFrame.Count:Show()
            else
                buff.CountFrame.Count:Hide();
            end

            CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, DRAW_EDGE);

            buff:Show();

            buffIndex = buffIndex + 1;

            return buffIndex >= AURAS_MAX_DISPLAY;
        end);

        for i = buffIndex, AURAS_MAX_DISPLAY do
            if self.buffList[i] then
                self.buffList[i]:Hide();
            else
                break;
            end
        end

        if buffIndex > 1 then
            if not self:IsShown() then
                self:Show();
            end

            self:UpdateAnchor();
        else
            if self:IsShown() then
                self:Hide();
            end
        end
    end

    frame.UpdateStyle = function(self)
        for _, buff in ipairs(self.buffList) do
            if Stripes.Masque then
                if MASQUE_SUPPORT then
                    Stripes.MasqueAurasCustomGroup:RemoveButton(buff);
                    Stripes.MasqueAurasCustomGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);

                    buff.Border:SetDrawLayer('BACKGROUND');
                else
                    Stripes.MasqueAurasCustomGroup:RemoveButton(buff);

                    buff.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                    buff.Border:SetDrawLayer('BACKGROUND');

                    buff.Icon:SetDrawLayer('ARTWORK');

                    buff.Cooldown:ClearAllPoints();
                    buff.Cooldown:SetAllPoints();
                end
            end

            buff:SetScale(SCALE);

            if SQUARE then
                buff:SetSize(20, 20);
                buff.Icon:SetSize(18, 18);
                buff.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
            else
                buff:SetSize(20, 14);
                buff.Icon:SetSize(18, 12);
                buff.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
            end

            buff.Border:SetShown(not BORDER_HIDE);
            buff.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);

            buff.Cooldown:SetDrawEdge(DRAW_EDGE);
            buff.Cooldown:SetDrawSwipe(DRAW_SWIPE);
            buff.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            buff.Cooldown:GetRegions():ClearAllPoints();
            buff.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            buff.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);

            buff.CountFrame.Count:ClearAllPoints();
            buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);
        end
    end

    unitframe.AurasCustom = frame;
end

function Module:UnitAdded(unitframe)
    CreateBuffFrame(unitframe);
    unitframe.AurasCustom:UpdateBuffs();
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasCustom then
        unitframe.AurasCustom:Hide();
    end
end

function Module:UnitAura(unitframe, unitAuraUpdateInfo)
    if unitframe.AurasCustom then
        unitframe.AurasCustom:UpdateBuffs(unitframe.data.unit, unitAuraUpdateInfo);
    end
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasCustomGroup:ReSkin();
    end

    unitframe.AurasCustom:UpdateBuffs();
    unitframe.AurasCustom:UpdateStyle();
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_custom_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_custom_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    BORDER_HIDE     = O.db.auras_border_hide;
    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_custom_border_color[1];
    BORDER_COLOR[2] = O.db.auras_custom_border_color[2];
    BORDER_COLOR[3] = O.db.auras_custom_border_color[3];
    BORDER_COLOR[4] = O.db.auras_custom_border_color[4] or 1;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_custom_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_custom_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_custom_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_custom_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_custom_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_custom_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_custom_count_offset_y;

    SCALE  = O.db.auras_custom_scale;
    SQUARE = O.db.auras_square;
    OFFSET_X = O.db.auras_custom_offset_x;
    OFFSET_Y = O.db.auras_custom_offset_y;
    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_custom_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_custom_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_custom_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_custom_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_custom_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_custom_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_custom_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_custom_count_color[4] or 1;

    SPACING_X = O.db.auras_custom_spacing_x or 2;

    DRAW_EDGE  = O.db.auras_custom_draw_edge;
    DRAW_SWIPE = O.db.auras_custom_draw_swipe;

    AURAS_DIRECTION = O.db.auras_custom_direction;
    AURAS_MAX_DISPLAY = O.db.auras_custom_max_display;

    UpdateFontObject(StripesAurasCustomCooldownFont, O.db.auras_custom_cooldown_font_value, O.db.auras_custom_cooldown_font_size, O.db.auras_custom_cooldown_font_flag, O.db.auras_custom_cooldown_font_shadow);
    UpdateFontObject(StripesAurasCustomCountFont, O.db.auras_custom_count_font_value, O.db.auras_custom_count_font_size, O.db.auras_custom_count_font_flag, O.db.auras_custom_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', function(unitframe)
        unitframe.AurasCustom:UpdateAnchor();
    end);
end