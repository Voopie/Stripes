local S, L, O, U, D, E = unpack((select(2, ...)));

local LSM = S.Libraries.LSM;
local M = 'Interface\\AddOns\\' .. S.AddonName .. '\\Media\\';
local LOCALE_WEST_AND_RU = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western;

S.Media = {};

S.Media.Path = M;

S.Media.LOGO_MINI = M .. 'Textures\\Assets\\stripes_logo_mini.blp';

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
        ARROW_DOWN_WHITE  = {3/4 + 0.01, 4/4, 0, 1/4},

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
        LIST_WHITE         = {2/4, 3/4, 1/4, 2/4},

        -- 3rd row
        STAR_WHITE         = {  0, 1/4, 2/4, 3/4},
        CROSS_SWORDS       = {1/4, 2/4, 2/4, 3/4},

        PALETTE_COLOR      = {0.71875, 1, 0.734375, 1},
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

        EVOKER  = {   0, 1/4, 3/4, 4/4 },
    },
};

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

-- Status bar textures
S.Media.StatusBar = {
    ['Stripes Flat']    = M .. 'Textures\\StatusBar\\flat.blp',
    ['Stripes Liline']  = M .. 'Textures\\StatusBar\\liline.blp',
    ['Stripes Limida']  = M .. 'Textures\\StatusBar\\limida.blp',
    ['Stripes Limiglo'] = M .. 'Textures\\StatusBar\\limiglo.blp',
    ['Stripes Mida']    = M .. 'Textures\\StatusBar\\mida.blp',
    ['Stripes Midiglo'] = M .. 'Textures\\StatusBar\\midiglo.blp',
    ['Stripes Sidy']    = M .. 'Textures\\StatusBar\\sidy.blp',
    ['Stripes Upli']    = M .. 'Textures\\StatusBar\\upli.blp',

    ['Melli']            = M .. 'Textures\\StatusBar\\melli.blp',
    ['Melli Dark']       = M .. 'Textures\\StatusBar\\melli_dark.blp',
    ['Melli Dark Rough'] = M .. 'Textures\\StatusBar\\melli_dark_rough.blp',

    ['Skullflower Neon'] = M .. 'Textures\\StatusBar\\skullflower_neon.blp',

    ['Bars']        = M .. 'Textures\\StatusBar\\bars.blp',
    ['Diagonal']    = M .. 'Textures\\StatusBar\\diagonal.blp',
    ['Striped Fat'] = M .. 'Textures\\StatusBar\\striped_fat.blp',

    ['Blizzard Glow']     = 'Interface\\TargetingFrame\\UI-StatusBar-Glow',
    ['Blizzard Bar Fill'] = 'Interface\\TargetingFrame\\UI-TargetingFrame-BarFill',
};

for bar_name, bar_path in pairs(S.Media.StatusBar) do
    LSM:Register(LSM.MediaType.STATUSBAR, bar_name, bar_path);
end

