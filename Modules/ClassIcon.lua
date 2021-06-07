local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('ClassIcon');

local ShouldShowName = S:GetNameplateModule('Handler').ShouldShowName;

-- Local Config
local ENABLED;

local classIconsCoords = S.Media.IconsClass.COORDS;

local function Create(unitframe)
    if unitframe.ClassIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentClassIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);

    frame.icon = frame:CreateTexture(nil, 'OVERLAY');
    PixelUtil.SetPoint(frame.icon, 'BOTTOM', unitframe.name, 'TOP', 0, 2);
    PixelUtil.SetSize(frame.icon, 12, 12);
    frame.icon:SetTexture(S.Media.IconsClass.TEXTURE);

    frame:SetShown(false);

    unitframe.ClassIcon = frame;
end

local function Update(unitframe)
    if ENABLED and unitframe.data.className and ShouldShowName(unitframe) then
        unitframe.ClassIcon.icon:SetTexCoord(unpack(classIconsCoords[unitframe.data.className]));
        unitframe.ClassIcon:SetShown(true);
    else
        unitframe.ClassIcon:SetShown(false);
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.ClassIcon then
        unitframe.ClassIcon:SetShown(false);
    end
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.class_icon_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end