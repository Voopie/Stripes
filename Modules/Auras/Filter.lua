local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Filter');

-- Lua API
local ipairs = ipairs;

-- Wow API
local CooldownFrame_Set, AuraUtil_ForEachAura = CooldownFrame_Set, AuraUtil.ForEachAura;

-- Local Config
local IS_ACTIVE, ENABLED, BLACKLIST_ENABLED, SPACING_X, AURAS_DIRECTION, AURAS_MAX_DISPLAY;
local DRAW_EDGE;

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

    if ENABLED and self:GetParent().data.unitType ~= 'SELF' then
        return units[caster];
    else
        return nameplateShowAll or (nameplateShowPersonal and units[caster]);
    end
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
        local _, name, texture, count, duration, expirationTime, caster, nameplateShowPersonal, spellId, nameplateShowAll;

        AuraUtil_ForEachAura(unit, filter, BUFF_MAX_DISPLAY, function(...)
            name, texture, count, _, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = ...;

            if FilterShouldShowBuff(self, name, spellId, caster, nameplateShowPersonal, nameplateShowAll or showAll) then
                if not self.buffList[buffIndex] then
                    self.buffList[buffIndex] = CreateFrame('Frame', nil, self, 'NameplateBuffButtonTemplate');
                    self.buffList[buffIndex]:SetMouseClickEnabled(false);
                    self.buffList[buffIndex].layoutIndex = buffIndex;
                end

                local buff = self.buffList[buffIndex];

                buff:SetID(index);

                buff.Icon:SetTexture(texture);

                if count > 1 then
                    buff.CountFrame.Count:SetText(count);
                    buff.CountFrame.Count:Show();
                else
                    buff.CountFrame.Count:Hide();
                end

                CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, DRAW_EDGE);

                buff:Show();

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

    -- self:Layout();
end

local function Update(unitframe)
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;
    unitframe.BuffFrame.UpdateBuffs    = UpdateBuffs;
    unitframe.BuffFrame.spacing        = SPACING_X;
    unitframe.BuffFrame.isActive       = IS_ACTIVE;

    if unitframe.BuffFrame.unit and unitframe.BuffFrame.filter then
        unitframe.BuffFrame:UpdateBuffs(unitframe.BuffFrame.unit, unitframe.BuffFrame.filter, unitframe.data.unitType == 'FRIENDLY_PLAYER');
    end
end

function Module:UnitAdded(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    IS_ACTIVE         = O.db.auras_is_active;
    ENABLED           = O.db.auras_filter_player_enabled;
    BLACKLIST_ENABLED = O.db.auras_blacklist_enabled;
    SPACING_X         = O.db.auras_spacing_x or 4;
    DRAW_EDGE         = O.db.auras_draw_edge;
    AURAS_DIRECTION   = O.db.auras_direction;
    AURAS_MAX_DISPLAY = O.db.auras_max_display;

    UpdateBlacklistCache();
end

function Module:StartUp()
    self:UpdateLocalConfig();
end