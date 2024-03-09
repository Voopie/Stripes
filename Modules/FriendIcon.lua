local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('FriendIcon');

local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;

-- Local Config
local ENABLED;

local function Create(unitframe)
    if unitframe.FriendIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentFriendIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint('LEFT', unitframe.name, 'RIGHT', 0, 0);
    icon:SetSize(12, 12);
    icon:SetAtlas('groupfinder-icon-friend');

    frame.icon = icon;

    frame:Hide();

    unitframe.FriendIcon = frame;
end

local function Update(unitframe)
    if not unitframe.FriendIcon then
        return;
    end

    if not (ENABLED and unitframe.data.isPlayer) then
        unitframe.FriendIcon:Hide();
        return;
    end

    local unitGUID   = unitframe.data.unitGUID;
    local shouldShow = ShouldShowName(unitframe) and unitGUID and C_FriendList.IsFriend(unitGUID);

    unitframe.FriendIcon:SetShown(shouldShow);
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.FriendIcon then
        unitframe.FriendIcon:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.friend_icon_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end