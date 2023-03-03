local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('TalkingHead');

local PlayerState = D.Player.State;

function Module:TALKINGHEAD_REQUESTED()
    if not (TalkingHeadFrame and O.db.talking_head_suppress) then
        return;
    end

    if O.db.talking_head_suppress_always then
        TalkingHeadFrame:CloseImmediately();
        return;
    end

    if not PlayerState.inInstance then
        return;
    end

    TalkingHeadFrame:CloseImmediately();
end

function Module:StartUp()
    self:RegisterEvent('TALKINGHEAD_REQUESTED');
end