local S, L, O, U, D, E = unpack(select(2, ...));
local Module = S:NewModule('AutoSlotKeystone');

local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots;
local GetContainerItemInfo = GetContainerItemInfo or C_Container.GetContainerNumSlots;
local PickupContainerItem  = PickupContainerItem  or C_Container.PickupContainerItem;

function Module:Slot()
    if not O.db.mythic_plus_auto_slot_keystone then
        return;
    end

    if C_ChallengeMode.HasSlottedKeystone() then
        return;
    end

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = GetContainerNumSlots(container);

        for slot = 1, slots do
            local slotLink = select(7, GetContainerItemInfo(container, slot));

            if slotLink and string.match(slotLink, '|Hkeystone:') then
                PickupContainerItem(container, slot);

                if CursorHasItem() then
                    C_ChallengeMode.SlotKeystone();

                    if C_ChallengeMode.HasSlottedKeystone() then
                        return;
                    end
                end
            end
        end
    end
end

function Module:Blizzard_ChallengesUI()
    ChallengesKeystoneFrame:HookScript('OnShow', self.Slot);
end

function Module:StartUp()
    self:RegisterAddon('Blizzard_ChallengesUI');
end