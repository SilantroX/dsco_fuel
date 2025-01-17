if Config.framework == "ESX" then
    FRWORK = exports["es_extended"]:getSharedObject()
elseif Config.framework == "QB" then
    FRWORK = exports["qb-core"]:GetCoreObject()

    FRWORK.Functions.CreateUseableItem(
        "jerry_can",
        function(source)
            local src = source
            TriggerClientEvent("dsco_fuel:client:UseJerrycan", src)
        end
    )
end

RegisterNetEvent(
    "dsco_fuel:pay",
    function(amount)
        local moneyType = Config.moneytype
        if Config.framework == "ESX" then
            local xPlayer = FRWORK.GetPlayerFromId(source)

            if xPlayer then
                if moneyType == "bank" then
                    xPlayer.removeAccountMoney("bank", math.floor(amount))
                elseif moneyType == "money" then
                    xPlayer.removeMoney(math.floor(amount))
                else
                    print("Error in money account")
                end

                xPlayer.showNotification(Lang.Pay .. string.format("%.2f", amount))
            end
        elseif Config.framework == "QB" then
            local Player = FRWORK.Functions.GetPlayer(source) -- Obtén al jugador actual

            if Player then
                if moneyType == "bank" then
                    Player.Functions.RemoveMoney("bank", math.floor(amount))
                elseif moneyType == "money" then
                    Player.Functions.RemoveMoney("cash", math.floor(amount))
                else
                    print("Error en el tipo de dinero")
                end

                TriggerEvent('QBCore:Notify', source, Lang.Pay .. string.format("%.2f", amount))
            end
        end
    end
)

RegisterNetEvent(
    "dsco_fuel:jerryCan",
    function(amount)
        if Config.framework == "ESX" then
            local xPlayer = FRWORK.GetPlayerFromId(source)

            if xPlayer then
                xPlayer.removeMoney(amount)
                xPlayer.addInventoryItem("jerry_can", 1)
                xPlayer.showNotification(Lang.Pay .. amount)
            end
        elseif Config.framework == "QB" then
            local Player = FRWORK.Functions.GetPlayer(source)
            if Player then
                Player.Functions.AddItem("jerry_can", 1)
                Player.Functions.RemoveMoney("cash", amount)
                TriggerEvent('QBCore:Notify', source, Lang.Pay .. amount)
            end
        end
    end
)

RegisterNetEvent(
    "dsco_fuel:removeJerryCan",
    function()
        if Config.framework == "QB" then
            local xPlayer = FRWORK.Functions.GetPlayer(source)
            if xPlayer then
                xPlayer.Functions.RemoveItem("jerry_can", 1)
                TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items["jerry_can"], "remove")
            end
        end
        if Config.framework == "ESX" then
            local xPlayer = FRWORK.GetPlayerFromId(source)
            if xPlayer then
                xPlayer.removeInventoryItem("jerry_can", 1)
            end
        end
    end
)

RegisterServerEvent("dsco_fuel:JerryCanprop")
AddEventHandler(
    "dsco_fuel:JerryCanprop",
    function(type)
        local src = source
        if type == "add" then
            GiveWeaponToPed(src, "weapon_petrolcan", 5, true, true)
        elseif type == "remove" then
            GiveWeaponToPed(src, "weapon_unarmed", 0, true, true)
        end
    end
)
