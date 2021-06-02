--[[
    English localisation (default) (with Google Translate help ^-^)
    enGB, enUS
    The number of lines must match in each file!
]]

local _, NAMESPACE = ...;

NAMESPACE[2] = NAMESPACE[2] or {};
NAMESPACE[2]['enUS'] = {};

local L = NAMESPACE[2]['enUS'];

L['RENAME'] = 'Rename';
L['SAVE'] = 'Save';

L['FONT_FLAG_NONE'] = 'None';
L['FONT_FLAG_OUTLINE'] = 'Outline';
L['FONT_FLAG_THICKOUTLINE'] = 'Thick outline';
L['FONT_FLAG_MONOCHROME'] = 'Monochrome';
L['FONT_FLAG_OUTLINE_MONOCHROME'] = 'Monochrome + outline';
L['FONT_FLAG_THICKOUTLINE_MONOCHROME'] = 'Monochrome + thick outline';

L['POSITION_TOP'] = 'Top';
L['POSITION_BOTTOM'] = 'Bottom';
L['POSITION_LEFT'] = 'Left';
L['POSITION_CENTER'] = 'Center';
L['POSITION_RIGHT'] = 'Right';

L['FRAME_ANCHOR_BOTTOM'] = 'Bottom';
L['FRAME_ANCHOR_BOTTOMLEFT'] = 'Bottom left';
L['FRAME_ANCHOR_BOTTOMRIGHT'] = 'Bottom right';
L['FRAME_ANCHOR_CENTER'] = 'Center';
L['FRAME_ANCHOR_LEFT'] = 'Left';
L['FRAME_ANCHOR_RIGHT'] = 'Right';
L['FRAME_ANCHOR_TOP'] = 'Top';
L['FRAME_ANCHOR_TOPLEFT'] = 'Top left';
L['FRAME_ANCHOR_TOPRIGHT'] = 'Top right';

L['FRAME_STRATA_INHERIT'] = 'Inherit';

L['AURAS_SORT_EXPIRES_ASC'] = 'By less time';
L['AURAS_SORT_EXPIRES_DESC'] = 'By longer time';

L['MINIMAP_BUTTON_LMB'] = 'LMB';
L['MINIMAP_BUTTON_OPEN'] = 'Open «Stripes» options';
L['MINIMAP_BUTTON_RMB'] = 'RMB';
L['MINIMAP_BUTTON_HIDE'] = 'Hide this button';
L['MINIMAP_BUTTON_COMMAND_SHOW'] = 'Use /stripes minimap to show the minimap button again';
L['MINIMAP_ACTIVE_PROFILE'] = 'Active profile';

L['DUNGEON_SL_MISTS'] = 'Mists of Tirna Scithe';
L['DUNGEON_SL_NW'] = 'The Necrotic Wake';
L['DUNGEON_SL_DOS'] = 'De Other Side';
L['DUNGEON_SL_HOA'] = 'Halls of Atonement';
L['DUNGEON_SL_PF'] = 'Plaguefall';
L['DUNGEON_SL_SD'] = 'Sanguine Depths';
L['DUNGEON_SL_SOA'] = 'Spires of Ascension';
L['DUNGEON_SL_TOP'] = 'Theater of Pain';
L['DUNGEON_SL_TTVM'] = 'Tazavesh, the Veiled Market';

L['RAID_SL_CN'] = 'Castle Nathria';
L['RAID_SL_SOD'] = 'Sanctum of Domination';

L['PSEUDOLINK_TOOLTIP'] = 'CTRL-C to copy';

L['OPTIONS_NEED_RELOAD'] = 'You must reload the interface to apply the settings.\r\rReload now?';
L['OPTIONS_HIDED_IN_COMBAT'] = 'The settings were hidden for the duration of the combat and will be automatically opened after the end of the combat';
L['OPTIONS_WILL_BE_OPENED_AFTER_COMBAT'] = 'The settings will be opened after the combat';

L['OPTIONS_CATEGORY_COMMON'] = 'General';
L['OPTIONS_CATEGORY_SIZES'] = 'Sizes';
L['OPTIONS_CATEGORY_VISIBILITY'] = 'Visibility';
L['OPTIONS_CATEGORY_HEALTHBAR'] = 'Health bar';
L['OPTIONS_CATEGORY_CASTBAR'] = 'Cast bar';
L['OPTIONS_CATEGORY_AURAS'] = 'Auras';
L['OPTIONS_CATEGORY_CUSTOMCOLOR'] = 'Custom HP bar colors';
L['OPTIONS_CATEGORY_MYTHIC_PLUS'] = 'Mythic+';
L['OPTIONS_CATEGORY_USEFUL'] = 'Useful';
L['OPTIONS_CATEGORY_PROFILES'] = 'Profiles';
L['OPTIONS_CATEGORY_INFO'] = 'Info';

L['OPTIONS_INFO_VERSION'] = 'Version';

L['OPTIONS_HOME_FREQUENTLY_USED_OPTIONS_TIP'] = 'Here will be links to the most frequently used options';
L['OPTIONS_HOME_DELETE_TIP'] = 'Right-click to delete what you need';

L['OPTIONS_PROFILE_DEFAULT_NAME'] = 'Default';
L['OPTIONS_PROFILES_ACTIVE_PROFILE'] = 'Active profile:';
L['OPTIONS_PROFILES_CHOOSE_PROFILE'] = 'Choose profile';
L['OPTIONS_PROFILES_CREATE_NEW_ENTER_NAME'] = 'Enter a name';
L['OPTIONS_PROFILES_COPY_FROM_ACTIVE_BUTTON_LABEL'] = 'Copy from active';
L['OPTIONS_PROFILES_CREATE_DEFAULT_PROFILE_BUTTON_LABEL'] = 'Create default profile';
L['OPTIONS_PROFILES_EXPORT_BUTTON_LABEL'] = 'Export';
L['OPTIONS_PROFILES_IMPORT_BUTTON_LABEL'] = 'Import';
L['OPTIONS_PROFILES_REMOVE_PROFILE'] = 'Profile annihilation';
L['OPTIONS_PROFILES_EXPORT_COPIED'] = 'Job`s done';
L['OPTIONS_PROFILES_IMPORT_FAILED'] = 'Check that the string you entered is correct';
L['OPTIONS_PROFILES_IMPORT_FAILED_DECOMPRESSION'] = 'Failed decompression when importing the profile!';
L['OPTIONS_PROFILES_IMPORT_FAILED_DESERIALIZATION'] = 'Failed deserialization when importing the profile!';
L['OPTIONS_PROFILES_RESET_PROFILE_TO_DEFAULT_PROMPT'] = 'Reset all profile settings to their default values?';
L['OPTIONS_PROFILES_RESET_PROFILE_BUTTON'] = 'Reset profile';

