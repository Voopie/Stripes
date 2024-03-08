local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewNameplateModule('CastBar');
local Stripes = S:GetNameplateModule('Handler');

-- Lua API
local string_format, math_max = string.format, math.max;

-- Stripes API
local UpdateFontObject = Stripes.UpdateFontObject;

-- Libraries
local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Local Config
local TIMER_ENABLED, TIMER_ONLY_REMAINING, TIMER_XSIDE, TIMER_ANCHOR, TIMER_OFFSET_X, TIMER_OFFSET_Y, ON_HP_BAR, ICON_LARGE, ICON_RIGHT_SIDE;
local START_CAST_COLOR, START_CHANNEL_COLOR, NONINTERRUPTIBLE_COLOR, FAILED_CAST_COLOR, INTERRUPT_READY_IN_TIME_COLOR, INTERRUPT_NOT_READY_COLOR;
local USE_INTERRUPT_READY_IN_TIME_COLOR, USE_INTERRUPT_NOT_READY_COLOR;
local STATUSBAR_TEXTURE;
local ENEMY_WIDTH, FRIENDLY_WIDTH, PLAYER_WIDTH;
local SHOW_TRADE_SKILLS, SHOW_SHIELD, SHOW_ICON_NOTINTERRUPTIBLE;
local SHOW_INTERRUPT_READY_TICK, INTERRUPT_READY_TICK_COLOR;
local BORDER_ENABLED, BORDER_COLOR, BORDER_SIZE;
local BAR_HEIGHT;
local TEXT_POSITION, TEXT_X_OFFSET, TEXT_Y_OFFSET, TEXT_TRUNCATE;
local TARGET_NAME_ENABLED, TARGET_NAME_CLASS_COLOR, TARGET_NAME_ONLY_ENEMY, TARGET_NAME_IN_SPELL_NAME, TARGET_NAME_POINT, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y;
local CAST_BAR_BACKGROUND_TEXTURE, CAST_BAR_BACKGROUND_COLOR;
local CAST_BAR_FRAME_STRATA, CAST_BAR_OFFSET_Y;

local StripesCastBarFont = CreateFont('StripesCastBarFont');
local StripesCastBarTimerFont = CreateFont('StripesCastBarTimerFont');
local StripesCastBarTargetFont = CreateFont('StripesCastBarTargetFont');

local WIDTH_OFFSET = 24;
local updateDelay = 0.05;
local TIMER_FORMAT = '%.2f / %.2f';

local ANCHOR_MIRROR = {
    ['LEFT']   = 'RIGHT',
    ['CENTER'] = 'CENTER',
    ['RIGHT']  = 'LEFT',
};

local function OnUpdate(self, elapsed)
    if not TIMER_ENABLED then
        return;
    end

    if self.updateDelay and self.updateDelay < elapsed then
        if self.casting then
            self.Timer:SetText(string_format(TIMER_FORMAT, math_max(self.maxValue - self.value, 0), self.maxValue));
        elseif self.channeling then
            self.Timer:SetText(string_format(TIMER_FORMAT, math_max(self.value, 0), self.maxValue));
        else
            self.Timer:SetText('');
        end

        self.updateDelay = updateDelay;
    else
        self.updateDelay = self.updateDelay - elapsed;
    end
end

local function UpdateBarTexture(unitframe)
    unitframe.castingBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, STATUSBAR_TEXTURE));

    if unitframe.castingBar.Flash then
        unitframe.castingBar.Flash:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, STATUSBAR_TEXTURE));
    end
end

