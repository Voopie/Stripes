local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Auras');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local ipairs, tonumber, math_max, table_wipe, table_sort, bit_band = ipairs, tonumber, math.max, wipe, table.sort, bit.band;

-- Wow API
local CooldownFrame_Set = CooldownFrame_Set;
local DebuffTypeColor = DebuffTypeColor;

-- Stripes API
local ShouldShowName   = Stripes.ShouldShowName;
local UpdateFontObject = Stripes.UpdateFontObject;
local U_GetTrulySpellId, U_IsSpellKnown = U.GetTrulySpellId, U.IsSpellKnown;
local U_GlowStart, U_GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Libraries
local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local LPS_CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local LPS_CROWD_CTRL = LPS.constants.CROWD_CTRL;

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

local MAX_OFFSET_Y = -9;
local PANDEMIC_PERCENT = 0.3;
local UPDATE_INTERVAL = 0.33;

local StripesAurasModCooldownFont = CreateFont('StripesAurasModCooldownFont');
local StripesAurasModCountFont    = CreateFont('StripesAurasModCountFont');

local playerUnits = D.PlayerUnits;

local pandemicKnownSpells = {};
local blacklistAurasNameCache = {};
local whitelistAurasNameCache = {};

local function BlacklistCacheFindAuraNameById(id)
    for name, spellId in pairs(blacklistAurasNameCache) do
        if spellId == id then
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
    for name, spellId in pairs(whitelistAurasNameCache) do
        if spellId == id then
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

local function IsAuraWhitelisted(name, spellId)
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

local function IsAuraBlacklisted(name, spellId)
    if blacklistAurasNameCache[name] then
        return true;
    elseif O.db.auras_blacklist[name] and O.db.auras_blacklist[name].enabled then
        blacklistAurasNameCache[name] = spellId;
        return true;
    elseif spellId and O.db.auras_blacklist[spellId] and O.db.auras_blacklist[spellId].enabled then
        blacklistAurasNameCache[name] = spellId;
        return true;
    end

    return false;
end

local function IsAuraOnPandemic(aura)
    if not PANDEMIC_ENABLED or not COUNTDOWN_ENABLED or aura:GetParent():GetParent().data.isPersonal then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= (durationMs * PANDEMIC_PERCENT);
end

local function ResetAllAurasPandemic(unitframe)
    if unitframe.BuffFrame and unitframe.BuffFrame.buffList then
        for _, aura in ipairs(unitframe.BuffFrame.buffList) do
            U_GlowStopAll(aura);

            aura.Cooldown.Countdown:SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
        end
    end
end

local function IsAuraOnExpireGlow(aura)
    if not EXPIRE_GLOW_ENABLED then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= (durationMs * EXPIRE_GLOW_PERCENT);
end

local function AuraComparator(a, b)
    local aExpires = a.expires or 0;
    local bExpires = b.expires or 0;

    if SORT_METHOD == 1 then      -- EXPIRES ASC
        return aExpires < bExpires;
    elseif SORT_METHOD == 2 then  -- EXPIRES DESC
        return aExpires > bExpires;
    end

    return false;
end

