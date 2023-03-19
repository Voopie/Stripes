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

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    PixelUtil.SetPoint(frame.icon, 'BOTTOM', unitframe.name, 'TOP', 0, 2);
    PixelUtil.SetSize(frame.icon, 12, 12);
    frame.icon:SetTexture(classIconsTexture);

    frame:Hide();

    unitframe.ClassIcon = frame;
end

local function Update(unitframe)
    if not ENABLED or not unitframe.data.className or not ShouldShowName(unitframe) then
        unitframe.ClassIcon:Hide();
        return;
    end

    if ONLY_IN_ARENA then
        if PlayerState.inArena then
            unitframe.ClassIcon.icon:SetTexCoord(unpack(classIconsCoords[unitframe.data.className]));
            unitframe.ClassIcon:Show();
        else
            unitframe.ClassIcon:Hide();
        end
    else
        if ONLY_ENEMY then
            if unitframe.data.unitType == 'ENEMY_PLAYER' then
                unitframe.ClassIcon.icon:SetTexCoord(unpack(classIconsCoords[unitframe.data.className]));
                unitframe.ClassIcon:Show();
            else
                unitframe.ClassIcon:Hide();
            end
        else
            unitframe.ClassIcon.icon:SetTexCoord(unpack(classIconsCoords[unitframe.data.className]));
            unitframe.ClassIcon:Show();
        end
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