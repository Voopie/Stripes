local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('CombatIndicator');

-- WoW API
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat;

-- Local Config
local ENABLED, COLOR, POINT, RELATIVE_POINT, OFFSET_X, OFFSET_Y, SIZE;

local UPDATE_INTERVAL = 0.5;

local function OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed;

    if self.elapsed < UPDATE_INTERVAL then
        return;
    end

    local data       = self:GetParent():GetParent():GetParent().data;
    local unit       = data and data.unit;
    local isEnemy    = data and data.commonReaction == 'ENEMY';
    local shouldShow = isEnemy and unit and (UnitAffectingCombat(unit) or (UnitExists(unit .. 'pet') and UnitAffectingCombat(unit .. 'pet')));

    self.icon:SetShown(shouldShow);

    self.elapsed = 0;
end

local function Create(unitframe)
    if unitframe.CombatIndicator then
        return;
    end

    local frame = CreateFrame('Frame', '$parentCombatIndicator', unitframe.HealthBarsContainer.healthBar);
    frame:SetAllPoints();

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetTexture(S.Media.Icons2.TEXTURE);
    icon:SetTexCoord(unpack(S.Media.Icons2.COORDS.CROSS_SWORDS));
    icon:Hide();

    frame.icon = icon;

    frame.elapsed = 0;
    frame:SetScript('OnUpdate', OnUpdate);

    unitframe.CombatIndicator = frame;
end

local function Update(unitframe)
    if not unitframe.CombatIndicator then
        return;
    end

    local combatIndicator     = unitframe.CombatIndicator;
    local combatIndicatorIcon = combatIndicator.icon;

    combatIndicator.elapsed = UPDATE_INTERVAL + 0.01;
    combatIndicator:SetShown(ENABLED and not unitframe.data.isPersonal);

    combatIndicatorIcon:ClearAllPoints();
    combatIndicatorIcon:SetPoint(POINT, combatIndicator, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    combatIndicatorIcon:SetSize(SIZE, SIZE);
    combatIndicatorIcon:SetVertexColor(COLOR[1], COLOR[2], COLOR[3], COLOR[4]);
end

local function Hide(unitframe)
    if unitframe.CombatIndicator then
        unitframe.CombatIndicator:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    Hide(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.combat_indicator_enabled;

    COLOR = COLOR or {};
    COLOR[1] = O.db.combat_indicator_color[1];
    COLOR[2] = O.db.combat_indicator_color[2];
    COLOR[3] = O.db.combat_indicator_color[3];
    COLOR[4] = O.db.combat_indicator_color[4] or 1;

    POINT          = O.Lists.frame_points[O.db.combat_indicator_point] or 'CENTER';
    RELATIVE_POINT = O.Lists.frame_points[O.db.combat_indicator_relative_point] or 'BOTTOM';
    OFFSET_X       = O.db.combat_indicator_offset_x;
    OFFSET_Y       = O.db.combat_indicator_offset_y;

    SIZE = O.db.combat_indicator_size;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end