local function UpdateAnchor(self)
    local unitframe = self:GetParent();
    local unit = unitframe.unit or unitframe.data.unit;
    local squareOffset = SQUARE and 6 or 0;

    self:ClearAllPoints();

    if unit and ShouldShowName(unitframe) then
        local nameOffset = NAME_TEXT_POSITION_V == 1 and (unitframe.name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y)) or 0;
        PixelUtil.SetPoint(self, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 2 + nameOffset + squareOffset + BUFFFRAME_OFFSET_Y);
    else
        local buffFrameBaseYOffset = self:GetBaseYOffset();
        local buffFrameTargetYOffset = unitframe.data.isTarget and self:GetTargetYOffset() or 0;

        PixelUtil.SetPoint(self, 'BOTTOM', unitframe.healthBar, 'TOP', 0, 5 + buffFrameBaseYOffset + buffFrameTargetYOffset + squareOffset + BUFFFRAME_OFFSET_Y);
    end

    if AURAS_DIRECTION == 1 then
        PixelUtil.SetPoint(self, 'LEFT', unitframe.healthBar, 'LEFT', BUFFFRAME_OFFSET_X, 0);
    elseif AURAS_DIRECTION == 2 then
        PixelUtil.SetPoint(self, 'RIGHT', unitframe.healthBar, 'RIGHT', BUFFFRAME_OFFSET_X, 0);
    else
        self:SetWidth(unitframe.healthBar:GetWidth());
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
    aura.Cooldown.Countdown = aura.Cooldown:GetRegions();
    aura.Cooldown.Countdown:ClearAllPoints();
    aura.Cooldown.Countdown:SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
    aura.Cooldown.Countdown:SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
    aura.Cooldown.Countdown:SetDrawLayer('OVERLAY', 7);

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

            if self.spellID and IsAuraOnPandemic(self) then
                if pandemicKnownSpells[self.spellID] then
                    self.Cooldown.Countdown:SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4]);
                else
                    local flags, _, _, cc = LPS_GetSpellInfo(LPS, self.spellID);
                    local isNotCrowdControl = not (flags and cc and bit_band(flags, LPS_CROWD_CTRL) > 0 and bit_band(cc, LPS_CC_TYPES) > 0);

                    if isNotCrowdControl then
                        self.trulySpellId = U_GetTrulySpellId(self.spellID);

                        if self.trulySpellId and (pandemicKnownSpells[self.trulySpellId] or U_IsSpellKnown(self.trulySpellId)) then
                            self.Cooldown.Countdown:SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4]);

                            pandemicKnownSpells[self.spellID]      = true;
                            pandemicKnownSpells[self.trulySpellId] = true;
                        end
                    end
                end
            else
                self.Cooldown.Countdown:SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
            end

            if IsAuraOnExpireGlow(self) then
                U_GlowStart(self, EXPIRE_GLOW_TYPE, EXPIRE_GLOW_COLOR);
            else
                U_GlowStopAll(self);
            end

            self.elapsed = 0;
        end);

        aura.Cooldown:HookScript('OnCooldownDone', function(self)
            U_GlowStopAll(self:GetParent());
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

local function FilterShouldShowBuff(self, aura, forceAll, isSelf)
    if not aura or not aura.name then
        return false;
    end

    local name       = aura.name;
    local spellId    = aura.spellId;
    local sourceUnit = aura.sourceUnit;

    if XLIST_MODE == 2 then -- BLACKLIST
        local isBlacklisted = IsAuraBlacklisted(name, spellId);
        if isBlacklisted then
            return false;
        end
    elseif XLIST_MODE == 3 then -- WHITELIST
        return IsAuraWhitelisted(name, spellId) and playerUnits[sourceUnit];
    end

    if FILTER_PLAYER_ENABLED and not isSelf then
        return playerUnits[sourceUnit];
    else
        return aura.nameplateShowAll or forceAll or (aura.nameplateShowPersonal and playerUnits[sourceUnit]);
    end
end

local function ParseAllAuras(self, forceAll, isSelf)
    if self.auras == nil then
        self.auras = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
    else
        self.auras:Clear();
    end

    local function HandleAura(aura)
        if FilterShouldShowBuff(self, aura, forceAll, isSelf) then
            self.auras[aura.auraInstanceID] = aura;
        end

        return false;
    end

    local batchCount = nil;
    local usePackedAura = true;
    AuraUtil.ForEachAura(self.unit, self.filter, batchCount, HandleAura, usePackedAura);
end

local function OnUnitAuraUpdate(unitframe, unitAuraUpdateInfo)
    if unitframe.data.isUnimportantUnit then
        return;
    end

    local hostileUnit = unitframe.data.reaction and unitframe.data.reaction <= 4;

    local filter;
    local showAll = false;

    if unitframe.data.isPersonal then
        filter = 'HELPFUL|INCLUDE_NAME_PLATE_ONLY';
    else
        if hostileUnit then
            -- Reaction 4 is neutral and less than 4 becomes increasingly more hostile
            filter = 'HARMFUL|INCLUDE_NAME_PLATE_ONLY';
        else
            if SHOW_DEBUFFS_ON_FRIENDLY then
                -- Dispellable debuffs
                filter = 'HARMFUL|RAID';
                showAll = true;
            else
                filter = 'NONE';
            end
        end
    end

    unitframe.BuffFrame:UpdateBuffs(unitframe.data.unit, unitAuraUpdateInfo, filter, showAll);
end

local function UpdateBuffs(self, unit, unitAuraUpdateInfo, filter, showAll)
    if type(filter) == 'table' then
        return;
    end

    if not unit or not self.isActive or filter == 'NONE' then
        self.buffPool:ReleaseAll();
        return;
    end

    local unitframe = self:GetParent();

    local isSelf = unitframe.data.isPersonal;

    local previousFilter = self.filter;
    local previousUnit   = self.unit;

    self.unit   = unit;
    self.filter = filter;

    local aurasChanged = false;
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or unit ~= previousUnit or self.auras == nil or filter ~= previousFilter then
        ParseAllAuras(self, showAll, isSelf);
        aurasChanged = true;
    else
        if unitAuraUpdateInfo.addedAuras ~= nil then
            for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
                if FilterShouldShowBuff(self, aura, showAll, isSelf) and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, aura.auraInstanceID, filter) then
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

    self.buffPool:ReleaseAll();

    local buffIndex = 1;
    self.auras:Iterate(function(auraInstanceID, aura)
        local buff, isNew = self.buffPool:Acquire();

        buff.auraInstanceID = auraInstanceID;
        buff.isBuff         = aura.isHelpful;
        buff.layoutIndex    = buffIndex;
        buff.spellID        = aura.spellId;
        buff.expirationTime = aura.expirationTime;

        if not isNew and buff.Cooldown.noCooldownCount == nil then
            buff.needUpdate = true;
        end

        if isNew or buff.needUpdate then
            UpdateAuraStyle(buff);
            buff.needUpdate = nil;
        end

        buff.Icon:SetTexture(aura.icon);

        if aura.applications > 1 then
            buff.CountFrame.Count:SetText(aura.applications);
            buff.CountFrame.Count:Show();
        else
            buff.CountFrame.Count:Hide();
        end

        CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, DRAW_EDGE);

        if BORDER_COLOR_ENABLED then
            if aura.dispelName and DebuffTypeColor[aura.dispelName]then
                local debuffColor = DebuffTypeColor[aura.dispelName];
                buff.Border:SetColorTexture(debuffColor.r, debuffColor.g, debuffColor.b, 1);
            else
                buff.Border:SetColorTexture(0, 0, 0, 1);
            end
        else
            buff.Border:SetColorTexture(0, 0, 0, 1);
        end

        buff:Show();

        buffIndex = buffIndex + 1;

        return buffIndex >= AURAS_MAX_DISPLAY;
    end);

    if buffIndex > 1 then
        if SORT_ENABLED and not isSelf then
            if not unitframe.SortBuffs then
                unitframe.SortBuffs = {};
            else
                table_wipe(unitframe.SortBuffs);
            end

            local activeCount = 1;
            for buff in self.buffPool:EnumerateActive() do
                unitframe.SortBuffs[activeCount]           = unitframe.SortBuffs[activeCount] or {};
                unitframe.SortBuffs[activeCount].buffIndex = activeCount;
                unitframe.SortBuffs[activeCount].expires   = tonumber(buff.expirationTime) or 0;
                unitframe.SortBuffs[activeCount].buff      = buff;

                activeCount = activeCount + 1;
            end

            if #unitframe.SortBuffs > 0 then
                table_sort(unitframe.SortBuffs, AuraComparator);

                local firstBuffIndex, lastBuff;

                for i, data in ipairs(unitframe.SortBuffs) do
                    if data.buff then
                        data.buff:ClearAllPoints();

                        if AURAS_DIRECTION == 1 then
                            data.buff:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                        elseif AURAS_DIRECTION == 2 then
                            data.buff:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                        else
                            if i == 1 then
                                firstBuffIndex = data.buffIndex;
                            end

                            unitframe.SortBuffs[firstBuffIndex]:SetPoint('TOP', -(unitframe.SortBuffs[firstBuffIndex]:GetWidth() * 0.5) * (i - 1), 0);

                            if i > 1 and firstBuffIndex ~= data.buffIndex then
                                if lastBuff then
                                    data.buff:SetPoint('TOPLEFT', lastBuff, 'TOPRIGHT', SPACING_X, 0);
                                    lastBuff = data.buff;
                                else
                                    data.buff:SetPoint('TOPLEFT', unitframe.SortBuffs[firstBuffIndex], 'TOPRIGHT', SPACING_X, 0);
                                    lastBuff = data.buff;
                                end
                            end
                        end
                    end
                end
            end
        else
            local activeCount = 1;
            local firstBuffIndex, firstBuff, lastBuff;

            for buff in self.buffPool:EnumerateActive() do
                buff:ClearAllPoints();

                if AURAS_DIRECTION == 1 then
                    buff:SetPoint('TOPLEFT', (activeCount - 1) * (20 + SPACING_X), 0);
                elseif AURAS_DIRECTION == 2 then
                    buff:SetPoint('TOPRIGHT', -((activeCount - 1) * (20 + SPACING_X)), 0);
                else
                    if activeCount == 1 then
                        firstBuff = buff;
                        firstBuffIndex = buff.layoutIndex;
                    end

                    firstBuff:SetPoint('TOP', -(firstBuff:GetWidth() * 0.5) * (activeCount - 1), 0);

                    if activeCount > 1 and firstBuffIndex ~= buff.layoutIndex then
                        if lastBuff then
                            buff:SetPoint('TOPLEFT', lastBuff, 'TOPRIGHT', SPACING_X, 0);
                            lastBuff = buff;
                        else
                            buff:SetPoint('TOPLEFT', firstBuff, 'TOPRIGHT', SPACING_X, 0);
                            lastBuff = buff;
                        end
                    end
                end

                activeCount = activeCount + 1;
            end
        end
    end
end

local function Update(unitframe, unitAuraUpdateInfo)
    unitframe.BuffFrame.spacing        = SPACING_X;
    unitframe.BuffFrame.isActive       = BUFFFRAME_IS_ACTIVE;
    unitframe.BuffFrame.UpdateAnchor   = UpdateAnchor;
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;
    unitframe.BuffFrame.ParseAllAuras  = ParseAllAuras;
    unitframe.BuffFrame.UpdateBuffs    = UpdateBuffs;

    OnUnitAuraUpdate(unitframe, unitAuraUpdateInfo);
end

local function UpdateStyle(unitframe)
    for aura in unitframe.BuffFrame.buffPool:EnumerateActive() do
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

    for _, aura in unitframe.BuffFrame.buffPool:EnumerateInactive() do
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
    if unitframe.data.isPersonal then
        ResetAllAurasPandemic(unitframe);
    end

    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    ResetAllAurasPandemic(unitframe);
end

function Module:UnitAura(unitframe, unitAuraUpdateInfo)
    Update(unitframe, unitAuraUpdateInfo);
end

function Module:Update(unitframe)
    ResetAllAurasPandemic(unitframe);

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
    EXPIRE_GLOW_PERCENT  = (O.db.auras_expire_glow_percent or 20)/100;
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