local config = require 'config.server'
local sharedConfig = require 'config.shared'
local playersMelting = {} ---@type table<number, {itemName: string, amount: number, endTime: number}>

---@param id string
---@param reason string
local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            GetPlayerIdentifierByType(id, 'license'),
            GetPlayerIdentifierByType(id, 'discord'),
            GetPlayerIdentifierByType(id, 'ip'),
            reason,
            2147483647,
            'qb-pawnshop'
        }
    )
    TriggerEvent('qb-log:server:CreateLog', 'pawnshop', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(id), 'qb-pawnshop', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

---@param src number
---@return boolean
local function isPlayerAtPawnShop(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))

    for i = 1, #sharedConfig.pawnLocation do
        local value = sharedConfig.pawnLocation[i]

        if #(playerCoords - value.coords) <= 5 then
            return true
        end
    end

    return false
end

---@param itemName string
---@return PawnItem?
local function getPawnShopItemFromName(itemName)
    for i = 1, #sharedConfig.pawnItems do
        local pawnItem = sharedConfig.pawnItems[i]
        if itemName == pawnItem.item then
            return pawnItem
        end
    end
end

---@param itemName string
---@return MeltingItem?
local function getMeltingItemFromName(itemName)
    for i = 1, #sharedConfig.meltingItems do
        local meltingItem = sharedConfig.meltingItems[i]
        if itemName == meltingItem.item then
            return meltingItem
        end
    end
end

---@param itemName string
---@param itemAmount number
RegisterNetEvent('qb-pawnshop:server:sellPawnItems', function(itemName, itemAmount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if not isPlayerAtPawnShop(src) then
        exploitBan(src, 'sellPawnItems Exploiting')
        return
    end

    local pawnItem = getPawnShopItemFromName(itemName)
    if not pawnItem then
        exploitBan(src, 'sellPawnItems Exploiting')
        return
    end

    local totalPrice = (itemAmount * pawnItem.price)
    if Player.Functions.RemoveItem(itemName, itemAmount) then
        Player.Functions.AddMoney(config.bankMoney and 'bank' or 'cash', totalPrice)
        exports.qbx_core:Notify(src,
            locale('success.sold', itemAmount, exports.ox_inventory:Items()[itemName].label, totalPrice), 'success')
        TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[itemName], 'remove')
    else
        exports.qbx_core:Notify(src, locale('error.no_items'), 'error')
    end
    TriggerClientEvent('qb-pawnshop:client:openMenu', src)
end)

---@param itemName string
---@param itemAmount number
RegisterNetEvent('qb-pawnshop:server:meltItemRemove', function(itemName, itemAmount)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if playersMelting[src] then
        return
    end

    local meltingItem = getMeltingItemFromName(itemName)
    if not meltingItem then
        exploitBan(src, 'meltItemRemove Exploiting')
        return
    end

    if not Player.Functions.RemoveItem(itemName, itemAmount) then
        exports.qbx_core:Notify(src, locale('error.no_items'), 'error')
        return
    end

    TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[itemName], 'remove')
    local meltTime = (itemAmount * meltingItem.meltTime)
    playersMelting[src] = { itemName = itemName, amount = itemAmount, endTime = os.time() + (meltTime * 60) }

    TriggerClientEvent('qb-pawnshop:client:startMelting', src, (meltTime * 60000 / 1000))
    exports.qbx_core:Notify(src, locale('info.melt_wait', meltTime), 'primary')
end)

RegisterNetEvent('qb-pawnshop:server:pickupMelted', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if not isPlayerAtPawnShop(src) then
        exploitBan(src, 'pickupMelted Exploiting')
        return
    end

    local meltingItem = getMeltingItemFromName(playersMelting[src].itemName)
    if not meltingItem then
        exploitBan(src, 'pickupMelted Exploiting')
        return
    end


    if not playersMelting[src] or playersMelting[src].endTime > os.time() then
        exploitBan(src, 'pickupMelted Exploiting')
        return
    end

    local meltedAmount = playersMelting[src].amount
    playersMelting[src] = nil

    for i = 1, #meltingItem.rewards do
        local reward = meltingItem.rewards[i]

        local rewardAmount = reward.amount
        if not Player.Functions.AddItem(reward.item, (meltedAmount * rewardAmount)) then
            TriggerClientEvent('qb-pawnshop:client:openMenu', src)
            return
        end

        TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[reward.item], 'add')
        exports.qbx_core:Notify(src, locale('success.items_received', (meltedAmount * rewardAmount), exports.ox_inventory:Items()[reward.item].label), 'success')
    end
    TriggerClientEvent('qb-pawnshop:client:resetPickup', src)
    TriggerClientEvent('qb-pawnshop:client:openMenu', src)
end)