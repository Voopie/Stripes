local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('CastBar');

-- Lua API
local string_format, math_max = string.format, math.max;

-- Stripes API
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local IsNameOnlyModeAndFriendly = S:GetNameplateModule('Handler').IsNameOnlyModeAndFriendly;
local PlayerState = D.Player.State;

-- Libraries
local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

-- Local config
local TIMER_ENABLED, TIMER_ONLY_REMAINING, TIMER_XSIDE, TIMER_ANCHOR, TIMER_OFFSET_X, TIMER_OFFSET_Y, ON_HP_BAR, ICON_LARGE, ICON_RIGHT_SIDE;
local START_CAST_COLOR, START_CHANNEL_COLOR, NONINTERRUPTIBLE_COLOR, FAILED_CAST_COLOR, INTERRUPT_READY_IN_TIME_COLOR, INTERRUPT_NOT_READY_COLOR;
local USE_INTERRUPT_READY_IN_TIME_COLOR, USE_INTERRUPT_NOT_READY_COLOR;
local STATUSBAR_TEXTURE;
local ENEMY_WIDTH, FRIENDLY_WIDTH, PLAYER_WIDTH;
local SHOW_TRADE_SKILLS, SHOW_SHIELD, SHOW_ICON_NOTINTERRUPTIBLE;
local SHOW_INTERRUPT_READY_TICK, INTERRUPT_READY_TICK_COLOR;
local NAME_ONLY_MODE;
local BORDER_ENABLED, BORDER_COLOR, BORDER_SIZE;
local BAR_HEIGHT;
local TEXT_POSITION, TEXT_X_OFFSET, TEXT_Y_OFFSET, TEXT_TRUNCATE;
local TARGET_NAME_ENABLED, TARGET_NAME_CLASS_COLOR, TARGET_NAME_ONLY_ENEMY, TARGET_NAME_IN_SPELL_NAME, TARGET_NAME_POINT, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y;
local CAST_BAR_BACKGROUND_TEXTURE, CAST_BAR_BACKGROUND_COLOR;

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

local function UpdateTexture(unitframe)
    unitframe.castingBar:SetStatusBarTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, STATUSBAR_TEXTURE));

    if unitframe.castingBar.Flash then
        unitframe.castingBar.Flash:SetTexture(LSM:Fetch(LSM_MEDIATYPE_STATUSBAR, STATUSBAR_TEXTURE));
    end
end

local function UpdateStyle(unitframe)
    unitframe.castingBar:ClearAllPoints();
    unitframe.castingBar.Icon:ClearAllPoints();

    unitframe.healthBar:ClearAllPoints();

    if ON_HP_BAR then
        PixelUtil.SetHeight(unitframe.castingBar, unitframe.healthBar.sHeight or 12);
        PixelUtil.SetPoint(unitframe.healthBar, 'BOTTOM', unitframe, 'BOTTOM', 0, 6 + 2 + BAR_HEIGHT);

        if unitframe.data.unitType == 'SELF' then
            PixelUtil.SetWidth(unitframe.healthBar, PLAYER_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'ENEMY' then
            PixelUtil.SetWidth(unitframe.healthBar, ENEMY_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'FRIENDLY' then
            PixelUtil.SetWidth(unitframe.healthBar, FRIENDLY_WIDTH - WIDTH_OFFSET);
        end

        PixelUtil.SetPoint(unitframe.castingBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', 0, -(unitframe.healthBar.sHeight or 12));
        PixelUtil.SetPoint(unitframe.castingBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0, -(unitframe.healthBar.sHeight or 12));

        if ICON_RIGHT_SIDE then
            PixelUtil.SetPoint(unitframe.castingBar.Icon, 'LEFT', unitframe.castingBar, 'RIGHT', 0, 0);
        else
            PixelUtil.SetPoint(unitframe.castingBar.Icon, 'RIGHT', unitframe.castingBar, 'LEFT', 0, 0);
        end

        PixelUtil.SetSize(unitframe.castingBar.Icon, unitframe.healthBar.sHeight or 12, unitframe.healthBar.sHeight or 12);

        PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
    else
        PixelUtil.SetHeight(unitframe.castingBar, BAR_HEIGHT);
        PixelUtil.SetPoint(unitframe.castingBar, 'BOTTOM', unitframe, 'BOTTOM', 0, 6);

        if unitframe.data.unitType == 'SELF' then
            PixelUtil.SetWidth(unitframe.castingBar, PLAYER_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'ENEMY' then
            PixelUtil.SetWidth(unitframe.castingBar, ENEMY_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'FRIENDLY' then
            PixelUtil.SetWidth(unitframe.castingBar, FRIENDLY_WIDTH - WIDTH_OFFSET);
        end

        PixelUtil.SetPoint(unitframe.healthBar, 'BOTTOMLEFT', unitframe.castingBar, 'TOPLEFT', 0, 2);
        PixelUtil.SetPoint(unitframe.healthBar, 'BOTTOMRIGHT', unitframe.castingBar, 'TOPRIGHT', 0, 2);

        if ICON_RIGHT_SIDE then
            if ICON_LARGE then
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'TOPLEFT', unitframe.healthBar, 'TOPRIGHT', 1, 0.5);
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'BOTTOMLEFT', unitframe.castingBar, 'BOTTOMRIGHT', 0, 0);
                PixelUtil.SetWidth(unitframe.castingBar.Icon, (unitframe.healthBar.sHeight or 12) + BAR_HEIGHT + 2);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'BOTTOM', 0, 0);
            else
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'LEFT', unitframe.castingBar, 'RIGHT', 0, 0);
                PixelUtil.SetSize(unitframe.castingBar.Icon, BAR_HEIGHT, BAR_HEIGHT);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
            end
        else
            if ICON_LARGE then
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'TOPRIGHT', unitframe.healthBar, 'TOPLEFT', -1, 0.5);
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'BOTTOMRIGHT', unitframe.castingBar, 'BOTTOMLEFT', 0, 0);
                PixelUtil.SetWidth(unitframe.castingBar.Icon, (unitframe.healthBar.sHeight or 12) + BAR_HEIGHT + 2);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'BOTTOM', 0, 0);
            else
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'RIGHT', unitframe.castingBar, 'LEFT', 0, 0);
                PixelUtil.SetSize(unitframe.castingBar.Icon, BAR_HEIGHT, BAR_HEIGHT);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
            end
        end
    end
