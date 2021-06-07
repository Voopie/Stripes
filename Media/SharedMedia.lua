local S, L, O, U, D, E = unpack(select(2, ...));

local LSM = S.Libraries.LSM;
local M = 'Interface\\AddOns\\' .. S.AddonName .. '\\Media\\';
local LOCALE_WEST_AND_RU = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western;

S.Media = {};

S.Media.Path = M;

S.Media.DUNGEON_ICON = 'Interface\\MINIMAP\\Dungeon';
S.Media.RAID_ICON = 'Interface\\MINIMAP\\Raid';

S.Media.DUNGEON_ICON_INLINE = '|T'.. S.Media.DUNGEON_ICON .. ':16|t ';
S.Media.RAID_ICON_INLINE = '|T'.. S.Media.RAID_ICON .. ':16|t ';

S.Media.INLINE_NEW_ICON = '|T' .. M .. 'Textures\\Assets\\icons32.blp:13:13:0:0:128:128:64:96:96:128|t ';

S.Media.GRADIENT_NAME = '|cffff6666S|r|cffff735dt|r|cffff8155r|r|cffff8f4ci|r|cffff9c44p|r|cffffaa3be|r|cffffb833s|r';

S.Media.ASTERISK = ' |T' .. M .. 'Textures\\Assets\\icons32_2.blp:10:10:0:4:128:128:96:128:0:32|t ';

S.Media.Colors = {
    HEX = {
        RED         = 'ff4d4d',
        LIGHTRED    = 'ff6666',
        ORANGE      = 'ff8400',
        LIGHTORANGE = 'ffb833',
    },
};

S.Media.StripesArt = {
    TEXTURE = M .. 'Textures\\Assets\\stripes_art.blp', -- 128x128

    COORDS = {
        MINI_STROKE_WHITE   = {  0, 1/4, 0, 1/4},
        MINI_NOSTROKE_WHITE = {1/4, 2/4, 0, 1/4},

        MINI_STROKE_GRADIENT   = {  0, 1/4, 1/4, 2/4},
        MINI_NOSTROKE_GRADIENT = {1/4, 2/4, 1/4, 2/4},

        WORD_WHITE    = {0, 4/4, 2/4, 3/4},
        WORD_GRADIENT = {0, 4/4, 3/4, 4/4},
    },
};

S.Media.Icons = {
    TEXTURE = M .. 'Textures\\Assets\\icons32.blp', -- 128x128

    COORDS = {
        -- 1st row
        GEAR_WHITE        = {  0, 1/4, 0, 1/4},
        CROSS_WHITE       = {1/4, 2/4, 0, 1/4},
        FULL_CIRCLE_WHITE = {2/4, 3/4, 0, 1/4},
        ARROW_DOWN_WHITE  = {3/4, 4/4, 0, 1/4},

        -- 2nd row
        INFINITY_WHITE    = {  0, 1/4, 1/4, 2/4},
        MAGNIFIER_WHITE   = {1/4, 2/4, 1/4, 2/4},
        PENCIL_WHITE      = {2/4, 3/4, 1/4, 2/4},
        TRASH_WHITE       = {3/4, 4/4, 1/4, 2/4},

        -- 3rd row
        CHECKBOX_EMPTY    = {  0, 1/4, 2/4, 3/4},
        CHECKBOX_CHECKED  = {1/4, 2/4, 2/4, 3/4},
        PLUS_SIGN_WHITE   = {2/4, 3/4, 2/4, 3/4},
        CHECKMARK_WHITE   = {3/4, 4/4, 2/4, 3/4},

        -- 4th row
        CIRCLE_NORMAL    = {  0, 1/4, 3/4 + 0.01, 4/4},
        CIRCLE_HIGHLIGHT = {1/4, 2/4, 3/4 + 0.01, 4/4},
        NEW              = {2/4, 3/4, 3/4,        4/4},
        NEW_WINDOW_WHITE = {3/4, 4/4, 3/4,        4/4},
    },
};

S.Media.Icons2 = {
    TEXTURE = M .. 'Textures\\Assets\\icons32_2.blp', -- 128x128

    COORDS = {
        -- 1st row
        LOOT                = {  0, 1/4 - 0.01, 0, 1/4},
        ROUNDSHIELD_SWORD   = {1/4, 2/4,        0, 1/4},
        CHATBUBBLE          = {2/4, 3/4,        0, 1/4},
        ASTERISK            = {3/4, 4/4,        0, 1/4},

        -- 2nd row
        REFRESH_WHITE      = {  0, 1/4, 1/4, 2/4},
        CROSS_SWORDS_WHITE = {1/4, 2/4, 1/4, 2/4},
    },
};

