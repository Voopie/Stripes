local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local ipairs, tonumber, math_max, table_wipe, table_sort, bit_band = ipairs, tonumber, math.max, wipe, table.sort, bit.band;

-- Wow API
local UnitIsUnit, CooldownFrame_Set, AuraUtil_ForEachAura, AuraUtil_ShouldSkipAuraUpdate = UnitIsUnit, CooldownFrame_Set, AuraUtil.ForEachAura, AuraUtil.ShouldSkipAuraUpdate;

-- Stripes API
local ShouldShowName   = S:GetNameplateModule('Handler').ShouldShowName;
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local GetTrulySpellId, S_IsSpellKnown = U.GetTrulySpellId, U.IsSpellKnown;
local GlowStart, GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

-- Local Config
local BUFFFRAME_IS_ACTIVE, FILTER_PLAYER_ENABLED, XLIST_MODE, SPACING_X, AURAS_DIRECTION, AURAS_MAX_DISPLAY;
local DRAW_EDGE, DRAW_SWIPE;
local BORDER_COLOR_ENABLED, BORDER_HIDE;
local NAME_TEXT_POSITION_V, NAME_TEXT_OFFSET_Y;
local COUNTDOWN_ENABLED, SUPPRESS_OMNICC;
local COUNTDOWN_POINT, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y;
local COUNT_POINT, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y;
local TEXT_COOLDOWN_COLOR, TEXT_COUNT_COLOR;
local SCALE, SQUARE, BUFFFRAME_OFFSET_X, BUFFFRAME_OFFSET_Y;
local SORT_ENABLED, SORT_METHOD;
local PANDEMIC_ENABLED, PANDEMIC_COLOR;
local EXPIRE_GLOW_ENABLED, EXPIRE_GLOW_PERCENT, EXPIRE_GLOW_COLOR, EXPIRE_GLOW_TYPE;
local MASQUE_SUPPORT;
local SHOW_DEBUFFS_ON_FRIENDLY;

local DebuffTypeColor = DebuffTypeColor;

local MAX_OFFSET_Y = -9;
local PANDEMIC_PERCENT = 30;
local UPDATE_INTERVAL = 0.33;

local pandemicKnownSpells = {};

local StripesAurasModCooldownFont = CreateFont('StripesAurasModCooldownFont');
local StripesAurasModCountFont    = CreateFont('StripesAurasModCountFont');

local units = {
    ['player']  = true,
    ['pet']     = true,
    ['vehicle'] = true,
};

local blacklistAurasNameCache = {};
local whitelistAurasNameCache = {};

local function BlacklistCacheFindAuraNameById(id)
    for name, sid in pairs(blacklistAurasNameCache) do
        if sid == id then
            return name;
        end
    end
end

local function UpdateBlacklistCache()
    local name;

    for spellId, data in pairs(O.db.auras_blacklist) do
        if not data.enabled then
            name = type(spellId) == 'string' and spellId or BlacklistCacheFindAuraNameById(spellId);

            if name then
                blacklistAurasNameCache[name] = nil;
            end
        end
    end

    -- For deleted entries
    for spellName, spellId in pairs(blacklistAurasNameCache) do
        if not O.db.auras_blacklist[spellName] or not O.db.auras_blacklist[spellId] then
            blacklistAurasNameCache[spellName] = nil;
        end
    end
end

local function WhitelistCacheFindAuraNameById(id)
    for name, sid in pairs(whitelistAurasNameCache) do
        if sid == id then
            return name;
        end
    end
end

local function UpdateWhitelistCache()
    local name;

    for spellId, data in pairs(O.db.auras_whitelist) do
        if not data.enabled then
            name = type(spellId) == 'string' and spellId or WhitelistCacheFindAuraNameById(spellId);

            if name then
                whitelistAurasNameCache[name] = nil;
            end
        end
    end

    -- For deleted entries
    for spellName, spellId in pairs(whitelistAurasNameCache) do
        if not O.db.auras_whitelist[spellName] or not O.db.auras_whitelist[spellId] then
            whitelistAurasNameCache[spellName] = nil;
        end
    end
