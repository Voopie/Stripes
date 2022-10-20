local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('TargetIndicator');

-- Lua API
local pairs = pairs;

-- WoW API
local UnitIsUnit, UnitExists = UnitIsUnit, UnitExists;

-- Nameplates
local NP = S.NamePlates;

-- Local Config
local TARGET_INDICATOR_ENABLED, TARGET_GLOW_ENABLED, HOVER_GLOW_ENABLED;
local TEXTURE, TARGET_INDICATOR_COLOR, TARGET_GLOW_COLOR;
local SIZE, X_OFFSET, Y_OFFSET;
local GLOW_SIZE;

local GLOW_TEXTURE = S.Media.Path .. 'Textures\\glow';
local GLOW_UPDATE_INTERVAL = 0.1;

local function Glow_Show(unitframe)
    if not unitframe.data.isTarget then
        unitframe.TargetIndicator.left:Hide();
        unitframe.TargetIndicator.right:Hide();
    end

    unitframe.TargetIndicator:Show();

    unitframe.TargetIndicator.glowUp:Show();
    unitframe.TargetIndicator.glowDown:Show();
end

local function Glow_Hide(unitframe)
    if unitframe.data.isTarget then
        return;
    end

    unitframe.TargetIndicator:Hide();

    unitframe.TargetIndicator.glowUp:Hide();
    unitframe.TargetIndicator.glowDown:Hide();

    unitframe.TargetIndicator.left:Hide();
    unitframe.TargetIndicator.right:Hide();
end

local function MouseOnUnit(unitframe)
    if unitframe and unitframe.data.unit and unitframe:IsVisible() and UnitExists('mouseover') then
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

    if unitframe.data.isPersonal then
        unitframe.TargetIndicator:Hide();
        return;
    end

    if unitframe.data.isTarget then
        unitframe.TargetIndicator:Show();

        unitframe.TargetIndicator.left:SetShown(TARGET_INDICATOR_ENABLED);
        unitframe.TargetIndicator.right:SetShown(TARGET_INDICATOR_ENABLED);

        unitframe.TargetIndicator.glowUp:SetShown(TARGET_GLOW_ENABLED);
        unitframe.TargetIndicator.glowDown:SetShown(TARGET_GLOW_ENABLED);
    else
        unitframe.TargetIndicator:Hide();
    end
end

