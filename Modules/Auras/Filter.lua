local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Filter');

-- Lua API
local ipairs = ipairs;

-- Wow API
local CooldownFrame_Set, AuraUtil_ForEachAura = CooldownFrame_Set, AuraUtil.ForEachAura;

-- Local Config
local ENABLED, BLACKLIST_ENABLED;

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
            name = CacheFindAuraNameById(spellId);

            if name then
                blacklistAurasNameCache[name] = nil;
            end
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

			if FilterShouldShowBuff(self, name, spellId, caster, nameplateShowPersonal, nameplateShowAll or showAll, duration) then
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

				CooldownFrame_Set(buff.Cooldown, expirationTime - duration, duration, duration > 0, true);

				buff:Show();

				buffIndex = buffIndex + 1;
			end

			index = index + 1;

			return buffIndex > BUFF_MAX_DISPLAY;
		end);

		for i = buffIndex, BUFF_MAX_DISPLAY do
			if self.buffList[i] then
				self.buffList[i]:Hide();
			else
				break;
			end
		end
	end

	self:Layout();
end

local function Update(unitframe)
    unitframe.BuffFrame.ShouldShowBuff = FilterShouldShowBuff;
    unitframe.BuffFrame.UpdateBuffs    = UpdateBuffs;

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
    ENABLED           = O.db.auras_filter_player_enabled;
    BLACKLIST_ENABLED = O.db.auras_blacklist_enabled;

    UpdateBlacklistCache();
end

function Module:StartUp()
    self:UpdateLocalConfig();
end