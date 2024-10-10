local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Auras_Important');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local bit_band, math_max = bit.band, math.max;

-- Wow API
local CooldownFrame_Set, UnitName, AuraUtil_ForEachAura = CooldownFrame_Set, UnitName, AuraUtil.ForEachAura;

-- Sripes API
local S_ShouldShowName, S_UpdateFontObject = Stripes.ShouldShowName, Stripes.UpdateFontObject;
local U_GetUnitColor = U.GetUnitColor;
local U_GlowStart, U_GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local LPS_CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local LPS_CROWD_CTRL = LPS.constants.CROWD_CTRL;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, CASTER_NAME_SHOW;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE;
local OFFSET_X, OFFSET_Y;
local BORDER_HIDE;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y, BUFFFRAME_OFFSET_Y;
local AURAS_MAX_DISPLAY;
local GLOW_ENABLED, GLOW_TYPE, GLOW_COLOR;
local BORDER_COLOR;

local StripesAurasImportantCooldownFont = CreateFont('StripesAurasImportantCooldownFont');
local StripesAurasImportantCountFont    = CreateFont('StripesAurasImportantCountFont');
local StripesAurasImportantCasterFont   = CreateFont('StripesAurasImportantCasterFont');

local MAX_OFFSET_Y = -9;

local additionalAuras = {
    -- Druid
    [81261] = true, -- Solar Beam

    -- Paladin
    [10326]  = true, -- Turn Evil
    [255941] = true, -- Wake of Ashes

    -- Priest
    [453] = true, -- Mind Soothe

    -- Warlock
    [5484] = true, -- Howl of Terror

    -- Warrior
    [385954] = true, -- Shield Charge

    -- Demon Hunter
    [370970] = true, -- The Hunt (Root)

    -- Evoker
    [360806] = true, -- Sleep Walk

    -- Shaman
    [3600]   = true, -- Earthbind Totem
    [210873] = true, -- Hex (Compy)
    [211004] = true, -- Hex (Spider)
    [211010] = true, -- Hex (Snake)
    [211015] = true, -- Hex (Cockroach)
    [269352] = true, -- Hex (Skeletal Hatchling)
    [277778] = true, -- Hex (Zandalari Tendonripper)
    [277784] = true, -- Hex (Wicker Mongrel)
    [309328] = true, -- Hex (Living Honey)

    -- Mage
    [391622] = true, -- Polymorph (Duck)
    [321395] = true, -- Polymorph (Mawrat)

    -- Covenant
    [331866] = true, -- Agent of Chaos (Venthyr)
    [332423] = true, -- Sparkling Driftglobe Core (Kyrian)

    -- Other
    [228626] = true, -- Haunted Urn (De Other Side) (Stun)
    [348723] = true, -- Haunted Urn (De Other Side) (Stun) ???
};