end

local function UpdateColors(unitframe)
    if not unitframe.castingBar then
        return;
    end

    StripesCastingBar_SetStartCastColor(unitframe.castingBar, START_CAST_COLOR[1], START_CAST_COLOR[2], START_CAST_COLOR[3], START_CAST_COLOR[4]);
    StripesCastingBar_SetStartChannelColor(unitframe.castingBar, START_CHANNEL_COLOR[1], START_CHANNEL_COLOR[2], START_CHANNEL_COLOR[3], START_CHANNEL_COLOR[4]);
    StripesCastingBar_SetNonInterruptibleCastColor(unitframe.castingBar, NONINTERRUPTIBLE_COLOR[1], NONINTERRUPTIBLE_COLOR[2], NONINTERRUPTIBLE_COLOR[3], NONINTERRUPTIBLE_COLOR[4]);
    StripesCastingBar_SetFailedCastColor(unitframe.castingBar, FAILED_CAST_COLOR[1], FAILED_CAST_COLOR[2], FAILED_CAST_COLOR[3], FAILED_CAST_COLOR[4]);
    StripesCastingBar_SetInterruptReadyInTimeCastColor(unitframe.castingBar, INTERRUPT_READY_IN_TIME_COLOR[1], INTERRUPT_READY_IN_TIME_COLOR[2], INTERRUPT_READY_IN_TIME_COLOR[3], INTERRUPT_READY_IN_TIME_COLOR[4]);
    StripesCastingBar_SetInterruptNotReadyCastColor(unitframe.castingBar, INTERRUPT_NOT_READY_COLOR[1], INTERRUPT_NOT_READY_COLOR[2], INTERRUPT_NOT_READY_COLOR[3], INTERRUPT_NOT_READY_COLOR[4]);

    if unitframe.castingBar.InterruptReadyTick then
        unitframe.castingBar.InterruptReadyTick:SetVertexColor(INTERRUPT_READY_TICK_COLOR[1], INTERRUPT_READY_TICK_COLOR[2], INTERRUPT_READY_TICK_COLOR[3], INTERRUPT_READY_TICK_COLOR[4]);
    end
end

