local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('Visibility');

-- Local Config
local SHOW_ALWAYS_INSTANCE, SHOW_ALWAYS_OPENWORLD, MAX_DISTANCE_INSTANCE, MAX_DISTANCE_OPENWORLD;
local SHOW_ENEMY, SHOW_FRIENDLY, ENEMY_ONLY_IN_COMBAT, FRIENDLY_ONLY_IN_COMBAT;

local wasInCombat = false;

local function ZoneChanged()
    if U.PlayerInCombat() then
        wasInCombat = true;

        return;
    end

    if IsInInstance() then
        C_CVar.SetCVar('nameplateShowAll', SHOW_ALWAYS_INSTANCE and 1 or 0);
        C_CVar.SetCVar('nameplateMaxDistance', MAX_DISTANCE_INSTANCE);
    else
        C_CVar.SetCVar('nameplateShowAll', SHOW_ALWAYS_OPENWORLD and 1 or 0);
        C_CVar.SetCVar('nameplateMaxDistance', MAX_DISTANCE_OPENWORLD);
    end
end

function Module:PLAYER_LOGIN()
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA');
    ZoneChanged();
end

function Module:ZONE_CHANGED_NEW_AREA()
    C_Timer.After(0.5, ZoneChanged);
end

function Module:PLAYER_REGEN_ENABLED()
    if wasInCombat then
        ZoneChanged();
        wasInCombat = false;
    end

    if ENEMY_ONLY_IN_COMBAT then
        C_CVar.SetCVar('nameplateShowEnemies', SHOW_ENEMY and 1 or 0);
    end

    if FRIENDLY_ONLY_IN_COMBAT then
        C_CVar.SetCVar('nameplateShowFriends', SHOW_FRIENDLY and 1 or 0);
    end
end

function Module:PLAYER_REGEN_DISABLED()
    if ENEMY_ONLY_IN_COMBAT then
        C_CVar.SetCVar('nameplateShowEnemies', 1);
    end

    if FRIENDLY_ONLY_IN_COMBAT then
        C_CVar.SetCVar('nameplateShowFriends', 1);
    end
end

function Module:UpdateLocalConfig()
    SHOW_ALWAYS_INSTANCE   = O.db.show_always_instance;
    SHOW_ALWAYS_OPENWORLD  = O.db.show_always_openworld;
    MAX_DISTANCE_INSTANCE  = O.db.max_distance_instance;
    MAX_DISTANCE_OPENWORLD = O.db.max_distance_openworld;

    SHOW_ENEMY    = O.db.show_enemy;
    SHOW_FRIENDLY = O.db.show_friendly;

    ENEMY_ONLY_IN_COMBAT    = O.db.show_enemy_only_in_combat;
    FRIENDLY_ONLY_IN_COMBAT = O.db.show_friendly_only_in_combat;
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_REGEN_ENABLED');
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
end