S.Media.Icons64 = {
    TEXTURE = M .. 'Textures\\Assets\\icons64.blp', -- 256x256

    COORDS = {
        -- 1st row
        FULL_CIRCLE_WHITE = {  0, 1/4, 0, 1/4},
        HEART_WHITE       = {1/4, 2/4, 0, 1/4},
        USER_WHITE        = {2/4, 3/4, 0, 1/4},
        DISCORD_WHITE     = {3/4, 4/4, 0, 1/4},

        -- 2nd row
        GITHUB_WORD_WHITE = {  0, 2/4, 1/4, 2/4},
        GITHUB_OCTO_WHITE = {2/4, 3/4, 1/4, 2/4},
        QMARK_WHITE       = {3/4, 4/4, 1/4, 2/4},

        -- 3rd row
        EXMARK_WHITE      = {0, 1/4, 2/4, 3/4},
    },

    COORDS_INLINE = {
        USER_WHITE         = {2/4 * 256, 3/4 * 256, 0 * 256, 1/4 * 256},
        DISCORD_LOGO_WHITE = {3/4 * 256, 4/4 * 256, 0 * 256, 1/4 * 256},
    },
};

S.Media.IconsClass = {
    TEXTURE = M .. 'Textures\\icons_classes.blp', -- 256x256

    COORDS = {
        DEATHKNIGHT = {   0, 1/4, 0, 1/4 },
        PRIEST      = { 1/4, 2/4, 0, 1/4 },
        ROGUE       = { 2/4, 3/4, 0, 1/4 },
        DEMONHUNTER = { 3/4, 4/4, 0, 1/4 },

        DRUID   = {   0, 1/4, 1/4, 2/4 },
        SHAMAN  = { 1/4, 2/4, 1/4, 2/4 },
        WARLOCK = { 2/4, 3/4, 1/4, 2/4 },
        HUNTER  = { 3/4, 4/4, 1/4, 2/4 },

        MAGE    = {   0, 1/4, 2/4, 3/4 },
        WARRIOR = { 1/4, 2/4, 2/4, 3/4 },
        MONK    = { 2/4, 3/4, 2/4, 3/4 },
        PALADIN = { 3/4, 4/4, 2/4, 3/4 },
    },
};

S.Media.Textures = {
    StatusBar = {
        FLAT    = M .. 'Textures\\StatusBar\\flat.blp',
        LILINE  = M .. 'Textures\\StatusBar\\liline.blp',
        LIMIDA  = M .. 'Textures\\StatusBar\\limida.blp',
        LIMIGLO = M .. 'Textures\\StatusBar\\limiglo.blp',
        MIDA    = M .. 'Textures\\StatusBar\\mida.blp',
        MIDIGLO = M .. 'Textures\\StatusBar\\midiglo.blp',
        SIDY    = M .. 'Textures\\StatusBar\\sidy.blp',
        UPLI    = M .. 'Textures\\StatusBar\\upli.blp',
    },
};