end

local function IsOnPandemic(aura)
    if not PANDEMIC_ENABLED or not COUNTDOWN_ENABLED or aura:GetParent():GetParent().data.unitType == 'SELF' then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= durationMs/100*PANDEMIC_PERCENT;
end

local function ResetPandemic(unitframe)
    if unitframe.BuffFrame and unitframe.BuffFrame.buffList then
        for _, aura in ipairs(unitframe.BuffFrame.buffList) do
            GlowStopAll(aura);

            aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
        end
    end
end

local function IsOnExpireGlow(aura)
    if not EXPIRE_GLOW_ENABLED then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= durationMs/100*EXPIRE_GLOW_PERCENT;
end

local function SortMethodFunction(a, b)
    if not a.expires or not b.expires then
        return;
    end

    if SORT_METHOD == 1 then      -- EXPIRES ASC
        return a.expires < b.expires;
    elseif SORT_METHOD == 2 then  -- EXPIRES DESC
        return a.expires > b.expires;
    end
end

local function UpdateAnchor(self)
    local unit = self:GetParent().unit;

    self:ClearAllPoints();

    if unit and ShouldShowName(self:GetParent()) then
        local offset = NAME_TEXT_POSITION_V == 1 and (self:GetParent().name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
        PixelUtil.SetPoint(self, 'BOTTOM', self:GetParent().healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
    else
        local offset = self:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and self:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(self, 'BOTTOM', self:GetParent().healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
    end

    if AURAS_DIRECTION == 1 then
        PixelUtil.SetPoint(self, 'LEFT', self:GetParent().healthBar, 'LEFT', BUFFFRAME_OFFSET_X, 0);
    elseif AURAS_DIRECTION == 2 then
        PixelUtil.SetPoint(self, 'RIGHT', self:GetParent().healthBar, 'RIGHT', BUFFFRAME_OFFSET_X, 0);
    else
        self:SetWidth(self:GetParent().healthBar:GetWidth());
    end
end

local function UpdateAuraStyle(aura, withoutMasque)
    aura.Border:SetShown(not BORDER_HIDE);

    aura:SetScale(SCALE);

    if SQUARE then
        aura:SetSize(20, 20);
        aura.Icon:SetSize(18, 18);
        aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
    else
        aura:SetSize(20, 14);
        aura.Icon:SetSize(18, 12);
        aura.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
    end

    aura.Cooldown:SetFrameStrata('HIGH');
    aura.Cooldown:SetDrawEdge(DRAW_EDGE);
    aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
    aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
    aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

    aura.Cooldown:SetCountdownFont('StripesAurasModCooldownFont');
    aura.Cooldown:GetRegions():ClearAllPoints();
    aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
    aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
    aura.Cooldown:GetRegions():SetDrawLayer('OVERLAY', 7);

    aura.CountFrame:SetFrameStrata('HIGH');
    aura.CountFrame.Count:ClearAllPoints();
    aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
    aura.CountFrame.Count:SetFontObject(StripesAurasModCountFont);
    aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);

    if not aura.Hooked then
        aura:HookScript('OnUpdate', function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed;

            if self.elapsed < UPDATE_INTERVAL then
                return;
            end

            if self.spellId and IsOnPandemic(self) then
                local flags, _, _, cc = LPS_GetSpellInfo(LPS, self.spellId);
                if not flags or not cc or not (bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0) then
                    self.spellId = GetTrulySpellId(self.spellId);

                    if self.spellId and (pandemicKnownSpells[self.spellId] or S_IsSpellKnown(self.spellId)) then
                        self.Cooldown:GetRegions():SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4]);

                        if not pandemicKnownSpells[self.spellId] then
                            pandemicKnownSpells[self.spellId] = true;
                        end
                    end
                end
            else
                self.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
            end

            if IsOnExpireGlow(self) then
                GlowStart(self, EXPIRE_GLOW_TYPE, EXPIRE_GLOW_COLOR);
            else
                GlowStopAll(self);
            end

            self.elapsed = 0;
        end);

        aura.Cooldown:HookScript('OnCooldownDone', function(self)
            GlowStopAll(self:GetParent());
        end);

        aura.Hooked = true;
    end

    if not withoutMasque then
        if MASQUE_SUPPORT and Stripes.Masque then
            Stripes.MasqueAurasGroup:RemoveButton(aura);
            Stripes.MasqueAurasGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
        end
    end