local function UpdateStyle(unitframe)
    local castingBar             = unitframe.castingBar;
    local castingBarIcon         = castingBar.Icon;
    local castingBarBorderShield = castingBar.BorderShield;

    local healthBar = unitframe.healthBar;

    castingBar:ClearAllPoints();
    castingBarIcon:ClearAllPoints();
    healthBar:ClearAllPoints();

    local healthBarHeight = healthBar.sHeight or 12;

    PixelUtil.SetHeight(castingBar, ON_HP_BAR and healthBarHeight or BAR_HEIGHT);

    if ON_HP_BAR then
        PixelUtil.SetPoint(healthBar, 'BOTTOM', unitframe, 'BOTTOM', 0, 6 + 2 + BAR_HEIGHT);

        local healthBarWidth = unitframe.data.isPersonal and PLAYER_WIDTH or (unitframe.data.commonReaction == 'ENEMY' and ENEMY_WIDTH or FRIENDLY_WIDTH);
        PixelUtil.SetWidth(healthBar, healthBarWidth - WIDTH_OFFSET);

        PixelUtil.SetPoint(castingBar, 'BOTTOMLEFT', healthBar, 'TOPLEFT', 0, -healthBarHeight);
        PixelUtil.SetPoint(castingBar, 'BOTTOMRIGHT', healthBar, 'TOPRIGHT', 0, -healthBarHeight);

        PixelUtil.SetPoint(castingBarIcon, ICON_RIGHT_SIDE and 'LEFT' or 'RIGHT', castingBar, ICON_RIGHT_SIDE and 'RIGHT' or 'LEFT', 0, 0);
        PixelUtil.SetSize(castingBarIcon, healthBarHeight, healthBarHeight);
    else
        PixelUtil.SetPoint(castingBar, 'BOTTOM', unitframe, 'BOTTOM', 0, 6);

        local castingBarWidth = unitframe.data.isPersonal and PLAYER_WIDTH or (unitframe.data.commonReaction == 'ENEMY' and ENEMY_WIDTH or FRIENDLY_WIDTH);
        PixelUtil.SetWidth(castingBar, castingBarWidth - WIDTH_OFFSET);

        PixelUtil.SetPoint(healthBar, 'BOTTOMLEFT', castingBar, 'TOPLEFT', 0, CAST_BAR_OFFSET_Y);
        PixelUtil.SetPoint(healthBar, 'BOTTOMRIGHT', castingBar, 'TOPRIGHT', 0, CAST_BAR_OFFSET_Y);

        local iconWidth = BAR_HEIGHT + (BORDER_ENABLED and BORDER_SIZE or 0);

        if ICON_LARGE then
            PixelUtil.SetPoint(castingBarIcon, ICON_RIGHT_SIDE and 'TOPLEFT' or 'TOPRIGHT', healthBar, ICON_RIGHT_SIDE and 'TOPRIGHT' or 'TOPLEFT', ICON_RIGHT_SIDE and 1 or -1, 0.5);
            PixelUtil.SetPoint(castingBarIcon, ICON_RIGHT_SIDE and 'BOTTOMLEFT' or 'BOTTOMRIGHT', castingBar, ICON_RIGHT_SIDE and 'BOTTOMRIGHT' or 'BOTTOMLEFT', 0, BORDER_ENABLED and -BORDER_SIZE or 0);
            PixelUtil.SetWidth(castingBarIcon, 2 + healthBarHeight + iconWidth);
        else
            PixelUtil.SetPoint(castingBarIcon, ICON_RIGHT_SIDE and 'LEFT' or 'RIGHT', castingBar, ICON_RIGHT_SIDE and 'RIGHT' or 'LEFT', 0, 0);
            PixelUtil.SetSize(castingBarIcon, iconWidth, iconWidth);
        end
    end

    -- Shield Icon Position
    PixelUtil.SetPoint(castingBarBorderShield, 'CENTER', castingBarIcon, (ON_HP_BAR or not ICON_LARGE) and 'CENTER' or 'BOTTOM', 0, 0);
end

local function UpdateColors(unitframe)
    if not unitframe.castingBar then
        return;
    end

    local castingBar = unitframe.castingBar;

    StripesCastingBar_SetStartCastColor(castingBar, START_CAST_COLOR[1], START_CAST_COLOR[2], START_CAST_COLOR[3], START_CAST_COLOR[4]);
    StripesCastingBar_SetStartChannelColor(castingBar, START_CHANNEL_COLOR[1], START_CHANNEL_COLOR[2], START_CHANNEL_COLOR[3], START_CHANNEL_COLOR[4]);
    StripesCastingBar_SetNonInterruptibleCastColor(castingBar, NONINTERRUPTIBLE_COLOR[1], NONINTERRUPTIBLE_COLOR[2], NONINTERRUPTIBLE_COLOR[3], NONINTERRUPTIBLE_COLOR[4]);
    StripesCastingBar_SetFailedCastColor(castingBar, FAILED_CAST_COLOR[1], FAILED_CAST_COLOR[2], FAILED_CAST_COLOR[3], FAILED_CAST_COLOR[4]);
    StripesCastingBar_SetInterruptReadyInTimeCastColor(castingBar, INTERRUPT_READY_IN_TIME_COLOR[1], INTERRUPT_READY_IN_TIME_COLOR[2], INTERRUPT_READY_IN_TIME_COLOR[3], INTERRUPT_READY_IN_TIME_COLOR[4]);
    StripesCastingBar_SetInterruptNotReadyCastColor(castingBar, INTERRUPT_NOT_READY_COLOR[1], INTERRUPT_NOT_READY_COLOR[2], INTERRUPT_NOT_READY_COLOR[3], INTERRUPT_NOT_READY_COLOR[4]);

    if castingBar.InterruptReadyTick then
        castingBar.InterruptReadyTick:SetVertexColor(INTERRUPT_READY_TICK_COLOR[1], INTERRUPT_READY_TICK_COLOR[2], INTERRUPT_READY_TICK_COLOR[3], INTERRUPT_READY_TICK_COLOR[4]);
    end
