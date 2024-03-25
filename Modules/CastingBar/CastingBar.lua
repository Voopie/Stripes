local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('CastingBar');
local Colors = S:GetModule('Options_Colors');
local Stripes = S:GetNameplateModule('Handler');

-- WoW API
local UnitName, UnitExists, UnitIsUnit = UnitName, UnitExists, UnitIsUnit;
local GetSpellCooldown, UnitCanAttack = GetSpellCooldown, UnitCanAttack;
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo;
local GetTime = GetTime;

-- Stripes API
local S_GetCachedName = Stripes.GetCachedName;
local U_GetUnitColor, U_GetInterruptSpellId = U.GetUnitColor, U.GetInterruptSpellId;
local U_GlowStart, U_GlowStopAll = U.GlowStart, U.GlowStopAll;
local U_CreateColor = U.CreateColor;

-- Libraries
local LSM = S.Libraries.LSM;

-- Local Config
local CUSTOM_CASTS_ENABLED;
local CUSTOM_CASTS_DATA = {};

-- In fact, this is a copy paste from Blizzard/CastingBarFrame.lua
local FAILED = FAILED;
local INTERRUPTED = INTERRUPTED;

local CASTING_BAR_ALPHA_STEP = 0.05;
local CASTING_BAR_FLASH_STEP = 0.2;
local CASTING_BAR_HOLD_TIME = 1;

local function GetInterruptReadyTickPosition(self)
    if not self.interruptSpellId then
        return 0, false, false;
    end

    local cooldownStart, cooldownDuration = GetSpellCooldown(self.interruptSpellId);
    local interruptCD = cooldownStart > 0 and cooldownDuration - (GetTime() - cooldownStart) or 0;
    local interruptReady = cooldownStart == 0;
    local interruptWillBeReady = interruptCD < (self.channeling and self.value or (self.maxValue - self.value));

    local tickPosition = 0;
    if interruptCD > 0 and interruptWillBeReady then
        tickPosition = (cooldownStart + cooldownDuration - (self.startTime / 1000)) / self.maxValue;
        if self.channeling then
            tickPosition = 1 - tickPosition;
        end
    end

    return tickPosition, interruptReady, interruptWillBeReady;
end

local function UpdateInterruptReadyColorAndTick(self)
    if not self.InterruptReadyTick or self.notInterruptible or not UnitCanAttack('player', self.unit) then
        if self.InterruptReadyTick then
            self.InterruptReadyTick:Hide();
        end
        return;
    end

    local tickPosition, interruptReady, interruptWillBeReady = GetInterruptReadyTickPosition(self);

    if not self.customColored then
        if not interruptReady then
            if self.useInterruptReadyInTimeColor and interruptWillBeReady then
                self:SetStatusBarColor(self.interruptReadyInTimeColor:GetRGBA());
            elseif self.useInterruptNotReadyColor then
                self:SetStatusBarColor(self.interruptNotReadyColor:GetRGBA());
            end
        else
            self:SetStatusBarColor(StripesCastingBar_GetEffectiveStartColor(self, self.channeling, self.notInterruptible):GetRGBA());
        end
    end

    if tickPosition == 0 or not self.showInterruptReadyTick then
        self.InterruptReadyTick:Hide();
    else
        self.InterruptReadyTick:SetPoint('CENTER', self, tickPosition < 0 and 'RIGHT' or 'LEFT', self:GetWidth() * tickPosition, 0);
        self.InterruptReadyTick:Show();
    end
end

local function UpdateCustomCast(self, changedInterruptibleState)
    local spellId  = self.spellID;
    local castData = spellId and CUSTOM_CASTS_DATA[spellId];

    if not (CUSTOM_CASTS_ENABLED and castData and castData.enabled) then
        U_GlowStopAll(self);
        self.customColored = nil;
        return;
    end

    if castData.color_enabled then
        local color = Colors:Get(castData.color_name);
        local cR, cG, cB, cA = self:GetStatusBarColor();

        if color[1] ~= cR or color[2] ~= cG or color[3] ~= cB or color[4] ~= cA then
            self:SetStatusBarColor(color[1], color[2], color[3], color[4]);
        end

        self.customColored = true;
    end

    if castData.new_name and castData.new_name ~= castData.name then
        if self.Text then
            self.spellName = castData.new_name;
            self.Text:SetText(self.spellName);
        end
    end

    if castData.glow_enabled then
        U_GlowStopAll(self);
        U_GlowStart(self, castData.glow_type, Colors:Get(castData.glow_color_name));
    end

    if castData.sound_enabled and not changedInterruptibleState then
        if castData.sound_on_you then
            C_Timer.After(0.1, function()
                local targetUnit = self.unit .. 'target';

                if UnitExists(targetUnit) and UnitIsUnit(targetUnit, 'player') then
                    PlaySoundFile(LSM:Fetch('sound', castData.sound_name), castData.sound_channel or 'Master');
                end
            end);
        else
            PlaySoundFile(LSM:Fetch('sound', castData.sound_name), castData.sound_channel or 'Master');
        end
    end
