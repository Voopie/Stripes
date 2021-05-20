local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('FactionIcon');

local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;

-- Local Config
local ENABLED;

local factionIcons = {
    ['Alliance'] = 'Interface\\FriendsFrame\\PlusManz-Alliance',
    ['Horde']    = 'Interface\\FriendsFrame\\PlusManz-Horde',
};

local function Create(unitframe)
    if unitframe.FactionIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentFactionIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    PixelUtil.SetPoint(frame.icon, 'RIGHT', unitframe.name, 'LEFT', -2, 0);
    PixelUtil.SetSize(frame.icon, 12, 12);

    frame:SetShown(false);

    unitframe.FactionIcon = frame;
end

local function Update(unitframe)
    if ENABLED and unitframe.data.commonUnitType == 'PLAYER' and ShouldShowName(unitframe) and factionIcons[unitframe.data.factionGroup] then
        unitframe.FactionIcon.icon:SetTexture(factionIcons[unitframe.data.factionGroup]);
        unitframe.FactionIcon:SetShown(true);
    else
        unitframe.FactionIcon:SetShown(false);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.FactionIcon then
        unitframe.FactionIcon:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.faction_icon_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end