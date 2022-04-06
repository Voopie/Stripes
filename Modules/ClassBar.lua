local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('ClassBar');

-- Local config
local SCALE, OFFSET_X, OFFSET_Y;
local SHOW_ON_TARGET;

local function UpdatePosition(unitframe)
    if not SHOW_ON_TARGET then
        return;
    end

    if not NamePlateDriverFrame.classNamePlateMechanicFrame then
        return;
    end

    if unitframe.data.unitType == 'SELF' then
        if NamePlateDriverFrame.classNamePlatePowerBar then
            NamePlateDriverFrame.classNamePlateMechanicFrame:ClearAllPoints();
            NamePlateDriverFrame.classNamePlateMechanicFrame:SetPoint('TOP', NamePlateDriverFrame.classNamePlatePowerBar, 'BOTTOM', 0, NamePlateDriverFrame.classNamePlateMechanicFrame.paddingOverride or -4);
        end
    else
        NamePlateDriverFrame.classNamePlateMechanicFrame:ClearAllPoints();
        PixelUtil.SetPoint(NamePlateDriverFrame.classNamePlateMechanicFrame, 'BOTTOM', unitframe.name, 'TOP', OFFSET_X, 14 + OFFSET_Y); -- Don't ask me why 14
    end
end

local function UpdateScale()
    if NamePlateDriverFrame.classNamePlateMechanicFrame then
        NamePlateDriverFrame.classNamePlateMechanicFrame:SetScale(SCALE);
    end
end

function Module:UnitAdded(unitframe)
    UpdatePosition(unitframe);
end

function Module:Update(unitframe)
    UpdatePosition(unitframe);
end

function Module:UpdateLocalConfig()
    SCALE    = O.db.class_bar_scale;
    OFFSET_X = O.db.class_bar_offset_x;
    OFFSET_Y = O.db.class_bar_offset_y;

    SHOW_ON_TARGET = O.db.show_personal_resource_ontarget;

    UpdateScale();
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateSelectionHighlight', UpdatePosition);
end