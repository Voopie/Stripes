local S, L, O, U, D, E = unpack(select(2, ...));

-- WoW API
local GetSpellCooldown, UnitCanAttack = GetSpellCooldown, UnitCanAttack;
local GetTime = GetTime;

-- In fact, this is a copy paste from Blizzard/CastingBarFrame.lua

local FAILED = FAILED;
local INTERRUPTED = INTERRUPTED;

local CASTING_BAR_ALPHA_STEP = 0.05;
local CASTING_BAR_FLASH_STEP = 0.2;
local CASTING_BAR_HOLD_TIME = 1;

local GetInterruptSpellId = U.GetInterruptSpellId;

-- Based on Plater mod (Interrupt not ready Cast Color + Custom Cast Color) by Continuity
local function GetInterruptReadyTickPosition(self)
    if not self.interruptSpellId then
        return 0, false;
    end

    local interruptCD, interruptStart, interruptDuration = 0, 0, 0;
    local interruptReadyInTime, interruptReady;

    local cooldownStart, cooldownDuration = GetSpellCooldown(self.interruptSpellId);
    local tmpInterruptCD = (cooldownStart > 0 and cooldownDuration - (GetTime() - cooldownStart)) or 0;

    if interruptCD == 0 or (tmpInterruptCD < interruptCD) then
        interruptCD       = tmpInterruptCD;
        interruptDuration = cooldownDuration;
        interruptStart    = cooldownStart;
    end

    interruptReady = cooldownStart == 0;

    if self.channeling then
        interruptReadyInTime = interruptCD < self.value;
    else
        interruptReadyInTime = interruptCD < (self.maxValue - self.value);
    end

    local tickPosition = 0;

    if interruptCD > 0 and interruptReadyInTime then
        tickPosition = (interruptStart + interruptDuration - (self.startTime / 1000)) / self.maxValue;

        if self.channeling then
            tickPosition = 1 - tickPosition;
        end
    end

    return tickPosition, interruptReady;
end

local function UpdateInterruptReadyColorAndTick(self)
    if self.InterruptReadyTick then
        if self.notInterruptible or not UnitCanAttack('player', self.unit) then
            self.InterruptReadyTick:Hide();
        else
            local InterruptReadyTickPosition, intReady = GetInterruptReadyTickPosition(self);

            if intReady and self.useInterruptReadyColor then
                self:SetStatusBarColor(self.interruptReadyColor:GetRGBA());
            end

            if InterruptReadyTickPosition == 0 or not self.showInterruptReadyTick then
                self.InterruptReadyTick:Hide();
            else
                self.InterruptReadyTick:SetPoint('CENTER', self, InterruptReadyTickPosition < 0 and 'RIGHT' or 'LEFT', self:GetWidth() * InterruptReadyTickPosition, 0);
                self.InterruptReadyTick:Show();
            end
        end
    end
end

function StripesCastingBar_OnLoad(self, unit, showTradeSkills, showShield)
    StripesCastingBar_SetStartCastColor(self, 1.0, 0.7, 0.0, 1);
    StripesCastingBar_SetStartChannelColor(self, 0.0, 1.0, 0.0, 1);
    StripesCastingBar_SetFinishedCastColor(self, 0.0, 1.0, 0.0, 1);
    StripesCastingBar_SetNonInterruptibleCastColor(self, 0.7, 0.7, 0.7, 1);
    StripesCastingBar_SetFailedCastColor(self, 1.0, 0.0, 0.0, 1);
    StripesCastingBar_SetInterruptReadyCastColor(self, 0, 0.65, 0, 1);
    StripesCastingBar_SetUseStartColorForFinished(self, true);
    StripesCastingBar_SetUseStartColorForFlash(self, true);
    StripesCastingBar_SetUnit(self, unit, showTradeSkills, showShield);

    self.showCastbar = true;

    local point, _, _, _, offsetY = self.Spark:GetPoint();
    if point == 'CENTER' then
        self.Spark.offsetY = offsetY;
    end

    PixelUtil.SetHeight(self, 12);
end

function StripesCastingBar_SetStartCastColor(self, r, g, b, a)
    self.startCastColor = CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetStartChannelColor(self, r, g, b, a)
    self.startChannelColor = CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetFinishedCastColor(self, r, g, b, a)
    self.finishedCastColor = CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetFailedCastColor(self, r, g, b, a)
    self.failedCastColor = CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetNonInterruptibleCastColor(self, r, g, b, a)
    self.nonInterruptibleColor = CreateColor(r, g, b, a or 1);
end