L['OPTIONS_SHOW'] = 'Show';
L['OPTIONS_TEXTURE'] = 'Texture';
L['OPTIONS_OTHER'] = 'Other';
L['OPTIONS_COMMON'] = 'Common';
L['OPTIONS_OK'] = 'Ok';
L['OPTIONS_CLOSE'] = 'Close';
L['OPTIONS_RESET'] = 'Reset';

L['OPTIONS_FONT_VALUE'] = 'Font';
L['OPTIONS_FONT_SIZE'] = 'Size';
L['OPTIONS_FONT_FLAG'] = 'Outline';
L['OPTIONS_FONT_SHADOW'] = 'Shadow';

L['OPTIONS_COMMON_TAB_NAME'] = 'Name';
L['OPTIONS_COMMON_TAB_HEALTHTEXT'] = 'Health';
L['OPTIONS_COMMON_TAB_LEVELTEXT'] = 'Level';

L['OPTIONS_NAME_TEXT_SHOW'] = 'Show name';
L['OPTIONS_NAME_TEXT_FONT_VALUE'] = 'Name font';
L['OPTIONS_NAME_TEXT_FONT_SIZE'] = 'Name font size';
L['OPTIONS_NAME_TEXT_FONT_FLAG'] = 'Name font outline';
L['OPTIONS_NAME_TEXT_FONT_SHADOW'] = 'Name font shadow';
L['OPTIONS_NAME_TEXT_POSITION'] = 'Position';
L['OPTIONS_NAME_TEXT_POSITION_TOOLTIP'] = 'Horizontal name position';
L['OPTIONS_NAME_TEXT_POSITION_V_TOOLTIP'] = 'Vertical name position';
L['OPTIONS_NAME_TEXT_OFFSET_Y_TOOLTIP'] = 'Vertical name offset';
L['OPTIONS_NAME_TEXT_TRUNCATE'] = 'Truncate';
L['OPTIONS_NAME_TEXT_TRUNCATE_TOOLTIP'] = 'Truncate the name if it goes outside the health bar';
L['OPTIONS_NAME_TEXT_ABBREVIATED'] = 'NPC name abbreviation';
L['OPTIONS_NAME_TEXT_ABBREVIATED_WITH_SPACE'] = 'With space';
L['OPTIONS_NAME_TEXT_ABBREVIATED_WITH_SPACE_TOOLTIP'] = 'Abbreviation of the NPC name with a space after the dot';
L['OPTIONS_NAME_TEXT_COLORING'] = 'Coloring';
L['OPTIONS_NAME_TEXT_COLORING_MODE_TOOLTIP'] = 'Name coloring mode';
L['OPTIONS_NAME_TEXT_COLORING_MODE_NONE'] = 'Don\'t coloring';
L['OPTIONS_NAME_TEXT_COLORING_MODE_CLASS'] = 'By class color';
L['OPTIONS_NAME_TEXT_COLORING_MODE_FACTION'] = 'By faction color';
L['OPTIONS_FACTION_ICON_ENABLED'] = 'Faction icon';
L['OPTIONS_FACTION_ICON_ENABLED_TOOLTIP'] = 'Show faction icon to the left of the name';
L['OPTIONS_TARGET_NAME_ENABLED'] = 'Target name';
L['OPTIONS_TARGET_NAME_ENABLED_TOOLTIP'] = 'Show the target name of the visible nameplate to the right of its name';
L['OPTIONS_TARGET_NAME_ONLY_ENEMY'] = 'Only for enemies';
L['OPTIONS_TARGET_NAME_ONLY_ENEMY_TOOLTIP'] = 'Show the target name only for enemy nameplates';
L['OPTIONS_NAME_TEXT_SHOW_ARENAID'] = 'Show «Arena ID»';
L['OPTIONS_NAME_TEXT_SHOW_ARENAID_TOOLTIP'] = 'Show the ID of the opponents in the arena (along with the names)';
L['OPTIONS_NAME_TEXT_SHOW_ARENAID_SOLO'] = 'Only «Arena ID»';
L['OPTIONS_NAME_TEXT_SHOW_ARENAID_SOLO_TOOLTIP'] = 'Show only the ID of the opponents in the arena (without names)';
L['OPTIONS_NAME_WITHOUT_REALM'] = 'Without realm';
L['OPTIONS_NAME_WITHOUT_REALM_TOOLTIP'] = 'Show player names without realm name';

L['OPTIONS_SHOW_HEALTH_TEXT'] = 'Show health text';
L['OPTIONS_HEALTH_TEXT_HIDE_FULL'] = 'Hide full';
L['OPTIONS_HEALTH_TEXT_HIDE_FULL_TOOLTIP'] = 'Hide when full health';
L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE'] = 'Display mode';
L['OPTIONS_HEALTH_TEXT_DISPLAY_MODE_TOOLTIP'] = 'Health text display mode';
L['OPTIONS_HEALTH_TEXT_FONT_VALUE'] = 'Health text font';
L['OPTIONS_HEALTH_TEXT_FONT_SIZE'] = 'Health text font size';
L['OPTIONS_HEALTH_TEXT_FONT_FLAG'] = 'Health text font outline';
L['OPTIONS_HEALTH_TEXT_FONT_SHADOW'] = 'Health text font shadow';
L['OPTIONS_HEALTH_TEXT_X_OFFSET'] = 'Hor. offset';
L['OPTIONS_HEALTH_TEXT_X_OFFSET_TOOLTIP'] = 'Horizontal health text offset';
L['OPTIONS_HEALTH_TEXT_Y_OFFSET'] = 'Vert. offset';
L['OPTIONS_HEALTH_TEXT_Y_OFFSET_TOOLTIP'] = 'Vertical health text offset';
L['OPTIONS_HEALTH_TEXT_ANCHOR'] = 'Position';
L['OPTIONS_HEALTH_TEXT_ANCHOR_TOOLTIP'] = 'Health text position';
L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED'] = 'Custom color';
L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP'] = 'Use custom color for the health text';
L['OPTIONS_HEALTH_TEXT_CUSTOM_COLOR_TOOLTIP'] = 'Custom color for the health text';

L['OPTIONS_SHOW_LEVEL_TEXT'] = 'Show level text';
L['OPTIONS_LEVEL_TEXT_FONT_VALUE'] = 'Level text font';
L['OPTIONS_LEVEL_TEXT_FONT_SIZE'] = 'Level text font size';
L['OPTIONS_LEVEL_TEXT_FONT_FLAG'] = 'Level text font outline';
L['OPTIONS_LEVEL_TEXT_FONT_SHADOW'] = 'Level text font shadow';
L['OPTIONS_LEVEL_TEXT_USE_DIFF_COLOR'] = 'Coloring';
L['OPTIONS_LEVEL_TEXT_USE_DIFF_COLOR_TOOLTIP'] = 'Color the level depending on your level and the target level';
L['OPTIONS_LEVEL_TEXT_X_OFFSET'] = 'Hor. offset';
L['OPTIONS_LEVEL_TEXT_X_OFFSET_TOOLTIP'] = 'Horizontal level text offset';
L['OPTIONS_LEVEL_TEXT_Y_OFFSET'] = 'Vert. offset';
L['OPTIONS_LEVEL_TEXT_Y_OFFSET_TOOLTIP'] = 'Vertical level text offset';
L['OPTIONS_LEVEL_TEXT_ANCHOR'] = 'Position';
L['OPTIONS_LEVEL_TEXT_ANCHOR_TOOLTIP'] = 'Level text position';
L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_ENABLED'] = 'Custom color';
L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_ENABLED_TOOLTIP'] = 'Use custom color for the level text';
L['OPTIONS_LEVEL_TEXT_CUSTOM_COLOR_TOOLTIP'] = 'Custom color for the level text';

