local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('MythicPlusExplosiveOrbs');

-- Lua API
local pairs = pairs;

-- Nameplates frames
local NP = S.NamePlates;

-- Local Config
local CROSSHAIR, COUNTER;

local PlayerState = D.Player.State;

local EXPLOSIVE_ID = 120651;
local EXPLOSIVE_TEXTURE = 2175503;

local OrbsCounter = CreateFrame('Frame', 'Stripes_ExplosiveOrbsCounter', UIParent);
OrbsCounter:SetPoint('CENTER', 0, -100);
OrbsCounter:SetSize(44, 44);
OrbsCounter:EnableMouse(true);
OrbsCounter:SetMovable(true);
OrbsCounter:SetClampedToScreen(true);
OrbsCounter:RegisterForDrag('LeftButton');
OrbsCounter:SetScript('OnDragStart', function(self) if self:IsMovable() then self:StartMoving(); end end);
OrbsCounter:SetScript('OnDragStop', function(self) self:StopMovingOrSizing(); end);

OrbsCounter.texture = OrbsCounter:CreateTexture(nil, 'ARTWORK');
OrbsCounter.texture:SetPoint('CENTER', 0, 0);
OrbsCounter.texture:SetTexture(EXPLOSIVE_TEXTURE);
OrbsCounter.texture:SetTexCoord(0.05, 0.95, 0.1, 0.6)
OrbsCounter.texture:SetVertexColor(1, 1, 1, 1);
OrbsCounter.texture:SetSize(42, 42);

OrbsCounter.border = OrbsCounter:CreateTexture(nil, 'BACKGROUND');
OrbsCounter.border:SetColorTexture(1, 0, 0);
OrbsCounter.border:SetPoint('TOPLEFT', OrbsCounter, -1, 1);
OrbsCounter.border:SetPoint('BOTTOMRIGHT', OrbsCounter, 1, -1);

OrbsCounter.count = OrbsCounter:CreateFontString();
OrbsCounter.count:SetPoint('CENTER', 0, 0);
OrbsCounter.count:SetFont(S.Media.Fonts['BigNoodleToo Oblique'], 26, 'OUTLINE');
OrbsCounter.count:SetTextColor(1, 1, 1);
OrbsCounter.count:SetShadowOffset(1, -1);
OrbsCounter.count:SetShadowColor(0, 0, 0);

OrbsCounter:Hide();

local counter = 0;
local function CountOrbs()
    if not COUNTER or not PlayerState.inMythicPlus then
        OrbsCounter:Hide();
        return;
    end

    counter = 0;

    for _, unitframe in pairs(NP) do
        if unitframe:IsShown() and unitframe.data.npcId == EXPLOSIVE_ID then
            counter = counter + 1;
        end
    end

    if counter > 0 then
        OrbsCounter.count:SetText(counter);
        OrbsCounter:Show();
    else
        OrbsCounter:Hide();
    end
end

OrbsCounter.CountOrbs = CountOrbs;
Module.OrbsCounter = OrbsCounter;

local function Update(unitframe)
    if not PlayerState.inMythicPlus then
        OrbsCounter:Hide();

        unitframe.Explosive:Hide();

        return;
    end

    CountOrbs();

    if unitframe:IsShown() then
        if unitframe.data.npcId == EXPLOSIVE_ID then
            unitframe.Explosive:SetShown(CROSSHAIR);
        else
            unitframe.Explosive:Hide();
        end
    end
end

local function Hide(unitframe)
    CountOrbs();

    if unitframe.Explosive then
        unitframe.Explosive:Hide();
    end
end

local function Create(unitframe)
    if unitframe.Explosive then
        return;
    end

    local frame = CreateFrame('Frame', '$parentExplosive', unitframe.healthBar);
    frame:SetAllPoints(unitframe.healthBar);

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
    CROSSHAIR = O.db.explosive_orbs_crosshair;
    COUNTER   = O.db.explosive_orbs_counter;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end