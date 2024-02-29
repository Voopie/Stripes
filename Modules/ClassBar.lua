local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('ClassBar');

-- Local Config
local ALPHA, SCALE, POINT, RELATIVE_POINT, OFFSET_X, OFFSET_Y;
local SHOW_ON_TARGET;

local function UpdatePositionForUnitFrame(unitframe)
    local mechanicFrame = NamePlateDriverFrame.classNamePlateMechanicFrame;

    if not (mechanicFrame and SHOW_ON_TARGET) then
        return;
    end

    if unitframe.data.isPersonal then
        if NamePlateDriverFrame.classNamePlatePowerBar then
            mechanicFrame:ClearAllPoints();
            mechanicFrame:SetPoint('TOP', NamePlateDriverFrame.classNamePlatePowerBar, 'BOTTOM', 0, NamePlateDriverFrame.classNamePlateMechanicFrame.paddingOverride or -4);
        end
    elseif unitframe.data.isTarget then
        mechanicFrame:ClearAllPoints();
        mechanicFrame:SetPoint(POINT, unitframe.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    end
end

local function UpdatePositionForDriverFrame()
    local mechanicFrame = NamePlateDriverFrame.classNamePlateMechanicFrame;

    if not (mechanicFrame and SHOW_ON_TARGET) then
        return;
    end

    local namePlatePlayer = C_NamePlate.GetNamePlateForUnit('player');
    local namePlateTarget = C_NamePlate.GetNamePlateForUnit('target');

    if namePlatePlayer then
        if NamePlateDriverFrame.classNamePlatePowerBar then
            mechanicFrame:ClearAllPoints();
            mechanicFrame:SetPoint('TOP', NamePlateDriverFrame.classNamePlatePowerBar, 'BOTTOM', 0, mechanicFrame.paddingOverride or -4);
        end
    elseif namePlateTarget then
        mechanicFrame:ClearAllPoints();
        mechanicFrame:SetPoint(POINT, namePlateTarget.UnitFrame.healthBar, RELATIVE_POINT, OFFSET_X, OFFSET_Y);
    end
end

local function UpdateAlphaAndScale()
    local mechanicFrame = NamePlateDriverFrame.classNamePlateMechanicFrame;

    if not mechanicFrame then
        return;
    end

    mechanicFrame:SetAlpha(ALPHA);
    mechanicFrame:SetScale(SCALE);
end

function Module:Update(unitframe)
    UpdatePositionForUnitFrame(unitframe);
end

function Module:UpdateLocalConfig()
    ALPHA = O.db.class_bar_alpha;
    SCALE = O.db.class_bar_scale;

    POINT          = O.Lists.frame_points[O.db.class_bar_point] or 'BOTTOM';
    RELATIVE_POINT = O.Lists.frame_points[O.db.class_bar_relative_point] or 'TOP';
    OFFSET_X       = O.db.class_bar_offset_x;
    OFFSET_Y       = O.db.class_bar_offset_y;

    SHOW_ON_TARGET = O.db.show_personal_resource_ontarget;

    UpdateAlphaAndScale();
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureHook('NamePlateDriverFrame', 'SetupClassNameplateBars', UpdatePositionForDriverFrame);
end