end

local function FilterShouldShowBuff(name, spellId, caster, nameplateShowPersonal, nameplateShowAll, isSelf)
    if not name then
        return false;
    end

    if XLIST_MODE == 2 then -- BLACKLIST
        if blacklistAurasNameCache[name] then
            return false;
        elseif O.db.auras_blacklist[name] and O.db.auras_blacklist[name].enabled then
            blacklistAurasNameCache[name] = spellId;
            return false;
        elseif spellId and O.db.auras_blacklist[spellId] and O.db.auras_blacklist[spellId].enabled then
            blacklistAurasNameCache[name] = spellId;
            return false;
        end
    elseif XLIST_MODE == 3 then -- WHITELIST
        if whitelistAurasNameCache[name] then
            return true;
        elseif O.db.auras_whitelist[name] and O.db.auras_whitelist[name].enabled then
            whitelistAurasNameCache[name] = spellId;
            return true;
        elseif spellId and O.db.auras_whitelist[spellId] and O.db.auras_whitelist[spellId].enabled then
            whitelistAurasNameCache[name] = spellId;
            return true;
        end

        return false;
    end

    if FILTER_PLAYER_ENABLED and not isSelf then
        return units[caster];
    else
        return nameplateShowAll or (nameplateShowPersonal and units[caster]);
    end
end

local function OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos)
    local filter;
    local showAll = false;
    local unit = unitframe.data.unit;
    local isPlayer = unitframe.data.unitType == 'SELF';
    local hostileUnit = unitframe.data.reaction and unitframe.data.reaction <= 4;

    if isPlayer then
        filter = 'HELPFUL|INCLUDE_NAME_PLATE_ONLY';
    else
        if hostileUnit then
            filter = 'HARMFUL|INCLUDE_NAME_PLATE_ONLY';
        else
            if SHOW_DEBUFFS_ON_FRIENDLY then
                filter = 'HARMFUL|RAID';
                showAll = true;
            else
                filter = 'NONE';
            end
        end
    end

    local function AuraCouldDisplayAsBuff(auraInfo)
        if not FilterShouldShowBuff(auraInfo.name, auraInfo.spellId, auraInfo.sourceUnit, auraInfo.nameplateShowPersonal, auraInfo.nameplateShowAll or showAll, isPlayer) then
            return false;
        elseif isPlayer then
            return auraInfo.isHelpful;
        elseif hostileUnit then
            return auraInfo.isHarmful;
        elseif SHOW_DEBUFFS_ON_FRIENDLY then
            return auraInfo.isHarmful and auraInfo.isRaid;
        end

        return false;
    end

    if filter ~= 'NONE' and AuraUtil_ShouldSkipAuraUpdate(isFullUpdate, updatedAuraInfos, AuraCouldDisplayAsBuff) then
        return;
    end

    unitframe.BuffFrame:UpdateBuffs(unit, filter, showAll);
end

