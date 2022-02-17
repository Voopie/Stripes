local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local select, ipairs, math_max, table_wipe, table_sort, bit_band = select, ipairs, math.max, wipe, table.sort, bit.band;

-- Wow API
local UnitIsUnit, UnitAura, GetCVarBool, CooldownFrame_Set, AuraUtil_ForEachAura = UnitIsUnit, UnitAura, GetCVarBool, CooldownFrame_Set, AuraUtil.ForEachAura;

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
local BUFFFRAME_IS_ACTIVE, FILTER_PLAYER_ENABLED, BLACKLIST_ENABLED, SPACING_X, AURAS_DIRECTION, AURAS_MAX_DISPLAY;
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

local DebuffTypeColor = DebuffTypeColor;

local CVAR_RESOURCE_ON_TARGET = 'nameplateResourceOnTarget';
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

local function CacheFindAuraNameById(id)
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
            name = type(spellId) == 'string' and spellId or CacheFindAuraNameById(spellId);

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
            aura.spellId = nil;
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

local function FilterShouldShowBuff(self, name, spellId, caster, nameplateShowPersonal, nameplateShowAll)
    if not name then
        return false;
    end

    if BLACKLIST_ENABLED then
        if blacklistAurasNameCache[name] then
            return false;
        end

        if O.db.auras_blacklist[name] and O.db.auras_blacklist[name].enabled then
            blacklistAurasNameCache[name] = spellId;
            return false;
        end

        if spellId and O.db.auras_blacklist[spellId] and O.db.auras_blacklist[spellId].enabled then
            blacklistAurasNameCache[name] = spellId;
            return false;
        end
    end

    if FILTER_PLAYER_ENABLED and self:GetParent().data.unitType ~= 'SELF' then
        return units[caster];
    else
        return nameplateShowAll or (nameplateShowPersonal and units[caster]);
    end
end