S.Media.Fonts = {
    BIGNOODLETOO = {
        OBLIQUE = M .. 'Fonts\\bignoodletoo_oblique.ttf',
        TITLING = M .. 'Fonts\\bignoodletoo_titling.ttf',
    },

    BRUTALTYPE = {
        REGULAR = M .. 'Fonts\\brutaltype.otf',
        LIGHT   = M .. 'Fonts\\brutaltype-light.otf',
        MEDIUM  = M .. 'Fonts\\brutaltype-medium.otf',
        BOLD    = M .. 'Fonts\\brutaltype-bold.otf',
    },

    CONVECTION = {
        REGULAR = M .. 'Fonts\\convection.ttf',
        MEDIUM  = M .. 'Fonts\\convection_medium.ttf',
        BOLD    = M .. 'Fonts\\convection_bold.ttf',
    },

    EXPRESSWAY = {
        REGULAR = M .. 'Fonts\\expressway.ttf',
        BOLD    = M .. 'Fonts\\expressway_bold.ttf',
    },

    FUTURAPT = {
        BOOK          = M .. 'Fonts\\futura-pt-book.ttf',
        BOOKOBLIQUE   = M .. 'Fonts\\futura-pt-book-oblique.ttf',
        MEDIUM        = M .. 'Fonts\\futura-pt-medium.ttf',
        MEDIUMOBLIQUE = M .. 'Fonts\\futura-pt-medium-oblique.ttf',
        DEMI          = M .. 'Fonts\\futura-pt-demi.ttf',
        DEMIOBLIQUE   = M .. 'Fonts\\futura-pt-demi-oblique.ttf',
        BOLD          = M .. 'Fonts\\futura-pt-bold.ttf',
        BOLDOBLIQUE   = M .. 'Fonts\\futura-pt-bold-oblique.ttf',
    },

    GOTHAMPRO = {
        REGULAR      = M .. 'Fonts\\gotham-pro-reg.otf',
        ITALIC       = M .. 'Fonts\\gotham-pro-italic.otf',
        BLACK        = M .. 'Fonts\\gotham-pro-black.otf',
        BLACKITALIC  = M .. 'Fonts\\gotham-pro-black-italic.otf',
        BOLD         = M .. 'Fonts\\gotham-pro-bold.otf',
        BOLDITALIC   = M .. 'Fonts\\gotham-pro-bold-italic.otf',
        LIGHT        = M .. 'Fonts\\gotham-pro-light.otf',
        LIGHTITALIC  = M .. 'Fonts\\gotham-pro-light-italic.otf',
        MEDIUM       = M .. 'Fonts\\gotham-pro-medium.otf',
        MEDIUMITALIC = M .. 'Fonts\\gotham-pro-medium-italic.otf',
        NARROW       = M .. 'Fonts\\gotham-pro-narrow.otf',
        NARROWBOLD   = M .. 'Fonts\\gotham-pro-narrow-bold.otf',
    },

    OSWALD = {
        REGULAR       = M .. 'Fonts\\oswald-regular.ttf',
        REGULARITALIC = M .. 'Fonts\\oswald-regular-italic.ttf',
        MEDIUM        = M .. 'Fonts\\oswald-medium.ttf',
        MEDIUMITALIC  = M .. 'Fonts\\oswald-medium-italic.ttf',
        DEMI          = M .. 'Fonts\\oswald-demi.ttf',
        DEMIITALIC    = M .. 'Fonts\\oswald-demi-italic.ttf',
        BOLD          = M .. 'Fonts\\oswald-bold.ttf',
        BOLDITALIC    = M .. 'Fonts\\oswald-bold-italic.ttf',
    },

    PTSANS = {
        NARROWBOLD = M .. 'Fonts\\ptsnb.ttf',
        BOLD       = M .. 'Fonts\\ptsab.ttf',
    },

    ROBOTO = {
        REGULAR      = M .. 'Fonts\\roboto.ttf',
        ITALIC       = M .. 'Fonts\\roboto-italic.ttf',
        MEDIUM       = M .. 'Fonts\\roboto-medium.ttf',
        MEDIUMITALIC = M .. 'Fonts\\roboto-medium-italic.ttf',
        BOLD         = M .. 'Fonts\\roboto-bold.ttf',
        BOLDITALIC   = M .. 'Fonts\\roboto-bold-italic.ttf',
    },

    RPL = {
        REGULAR = M .. 'Fonts\\rpl-regular.ttf',
    },

    SYSTOPIE = {
        REGULAR        = M .. 'Fonts\\systopie.otf',
        REGULARITALIC  = M .. 'Fonts\\systopie-italic.otf',
        SEMIBOLD       = M .. 'Fonts\\systopie-semi-bold.otf',
        SEMIBOLDITALIC = M .. 'Fonts\\systopie-semi-bold-italic.otf',
        BOLD           = M .. 'Fonts\\systopie-bold.otf',
        BOLDITALIC     = M .. 'Fonts\\systopie-bold-italic.otf',
    },

    TEEN = {
        CYR = M .. 'Fonts\\teencyr.ttf',
    },
};