end

-- '[XY]_OFFSET' will be replaced with TEXT_[XY]_OFFSET
local castBarTextPositions = {
    [1] = { -- LEFT
        justifyH = 'LEFT',
        positions = {
            truncate = {
                wordWrap = false,
                points = {
                    { 'RIGHT', 0, 0 },
                    { 'LEFT', 'X_OFFSET', 'Y_OFFSET' },
                }
            },

            nontruncate = {
                wordWrap = true,
                points = {
                    { 'LEFT', 'X_OFFSET', 'Y_OFFSET' },
                }
            }
        }
    },

    [2] = { -- CENTER
        justifyH = 'CENTER',
        positions = {
            truncate = {
                wordWrap = false,
                points = {
                    { 'RIGHT', 'X_OFFSET', 'Y_OFFSET' },
                    { 'LEFT', 'X_OFFSET', 'Y_OFFSET' },
                }
            },

            nontruncate = {
                wordWrap = true,
                points = {
                    { 'CENTER', 'X_OFFSET', 'Y_OFFSET' },
                }
            }
        }
    },

    [3] = { -- RIGHT
        justifyH = 'RIGHT',
        positions = {
            truncate = {
                wordWrap = false,
                points = {
                    { 'RIGHT', 'X_OFFSET', 'Y_OFFSET' },
                    { 'LEFT', 0, 0 },
                }
            },

            nontruncate = {
                wordWrap = true,
                points = {
                    { 'RIGHT', 'X_OFFSET', 'Y_OFFSET' },
                }
            }
        }
    }
};

local function UpdateTextPosition(unitframe)
    local castingBarText = unitframe.castingBar.Text;

    local posTable  = castBarTextPositions[TEXT_POSITION];
    local modeTable = TEXT_TRUNCATE and posTable.positions.truncate or posTable.positions.nontruncate;

    local justifyH = posTable.justifyH;
    local wordWrap = modeTable.wordWrap;
    local points   = modeTable.points;

    castingBarText:ClearAllPoints();
    castingBarText:SetJustifyH(justifyH);
    castingBarText:SetWordWrap(wordWrap);

    for _, point in ipairs(points) do
        local xOffset = point[2] == 'X_OFFSET' and TEXT_X_OFFSET or point[2];
        local yOffset = point[3] == 'Y_OFFSET' and TEXT_Y_OFFSET or point[3];

        castingBarText:SetPoint(point[1], xOffset, yOffset);
    end
end

local function CreateCastingBarAndTimer(unitframe)
    if not unitframe.castBar or (unitframe.castingBar and unitframe.castingBar.Timer) then
        return;
    end

    if not unitframe.castingBar then
        unitframe.castingBar = CreateFrame('StatusBar', nil, unitframe, 'StripesNameplateCastBarTemplate');
        unitframe.castingBar:SetFrameStrata(CAST_BAR_FRAME_STRATA == 1 and unitframe.castingBar:GetParent():GetFrameStrata() or CAST_BAR_FRAME_STRATA);
    end

    UpdateTextPosition(unitframe);

    local castingBar = unitframe.castingBar;

    castingBar.Timer = castingBar:CreateFontString(nil, 'OVERLAY', 'StripesCastBarTimerFont');
    PixelUtil.SetPoint(castingBar.Timer, TIMER_XSIDE == 1 and ANCHOR_MIRROR[TIMER_ANCHOR] or TIMER_ANCHOR, castingBar, TIMER_ANCHOR, TIMER_OFFSET_X, 0);
    castingBar.Timer:SetTextColor(1, 1, 1);
    castingBar.updateDelay = updateDelay;
    castingBar:HookScript('OnUpdate', OnUpdate);

    castingBar.TargetText:ClearAllPoints();
    PixelUtil.SetPoint(castingBar.TargetText, TARGET_NAME_POINT, castingBar, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y);

    StripesCastingBar_AddWidgetForFade(castingBar, castingBar.Icon);
    StripesCastingBar_AddWidgetForFade(castingBar, castingBar.BorderShield);
    StripesCastingBar_AddWidgetForFade(castingBar, castingBar.Timer);
    StripesCastingBar_AddWidgetForFade(castingBar, castingBar.TargetText);