end

local function UpdateCastTargetName(self)
    if not self.unit or not self.showCastTargetName then
        self.TargetText:Hide();
        return;
    end

    if self.castTargetNameOnlyEnemy and self:GetParent().data.commonReaction ~= 'ENEMY' then
        self.TargetText:Hide();
        return;
    end

    local targetUnit = self.unit .. 'target';

    if UnitExists(targetUnit) and not UnitIsUnit(self.unit, targetUnit) then
        local useTranslit, useReplaceDiacritics, useCut = true, true, false;
        local targetName = S_GetCachedName(UnitName(targetUnit), useTranslit, useReplaceDiacritics, useCut);

        if self.castTargetNameInSpellName and self.spellName then
            local classColor = self.castTargetNameUseClassColor and U_GetUnitColor(targetUnit, true) or 'ffffff';
            self.Text:SetText(string.format('%s > |cff%s%s|r', self.spellName, classColor, targetName));
            self.TargetText:Hide();
        else
            self.TargetText:SetText(targetName);

            if self.castTargetNameUseClassColor then
                self.TargetText:SetTextColor(U_GetUnitColor(targetUnit, 2));
            else
                self.TargetText:SetTextColor(1, 1, 1, 1);
            end

            self.TargetText:Show();
        end
    else
        self.TargetText:Hide();
    end
end

function Module:UpdateLocalConfig()
    CUSTOM_CASTS_ENABLED = O.db.castbar_custom_casts_enabled;
    CUSTOM_CASTS_DATA    = O.db.castbar_custom_casts_data;
end

function Module:StartUp()
    self:UpdateLocalConfig();
end

StripesBorderTemplateMixin = {};

function StripesBorderTemplateMixin:SetVertexColor(r, g, b, a)
    for _, texture in ipairs(self.Textures) do
        texture:SetVertexColor(r, g, b, a);
    end
end

function StripesBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
    self.borderSize = borderSize;
    self.borderSizeMinPixels = borderSizeMinPixels;
    self.upwardExtendHeightPixels = upwardExtendHeightPixels;
    self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function StripesBorderTemplateMixin:UpdateSizes()
    local borderSize = self.borderSize or 1;
    local minPixels = self.borderSizeMinPixels or 2;
    local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
    local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

    PixelUtil.SetWidth(self.Left, borderSize, minPixels);
    PixelUtil.SetPoint(self.Left, 'TOPRIGHT', self, 'TOPLEFT', 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
    PixelUtil.SetPoint(self.Left, 'BOTTOMRIGHT', self, 'BOTTOMLEFT', 0, -borderSize, 0, minPixels);
    PixelUtil.SetWidth(self.Right, borderSize, minPixels);
    PixelUtil.SetPoint(self.Right, 'TOPLEFT', self, 'TOPRIGHT', 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
    PixelUtil.SetPoint(self.Right, 'BOTTOMLEFT', self, 'BOTTOMRIGHT', 0, -borderSize, 0, minPixels);
    PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
    PixelUtil.SetPoint(self.Bottom, 'TOPLEFT', self, 'BOTTOMLEFT', 0, 0);
    PixelUtil.SetPoint(self.Bottom, 'TOPRIGHT', self, 'BOTTOMRIGHT', 0, 0);

    if self.Top then
        PixelUtil.SetHeight(self.Top, borderSize, minPixels);
        PixelUtil.SetPoint(self.Top, 'BOTTOMLEFT', self, 'TOPLEFT', 0, 0);
        PixelUtil.SetPoint(self.Top, 'BOTTOMRIGHT', self, 'TOPRIGHT', 0, 0);
    end
end

function StripesCastingBar_OnLoad(self, unit, showTradeSkills, showShield)
    StripesCastingBar_SetStartCastColor(self, 1.0, 0.7, 0.0, 1);
    StripesCastingBar_SetStartChannelColor(self, 0.0, 1.0, 0.0, 1);
    StripesCastingBar_SetFinishedCastColor(self, 0.0, 1.0, 0.0, 1);
    StripesCastingBar_SetNonInterruptibleCastColor(self, 0.7, 0.7, 0.7, 1);
    StripesCastingBar_SetFailedCastColor(self, 1.0, 0.0, 0.0, 1);
    StripesCastingBar_SetUseStartColorForFinished(self, true);
    StripesCastingBar_SetUseStartColorForFlash(self, true);
    StripesCastingBar_SetUnit(self, unit, showTradeSkills, showShield);

    self.StagePoints = {};
    self.StagePips = {};

    self.showCastbar = true;

    local point, _, _, _, offsetY = self.Spark:GetPoint();
    if point == 'CENTER' then
        self.Spark.offsetY = offsetY;
    end
end

local CASTBAR_STAGE_INVALID = -1;
local CASTBAR_STAGE_DURATION_INVALID = -1;

function StripesCastingBar_AddStages(self, numStages)
    self.CurrSpellStage = CASTBAR_STAGE_INVALID;
    self.NumStages = numStages + 1;

    local sumDuration = 0;

    self.StagePoints = {};
    self.StagePips = {};

    local hasFX = self.StandardFinish ~= nil;
    local stageMaxValue = self.maxValue * 1000;

    local getStageDuration = function(stage)
        if stage == self.NumStages then
            return GetUnitEmpowerHoldAtMaxTime(self.unit);
        else
            return GetUnitEmpowerStageDuration(self.unit, stage-1);
        end
    end;

    local castBarWidth = self:GetWidth();

    for i = 1, self.NumStages - 1, 1 do
        local duration = getStageDuration(i);

        if duration > CASTBAR_STAGE_DURATION_INVALID then
            sumDuration = sumDuration + duration;

            local portion = sumDuration / stageMaxValue;
            local offset = castBarWidth * portion;

            self.StagePoints[i] = sumDuration;

            local stagePipName = 'StagePip' .. i;
            local stagePip = self[stagePipName];

            if not stagePip then
                stagePip = CreateFrame('Frame', nil, self, hasFX and 'CastingBarFrameStagePipFXTemplate' or 'CastingBarFrameStagePipTemplate');
                self[stagePipName] = stagePip;
            end

            if stagePip then
                table.insert(self.StagePips, stagePip);
                stagePip:ClearAllPoints();
                stagePip:SetPoint('TOP', self, 'TOPLEFT', offset, -1);
                stagePip:SetPoint('BOTTOM', self, 'BOTTOMLEFT', offset, 1);
                stagePip:Show();
                stagePip.BasePip:SetShown(i ~= self.NumStages);
            end
        end
    end
end

function StripesCastingBar_UpdateStage(self)
    local maxStage = 0;
    local stageValue = self.value*1000;
    for i = 1, self.NumStages do
        if self.StagePoints[i] then
            if stageValue > self.StagePoints[i] then
                maxStage = i;
            else
                break;
            end
        end
    end

    if maxStage ~= self.CurrSpellStage and maxStage > CASTBAR_STAGE_INVALID and maxStage <= self.NumStages then
        self.CurrSpellStage = maxStage;

        if maxStage < self.NumStages then
            local stagePip = self.StagePips[maxStage];
            if stagePip and stagePip.StageAnim then
                stagePip.StageAnim:Play();
            end
        end
    end
end

function StripesCastingBar_ClearStages(self)
    for _, stagePip in pairs(self.StagePips) do
        local maxStage = self.NumStages;

        for i = 1, maxStage do
            local stageAnimName = 'Stage' .. i;
            local stageAnim = stagePip[stageAnimName];
            if stageAnim then
                stageAnim:Stop();
            end
        end

        stagePip:Hide();
    end

    self.NumStages = 0;

    wipe(self.StagePoints);
end

function StripesCastingBar_SetStartCastColor(self, r, g, b, a)
    self.startCastColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetStartChannelColor(self, r, g, b, a)
    self.startChannelColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetFinishedCastColor(self, r, g, b, a)
    self.finishedCastColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetFailedCastColor(self, r, g, b, a)
    self.failedCastColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetNonInterruptibleCastColor(self, r, g, b, a)
    self.nonInterruptibleColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetInterruptReadyInTimeCastColor(self, r, g, b, a)
    self.interruptReadyInTimeColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetInterruptNotReadyCastColor(self, r, g, b, a)
    self.interruptNotReadyColor = U_CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetUseStartColorForFinished(self, finishedColorSameAsStart)
    self.finishedColorSameAsStart = finishedColorSameAsStart;
end

function StripesCastingBar_SetUseStartColorForFlash(self, flashColorSameAsStart)
    self.flashColorSameAsStart = flashColorSameAsStart;
end

-- Fades additional widgets along with the cast bar, in case these widgets are not parented or use ignoreParentAlpha
function StripesCastingBar_AddWidgetForFade(self, widget)
    if not self.additionalFadeWidgets then
        self.additionalFadeWidgets = {};
    end

    self.additionalFadeWidgets[widget] = true;
end

function StripesCastingBar_SetUnit(self, unit, showTradeSkills, showShield)
    if self.unit ~= unit then
        self.unit = unit;
        self.showTradeSkills = showTradeSkills;
        self.showShield = showShield;
        self.casting = nil;
        self.channeling = nil;
        self.holdTime = 0;
        self.fadeOut = nil;

        self.interruptSpellId = nil;
        self.startTime = nil;
        self.endTime = nil;
        self.notInterruptible = nil;

        if unit then
            self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_START', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_UPDATE', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_EMPOWER_STOP', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTIBLE', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_START', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', unit);
            self:RegisterEvent('PLAYER_ENTERING_WORLD');

            self.interruptSpellId = U_GetInterruptSpellId();

            StripesCastingBar_OnEvent(self, 'PLAYER_ENTERING_WORLD');
        else
            self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED');
            self:UnregisterEvent('UNIT_SPELLCAST_DELAYED');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP');
            self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_START');
            self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_UPDATE');
            self:UnregisterEvent('UNIT_SPELLCAST_EMPOWER_STOP');
            self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE');
            self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE');
            self:UnregisterEvent('UNIT_SPELLCAST_START');
            self:UnregisterEvent('UNIT_SPELLCAST_STOP');
            self:UnregisterEvent('UNIT_SPELLCAST_FAILED');
            self:UnregisterEvent('PLAYER_ENTERING_WORLD');

            self:Hide();
        end
    end
end

function StripesCastingBar_OnShow(self)
    if self.unit then
        if self.casting then
            local _, _, _, startTime = UnitCastingInfo(self.unit);
            if startTime then
                self.value = (GetTime() - (startTime / 1000));
            end
        else
            local _, _, _, _, endTime = UnitChannelInfo(self.unit);
            if endTime then
                self.value = ((endTime / 1000) - GetTime());
            end
        end
    end
end

function StripesCastingBar_GetEffectiveStartColor(self, isChannel, notInterruptible)
    if self.nonInterruptibleColor and notInterruptible then
        return self.nonInterruptibleColor;
    end

    return isChannel and self.startChannelColor or self.startCastColor;
end

function StripesCastingBar_OnEvent(self, event, ...)
    local arg1 = ...;
    local unit = self.unit;

    if event == 'PLAYER_ENTERING_WORLD' then
        local nameChannel = UnitChannelInfo(unit);
        local nameSpell = UnitCastingInfo(unit);

        if nameChannel then
            event = 'UNIT_SPELLCAST_CHANNEL_START';
            arg1 = unit;
        elseif nameSpell then
            event = 'UNIT_SPELLCAST_START';
            arg1 = unit;
        else
            StripesCastingBar_FinishSpell(self);
        end
    end

    if arg1 ~= unit then
        return;
    end

    if event == 'UNIT_SPELLCAST_START' then
        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit);

        if not name or (not self.showTradeSkills and isTradeSkill) then
            self:Hide();
            return;
        end

        local startColor = StripesCastingBar_GetEffectiveStartColor(self, false, notInterruptible);
        self:SetStatusBarColor(startColor:GetRGBA());

        StripesCastingBar_ClearStages(self);

        if self.flashColorSameAsStart then
            self.Flash:SetVertexColor(startColor:GetRGB());
        else
            self.Flash:SetVertexColor(1, 1, 1);
        end

        if self.Spark then
            self.Spark:Show();
        end

        self.value = (GetTime() - (startTime / 1000));
        self.maxValue = (endTime - startTime) / 1000;
        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);

        if self.Text then
            self.Text:SetText(text);
        end

        if self.Icon then
            self.Icon:SetTexture(texture);

            if notInterruptible then
                self.Icon:SetShown(self.iconWhenNoninterruptible);
            else
                self.Icon:Show();
            end
        end

        StripesCastingBar_ApplyAlpha(self, 1.0);

        self.holdTime = 0;
        self.casting = true;
        self.castID = castID;
        self.spellID = spellID;
        self.spellName = text;
        self.channeling = nil;
        self.reverseChanneling = nil;
        self.fadeOut = nil;

        self.notInterruptible = notInterruptible;
        self.startTime = startTime;
        self.endTime   = endTime;

        if self.TargetText then
            UpdateCastTargetName(self);
        end

        UpdateInterruptReadyColorAndTick(self);
        UpdateCustomCast(self);

        if self.BorderShield then
            if self.showShield and notInterruptible then
                self.BorderShield:SetShown(self.iconWhenNoninterruptible);
                if self.BarBorder then
                    self.BarBorder:Hide();
                end
            else
                self.BorderShield:Hide();
                if self.BarBorder then
                    self.BarBorder:Show();
                end
            end
        end

        if self.showCastbar then
            self:Show();
        end
    elseif event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_CHANNEL_STOP' or event == 'UNIT_SPELLCAST_EMPOWER_STOP' then
        if not self:IsVisible() then
            self:Hide();
        end

        if ( (self.casting and event == 'UNIT_SPELLCAST_STOP' and select(2, ...) == self.castID) or ((self.channeling or self.reverseChanneling) and (event == 'UNIT_SPELLCAST_CHANNEL_STOP' or event == 'UNIT_SPELLCAST_EMPOWER_STOP')) ) then
            if not self.reverseChanneling then
                if self.Spark then
                    self.Spark:Hide();
                end
            end

            if self.Flash then
                self.Flash:SetAlpha(0.0);
                self.Flash:Show();
            end

            if not self.reverseChanneling and not self.channeling then
                self:SetValue(self.maxValue);
            end

            if self.InterruptReadyTick then
                self.InterruptReadyTick:Hide();
            end

            self:SetValue(self.maxValue);

            if event == 'UNIT_SPELLCAST_STOP' then
                self.casting = nil;
                if not self.finishedColorSameAsStart then
                    self:SetStatusBarColor(self.finishedCastColor:GetRGB());
                end
            else
                self.channeling = nil;
                if self.reverseChanneling then
                    self.casting = nil;
                end
                self.reverseChanneling = nil;
            end

            self.flash = true;
            self.fadeOut = true;
            self.holdTime = 0;
            self.spellName = nil;
            self.customColored = nil;
        end
    elseif event == 'UNIT_SPELLCAST_FAILED' or event == 'UNIT_SPELLCAST_INTERRUPTED' then
        if self:IsShown() and (self.casting and select(2, ...) == self.castID) and not self.fadeOut then
            self:SetValue(self.maxValue);
            self:SetStatusBarColor(self.failedCastColor:GetRGBA());

            if self.Spark then
                self.Spark:Hide();
            end

            if self.InterruptReadyTick then
                self.InterruptReadyTick:Hide();
            end

            if self.Text then
                if event == 'UNIT_SPELLCAST_FAILED' then
                    self.Text:SetText(FAILED);
                else
                    self.Text:SetText(INTERRUPTED);
                end
            end

            if self.TargetText then
                self.TargetText:Hide();
            end

            U_GlowStopAll(self);

            self.casting = nil;
            self.channeling = nil;
            self.reverseChanneling = nil;
            self.fadeOut = true;
            self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
            self.notInterruptible = nil;
            self.spellName = nil;
            self.customColored = nil;
        end
    elseif event == 'UNIT_SPELLCAST_DELAYED' then
        if self:IsShown() then
            local name, text, _, startTime, endTime, isTradeSkill, _, notInterruptible = UnitCastingInfo(unit);
            if not name or (not self.showTradeSkills and isTradeSkill) then
                -- if there is no name, there is no bar
                self:Hide();
                return;
            end

            self.value = (GetTime() - (startTime / 1000));
            self.maxValue = (endTime - startTime) / 1000;
            self:SetMinMaxValues(0, self.maxValue);

            if not self.casting then
                self:SetStatusBarColor(StripesCastingBar_GetEffectiveStartColor(self, false, notInterruptible):GetRGBA());

                StripesCastingBar_ClearStages(self);

                if self.Spark then
                    self.Spark:Show();
                end

                if self.Flash then
                    self.Flash:SetAlpha(0.0);
                    self.Flash:Hide();
                end

                self.casting = true;
                self.channeling = nil;
                self.reverseChanneling = nil;
                self.flash = nil;
                self.fadeOut = nil;
                self.notInterruptible = nil;
                self.spellName = text;
            end

            self.notInterruptible = notInterruptible;
        end
    elseif event == 'UNIT_SPELLCAST_CHANNEL_START' or event == 'UNIT_SPELLCAST_EMPOWER_START' then
        local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit);
        if not name or (not self.showTradeSkills and isTradeSkill) then
            -- if there is no name, there is no bar
            self:Hide();
            return;
        end

        local isChargeSpell = numStages > 0;

        if isChargeSpell then
            endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit);
        end

        self.maxValue = (endTime - startTime) / 1000;

        local startColor = StripesCastingBar_GetEffectiveStartColor(self, true, notInterruptible);
        if self.flashColorSameAsStart then
            self.Flash:SetVertexColor(startColor:GetRGB());
        else
            self.Flash:SetVertexColor(1, 1, 1);
        end

        self:SetStatusBarColor(startColor:GetRGBA());

        StripesCastingBar_ClearStages(self);

        if isChargeSpell then
            self.value = (startTime / 1000) - GetTime();
        else
            self.value = (endTime / 1000) - GetTime();
        end

        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);

        if self.Text then
            self.Text:SetText(text);
        end

        if self.Icon then
            self.Icon:SetTexture(texture);

            if notInterruptible then
                self.Icon:SetShown(self.iconWhenNoninterruptible);
            else
                self.Icon:Show();
            end
        end

        if self.Spark then
            self.Spark:Hide();
        end

        if isChargeSpell then
            self.reverseChanneling = true;
            self.casting = true;
            self.channeling = false;
        else
            self.reverseChanneling = nil;
            self.casting = nil;
            self.channeling = true;
        end

        StripesCastingBar_ApplyAlpha(self, 1.0);

        self.holdTime = 0;
        self.fadeOut = nil;
        self.spellID = spellID;
        self.spellName = text;
        self.notInterruptible = notInterruptible;
        self.startTime = startTime;
        self.endTime   = endTime;

        if self.TargetText then
            UpdateCastTargetName(self);
        end

        UpdateInterruptReadyColorAndTick(self);
        UpdateCustomCast(self);

        if self.BorderShield then
            if self.showShield and notInterruptible then
                self.BorderShield:SetShown(self.iconWhenNoninterruptible);
                if self.BarBorder then
                    self.BarBorder:Hide();
                end
            else
                self.BorderShield:Hide();
                if self.BarBorder then
                    self.BarBorder:Show();
                end
            end
        end

        if self.showCastbar then
            self:Show();
        end

        if isChargeSpell then
            StripesCastingBar_AddStages(self, numStages);
        end
    elseif event == 'UNIT_SPELLCAST_CHANNEL_UPDATE' or event == 'UNIT_SPELLCAST_EMPOWER_UPDATE' then
        if self:IsShown() then
            local name, text, _, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);

            if not name or (not self.showTradeSkills and isTradeSkill) then
                -- if there is no name, there is no bar
                self:Hide();
                return;
            end

            self.value = ((endTime / 1000) - GetTime());
            self.maxValue = (endTime - startTime) / 1000;
            self:SetMinMaxValues(0, self.maxValue);
            self:SetValue(self.value);

            self.startTime = startTime;
            self.endTime   = endTime;

            self.spellName = text;

            if self.TargetText then
                UpdateCastTargetName(self);
            end
        end
    elseif event == 'UNIT_SPELLCAST_INTERRUPTIBLE' or event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE' then
        StripesCastingBar_UpdateInterruptibleState(self, event == 'UNIT_SPELLCAST_NOT_INTERRUPTIBLE');
    end
