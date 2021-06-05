local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('CombatIndicator');

-- WoW API
local UnitExists, UnitAffectingCombat = UnitExists, UnitAffectingCombat;

-- Local config
local ENABLED, COLOR, ANCHOR, RELATIVE_ANCHOR, OFFSET_X, OFFSET_Y, SIZE;

local FRAME_ANCHORS = O.Lists.frame_positions;

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
    frame.icon:SetTexture(S.Media.Icons2.TEXTURE);
    frame.icon:SetTexCoord(unpack(S.Media.Icons2.COORDS.CROSS_SWORDS_WHITE));
    frame.icon:SetShown(false);

    frame.elapsed = 0;
    frame:SetScript('OnUpdate', OnUpdate);

    unitframe.CombatIndicator = frame;
end

local function Update(unitframe)
    unitframe.CombatIndicator.elapsed = UPDATE_INTERVAL + 0.01;
    unitframe.CombatIndicator:SetShown(ENABLED and unitframe.data.unitType ~= 'SELF');

    unitframe.CombatIndicator.icon:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.CombatIndicator.icon, ANCHOR, unitframe.CombatIndicator, RELATIVE_ANCHOR, OFFSET_X, OFFSET_Y);

    PixelUtil.SetSize(unitframe.CombatIndicator.icon, SIZE, SIZE);

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

    ANCHOR          = FRAME_ANCHORS[O.db.combat_indicator_anchor] or 'TOPLEFT';
    RELATIVE_ANCHOR = FRAME_ANCHORS[O.db.combat_indicator_relative_anchor] or 'BOTTOMLEFT';

    OFFSET_X = O.db.combat_indicator_offset_x;
    OFFSET_Y = O.db.combat_indicator_offset_y;

    SIZE = O.db.combat_indicator_size;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end