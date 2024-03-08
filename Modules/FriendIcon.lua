local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('FriendIcon');

-- Local Config
local ENABLED;

local function Create(unitframe)
    if unitframe.FriendIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentFriendIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint('LEFT', unitframe.name, 'RIGHT', 2, -1);
    icon:SetSize(10, 10);
    icon:SetAtlas('UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon-2x');

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

    local unitGUID = unitframe.data.unitGUID;

    unitframe.FriendIcon:SetShown(unitGUID and C_FriendList.IsFriend(unitGUID));
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