local function CreateBuffFrame(unitframe)
    if unitframe.AurasImportant then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasImportant', unitframe);
    frame:SetSize(14, 14);

    frame.buffList = {};

    frame.AuraComparator = function(a, b)
        return AuraUtil.DefaultAuraCompare(a, b);
    end

    frame.UpdateAnchor = function(self)
        local uf = self:GetParent();

        local squareOffset = SQUARE and 6 or 0;

        if uf.BuffFrame.buffPool:GetNumActive() > 0 then
            self:SetPoint('BOTTOMLEFT', uf.BuffFrame, 'TOPLEFT', OFFSET_X, 4 + squareOffset + OFFSET_Y);
        else
            if S_ShouldShowName(uf) then
                local nameOffset = NAME_TEXT_POSITION_V == 1 and (uf.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
                self:SetPoint('BOTTOMLEFT', uf.healthBar, 'TOPLEFT', OFFSET_X, 2 + nameOffset + squareOffset + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            else
                local buffFrameBaseYOffset = uf.BuffFrame:GetBaseYOffset();
                local buffFrameTargetYOffset = uf.data.isTarget and uf.BuffFrame:GetTargetYOffset() or 0;

                self:SetPoint('BOTTOMLEFT', uf.healthBar, 'TOPLEFT', OFFSET_X, 5 + buffFrameBaseYOffset + buffFrameTargetYOffset + squareOffset + BUFFFRAME_OFFSET_Y + OFFSET_Y);
            end
        end

        self:SetWidth(uf.healthBar:GetWidth());
    end

    frame.ShouldShowBuff = function(self, aura)
        if not (aura and aura.spellId) then
            return false;
        end

        local spellId = aura.spellId;

        local spellFound = false;

        if additionalAuras[spellId] then
            spellFound = true;
        else
            local flags, _, _, cc = LPS_GetSpellInfo(LPS, spellId);
            if flags and cc and bit_band(flags, LPS_CROWD_CTRL) > 0 and bit_band(cc, LPS_CC_TYPES) > 0 then
                spellFound = true;
            end
        end

        return spellFound;
    end

    frame.ParseAllAuras = function(self)
        if self.auras == nil then
            self.auras = TableUtil.CreatePriorityTable(self.AuraComparator, TableUtil.Constants.AssociativePriorityTable);
        else
            self.auras:Clear();
        end

        local function HandleAura(aura)
            if self:ShouldShowBuff(aura) then
                self.auras[aura.auraInstanceID] = aura;
            end

            return false;
        end

        local batchCount = nil;
        local usePackedAura = true;

        AuraUtil_ForEachAura(self.unit, self.filter, batchCount, HandleAura, usePackedAura);
    end

    frame.UpdateBuffs = function(self, unit, unitAuraUpdateInfo)
        local uf = self:GetParent();

        unit = unit or uf.data.unit;

        if not ENABLED or not unit or uf.data.isPersonal or uf.data.isUnimportantUnit then
            self:Hide();
            return;
        end

        local previousFilter = self.filter;
        local previousUnit   = self.unit;

        self.unit   = unit;
        self.filter = 'HARMFUL';

        local aurasChanged = false;
        if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or self.filter ~= previousFilter then
            self:ParseAllAuras();
            aurasChanged = true;
        else
            if unitAuraUpdateInfo.addedAuras ~= nil then
                for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                    if self:ShouldShowBuff(aura) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, self.filter) then
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

                buff.Border:SetColorTexture(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
                buff.Border:SetShown(not BORDER_HIDE);

                local cooldown = buff.Cooldown;
                cooldown:SetDrawEdge(DRAW_EDGE);
                cooldown:SetDrawSwipe(DRAW_SWIPE);
                cooldown:SetFrameStrata('HIGH');
                cooldown:SetCountdownFont('StripesAurasImportantCooldownFont');
                cooldown.Countdown = cooldown:GetRegions();
                cooldown.Countdown:ClearAllPoints();
                cooldown.Countdown:SetPoint(COUNTDOWN_POINT, cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                cooldown.Countdown:SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
                cooldown.noCooldownCount = SUPPRESS_OMNICC;

                buff.CountFrame:SetFrameStrata('HIGH');
                buff.CountFrame.Count:ClearAllPoints();
                buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                buff.CountFrame.Count:SetFontObject(StripesAurasImportantCountFont);
                buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                buff.CasterName = buff:CreateFontString(nil, 'ARTWORK');
                buff.CasterName:SetPoint('BOTTOM', buff, 'TOP', 0, 2);
                buff.CasterName:SetFontObject(StripesAurasImportantCasterFont);

                if GLOW_ENABLED then
                    U_GlowStart(buff, GLOW_TYPE, GLOW_COLOR);
                end

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasImportantGroup:RemoveButton(buff);
                    Stripes.MasqueAurasImportantGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = cooldown }, 'Aura', true);
                end

                self.buffList[buffIndex] = buff;
            end

            buff.auraInstanceID = auraInstanceID;
            buff.isBuff         = aura.isHelpful;
            buff.layoutIndex    = buffIndex;
            buff.spellID        = aura.spellId;
            buff.expirationTime = aura.expirationTime;
            buff.sourceUnit     = aura.sourceUnit;

            self.buffList[1]:ClearAllPoints();
            self.buffList[1]:SetPoint('CENTER', -(self.buffList[1]:GetWidth() * 0.5) * (buffIndex - 1), 0);

            if buffIndex > 1 then
                buff:ClearAllPoints();
                buff:SetPoint('LEFT', self.buffList[buffIndex - 1], 'RIGHT', SPACING_X, 0);
            end

            buff.Icon:SetTexture(aura.icon);

            if aura.applications > 1 then
                buff.CountFrame.Count:SetText(aura.applications);
                buff.CountFrame.Count:Show()
            else
                buff.CountFrame.Count:Hide();
            end

            CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, DRAW_EDGE);

            if CASTER_NAME_SHOW then
                local unitname = buff.sourceUnit and UnitName(buff.sourceUnit);
                if unitname then
                    buff.CasterName:SetText(unitname);
                    buff.CasterName:SetTextColor(U_GetUnitColor(buff.sourceUnit, 2));
                    buff.CasterName:Show();
                else
                    buff.CasterName:Hide();
                end
            else
                buff.CasterName:Hide();
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

    frame.UpdateStyle = function(self)
        for _, buff in ipairs(self.buffList) do
            if Stripes.Masque then
                if MASQUE_SUPPORT then
                    Stripes.MasqueAurasImportantGroup:RemoveButton(buff);
                    Stripes.MasqueAurasImportantGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);

                    buff.Border:SetDrawLayer('BACKGROUND');
                else
                    Stripes.MasqueAurasImportantGroup:RemoveButton(buff);

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

            buff.Cooldown.Countdown:ClearAllPoints();
            buff.Cooldown.Countdown:SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
            buff.Cooldown.Countdown:SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);

            buff.CountFrame.Count:ClearAllPoints();
            buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
            buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

            if GLOW_ENABLED then
                U_GlowStopAll(buff);
                U_GlowStart(buff, GLOW_TYPE, GLOW_COLOR);
            else
                U_GlowStopAll(buff);
            end
        end
    end

    unitframe.AurasImportant = frame;
