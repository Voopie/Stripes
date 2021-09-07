local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewNameplateModule('CastBar');

-- Lua API
local string_format, math_max = string.format, math.max;

-- Stripes API
local UpdateFontObject = S:GetNameplateModule('Handler').UpdateFontObject;
local IsNameOnlyModeAndFriendly = S:GetNameplateModule('Handler').IsNameOnlyModeAndFriendly;

-- Libraries
local LSM = S.Libraries.LSM;
local LSM_MEDIATYPE_FONT = LSM.MediaType.FONT;
local LSM_MEDIATYPE_STATUSBAR = LSM.MediaType.STATUSBAR;

local LIST_FONT_FLAGS = O.Lists.font_flags;

-- Local config
local TIMER_ENABLED, ON_HP_BAR, ICON_LARGE, ICON_RIGHT_SIDE;
local START_CAST_COLOR, START_CHANNEL_COLOR, NONINTERRUPTIBLE_COLOR, FAILED_CAST_COLOR, INTERRUPT_READY_IN_TIME_COLOR, INTERRUPT_NOT_READY_COLOR;
local USE_INTERRUPT_READY_IN_TIME_COLOR, USE_INTERRUPT_NOT_READY_COLOR;
local FONT_VALUE, FONT_SIZE, FONT_FLAG, FONT_SHADOW;
local STATUSBAR_TEXTURE;
local ENEMY_WIDTH, FRIENDLY_WIDTH, PLAYER_WIDTH;
local SHOW_TRADE_SKILLS, SHOW_SHIELD, SHOW_ICON_NOTINTERRUPTIBLE;
local SHOW_INTERRUPT_READY_TICK, INTERRUPT_READY_TICK_COLOR;

local StripesCastBarFont = CreateFont('StripesCastBarFont');

local WIDTH_OFFSET = 24;
local updateDelay = 0.05;
local TIMER_FORMAT = '%.2f / %.2f';

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

local function UpdateFont(unitframe)
    unitframe.castingBar.Text:SetFont(LSM:Fetch(LSM_MEDIATYPE_FONT, FONT_VALUE), FONT_SIZE, LIST_FONT_FLAGS[FONT_FLAG]);
    unitframe.castingBar.Text:SetShadowOffset(FONT_SHADOW and 1 or 0, FONT_SHADOW and -1 or 0);
end

local function UpdateStyle(unitframe)
    unitframe.castingBar:ClearAllPoints();
    unitframe.castingBar.Icon:ClearAllPoints();

    unitframe.healthBar:ClearAllPoints();

    if ON_HP_BAR then
        PixelUtil.SetPoint(unitframe.healthBar, 'BOTTOM', unitframe, 'BOTTOM', 0, 6 + 2 + 12);

        if unitframe.data.unitType == 'SELF' then
            PixelUtil.SetWidth(unitframe.healthBar, PLAYER_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'ENEMY' then
            PixelUtil.SetWidth(unitframe.healthBar, ENEMY_WIDTH - WIDTH_OFFSET);
        elseif unitframe.data.commonReaction == 'FRIENDLY' then
            PixelUtil.SetWidth(unitframe.healthBar, FRIENDLY_WIDTH - WIDTH_OFFSET);
        end

        PixelUtil.SetPoint(unitframe.castingBar, 'BOTTOMLEFT', unitframe.healthBar, 'TOPLEFT', 0, -12);
        PixelUtil.SetPoint(unitframe.castingBar, 'BOTTOMRIGHT', unitframe.healthBar, 'TOPRIGHT', 0, -12);

        if ICON_RIGHT_SIDE then
            PixelUtil.SetPoint(unitframe.castingBar.Icon, 'LEFT', unitframe.castingBar, 'RIGHT', 0, 0);
        else
            PixelUtil.SetPoint(unitframe.castingBar.Icon, 'RIGHT', unitframe.castingBar, 'LEFT', 0, 0);
        end

        PixelUtil.SetSize(unitframe.castingBar.Icon, 12, 12);

        PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
    else
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
                PixelUtil.SetWidth(unitframe.castingBar.Icon, (unitframe.healthBar.sHeight or 12) + 12 + 2);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'BOTTOM', 0, 0);
            else
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'LEFT', unitframe.castingBar, 'RIGHT', 0, 0);
                PixelUtil.SetSize(unitframe.castingBar.Icon, 12, 12);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
            end
        else
            if ICON_LARGE then
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'TOPRIGHT', unitframe.healthBar, 'TOPLEFT', -1, 0.5);
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'BOTTOMRIGHT', unitframe.castingBar, 'BOTTOMLEFT', 0, 0);
                PixelUtil.SetWidth(unitframe.castingBar.Icon, (unitframe.healthBar.sHeight or 12) + 12 + 2);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'BOTTOM', 0, 0);
            else
                PixelUtil.SetPoint(unitframe.castingBar.Icon, 'RIGHT', unitframe.castingBar, 'LEFT', 0, 0);
                PixelUtil.SetSize(unitframe.castingBar.Icon, 12, 12);

                PixelUtil.SetPoint(unitframe.castingBar.BorderShield, 'CENTER', unitframe.castingBar.Icon, 'CENTER', 0, 0);
            end
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

    unitframe.castingBar.Timer = unitframe.castingBar:CreateFontString(nil, 'OVERLAY', 'StripesCastBarFont');
    PixelUtil.SetPoint(unitframe.castingBar.Timer, 'LEFT', unitframe.castingBar, 'RIGHT', 2, 0);
    unitframe.castingBar.Timer:SetTextColor(1, 1, 1);
    unitframe.castingBar.updateDelay = updateDelay;
    unitframe.castingBar:HookScript('OnUpdate', OnUpdate);

    unitframe.castingBar.Text:SetFontObject('StripesCastBarFont');

    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.Icon);
    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.BorderShield);
    StripesCastingBar_AddWidgetForFade(unitframe.castingBar, unitframe.castingBar.Timer);

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

