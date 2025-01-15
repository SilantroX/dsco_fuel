RegisterNUICallback('exit', function(data, cb)
    SendNUIMessage({
        type = "close"
    })
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('jerrycan', function(data, cb)
    SendNUIMessage({
        type = "close"
    })
    if config.framework == "ESX" then
        TriggerServerEvent("dsco_fuel:jerryCan", config.jerryCanPrice)
        if HasPedGotWeapon(ped, 883325847) then
            SetPedAmmo(ped, 883325847, 4500)
        else
            GiveWeaponToPed(ped, 883325847, 4500, false, true)
            SetPedAmmo(ped, 883325847, 4500)
        end
    
    elseif config.framework == "QB" then
        local Player = FRWORK.Functions.GetPlayerData() -- Obtén los datos del jugador actual

        if Player.money.cash < config.jerryCanPrice then
            TriggerServerEvent("dsco_fuel:jerryCan", config.jerryCanPrice)

            local ped = GetPlayerPed(-1)

            if HasPedGotWeapon(ped, GetHashKey("WEAPON_PETROLCAN")) then
                SetPedAmmo(ped, GetHashKey("WEAPON_PETROLCAN"), 4500)
            else
                GiveWeaponToPed(ped, GetHashKey("WEAPON_PETROLCAN"), 4500, false, true)
            end
        end    
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('fuel', function(data, cb)
    SendNUIMessage({
        type = "close"
    })
    GrabNozzleFromPump()
    SetNuiFocus(false, false)
    cb('ok')
end)