-- Fonts
S.Media.Fonts = {
    ['Avant Garde']             = M .. 'Fonts\\avant_garde_ctt.ttf',
    ['Avant Garde Italic']      = M .. 'Fonts\\avant_garde_ctt_italic.ttf',
    ['Avant Garde Gothic Bold'] = M .. 'Fonts\\avant_garde_gothic_ctt_bold.ttf',

    ['BigNoodleToo Oblique'] = M .. 'Fonts\\bignoodletoo_oblique.ttf',
    ['BigNoodleToo Titling'] = M .. 'Fonts\\bignoodletoo_titling.ttf',

    ['Brutal Type']        = M .. 'Fonts\\brutaltype.ttf',
    ['Brutal Type Light']  = M .. 'Fonts\\brutaltype_light.ttf',
    ['Brutal Type Medium'] = M .. 'Fonts\\brutaltype_medium.ttf',
    ['Brutal Type Bold']   = M .. 'Fonts\\brutaltype_bold.ttf',

    ['Convection Regular'] = M .. 'Fonts\\convection.ttf',
    ['Convection Medium']  = M .. 'Fonts\\convection_medium.ttf',
    ['Convection Bold']    = M .. 'Fonts\\convection_bold.ttf',

    ['Expressway Regular'] = M .. 'Fonts\\expressway.ttf',
    ['Expressway Bold']    = M .. 'Fonts\\expressway_bold.ttf',

    ['Futura PT Book']           = M .. 'Fonts\\futura_pt_book.ttf',
    ['Futura PT Book Oblique']   = M .. 'Fonts\\futura_pt_book_oblique.ttf',
    ['Futura PT Medium']         = M .. 'Fonts\\futura_pt_medium.ttf',
    ['Futura PT Medium Oblique'] = M .. 'Fonts\\futura_pt_medium_oblique.ttf',
    ['Futura PT Demi']           = M .. 'Fonts\\futura_pt_demi.ttf',
    ['Futura PT Demi Oblique']   = M .. 'Fonts\\futura_pt_demi_oblique.ttf',
    ['Futura PT Bold']           = M .. 'Fonts\\futura_pt_bold.ttf',
    ['Futura PT Bold Oblique']   = M .. 'Fonts\\futura_pt_bold_oblique.ttf',

    ['Google Sans Regular']       = M .. 'Fonts\\googlesans_regular.ttf',
    ['Google Sans Italic']        = M .. 'Fonts\\googlesans_italic.ttf',
    ['Google Sans Medium']        = M .. 'Fonts\\googlesans_medium.ttf',
    ['Google Sans Medium Italic'] = M .. 'Fonts\\googlesans_medium_italic.ttf',
    ['Google Sans Bold']          = M .. 'Fonts\\googlesans_bold.ttf',
    ['Google Sans Bold Italic']   = M .. 'Fonts\\googlesans_bold_italic.ttf',

    ['Gotham Pro Regular']       = M .. 'Fonts\\gotham_pro_regilar.ttf',
    ['Gotham Pro Italic']        = M .. 'Fonts\\gotham_pro_italic.ttf',
    ['Gotham Pro Black']         = M .. 'Fonts\\gotham_pro_black.ttf',
    ['Gotham Pro Black Italic']  = M .. 'Fonts\\gotham_pro_black_italic.ttf',
    ['Gotham Pro Bold']          = M .. 'Fonts\\gotham_pro_bold.ttf',
    ['Gotham Pro Bold Italic']   = M .. 'Fonts\\gotham_pro_bold_italic.ttf',
    ['Gotham Pro Light']         = M .. 'Fonts\\gotham_pro_light.ttf',
    ['Gotham Pro Light Italic']  = M .. 'Fonts\\gotham_pro_light_italic.ttf',
    ['Gotham Pro Medium']        = M .. 'Fonts\\gotham_pro_medium.ttf',
    ['Gotham Pro Medium Italic'] = M .. 'Fonts\\gotham_pro_medium_italic.ttf',
    ['Gotham Pro Narrow Medium'] = M .. 'Fonts\\gotham_pro_narrow_medium.ttf',
    ['Gotham Pro Narrow Bold']   = M .. 'Fonts\\gotham_pro_narrow_bold.ttf',

    ['Oswald Regular']        = M .. 'Fonts\\oswald_regular.ttf',
    ['Oswald Regular Italic'] = M .. 'Fonts\\oswald_regular_italic.ttf',
    ['Oswald Medium']         = M .. 'Fonts\\oswald_medium.ttf',
    ['Oswald Medium Italic']  = M .. 'Fonts\\oswald_medium_italic.ttf',
    ['Oswald Demi']           = M .. 'Fonts\\oswald_demi.ttf',
    ['Oswald Demi Italic']    = M .. 'Fonts\\oswald_demi_italic.ttf',
    ['Oswald Bold']           = M .. 'Fonts\\oswald_bold.ttf',
    ['Oswald Bold Italic']    = M .. 'Fonts\\oswald_bold_italic.ttf',

    ['PT Sans Bold']        = M .. 'Fonts\\ptsans_bold.ttf',
    ['PT Sans Narrow Bold'] = M .. 'Fonts\\ptsans_narrow_bold.ttf',

    ['Roboto']               = M .. 'Fonts\\roboto.ttf',
    ['Roboto Italic']        = M .. 'Fonts\\roboto_italic.ttf',
    ['Roboto Medium']        = M .. 'Fonts\\roboto_medium.ttf',
    ['Roboto Medium Italic'] = M .. 'Fonts\\roboto_medium_italic.ttf',
    ['Roboto Bold']          = M .. 'Fonts\\roboto_bold.ttf',
    ['Roboto Bold Italic']   = M .. 'Fonts\\roboto_bold_italic.ttf',

    ['RPL Regular'] = M .. 'Fonts\\rpl_regular.ttf',

    ['Systopie']                  = M .. 'Fonts\\systopie.ttf',
    ['Systopie Italic']           = M .. 'Fonts\\systopie_italic.ttf',
    ['Systopie Semi Bold']        = M .. 'Fonts\\systopie_semi_bold.ttf',
    ['Systopie Semi Bold Italic'] = M .. 'Fonts\\systopie_semi_bold_italic.ttf',
    ['Systopie Bold']             = M .. 'Fonts\\systopie_bold.ttf',
    ['Systopie Bold Italic']      = M .. 'Fonts\\systopie_bold_italic.ttf',

    ['Teen CYR'] = M .. 'Fonts\\teencyr.ttf',
};

