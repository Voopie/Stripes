local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('TargetIndicator');

-- Lua API
local pairs, math_rad = pairs, math.rad;

-- WoW API
local UnitIsUnit, UnitExists, UnitGUID = UnitIsUnit, UnitExists, UnitGUID;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local TARGET_INDICATOR_ENABLED, TARGET_GLOW_ENABLED, HOVER_GLOW_ENABLED;

local currentTargetGUID;

local INDICATOR_TEXTURES = O.Lists.target_indicator_texture_path;
local DEFAULT_INDICATOR = 1;

local GLOW_UPDATE_INTERVAL = 0.1;

local function Glow_Show(unitframe)
    if currentTargetGUID ~= unitframe.data.unitGUID then
        unitframe.TargetIndicator.left:Hide();
        unitframe.TargetIndicator.right:Hide();
    end

    unitframe.TargetIndicator:Show();

    unitframe.TargetIndicator.glowUp:Show();
    unitframe.TargetIndicator.glowDown:Show();
end

local function Glow_Hide(unitframe)
    if currentTargetGUID == unitframe.data.unitGUID then
        return;
    end

    unitframe.TargetIndicator:Hide();

    unitframe.TargetIndicator.glowUp:Hide();
    unitframe.TargetIndicator.glowDown:Hide();

    unitframe.TargetIndicator.left:Hide();
    unitframe.TargetIndicator.right:Hide();
end

local function MouseOnUnit(unitframe)
    if unitframe and unitframe:IsVisible() and UnitExists('mouseover') then
        return UnitIsUnit('mouseover', unitframe.data.unit);
    end

    return false;
end

local function OnUpdate(self, elapsed)
    if self.elapsed and self.elapsed > GLOW_UPDATE_INTERVAL then
        local unitframe = self:GetParent():GetParent();

        if not MouseOnUnit(unitframe) then
            Glow_Hide(unitframe);
        end

        self.elapsed = 0;
    else
        self.elapsed = (self.elapsed or 0) + elapsed;
    end
end

local function UpdateTargetSelection(unitframe)
    if not unitframe.TargetIndicator then
        return;
    end

    if unitframe.data.unitType == 'SELF' then
        unitframe.TargetIndicator:SetShown(false);
        return;
    end

    currentTargetGUID = UnitGUID('target');

    if currentTargetGUID == unitframe.data.unitGUID then
        unitframe.TargetIndicator:SetShown(true);

        unitframe.TargetIndicator.left:SetShown(TARGET_INDICATOR_ENABLED);
        unitframe.TargetIndicator.right:SetShown(TARGET_INDICATOR_ENABLED);

        unitframe.TargetIndicator.glowUp:SetShown(TARGET_GLOW_ENABLED);
        unitframe.TargetIndicator.glowDown:SetShown(TARGET_GLOW_ENABLED);
    else
        unitframe.TargetIndicator:SetShown(false);
    end
end

