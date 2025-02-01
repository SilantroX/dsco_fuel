RegisterNUICallback(
    "exit",
    function(data, cb)
        SendNUIMessage(
            {
                type = "close"
            }
        )
        SetNuiFocus(false, false)
        cb("ok")
    end
)

RegisterNUICallback(
    "jerrycan",
    function(data, cb)
        SendNUIMessage(
            {
                type = "close"
            }
        )
        if Config.framework == "ESX" then
            TriggerServerEvent("dsco_fuel:jerryCan", Config.jerryCanPrice)
        elseif Config.framework == "QB" then
            local Player = FRWORK.Functions.GetPlayerData() -- Obtén los datos del jugador actual
            print("Melo")
            TriggerServerEvent("dsco_fuel:jerryCan", Config.jerryCanPrice)
        end
        SetNuiFocus(false, false)
        cb("ok")
    end
)

RegisterNUICallback(
    "fuel",
    function(data, cb)
        SendNUIMessage(
            {
                type = "close"
            }
        )
        
        GrabNozzleFromPump()
        SetNuiFocus(false, false)
        cb("ok")
        if Config.framework == "ESX" then
            FRWORK.TriggerServerCallback('dsco_fuel:getMoney', function(data)
                SetPlayerMoneyESX(data)
            end)
        end
    end
)
