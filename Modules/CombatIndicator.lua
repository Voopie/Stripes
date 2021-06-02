local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('CombatIndicator');

-- WoW API
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat;

-- Nameplates
local NP = S.NamePlates;

-- Local config
local ENABLED, COLOR, OFFSET_X, OFFSET_Y;

local UPDATE_INTERVAL = 0.5;

local function OnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed;

    if self.elapsed < UPDATE_INTERVAL then
        return;
    end

    local unit = self:GetParent():GetParent().data.unit;

    if unit and UnitAffectingCombat(unit) or (UnitExists(unit .. 'pet') and UnitAffectingCombat(unit .. 'pet')) then
        self.icon:SetShown(self:GetParent():GetParent().data.commonReaction == 'ENEMY');
    else
        self.icon:Hide();
    end

    self.elapsed = 0;
end

local function Create(unitframe)
    if unitframe.CombatIndicator then
        return;
    end

    local frame = CreateFrame('Frame', '$parentCombatIndicator', unitframe.healthBar);
    frame:SetAllPoints();

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    PixelUtil.SetPoint(frame.icon, 'TOPLEFT', frame, 'BOTTOMLEFT', OFFSET_X, OFFSET_Y);
    PixelUtil.SetSize(frame.icon, 8, 8);
    frame.icon:SetTexture(S.Media.Icons2.TEXTURE);
    frame.icon:SetTexCoord(unpack(S.Media.Icons2.COORDS.CROSS_SWORDS_WHITE));
    frame.icon:SetShown(false);

    frame.elapsed = 0;
    frame:SetScript('OnUpdate', OnUpdate);

    unitframe.CombatIndicator = frame;
end

local function Update(unitframe)
    unitframe.elapsed = 0;
    unitframe.CombatIndicator:SetShown(ENABLED and unitframe.data.unitType ~= 'SELF');
    PixelUtil.SetPoint(unitframe.CombatIndicator.icon, 'TOPLEFT', unitframe.CombatIndicator, 'BOTTOMLEFT', OFFSET_X, OFFSET_Y);
    unitframe.CombatIndicator.icon:SetVertexColor(COLOR[1], COLOR[2], COLOR[3], COLOR[4]);
end

local function Hide(unitframe)
    if unitframe.CombatIndicator then
        unitframe.CombatIndicator:SetShown(false);
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

    OFFSET_X = O.db.combat_indicator_offset_x;
    OFFSET_Y = O.db.combat_indicator_offset_y;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end