end

local function UpdateVisibility(unitframe)
    local castBar = unitframe.castBar;

    if castBar then
        castBar:UnregisterAllEvents();
        castBar:Hide();
    end

    local castingBar = unitframe.castingBar;

    if not castingBar then
        return;
    end

    local unit = unitframe.data.unit;

    if unitframe.data.isUnimportantUnit or unitframe.data.isPersonal or Stripes.NameOnly:IsActive(unitframe) then
        StripesCastingBar_SetUnit(castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
        return;
    end

    StripesCastingBar_SetUnit(castingBar, unit, SHOW_TRADE_SKILLS, SHOW_SHIELD);

    castingBar:SetFrameStrata(CAST_BAR_FRAME_STRATA == 1 and castingBar:GetParent():GetFrameStrata() or CAST_BAR_FRAME_STRATA);

    castingBar.iconWhenNoninterruptible     = SHOW_ICON_NOTINTERRUPTIBLE;
    castingBar.showInterruptReadyTick       = SHOW_INTERRUPT_READY_TICK;
    castingBar.useInterruptReadyInTimeColor = USE_INTERRUPT_READY_IN_TIME_COLOR;
    castingBar.useInterruptNotReadyColor    = USE_INTERRUPT_NOT_READY_COLOR;
    castingBar.showCastTargetName           = TARGET_NAME_ENABLED;
    castingBar.castTargetNameOnlyEnemy      = TARGET_NAME_ONLY_ENEMY;
    castingBar.castTargetNameInSpellName    = TARGET_NAME_IN_SPELL_NAME;
    castingBar.castTargetNameUseClassColor  = TARGET_NAME_CLASS_COLOR;

    local castingBarBorder = castingBar.border;

    if BORDER_ENABLED then
        castingBarBorder:SetVertexColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
        castingBarBorder:SetBorderSizes(BORDER_SIZE, BORDER_SIZE - 0.5);
        castingBarBorder:UpdateSizes();
        castingBarBorder:Show();
    else
        castingBarBorder:Hide();
    end

    UpdateTextPosition(unitframe);

    castingBar.Timer:ClearAllPoints();
    PixelUtil.SetPoint(castingBar.Timer, TIMER_XSIDE == 1 and ANCHOR_MIRROR[TIMER_ANCHOR] or TIMER_ANCHOR, castingBar, TIMER_ANCHOR, TIMER_OFFSET_X, TIMER_OFFSET_Y);

    castingBar.TargetText:ClearAllPoints();
    PixelUtil.SetPoint(castingBar.TargetText, TARGET_NAME_POINT, castingBar, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y);
end

local function UpdateBorderSizes(unitframe)
    if BORDER_ENABLED and unitframe.castingBar then
        unitframe.castingBar.border:UpdateSizes();
    end
end

local function UpdateBackgroundTexture(unitframe)
    if not unitframe.castingBar.background then
        return;
    end

    unitframe.castingBar.background:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, CAST_BAR_BACKGROUND_TEXTURE));
    unitframe.castingBar.background:SetVertexColor(CAST_BAR_BACKGROUND_COLOR[1], CAST_BAR_BACKGROUND_COLOR[2], CAST_BAR_BACKGROUND_COLOR[3], CAST_BAR_BACKGROUND_COLOR[4])
end

