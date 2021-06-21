local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Auras_Pandemic');

-- Lua API
local select, ipairs, table_wipe, bit_band = select, ipairs, wipe, bit.band;

-- WoW API
local UnitAura, GetSpellInfo, IsSpellKnown = UnitAura, GetSpellInfo, IsSpellKnown;

-- Local Config
local ENABLED, COUNTDOWN_ENABLED, PANDEMIC_COLOR;
local EXPIRE_GLOW_ENABLED, EXPIRE_GLOW_PERCENT, EXPIRE_GLOW_COLOR, EXPIRE_GLOW_TYPE;

-- Libraries
local LCG = S.Libraries.LCG;

local LPS = S.Libraries.LPS;
local LPS_GetSpellInfo = LPS.GetSpellInfo;
local CC_TYPES = bit.bor(LPS.constants.DISORIENT, LPS.constants.INCAPACITATE, LPS.constants.ROOT, LPS.constants.STUN);
local CROWD_CTRL = LPS.constants.CROWD_CTRL;

local PANDEMIC_PERCENT = 30;
local knownSpells = {};

local UPDATE_INTERVAL = 0.33;

--[[
    IsPlayerSpell(spellId), IsSpellKnown(spellId), IsSpellKnownOrOverridesKnown(spellId)
    Incorrectly returned false for some spells
]]

local function GetTrulySpellId(spellId)
    return select(7, GetSpellInfo(GetSpellInfo(spellId))); -- here we extract the spell name and then get needed spellId by spell name
end

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

local function UpdateExpireGlow(aura)
    if EXPIRE_GLOW_TYPE == 1 then
        LCG.PixelGlow_Start(aura, EXPIRE_GLOW_COLOR);
    elseif EXPIRE_GLOW_TYPE == 2 then
        LCG.AutoCastGlow_Start(aura, EXPIRE_GLOW_COLOR);
    elseif EXPIRE_GLOW_TYPE == 3 then
        LCG.ButtonGlow_Start(aura, EXPIRE_GLOW_COLOR);
    end
end

local function StopExpireGlow(aura)
    LCG.PixelGlow_Stop(aura);
    LCG.AutoCastGlow_Stop(aura);
    LCG.ButtonGlow_Stop(aura);
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

                            if self.spellId and (knownSpells[self.spellId] or IsSpellKnown(self.spellId)) then
                                self.Cooldown:GetRegions():SetTextColor(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4]);

                                if not knownSpells[self.spellId] then
                                    knownSpells[self.spellId] = true;
                                end
                            end
                        end
                    else
                        self.Cooldown:GetRegions():SetTextColor(1, 1, 1, 1);
                    end

                    if IsOnExpireGlow(self) then
                        UpdateExpireGlow(self);
                    else
                        StopExpireGlow(self);
                    end

                    self.elapsed = 0;
                end);

                aura.Cooldown:HookScript('OnCooldownDone', function(self)
                    StopExpireGlow(self:GetParent());
                end);

                aura.Cooldown.OnUpdateHooked = true;
            end
        end
    end
end

local function Reset(unitframe)
    if unitframe.BuffFrame and unitframe.BuffFrame.buffList then
        for _, aura in ipairs(unitframe.BuffFrame.buffList) do
            aura.spellId = nil;
            StopExpireGlow(aura);

            aura.Cooldown:GetRegions():SetTextColor(1, 1, 1, 1);
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

    PANDEMIC_COLOR    = PANDEMIC_COLOR or {}
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