L['OPTIONS_HEALTH_BAR_TEXTURE_VALUE_TOOLTIP'] = 'Health bar texture';
L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY'] = 'Friendly players: class color';
L['OPTIONS_HEALTH_BAR_CLASS_COLOR_FRIENDLY_TOOLTIP'] = 'Color health bar of friendly players to match the class color';
L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY'] = 'Enemy players: class color';
L['OPTIONS_HEALTH_BAR_CLASS_COLOR_ENEMY_TOOLTIP'] = 'Color health bar of enemy players to match the class color';
L['OPTIONS_HEALTH_BAR_BORDER_THIN'] = 'Thin border';
L['OPTIONS_HEALTH_BAR_BORDER_THIN_TOOLTIP'] = 'Make a thin border around the health bar';
L['OPTIONS_HEALTH_BAR_BORDER_HIDE'] = 'Hide border';
L['OPTIONS_HEALTH_BAR_BORDER_HIDE_TOOLTIP'] = 'Hide the border around the health bar';
L['OPTIONS_HEADER_ABSORB'] = 'Absorbs (shields)';
L['OPTIONS_ABSORB_BAR_ENABLED'] = 'Absorb bar';
L['OPTIONS_ABSORB_BAR_ENABLED_TOOLTIP'] = 'Show absorb bar in relation to the amount of health';
L['OPTIONS_ABSORB_BAR_AT_TOP'] = 'At top';
L['OPTIONS_ABSORB_BAR_AT_TOP_TOOLTIP'] = 'Show absorb bar at the top of the health bar';
L['OPTIONS_HEADER_THREAT'] = 'Threat';
L['OPTIONS_THREAT_COLOR_ENABLED'] = 'Threat color';
L['OPTIONS_THREAT_COLOR_ENABLED_TOOLTIP'] = 'Change the color of the health bar depending on the amount of threat';
L['OPTIONS_THREAT_COLOR_REVERSED'] = 'Reversed';
L['OPTIONS_THREAT_COLOR_REVERSED_TOOLTIP'] = 'Reverse the threat colors';
L['OPTIONS_THREAT_COLOR_STATUS_0_TOOLTIP'] = 'Not tanking, lower threat than tank';
L['OPTIONS_THREAT_COLOR_STATUS_1_TOOLTIP'] = 'Not tanking, higher threat than tank';
L['OPTIONS_THREAT_COLOR_STATUS_2_TOOLTIP'] = 'Insecurely tanking, another unit have higher threat but not tanking';
L['OPTIONS_THREAT_COLOR_STATUS_3_TOOLTIP'] = 'Securely tanking, highest threat';
L['OPTIONS_THREAT_COLOR_OFFTANK_TOOLTIP'] = 'Offtank';
L['OPTIONS_RESET_THREAT_COLORS'] = 'Reset colors';
L['OPTIONS_RESET_THREAT_COLORS_TOOLTIP'] = 'Reset threat colors to default values';
L['OPTIONS_HEADER_TARGET_INDICATOR'] = 'Target indicator';
L['OPTIONS_TARGET_INDICATOR_ENABLED'] = 'Enable';
L['OPTIONS_TARGET_INDICATOR_ENABLED_TOOLTIP'] = 'Show indicator of the current target nameplate';
L['OPTIONS_TARGET_INDICATOR_COLOR_TOOLTIP'] = 'Target indicator texture color';
L['OPTIONS_TARGET_INDICATOR_TEXTURE'] = 'Texture';
L['OPTIONS_TARGET_INDICATOR_TEXTURE_TOOLTIP'] = 'Target idicator texture|n|nIf the texture is colored, then paint it white and everything will be fine';
L['OPTIONS_TARGET_INDICATOR_SIZE_TOOLTIP'] = 'Size of the target indicator texture';
L['OPTIONS_TARGET_INDICATOR_X_OFFSET_TOOLTIP'] = 'Horizontal offset of the target indicator texture';
L['OPTIONS_TARGET_INDICATOR_Y_OFFSET_TOOLTIP'] = 'Vertical offset of the target indicator texture';
L['OPTIONS_TARGET_GLOW_ENABLED'] = 'Target glow';
L['OPTIONS_TARGET_GLOW_ENABLED_TOOLTIP'] = 'Show glow of the current target nameplate';
L['OPTIONS_TARGET_GLOW_COLOR_TOOLTIP'] = 'Glow color';
L['OPTIONS_HOVER_GLOW_ENABLED'] = 'On hover';
L['OPTIONS_HOVER_GLOW_ENABLED_TOOLTIP'] = 'Show glow on mouse over nameplates';
L['OPTIONS_HEADER_EXECUTION'] = 'Execution';
L['OPTIONS_EXECUTION_ENABLED'] = 'Enable';
L['OPTIONS_EXECUTION_ENABLED_TOOLTIP'] = 'Enable execution indication';
L['OPTIONS_EXECUTION_COLOR_TOOLTIP'] = 'Color of the health bar when the specified percentage of the health is reached';
L['OPTIONS_EXECUTION_LOW_TEXT'] = 'If less than or equal to';
L['OPTIONS_EXECUTION_LOW_PERCENT_TOOLTIP'] = 'Percentage of lower health threshold';
L['OPTIONS_EXECUTION_HIGH_ENABLED'] = 'Enable higher threshold';
L['OPTIONS_EXECUTION_HIGH_ENABLED_TOOLTIP'] = 'Enable higher health threshold';
L['OPTIONS_EXECUTION_HIGH_TEXT'] = 'If more than or equal to';
L['OPTIONS_EXECUTION_HIGH_PERCENT_TOOLTIP'] = 'Percentage of higher health threshold';
L['OPTIONS_EXECUTION_GLOW'] = 'Pixel glow';
L['OPTIONS_EXECUTION_GLOW_TOOLTIP'] = 'Show pixel glow around health bar';

