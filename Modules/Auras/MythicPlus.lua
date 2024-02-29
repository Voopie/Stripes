local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Auras_MythicPlus');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local math_max = math.max;

-- WoW API
local CooldownFrame_Set, AuraUtil_ForEachAura = CooldownFrame_Set, AuraUtil.ForEachAura;

-- Stripes API
local ShouldShowName   = Stripes.ShouldShowName;
local UpdateFontObject = Stripes.UpdateFontObject;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local SCALE, SQUARE, BUFFFRAME_OFFSET_Y;
local OFFSET_X, OFFSET_Y;
local BORDER_HIDE, BORDER_COLOR;
local MASQUE_SUPPORT;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SPACING_X;
local DRAW_EDGE, DRAW_SWIPE;
local AURAS_DIRECTION, AURAS_MAX_DISPLAY;
local HELPFUL_SHOW_ALL;

local StripesAurasMythicPlusCooldownFont = CreateFont('StripesAurasMythicPlusCooldownFont');
local StripesAurasMythicPlusCountFont    = CreateFont('StripesAurasMythicPlusCountFont');

local HelpfulExceptionList = {
    [206150] = true, -- Challenger's Might
};

local HelpfulList = {
    [226510] = true, -- Mythic Plus Affix: Sanguine
    [209859] = true, -- Mythic Plus Affix: Bolstering
    [343502] = true, -- Mythic Plus Affix: Inspiring
    [343503] = true, -- Mythic Plus Affix: Inspiring (Inspired)
    [228318] = true, -- Mythic Plus Affix: Raging
    [343553] = true, -- Mythic Plus Affix: All-Consuming Spite (Spiteful)
    [373011] = true, -- Affix SL S4: Disguised
    [373785] = true, -- Affix SL S4: Disguised

    -- Mists of Pandaria
    [113315] = true, -- Temple of the Jade Serpent (Intensity)
    [113309] = true, -- Temple of the Jade Serpent (Ultimate Power)

    -- BfA
    [263246] = true, -- Temple of Sethralis: Lightning Shield
    [257597] = true, -- MOTHERLODE: Azerite Infusion
    [257042] = true, -- Siege of Boralus: Feral Bond
    [260805] = true, -- Waycrest Manor: Focusing Iris
    [264027] = true, -- Waycrest Manor: Warding Candles
    [269935] = true, -- King's Rest: Minion of Zul
    [257402] = true, -- Freehold: Harlan Sweete - Loaded Dice: All Hands!
    [257458] = true, -- Freehold: Harlan Sweete - Loaded Dice: Man-O-War
    [265091] = true, -- The Underrot: Devout Blood Priest - Gift of G'huun

    -- Legion
    [190225] = true, -- Halls of Valor (Enrage)
    [397410] = true, -- Halls of Valor (Enraged Regeneration)
    [225101] = true, -- Court of Stars (Power Charge)
    [209033] = true, -- Court of Stars (Fortification)

    -- Shadowlands
    [324085] = true, -- Theater of Pain (Enrage)
    [333241] = true, -- Theater of Pain (Raging Tantrum)
    [331510] = true, -- Theater of Pain (Death Wish)
    [333227] = true, -- De Other Side (Undying Rage)
    [334800] = true, -- De Other Side (Enrage)
    [321220] = true, -- Sanguine Depths (Frenzy)
    [322569] = true, -- Mists of Tirna Scithe (Hand of Thros)
    [326450] = true, -- Halls of Atonement (Loyal Beasts)
    [328015] = true, -- Plaguefall (Wonder Grow)
    [343470] = true, -- The Necrotic Wake (Skeletal Marauder)
    [355147] = true, -- Tazavesh: So'leah's Gambit (Fish Invigoration)

    -- Dragonflight,
    [385063] = true, -- Ruby Life Pools (Burning Ambition)
    [392454] = true, -- Ruby Life Pools (Burning Veins)
    [387596] = true, -- The Nokhud Offensive (Swift Wind)
    [396798] = true, -- The Nokhud Offensive (Swift Wind)
    [383067] = true, -- The Nokhud Offensive (Raging Kin)
    [389686] = true, -- The Azure Vault (Arcane Fury)
    [378065] = true, -- The Azure Vault (Mage Hunter's Fervor)
    [374778] = true, -- The Azure Vault (Brilliant Scales)
};

local HarmfulList = {
    [323059] = true, -- Mists of Tirna Scithe (Droman's Wrath)
    [340191] = true, -- Mists of Tirna Scithe (Rejuvenating Radiance)
};

local PlayerState = D.Player.State;
local filterHelpful = 'HELPFUL';
local filterHarmful = 'HARMFUL';

local MAX_OFFSET_Y = -9;

local function CreateBuffFrame(unitframe)
    if unitframe.AurasMythicPlus then
        return;
    end

    local frame = CreateFrame('Frame', '$parentAurasMythicPlus', unitframe);
    frame:SetPoint('RIGHT', unitframe.healthBar, 'RIGHT', 0, 0);
    frame:SetHeight(14);

    frame.buffList = {};
    frame.compactList = {};

    frame.AuraComparator = function(a, b)
        return AuraUtil.DefaultAuraCompare(a, b);
    end

    frame.UpdateAnchor = function(self)
        self:ClearAllPoints();

        local uf = self:GetParent();
        local unit = uf.data.unit or uf.unit;

        if unit and ShouldShowName(uf) then
            local offset = NAME_TEXT_POSITION_V == 1 and (uf.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
            self:SetPoint('BOTTOM', uf.healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        else
            local offset = uf.BuffFrame:GetBaseYOffset() + (uf.data.isTarget and uf.BuffFrame:GetTargetYOffset() or 0.0);
            self:SetPoint('BOTTOM', uf.healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y + OFFSET_Y);
        end

        if AURAS_DIRECTION == 1 then
            self:SetPoint('LEFT', uf.healthBar, 'LEFT', OFFSET_X, 0);
        elseif AURAS_DIRECTION == 2 then
            self:SetPoint('RIGHT', uf.healthBar, 'RIGHT', OFFSET_X, 0);
        else
            self:SetWidth(uf.healthBar:GetWidth());
        end
    end

    frame.ShouldShowBuff = function(self, aura, isHelpful)
        if not aura or not aura.spellId then
            return;
        end

        if isHelpful then
            if HELPFUL_SHOW_ALL then
                return not HelpfulExceptionList[aura.spellId];
            else
                return HelpfulList[aura.spellId];
            end
        elseif not isHelpful and HarmfulList[aura.spellId] then
            return true;
        end

        return false;
    end

    frame.ParseAllAuras = function(self)
        if self.auras == nil then
            self.auras = TableUtil.CreatePriorityTable(self.AuraComparator, TableUtil.Constants.AssociativePriorityTable);
        else
            self.auras:Clear();
        end

        local function HandleAuraHelpful(aura)
            if self:ShouldShowBuff(aura, true) then
                self.auras[aura.auraInstanceID] = aura;
            end

            return false;
        end

        local function HandleAuraHarmful(aura)
            if self:ShouldShowBuff(aura, false) then
                self.auras[aura.auraInstanceID] = aura;
            end

            return false;
        end

        local batchCount = nil;
        local usePackedAura = true;

        AuraUtil_ForEachAura(self.unit, filterHelpful, batchCount, HandleAuraHelpful, usePackedAura);
        AuraUtil_ForEachAura(self.unit, filterHarmful, batchCount, HandleAuraHarmful, usePackedAura);
    end

    frame.UpdateBuffs = function(self, unit, unitAuraUpdateInfo)
        local uf = self:GetParent();

        unit = unit or uf.data.unit;

        if not ENABLED or not PlayerState.inChallenge or not unit or uf.data.isPersonal or uf.data.isUnimportantUnit then
            self:Hide();
            return;
        end

        local filterString = filterHelpful;

        local previousFilter = self.filter;
        local previousUnit   = self.unit;

        self.unit   = unit;
        self.filter = filterHelpful;

        local aurasChanged = false;
        if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filterString ~= previousFilter then
            self:ParseAllAuras();
            aurasChanged = true;
        else
            if unitAuraUpdateInfo.addedAuras ~= nil then
                for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                    if self:ShouldShowBuff(aura, aura.isHelpful) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filterString) then
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

        wipe(unitframe.AurasMythicPlus.compactList);

        self.auras:Iterate(function(auraInstanceID, aura)
            local aCount = aura.applications == 0 and 1 or aura.applications;

            if not unitframe.AurasMythicPlus.compactList[aura.spellId] then
                unitframe.AurasMythicPlus.compactList[aura.spellId] = {
                    spellId        = aura.spellId,
                    name           = aura.name,
                    icon           = aura.icon,
                    applications   = aCount,
                    duration       = aura.duration,
                    expirationTime = aura.expirationTime,
                    auraInstanceID = aura.auraInstanceID,
                    isHelpful      = aura.isHelpful,
                };
            else
                unitframe.AurasMythicPlus.compactList[aura.spellId].applications   = unitframe.AurasMythicPlus.compactList[aura.spellId].applications + aCount;
                unitframe.AurasMythicPlus.compactList[aura.spellId].duration       = aura.duration;
                unitframe.AurasMythicPlus.compactList[aura.spellId].expirationTime = aura.expirationTime;
            end
        end);

        for _, aura in pairs(unitframe.AurasMythicPlus.compactList) do
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

                buff.Cooldown:SetDrawEdge(DRAW_EDGE);
                buff.Cooldown:SetDrawSwipe(DRAW_SWIPE);
                buff.Cooldown:SetCountdownFont('StripesAurasMythicPlusCooldownFont');
                buff.Cooldown:GetRegions():ClearAllPoints();
                buff.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, buff.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
                buff.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
                buff.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
                buff.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

                buff.CountFrame.Count:ClearAllPoints();
                buff.CountFrame.Count:SetPoint(COUNT_POINT, buff.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
                buff.CountFrame.Count:SetFontObject(StripesAurasMythicPlusCountFont);
                buff.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

                if MASQUE_SUPPORT and Stripes.Masque then
                    Stripes.MasqueAurasMythicGroup:RemoveButton(buff);
                    Stripes.MasqueAurasMythicGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);
                end

                self.buffList[buffIndex] = buff;
            end

            buff.layoutIndex    = buffIndex;
            buff.spellID        = aura.spellId;
            buff.expirationTime = aura.expirationTime;
            buff.auraInstanceID = aura.auraInstanceID;
            buff.isBuff         = aura.isHelpful;

            buff:ClearAllPoints();

            if AURAS_DIRECTION == 1 then
                buff:SetPoint('TOPLEFT', (buffIndex - 1) * (20 + SPACING_X), 0);
            elseif AURAS_DIRECTION == 2 then
                buff:SetPoint('TOPRIGHT', -((buffIndex - 1) * (20 + SPACING_X)), 0);
            else
                self.buffList[1]:SetPoint('TOP', -(buff:GetWidth() / 2) * (buffIndex - 1), 0);

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

            if aura.spellId == 343553 then
                local dur = tonumber(string.format('%.0f', unitframe.data.healthPerF / 8));
                CooldownFrame_Set(buff.Cooldown, GetTime(), dur, dur > 0, DRAW_EDGE);
            else
                CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, DRAW_EDGE);
            end

            buff:Show();

            buffIndex = buffIndex + 1;

            if buffIndex > AURAS_MAX_DISPLAY then
                break;
            end
        end

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
                    Stripes.MasqueAurasMythicGroup:RemoveButton(buff);
                    Stripes.MasqueAurasMythicGroup:AddButton(buff, { Icon = buff.Icon, Cooldown = buff.Cooldown }, 'Aura', true);

                    buff.Border:SetDrawLayer('BACKGROUND');
                else
                    Stripes.MasqueAurasMythicGroup:RemoveButton(buff);

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

    unitframe.AurasMythicPlus = frame;
end

function Module:UnitAdded(unitframe)
    CreateBuffFrame(unitframe);

    unitframe.AurasMythicPlus.spacing = SPACING_X;
    unitframe.AurasMythicPlus:UpdateBuffs();
end

function Module:UnitRemoved(unitframe)
    if unitframe.AurasMythicPlus then
        unitframe.AurasMythicPlus:Hide();
    end
end

function Module:UnitAura(unitframe, unitAuraUpdateInfo)
    unitframe.AurasMythicPlus:UpdateBuffs(unitframe.data.unit, unitAuraUpdateInfo);
end

function Module:Update(unitframe)
    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasMythicGroup:ReSkin();
    end

    unitframe.AurasMythicPlus.spacing = SPACING_X;
    unitframe.AurasMythicPlus:UpdateBuffs();
    unitframe.AurasMythicPlus:UpdateStyle();
end

function Module:UpdateLocalConfig()
    MASQUE_SUPPORT = O.db.auras_masque_support;

    ENABLED              = O.db.auras_mythicplus_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_mythicplus_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    HELPFUL_SHOW_ALL = O.db.auras_mythicplus_helpful_show_all;

    BORDER_HIDE = O.db.auras_border_hide;
    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.auras_mythicplus_border_color[1];
    BORDER_COLOR[2] = O.db.auras_mythicplus_border_color[2];
    BORDER_COLOR[3] = O.db.auras_mythicplus_border_color[3];
    BORDER_COLOR[4] = O.db.auras_mythicplus_border_color[4] or 1;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_mythicplus_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_mythicplus_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_mythicplus_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_mythicplus_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_mythicplus_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_mythicplus_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_mythicplus_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_mythicplus_count_offset_y;

    SCALE  = O.db.auras_mythicplus_scale;
    SQUARE = O.db.auras_square;

    OFFSET_X = O.db.auras_mythicplus_offset_x;
    OFFSET_Y = O.db.auras_mythicplus_offset_y;

    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_mythicplus_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_mythicplus_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_mythicplus_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_mythicplus_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_mythicplus_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_mythicplus_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_mythicplus_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_mythicplus_count_color[4] or 1;

    SPACING_X = O.db.auras_mythicplus_spacing_x or 4;

    DRAW_EDGE  = O.db.auras_mythicplus_draw_edge;
    DRAW_SWIPE = O.db.auras_mythicplus_draw_swipe;

    AURAS_DIRECTION = O.db.auras_mythicplus_direction;
    AURAS_MAX_DISPLAY = O.db.auras_mythicplus_max_display;

    UpdateFontObject(StripesAurasMythicPlusCooldownFont, O.db.auras_mythicplus_cooldown_font_value, O.db.auras_mythicplus_cooldown_font_size, O.db.auras_mythicplus_cooldown_font_flag, O.db.auras_mythicplus_cooldown_font_shadow);
    UpdateFontObject(StripesAurasMythicPlusCountFont, O.db.auras_mythicplus_count_font_value, O.db.auras_mythicplus_count_font_size, O.db.auras_mythicplus_count_font_flag, O.db.auras_mythicplus_count_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', function(unitframe)
        unitframe.AurasMythicPlus:UpdateAnchor();
    end);

    -- All-Consuming Spite (Spiteful) timer update
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateHealth', function(unitframe)
        if unitframe.data.npcId == 174773 then
            unitframe.AurasMythicPlus:UpdateBuffs();
        end
    end);
end