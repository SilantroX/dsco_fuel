ped = nil
pedCoords = nil
pump = nil
pumpHandle = nil
veh = nil
NozzleBasedOnClass = {
    0.65, -- Compacts
    0.65, -- Sedans
    0.85, -- SUVs
    0.6, -- Coupes
    0.55, -- Muscle
    0.6, -- Sports Classics
    0.6, -- Sports
    0.55, -- Super
    0.12, -- Motorcycles
    0.8, -- Off-road
    0.7, -- Industrial
    0.6, -- Utility
    0.7, -- Vans
    0.0, -- Cycles
    0.0, -- Boats
    0.0, -- Helicopters
    0.0, -- Planes
    0.6, -- Service
    0.65, -- Emergency
    0.65, -- Military
    0.75, -- Commercial
    0.0 -- Trains
}

local playermoeny = 0
function SetPlayerMoneyESX(data)
    playermoeny = data
end

CreateThread(
    function()
        while true do
            ped = PlayerPedId()
            pedCoords = GetEntityCoords(ped)
            pump, pumpHandle = NearPump(pedCoords)
            veh = GetVehiclePedIsIn(ped, true)
            Wait(500)
        end
    end
)

-- Refuel the vehicle.
CreateThread(
    function()
        while true do
            Wait(2000)
            if VehicleFueling then
                local classMultiplier = Config.vehicleClasses[GetVehicleClass(VehicleFueling)]
                local cost = 0
                while VehicleFueling do
                    local fuel = GetFuel(VehicleFueling)
                    if not DoesEntityExist(VehicleFueling) then
                        DropNozzle()
                        break
                    end
                    fuel = GetFuel(VehicleFueling)
                    cost = cost + ((2.0 / classMultiplier) * Config.fuelCostMultiplier) - math.random(0, 100) / 100
                    if Config.framework == "ESX" then
                        local xPlayer = FRWORK.GetPlayerData() -- Obtén el jugador actual

                        if playermoeny < cost then
                            SendNUIMessage(
                                {
                                    type = "warn"
                                }
                            )
                            VehicleFueling = false
                            break
                        end
                    elseif Config.framework == "QB" then
                        local Player = FRWORK.Functions.GetPlayerData() -- Obtén los datos del jugador actual

                        if Player.money.cash < cost then
                            SendNUIMessage(
                                {
                                    type = "warn"
                                }
                            )
                            VehicleFueling = false
                            break
                        end
                    end
                    if fuel < 80 then
                        SetFuel(VehicleFueling, fuel + math.random(30,40) / 2)
                    else
                        fuel = 100
                        SetFuel(VehicleFueling, fuel)
                        VehicleFueling = false
                    end
                    SendNUIMessage(
                        {
                            type = "update",
                            fuelCost = string.format("%.2f", cost),
                            fuelTank = string.format("%.2f", fuel)
                        }
                    )
                    Wait(600)
                end
                if cost ~= 0 then
                    TriggerServerEvent("dsco_fuel:pay", cost)
                    cost = 0
                end
            end
        end
    end
)

CreateThread(
    function()
        while true do
            Wait(500)
            if WastingFuel then
                local gettermoney = false
                local playermoeny = 0
                if Config.framework == "ESX" then
                    FRWORK.TriggerServerCallback('dsco_fuel:getMoney', function(data)
                        gettermoney = true
                        playermoeny = data
                    end)
                else
                    gettermoney = true
                end
                while not gettermoney do
                    Citizen.Wait(5)
                end
                local cost = 0
                while WastingFuel do
                    cost = cost + (2.0 * Config.fuelCostMultiplier) - math.random(0, 100) / 100
                    SendNUIMessage(
                        {
                            type = "update",
                            fuelCost = string.format("%.2f", cost),
                            fuelTank = "0.0"
                        }
                    )
                    if Config.framework == "ESX" then
                        local xPlayer = FRWORK.GetPlayerData()
                        if playermoeny < cost then
                            SendNUIMessage(
                                {
                                    type = "warn"
                                }
                            )
                        end
                    elseif Config.framework == "QB" then
                        local Player = FRWORK.Functions.GetPlayerData()
                        if Player.money.cash < cost then
                            SendNUIMessage(
                                {
                                    type = "warn"
                                }
                            )
                        end
                    end
                    Wait(800)
                end
                if cost ~= 0 then
                    TriggerServerEvent("dsco_fuel:pay", cost)
                end
            end
        end
    end
)