end

function Module:UnitAdded(unitframe)
    CreateBuffFrame(unitframe);
    unitframe.AurasImportant:UpdateBuffs();
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasImportant then
        unitframe.AurasImportant:Hide();
    end
end

function Module:UnitAura(unitframe, unitAuraUpdateInfo)
    if unitframe.AurasImportant then
        unitframe.AurasImportant:UpdateBuffs(unitframe.data.unit, unitAuraUpdateInfo);
    end
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasImportantGroup:ReSkin();
    end

    if unitframe.AurasImportant then
        unitframe.AurasImportant:UpdateBuffs();
        unitframe.AurasImportant:UpdateStyle();
    end
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    SCALE = O.db.auras_important_scale;

    ENABLED           = O.db.auras_important_enabled;
    COUNTDOWN_ENABLED = O.db.auras_important_countdown_enabled;
    CASTER_NAME_SHOW  = O.db.auras_important_castername_show;
    SUPPRESS_OMNICC   = O.db.auras_omnicc_suppress;

    BORDER_HIDE = O.db.auras_border_hide;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_important_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_important_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_important_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_important_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_important_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_important_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_important_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_important_count_offset_y;

    SQUARE = O.db.auras_square;

    OFFSET_X = O.db.auras_important_offset_x;
    OFFSET_Y = O.db.auras_important_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_important_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_important_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_important_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_important_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_important_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_important_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_important_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_important_count_color[4] or 1;

    SPACING_X = O.db.auras_important_spacing_x or 2;

    DRAW_EDGE  = O.db.auras_important_draw_edge;
    DRAW_SWIPE = O.db.auras_important_draw_swipe;

    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    BUFFFRAME_OFFSET_Y   = O.db.auras_offset_y;

    AURAS_MAX_DISPLAY = O.db.auras_important_max_display;

    GLOW_ENABLED = O.db.auras_important_glow_enabled;
    GLOW_TYPE    = O.db.auras_important_glow_type;
    GLOW_COLOR    = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.auras_important_glow_color[1];
    GLOW_COLOR[2] = O.db.auras_important_glow_color[2];
    GLOW_COLOR[3] = O.db.auras_important_glow_color[3];
    GLOW_COLOR[4] = O.db.auras_important_glow_color[4] or 1;

    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_important_border_color[1];
    BORDER_COLOR[2] = O.db.auras_important_border_color[2];
    BORDER_COLOR[3] = O.db.auras_important_border_color[3];
    BORDER_COLOR[4] = O.db.auras_important_border_color[4] or 1;

    S_UpdateFontObject(StripesAurasImportantCooldownFont, O.db.auras_important_cooldown_font_value, O.db.auras_important_cooldown_font_size, O.db.auras_important_cooldown_font_flag, O.db.auras_important_cooldown_font_shadow);
    S_UpdateFontObject(StripesAurasImportantCountFont, O.db.auras_important_count_font_value, O.db.auras_important_count_font_size, O.db.auras_important_count_font_flag, O.db.auras_important_count_font_shadow);
    S_UpdateFontObject(StripesAurasImportantCasterFont, O.db.auras_important_castername_font_value, O.db.auras_important_castername_font_size, O.db.auras_important_castername_font_flag, O.db.auras_important_castername_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', function(unitframe)
        if unitframe.AurasImportant then
            unitframe.AurasImportant:UpdateAnchor();
        end
    end);
end