local function UpdateBuffs(self, unit, filter, showAll)
    if not self.isActive then
        for i = 1, BUFF_MAX_DISPLAY do
            if self.buffList[i] then
                self.buffList[i]:Hide();
            else
                break;
            end
        end

        return;
    end

    self.unit   = unit;
    self.filter = filter;

    self:UpdateAnchor();

    local isSelf = self:GetParent().data.unitType == 'SELF';

    if filter == 'NONE' then
        for _, buff in ipairs(self.buffList) do
            buff:Hide();
        end
    else
        local buffIndex = 1;
        local index = 1;
        local _, name, texture, count, debuffType, duration, expirationTime, caster, nameplateShowPersonal, spellId, nameplateShowAll;
        local aura;

        AuraUtil_ForEachAura(unit, filter, BUFF_MAX_DISPLAY, function(...)
            name, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = ...;

            if FilterShouldShowBuff(name, spellId, caster, nameplateShowPersonal, nameplateShowAll or showAll, isSelf) then
                aura = self.buffList[buffIndex];

                if aura and aura.Cooldown.noCooldownCount == nil then
                    aura.needUpdate = true;
                end

                if not aura then
                    aura = CreateFrame('Frame', nil, self, 'NameplateBuffButtonTemplate');
                    aura:SetMouseClickEnabled(false);
                    aura.layoutIndex = buffIndex;

                    UpdateAuraStyle(aura);
                    aura.needUpdate = nil;

                    self.buffList[buffIndex] = aura;
                end

                if aura.needUpdate then
                    UpdateAuraStyle(aura);
                    aura.needUpdate = nil;
                end

                aura:SetID(index);

                aura.spellId = spellId;
                aura.expirationTime = expirationTime;

                aura.Icon:SetTexture(texture);

                if count > 1 then
                    aura.CountFrame.Count:SetText(count);
                    aura.CountFrame.Count:Show();
                else
                    aura.CountFrame.Count:Hide();
                end

                CooldownFrame_Set(aura.Cooldown, expirationTime - duration, duration, duration > 0, DRAW_EDGE);

                if BORDER_COLOR_ENABLED then
                    if debuffType then
                        aura.Border:SetColorTexture(DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b, 1);
                    else
                        aura.Border:SetColorTexture(0, 0, 0, 1);
                    end
                else
                    aura.Border:SetColorTexture(0, 0, 0, 1);
                end

                aura:Show();

                buffIndex = buffIndex + 1;
            end

            index = index + 1;

            return buffIndex > AURAS_MAX_DISPLAY;
        end);

        for i = buffIndex, BUFF_MAX_DISPLAY do
            if self.buffList[i] then
                self.buffList[i]:Hide();
            else
                break;
            end
        end

        if buffIndex > 1 then
            if SORT_ENABLED and self:GetParent().data.unitType ~= 'SELF' then
                local unitframe = self:GetParent();

                if not unitframe.SortBuffs then
                    unitframe.SortBuffs = {};
                else
                    table_wipe(unitframe.SortBuffs);
                end

                for sBuffIndex, sAura in ipairs(self.buffList) do
                    if self.buffList[sBuffIndex]:IsShown() then
                        unitframe.SortBuffs[sBuffIndex]           = unitframe.SortBuffs[sBuffIndex] or {};
                        unitframe.SortBuffs[sBuffIndex].buffIndex = sBuffIndex;
                        unitframe.SortBuffs[sBuffIndex].expires   = tonumber(sAura.expirationTime) or 0;
                    end
                end

                if #unitframe.SortBuffs > 0 then
                    table_sort(unitframe.SortBuffs, SortMethodFunction);

                    local firstBuffIndex, lastBuff;

                    for i, data in ipairs(unitframe.SortBuffs) do
                        if self.buffList[data.buffIndex] then
                            self.buffList[data.buffIndex]:ClearAllPoints();

                            if AURAS_DIRECTION == 1 then
                                self.buffList[data.buffIndex]:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                            elseif AURAS_DIRECTION == 2 then
                                self.buffList[data.buffIndex]:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                            else
                                if i == 1 then
                                    firstBuffIndex = data.buffIndex;
                                end

                                self.buffList[firstBuffIndex]:SetPoint('TOP', -(self.buffList[firstBuffIndex]:GetWidth()/2)*(i-1), 0);

                                if i > 1 and firstBuffIndex ~= data.buffIndex then
                                    if lastBuff then
                                        self.buffList[data.buffIndex]:SetPoint('TOPLEFT', lastBuff, 'TOPRIGHT', SPACING_X, 0);
                                        lastBuff = self.buffList[data.buffIndex];
                                    else
                                        self.buffList[data.buffIndex]:SetPoint('TOPLEFT', self.buffList[firstBuffIndex], 'TOPRIGHT', SPACING_X, 0);
                                        lastBuff = self.buffList[data.buffIndex];
                                    end
                                end
                            end
                        end
                    end
                end
            else
                for i = 1, buffIndex - 1 do
                    self.buffList[i]:ClearAllPoints();

                    if AURAS_DIRECTION == 1 then
                        self.buffList[i]:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                    elseif AURAS_DIRECTION == 2 then
                        self.buffList[i]:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                    else
                        self.buffList[1]:SetPoint('TOP', -(self.buffList[1]:GetWidth()/2)*(i-1), 0);

                        if i > 1 then
                            self.buffList[i]:SetPoint('TOPLEFT', self.buffList[i - 1], 'TOPRIGHT', SPACING_X, 0);
                        end
                    end
                end
            end
        end
    end