local function CreateTargetIndicator(unitframe)
    if unitframe.TargetIndicator then
        return;
    end

    local indicator = CreateFrame('Frame', nil, unitframe.healthBar);
    indicator:SetFrameStrata('LOW');
    indicator:SetAllPoints(unitframe.healthBar);

    indicator.left = indicator:CreateTexture(nil, 'BORDER');
    indicator.left:Hide();

    indicator.right = indicator:CreateTexture(nil, 'BORDER');
    indicator.right:SetTexCoord(1, 0, 0, 1); -- Hor flip
    indicator.right:Hide();

    indicator.glowUp = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(indicator.glowUp, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', 0, 0);
    PixelUtil.SetPoint(indicator.glowUp, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0, 0);
    PixelUtil.SetHeight(indicator.glowUp, GLOW_SIZE);
    indicator.glowUp:SetTexture(GLOW_TEXTURE);
    indicator.glowUp:SetTexCoord(0, 1, 1, 0);
    indicator.glowUp:Hide();

    indicator.glowDown = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(indicator.glowDown, 'TOPLEFT', unitframe.healthBar, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(indicator.glowDown, 'TOPRIGHT', unitframe.healthBar, 'BOTTOMRIGHT', 0, 0);
    PixelUtil.SetHeight(indicator.glowDown, GLOW_SIZE);
    indicator.glowDown:SetTexture(GLOW_TEXTURE);
    indicator.glowDown:Hide();

    indicator:HookScript('OnUpdate', OnUpdate);

    unitframe.TargetIndicator = indicator;

    unitframe.TargetIndicator:Hide();
end

local function UpdateStyle(unitframe)
    PixelUtil.SetSize(unitframe.TargetIndicator.left, SIZE, SIZE);
    PixelUtil.SetSize(unitframe.TargetIndicator.right, SIZE, SIZE);

    PixelUtil.SetPoint(unitframe.TargetIndicator.left, 'RIGHT', unitframe.healthBar, 'LEFT', -(X_OFFSET), Y_OFFSET);
    PixelUtil.SetPoint(unitframe.TargetIndicator.right, 'LEFT', unitframe.healthBar, 'RIGHT', X_OFFSET, Y_OFFSET);

    unitframe.TargetIndicator.left:SetTexture(TEXTURE);
    unitframe.TargetIndicator.right:SetTexture(TEXTURE);

    unitframe.TargetIndicator.left:SetVertexColor(unpack(TARGET_INDICATOR_COLOR));
    unitframe.TargetIndicator.right:SetVertexColor(unpack(TARGET_INDICATOR_COLOR));

    unitframe.TargetIndicator.glowUp:SetVertexColor(unpack(TARGET_GLOW_COLOR));
    unitframe.TargetIndicator.glowDown:SetVertexColor(unpack(TARGET_GLOW_COLOR));

    PixelUtil.SetHeight(unitframe.TargetIndicator.glowUp, GLOW_SIZE);
    PixelUtil.SetHeight(unitframe.TargetIndicator.glowDown, GLOW_SIZE);
end

local function UpdateMouseoverUnit()
    if not HOVER_GLOW_ENABLED then
        return;
    end

    for _, unitframe in pairs(NP) do
        if unitframe:IsShown() and not unitframe.data.isTarget and not unitframe.data.isPersonal then
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
        unitframe.TargetIndicator:Hide();
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

    SIZE     = O.db.target_indicator_size;
    X_OFFSET = O.db.target_indicator_x_offset;
    Y_OFFSET = O.db.target_indicator_y_offset;
    TEXTURE  = O.Lists.target_indicator_texture_path[O.db.target_indicator_texture] or O.Lists.target_indicator_texture_path[1];

    GLOW_SIZE = O.db.target_glow_size;

    TARGET_INDICATOR_COLOR = TARGET_INDICATOR_COLOR or {};

    if O.db.target_indicator_color_as_class then
        TARGET_INDICATOR_COLOR[1] = D.Player.ClassColor.r;
        TARGET_INDICATOR_COLOR[2] = D.Player.ClassColor.g;
        TARGET_INDICATOR_COLOR[3] = D.Player.ClassColor.b;
        TARGET_INDICATOR_COLOR[4] = D.Player.ClassColor.a or 1;
    else
        TARGET_INDICATOR_COLOR[1] = O.db.target_indicator_color[1];
        TARGET_INDICATOR_COLOR[2] = O.db.target_indicator_color[2];
        TARGET_INDICATOR_COLOR[3] = O.db.target_indicator_color[3];
        TARGET_INDICATOR_COLOR[4] = O.db.target_indicator_color[4] or 1;
    end

    TARGET_GLOW_COLOR = TARGET_GLOW_COLOR or {};

    if O.db.target_glow_color_as_class then
        TARGET_GLOW_COLOR[1] = D.Player.ClassColor.r;
        TARGET_GLOW_COLOR[2] = D.Player.ClassColor.g;
        TARGET_GLOW_COLOR[3] = D.Player.ClassColor.b;
        TARGET_GLOW_COLOR[4] = D.Player.ClassColor.a or 1;
    else
        TARGET_GLOW_COLOR[1] = O.db.target_glow_color[1];
        TARGET_GLOW_COLOR[2] = O.db.target_glow_color[2];
        TARGET_GLOW_COLOR[3] = O.db.target_glow_color[3];
        TARGET_GLOW_COLOR[4] = O.db.target_glow_color[4] or 1;
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateTargetSelection);
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', UpdateMouseoverUnit);
end