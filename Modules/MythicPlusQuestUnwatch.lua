local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('MythicPlus_QuestUnwatch');

-- Lua API
local ipairs, table_insert = ipairs, table.insert;

local function Watch()
    local watchedQuests = type(O.db.mythic_plus_questunwatch_data) == 'table' and #O.db.mythic_plus_questunwatch_data or 0;

    if watchedQuests == 0 then
        return;
    end

    for _, questId in ipairs(O.db.mythic_plus_questunwatch_data) do
        C_QuestLog.AddQuestWatch(questId, C_QuestLog.GetQuestWatchType(questId) or 1);
    end

    wipe(O.db.mythic_plus_questunwatch_data);
end

local function Unwatch()
    wipe(O.db.mythic_plus_questunwatch_data);

    local questId, questLogIndex, questInfo;

    for questWatchIndex = C_QuestLog.GetNumQuestWatches(), 1, -1 do
        questId = C_QuestLog.GetQuestIDForQuestWatchIndex(questWatchIndex);

        if questId then
            questLogIndex = C_QuestLog.GetLogIndexForQuestID(questId);

            if questLogIndex then
                questInfo = C_QuestLog.GetInfo(questLogIndex);

                if questInfo and not questInfo.isHidden and not questInfo.isHeader then
                    C_QuestLog.RemoveQuestWatch(questId);
                    table_insert(O.db.mythic_plus_questunwatch_data, questId);
                end
            end
        end
    end
end

function Module:UpdateLocalConfig()
    if O.db.mythic_plus_questunwatch_enabled then
        self:RegisterEvent('PLAYER_ENTERING_WORLD', Watch);
        self:RegisterEvent('CHALLENGE_MODE_START', Unwatch);
        self:RegisterEvent('CHALLENGE_MODE_COMPLETED', Watch);
        self:RegisterEvent('CHALLENGE_MODE_RESET', Watch);
    else
        self:UnregisterEvent('PLAYER_ENTERING_WORLD');
        self:UnregisterEvent('CHALLENGE_MODE_START');
        self:UnregisterEvent('CHALLENGE_MODE_COMPLETED');
        self:UnregisterEvent('CHALLENGE_MODE_RESET');
    end
end

function Module:StartUp()
    self:UpdateLocalConfig();
end