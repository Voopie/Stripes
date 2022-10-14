local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_SpellSteal');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local math_max = math.max;

-- WoW API
local CooldownFrame_Set, UnitIsUnit, GetTime, AuraUtil_ForEachAura = CooldownFrame_Set, UnitIsUnit, GetTime, AuraUtil.ForEachAura;

-- Stripes API
local ShouldShowName   = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local BORDER_COLOR;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE, BUFFFRAME_OFFSET_Y;
local STATIC_POSITION, OFFSET_X, OFFSET_Y;
local GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;
local BORDER_HIDE;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local AURAS_DIRECTION, AURAS_MAX_DISPLAY;

-- Libraries
local LCG = S.Libraries.LCG;

local StripesAurasSpellStealCooldownFont = CreateFont('StripesAurasSpellStealCooldownFont');
local StripesAurasSpellStealCountFont    = CreateFont('StripesAurasSpellStealCountFont');

local filter = 'HELPFUL';

local MAX_OFFSET_Y = -9;

local function CreateBuffFrame(unitframe)
    if unitframe.AurasSpellSteal then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasSpellSteal', unitframe);
    frame:SetPoint('LEFT', unitframe.healthBar, 'LEFT', 0, 0);
    frame:SetPoint('BOTTOM', unitframe.BuffFrame, 'TOP', 0, 4);
    frame:SetHeight(14);

    frame.buffList = {};

    frame.AuraComparator = function(a, b)
        return AuraUtil.DefaultAuraCompare(a, b);
    end

    frame.UpdateAnchor = function(self)
        local uf = self:GetParent();

        self:ClearAllPoints();

        if uf.BuffFrame.buffPool:GetNumActive() > 0 then
            if STATIC_POSITION then
                self:SetPoint('BOTTOM', uf.healthBar, 'TOP', 1 + OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
            else
                self:SetPoint('BOTTOM', uf.BuffFrame, 'TOP', OFFSET_X, 4 + OFFSET_Y);
            end
        else
            if ShouldShowName(uf) then
                if STATIC_POSITION then
                    self:SetPoint('BOTTOM', uf.healthBar, 'TOP', OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
                else
                    local offset = NAME_TEXT_POSITION_V == 1 and (uf.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
                    self:SetPoint('BOTTOM', uf.healthBar, 'TOP', OFFSET_X, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
                end
            else
                if STATIC_POSITION then
                    self:SetPoint('BOTTOM', uf.healthBar, 'TOP', OFFSET_X, 2 + (SQUARE and 6 or 0) + OFFSET_Y);
                else
                    local offset = uf.BuffFrame:GetBaseYOffset() + (UnitIsUnit(uf.data.unit, 'target') and uf.BuffFrame:GetTargetYOffset() or 0.0);
                    self:SetPoint('BOTTOM', uf.healthBar, 'TOP', OFFSET_X, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
                end
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
        return aura and aura.isStealable;
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

        AuraUtil_ForEachAura(self.unit, self.filter, batchCount, HandleAura, usePackedAura);
    end

    frame.UpdateBuffs = function(self, unit, unitAuraUpdateInfo, auraSettings)
        local uf = self:GetParent();

        if not ENABLED or not uf.data.unit or uf.data.isPersonal or unitframe.data.isUnimportantUnit then
            self:Hide();
            return;
        end

        unit = unit or uf.data.unit;

        local isSelf = uf.data.isPersonal;

        local filterString = filter;

        local previousFilter = self.filter;
        local previousUnit   = self.unit;

        local showAll = auraSettings and auraSettings.showAll;

        self.unit   = unit;
        self.filter = filter;

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
                buff.Cooldown:SetFrameStrata('HIGH');
                buff.Cooldown:SetCountdownFont('StripesAurasSpellStealCooldownFont');
                buff.Cooldown:GetRegions():ClearAllPoints();
                buff.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                buff.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                buff.CountFrame:SetFrameStrata('HIGH');
                buff.CountFrame.Count:ClearAllPoints();
                buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                buff.CountFrame.Count:SetFontObject(StripesAurasSpellStealCountFont);
                buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                buff.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                buff.Border:SetShown(not BORDER_HIDE);

                self:UpdateGlow(buff);

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasSpellstealGroup:RemoveButton(buff);
                    Stripes.MasqueAurasSpellstealGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);
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

            if aura.expirationTime - GetTime() >= 3600 then
                buff.Cooldown:SetHideCountdownNumbers(true);
            else
                buff.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
            end

            buff:Show();

            buffIndex = buffIndex + 1;

            return buffIndex > AURAS_MAX_DISPLAY;
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

    frame.UpdateGlow = function(self, buff)
        if not GLOW_ENABLED then
            return;
        end

        if GLOW_TYPE == 1 then
            LCG.PixelGlow_Start(buff, GLOW_COLOR);
        elseif GLOW_TYPE == 2 then
            LCG.AutoCastGlow_Start(buff, GLOW_COLOR);
        elseif GLOW_TYPE == 3 then
            LCG.ButtonGlow_Start(buff, GLOW_COLOR);
        end
    end

    frame.StopGlow = function(self, buff)
        LCG.PixelGlow_Stop(buff);
        LCG.AutoCastGlow_Stop(buff);
        LCG.ButtonGlow_Stop(buff);
    end

    frame.UpdateStyle = function(self)
        for _, buff in ipairs(self.buffList) do
            if Stripes.Masque then
                if MASQUE_SUPPORT then
                    Stripes.MasqueAurasSpellstealGroup:RemoveButton(buff);
                    Stripes.MasqueAurasSpellstealGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);

                    buff.Border:SetDrawLayer('BACKGROUND');
                else
                    Stripes.MasqueAurasSpellstealGroup:RemoveButton(buff);

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
            buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

            buff.Cooldown:GetRegions():ClearAllPoints();
            buff.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            buff.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);

            buff.CountFrame.Count:ClearAllPoints();
            buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

            self:StopGlow(buff);
            self:UpdateGlow(buff);
        end
    end

    unitframe.AurasSpellSteal = frame;
end

function Module:UnitAdded(unitframe)
    CreateBuffFrame(unitframe);

    unitframe.AurasSpellSteal.spacing = SPACING_X;
    unitframe.AurasSpellSteal:UpdateBuffs();
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasSpellSteal then
        unitframe.AurasSpellSteal:Hide();
    end
end

function Module:UnitAura(unitframe, unitAuraUpdateInfo)
    unitframe.AurasSpellSteal:UpdateBuffs(unitframe.data.unit, unitAuraUpdateInfo);
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasSpellstealGroup:ReSkin();
    end

    unitframe.AurasSpellSteal.spacing = SPACING_X;
    unitframe.AurasSpellSteal:UpdateBuffs();
    unitframe.AurasSpellSteal:UpdateStyle();
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_spellsteal_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_spellsteal_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    BORDER_HIDE = O.db.auras_border_hide;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_spellsteal_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_spellsteal_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_spellsteal_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_spellsteal_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_spellsteal_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_spellsteal_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_spellsteal_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_spellsteal_count_offset_y;

    SCALE  = O.db.auras_spellsteal_scale;
    SQUARE = O.db.auras_square;

    STATIC_POSITION = O.db.auras_spellsteal_static_position;
    OFFSET_X = O.db.auras_spellsteal_offset_x;
    OFFSET_Y = O.db.auras_spellsteal_offset_y;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    GLOW_ENABLED = O.db.auras_spellsteal_glow_enabled;
    GLOW_TYPE    = O.db.auras_spellsteal_glow_type;
    GLOW_COLOR    = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.auras_spellsteal_glow_color[1];
    GLOW_COLOR[2] = O.db.auras_spellsteal_glow_color[2];
    GLOW_COLOR[3] = O.db.auras_spellsteal_glow_color[3];
    GLOW_COLOR[4] = O.db.auras_spellsteal_glow_color[4] or 1;

    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_spellsteal_color[1];
    BORDER_COLOR[2] = O.db.auras_spellsteal_color[2];
    BORDER_COLOR[3] = O.db.auras_spellsteal_color[3];
    BORDER_COLOR[4] = O.db.auras_spellsteal_color[4] or 1;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_spellsteal_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_spellsteal_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_spellsteal_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_spellsteal_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_spellsteal_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_spellsteal_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_spellsteal_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_spellsteal_count_color[4] or 1;

    SPACING_X = O.db.auras_spellsteal_spacing_x or 4;

    DRAW_EDGE  = O.db.auras_spellsteal_draw_edge;
    DRAW_SWIPE = O.db.auras_spellsteal_draw_swipe;

    AURAS_DIRECTION = O.db.auras_spellsteal_direction;
    AURAS_MAX_DISPLAY = O.db.auras_spellsteal_max_display;

    UpdateFontObject(StripesAurasSpellStealCooldownFont, O.db.auras_spellsteal_cooldown_font_value, O.db.auras_spellsteal_cooldown_font_size, O.db.auras_spellsteal_cooldown_font_flag, O.db.auras_spellsteal_cooldown_font_shadow);
    UpdateFontObject(StripesAurasSpellStealCountFont, O.db.auras_spellsteal_count_font_value, O.db.auras_spellsteal_count_font_size, O.db.auras_spellsteal_count_font_flag, O.db.auras_spellsteal_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', function(unitframe)
        unitframe.AurasSpellSteal:UpdateAnchor();
    end);
end