end

local function Update(unitframe, isFullUpdate, updatedAuraInfos)
    unitframe.BuffFrame.spacing        = SPACING_X;
    unitframe.BuffFrame.isActive       = BUFFFRAME_IS_ACTIVE;
    unitframe.BuffFrame.UpdateAnchor   = UpdateAnchor;
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;
    unitframe.BuffFrame.UpdateBuffs    = UpdateBuffs;

    OnUnitAuraUpdate(unitframe, isFullUpdate, updatedAuraInfos);
end

local function UpdateStyle(unitframe)
    for _, aura in ipairs(unitframe.BuffFrame.buffList) do
        if Stripes.Masque then
            if MASQUE_SUPPORT then
                Stripes.MasqueAurasGroup:RemoveButton(aura);
                Stripes.MasqueAurasGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);

                aura.Border:SetDrawLayer('BACKGROUND');
            else
                Stripes.MasqueAurasGroup:RemoveButton(aura);

                aura.Border:SetColorTexture(0, 0, 0, 1);
                aura.Border:SetDrawLayer('BACKGROUND');

                aura.Icon:SetDrawLayer('ARTWORK');

                aura.Cooldown:ClearAllPoints();
                aura.Cooldown:SetAllPoints();
            end
        end

        UpdateAuraStyle(aura, true);
    end
end

function Module:UnitAdded(unitframe)
    if unitframe.data.unitType == 'SELF' then
        ResetPandemic(unitframe);
    end

    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    ResetPandemic(unitframe);
end

function Module:UnitAura(unitframe, isFullUpdate, updatedAuraInfos)
    Update(unitframe, isFullUpdate, updatedAuraInfos);
end

