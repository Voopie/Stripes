local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('TotemIcon');

-- Local Config
local ENABLED;

local TOTEM_TEXTURE = 971076;

local TOTEM_LOCALIZED_NAME = {
    ['enUS'] = 'Totem',
    ['deDE'] = 'Totem',
    ['esES'] = 'Tótem',
    ['esMX'] = 'Totém',
    ['frFR'] = 'Totem',
    ['itIT'] = 'Totem',
    ['ptBR'] = 'Totem',
    ['ruRU'] = 'Тотем',
    ['koKR'] = '토템',
    ['zhCN'] = '图腾',
    ['zhTW'] = '圖騰',
};

local TOTEM_NAME = TOTEM_LOCALIZED_NAME[S.ClientLocale];

local EXPLOSIVE_ID = 120651;

local function Create(unitframe)
    if unitframe.TotemIcon then
        return;
    end

    local frame = CreateFrame('Frame', '$parentTotemIcon', unitframe);
    frame:SetAllPoints(unitframe.healthBar);
    frame:SetFrameStrata('HIGH');

    local icon = frame:CreateTexture(nil, 'OVERLAY');
    icon:SetPoint('BOTTOM', unitframe, 'TOP', 0, 0);
    icon:SetTexture(TOTEM_TEXTURE);
    icon:SetTexCoord(0.05, 0.95, 0.1, 0.6);
    icon:SetSize(24, 16);

    local border = frame:CreateTexture(nil, 'BORDER');
    border:SetPoint('TOPLEFT', icon, 'TOPLEFT', -1, 1);
    border:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 1, -1);
    border:SetColorTexture(0.3, 0.3, 0.3);

    frame.icon   = icon;
    frame.border = border;

    frame:Hide();

    unitframe.TotemIcon = frame;
end

local function Update(unitframe)
    unitframe.TotemIcon:SetShown(ENABLED and unitframe.data.npcId ~= EXPLOSIVE_ID and unitframe.data.creatureType == TOTEM_NAME);
end

local function Hide(unitframe)
    if unitframe.TotemIcon then
        unitframe.TotemIcon:Hide();
    end
end

function Module:UnitAdded(unitframe)
    Create(unitframe);
    Update(unitframe);
end

function Module:UnitRemoved(unitframe)
    Hide(unitframe);
end

function Module:Update(unitframe)
    Update(unitframe);
end

function Module:UpdateLocalConfig()
    ENABLED = O.db.totem_icon_enabled;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end