CreateThread(
    function()
        local wait = 500
        while true do
            Wait(wait)
            if pump then
                wait = 0
                if not HoldingNozzle and not NozzleInVehicle and not NozzleDropped then
                    DrawText3D(pump.x, pump.y, pump.z + 1.2, Lang.PressE)
                    if IsControlJustPressed(0, 38) then
                        SendNUIMessage(
                            {
                                type = "mainMenu"
                            }
                        )
                        SetNuiFocus(true, true)
                        Wait(1000)
                        ClearPedTasks(ped)
                    end
                elseif HoldingNozzle and not NearTank and pumpHandle == UsedPump then
                    DrawText3D(pump.x, pump.y, pump.z + 1.2, Lang.ReturnPump)
                    if IsControlJustPressed(0, 51) then
                        LoadAnimDict("anim@am_hold_up@male")
                        TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                        Wait(300)
                        ReturnNozzleToPump()
                        Wait(1000)
                        ClearPedTasks(ped)
                    end
                end
            else
                wait = 500
            end
        end
    end
)

CreateThread(
    function()
        local wait = 500
        while true do
            Wait(wait)
            if HoldingNozzle or NozzleInVehicle or NozzleDropped then
                wait = 0

                -- drop the Nozzle and remove it if it's far away from the pump.
                if pump then
                    pumpCoords = GetEntityCoords(UsedPump)
                end
                if Nozzle and pumpCoords then
                    nozzleLocation = GetEntityCoords(Nozzle)
                    if #(pumpCoords - pedCoords) < 3.0 then
                        SendNUIMessage(
                            {
                                type = "status",
                                status = true
                            }
                        )
                    else
                        SendNUIMessage(
                            {
                                type = "status",
                                status = false
                            }
                        )
                    end
                    if #(nozzleLocation - pumpCoords) > 6.0 then
                        DropNozzle()
                    elseif #(pumpCoords - pedCoords) > 100.0 then
                        ReturnNozzleToPump()
                    end
                    if NozzleDropped and #(nozzleLocation - pedCoords) < 1.5 then
                        DrawText3D(nozzleLocation.x, nozzleLocation.y, nozzleLocation.z, Lang.PickUpPump)
                        if IsControlJustPressed(0, 51) then
                            LoadAnimDict("anim@mp_snowball")
                            TaskPlayAnim(ped, "anim@mp_snowball", "pickup_snowball", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                            Wait(700)
                            GrabExistingNozzle()
                            ClearPedTasks(ped)
                        end
                    end
                end

                local veh = VehicleInFront()

                -- Animations for manually fueling and effect for sparying fuel.
                if HoldingNozzle and Nozzle then
                    DisableControlAction(0, 25, true)
                    DisableControlAction(0, 24, true)
                    if IsDisabledControlPressed(0, 24) then
                        if veh and tankPosition and #(pedCoords - tankPosition) < 1.2 then
                            if not IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                                LoadAnimDict("timetable@gardener@filling_can")
                                TaskPlayAnim(
                                    ped,
                                    "timetable@gardener@filling_can",
                                    "gar_ig_5_filling_can",
                                    2.0,
                                    8.0,
                                    -1,
                                    50,
                                    0,
                                    0,
                                    0,
                                    0
                                )
                            end
                            WastingFuel = false
                            VehicleFueling = veh
                        else
                            if IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                                VehicleFueling = false
                                ClearPedTasks(ped)
                            end
                            if nozzleLocation then
                                WastingFuel = true
                                PlayEffect("core", "veh_trailer_petrol_spray")
                            end
                        end
                    else
                        if IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
                            VehicleFueling = false
                            ClearPedTasks(ped)
                        end
                        WastingFuel = false
                    end
                end

                -- attaching and taking the Nozzle from the vehicle.
                if veh then
                    local vehClass = GetVehicleClass(veh)
                    local zPos = NozzleBasedOnClass[vehClass + 1]
                    local isBike = false
                    local nozzleModifiedPosition = {
                        x = 0.0,
                        y = 0.0,
                        z = 0.0
                    }
                    local textModifiedPosition = {
                        x = 0.0,
                        y = 0.0,
                        z = 0.0
                    }
                    local tankPosition = nil
                    local TankBone = nil

                    if vehClass == 8 and vehClass ~= 13 and not Config.electricVehicles[GetHashKey(veh)] then
                        TankBone = GetEntityBoneIndexByName(veh, "petrolcap")
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "petroltank")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "fuel")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "seat_r")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "engine")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "misc_a")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "misc_b")
                        end
                        isBike = true
                    elseif vehClass ~= 13 and not Config.electricVehicles[GetHashKey(veh)] then
                        TankBone = GetEntityBoneIndexByName(veh, "petrolcap")
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "petroltank_l")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "petroltank_r")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "hub_lr")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "handle_dside_r")
                        end
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "chassis")
                        end
                        
                        if TankBone == -1 then
                            TankBone = GetEntityBoneIndexByName(veh, "bodyshell")
                            nozzleModifiedPosition = {x = -0.3, y = -0.5, z = -0.6}
                            textModifiedPosition = {x = 0.5, y = 0.2, z = -0.2}
                        else
                            if TankBone == GetEntityBoneIndexByName(veh, "handle_dside_r") then
                                nozzleModifiedPosition = {x = 0.1, y = -0.5, z = -0.6}
                                textModifiedPosition = {x = 0.55, y = 0.1, z = -0.2}
                            end
                        end
                    end
                    tankPosition = GetWorldPositionOfEntityBone(veh, TankBone)
                    if tankPosition and #(pedCoords - tankPosition) < 2.5 then
                        if not NozzleInVehicle and HoldingNozzle then
                            NearTank = true
                            DrawText3D(
                                tankPosition.x + textModifiedPosition.x,
                                tankPosition.y + textModifiedPosition.y,
                                tankPosition.z + zPos + textModifiedPosition.z,
                                Lang.PutPump
                            )
                            if IsControlJustPressed(0, 51) then
                                LoadAnimDict("timetable@gardener@filling_can")
                                TaskPlayAnim(
                                    ped,
                                    "timetable@gardener@filling_can",
                                    "gar_ig_5_filling_can",
                                    2.0,
                                    8.0,
                                    -1,
                                    50,
                                    0,
                                    0,
                                    0,
                                    0
                                )
                                Wait(300)
                                PutNozzleInVehicle(veh, TankBone, isBike, true, nozzleModifiedPosition)
                                Wait(300)
                                ClearPedTasks(ped)
                            end
                        elseif NozzleInVehicle then
                            DrawText3D(
                                tankPosition.x + textModifiedPosition.x,
                                tankPosition.y + textModifiedPosition.y,
                                tankPosition.z + zPos + textModifiedPosition.z,
                                Lang.GetPump
                            )
                            if IsControlJustPressed(0, 51) then
                                LoadAnimDict("timetable@gardener@filling_can")
                                TaskPlayAnim(
                                    ped,
                                    "timetable@gardener@filling_can",
                                    "gar_ig_5_filling_can",
                                    2.0,
                                    8.0,
                                    -1,
                                    50,
                                    0,
                                    0,
                                    0,
                                    0
                                )
                                Wait(300)
                                GrabExistingNozzle()
                                Wait(300)
                                ClearPedTasks(ped)
                            end
                        end
                    end
                else
                    NearTank = false
                end
            else
                wait = 500
            end
        end
    end
)

