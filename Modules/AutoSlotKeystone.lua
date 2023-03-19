local S, L, O, U, D, E = unpack((select(2, ...)));
local Module = S:NewModule('AutoSlotKeystone');

function Module:Slot()
    if not O.db.mythic_plus_auto_slot_keystone then
        return;
    end

    if C_ChallengeMode.HasSlottedKeystone() then
        return;
    end

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(container);

        for slot = 1, slots do
            local itemInfo = C_Container.GetContainerItemInfo(container, slot);
            if itemInfo and itemInfo.hyperlink and string.match(itemInfo.hyperlink, '|Hkeystone:') then
                C_Container.PickupContainerItem(container, slot);

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