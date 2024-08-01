local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('MythicPlusExplosiveOrbs');
local Stripes = S:GetNameplateModule('Handler');

-- Stripes API
local S_UpdateFontObject = Stripes.UpdateFontObject;

-- Local Config
local CROSSHAIR, COUNTER;

local StripesExplosiveOrbsFont = CreateFont('StripesExplosiveOrbsFont');

local PlayerState = D.Player.State;

local EXPLOSIVE_ID      = 120651;
local EXPLOSIVE_TEXTURE = 2175503;

local OrbsCounterFrame = CreateFrame('Frame', 'Stripes_ExplosiveOrbsCounter', UIParent);
OrbsCounterFrame:SetPoint('CENTER', 0, -100);
OrbsCounterFrame:SetSize(44, 44);
OrbsCounterFrame:EnableMouse(true);
OrbsCounterFrame:SetMovable(true);
OrbsCounterFrame:SetClampedToScreen(true);
OrbsCounterFrame:RegisterForDrag('LeftButton');
OrbsCounterFrame:SetScript('OnDragStart', function(self) if self:IsMovable() then self:StartMoving(); end end);
OrbsCounterFrame:SetScript('OnDragStop', function(self) self:StopMovingOrSizing(); end);

OrbsCounterFrame.texture = OrbsCounterFrame:CreateTexture(nil, 'ARTWORK');
OrbsCounterFrame.texture:SetPoint('CENTER', 0, 0);
OrbsCounterFrame.texture:SetTexture(EXPLOSIVE_TEXTURE);
OrbsCounterFrame.texture:SetTexCoord(0.05, 0.95, 0.1, 0.6)
OrbsCounterFrame.texture:SetVertexColor(1, 1, 1, 1);
OrbsCounterFrame.texture:SetSize(42, 42);

OrbsCounterFrame.border = OrbsCounterFrame:CreateTexture(nil, 'BACKGROUND');
OrbsCounterFrame.border:SetColorTexture(1, 0, 0);
OrbsCounterFrame.border:SetPoint('TOPLEFT', OrbsCounterFrame, -1, 1);
OrbsCounterFrame.border:SetPoint('BOTTOMRIGHT', OrbsCounterFrame, 1, -1);

OrbsCounterFrame.count = OrbsCounterFrame:CreateFontString(nil, 'OVERLAY', 'StripesExplosiveOrbsFont');
OrbsCounterFrame.count:SetPoint('CENTER', 0, 0);

OrbsCounterFrame:Hide();

local counter = 0;
function Module:CountOrbs()
    if not COUNTER or not PlayerState.inMythicPlus then
        OrbsCounterFrame:Hide();
        return;
    end

    counter = 0;

    self:ForAllActiveAndShownUnitFrames(function(unitframe)
        if unitframe.data.npcId == EXPLOSIVE_ID then
            counter = counter + 1;
        end
    end);

    if counter > 0 then
        OrbsCounterFrame.count:SetText(counter);
        OrbsCounterFrame:Show();
    else
        OrbsCounterFrame:Hide();
    end
end

Module.OrbsCounterFrame = OrbsCounterFrame;

function Module:UpdateExplosive(unitframe)
    if not PlayerState.inMythicPlus then
        OrbsCounterFrame:Hide();

        unitframe.Explosive:Hide();

        return;
    end

    self:CountOrbs();

    if unitframe:IsShown() then
        if unitframe.data.npcId == EXPLOSIVE_ID then
            unitframe.Explosive:SetShown(CROSSHAIR);
        else
            unitframe.Explosive:Hide();
        end
    end
end

function Module:HideExplosive(unitframe)
    self:CountOrbs();

    if unitframe.Explosive then
        unitframe.Explosive:Hide();
    end
end

function Module:CreateExplosive(unitframe)
    if unitframe.Explosive then
        return;
    end

    local frame = CreateFrame('Frame', '$parentExplosive', unitframe.HealthBarsContainer.healthBar);
    frame:SetAllPoints(unitframe.HealthBarsContainer.healthBar);

    local icon = frame:CreateTexture(nil, 'ARTWORK', nil, 2);
    icon:SetPoint('BOTTOM', unitframe, 'TOP', 0, 4);
    icon:SetSize(24, 16);
    icon:SetTexture(EXPLOSIVE_TEXTURE);
    icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);

    local border = frame:CreateTexture(nil, 'BORDER');
    border:SetPoint('TOPLEFT', icon, 'TOPLEFT', -1, 1);
    border:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 1, -1);
    border:SetColorTexture(1, 0, 0);

    local vertLine = frame:CreateTexture(nil, 'ARTWORK', nil, 1);
    vertLine:SetPoint('CENTER', icon, 'CENTER', 0, 0);
    vertLine:SetSize(2, 30000);
    vertLine:SetTexture('Interface\\Buttons\\WHITE8x8');
    vertLine:SetVertexColor(1, 0, 0, 0.5);

    local horLine = frame:CreateTexture(nil, 'ARTWORK', nil, 1);
    horLine:SetPoint('CENTER', icon, 'CENTER', 0, 0);
    horLine:SetSize(30000, 2);
    horLine:SetTexture('Interface\\Buttons\\WHITE8x8');
    horLine:SetVertexColor(1, 0, 0, 0.5);

    unitframe.Explosive = frame;
    unitframe.Explosive:Hide();
end

function Module:UnitAdded(unitframe)
    self:CreateExplosive(unitframe);
    self:UpdateExplosive(unitframe);
end

function Module:UnitRemoved(unitframe)
    self:HideExplosive(unitframe);
end

function Module:Update(unitframe)
    self:UpdateExplosive(unitframe);
end

function Module:UpdateLocalConfig()
    CROSSHAIR = O.db.explosive_orbs_crosshair;
    COUNTER   = O.db.explosive_orbs_counter;

    S_UpdateFontObject(StripesExplosiveOrbsFont, O.db.explosive_orbs_font_value, O.db.explosive_orbs_font_size, O.db.explosive_orbs_font_flag, O.db.explosive_orbs_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();
end