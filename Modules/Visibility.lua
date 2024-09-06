local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('Visibility');
local Stripes = S:GetNameplateModule('Handler');

-- Local Config
local SHOW_ALWAYS_INSTANCE, SHOW_ALWAYS_OPENWORLD, SHOW_ALWAYS_PVP_INSTANCE, MAX_DISTANCE_INSTANCE, MAX_DISTANCE_OPENWORLD, MAX_DISTANCE_PVP_INSTANCE;
local SHOW_ENEMY, SHOW_FRIENDLY, ENEMY_ONLY_IN_COMBAT, FRIENDLY_ONLY_IN_COMBAT;

local wasInCombat = false;

local function HandleVisibility()
    if U.PlayerInCombat() then
        wasInCombat = true;
        return;
    end

    local showAll, maxDistance = SHOW_ALWAYS_OPENWORLD and 1 or 0, MAX_DISTANCE_OPENWORLD;

    if D.Player.State.inPvPInstance then
        showAll, maxDistance = SHOW_ALWAYS_PVP_INSTANCE and 1 or 0, MAX_DISTANCE_PVP_INSTANCE;
    elseif D.Player.State.inInstance then
        showAll, maxDistance = SHOW_ALWAYS_INSTANCE and 1 or 0, MAX_DISTANCE_INSTANCE;
    end

    Stripes.SetCVar('nameplateShowAll', showAll);
    Stripes.SetCVar('nameplateMaxDistance', maxDistance);

    Stripes.UpdateFriendlySizes();
end

function Module:PLAYER_LOGIN()
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA');
    self:RegisterEvent('GARRISON_UPDATE');

    HandleVisibility();
end

function Module:ZONE_CHANGED_NEW_AREA()
    C_Timer.After(0.15, HandleVisibility);
end

function Module:GARRISON_UPDATE()
    C_Timer.After(0.15, HandleVisibility);
end

function Module:PLAYER_REGEN_ENABLED()
    if wasInCombat then
        HandleVisibility();
        wasInCombat = false;
    end

    if ENEMY_ONLY_IN_COMBAT then
        Stripes.SetCVar('nameplateShowEnemies', SHOW_ENEMY and 1 or 0);
    end

    if FRIENDLY_ONLY_IN_COMBAT then
        Stripes.SetCVar('nameplateShowFriends', SHOW_FRIENDLY and 1 or 0);
    end
end

function Module:PLAYER_REGEN_DISABLED()
    if ENEMY_ONLY_IN_COMBAT then
        Stripes.SetCVar('nameplateShowEnemies', 1);
    end

    if FRIENDLY_ONLY_IN_COMBAT then
        Stripes.SetCVar('nameplateShowFriends', 1);
    end
end

function Module:UpdateLocalConfig()
    SHOW_ALWAYS_INSTANCE     = O.db.show_always_instance;
    SHOW_ALWAYS_OPENWORLD    = O.db.show_always_openworld;
    SHOW_ALWAYS_PVP_INSTANCE = O.db.show_always_pvp_instance;

    MAX_DISTANCE_INSTANCE     = O.db.max_distance_instance;
    MAX_DISTANCE_OPENWORLD    = O.db.max_distance_openworld;
    MAX_DISTANCE_PVP_INSTANCE = O.db.max_distance_pvp_instance;

    SHOW_ENEMY    = O.db.show_enemy;
    SHOW_FRIENDLY = O.db.show_friendly;

    ENEMY_ONLY_IN_COMBAT    = O.db.show_enemy_only_in_combat;
    FRIENDLY_ONLY_IN_COMBAT = O.db.show_friendly_only_in_combat;

    Stripes.UpdateFriendlySizes();
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:RegisterEvent('PLAYER_LOGIN');
    self:RegisterEvent('PLAYER_REGEN_ENABLED');
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
end