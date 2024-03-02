local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('MythicPlusPercentage');

-- Lua API
local string_format = string.format;

-- Stripes API
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;

-- Local Config
local ENABLED, DB_MODE;
local POINT, RELATIVE_POINT, OFFSET_X, OFFSET_Y;

local StripesMythicPlusPercentageFont = CreateFont('StripesMythicPlusPercentageFont');

local PlayerState = D.Player.State;
local MythicPlusPercentage = D.MythicPlusPercentage;

local MDTLoaded = false;
local MDT;
local MDT_GetEnemyInfo;

local percentPattern = '%.2f%%';

local function Create(unitframe)
    if unitframe.MythicPlusPercentage then
        return;
    end

    local frame = CreateFrame('Frame', '$parentMythicPlusPercentage', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.text = frame:CreateFontString(nil, 'BACKGROUND', 'StripesMythicPlusPercentageFont');
    frame.text:SetTextColor(1, 1, 1);

    unitframe.MythicPlusPercentage = frame;
end

local function Update(unitframe)
    if not ENABLED or not PlayerState.inMythicPlus then
        unitframe.MythicPlusPercentage.text:SetText('');
        return;
    end

    local weight, count, max, maxTeeming;

    if DB_MODE == 1 then -- EMBEDDED
        local data = MythicPlusPercentage[unitframe.data.npcId];
        if data then
            count, max, maxTeeming = data.count, data.normal, data.teeming;
        end
    elseif DB_MODE == 2 then -- MDT
        if MDTLoaded then
            count, max, maxTeeming = MDT_GetEnemyInfo(MDT, unitframe.data.npcId);
        end
    end

    if count and max and maxTeeming then
        weight = (PlayerState.inMythicPlusTeeming and (count / maxTeeming) or (count / max)) * 100;
    end

    if weight and weight > 0 then
        unitframe.MythicPlusPercentage.text:ClearAllPoints();
        PixelUtil.SetPoint(unitframe.MythicPlusPercentage.text, POINT, unitframe.MythicPlusPercentage, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
        unitframe.MythicPlusPercentage.text:SetText(string_format(percentPattern, weight));
    else
        unitframe.MythicPlusPercentage.text:SetText('');
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.MythicPlusPercentage then
        unitframe.MythicPlusPercentage.text:SetText('');
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.mythic_plus_percentage_enabled;
    DB_MODE = MDTLoaded and O.db.mythic_plus_percentage_use_mode or 1;

    POINT          = O.Lists.frame_points[O.db.mythic_plus_percentage_point] or 'TOPRIGHT';
    RELATIVE_POINT = O.Lists.frame_points[O.db.mythic_plus_percentage_relative_point] or 'BOTTOMRIGHT';
    OFFSET_X       = O.db.mythic_plus_percentage_offset_x;
    OFFSET_Y       = O.db.mythic_plus_percentage_offset_y;

    UpdateFontObject(StripesMythicPlusPercentageFont, O.db.mythic_plus_percentage_font_value, O.db.mythic_plus_percentage_font_size, O.db.mythic_plus_percentage_font_flag, O.db.mythic_plus_percentage_font_shadow);
end

function Module:MythicDungeonTools()
    MDTLoaded        = true;
    MDT              = _G['MDT'];
    MDT_GetEnemyInfo = MDT.GetEnemyForces;

    DB_MODE = O.db.mythic_plus_percentage_use_mode;
end

function Module:StartUp()
    self:RegisterAddon('MythicDungeonTools');
    self:UpdateLocalConfig();
end