local function UpdateAnchor(self)
    local unit = self:GetParent().unit;

    self:ClearAllPoints();

    if unit and ShouldShowName(self:GetParent()) then
        local showMechanicOnTarget = GetCVarBool(CVAR_RESOURCE_ON_TARGET) and 10 or 0;
        local offset = NAME_TEXT_POSITION_V == 1 and (self:GetParent().name:GetLineHeight() + math_max(NAME_TEXT_OFFSET_Y, MAX_OFFSET_Y) + showMechanicOnTarget) or showMechanicOnTarget;
        PixelUtil.SetPoint(self, 'BOTTOM', self:GetParent().healthBar, 'TOP', 0, 2 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
    else
        local offset = self:GetBaseYOffset() + ((unit and UnitIsUnit(unit, 'target')) and self:GetTargetYOffset() or 0.0);
        PixelUtil.SetPoint(self, 'BOTTOM', self:GetParent().healthBar, 'TOP', 0, 5 + offset + (SQUARE and 6 or 0) + BUFFFRAME_OFFSET_Y);
    end

    PixelUtil.SetPoint(self, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', self:GetParent().healthBar, AURAS_DIRECTION == 1 and 'LEFT' or 'RIGHT', BUFFFRAME_OFFSET_X, 0);
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

            if FilterShouldShowBuff(self, name, spellId, caster, nameplateShowPersonal, nameplateShowAll or showAll) then
                aura = self.buffList[buffIndex];

                if not aura then
                    aura = CreateFrame('Frame', nil, self, 'NameplateBuffButtonTemplate');
                    aura:SetMouseClickEnabled(false);
                    aura.layoutIndex = buffIndex;

                    if BORDER_COLOR_ENABLED then
                        if debuffType then
                            aura.Border:SetColorTexture(DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b, 1);
                        else
                            aura.Border:SetColorTexture(0, 0, 0, 1);
                        end
                    else
                        aura.Border:SetColorTexture(0, 0, 0, 1);
                    end

                    aura.Border:SetShown(not BORDER_HIDE);

                    aura:SetScale(SCALE);

                    if SQUARE then
                        aura:SetSize(20, 20);
                        aura.Icon:SetSize(18, 18);
                        aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
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

                    if MASQUE_SUPPORT and Stripes.Masque then
                        Stripes.MasqueAurasGroup:RemoveButton(aura);
                        Stripes.MasqueAurasGroup:AddButton(aura, { Icon = aura.Icon, Cooldown = aura.Cooldown }, 'Aura', true);
                    end

                    self.buffList[buffIndex] = aura;
                end

                aura:SetID(index);
                aura.spellId = spellId;

                aura.Icon:SetTexture(texture);

                if count > 1 then
                    aura.CountFrame.Count:SetText(count);
                    aura.CountFrame.Count:Show();
                else
                    aura.CountFrame.Count:Hide();
                end

                CooldownFrame_Set(aura.Cooldown, expirationTime - duration, duration, duration > 0, DRAW_EDGE);

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

                local sExpirationTime;
                for sBuffIndex, sAura in ipairs(self.buffList) do
                    if self.buffList[sBuffIndex]:IsShown() then
                        sExpirationTime = select(6, UnitAura(self.unit, sAura:GetID(), self.filter));

                        unitframe.SortBuffs[sBuffIndex]           = unitframe.SortBuffs[sBuffIndex] or {};
                        unitframe.SortBuffs[sBuffIndex].buffIndex = sBuffIndex;
                        unitframe.SortBuffs[sBuffIndex].expires   = tonumber(sExpirationTime) or 0;
                    end
                end

                if #unitframe.SortBuffs > 0 then
                    table_sort(unitframe.SortBuffs, SortMethodFunction);

                    for i, data in ipairs(unitframe.SortBuffs) do
                        if self.buffList[data.buffIndex] then
                            self.buffList[data.buffIndex]:ClearAllPoints();

                            if AURAS_DIRECTION == 1 then
                                self.buffList[data.buffIndex]:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                            else
                                self.buffList[data.buffIndex]:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                            end
                        end
                    end
                end
            else
                for i = 1, buffIndex - 1 do
                    self.buffList[i]:ClearAllPoints();

                    if AURAS_DIRECTION == 1 then
                        self.buffList[i]:SetPoint('TOPLEFT', (i - 1) * (20 + SPACING_X), 0);
                    else
                        self.buffList[i]:SetPoint('TOPRIGHT', -((i - 1) * (20 + SPACING_X)), 0);
                    end
                end
            end
        end
    end
end

local function Update(unitframe)
    unitframe.BuffFrame.UpdateAnchor   = UpdateAnchor;
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;
    unitframe.BuffFrame.UpdateBuffs    = UpdateBuffs;
    unitframe.BuffFrame.spacing        = SPACING_X;
    unitframe.BuffFrame.isActive       = BUFFFRAME_IS_ACTIVE;

    if unitframe.BuffFrame.unit and unitframe.BuffFrame.filter then
        unitframe.BuffFrame:UpdateBuffs(unitframe.BuffFrame.unit, unitframe.BuffFrame.filter, unitframe.data.unitType == 'FRIENDLY_PLAYER');
    end
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

        aura:SetScale(SCALE);

        aura.Border:SetShown(not BORDER_HIDE);

        if SQUARE then
            aura:SetSize(20, 20);
            aura.Icon:SetSize(18, 18);
            aura.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);
        else
            aura:SetSize(20, 14);
            aura.Icon:SetSize(18, 12);
            aura.Icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
        end

        aura.Cooldown:SetDrawEdge(DRAW_EDGE);
        aura.Cooldown:SetDrawSwipe(DRAW_SWIPE);
        aura.Cooldown:SetHideCountdownNumbers(not COUNTDOWN_ENABLED);
        aura.Cooldown.noCooldownCount = SUPPRESS_OMNICC;

        aura.Cooldown:GetRegions():ClearAllPoints();
        aura.Cooldown:GetRegions():SetPoint(COUNTDOWN_POINT, aura.Cooldown, COUNTDOWN_RELATIVE_POINT, COUNTDOWN_OFFSET_X, COUNTDOWN_OFFSET_Y);
        aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
        aura.Cooldown:GetRegions():SetDrawLayer('OVERLAY', 7);

        aura.CountFrame.Count:ClearAllPoints();
        aura.CountFrame.Count:SetPoint(COUNT_POINT, aura.CountFrame, COUNT_RELATIVE_POINT, COUNT_OFFSET_X, COUNT_OFFSET_Y);
        aura.CountFrame.Count:SetTextColor(TEXT_COUNT_COLOR[1], TEXT_COUNT_COLOR[2], TEXT_COUNT_COLOR[3], TEXT_COUNT_COLOR[4]);
    end
end

function Module:UnitAdded(unitframe)
    if unitframe.data.unitType == 'SELF' then
        ResetPandemic(unitframe);
    end

    Update(unitframe);

    if Stripes.Masque and MASQUE_SUPPORT then
        Stripes.MasqueAurasGroup:ReSkin();
    end

    UpdateStyle(unitframe);
end

function Module:UnitRemoved(unitframe)
    ResetPandemic(unitframe);
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
    BLACKLIST_ENABLED     = O.db.auras_blacklist_enabled;

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

    UpdateFontObject(StripesAurasModCooldownFont, O.db.auras_cooldown_font_value, O.db.auras_cooldown_font_size, O.db.auras_cooldown_font_flag, O.db.auras_cooldown_font_shadow);
    UpdateFontObject(StripesAurasModCountFont, O.db.auras_count_font_value, O.db.auras_count_font_size, O.db.auras_count_font_flag, O.db.auras_count_font_shadow);

    UpdateBlacklistCache();
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