local function UpdateCastNameTextPosition(unitframe)
    unitframe.castingBar.Text:ClearAllPoints();

    if TEXT_POSITION == 1 then -- LEFT
        unitframe.castingBar.Text:SetJustifyH('LEFT');

        if TEXT_TRUNCATE then
            unitframe.castingBar.Text:SetWordWrap(false);
            unitframe.castingBar.Text:SetPoint('RIGHT', 0, 0);
            unitframe.castingBar.Text:SetPoint('LEFT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
        else
            unitframe.castingBar.Text:SetWordWrap(true);
            unitframe.castingBar.Text:SetPoint('LEFT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
        end
    elseif TEXT_POSITION == 2 then -- CENTER
        unitframe.castingBar.Text:SetJustifyH('CENTER');

        if TEXT_TRUNCATE then
            unitframe.castingBar.Text:SetWordWrap(false);
            unitframe.castingBar.Text:SetPoint('RIGHT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
            unitframe.castingBar.Text:SetPoint('LEFT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
        else
            unitframe.castingBar.Text:SetWordWrap(true);
            unitframe.castingBar.Text:SetPoint('CENTER', TEXT_X_OFFSET, TEXT_Y_OFFSET);
        end
    else -- RIGHT
        unitframe.castingBar.Text:SetJustifyH('RIGHT');

        if TEXT_TRUNCATE then
            unitframe.castingBar.Text:SetWordWrap(false);
            unitframe.castingBar.Text:SetPoint('RIGHT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
            unitframe.castingBar.Text:SetPoint('LEFT', 0, 0);
        else
            unitframe.castingBar.Text:SetWordWrap(true);
            unitframe.castingBar.Text:SetPoint('RIGHT', TEXT_X_OFFSET, TEXT_Y_OFFSET);
        end
    end
end

local function CreateTimer(unitframe)
    if not unitframe.castBar then
        return;
    end

    if unitframe.castingBar and unitframe.castingBar.Timer then
        return;
    end

    if not unitframe.castingBar then
        unitframe.castingBar = CreateFrame('StatusBar', nil, unitframe, 'StripesNameplateCastBarTemplate');
    end

    UpdateCastNameTextPosition(unitframe);

    unitframe.castingBar.Timer = unitframe.castingBar:CreateFontString(nil, 'OVERLAY', 'StripesCastBarTimerFont');
    PixelUtil.SetPoint(unitframe.castingBar.Timer, TIMER_XSIDE == 1 and ANCHOR_MIRROR[TIMER_ANCHOR] or TIMER_ANCHOR, unitframe.castingBar, TIMER_ANCHOR, TIMER_OFFSET_X, 0);
    unitframe.castingBar.Timer:SetTextColor(1, 1, 1);
    unitframe.castingBar.updateDelay = updateDelay;
    unitframe.castingBar:HookScript('OnUpdate', OnUpdate);

    unitframe.castingBar.TargetText:ClearAllPoints();
    PixelUtil.SetPoint(unitframe.castingBar.TargetText, TARGET_NAME_POINT, unitframe.castingBar, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y);

    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.Icon);
    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.BorderShield);
    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.Timer);
    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.TargetText);
end

local function UpdateVisibility(unitframe)
    if unitframe.castBar then
        unitframe.castBar:UnregisterAllEvents();
        unitframe.castBar:SetShown(false);
    end

    if unitframe.castingBar then
        if unitframe.data.unitType == 'SELF' then
            StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
        else
            if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) and (NAME_ONLY_MODE == 1 or (NAME_ONLY_MODE == 2 and not PlayerState.inInstance)) then
                StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
            else
                StripesCastingBar_SetUnit(unitframe.castingBar, unitframe.data.unit, SHOW_TRADE_SKILLS, SHOW_SHIELD);
            end
        end

        unitframe.castingBar.iconWhenNoninterruptible     = SHOW_ICON_NOTINTERRUPTIBLE;
        unitframe.castingBar.showInterruptReadyTick       = SHOW_INTERRUPT_READY_TICK;
        unitframe.castingBar.useInterruptReadyInTimeColor = USE_INTERRUPT_READY_IN_TIME_COLOR;
        unitframe.castingBar.useInterruptNotReadyColor    = USE_INTERRUPT_NOT_READY_COLOR;
        unitframe.castingBar.showCastTargetName           = TARGET_NAME_ENABLED;
        unitframe.castingBar.castTargetNameOnlyEnemy      = TARGET_NAME_ONLY_ENEMY;
        unitframe.castingBar.castTargetNameInSpellName    = TARGET_NAME_IN_SPELL_NAME;
        unitframe.castingBar.castTargetNameUseClassColor  = TARGET_NAME_CLASS_COLOR;

        if BORDER_ENABLED then
            unitframe.castingBar.border:SetVertexColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_COLOR[4]);
            unitframe.castingBar.border:SetBorderSizes(BORDER_SIZE, BORDER_SIZE - 0.5);
            unitframe.castingBar.border:UpdateSizes();
            unitframe.castingBar.border:Show();
        else
            unitframe.castingBar.border:Hide();
        end

        UpdateCastNameTextPosition(unitframe);

        unitframe.castingBar.Timer:ClearAllPoints();
        PixelUtil.SetPoint(unitframe.castingBar.Timer, TIMER_XSIDE == 1 and ANCHOR_MIRROR[TIMER_ANCHOR] or TIMER_ANCHOR, unitframe.castingBar, TIMER_ANCHOR, TIMER_OFFSET_X, TIMER_OFFSET_Y);

        unitframe.castingBar.TargetText:ClearAllPoints();
        PixelUtil.SetPoint(unitframe.castingBar.TargetText, TARGET_NAME_POINT, unitframe.castingBar, TARGET_NAME_RELATIVE_POINT, TARGET_NAME_OFFSET_X, TARGET_NAME_OFFSET_Y);
    end
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
    CreateTimer(unitframe);
    UpdateTexture(unitframe);
    UpdateBackgroundTexture(unitframe);
    UpdateColors(unitframe);
    UpdateStyle(unitframe);
    UpdateVisibility(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.castingBar then
        StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
    end
end

function Module:Update(unitframe)
    UpdateTexture(unitframe);
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

    NAME_ONLY_MODE = O.db.name_only_friendly_mode;

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
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateVisibility); -- for duels, for example
end