function StripesCastingBar_SetInterruptReadyCastColor(self, r, g, b, a)
    self.interruptReadyColor = CreateColor(r, g, b, a or 1);
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
            self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED');
            self:RegisterEvent('UNIT_SPELLCAST_DELAYED');
            self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START');
            self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE');
            self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP');
            self:RegisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE');
            self:RegisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE');
            self:RegisterEvent('PLAYER_ENTERING_WORLD');
            self:RegisterUnitEvent('UNIT_SPELLCAST_START', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_STOP', unit);
            self:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', unit);

            self.interruptSpellId = GetInterruptSpellId();

            StripesCastingBar_OnEvent(self, 'PLAYER_ENTERING_WORLD');
        else
            self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTED');
            self:UnregisterEvent('UNIT_SPELLCAST_DELAYED');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_UPDATE');
            self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP');
            self:UnregisterEvent('UNIT_SPELLCAST_INTERRUPTIBLE');
            self:UnregisterEvent('UNIT_SPELLCAST_NOT_INTERRUPTIBLE');
            self:UnregisterEvent('PLAYER_ENTERING_WORLD');
            self:UnregisterEvent('UNIT_SPELLCAST_START');
            self:UnregisterEvent('UNIT_SPELLCAST_STOP');
            self:UnregisterEvent('UNIT_SPELLCAST_FAILED');

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
        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);

        if not name or (not self.showTradeSkills and isTradeSkill) then
            self:Hide();
            return;
        end

        local startColor = StripesCastingBar_GetEffectiveStartColor(self, false, notInterruptible);
        self:SetStatusBarColor(startColor:GetRGBA());

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
                self.Icon:SetShown(true);
            end
        end

        StripesCastingBar_ApplyAlpha(self, 1.0);

        self.holdTime = 0;
        self.casting = true;
        self.castID = castID;
        self.channeling = nil;
        self.fadeOut = nil;

        self.notInterruptible = notInterruptible;
        self.startTime = startTime;
        self.endTime   = endTime;

        UpdateInterruptReadyColorAndTick(self);

        if self.BorderShield then
            if self.showShield and notInterruptible then
                self.BorderShield:Show();
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
    elseif event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_CHANNEL_STOP' then
        if not self:IsVisible() then
            self:Hide();
        end

        if (self.casting and event == 'UNIT_SPELLCAST_STOP' and select(2, ...) == self.castID) or (self.channeling and event == 'UNIT_SPELLCAST_CHANNEL_STOP') then
            if self.Spark then
                self.Spark:Hide();
            end

            if self.Flash then
                self.Flash:SetAlpha(0.0);
                self.Flash:Show();
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
            end

            self.flash = true;
            self.fadeOut = true;
            self.holdTime = 0;
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

            self.casting = nil;
            self.channeling = nil;
            self.fadeOut = true;
            self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
            self.notInterruptible = nil;
        end
    elseif event == 'UNIT_SPELLCAST_DELAYED' then
        if self:IsShown() then
            local name, _, _, startTime, endTime, isTradeSkill, _, notInterruptible = UnitCastingInfo(unit);
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

                if self.Spark then
                    self.Spark:Show();
                end

                if self.Flash then
                    self.Flash:SetAlpha(0.0);
                    self.Flash:Hide();
                end

                self.casting = true;
                self.channeling = nil;
                self.flash = nil;
                self.fadeOut = nil;
                self.notInterruptible = nil;
            end

            self.notInterruptible = notInterruptible;
        end
    elseif event == 'UNIT_SPELLCAST_CHANNEL_START' then
        local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
        if not name or (not self.showTradeSkills and isTradeSkill) then
            -- if there is no name, there is no bar
            self:Hide();
            return;
        end

        local startColor = StripesCastingBar_GetEffectiveStartColor(self, true, notInterruptible);
        if self.flashColorSameAsStart then
            self.Flash:SetVertexColor(startColor:GetRGB());
        else
            self.Flash:SetVertexColor(1, 1, 1);
        end

        self:SetStatusBarColor(startColor:GetRGBA());
        self.value = (endTime / 1000) - GetTime();
        self.maxValue = (endTime - startTime) / 1000;
        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);

        if self.Text then
            self.Text:SetText(text);
        end

        if self.Icon then
            self.Icon:SetTexture(texture);
        end

        if self.Spark then
            self.Spark:Hide();
        end

        StripesCastingBar_ApplyAlpha(self, 1.0);

        self.holdTime = 0;
        self.casting = nil;
        self.channeling = true;
        self.fadeOut = nil;

        self.notInterruptible = notInterruptible;
        self.startTime = startTime;
        self.endTime   = endTime;

        UpdateInterruptReadyColorAndTick(self);

        if self.BorderShield then
            if self.showShield and notInterruptible then
                self.BorderShield:Show();

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
    elseif event == 'UNIT_SPELLCAST_CHANNEL_UPDATE' then
        if self:IsShown() then
            local name, _, _, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);

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
                self.BorderShield:Show();

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
                self.Icon:SetShown(true);
            end
        end

        if self.InterruptReadyTick then
            if notInterruptible or not self.showInterruptReadyTick then
                self.InterruptReadyTick:SetShown(false);
            else
                local InterruptReadyTickPosition = GetInterruptReadyTickPosition(self);
                if InterruptReadyTickPosition == 0 then
                    self.InterruptReadyTick:SetShown(false);
                else
                    self.InterruptReadyTick:SetPoint('CENTER', self, 'LEFT', self:GetWidth() * InterruptReadyTickPosition, 0);
                    self.InterruptReadyTick:SetShown(true);
                end
            end
        end
    end
end

function StripesCastingBar_OnUpdate(self, elapsed)
    if self.casting then
        self.value = self.value + elapsed;

        if self.value >= self.maxValue then
            self:SetValue(self.maxValue);
            StripesCastingBar_FinishSpell(self, self.Spark, self.Flash);
            return;
        end

        self:SetValue(self.value);

        if self.Flash then
            self.Flash:Hide();
        end

        if self.Spark then
            local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
            self.Spark:SetPoint('CENTER', self, 'LEFT', sparkPosition, self.Spark.offsetY or 2);
        end

        UpdateInterruptReadyColorAndTick(self);
    elseif self.channeling then
        self.value = self.value - elapsed;

        if self.value <= 0 then
            StripesCastingBar_FinishSpell(self, self.Spark, self.Flash);
            return;
        end

        self:SetValue(self.value);

        if self.Flash then
            self.Flash:Hide();
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
end

function StripesCastingBar_UpdateIsShown(self)
    if self.casting and self.showCastbar then
        StripesCastingBar_OnEvent(self, 'PLAYER_ENTERING_WORLD');
    else
        self:Hide();
    end
end