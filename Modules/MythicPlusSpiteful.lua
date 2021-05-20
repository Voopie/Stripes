local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('MythicPlusSpiteful');

local LCG = S.Libraries.LCG;
local LCG_PixelGlow_Start, LCG_PixelGlow_Stop = LCG.PixelGlow_Start, LCG.PixelGlow_Stop;

-- Local config
local ENABLED;

local SPITEFUL_NPC_ID  = 174773;
local SPITEFUL_TEXTURE = 135945;
local LSG_SUFFIX = 'S_SPITEFUL';

local function Create(unitframe)
    if unitframe.Spiteful then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpiteful', unitframe.healthBar);
    frame:SetPoint('BOTTOM', unitframe.name, 'TOP', 0, 4);
    frame:SetSize(32, 32);
    frame:SetFrameStrata('LOW');

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    frame.icon:SetAllPoints();
    frame.icon:SetTexture(SPITEFUL_TEXTURE);
    frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9);

    frame:SetShown(false);

    unitframe.Spiteful = frame;
end

local function Update(unitframe)
    if unitframe.data.unitType == 'SELF' then
        unitframe.Spiteful:SetShown(false);
        return;
    end

    if unitframe:IsShown() then
        if ENABLED and unitframe.data.npcId == SPITEFUL_NPC_ID then
            LCG_PixelGlow_Start(unitframe.Spiteful, nil, 16, nil, 6, nil, 1, 1, nil, LSG_SUFFIX);
            unitframe.Spiteful:SetShown(true);
        else
            LCG_PixelGlow_Stop(unitframe.Spiteful, LSG_SUFFIX);
            unitframe.Spiteful:SetShown(false);
        end
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.Spiteful then
        LCG_PixelGlow_Stop(unitframe.Spiteful, LSG_SUFFIX);
        unitframe.Spiteful:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.spiteful_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end