L['OPTIONS_CAST_BAR_TEXTURE_VALUE_TOOLTIP'] = 'Cast bar texture';
L['OPTIONS_CAST_BAR_TEXT_FONT_VALUE'] = 'Spell name font';
L['OPTIONS_CAST_BAR_TEXT_FONT_SIZE'] = 'Spell name font size';
L['OPTIONS_CAST_BAR_TEXT_FONT_FLAG'] = 'Spell name font outline';
L['OPTIONS_CAST_BAR_TEXT_FONT_SHADOW'] = 'Spell name font shadow';
L['OPTIONS_CAST_BAR_ON_HP_BAR'] = 'On health bar';
L['OPTIONS_CAST_BAR_ON_HP_BAR_TOOLTIP'] = 'Show cast bar on health bar';
L['OPTIONS_CAST_BAR_ICON_LARGE'] = 'Icon: large';
L['OPTIONS_CAST_BAR_ICON_LARGE_TOOLTIP'] = 'Show a large spell icon |n|n|cffffb833doesn\'t work if «On health bar» is turned on|r';
L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE'] = 'Icon: right side';
L['OPTIONS_CAST_BAR_ICON_RIGHT_SIDE_TOOLTIP'] = 'Show spell icon on the right side';
L['OPTIONS_CAST_BAR_TIMER_ENABLED'] = 'Timer';
L['OPTIONS_CAST_BAR_TIMER_ENABLED_TOOLTIP'] = 'Show a timer next to the cast bar';
L['OPTIONS_WHO_INTERRUPTED_ENABLED'] = 'Who interrupted';
L['OPTIONS_WHO_INTERRUPTED_ENABLED_TOOLTIP'] = 'Show the name of the player who interrupted a spell';
L['OPTIONS_CAST_BAR_START_CAST_COLOR'] = 'Normal';
L['OPTIONS_CAST_BAR_START_CAST_COLOR_TOOLTIP'] = 'Cast bar color for normal spells';
L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR'] = 'Channel';
L['OPTIONS_CAST_BAR_START_CHANNEL_COLOR_TOOLTIP'] = 'Cast bar color for channel spells';
L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR'] = 'Non interruptible';
L['OPTIONS_CAST_BAR_NON_INTERRUPTIBLE_COLOR_TOOLTIP'] = 'Cast bar color for non interruptible spells';
L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR'] = 'Failed';
L['OPTIONS_CAST_BAR_FAILED_CAST_COLOR_TOOLTIP'] = 'Cast bar color for failed spells casts';
L['OPTIONS_CAST_BAR_RESET_COLORS'] = 'Reset colors';
L['OPTIONS_CAST_BAR_RESET_COLORS_TOOLTIP'] = 'Reset cast bar colors to default values';
L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS'] = 'Trade skills casts';
L['OPTIONS_CAST_BAR_SHOW_TRADE_SKILLS_TOOLTIP'] = 'Show the cast bar when creating items';
L['OPTIONS_CAST_BAR_SHOW_SHIELD'] = 'Shield';
L['OPTIONS_CAST_BAR_SHOW_SHIELD_TOOLTIP'] = 'Show shield icon for non interruptible spells';
L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE'] = 'Icon for non interruptible spells';
L['OPTIONS_CAST_BAR_SHOW_ICON_NOTINTERRUPTIBLE_TOOLTIP'] = 'Show the spell icon for non interruptible spells';

L['OPTIONS_SIZES_TAB_ENEMY'] = 'Enemy';
L['OPTIONS_SIZES_TAB_FRIENDLY'] = 'Friendly';
L['OPTIONS_SIZES_TAB_SELF'] = 'Self';
L['OPTIONS_SIZES_TAB_OTHER'] = 'Other';
L['OPTIONS_SIZES_SHOW_CLICKABLE_AREA'] = 'Show clickable area';
L['OPTIONS_SIZES_ENEMY_CLICKABLE_WIDTH'] = 'Width';
L['OPTIONS_SIZES_ENEMY_CLICKABLE_WIDTH_TOOLTIP'] = 'Width of health bar and clickable area for enemy units';
L['OPTIONS_SIZES_ENEMY_CLICKABLE_HEIGHT'] = 'Height of click-area';
L['OPTIONS_SIZES_ENEMY_CLICKABLE_HEIGHT_TOOLTIP'] = 'Height of click-area for enemy units';
L['OPTIONS_SIZES_ENEMY_HEIGHT'] = 'Height';
L['OPTIONS_SIZES_ENEMY_HEIGHT_TOOLTIP'] = 'Height of the health bar for enemy normal+ units';
L['OPTIONS_SIZES_ENEMY_MINUS_HEIGHT'] = 'Height (minus)';
L['OPTIONS_SIZES_ENEMY_MINUS_HEIGHT_TOOLTIP'] = 'Height of the health bar for enemy minor units';
L['OPTIONS_SIZES_ENEMY_CLICK_THROUGH'] = 'Disable mouse clicks';
L['OPTIONS_SIZES_ENEMY_CLICK_THROUGH_TOOLTIP'] = 'Disable the ability to click on enemy nameplates';
L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_WIDTH'] = 'Width';
L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_WIDTH_TOOLTIP'] = 'Width of health bar and clickable area for friendly units';
L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_HEIGHT'] = 'Height of click-area';
L['OPTIONS_SIZES_FRIENDLY_CLICKABLE_HEIGHT_TOOLTIP'] = 'Height of click-area for friendly units';
L['OPTIONS_SIZES_FRIENDLY_HEIGHT'] = 'Height';
L['OPTIONS_SIZES_FRIENDLY_HEIGHT_TOOLTIP'] = 'Height of the health bar for friendly units';
L['OPTIONS_SIZES_FRIENDLY_CLICK_THROUGH'] = 'Disable mouse clicks';
L['OPTIONS_SIZES_FRIENDLY_CLICK_THROUGH_TOOLTIP'] = 'Disable the ability to click on friendly nameplates';
L['OPTIONS_SIZES_SELF_WIDTH'] = 'Width';
L['OPTIONS_SIZES_SELF_WIDTH_TOOLTIP'] = 'Width of the personal nameplate';
L['OPTIONS_SIZES_SELF_HEIGHT'] = 'Height';
L['OPTIONS_SIZES_SELF_HEIGHT_TOOLTIP'] = 'Height of the health bar and resource bar of the personal nameplate';
L['OPTIONS_SIZES_SELF_CLICK_THROUGH'] = 'Disable mouse clicks';
L['OPTIONS_SIZES_SELF_CLICK_THROUGH_TOOLTIP'] = 'Disable the ability to click on a personal nameplate';
L['OPTIONS_SIZES_SCALE_LARGE'] = 'Scale (large)';
L['OPTIONS_SIZES_SCALE_LARGE_TOOLTIP'] = 'Scale of the nameplate for important units';
L['OPTIONS_SIZES_SCALE_GLOBAL'] = 'Scale (other)';
L['OPTIONS_SIZES_SCALE_GLOBAL_TOOLTIP'] = 'Scale of the nameplate for other units';
L['OPTIONS_SIZES_SCALE_SELECTED'] = 'Scale (target)';
L['OPTIONS_SIZES_SCALE_SELECTED_TOOLTIP'] = 'Scale of the nameplate for selected unit';
L['OPTIONS_SIZES_SCALE_SELF'] = 'Scale (self)';
L['OPTIONS_SIZES_SCALE_SELF_TOOLTIP'] = 'Scale of the personal nameplate';
L['OPTIONS_SIZES_OVERLAP_H'] = 'Hor. overlap';
L['OPTIONS_SIZES_OVERLAP_H_TOOLTIP'] = 'Horizontal overlap';
L['OPTIONS_SIZES_OVERLAP_V'] = 'Vert. overlap';
L['OPTIONS_SIZES_OVERLAP_V_TOOLTIP'] = 'Vertical overlap';
L['OPTIONS_SIZES_LARGE_TOP_INSET'] = 'Top inset (Large)';
L['OPTIONS_SIZES_LARGE_TOP_INSET_TOOLTIP'] = 'The inset from top (in screen percent) that large nameplates are clamped to';
L['OPTIONS_SIZES_LARGE_BOTTOM_INSET'] = 'Bottom inset (Large)';
L['OPTIONS_SIZES_LARGE_BOTTOM_INSET_TOOLTIP'] = 'The inset from bottom (in screen percent) that large nameplates are clamped to';
L['OPTIONS_SIZES_OTHER_TOP_INSET'] = 'Top inset (other)';
L['OPTIONS_SIZES_OTHER_TOP_INSET_TOOLTIP'] = 'The inset from top (in screen percent) that the non-self nameplates are clamped to';
L['OPTIONS_SIZES_OTHER_BOTTOM_INSET'] = 'Bottom inset (other)';
L['OPTIONS_SIZES_OTHER_BOTTOM_INSET_TOOLTIP'] = 'The inset from bottom (in screen percent) that the non-self nameplates are clamped to';
L['OPTIONS_SIZES_SELF_TOP_INSET'] = 'Top inset (self)';
L['OPTIONS_SIZES_SELF_TOP_INSET_TOOLTIP'] = 'The inset from top (in screen percent) that the personal nameplate is clamped to';
L['OPTIONS_SIZES_SELF_BOTTOM_INSET'] = 'Bottom inset (self)';
L['OPTIONS_SIZES_SELF_BOTTOM_INSET_TOOLTIP'] = 'The inset from bottom (in screen percent) that the personal nameplate is clamped to';

