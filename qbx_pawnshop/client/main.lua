local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@alias PawnItem {item: string, price: number}
---@alias MeltingItem {item: string, rewards: {item: string, amount: number}[], meltTime: number}
local isMelting = false ---@type boolean
local canTake = false ---@type boolean
local meltTimeSeconds = 0 ---@type number

---@param id number
---@param shopConfig {coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number}
local function addPawnShop(id, shopConfig)
    if not config.useTarget then
        lib.zones.box({
            name = 'PawnShop' .. id,
            coords = shopConfig.coords,
            size = shopConfig.size,
            rotation = shopConfig.heading,
            debug = shopConfig.debugPoly,
            onEnter = function()
                lib.registerContext({
                    id = 'open_pawnShopMain',
                    title = locale('info.title'),
                    options = {
                        {
                            title = locale('info.open_pawn'),
                            event = 'qb-pawnshop:client:openMenu'
                        }
                    }
                })
                lib.showContext('open_pawnShopMain')
            end,
            onExit = function()
                lib.hideContext(false)
            end
        })
        return
    end

    exports.ox_target:addBoxZone({
        coords = shopConfig.coords,
        size = shopConfig.size,
        rotation = shopConfig.heading,
        debug = shopConfig.debugPoly,
        options = {
            {
                name = 'PawnShop' .. id,
                event = 'qb-pawnshop:client:openMenu',
                icon = 'fas fa-ring',
                label = 'PawnShop ' .. id,
                distance = shopConfig.distance
            }
        }
    })
end

CreateThread(function()
    for i = 1, #sharedConfig.pawnLocation do
        local shopConfig = sharedConfig.pawnLocation[i]
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('info.title'))
        EndTextCommandSetBlipName(blip)

        addPawnShop(i, shopConfig)
    end
end)

RegisterNetEvent('qb-pawnshop:client:openMenu', function()
    if not config.useTimes then
        local pawnShop = {
            {
                title = locale('info.sell'),
                description = locale('info.sell_pawn'),
                event = 'qb-pawnshop:client:openPawn',
                args = {
                    pawnItems = sharedConfig.pawnItems
                }
            }
        }
        if not isMelting then
            pawnShop[#pawnShop + 1] = {
                title = locale('info.melt'),
                description = locale('info.melt_pawn'),
                event = 'qb-pawnshop:client:openMelt',
                args = {
                    meltingItems = sharedConfig.meltingItems
                }
            }
        end
        if canTake then
            pawnShop[#pawnShop + 1] = {
                title = locale('info.melt_pickup'),
                serverEvent = 'qb-pawnshop:server:pickupMelted',
            }
        end
        lib.registerContext({
            id = 'open_pawnShop',
            title = locale('info.title'),
            options = pawnShop
        })
        lib.showContext('open_pawnShop')
        return
    end

    local gameHour = GetClockHours()
    if gameHour < config.timeOpen or gameHour > config.timeClosed then
        exports.qbx_core:Notify(locale('info.pawn_closed', config.timeOpen, config.timeClosed))
        return
    end

    local pawnShop = {
        {
            title = locale('info.sell'),
            description = locale('info.sell_pawn'),
            event = 'qb-pawnshop:client:openPawn',
            args = {
                pawnItems = sharedConfig.pawnItems
            }
        }
    }
    if not isMelting then
        pawnShop[#pawnShop + 1] = {
            title = locale('info.melt'),
            description = locale('info.melt_pawn'),
            event = 'qb-pawnshop:client:openMelt',
            args = {
                meltingItems = sharedConfig.meltingItems
            }
        }
    end
    if canTake then
        pawnShop[#pawnShop + 1] = {
            title = locale('info.melt_pickup'),
            serverEvent = 'qb-pawnshop:server:pickupMelted',
        }
    end
    lib.registerContext({
        id = 'open_pawnShop',
        title = locale('info.title'),
        options = pawnShop
    })
    lib.showContext('open_pawnShop')
end)

---@param pMeltTimeSeconds number
RegisterNetEvent('qb-pawnshop:client:startMelting', function(pMeltTimeSeconds)
    if isMelting then
        return
    end

    isMelting = true
    meltTimeSeconds = pMeltTimeSeconds
    CreateThread(function()
        while isMelting and LocalPlayer.state.isLoggedIn and meltTimeSeconds > 0 do
            meltTimeSeconds = meltTimeSeconds - 1
            Wait(1000)
        end

        canTake = true
        isMelting = false

        if not config.sendMeltingEmail then
            exports.qbx_core:Notify(locale('info.message'), 'success')
            return
        end

        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = locale('info.title'),
            subject = locale('info.subject'),
            message = locale('info.message'),
            button = {}
        })
    end)
end)

RegisterNetEvent('qb-pawnshop:client:resetPickup', function()
    canTake = false
end)

---@param data {meltingItems: MeltingItem[]}
RegisterNetEvent('qb-pawnshop:client:openMelt', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local meltMenu = {}

    for _, invItem in pairs(inventory) do
        for i = 1, #data.meltingItems do
            if invItem.name == data.meltingItems[i].item then
                meltMenu[#meltMenu + 1] = {
                    title = invItem.label,
                    description = locale('info.melt_item', invItem.label),
                    event = 'qb-pawnshop:client:meltItems',
                    args = {
                        name = invItem.name,
                        amount = invItem.count,
                    }
                }
            end
        end
    end
    lib.registerContext({
        id = 'open_meltMenu',
        menu = 'open_pawnShop',
        title = locale('info.title'),
        options = meltMenu
    })
    lib.showContext('open_meltMenu')
end)

---@param item {name: string, amount: number}
RegisterNetEvent('qb-pawnshop:client:pawnitems', function(item)
    local input = lib.inputDialog(locale('info.title'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount)
        }
    })
    if not input then
        exports.qbx_core:Notify(locale('error.negative'), 'error')
        return
    end

    if not input[1] or input[1] <= 0 then return end
    TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, input[1])
end)

---@param item {name: string, amount: number}
RegisterNetEvent('qb-pawnshop:client:meltItems', function(item)
    local input = lib.inputDialog(locale('info.melt'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount)
        }
    })
    if not input then
        exports.qbx_core:Notify(locale('error.no_melt'), 'error')
        return
    end
    if not input[1] or input[1] <= 0 then return end

    TriggerServerEvent('qb-pawnshop:server:meltItemRemove', item.name, input[1])
end)

---@param data {pawnItems: PawnItem[]}
RegisterNetEvent('qb-pawnshop:client:openPawn', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local pawnMenu = {}

    for _, invItem in pairs(inventory) do
        for i = 1, #data.pawnItems do
            if invItem.name == data.pawnItems[i].item then
                pawnMenu[#pawnMenu + 1] = {
                    title = invItem.label,
                    description = locale('info.sell_items', data.pawnItems[i].price),
                    event = 'qb-pawnshop:client:pawnitems',
                    args = {
                        name = invItem.name,
                        amount = invItem.amount
                    }
                }
            end
        end
    end
    lib.registerContext({
        id = 'open_pawnMenu',
        menu = 'open_pawnShop',
        title = locale('info.title'),
        options = pawnMenu
    })
    lib.showContext('open_pawnMenu')
end)