for font_name, font_path in pairs(S.Media.Fonts) do
    LSM:Register(LSM.MediaType.FONT, font_name, font_path, LOCALE_WEST_AND_RU);
end

local hieroglyphsLocales = {
    ['zhCN'] = true,
    ['zhTW'] = true,
    ['koKR'] = true,
};

local isHieroglyphLocale = hieroglyphsLocales[S.ClientLocale];
local fontFlagNone = '';

local StripesCategoryButtonNormalFont = CreateFont('StripesCategoryButtonNormalFont');
if isHieroglyphLocale then
    StripesCategoryButtonNormalFont:CopyFontObject('SystemFont_Med3');
else
    StripesCategoryButtonNormalFont:SetFont(S.Media.Fonts['Systopie Semi Bold Italic'], 14, fontFlagNone);
end
StripesCategoryButtonNormalFont:SetJustifyH('LEFT');
StripesCategoryButtonNormalFont:SetTextColor(1, 1, 1);
StripesCategoryButtonNormalFont:SetShadowColor(0, 0, 0);
StripesCategoryButtonNormalFont:SetShadowOffset(1, -1);

local StripesCategoryButtonHighlightFont = CreateFont('StripesCategoryButtonHighlightFont');
if isHieroglyphLocale then
    StripesCategoryButtonHighlightFont:CopyFontObject('SystemFont_Shadow_Med3');
else
    StripesCategoryButtonHighlightFont:SetFont(S.Media.Fonts['Systopie Semi Bold Italic'], 14, fontFlagNone);
end
StripesCategoryButtonHighlightFont:SetJustifyH('LEFT');
StripesCategoryButtonHighlightFont:SetTextColor(1, 0.85, 0);
StripesCategoryButtonHighlightFont:SetShadowColor(0, 0, 0);
StripesCategoryButtonHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsNormalFont = CreateFont('StripesOptionsNormalFont');
if isHieroglyphLocale then
    StripesOptionsNormalFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsNormalFont:SetFont(S.Media.Fonts['Futura PT Medium'], 13, fontFlagNone);
end
StripesOptionsNormalFont:SetJustifyH('LEFT');
StripesOptionsNormalFont:SetTextColor(1, 1, 1);
StripesOptionsNormalFont:SetShadowColor(0, 0, 0);
StripesOptionsNormalFont:SetShadowOffset(1, -1);

local StripesOptionsHighlightFont = CreateFont('StripesOptionsHighlightFont');
if isHieroglyphLocale then
    StripesOptionsHighlightFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsHighlightFont:SetFont(S.Media.Fonts['Futura PT Medium'], 13, fontFlagNone);
end
StripesOptionsHighlightFont:SetJustifyH('LEFT');
StripesOptionsHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsLightGreyedFont = CreateFont('StripesOptionsLightGreyedFont');
if isHieroglyphLocale then
    StripesOptionsLightGreyedFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsLightGreyedFont:SetFont(S.Media.Fonts['Futura PT Medium'], 13, fontFlagNone);
end
StripesOptionsLightGreyedFont:SetJustifyH('LEFT');
StripesOptionsLightGreyedFont:SetTextColor(0.75, 0.75, 0.75);
StripesOptionsLightGreyedFont:SetShadowColor(0, 0, 0);
StripesOptionsLightGreyedFont:SetShadowOffset(1, -1);

local StripesOptionsDisabledFont = CreateFont('StripesOptionsDisabledFont');
if isHieroglyphLocale then
    StripesOptionsDisabledFont:CopyFontObject('SystemFont_Shadow_Med1');
else
    StripesOptionsDisabledFont:SetFont(S.Media.Fonts['Futura PT Medium'], 13, fontFlagNone);
end
StripesOptionsDisabledFont:SetJustifyH('LEFT');
StripesOptionsDisabledFont:SetTextColor(0.35, 0.35, 0.35);
StripesOptionsDisabledFont:SetShadowColor(0, 0, 0);
StripesOptionsDisabledFont:SetShadowOffset(1, -1);

local StripesOptionsTabHighlightFont = CreateFont('StripesOptionsTabHighlightFont');
if isHieroglyphLocale then
    StripesOptionsTabHighlightFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsTabHighlightFont:SetFont(S.Media.Fonts['Systopie Bold'] , 11, fontFlagNone);
