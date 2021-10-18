local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('MythicPlusSpiteful');

-- Libraires
local LCG = S.Libraries.LCG;
local LCG_ButtonGlow_Start, LCG_ButtonGlow_Stop = LCG.ButtonGlow_Start, LCG.ButtonGlow_Stop;

-- Local config
local ENABLED, ONLY_ON_ME, GLOW, GLOW_COLOR;

local PlayerName = D.Player.Name;

local SPITEFUL_NPC_ID  = 174773;
local SPITEFUL_TEXTURE = 135945;

local function Create(unitframe)
    if unitframe.Spiteful then
        return;
    end

    local frame = CreateFrame('Frame', '$parentSpiteful', unitframe.healthBar);
    frame:SetPoint('BOTTOM', unitframe, 'TOP', 0, 4);
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
            if ONLY_ON_ME then
                if unitframe.data.targetName == PlayerName then
                    if GLOW then
                        LCG_ButtonGlow_Start(unitframe.Spiteful, GLOW_COLOR);
                    else
                        LCG_ButtonGlow_Stop(unitframe.Spiteful);
                    end

                    unitframe.Spiteful:SetShown(true);
                else
                    LCG_ButtonGlow_Stop(unitframe.Spiteful);
                    unitframe.Spiteful:SetShown(false);
                end
            else
                if GLOW then
                    LCG_ButtonGlow_Start(unitframe.Spiteful, GLOW_COLOR);
                else
                    LCG_ButtonGlow_Stop(unitframe.Spiteful);
                end

                unitframe.Spiteful:SetShown(true);
            end
        else
            LCG_ButtonGlow_Stop(unitframe.Spiteful);
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
        LCG_ButtonGlow_Stop(unitframe.Spiteful);
        unitframe.Spiteful:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED    = O.db.spiteful_enabled;
    ONLY_ON_ME = O.db.spiteful_show_only_on_me;
    GLOW       = O.db.spiteful_glow;
    GLOW_COLOR = GLOW_COLOR or {};
    GLOW_COLOR[1] = O.db.spiteful_glow_color[1];
    GLOW_COLOR[2] = O.db.spiteful_glow_color[2];
    GLOW_COLOR[3] = O.db.spiteful_glow_color[3];
    GLOW_COLOR[4] = O.db.spiteful_glow_color[4] or 1;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end