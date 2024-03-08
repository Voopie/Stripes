local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('ClassIcon');

local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;

-- Local Config
local ENABLED, ONLY_IN_ARENA, ONLY_ENEMY;

local PlayerState = D.Player.State;

local classIconsTexture, classIconsCoords = S.Media.IconsClass.TEXTURE, S.Media.IconsClass.COORDS;

local function Create(unitframe)
    if unitframe.ClassIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentClassIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    PixelUtil.SetPoint(icon, 'BOTTOM', unitframe.name, 'TOP', 0, 2);
    PixelUtil.SetSize(icon, 12, 12);
    icon:SetTexture(classIconsTexture);

    frame.icon = icon;

    frame:Hide();

    unitframe.ClassIcon = frame;
end

local function Update(unitframe)
    if not unitframe.ClassIcon then
        return;
    end

    if not (ENABLED and unitframe.data.className and ShouldShowName(unitframe)) then
        unitframe.ClassIcon:Hide();
        return;
    end

    local shouldShow = ONLY_IN_ARENA and PlayerState.inArena or ONLY_ENEMY and unitframe.data.unitType == 'ENEMY_PLAYER' or not ONLY_IN_ARENA and not ONLY_ENEMY;

    if shouldShow then
        unitframe.ClassIcon.icon:SetTexCoord(unpack(classIconsCoords[unitframe.data.className]));
        unitframe.ClassIcon:Show();
    else
        unitframe.ClassIcon:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.ClassIcon then
        unitframe.ClassIcon:Hide();
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED       = O.db.class_icon_enabled;
    ONLY_IN_ARENA = O.db.class_icon_arena_only;
    ONLY_ENEMY    = O.db.class_icon_enemy_only;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end