-- Textures
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Flat', S.Media.Textures.StatusBar.FLAT);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Liline', S.Media.Textures.StatusBar.LILINE);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Limida', S.Media.Textures.StatusBar.LIMIDA);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Limiglo', S.Media.Textures.StatusBar.LIMIGLO);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Mida', S.Media.Textures.StatusBar.MIDA);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Midiglo', S.Media.Textures.StatusBar.MIDIGLO);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Sidy', S.Media.Textures.StatusBar.SIDY);
LSM:Register(LSM.MediaType.STATUSBAR, 'Stripes Upli', S.Media.Textures.StatusBar.UPLI);
LSM:Register(LSM.MediaType.STATUSBAR, 'Blizzard Glow', [[Interface\TargetingFrame\UI-StatusBar-Glow]]);
LSM:Register(LSM.MediaType.STATUSBAR, 'Blizzard Bar Fill', [[Interface\TargetingFrame\UI-TargetingFrame-BarFill]]);

-- Fonts
LSM:Register(LSM.MediaType.FONT, 'BigNoodleToo Oblique', S.Media.Fonts.BIGNOODLETOO.OBLIQUE, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'BigNoodleToo Titling', S.Media.Fonts.BIGNOODLETOO.TITLING, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Brutal Type', S.Media.Fonts.BRUTALTYPE.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Brutal Type Light', S.Media.Fonts.BRUTALTYPE.LIGHT, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Brutal Type Medium', S.Media.Fonts.BRUTALTYPE.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Brutal Type Bold', S.Media.Fonts.BRUTALTYPE.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Convection Regular', S.Media.Fonts.CONVECTION.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Convection Medium', S.Media.Fonts.CONVECTION.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Convection Bold', S.Media.Fonts.CONVECTION.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Expressway Regular', S.Media.Fonts.EXPRESSWAY.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Expressway Bold', S.Media.Fonts.EXPRESSWAY.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Book', S.Media.Fonts.FUTURAPT.BOOK, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Book Oblique', S.Media.Fonts.FUTURAPT.BOOKOBLIQUE, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Medium', S.Media.Fonts.FUTURAPT.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Medium Oblique', S.Media.Fonts.FUTURAPT.MEDIUMOBLIQUE, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Demi', S.Media.Fonts.FUTURAPT.DEMI, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Demi Oblique', S.Media.Fonts.FUTURAPT.DEMIOBLIQUE, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Bold', S.Media.Fonts.FUTURAPT.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Futura PT Bold Oblique', S.Media.Fonts.FUTURAPT.BOLDOBLIQUE, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Regular', S.Media.Fonts.GOTHAMPRO.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Italic', S.Media.Fonts.GOTHAMPRO.ITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Black', S.Media.Fonts.GOTHAMPRO.BLACK, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Black Italic', S.Media.Fonts.GOTHAMPRO.BLACKITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Bold', S.Media.Fonts.GOTHAMPRO.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Bold Italic', S.Media.Fonts.GOTHAMPRO.BOLDITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Light', S.Media.Fonts.GOTHAMPRO.LIGHT, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Light Italic', S.Media.Fonts.GOTHAMPRO.LIGHTITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Medium', S.Media.Fonts.GOTHAMPRO.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Medium Italic', S.Media.Fonts.GOTHAMPRO.MEDIUMITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Narrow', S.Media.Fonts.GOTHAMPRO.NARROW, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Gotham Pro Narrow Bold', S.Media.Fonts.GOTHAMPRO.NARROWBOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Regular', S.Media.Fonts.OSWALD.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Regular Italic', S.Media.Fonts.OSWALD.REGULARITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Medium', S.Media.Fonts.OSWALD.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Medium Italic', S.Media.Fonts.OSWALD.MEDIUMITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Demi', S.Media.Fonts.OSWALD.DEMI, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Demi Italic', S.Media.Fonts.OSWALD.DEMIITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Bold', S.Media.Fonts.OSWALD.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Oswald Bold Italic', S.Media.Fonts.OSWALD.BOLDITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'PT Sans Narrow Bold', S.Media.Fonts.PTSANS.NARROWBOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'PT Sans Bold', S.Media.Fonts.PTSANS.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto', S.Media.Fonts.ROBOTO.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto Italic', S.Media.Fonts.ROBOTO.ITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto Medium', S.Media.Fonts.ROBOTO.MEDIUM, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto Medium Italic', S.Media.Fonts.ROBOTO.MEDIUMITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto Bold', S.Media.Fonts.ROBOTO.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Roboto Bold Italic', S.Media.Fonts.ROBOTO.BOLDITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'RPL Regular', S.Media.Fonts.RPL.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie', S.Media.Fonts.SYSTOPIE.REGULAR, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie Italic', S.Media.Fonts.SYSTOPIE.REGULARITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie Semi Bold', S.Media.Fonts.SYSTOPIE.SEMIBOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie Semi Bold Italic', S.Media.Fonts.SYSTOPIE.SEMIBOLDITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie Bold', S.Media.Fonts.SYSTOPIE.BOLD, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Systopie Bold Italic', S.Media.Fonts.SYSTOPIE.BOLDITALIC, LOCALE_WEST_AND_RU);
LSM:Register(LSM.MediaType.FONT, 'Teen CYR', S.Media.Fonts.TEEN.CYR, LOCALE_WEST_AND_RU);

-- LSM Font Preloader ~Simpy
do
	local preloader = CreateFrame('Frame');
	preloader:SetPoint('TOP', UIParent, 'BOTTOM', 0, -500);
	preloader:SetSize(100, 100);

	local cacheFont = function(_, data)
		local loadFont = preloader:CreateFontString()
		loadFont:SetAllPoints()

		if pcall(loadFont.SetFont, loadFont, data, 14) then
			pcall(loadFont.SetText, loadFont, 'cache');
		end
	end

	-- Lets load all the fonts in LSM to prevent fonts not being ready
	local sharedFonts = LSM:HashTable('font')
	for key, data in next, sharedFonts do
		cacheFont(key, data);
	end

	-- Now lets hook it so we can preload any other AddOns add to LSM
	hooksecurefunc(LSM, 'Register', function(_, mediatype, key, data)
		if not mediatype or type(mediatype) ~= 'string' then
            return;
        end

		if mediatype:lower() == 'font' then
			cacheFont(key, data);
		end
	end);
end

local StripesCategoryButtonNormalFont = CreateFont('StripesCategoryButtonNormalFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesCategoryButtonNormalFont:CopyFontObject('SystemFont_Med3');
else
    StripesCategoryButtonNormalFont:SetFont(S.Media.Fonts.SYSTOPIE.SEMIBOLDITALIC, 14);
end
StripesCategoryButtonNormalFont:SetJustifyH('LEFT');
StripesCategoryButtonNormalFont:SetTextColor(1, 1, 1);
StripesCategoryButtonNormalFont:SetShadowColor(0, 0, 0);
StripesCategoryButtonNormalFont:SetShadowOffset(1, -1);

local StripesCategoryButtonHighlightFont = CreateFont('StripesCategoryButtonHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesCategoryButtonHighlightFont:CopyFontObject('SystemFont_Shadow_Med3');
else
    StripesCategoryButtonHighlightFont:SetFont(S.Media.Fonts.SYSTOPIE.SEMIBOLDITALIC, 14);
end
StripesCategoryButtonHighlightFont:SetJustifyH('LEFT');
StripesCategoryButtonHighlightFont:SetTextColor(1, 0.85, 0);
StripesCategoryButtonHighlightFont:SetShadowColor(0, 0, 0);
StripesCategoryButtonHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsNormalFont = CreateFont('StripesOptionsNormalFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsNormalFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsNormalFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 13);
end
StripesOptionsNormalFont:SetJustifyH('LEFT');
StripesOptionsNormalFont:SetTextColor(1, 1, 1);
StripesOptionsNormalFont:SetShadowColor(0, 0, 0);
StripesOptionsNormalFont:SetShadowOffset(1, -1);

local StripesOptionsHighlightFont = CreateFont('StripesOptionsHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsHighlightFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsHighlightFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 13);
end
StripesOptionsHighlightFont:SetJustifyH('LEFT');
StripesOptionsHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsLightGreyedFont = CreateFont('StripesOptionsLightGreyedFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsLightGreyedFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsLightGreyedFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 13);
end
StripesOptionsLightGreyedFont:SetJustifyH('LEFT');
StripesOptionsLightGreyedFont:SetTextColor(0.75, 0.75, 0.75);
StripesOptionsLightGreyedFont:SetShadowColor(0, 0, 0);
StripesOptionsLightGreyedFont:SetShadowOffset(1, -1);

local StripesOptionsDisabledFont = CreateFont('StripesOptionsDisabledFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsDisabledFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsDisabledFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 13);
end
StripesOptionsDisabledFont:SetJustifyH('LEFT');
StripesOptionsDisabledFont:SetTextColor(0.35, 0.35, 0.35);
StripesOptionsDisabledFont:SetShadowColor(0, 0, 0);
StripesOptionsDisabledFont:SetShadowOffset(1, -1);

local StripesOptionsTabHighlightFont = CreateFont('StripesOptionsTabHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsTabHighlightFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsTabHighlightFont:SetFont(S.Media.Fonts.SYSTOPIE.BOLD, 11);
end
StripesOptionsTabHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsTabHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsTabHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsTabGreyedFont = CreateFont('StripesOptionsTabGreyedFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsTabGreyedFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsTabGreyedFont:SetFont(S.Media.Fonts.SYSTOPIE.BOLD, 11);
end
StripesOptionsTabGreyedFont:SetTextColor(0.75, 0.75, 0.75);
StripesOptionsTabGreyedFont:SetShadowColor(0, 0, 0);
StripesOptionsTabGreyedFont:SetShadowOffset(1, -1);

local StripesOptionsButtonNormalFont = CreateFont('StripesOptionsButtonNormalFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsButtonNormalFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonNormalFont:SetFont(S.Media.Fonts.SYSTOPIE.BOLD, 11);
end
StripesOptionsButtonNormalFont:SetTextColor(1, 1, 1);
StripesOptionsButtonNormalFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonNormalFont:SetShadowOffset(1, -1);

local StripesOptionsButtonHighlightFont = CreateFont('StripesOptionsButtonHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsButtonHighlightFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonHighlightFont:SetFont(S.Media.Fonts.SYSTOPIE.BOLD, 11);
end
StripesOptionsButtonHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsButtonHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsButtonDisabledFont = CreateFont('StripesOptionsButtonDisabledFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesOptionsButtonDisabledFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonDisabledFont:SetFont(S.Media.Fonts.SYSTOPIE.BOLD, 11);
end
StripesOptionsButtonDisabledFont:SetTextColor(0.35, 0.35, 0.35);
StripesOptionsButtonDisabledFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonDisabledFont:SetShadowOffset(1, -1);

local StripesMediumHighlightFont = CreateFont('StripesMediumHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesMediumHighlightFont:CopyFontObject('SystemFont_Shadow_Med2');
else
    StripesMediumHighlightFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 14);
end
StripesMediumHighlightFont:SetJustifyH('LEFT');
StripesMediumHighlightFont:SetTextColor(1, 0.85, 0);
StripesMediumHighlightFont:SetShadowColor(0, 0, 0);
StripesMediumHighlightFont:SetShadowOffset(1, -1);

local StripesLargeHighlightFont = CreateFont('StripesLargeHighlightFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesLargeHighlightFont:CopyFontObject('SystemFont_Shadow_Large');
else
    StripesLargeHighlightFont:SetFont(S.Media.Fonts.FUTURAPT.MEDIUM, 16);
end
StripesLargeHighlightFont:SetJustifyH('LEFT');
StripesLargeHighlightFont:SetTextColor(1, 0.85, 0);
StripesLargeHighlightFont:SetShadowColor(0, 0, 0);
StripesLargeHighlightFont:SetShadowOffset(1, -1);

local StripesSmallNormalFont = CreateFont('StripesSmallNormalFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesSmallNormalFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesSmallNormalFont:SetFont(S.Media.Fonts.SYSTOPIE.REGULARITALIC, 11);
end
StripesSmallNormalFont:SetTextColor(1, 1, 1);
StripesSmallNormalFont:SetShadowColor(0, 0, 0);
StripesSmallNormalFont:SetShadowOffset(1, -1);

local StripesMediumNormalSemiBoldFont = CreateFont('StripesMediumNormalSemiBoldFont');
if S.ClientLocale == 'zhCN' or S.ClientLocale == 'zhTW' or S.ClientLocale == 'koKR' then
    StripesMediumNormalSemiBoldFont:CopyFontObject('SystemFont_Shadow_Med2');
else
    StripesMediumNormalSemiBoldFont:SetFont(S.Media.Fonts.SYSTOPIE.SEMIBOLD, 14);
end
StripesMediumNormalSemiBoldFont:SetJustifyH('LEFT');
StripesMediumNormalSemiBoldFont:SetTextColor(1, 1, 1);
StripesMediumNormalSemiBoldFont:SetShadowColor(0, 0, 0);
StripesMediumNormalSemiBoldFont:SetShadowOffset(1, -1);