end

function StripesCastingBar_UpdateInterruptibleState(self, notInterruptible)
    if self.casting or self.channeling then
        self.notInterruptible = notInterruptible;

        local startColor = StripesCastingBar_GetEffectiveStartColor(self, self.channeling, notInterruptible);
        self:SetStatusBarColor(startColor:GetRGBA());

        if self.flashColorSameAsStart then
            self.Flash:SetVertexColor(startColor:GetRGB());
        end

        if self.BorderShield then
            if self.showShield and notInterruptible then
                self.BorderShield:SetShown(self.iconWhenNoninterruptible);
                if self.BarBorder then
                    self.BarBorder:Hide();
                end
            else
                self.BorderShield:Hide();
                if self.BarBorder then
                    self.BarBorder:Show();
                end
            end
        end

        if self.Icon then
            if notInterruptible then
                self.Icon:SetShown(self.iconWhenNoninterruptible);
            else
                self.Icon:Show();
            end
        end

        if self.TargetText then
            UpdateCastTargetName(self);
        end

        UpdateInterruptReadyColorAndTick(self);
        UpdateCustomCast(self, true);
    end
end

function StripesCastingBar_OnUpdate(self, elapsed)
    if self.casting or self.reverseChanneling then
        self.value = self.value + elapsed;

        if self.reverseChanneling and self.NumStages > 0 then
            StripesCastingBar_UpdateStage(self);
        end

        if self.value >= self.maxValue then
            self:SetValue(self.maxValue);


            if not self.reverseChanneling then
                StripesCastingBar_FinishSpell(self);
            else
                if self.FlashLoopingAnim and not self.FlashLoopingAnim:IsPlaying() then
                    self.FlashLoopingAnim:Play();
                    self.Flash:Show();
                end
            end

            if self.Spark then
                self.Spark:Hide();
            end

            return;
        end

        self:SetValue(self.value);

        if self.Flash then
            self.Flash:Hide();
        end

        if self.TargetText then
            UpdateCastTargetName(self);
        end

        UpdateInterruptReadyColorAndTick(self);
    elseif self.channeling then
        self.value = self.value - elapsed;

        if self.value <= 0 then
            StripesCastingBar_FinishSpell(self);
            return;
        end

        self:SetValue(self.value);

        if self.Flash then
            self.Flash:Hide();
        end

        if self.TargetText then
            UpdateCastTargetName(self);
        end

        UpdateInterruptReadyColorAndTick(self);
    elseif GetTime() < self.holdTime then
        return;
    elseif self.flash then
        local alpha = 0;

        if self.Flash then
            alpha = self.Flash:GetAlpha() + CASTING_BAR_FLASH_STEP;
        end

        if alpha < 1 then
            if self.Flash then
                self.Flash:SetAlpha(alpha);
            end
        else
            if self.Flash then
                self.Flash:SetAlpha(1.0);
            end

            self.flash = nil;
        end
    elseif self.fadeOut then
        local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;

        if alpha > 0 then
            StripesCastingBar_ApplyAlpha(self, alpha);
        else
            self.fadeOut = nil;
            self:Hide();
        end
    end

    if self.casting or self.reverseChanneling or self.channeling then
        if self.Spark then
            local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
            self.Spark:SetPoint('CENTER', self, 'LEFT', sparkPosition, self.Spark.offsetY or 2);
        end
    end
end

function StripesCastingBar_ApplyAlpha(self, alpha)
    self:SetAlpha(alpha);

    if self.additionalFadeWidgets then
        for widget in pairs(self.additionalFadeWidgets) do
            widget:SetAlpha(alpha);
        end
    end
end

function StripesCastingBar_FinishSpell(self)
    if not self.finishedColorSameAsStart then
        self:SetStatusBarColor(self.finishedCastColor:GetRGB());
    end

    if self.Spark then
        self.Spark:Hide();
    end

    if self.Flash then
        self.Flash:SetAlpha(0.0);
        self.Flash:Show();
    end

    self.flash = true;
    self.fadeOut = true;
    self.casting = nil;
    self.channeling = nil;
    self.spellID = nil;
end

function StripesCastingBar_UpdateIsShown(self)
    if self.casting and self.showCastbar then
        StripesCastingBar_OnEvent(self, 'PLAYER_ENTERING_WORLD');
    else
        self:Hide();
    end
end