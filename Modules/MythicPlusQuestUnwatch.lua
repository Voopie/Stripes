local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('MythicPlus_QuestUnwatch');

-- Lua API
local ipairs, table_insert = ipairs, table.insert;

function Module:Watch()
    local watchedQuests = #O.db.mythic_plus_questunwatch_data;

    if not watchedQuests or watchedQuests == 0 then
        return;
    end

    for _, questId in ipairs(O.db.mythic_plus_questunwatch_data) do
        C_QuestLog.AddQuestWatch(questId, C_QuestLog.GetQuestWatchType(questId) or 1);
    end

    wipe(O.db.mythic_plus_questunwatch_data);
end

function Module:Unwatch()
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

function Module:PLAYER_ENTERING_WORLD()
    if O.db.mythic_plus_questunwatch_enabled then
        self:Watch();
    end
end

function Module:CHALLENGE_MODE_START()
    if O.db.mythic_plus_questunwatch_enabled then
        self:Unwatch();
    end
end

function Module:CHALLENGE_MODE_COMPLETED()
    if O.db.mythic_plus_questunwatch_enabled then
        self:Watch();
    end
end

function Module:CHALLENGE_MODE_RESET()
    if O.db.mythic_plus_questunwatch_enabled then
        self:Watch();
    end
end

function Module:StartUp()
    self:RegisterEvent('PLAYER_ENTERING_WORLD');
    self:RegisterEvent('CHALLENGE_MODE_START');
    self:RegisterEvent('CHALLENGE_MODE_COMPLETED');
    self:RegisterEvent('CHALLENGE_MODE_RESET');
end