local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('TalkingHead');

local function CloseTalkingHead()
    local shouldClose = TalkingHeadFrame and (O.db.talking_head_suppress and D.Player.State.inInstance) or (O.db.talking_head_suppress and O.db.talking_head_suppress_always);

    if shouldClose then
        TalkingHeadFrame:CloseImmediately();
    end
end

function Module:StartUp()
    self:RegisterEvent('TALKINGHEAD_REQUESTED', CloseTalkingHead);
end