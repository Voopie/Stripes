local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('TargetIndicator');

-- WoW API
local UnitIsUnit, UnitExists = UnitIsUnit, UnitExists;

-- Local Config
local TARGET_INDICATOR_ENABLED, TARGET_GLOW_ENABLED;
local TEXTURE, TARGET_INDICATOR_COLOR, TARGET_GLOW_COLOR;
local FRAME_STRATA, SIZE, X_OFFSET, Y_OFFSET;
local GLOW_SIZE;

local GLOW_TEXTURE = S.Media.Path .. 'Textures\\glow';
local GLOW_UPDATE_INTERVAL = 0.1;

local function Glow_Show(unitframe)
    local targetIndicator = unitframe.TargetIndicator;

    if not unitframe.data.isTarget then
        targetIndicator.left:Hide();
        targetIndicator.right:Hide();
    end

    targetIndicator:Show();

    targetIndicator.glowUp:Show();
    targetIndicator.glowDown:Show();
end

local function Glow_Hide(unitframe)
    if unitframe.data and unitframe.data.isTarget then
        return;
    end

    local targetIndicator = unitframe.TargetIndicator;

    targetIndicator:Hide();

    targetIndicator.glowUp:Hide();
    targetIndicator.glowDown:Hide();

    targetIndicator.left:Hide();
    targetIndicator.right:Hide();
end

local function MouseOnUnit(unitframe)
    if unitframe and unitframe.data and unitframe.data.unit and unitframe:IsVisible() and UnitExists('mouseover') then
        return UnitIsUnit('mouseover', unitframe.data.unit);
    end

    return false;
end

local function OnUpdate(self, elapsed)
    if self.elapsed and self.elapsed > GLOW_UPDATE_INTERVAL then
        local unitframe = self:GetParent():GetParent():GetParent();

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

    if unitframe.data.isPersonal or not unitframe.data.isTarget then
        unitframe.TargetIndicator:Hide();
        return;
    end

    local targetIndicator = unitframe.TargetIndicator;

    targetIndicator.left:SetShown(TARGET_INDICATOR_ENABLED);
    targetIndicator.right:SetShown(TARGET_INDICATOR_ENABLED);

    targetIndicator.glowUp:SetShown(TARGET_GLOW_ENABLED);
    targetIndicator.glowDown:SetShown(TARGET_GLOW_ENABLED);

    targetIndicator:Show();
end

local function CreateTargetIndicator(unitframe)
    if unitframe.TargetIndicator then
        return;
    end

    local indicator = CreateFrame('Frame', nil, unitframe.HealthBarsContainer.healthBar);
    indicator:SetFrameStrata(FRAME_STRATA == 1 and indicator:GetParent():GetFrameStrata() or FRAME_STRATA);
    indicator:SetAllPoints(unitframe.HealthBarsContainer.healthBar);

    indicator.left = indicator:CreateTexture(nil, 'BORDER');
    indicator.left:Hide();

    indicator.right = indicator:CreateTexture(nil, 'BORDER');
    indicator.right:SetTexCoord(1, 0, 0, 1); -- Hor flip
    indicator.right:Hide();

    local glowUp = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(glowUp, 'BOTTOMLEFT', unitframe.HealthBarsContainer.healthBar, 'TOPLEFT', 0, 0);
    PixelUtil.SetPoint(glowUp, 'BOTTOMRIGHT', unitframe.HealthBarsContainer.healthBar, 'TOPRIGHT', 0, 0);
    PixelUtil.SetHeight(glowUp, GLOW_SIZE);
    glowUp:SetTexture(GLOW_TEXTURE);
    glowUp:SetTexCoord(0, 1, 1, 0);
    glowUp:Hide();
    indicator.glowUp = glowUp;

    local glowDown = indicator:CreateTexture(nil, 'BORDER');
    PixelUtil.SetPoint(glowDown, 'TOPLEFT', unitframe.HealthBarsContainer.healthBar, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(glowDown, 'TOPRIGHT', unitframe.HealthBarsContainer.healthBar, 'BOTTOMRIGHT', 0, 0);
    PixelUtil.SetHeight(glowDown, GLOW_SIZE);
    glowDown:SetTexture(GLOW_TEXTURE);
    glowDown:Hide();
    indicator.glowDown = glowDown;

    unitframe.TargetIndicator = indicator;
    unitframe.TargetIndicator:Hide();

    indicator:HookScript('OnUpdate', OnUpdate);
end

local function UpdateStyle(unitframe)
    local targetIndicator = unitframe.TargetIndicator;

    targetIndicator:SetFrameStrata(FRAME_STRATA == 1 and targetIndicator:GetParent():GetFrameStrata() or FRAME_STRATA);

    PixelUtil.SetSize(targetIndicator.left, SIZE, SIZE);
    PixelUtil.SetSize(targetIndicator.right, SIZE, SIZE);

    PixelUtil.SetPoint(targetIndicator.left, 'RIGHT', unitframe.HealthBarsContainer.healthBar, 'LEFT', -X_OFFSET, Y_OFFSET);
    PixelUtil.SetPoint(targetIndicator.right, 'LEFT', unitframe.HealthBarsContainer.healthBar, 'RIGHT', X_OFFSET, Y_OFFSET);

    targetIndicator.left:SetTexture(TEXTURE);
    targetIndicator.right:SetTexture(TEXTURE);

    local r, g, b, a = TARGET_INDICATOR_COLOR[1], TARGET_INDICATOR_COLOR[2], TARGET_INDICATOR_COLOR[3], TARGET_INDICATOR_COLOR[4];
    targetIndicator.left:SetVertexColor(r, g, b, a);
    targetIndicator.right:SetVertexColor(r, g, b, a);

    r, g, b, a = TARGET_GLOW_COLOR[1], TARGET_GLOW_COLOR[2], TARGET_GLOW_COLOR[3], TARGET_GLOW_COLOR[4];
    targetIndicator.glowUp:SetVertexColor(r, g, b, a);
    targetIndicator.glowDown:SetVertexColor(r, g, b, a);

    PixelUtil.SetHeight(targetIndicator.glowUp, GLOW_SIZE);
    PixelUtil.SetHeight(targetIndicator.glowDown, GLOW_SIZE);
end

function Module:UpdateMouseoverUnit()
    self:ForAllActiveAndShownUnitFrames(function(unitframe)
        if not unitframe.data.isTarget and not unitframe.data.isPersonal then
            if MouseOnUnit(unitframe) then
                Glow_Show(unitframe);
            else
                Glow_Hide(unitframe);
            end
        end
    end);
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

    FRAME_STRATA = O.db.target_indicator_frame_strata ~= 1 and O.Lists.frame_strata[O.db.target_indicator_frame_strata] or 1;
    SIZE         = O.db.target_indicator_size;
    X_OFFSET     = O.db.target_indicator_x_offset;
    Y_OFFSET     = O.db.target_indicator_y_offset;
    TEXTURE      = O.Lists.target_indicator_texture_path[O.db.target_indicator_texture] or O.Lists.target_indicator_texture_path[1];

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

    if O.db.hover_glow_enabled then
        self:RegisterEvent('UPDATE_MOUSEOVER_UNIT', 'UpdateMouseoverUnit');
    else
        self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdateTargetSelection);
end