end
StripesOptionsTabHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsTabHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsTabHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsTabGreyedFont = CreateFont('StripesOptionsTabGreyedFont');
if isHieroglyphLocale then
    StripesOptionsTabGreyedFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsTabGreyedFont:SetFont(S.Media.Fonts['Systopie Bold'] , 11, fontFlagNone);
end
StripesOptionsTabGreyedFont:SetTextColor(0.75, 0.75, 0.75);
StripesOptionsTabGreyedFont:SetShadowColor(0, 0, 0);
StripesOptionsTabGreyedFont:SetShadowOffset(1, -1);

local StripesOptionsButtonNormalFont = CreateFont('StripesOptionsButtonNormalFont');
if isHieroglyphLocale then
    StripesOptionsButtonNormalFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonNormalFont:SetFont(S.Media.Fonts['Systopie Bold'] , 11, fontFlagNone);
end
StripesOptionsButtonNormalFont:SetTextColor(1, 1, 1);
StripesOptionsButtonNormalFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonNormalFont:SetShadowOffset(1, -1);

local StripesOptionsButtonHighlightFont = CreateFont('StripesOptionsButtonHighlightFont');
if isHieroglyphLocale then
    StripesOptionsButtonHighlightFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonHighlightFont:SetFont(S.Media.Fonts['Systopie Bold'] , 11, fontFlagNone);
end
StripesOptionsButtonHighlightFont:SetTextColor(1, 0.85, 0);
StripesOptionsButtonHighlightFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonHighlightFont:SetShadowOffset(1, -1);

local StripesOptionsButtonDisabledFont = CreateFont('StripesOptionsButtonDisabledFont');
if isHieroglyphLocale then
    StripesOptionsButtonDisabledFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesOptionsButtonDisabledFont:SetFont(S.Media.Fonts['Systopie Bold'] , 11, fontFlagNone);
end
StripesOptionsButtonDisabledFont:SetTextColor(0.35, 0.35, 0.35);
StripesOptionsButtonDisabledFont:SetShadowColor(0, 0, 0);
StripesOptionsButtonDisabledFont:SetShadowOffset(1, -1);

local StripesMediumHighlightFont = CreateFont('StripesMediumHighlightFont');
if isHieroglyphLocale then
    StripesMediumHighlightFont:CopyFontObject('SystemFont_Shadow_Med2');
else
    StripesMediumHighlightFont:SetFont(S.Media.Fonts['Futura PT Medium'], 14, fontFlagNone);
end
StripesMediumHighlightFont:SetJustifyH('LEFT');
StripesMediumHighlightFont:SetTextColor(1, 0.85, 0);
StripesMediumHighlightFont:SetShadowColor(0, 0, 0);
StripesMediumHighlightFont:SetShadowOffset(1, -1);

local StripesLargeHighlightFont = CreateFont('StripesLargeHighlightFont');
if isHieroglyphLocale then
    StripesLargeHighlightFont:CopyFontObject('SystemFont_Shadow_Large');
else
    StripesLargeHighlightFont:SetFont(S.Media.Fonts['Futura PT Medium'], 16, fontFlagNone);
end
StripesLargeHighlightFont:SetJustifyH('LEFT');
StripesLargeHighlightFont:SetTextColor(1, 0.85, 0);
StripesLargeHighlightFont:SetShadowColor(0, 0, 0);
StripesLargeHighlightFont:SetShadowOffset(1, -1);

local StripesSmallNormalFont = CreateFont('StripesSmallNormalFont');
if isHieroglyphLocale then
    StripesSmallNormalFont:CopyFontObject('SystemFont_Shadow_Small2');
else
    StripesSmallNormalFont:SetFont(S.Media.Fonts['Systopie Italic'], 11, fontFlagNone);
end
StripesSmallNormalFont:SetTextColor(1, 1, 1);
StripesSmallNormalFont:SetShadowColor(0, 0, 0);
StripesSmallNormalFont:SetShadowOffset(1, -1);

local StripesMediumNormalSemiBoldFont = CreateFont('StripesMediumNormalSemiBoldFont');
if isHieroglyphLocale then
    StripesMediumNormalSemiBoldFont:CopyFontObject('SystemFont_Shadow_Med2');
else
    StripesMediumNormalSemiBoldFont:SetFont(S.Media.Fonts['Systopie Semi Bold'], 14, fontFlagNone);
end
StripesMediumNormalSemiBoldFont:SetJustifyH('LEFT');
StripesMediumNormalSemiBoldFont:SetTextColor(1, 1, 1);
StripesMediumNormalSemiBoldFont:SetShadowColor(0, 0, 0);
StripesMediumNormalSemiBoldFont:SetShadowOffset(1, -1);