function Module:UnitAdded(unitframe)
    CreateCastingBarAndTimer(unitframe);
    UpdateBarTexture(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateColors(unitframe);
    UpdateStyle(unitframe);
    UpdateVisibility(unitframe);

    if unitframe.data.isUnimportantUnit then
        StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
    end
end

function Module:UnitRemoved(unitframe)
    if unitframe.castingBar then
        StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
    end
end

function Module:Update(unitframe)
    UpdateBarTexture(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateColors(unitframe);
    UpdateStyle(unitframe);
    UpdateVisibility(unitframe);
end

function Module:UpdateLocalConfig()
    BAR_HEIGHT = O.db.castbar_height;

    TEXT_POSITION = O.db.castbar_text_anchor;
    TEXT_X_OFFSET = O.db.castbar_text_offset_x;
    TEXT_Y_OFFSET = O.db.castbar_text_offset_y;
    TEXT_TRUNCATE = O.db.castbar_text_truncate;

    TIMER_ENABLED = O.db.castbar_timer_enabled;
    TIMER_FORMAT  = O.db.castbar_timer_format;
    TIMER_ONLY_REMAINING = O.db.castbar_timer_only_remaining;

    if TIMER_ONLY_REMAINING then
        TIMER_FORMAT = '%.' .. TIMER_FORMAT - 1 .. 'f';
    else
        TIMER_FORMAT = '%.' .. TIMER_FORMAT - 1 .. 'f / %.' .. TIMER_FORMAT - 1 .. 'f';
    end

    TIMER_XSIDE = O.db.castbar_timer_xside;
    TIMER_ANCHOR = O.Lists.frame_points_simple[O.db.castbar_timer_anchor];
    TIMER_OFFSET_X = O.db.castbar_timer_offset_x;
    TIMER_OFFSET_Y = O.db.castbar_timer_offset_y;

    ON_HP_BAR       = O.db.castbar_on_hp_bar;
    ICON_LARGE      = O.db.castbar_icon_large;
    ICON_RIGHT_SIDE = O.db.castbar_icon_right_side;

    START_CAST_COLOR    = START_CAST_COLOR or {};
    START_CAST_COLOR[1] = O.db.castbar_start_cast_color[1];
    START_CAST_COLOR[2] = O.db.castbar_start_cast_color[2];
    START_CAST_COLOR[3] = O.db.castbar_start_cast_color[3];
    START_CAST_COLOR[4] = O.db.castbar_start_cast_color[4] or 1;

    START_CHANNEL_COLOR    = START_CHANNEL_COLOR or {};
    START_CHANNEL_COLOR[1] = O.db.castbar_start_channel_color[1];
    START_CHANNEL_COLOR[2] = O.db.castbar_start_channel_color[2];
    START_CHANNEL_COLOR[3] = O.db.castbar_start_channel_color[3];
    START_CHANNEL_COLOR[4] = O.db.castbar_start_channel_color[4] or 1;

    NONINTERRUPTIBLE_COLOR    = NONINTERRUPTIBLE_COLOR or {};
    NONINTERRUPTIBLE_COLOR[1] = O.db.castbar_noninterruptible_color[1];
    NONINTERRUPTIBLE_COLOR[2] = O.db.castbar_noninterruptible_color[2];
    NONINTERRUPTIBLE_COLOR[3] = O.db.castbar_noninterruptible_color[3];
    NONINTERRUPTIBLE_COLOR[4] = O.db.castbar_noninterruptible_color[4] or 1;

    FAILED_CAST_COLOR    = FAILED_CAST_COLOR or {};
    FAILED_CAST_COLOR[1] = O.db.castbar_failed_cast_color[1];
    FAILED_CAST_COLOR[2] = O.db.castbar_failed_cast_color[2];
    FAILED_CAST_COLOR[3] = O.db.castbar_failed_cast_color[3];
    FAILED_CAST_COLOR[4] = O.db.castbar_failed_cast_color[4] or 1;

    USE_INTERRUPT_READY_IN_TIME_COLOR = O.db.castbar_use_interrupt_ready_in_time_color;
    INTERRUPT_READY_IN_TIME_COLOR    = INTERRUPT_READY_IN_TIME_COLOR or {};
    INTERRUPT_READY_IN_TIME_COLOR[1] = O.db.castbar_interrupt_ready_in_time_color[1];
    INTERRUPT_READY_IN_TIME_COLOR[2] = O.db.castbar_interrupt_ready_in_time_color[2];
    INTERRUPT_READY_IN_TIME_COLOR[3] = O.db.castbar_interrupt_ready_in_time_color[3];
    INTERRUPT_READY_IN_TIME_COLOR[4] = O.db.castbar_interrupt_ready_in_time_color[4] or 1;

    USE_INTERRUPT_NOT_READY_COLOR = O.db.castbar_use_interrupt_not_ready_color;
    INTERRUPT_NOT_READY_COLOR = INTERRUPT_NOT_READY_COLOR or {};
    INTERRUPT_NOT_READY_COLOR[1] = O.db.castbar_interrupt_not_ready_color[1];
    INTERRUPT_NOT_READY_COLOR[2] = O.db.castbar_interrupt_not_ready_color[2];
    INTERRUPT_NOT_READY_COLOR[3] = O.db.castbar_interrupt_not_ready_color[3];
    INTERRUPT_NOT_READY_COLOR[4] = O.db.castbar_interrupt_not_ready_color[4] or 1;

    INTERRUPT_READY_TICK_COLOR    = INTERRUPT_READY_TICK_COLOR or {};
    INTERRUPT_READY_TICK_COLOR[1] = O.db.castbar_interrupt_ready_tick_color[1];
    INTERRUPT_READY_TICK_COLOR[2] = O.db.castbar_interrupt_ready_tick_color[2];
    INTERRUPT_READY_TICK_COLOR[3] = O.db.castbar_interrupt_ready_tick_color[3];
    INTERRUPT_READY_TICK_COLOR[4] = O.db.castbar_interrupt_ready_tick_color[4] or 1;

    STATUSBAR_TEXTURE = O.db.castbar_texture_value;

    ENEMY_WIDTH    = O.db.size_enemy_clickable_width;
    FRIENDLY_WIDTH = O.db.size_friendly_clickable_width;
    PLAYER_WIDTH   = O.db.size_self_width;

    SHOW_TRADE_SKILLS = O.db.castbar_show_tradeskills;

    SHOW_SHIELD                = O.db.castbar_show_shield;
    SHOW_ICON_NOTINTERRUPTIBLE = O.db.castbar_show_icon_notinterruptible;

    SHOW_INTERRUPT_READY_TICK = O.db.castbar_show_interrupt_ready_tick;

    BORDER_ENABLED  = O.db.castbar_border_enabled;
    BORDER_SIZE     = O.db.castbar_border_size;
    BORDER_COLOR    = BORDER_COLOR or {};
    BORDER_COLOR[1] = O.db.castbar_border_color[1];
    BORDER_COLOR[2] = O.db.castbar_border_color[2];
    BORDER_COLOR[3] = O.db.castbar_border_color[3];
    BORDER_COLOR[4] = O.db.castbar_border_color[4] or 1;

    TARGET_NAME_ENABLED        = O.db.castbar_target_name_enabled;
    TARGET_NAME_CLASS_COLOR    = O.db.castbar_target_name_class_color;
    TARGET_NAME_ONLY_ENEMY     = O.db.castbar_target_name_only_enemy;
    TARGET_NAME_IN_SPELL_NAME  = O.db.castbar_target_name_in_spell_name;
    TARGET_NAME_POINT          = O.Lists.frame_points[O.db.castbar_target_point] or 'TOP';
    TARGET_NAME_RELATIVE_POINT = O.Lists.frame_points[O.db.castbar_target_relative_point] or 'BOTTOM';
    TARGET_NAME_OFFSET_X       = O.db.castbar_target_offset_x;
    TARGET_NAME_OFFSET_Y       = O.db.castbar_target_offset_y;

    CAST_BAR_BACKGROUND_TEXTURE = O.db.castbar_background_texture_value;
    CAST_BAR_BACKGROUND_COLOR    = CAST_BAR_BACKGROUND_COLOR or {};
    CAST_BAR_BACKGROUND_COLOR[1] = O.db.castbar_bg_color[1];
    CAST_BAR_BACKGROUND_COLOR[2] = O.db.castbar_bg_color[2];
    CAST_BAR_BACKGROUND_COLOR[3] = O.db.castbar_bg_color[3];
    CAST_BAR_BACKGROUND_COLOR[4] = O.db.castbar_bg_color[4] or 1;

    CAST_BAR_FRAME_STRATA = O.db.castbar_frame_strata ~= 1 and O.Lists.frame_strata[O.db.castbar_frame_strata] or 1;

    CAST_BAR_OFFSET_Y = O.db.castbar_offset_y;

    UpdateFontObject(StripesCastBarFont, O.db.castbar_text_font_value, O.db.castbar_text_font_size, O.db.castbar_text_font_flag, O.db.castbar_text_font_shadow);
    UpdateFontObject(StripesCastBarTimerFont, O.db.castbar_timer_font_value, O.db.castbar_timer_font_size, O.db.castbar_timer_font_flag, O.db.castbar_timer_font_shadow);
    UpdateFontObject(StripesCastBarTargetFont, O.db.castbar_target_font_value, O.db.castbar_target_font_size, O.db.castbar_target_font_flag, O.db.castbar_target_font_shadow);
end

function Module:StartUp()
    self:UpdateLocalConfig();

    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', function(unitframe)
        UpdateStyle(unitframe);
        UpdateBorderSizes(unitframe);
    end);

    self:SecureUnitFrameHook('CompactUnitFrame_SetUnit', UpdateVisibility);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateVisibility);
end