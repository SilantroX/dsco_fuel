function GetFuel(vehicle)
    if not DecorExistOn(vehicle, FUEL_DECOR) then
        return GetVehicleFuelLevel(vehicle)
    end
    return DecorGetFloat(vehicle, FUEL_DECOR)
end

function SetFuel(vehicle, fuel)
    if type(fuel) == "number" and fuel >= 0 and fuel <= 100 then
        SetVehicleFuelLevel(vehicle, fuel)
        DecorSetFloat(vehicle, FUEL_DECOR, GetVehicleFuelLevel(vehicle))
    end
end

function NearPump(coords)
    local entity = nil
    for hash in pairs(Config.pumpModels) do
        entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 0.8, hash, true, true, true)
        if entity ~= 0 then
            break
        end
    end
    if Config.pumpModels[GetEntityModel(entity)] then
        return GetEntityCoords(entity), entity
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(1)
        end
    end
end

function PlayEffect(pdict, pname)
    CreateThread(
        function()
            local position = GetOffsetFromEntityInWorldCoords(Nozzle, 0.0, 0.28, 0.17)
            UseParticleFxAssetNextCall(pdict)
            local pfx =
                StartParticleFxLoopedAtCoord(
                pname,
                position.x,
                position.y,
                position.z,
                0.0,
                0.0,
                GetEntityHeading(Nozzle),
                1.0,
                false,
                false,
                false,
                false
            )
            Wait(100)
            StopParticleFxLooped(pfx, 0)
        end
    )
end

function VehicleInFront()
    local entity = nil
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local rayHandle =
        CastRayPointToPoint(pedCoords.x, pedCoords.y, pedCoords.z - 1.3, offset.x, offset.y, offset.z, 10, ped, 0)
    local A, B, C, D, entity = GetRaycastResult(rayHandle)
    if IsEntityAVehicle(entity) then
        return entity
    end
end

function GrabNozzleFromPump()
    LoadAnimDict("anim@am_hold_up@male")
    TaskPlayAnim(ped, "anim@am_hold_up@male", "shoplift_high", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
    Wait(300)
    Nozzle = CreateObject("prop_cs_fuel_nozle", 0, 0, 0, true, true, true)
    AttachEntityToEntity(
        Nozzle,
        ped,
        GetPedBoneIndex(ped, 0x49D9),
        0.11,
        0.02,
        0.02,
        -80.0,
        -90.0,
        15.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
    end
    while not pump do
        Wait(0)
    end
    Rope = AddRope(pump.x, pump.y, pump.z, 0.0, 0.0, 0.0, 3.0, 1, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
    while not Rope do
        Wait(0)
    end
    ActivatePhysics(Rope)
    Wait(50)
    local nozzlePos = GetEntityCoords(Nozzle)
    nozzlePos = GetOffsetFromEntityInWorldCoords(Nozzle, 0.0, -0.033, -0.195)
    AttachEntitiesToRope(
        Rope,
        pumpHandle,
        Nozzle,
        pump.x,
        pump.y,
        pump.z + 1.45,
        nozzlePos.x,
        nozzlePos.y,
        nozzlePos.z,
        5.0,
        false,
        false,
        nil,
        nil
    )
    NozzleDropped = false
    HoldingNozzle = true
    NozzleInVehicle = false
    VehicleFueling = false
    UsedPump = pumpHandle
    SendNUIMessage(
        {
            type = "status",
            status = true
        }
    )
    SendNUIMessage(
        {
            type = "update",
            fuelCost = "0.00",
            fuelTank = "0.00"
        }
    )
end

function GrabExistingNozzle()
    AttachEntityToEntity(
        Nozzle,
        ped,
        GetPedBoneIndex(ped, 0x49D9),
        0.11,
        0.02,
        0.02,
        -80.0,
        -90.0,
        15.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
    NozzleDropped = false
    HoldingNozzle = true
    NozzleInVehicle = false
    VehicleFueling = false
end

function PutNozzleInVehicle(vehicle, ptankBone, isBike, dontClear, newTankPosition)
    if isBike then
        AttachEntityToEntity(
            Nozzle,
            vehicle,
            ptankBone,
            0.0 + newTankPosition.x,
            -0.2 + newTankPosition.y,
            0.2 + newTankPosition.z,
            -80.0,
            0.0,
            0.0,
            true,
            true,
            false,
            false,
            1,
            true
        )
    else
        AttachEntityToEntity(
            Nozzle,
            vehicle,
            ptankBone,
            -0.18 + newTankPosition.x,
            0.0 + newTankPosition.y,
            0.75 + newTankPosition.z,
            -125.0,
            -90.0,
            -90.0,
            true,
            true,
            false,
            false,
            1,
            true
        )
    end
    if not dontClear and IsEntityPlayingAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 3) then
        ClearPedTasks(ped)
    end
    NozzleDropped = false
    HoldingNozzle = false
    NozzleInVehicle = true
    WastingFuel = false
    VehicleFueling = vehicle
end

function DropNozzle()
    DetachEntity(Nozzle, true, true)
    NozzleDropped = true
    HoldingNozzle = false
    NozzleInVehicle = false
    VehicleFueling = false
    SendNUIMessage(
        {
            type = "status",
            status = false
        }
    )
end

function ReturnNozzleToPump()
    DeleteEntity(Nozzle)
    RopeUnloadTextures()
    DeleteRope(Rope)
    NozzleDropped = false
    HoldingNozzle = false
    NozzleInVehicle = false
    VehicleFueling = false
    SendNUIMessage(
        {
            type = "status",
            status = false
        }
    )
end

function AddFuelToVehicle(vehicle, fuel)
    if fuel < 0 then
        fuel = 0
    end
    if fuel > 100 then
        fuel = 100
    end
    if type(fuel) == "number" and fuel >= 0 and fuel <= 100 then
        SetVehicleFuelLevel(vehicle, fuel + 0.0)
        DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
    end
end

function FuelingAnimation()
    local ped = GetPlayerPed(-1)
    LoadAnimDict("timetable@gardener@filling_can")
    TaskPlayAnim(ped, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
end

exports("GetFuel", GetFuel)
exports("SetFuel", SetFuel)
