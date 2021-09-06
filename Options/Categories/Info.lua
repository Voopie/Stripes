local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('Options_Categories_Info');

O.frame.Left.Info, O.frame.Right.Info = O.CreateCategory(string.upper(L['OPTIONS_CATEGORY_INFO']), 'info', 20);
local panel = O.frame.Right.Info;

panel.Load = function(self)

    self.VersionText = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesCategoryButtonNormalFont'), E.PixelPerfectMixin);
    self.VersionText:SetPosition('CENTER', self, 'CENTER', 0, 60);
    self.VersionText:SetText(string.format('|cff%s%s:|r %s', S.Media.Colors.HEX.LIGHTORANGE, L['OPTIONS_INFO_VERSION'], S.Version));

    self.DiscordLogoTexture = Mixin(self:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    self.DiscordLogoTexture:SetPosition('CENTER', self, 'CENTER', 0, 30);
    self.DiscordLogoTexture:SetSize(28, 28);
    self.DiscordLogoTexture:SetTexture(S.Media.Icons64.TEXTURE);
    self.DiscordLogoTexture:SetTexCoord(unpack(S.Media.Icons64.COORDS.DISCORD_WHITE));

    self.DiscordUserPseudoLink = E.CreatePseudoLink(self);
    self.DiscordUserPseudoLink:SetPosition('RIGHT', self.DiscordLogoTexture, 'LEFT', -12, 0);
    self.DiscordUserPseudoLink:SetText('Voopie#1090');

    self.DiscordPseudoLink = E.CreatePseudoLink(self);
    self.DiscordPseudoLink:SetPosition('LEFT', self.DiscordLogoTexture, 'RIGHT', 12, 0);
    self.DiscordPseudoLink:SetText('rWy6KG94ec');

    self.AndText = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesCategoryButtonNormalFont'), E.PixelPerfectMixin);
    self.AndText:SetPosition('CENTER', self, 'CENTER', 0, 0);
    self.AndText:SetText('&');

    self.characterText = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesCategoryButtonNormalFont'), E.PixelPerfectMixin);
    self.characterText:SetPosition('TOP', self.AndText, 'BOTTOM', 0, -14);
    self.characterText:SetFont(self.characterText:GetFont(), 16);
    self.characterText:SetTextColor(D.Player.ClassColor:GetRGB());
    self.characterText:SetText(D.Player.Name .. '-' .. D.Player.Realm);

    self.heart = Mixin(CreateFrame('Frame', nil, self), E.PixelPerfectMixin);
    self.heart:SetPosition('TOP', self.characterText, 'BOTTOM', 0, -16);
    self.heart:SetSize(32, 32);

    self.heartTexture = Mixin(self.heart:CreateTexture(nil, 'ARTWORK'), E.PixelPerfectMixin);
    self.heartTexture:SetAllPoints();
    self.heartTexture:SetTexture(S.Media.Icons64.TEXTURE);
    self.heartTexture:SetTexCoord(unpack(S.Media.Icons64.COORDS.HEART_WHITE));
    self.heartTexture:SetVertexColor(1, 0.13, 0.31);

    local animation = self.heart:CreateAnimationGroup();

    local scale = animation:CreateAnimation('Scale');
    scale:SetOrder(1);
    scale:SetDuration(0.1);
    scale:SetScale(1.8, 1.8);

    local scale2 = animation:CreateAnimation('Scale');
    scale2:SetOrder(2);
    scale2:SetDuration(0.5);
    scale2:SetScale(0.5, 0.5);

    animation:SetLooping('REPEAT');

    animation:Play();

    self.TranslationCreditText = Mixin(self:CreateFontString(nil, 'ARTWORK', 'StripesCategoryButtonNormalFont'), E.PixelPerfectMixin);
    self.TranslationCreditText:SetPosition('TOP', self.heart, 'BOTTOM', 0, -100);
    self.TranslationCreditText:SetFont(self.TranslationCreditText:GetFont(), 16);
    self.TranslationCreditText:SetText(L['OPTIONS_INFO_TRANSLATED_BY']);
    self.TranslationCreditText:SetShown(S.ClientLocale ~= 'ruRU');
end