L['OPTIONS_VISIBILITY_TAB_COMMON'] = 'General';
L['OPTIONS_VISIBILITY_TAB_ENEMY'] = 'Enemy';
L['OPTIONS_VISIBILITY_TAB_FRIENDLY'] = 'Friendly';
L['OPTIONS_VISIBILITY_TAB_SELF'] = 'Self';
L['OPTIONS_VISIBILITY_MOTION'] = 'Arrangement';
L['OPTIONS_VISIBILITY_MOTION_TOOLTIP'] = 'Arrangement of nameplates';
L['OPTIONS_VISIBILITY_MOTION_SPEED_TOOLTIP'] = 'The speed of placing namplates on their positions|n|n|cffff6666It is not recommended to set a high value!|r';
L['OPTIONS_VISIBILITY_SHOW_ALWAYS_OPENWORLD'] = 'Always in open world';
L['OPTIONS_VISIBILITY_SHOW_ALWAYS_OPENWORLD_TOOLTIP'] = 'Enable permanent display of nameplates in open world';
L['OPTIONS_VISIBILITY_SHOW_ALWAYS_INSTANCE'] = 'Always in instances';
L['OPTIONS_VISIBILITY_SHOW_ALWAYS_INSTANCE_TOOLTIP'] = 'Enable permanent display of nameplates in dungeons / raids';
L['OPTIONS_VISIBILITY_MAX_DISTANCE_OPENWORLD'] = 'Open world';
L['OPTIONS_VISIBILITY_MAX_DISTANCE_OPENWORLD_TOOLTIP'] = 'Nameplates disntance in open world|n|n|cffffb833Locked by«Blizzard»|r';
L['OPTIONS_VISIBILITY_MAX_DISTANCE_INSTANCE'] = 'Dungeons / Raids';
L['OPTIONS_VISIBILITY_MAX_DISTANCE_INSTANCE_TOOLTIP'] = 'Nameplates disntance in dungeons / raids|n|n|cffffb833Locked by«Blizzard»|r';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY'] = 'Show';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOOLTIP'] = 'Show friendly nameplates|n|nIf permanent visibility is disabled in the open world, friendly nameplates will only be shown when these units are in combat or they will not have enough health';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_ONLY_IN_COMBAT'] = 'Only in combat';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_ONLY_IN_COMBAT_TOOLTIP'] = 'Show friendly nameplates only in combat';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_MINIONS'] = 'Minions';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_MINIONS_TOOLTIP'] = 'Show friendly minions';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_GUARDIANS'] = 'Guardians';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_GUARDIANS_TOOLTIP'] = 'Show friendly guardians';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_NPCS'] = 'NPC';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_NPCS_TOOLTIP'] = 'Show friendly NPCs';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_PETS'] = 'Pets';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_PETS_TOOLTIP'] = 'Show friendly pets';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOTEMS'] = 'Totems';
L['OPTIONS_VISIBILITY_SHOW_FRIENDLY_TOTEMS_TOOLTIP'] = 'Show friendly totems';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL'] = 'Show';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL_TOOLTIP'] = 'Show personal nameplate';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL_ALWAYS'] = 'Always';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL_ALWAYS_TOOLTIP'] = 'Always show personal nameplate';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL_RESOURCE_ONTARGET'] = 'Resources on target';
L['OPTIONS_VISIBILITY_SHOW_PERSONAL_RESOURCE_ONTARGET_TOOLTIP'] = 'Show own special resources on target';
L['OPTIONS_VISIBILITY_HIDE_NON_CAST_ENABLED'] = 'Hide non-casting';
L['OPTIONS_VISIBILITY_HIDE_NON_CAST_ENABLED_TOOLTIP'] = 'Hide non-casting nameplates when the selected key is pressed';
L['OPTIONS_VISIBILITY_HIDE_NON_CAST_MODIFIER_TOOLTIP'] = 'Key for hiding';
L['OPTIONS_VISIBILITY_HIDE_NON_CAST_SHOW_UNINTERRUPTIBLE'] = 'Show uninterruptible casts'
L['OPTIONS_VISIBILITY_HIDE_NON_CAST_SHOW_UNINTERRUPTIBLE_TOOLTIP'] = 'Leave visible nameplates casting uninterruptible spells';
L['OPTIONS_HEADER_NAME_ONLY'] = '«Name Only» mode';
L['OPTIONS_VISIBILITY_NAME_ONLY_ENABLED'] = 'Enable';
L['OPTIONS_VISIBILITY_NAME_ONLY_ENABLED_TOOLTIP'] = 'Enable «Name Only» mode for friendly nameplates|n|nIn this mode, the health bars and spells of friendly nameplates are hidden|n|n|cffff6666After enabling, for the full operation of this feature, you need to reload the interface!|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_HEALTH'] = 'Health progress in the name';
L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_HEALTH_TOOLTIP'] = 'Fill in the name with gray color in relation to the lost amount of health|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_CLASS'] = 'Name by class color';
L['OPTIONS_VISIBILITY_NAME_ONLY_COLOR_NAME_BY_CLASS_TOOLTIP'] = 'Color the name by the color of the class in the «Name Only» mode|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME'] = 'Guild name / title';
L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_TOOLTIP'] = 'Show the guild name or NPC title under the name in the «Name Only» mode|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_COLOR_TOOLTIP'] = 'Guild name or NPC title color in the «Name Only» mode';
L['OPTIONS_VISIBILITY_NAME_ONLY_GUILD_NAME_SAME_COLOR_TOOLTIP'] = 'Guild name color if you are a member of the same guild';
L['OPTIONS_VISIBILITY_NAME_ONLY_Y_OFFSET'] = 'Vertical offset';
L['OPTIONS_VISIBILITY_NAME_ONLY_Y_OFFSET_TOOLTIP'] = 'Vertical offset of the name in the «Name Only» mode|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_PLAYERS_ONLY'] = 'Players only';
L['OPTIONS_VISIBILITY_NAME_ONLY_PLAYERS_ONLY_TOOLTIP'] = 'Show only players in the «Name Only» mode|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_NAME_PVP'] = 'Name with title';
L['OPTIONS_VISIBILITY_NAME_ONLY_NAME_PVP_TOOLTIP'] = 'Show the name along with the title in the «Name Only» mode|n|n|cffff6666Only in open world|r';
L['OPTIONS_VISIBILITY_NAME_ONLY_STACKING'] = 'Stacking';
L['OPTIONS_VISIBILITY_NAME_ONLY_STACKING_TOOLTIP'] = 'Overlap friendly nameplates in «Name Only» mode';
L['OPTIONS_VISIBILITY_SHOW_ENEMY'] = 'Show';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOOLTIP'] = 'Show enemy nameplates';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_ONLY_IN_COMBAT'] = 'Only in combat';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_ONLY_IN_COMBAT_TOOLTIP'] = 'Show enemy nameplates only in combat';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINIONS'] = 'Minions';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINIONS_TOOLTIP'] = 'Show enemy minions';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_GUARDIANS'] = 'Guardians';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_GUARDIANS_TOOLTIP'] = 'Show enemy guardians';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINUS'] = 'Minus';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_MINUS_TOOLTIP'] = 'Show enemy minor creatures';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_PETS'] = 'Pets';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_PETS_TOOLTIP'] = 'Show enemy pets';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOTEMS'] = 'Totems';
L['OPTIONS_VISIBILITY_SHOW_ENEMY_TOTEMS_TOOLTIP'] = 'Show enemy totems';
L['OPTIONS_HEADER_RAID_TARGET_ICON'] = 'Target marker icon';
L['OPTIONS_RAID_TARGET_ICON_SHOW'] = 'Show';
L['OPTIONS_RAID_TARGET_ICON_SHOW_TOOLTIP'] = 'Show target marker icon';
L['OPTIONS_RAID_TARGET_ICON_SCALE'] = 'Scale';
L['OPTIONS_RAID_TARGET_ICON_SCALE_TOOLTIP'] = 'Scale of the target marker icon';
L['OPTIONS_RAID_TARGET_ICON_POSITION'] = 'Position';
L['OPTIONS_RAID_TARGET_ICON_POSITION_TOOLTIP'] = 'Position of the target marker icon';
L['OPTIONS_RAID_TARGET_ICON_POSITION_OFFSET_X_TOOLTIP'] = 'Horizontal offset of the target marker icon';
L['OPTIONS_RAID_TARGET_ICON_POSITION_OFFSET_Y_TOOLTIP'] = 'Vertical offset of the target marker icon';
L['OPTIONS_RAID_TARGET_ICON_FRAME_STRATA'] = 'Strata';
L['OPTIONS_RAID_TARGET_ICON_FRAME_STRATA_TOOLTIP'] = 'Strata of the target marker icon';

