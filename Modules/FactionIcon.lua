local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('FactionIcon');

local S_ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;

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
    frame:SetAllPoints(unitframe.HealthBarsContainer.healthBar);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint('RIGHT', unitframe.name, 'LEFT', -2, 0);
    icon:SetSize(12, 12);

    frame.icon = icon;

    frame:Hide();

    unitframe.FactionIcon = frame;
end

local function Update(unitframe)
    if not unitframe.FactionIcon then
        return;
    end

    local shouldShowTexture = ENABLED and unitframe.data.commonUnitType == 'PLAYER' and S_ShouldShowName(unitframe) and factionIcons[unitframe.data.factionGroup];

    if shouldShowTexture then
        unitframe.FactionIcon.icon:SetTexture(shouldShowTexture);
        unitframe.FactionIcon:Show();
    else
        unitframe.FactionIcon:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.FactionIcon then
        unitframe.FactionIcon:Hide();
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