local function CreateTargetIndicator(unitframe)
    if unitframe.TargetIndicator then
        return;
    end

    local indicator = CreateFrame('Frame', nil, unitframe.healthBar);
    indicator:SetAllPoints(unitframe.healthBar);

    indicator.left = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(indicator.left, 'RIGHT', unitframe.healthBar, 'LEFT', -(O.db.target_indicator_x_offset), O.db.target_indicator_y_offset);
    PixelUtil.SetSize(indicator.left, O.db.target_indicator_size, O.db.target_indicator_size);
    indicator.left:SetTexture(INDICATOR_TEXTURES[O.db.target_indicator_texture] or INDICATOR_TEXTURES[DEFAULT_INDICATOR]);
    indicator.left:Hide();

    indicator.right = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(indicator.right, 'LEFT', unitframe.healthBar, 'RIGHT', O.db.target_indicator_x_offset, O.db.target_indicator_y_offset)
    PixelUtil.SetSize(indicator.right, O.db.target_indicator_size, O.db.target_indicator_size);
    indicator.right:SetTexture(INDICATOR_TEXTURES[O.db.target_indicator_texture] or INDICATOR_TEXTURES[DEFAULT_INDICATOR]);
    indicator.right:SetTexCoord(1, 0, 0, 1); -- Hor flip
    indicator.right:Hide();

    indicator.left:SetVertexColor(unpack(O.db.target_indicator_color));
    indicator.right:SetVertexColor(unpack(O.db.target_indicator_color));

    indicator.glowUp = indicator:CreateTexture(nil, 'BACKGROUND');
    PixelUtil.SetPoint(indicator.glowUp, 'TOPLEFT', unitframe.healthBar, 'TOPLEFT', 0, 6);
    PixelUtil.SetPoint(indicator.glowUp, 'TOPRIGHT', unitframe.healthBar, 'TOPRIGHT', 0, 6);
    PixelUtil.SetHeight(indicator.glowUp, 6);
    indicator.glowUp:SetTexture(S.Media.Path .. 'Textures\\glow');
    indicator.glowUp:SetRotation(math_rad(180));
    indicator.glowUp:Hide();

    indicator.glowDown = indicator:CreateTexture(nil, 'BACKGROUND');
    PixelUtil.SetPoint(indicator.glowDown, 'TOPLEFT', unitframe.healthBar, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(indicator.glowDown, 'TOPRIGHT', unitframe.healthBar, 'BOTTOMRIGHT', 0, 0);
    PixelUtil.SetHeight(indicator.glowDown, 6);
    indicator.glowDown:SetTexture(S.Media.Path .. 'Textures\\glow');
    indicator.glowDown:Hide();

    indicator.glowUp:SetVertexColor(unpack(O.db.target_glow_color));
    indicator.glowDown:SetVertexColor(unpack(O.db.target_glow_color));

    indicator:HookScript('OnUpdate', OnUpdate);

    unitframe.TargetIndicator = indicator;

    unitframe.TargetIndicator:Hide();
end

local function UpdateStyle(unitframe)
    PixelUtil.SetSize(unitframe.TargetIndicator.left, O.db.target_indicator_size, O.db.target_indicator_size);
    PixelUtil.SetSize(unitframe.TargetIndicator.right, O.db.target_indicator_size, O.db.target_indicator_size);

    PixelUtil.SetPoint(unitframe.TargetIndicator.left, 'RIGHT', unitframe.healthBar, 'LEFT', -(O.db.target_indicator_x_offset), O.db.target_indicator_y_offset);
    PixelUtil.SetPoint(unitframe.TargetIndicator.right, 'LEFT', unitframe.healthBar, 'RIGHT', O.db.target_indicator_x_offset, O.db.target_indicator_y_offset);

    unitframe.TargetIndicator.left:SetTexture(INDICATOR_TEXTURES[O.db.target_indicator_texture] or INDICATOR_TEXTURES[DEFAULT_INDICATOR]);
    unitframe.TargetIndicator.right:SetTexture(INDICATOR_TEXTURES[O.db.target_indicator_texture] or INDICATOR_TEXTURES[DEFAULT_INDICATOR]);

    unitframe.TargetIndicator.left:SetVertexColor(unpack(O.db.target_indicator_color));
    unitframe.TargetIndicator.right:SetVertexColor(unpack(O.db.target_indicator_color));

    unitframe.TargetIndicator.glowUp:SetVertexColor(unpack(O.db.target_glow_color));
    unitframe.TargetIndicator.glowDown:SetVertexColor(unpack(O.db.target_glow_color));
end

local function UpdateMouseoverUnit()
    if not HOVER_GLOW_ENABLED then
        return;
    end

    for _, unitframe in pairs(NP) do
        if unitframe.data.unitType ~= 'SELF' and currentTargetGUID ~= unitframe.data.unitGUID then
            if MouseOnUnit(unitframe) then
                Glow_Show(unitframe);
            else
                Glow_Hide(unitframe);
            end
        end
    end
end

function Module:UnitAdded(unitframe)
    CreateTargetIndicator(unitframe);
    UpdateStyle(unitframe);
    UpdateTargetSelection(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.TargetIndicator then
        unitframe.TargetIndicator:SetShown(false);
    end
end

function Module:Update(unitframe)
    UpdateTargetSelection(unitframe);
    UpdateStyle(unitframe);
end

function Module:UpdateLocalConfig()
    TARGET_INDICATOR_ENABLED = O.db.target_indicator_enabled;
    TARGET_GLOW_ENABLED      = O.db.target_glow_enabled;
    HOVER_GLOW_ENABLED       = O.db.hover_glow_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateTargetSelection);
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', UpdateMouseoverUnit);
end