local function UpdateVisibility(unitframe)
    if unitframe.castBar then
        unitframe.castBar:UnregisterAllEvents();
        unitframe.castBar:SetShown(false);
    end

    if unitframe.castingBar then
        if unitframe.data.unitType == 'SELF' then
            StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
        else
            if IsNameOnlyModeAndFriendly(unitframe.data.unitType, unitframe.data.canAttack) then
                StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
            else
                StripesCastingBar_SetUnit(unitframe.castingBar, unitframe.data.unit, SHOW_TRADE_SKILLS, SHOW_SHIELD);
            end
        end

        unitframe.castingBar.iconWhenNoninterruptible     = SHOW_ICON_NOTINTERRUPTIBLE;
        unitframe.castingBar.showInterruptReadyTick       = SHOW_INTERRUPT_READY_TICK;
        unitframe.castingBar.useInterruptReadyInTimeColor = USE_INTERRUPT_READY_IN_TIME_COLOR;
        unitframe.castingBar.useInterruptNotReadyColor    = USE_INTERRUPT_NOT_READY_COLOR;
    end
end

function Module:UnitAdded(unitframe)
    CreateTimer(unitframe);
    UpdateFont(unitframe);
    UpdateTexture(unitframe);
    UpdateStyle(unitframe);

    UpdateVisibility(unitframe);
end

function Module:UnitRemoved(unitframe)
    if unitframe.castingBar then
        StripesCastingBar_SetUnit(unitframe.castingBar, nil, SHOW_TRADE_SKILLS, SHOW_SHIELD);
    end
end

function Module:Update(unitframe)
    UpdateFont(unitframe);
    UpdateTexture(unitframe);
    UpdateStyle(unitframe);
    UpdateColors(unitframe);

    UpdateVisibility(unitframe);
end

function Module:UpdateLocalConfig()
    TIMER_ENABLED   = O.db.castbar_timer_enabled;
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

    FONT_VALUE  = O.db.castbar_text_font_value;
    FONT_SIZE   = O.db.castbar_text_font_size;
    FONT_FLAG   = O.db.castbar_text_font_flag;
    FONT_SHADOW = O.db.castbar_text_font_shadow;

    ENEMY_WIDTH    = O.db.size_enemy_clickable_width;
    FRIENDLY_WIDTH = O.db.size_friendly_clickable_width;
    PLAYER_WIDTH   = O.db.size_self_width;

    SHOW_TRADE_SKILLS = O.db.castbar_show_tradeskills;

    SHOW_SHIELD                = O.db.castbar_show_shield;
    SHOW_ICON_NOTINTERRUPTIBLE = O.db.castbar_show_icon_notinterruptible;

    SHOW_INTERRUPT_READY_TICK = O.db.castbar_show_interrupt_ready_tick;

    UpdateFontObject(StripesCastBarFont, FONT_VALUE, FONT_SIZE, FONT_FLAG, FONT_SHADOW);
end

function Module:StartUp()
    self:UpdateLocalConfig();
    self:SecureUnitFrameHook('DefaultCompactNamePlateFrameAnchorInternal', UpdateStyle);
    self:SecureUnitFrameHook('CompactUnitFrame_SetUnit', UpdateVisibility);
    self:SecureUnitFrameHook('CompactUnitFrame_UpdateName', UpdateVisibility); -- for duels, for example
end