local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Pandemic');

-- Lua API
local select, ipairs, table_wipe, bit_band = select, ipairs, wipe, bit.band;

-- WoW API
local UnitAura = UnitAura;

-- Stripes API
local GetTrulySpellId, S_IsSpellKnown = U.GetTrulySpellId, U.IsSpellKnown;
local GlowStart, GlowStopAll = U.GlowStart, U.GlowStopAll;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, PANDEMIC_COLOR;
local EXPIRE_GLOW_ENABLED, EXPIRE_GLOW_PERCENT, EXPIRE_GLOW_COLOR, EXPIRE_GLOW_TYPE;
local TEXT_COOLDOWN_COLOR;

local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

local PANDEMIC_PERCENT = 30;
local knownSpells = {};

local UPDATE_INTERVAL = 0.33;

local function IsOnPandemic(aura)
    if not ENABLED or not COUNTDOWN_ENABLED then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= durationMs/100*PANDEMIC_PERCENT;
end

local function IsOnExpireGlow(aura)
    if not EXPIRE_GLOW_ENABLED then
        return;
    end

    local startTimeMs, durationMs = aura.Cooldown:GetCooldownTimes();
    local remTimeMs = startTimeMs - (GetTime() * 1000 - durationMs);

    return remTimeMs > 0 and remTimeMs <= durationMs/100*EXPIRE_GLOW_PERCENT;
end

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' or not unitframe.BuffFrame then
        return;
    end

    local _, spellId, flags, cc;

    for _, aura in ipairs(unitframe.BuffFrame.buffList) do
        spellId = select(10, UnitAura(unitframe.BuffFrame.unit, aura:GetID(), unitframe.BuffFrame.filter));

        if spellId then
            aura.spellId = spellId;

            if not aura.OnUpdateHooked then
                aura.Cooldown:SetFrameStrata('HIGH');
                aura.CountFrame:SetFrameStrata('HIGH');

                aura:HookScript('OnUpdate', function(self, elapsed)
                    self.elapsed = (self.elapsed or 0) + elapsed;

                    if self.elapsed < UPDATE_INTERVAL then
                        return;
                    end

                    if self.spellId and IsOnPandemic(self) then
                        flags, _, _, cc = LPS_GetSpellInfo(LPS, self.spellId);
                        if not flags or not cc or not (bit_band(flags, CROWD_CTRL) > 0 and bit_band(cc, CC_TYPES) > 0) then
                            self.spellId = GetTrulySpellId(self.spellId);

                            if self.spellId and (knownSpells[self.spellId] or S_IsSpellKnown(self.spellId)) then
                                self.Cooldown:GetRegions():SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4]);

                                if not knownSpells[self.spellId] then
                                    knownSpells[self.spellId] = true;
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

                aura.OnUpdateHooked = true;
            end
        end
    end
end

local function Reset(unitframe)
    if unitframe.BuffFrame and unitframe.BuffFrame.buffList then
        for _, aura in ipairs(unitframe.BuffFrame.buffList) do
            aura.spellId = nil;
            GlowStopAll(aura);

            aura.Cooldown:GetRegions():SetTextColor(TEXT_COOLDOWN_COLOR[1], TEXT_COOLDOWN_COLOR[2], TEXT_COOLDOWN_COLOR[3], TEXT_COOLDOWN_COLOR[4]);
        end
    end
end

function Module:UnitAdded(unitframe)
    if unitframe.data.unitType == 'SELF' then
        Reset(unitframe);
    else
        Update(unitframe);
    end
end

function Module:UnitRemoved(unitframe)
    Reset(unitframe);
end

function Module:UnitAura(unitframe)
    Update(unitframe);
end

function Module:Update(unitframe)
    Reset(unitframe);
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED           = O.db.auras_pandemic_enabled;
    COUNTDOWN_ENABLED = O.db.auras_countdown_enabled;

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

    TEXT_COOLDOWN_COLOR    = TEXT_COOLDOWN_COLOR or {};
    TEXT_COOLDOWN_COLOR[1] = O.db.auras_cooldown_color[1];
    TEXT_COOLDOWN_COLOR[2] = O.db.auras_cooldown_color[2];
    TEXT_COOLDOWN_COLOR[3] = O.db.auras_cooldown_color[3];
    TEXT_COOLDOWN_COLOR[4] = O.db.auras_cooldown_color[4] or 1;
end

function Module:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit ~= 'player' then
        return;
    end

    table_wipe(knownSpells);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED');
end