L['OPTIONS_HEADER_PERCENTAGE'] = 'Percentage';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_ENABLED'] = 'Enable';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_ENABLED_TOOLTIP'] = 'Enable display of percentages for creature under the health bar';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_USE_MODE_TOOLTIP'] = 'Database for displaying percentages';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_USE_MODE_EMBEDDED'] = 'Stripes DB';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_USE_MODE_MDT'] = 'Mythic Dungeon Tools DB';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_VALUE'] = 'Percentage font value';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SIZE'] = 'Percentage font size';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_FLAG'] = 'Percentage font outline';
L['OPTIONS_MYTHIC_PLUS_PERCENTAGE_FONT_SHADOW'] = 'Percentage font shadow';
L['OPTIONS_HEADER_EXPLOSIVE_ORBS'] = 'Explosive orbs';
L['OPTIONS_EXPLOSIVE_ORBS_CROSSHAIR'] = 'Crosshair';
L['OPTIONS_EXPLOSIVE_ORBS_CROSSHAIR_TOOLTIP'] = 'Show crosshair on explosive orbs';
L['OPTIONS_EXPLOSIVE_ORBS_COUNTER'] = 'Counter';
L['OPTIONS_EXPLOSIVE_ORBS_COUNTER_TOOLTIP'] = 'Show quantity of active explosive orbs';
L['OPTIONS_EXPLOSIVE_ORBS_GLOW'] = 'Pixel glow';
L['OPTIONS_EXPLOSIVE_ORBS_GLOW_TOOLTIP'] = 'Show pixel glow around the health bar';
L['OPTIONS_SPITEFUL_ICON'] = '«The Spiteful Shade» icon';
L['OPTIONS_SPITEFUL_ICON_TOOLTIP'] = 'Show icon above «The Spiteful Shade» nameplate';
L['OPTIONS_MYTHIC_PLUS_AUTO_SLOT_KEYSTONE'] = 'Auto-keystone';
L['OPTIONS_MYTHIC_PLUS_AUTO_SLOT_KEYSTONE_TOOLTIP'] = 'Insert keystones automatically';

