FUEL_DECOR = Config.fuel_decor
NozzleDropped = false
HoldingNozzle = false
NozzleInVehicle = false
Nozzle = nil
Rope = nil
VehicleFueling = nil
UsedPump = nil
PumpCoords = nil
WastingFuel = false
UsingCan = false
NearTank = false

-- Nozzle Z position based on vehicle class.
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

if Config.framework == "ESX" then
    FRWORK = exports["es_extended"]:getSharedObject()
elseif Config.framework == "QB" then
    FRWORK = exports["qb-core"]:GetCoreObject()
end

for _, vehHash in pairs(Config.electricVehicles) do
    Config.electricVehicles[vehHash] = vehHash
end

-- Create blips for each gas station location.
CreateThread(
    function()
        for _, coords in pairs(Config.blipLocations) do
            local blip = AddBlipForCoord(coords)
            SetBlipSprite(blip, 361)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, 4)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Gasolinera")
            EndTextCommandSetBlipName(blip)
        end
    end
)

-- vehicle fuel consumption.
CreateThread(
    function()
        while true do
            Wait(3500)
            local pedVeh = GetVehiclePedIsIn(ped)
            local seat = GetPedInVehicleSeat(pedVeh, -1)
            if pedVeh ~= 0 and seat ~= 0 then
                local vehClass = GetVehicleClass(pedVeh)
                if not DecorExistOn(pedVeh, FUEL_DECOR) then
                    SetFuel(pedVeh, math.random(200, 800) / 10)
                end
                local fuel = GetFuel(pedVeh)
                if GetIsVehicleEngineRunning(pedVeh) then
                    if fuel < 5.0 then
                        DisableControlAction(0, 71)
                        SetVehicleEngineOn(pedVeh, false, true, true)
                    end
                    SetFuel(pedVeh, fuel - ((GetVehicleCurrentRpm(pedVeh) * Config.vehicleClasses[vehClass]) / 1.7))
                end
            end
        end
    end
)

-- spawn pumps on the map.
CreateThread(
    function()
        for _, pumps in pairs(Config.addPumps) do
            CreateObject(GetHashKey(pumps.hash), pumps.x, pumps.y, pumps.z - 1.0, true, true, true)
        end
    end
)

-- Register the fuel decor
CreateThread(
    function()
        DecorRegister(FUEL_DECOR, 1)
    end
)

RegisterNetEvent("dsco_fuel:client:UseJerrycan")
AddEventHandler(
    "dsco_fuel:client:UseJerrycan",
    function()
        local src = source
        local ped = GetPlayerPed(-1)
        local invehicle = IsPedInAnyVehicle(ped)
        local curVehD = FRWORK.Functions.GetClosestVehicle()
        local PlayerCoords = GetEntityCoords(ped)
        local vehicleCoords = GetEntityCoords(curVehD)
        local distanceToVehicle = #(PlayerCoords - vehicleCoords)
        if distanceToVehicle > 2.5 then
            FRWORK.Functions.Notify(Lang.NoVehicle, "error")
            return
        end
        if invehicle then
            FRWORK.Functions.Notify(Lang.InVehicle, "error")
            return
        end
        local curVeh = FRWORK.Functions.GetClosestVehicle()
        local vehicleFuel = DecorGetFloat(curVeh, Config.fuel_decor)
        if vehicleFuel < 100 then
            TaskTurnPedToFaceEntity(ped, curVeh, 1000)
            Wait(1000)
            TriggerServerEvent("dsco_fuel:JerryCanprop", "add")
            Wait(500)
            FuelingAnimation()
            TriggerEvent("cxc:displayItems", false)
            FRWORK.Functions.Progressbar(
                "refueling_veh",
                Lang.ProgressJerryCan,
                10000,
                false,
                true,
                {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true
                },
                {},
                {},
                {},
                function()
                    -- Done
                    AddFuelToVehicle(curVeh, vehicleFuel + 100.0)
                    FRWORK.Functions.Notify(Lang.JerryCanSucess, "success")
                    TriggerServerEvent("dsco_fuel:removeJerryCan")
                    TriggerServerEvent("dsco_fuel:JerryCanprop", "remove")
                end,
                function()
                    -- Cancel
                    TriggerServerEvent("dsco_fuel:JerryCanprop", "remove")
                end
            )
        else
            FRWORK.Functions.Notify(Lang.FullJerry, "error")
        end
    end
)


Citizen.CreateThread(function()
    Citizen.Wait(10000)
    SendNUIMessage({
        type = "lang",
        translate = Lang.UI,
        FuelPrice = Config.jerryCanPrice
    })
end)