function Module:Update(unitframe)
    ResetPandemic(unitframe);

    Update(unitframe);

    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasGroup:ReSkin();
    end

    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    BUFFFRAME_IS_ACTIVE   = O.db.auras_is_active;
    FILTER_PLAYER_ENABLED = O.db.auras_filter_player_enabled;
    XLIST_MODE            = O.db.auras_xlist_mode;

    SPACING_X         = O.db.auras_spacing_x or 4;
    AURAS_DIRECTION   = O.db.auras_direction;
    AURAS_MAX_DISPLAY = O.db.auras_max_display;

    DRAW_EDGE  = O.db.auras_draw_edge;
    DRAW_SWIPE = O.db.auras_draw_swipe;

    BORDER_HIDE          = O.db.auras_border_hide;
    BORDER_COLOR_ENABLED = O.db.auras_border_color_enabled;
    COUNTDOWN_ENABLED    = O.db.auras_countdown_enabled;
    NAME_TEXT_POSITION_V = O.db.name_text_position_v;
    NAME_TEXT_OFFSET_Y   = O.db.name_text_offset_y;
    SUPPRESS_OMNICC      = O.db.auras_omnicc_suppress;

    COUNTDOWN_POINT          = O.Lists.frame_points[O.db.auras_cooldown_point] or 'TOPLEFT';
    COUNTDOWN_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_cooldown_relative_point] or 'TOPLEFT';
    COUNTDOWN_OFFSET_X       = O.db.auras_cooldown_offset_x;
    COUNTDOWN_OFFSET_Y       = O.db.auras_cooldown_offset_y;

    COUNT_POINT          = O.Lists.frame_points[O.db.auras_count_point] or 'BOTTOMRIGHT';
    COUNT_RELATIVE_POINT = O.Lists.frame_points[O.db.auras_count_relative_point] or 'BOTTOMRIGHT';
    COUNT_OFFSET_X       = O.db.auras_count_offset_x;
    COUNT_OFFSET_Y       = O.db.auras_count_offset_y;

    SCALE  = O.db.auras_scale;
    SQUARE = O.db.auras_square;

    BUFFFRAME_OFFSET_X = O.db.auras_offset_x;
    BUFFFRAME_OFFSET_Y = O.db.auras_offset_y;

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_cooldown_color[4] or 1;

    TEXT_COUNT_COLOR    = TEXT_COUNT_COLOR or {};
    TEXT_COUNT_COLOR[1] = O.db.auras_count_color[1];
    TEXT_COUNT_COLOR[2] = O.db.auras_count_color[2];
    TEXT_COUNT_COLOR[3] = O.db.auras_count_color[3];
    TEXT_COUNT_COLOR[4] = O.db.auras_count_color[4] or 1;

    SORT_ENABLED = O.db.auras_sort_enabled;
    SORT_METHOD  = O.db.auras_sort_method;

    PANDEMIC_ENABLED  = O.db.auras_pandemic_enabled;

    PANDEMIC_COLOR    = PANDEMIC_COLOR or {};
    PANDEMIC_COLOR[1] = O.db.auras_pandemic_color[1];
    PANDEMIC_COLOR[2] = O.db.auras_pandemic_color[2];
    PANDEMIC_COLOR[3] = O.db.auras_pandemic_color[3];
    PANDEMIC_COLOR[4] = O.db.auras_pandemic_color[4] or 1;

    EXPIRE_GLOW_ENABLED  = O.db.auras_expire_glow_enabled;
    EXPIRE_GLOW_PERCENT  = O.db.auras_expire_glow_percent;
    EXPIRE_GLOW_COLOR    = EXPIRE_GLOW_COLOR or {};
    EXPIRE_GLOW_COLOR[1] = O.db.auras_expire_glow_color[1];
    EXPIRE_GLOW_COLOR[2] = O.db.auras_expire_glow_color[2];
    EXPIRE_GLOW_COLOR[3] = O.db.auras_expire_glow_color[3];
    EXPIRE_GLOW_COLOR[4] = O.db.auras_expire_glow_color[4] or 1;
    EXPIRE_GLOW_TYPE     = O.db.auras_expire_glow_type;

    MASQUE_SUPPORT = O.db.auras_masque_support;

    SHOW_DEBUFFS_ON_FRIENDLY = O.db.auras_show_debuffs_on_friendly;

    UpdateFontObject(StripesAurasModCooldownFont, O.db.auras_cooldown_font_value, O.db.auras_cooldown_font_size, O.db.auras_cooldown_font_flag, O.db.auras_cooldown_font_shadow);
    UpdateFontObject(StripesAurasModCountFont, O.db.auras_count_font_value, O.db.auras_count_font_size, O.db.auras_count_font_flag, O.db.auras_count_font_shadow);

    UpdateBlacklistCache();
    UpdateWhitelistCache();
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    table_wipe(pandemicKnownSpells);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
end