L['OPTIONS_QUEST_INDICATOR_ENABLED'] = 'Quest indicator';
L['OPTIONS_QUEST_INDICATOR_ENABLED_TOOLTIP'] = 'Еnable the quest indicator showing how much is left to kill mobs, collect loot etc.';
L['OPTIONS_QUEST_INDICATOR_POSITION'] = 'Position';
L['OPTIONS_QUEST_INDICATOR_POSITION_TOOLTIP'] = 'Position of the quest indicator';
L['OPTIONS_STEALTH_DETECT_ENABLED'] = 'Stealth detection';
L['OPTIONS_STEALTH_DETECT_ENABLED_TOOLTIP'] = 'Enable the stealth detection icon on mobs that can detect you in the stealth state';
L['OPTIONS_STEALTH_DETECT_ALWAYS'] = 'Always';
L['OPTIONS_STEALTH_DETECT_ALWAYS_TOOLTIP'] = 'Always show the stealth detection icon, not just when you are in the appropriate state';
L['OPTIONS_STEALTH_DETECT_NOT_IN_COMBAT'] = 'Not in combat';
L['OPTIONS_STEALTH_DETECT_NOT_IN_COMBAT_TOOLTIP'] = 'Do not show the stealth detection icon in combat';
L['OPTIONS_TOTEM_ICON_ENABLED'] = 'Totem icon';
L['OPTIONS_TOTEM_ICON_ENABLED_TOOLTIP'] = 'Show totem icon over the corresponding nameplate';
L['OPTIONS_TALKING_HEAD_SUPPRESS'] = 'Disable «talking head»';
L['OPTIONS_TALKING_HEAD_SUPPRESS_TOOLTIP'] = 'Disable pop-up «talking head» in dungeons / raids';
L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS'] = 'Always';
L['OPTIONS_TALKING_HEAD_SUPPRESS_ALWAYS_TOOLTIP'] = 'Turn off the «talking head» completely»';
L['OPTIONS_SPELL_INTERRUPTED_ICON_HEADER'] = 'Spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON'] = 'Enable';
L['OPTIONS_SPELL_INTERRUPTED_ICON_TOOLTIP'] = 'Show the spell interrupt icon with a timer when the enemy\'s spell was interrupted';
L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_TEXT'] = 'Countdown';
L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_VALUE'] = 'Countdown font of spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SIZE'] = 'Countdown font size of spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_FLAG'] = 'Countdown font outline of spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_COUNTDOWN_FONT_SHADOW'] = 'Countdown font shadow of spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW'] = 'Show player name';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_SHOW_TOOLTIP'] = 'Show the name of the player who interrupted the spell above interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_VALUE'] = 'Player name font on spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SIZE'] = 'Player name font size on spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_FLAG'] = 'Player name font outline on spell interrupt icon';
L['OPTIONS_SPELL_INTERRUPTED_ICON_CASTER_NAME_FONT_SHADOW'] = 'Player name font shadow on spell interrupt icon';
L['OPTIONS_HEADER_HEALERS_MARKS'] = 'Marks on healers';
L['OPTIONS_PVP_HEALERS_ENABLED'] = 'PvP';
L['OPTIONS_PVP_HEALERS_ENABLED_TOOLTIP'] = 'Show marks on enemy healers in PvP (arena, battlefield)';
L['OPTIONS_PVP_HEALERS_SCALE_TOOLTIP'] = 'Set scale of the marks in PvP';
L['OPTIONS_PVP_HEALERS_SOUND'] = 'Sound';
L['OPTIONS_PVP_HEALERS_SOUND_TOOLTIP'] = 'Play sound when hovering a healer in PvP';
L['OPTIONS_PVE_HEALERS_ENABLED'] = 'PvE';
L['OPTIONS_PVE_HEALERS_ENABLED_TOOLTIP'] = 'Show marks on enemy healers in PvE (dungeon, raid)';
L['OPTIONS_PVE_HEALERS_SCALE_TOOLTIP'] = 'Set scale of the marks in PvE';
L['OPTIONS_PVE_HEALERS_SOUND'] = 'Sound';
L['OPTIONS_PVE_HEALERS_SOUND_TOOLTIP'] = 'Play sound when hovering a healer in PvE';
L['OPTIONS_COMBAT_INDICATOR_HEADER'] = 'Combat indicator';
L['OPTIONS_COMBAT_INDICATOR_ENABLED'] = 'Enable';
L['OPTIONS_COMBAT_INDICATOR_ENABLED_TOOLTIP'] = 'Show the icon depending on whether the visible nameplate is in combat';
L['OPTIONS_COMBAT_INDICATOR_COLOR_TOOLTIP'] = 'Color of combat indicator icon';
L['OPTIONS_COMBAT_INDICATOR_OFFSET_X_TOOLTIP'] = 'Horizontal offset of combat indicator icon';
L['OPTIONS_COMBAT_INDICATOR_OFFSET_Y_TOOLTIP'] = 'Vertical offset of combat indicator icon';
L['OPTIONS_COMBAT_INDICATOR_SIZE_TOOLTIP'] = 'Size of combat indicator icon';

L['OPTIONS_AURAS_TAB_COMMON'] = 'General';
L['OPTIONS_AURAS_TAB_SPELLSTEAL'] = 'Dispelable';
L['OPTIONS_AURAS_TAB_MYTHICPLUS'] = 'Mythic+';
L['OPTIONS_AURAS_TAB_IMPORTANT'] = 'Important';
L['OPTIONS_AURAS_TAB_CUSTOM'] = 'Custom';

L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED'] = 'No filter';
L['OPTIONS_AURAS_FILTER_PLAYER_ENABLED_TOOLTIP'] = 'Show all auras (debuffs) on enemy nameplates';
L['OPTIONS_AURAS_PANDEMIC_ENABLED'] = 'Pandemic';
L['OPTIONS_AURAS_PANDEMIC_ENABLED_TOOLTIP'] = 'Enable coloring of auras countdown when 30% or less of the total spell duration is left';
L['OPTIONS_AURAS_PANDEMIC_COLOR_TOOLTIP'] = 'Color of pandemic timer';
L['OPTIONS_AURAS_BORDER_COLOR_ENABLED'] = 'Border color';
L['OPTIONS_AURAS_BORDER_COLOR_ENABLED_TOOLTIP'] = 'Enable auras border coloring depending of its type';
L['OPTIONS_AURAS_SHOW_DEBUFFS_ON_FRIENDLY'] = 'Show debuffs on friendly nameplates';
L['OPTIONS_AURAS_SORT_ENABLED'] = 'Auras sort';
L['OPTIONS_AURAS_SORT_ENABLED_TOOLTIP'] = 'Enable auras sorting';
L['OPTIONS_AURAS_SORT_TOOLTIP'] = 'Auras sort type';
L['OPTIONS_AURAS_COUNTDOWN_ENABLED'] = 'Show countdown';
L['OPTIONS_AURAS_COUNTDOWN_ENABLED_TOOLTIP'] = 'Show countdown timers on auras';
L['OPTIONS_AURAS_COUNTDOWN_TEXT'] = 'Countdown';
L['OPTIONS_AURAS_COOLDOWN_FONT_VALUE'] = 'Countdown font';
L['OPTIONS_AURAS_COOLDOWN_FONT_SIZE'] = 'Countdown font size';
L['OPTIONS_AURAS_COOLDOWN_FONT_FLAG'] = 'Countdown font outline';
L['OPTIONS_AURAS_COOLDOWN_FONT_SHADOW'] = 'Countdown font shadow';
L['OPTIONS_AURAS_COUNT_TEXT'] = 'Count';
L['OPTIONS_AURAS_COUNT_FONT_VALUE'] = 'Count font';
L['OPTIONS_AURAS_COUNT_FONT_SIZE'] = 'Count font size';
L['OPTIONS_AURAS_COUNT_FONT_FLAG'] = 'Count font outline';
L['OPTIONS_AURAS_COUNT_FONT_SHADOW'] = 'Count font shadow';

L['OPTIONS_AURAS_SPELLSTEAL_ENABLED'] = 'Enable';
L['OPTIONS_AURAS_SPELLSTEAL_ENABLED_TOOLTIP'] = 'Show auras that can be dispelled';
L['OPTIONS_AURAS_SPELLSTEAL_COLOR_TOOLTIP'] = 'Border color of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED'] = 'Show countdown';
L['OPTIONS_AURAS_SPELLSTEAL_COUNTDOWN_ENABLED_TOOLTIP'] = 'Show countdown timers on dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_VALUE'] = 'Countdown font of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SIZE'] = 'Countdown font size of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_FLAG'] = 'Countdown font outline of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COOLDOWN_FONT_SHADOW'] = 'Countdown font shadow of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_VALUE'] = 'Count font of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SIZE'] = 'Count font size of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_FLAG'] = 'Count font outline of dispelable auras';
L['OPTIONS_AURAS_SPELLSTEAL_COUNT_FONT_SHADOW'] = 'Count font shadow of dispelable auras';

L['OPTIONS_AURAS_MYTHICPLUS_ENABLED'] = 'Enable';
L['OPTIONS_AURAS_MYTHICPLUS_ENABLED_TOOLTIP'] = 'Show special auras that will be shown in mythic+ dungeons';
L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED'] = 'Show countdown';
L['OPTIONS_AURAS_MYTHICPLUS_COUNTDOWN_ENABLED_TOOLTIP'] = 'Show countdown timers on mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_VALUE'] = 'Countdown font of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SIZE'] = 'Countdown font size of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_FLAG'] = 'Countdown font outline of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COOLDOWN_FONT_SHADOW'] = 'Countdown font shadow of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_VALUE'] = 'Count font of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SIZE'] = 'Count font size of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_FLAG'] = 'Count font outline of mythic+ auras';
L['OPTIONS_AURAS_MYTHICPLUS_COUNT_FONT_SHADOW'] = 'Count font shadow of mythic+ auras';

L['OPTIONS_AURAS_IMPORTANT_ENABLED'] = 'Enable';
L['OPTIONS_AURAS_IMPORTANT_ENABLED_TOOLTIP'] = 'Show important auras (stuns, crowd control, disorient etc)';
L['OPTIONS_AURAS_IMPORTANT_SCALE'] = 'Scale';
L['OPTIONS_AURAS_IMPORTANT_SCALE_TOOLTIP'] = 'Scale of important auras';
L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED'] = 'Show countdown';
L['OPTIONS_AURAS_IMPORTANT_COUNTDOWN_ENABLED_TOOLTIP'] = 'Show countdown timers on important auras';
L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_VALUE'] = 'Countdown font of important auras';
L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SIZE'] = 'Countdown font size of important auras';
L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_FLAG'] = 'Countdown font outline of important auras';
L['OPTIONS_AURAS_IMPORTANT_COOLDOWN_FONT_SHADOW'] = 'Countdown font shadow of important auras';
L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_VALUE'] = 'Count font of important auras';
L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SIZE'] = 'Count font size of important auras';
L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_FLAG'] = 'Count font outline of important auras';
L['OPTIONS_AURAS_IMPORTANT_COUNT_FONT_SHADOW'] = 'Count font shadow of important auras';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_SHOW'] = 'Show player name';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_SHOW_TOOLTIP'] = 'Show player name above important aura';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_VALUE'] = 'Player name font on important auras';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SIZE'] = 'Player name font size on important auras';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_FLAG'] = 'Player name font outline on important auras';
L['OPTIONS_AURAS_IMPORTANT_CASTERNAME_FONT_SHADOW'] = 'Player name font shadow on important auras';

L['OPTIONS_AURAS_CUSTOM_ENABLED'] = 'Enable';
L['OPTIONS_AURAS_CUSTOM_ENABLED_TOOLTIP'] = 'Show custom auras';
L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED'] = 'Show countdown';
L['OPTIONS_AURAS_CUSTOM_COUNTDOWN_ENABLED_TOOLTIP'] = 'Show countdown timers on custom auras';
L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_VALUE'] = 'Countdown font of custom auras';
L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SIZE'] = 'Countdown font size of custom auras';
L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_FLAG'] = 'Countdown font outline of custom auras';
L['OPTIONS_AURAS_CUSTOM_COOLDOWN_FONT_SHADOW'] = 'Countdown font shadow of custom auras';
L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_VALUE'] = 'Count font of custom auras';
L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SIZE'] = 'Count font size of custom auras';
L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_FLAG'] = 'Count font outline of custom auras';
L['OPTIONS_AURAS_CUSTOM_COUNT_FONT_SHADOW'] = 'Count font shadow of custom auras';
L['OPTIONS_AURAS_CUSTOM_EDITBOX_ENTER_ID'] = 'Enter the name or ID of the aura';
L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HARMFUL'] = 'Switch to debuff (HARMFUL)';
L['OPTIONS_AURAS_CUSTOM_SWITCH_TO_HELPFUL'] = 'Switch to buff (HELPFUL)';
L['OPTIONS_AURAS_CUSTOM_COPY_FROM_PROFILE'] = 'Copy from profile';
L['OPTIONS_AURAS_CUSTOM_COPY_FROM_PROFILE_SHIFT'] = 'Replace from profile';
L['OPTIONS_AURAS_CUSTOM_HELPFUL'] = 'buff (HELPFUL)';
L['OPTIONS_AURAS_CUSTOM_HELPFUL_TOOLTIP'] = 'Add an aura as buff (HELPFUL)';
L['OPTIONS_AURAS_CUSTOM_BORDER_COLOR_TOOLTIP'] = 'Border color of custom auras';

L['OPTIONS_CUSTOM_COLOR_ENABLED'] = 'Enable';
L['OPTIONS_CUSTOM_COLOR_ENABLED_TOOLTIP'] = 'Enable custom health bar colors';
L['OPTIONS_CUSTOM_COLOR_EDITBOX_ENTER_ID'] = 'Enter the ID of the NPC';
L['OPTIONS_CUSTOM_COLOR_ADD_FROM_TARGET'] = 'From target';
L['OPTIONS_CUSTOM_COLOR_ADD_FROM_LIST'] = 'From list';
L['OPTIONS_CUSTOM_COLOR_COPY_FROM_PROFILE'] = 'Copy from profile';
L['OPTIONS_CUSTOM_COLOR_COPY_FROM_PROFILE_SHIFT'] = 'Replace from profile';