local isOpen = false
local currentVehicle = nil
local vehicleOriginalHandling = {}
local savedPresets = {}

-- Handling fields
local handlingFields = {
    -- Engine
    {name = 'fInitialDriveForce', label = 'Drive Force', min = 0.01, max = 2.0, step = 0.01, category = 'engine', tip = 'Engine power. Higher = faster acceleration.'},
    {name = 'fDriveInertia', label = 'Drive Inertia', min = 0.1, max = 3.0, step = 0.05, category = 'engine', tip = 'Engine response time. Higher = slower revving.'},
    {name = 'fInitialDriveMaxFlatVel', label = 'Max Speed', min = 50, max = 500, step = 5, category = 'engine', tip = 'Top speed in km/h.'},
    {name = 'fInitialDragCoeff', label = 'Drag Coefficient', min = 0.1, max = 20, step = 0.1, category = 'engine', tip = 'Air resistance. Lower = higher top speed.'},
    {name = 'fMass', label = 'Mass (kg)', min = 500, max = 10000, step = 50, category = 'engine', tip = 'Vehicle weight in kilograms.'},
    {name = 'nInitialDriveGears', label = 'Gear Count', min = 1, max = 10, step = 1, category = 'engine', isGear = true, tip = 'Number of gears in the gearbox.'},
    {name = 'fClutchChangeRateScaleUpShift', label = 'Upshift Speed', min = 0.1, max = 10.0, step = 0.1, category = 'engine', tip = 'Upshift speed. Higher = faster gear change.'},
    {name = 'fClutchChangeRateScaleDownShift', label = 'Downshift Speed', min = 0.1, max = 10.0, step = 0.1, category = 'engine', tip = 'Downshift speed. Higher = faster gear change.'},

    -- Brakes
    {name = 'fBrakeForce', label = 'Brake Force', min = 0.1, max = 3.0, step = 0.05, category = 'brakes', tip = 'Braking power.'},
    {name = 'fHandBrakeForce', label = 'Handbrake', min = 0.1, max = 3.0, step = 0.05, category = 'brakes', tip = 'Handbrake strength.'},
    {name = 'fSteeringLock', label = 'Steering Angle', min = 20, max = 80, step = 1, category = 'brakes', tip = 'Maximum steering angle.'},

    -- Traction
    {name = 'fTractionCurveMax', label = 'Traction Max', min = 0.5, max = 5.0, step = 0.05, category = 'traction', tip = 'Maximum grip level.'},
    {name = 'fTractionCurveMin', label = 'Traction Min', min = 0.5, max = 5.0, step = 0.05, category = 'traction', tip = 'Minimum grip level.'},
    {name = 'fTractionCurveLateral', label = 'Lateral Grip', min = 10, max = 35, step = 0.5, category = 'traction', tip = 'Sideways grip in corners.'},
    {name = 'fTractionBiasFront', label = 'Traction Bias', min = 0.0, max = 1.0, step = 0.01, category = 'traction', tip = '0 = rear, 0.5 = even, 1 = front.'},
    {name = 'fLowSpeedTractionLossMult', label = 'Low Speed Loss', min = 0.0, max = 2.0, step = 0.05, category = 'traction', tip = 'Grip loss at low speed.'},

    -- Suspension
    {name = 'fSuspensionForce', label = 'Suspension Force', min = 0.5, max = 5.0, step = 0.1, category = 'suspension', tip = 'Suspension stiffness.'},
    {name = 'fSuspensionCompDamp', label = 'Comp Damp', min = 0.5, max = 5.0, step = 0.1, category = 'suspension', tip = 'Compression damping.'},
    {name = 'fSuspensionReboundDamp', label = 'Rebound Damp', min = 0.5, max = 5.0, step = 0.1, category = 'suspension', tip = 'Rebound damping.'},
    {name = 'fSuspensionRaise', label = 'Ride Height', min = -0.15, max = 0.15, step = 0.01, category = 'suspension', tip = 'Raise or lower the vehicle.'},
    {name = 'fAntiRollBarForce', label = 'Anti Roll', min = 0.0, max = 3.0, step = 0.1, category = 'suspension', tip = 'Counters body roll in corners.'},

    -- Damage
    {name = 'fCollisionDamageMult', label = 'Collision Damage', min = 0.0, max = 5.0, step = 0.1, category = 'damage', tip = 'Damage from collisions.'},
    {name = 'fWeaponDamageMult', label = 'Weapon Damage', min = 0.0, max = 5.0, step = 0.1, category = 'damage', tip = 'Damage from weapons.'},
    {name = 'fDeformationDamageMult', label = 'Deformation', min = 0.0, max = 5.0, step = 0.1, category = 'damage', tip = 'Visual deformation damage.'},
    {name = 'fEngineDamageMult', label = 'Engine Damage', min = 0.0, max = 5.0, step = 0.1, category = 'damage', tip = 'Engine damage multiplier.'},
}

-- Save original handling (only first time per vehicle)
local function SaveOriginalHandling(vehicle)
    local vehId = NetworkGetNetworkIdFromEntity(vehicle)

    if vehicleOriginalHandling[vehId] then
        return
    end

    vehicleOriginalHandling[vehId] = {
        highGear = GetVehicleHighGear(vehicle),
        values = {}
    }

    for _, field in ipairs(handlingFields) do
        if field.isGear then
            vehicleOriginalHandling[vehId].values[field.name] = GetVehicleHighGear(vehicle)
        else
            vehicleOriginalHandling[vehId].values[field.name] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', field.name)
        end
    end
end

-- Get original handling for vehicle
local function GetOriginalHandling(vehicle)
    local vehId = NetworkGetNetworkIdFromEntity(vehicle)
    return vehicleOriginalHandling[vehId]
end

-- Get handling value
local function GetHandlingValue(vehicle, field)
    if field.isGear then
        return GetVehicleHighGear(vehicle)
    end
    return GetVehicleHandlingFloat(vehicle, 'CHandlingData', field.name)
end

-- Set handling value
local function SetHandlingValue(vehicle, field, value)
    if field.isGear then
        SetVehicleHighGear(vehicle, math.floor(value))
    else
        SetVehicleHandlingFloat(vehicle, 'CHandlingData', field.name, value + 0.0)
    end
end

-- Get all handling values
local function GetAllHandlingValues(vehicle)
    local values = {}
    for _, field in ipairs(handlingFields) do
        values[field.name] = GetHandlingValue(vehicle, field)
    end
    return values
end

-- Notify via chat
local function Notify(msg)
    if Config.ChatNotify then
        TriggerEvent('chat:addMessage', {
            color = {255, 100, 100},
            args = {'ab-handling', msg}
        })
    end
end

-- Open editor
local function OpenEditor()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(vehicle) then
        Notify(Config.Locale.not_in_vehicle)
        return
    end

    currentVehicle = vehicle
    SaveOriginalHandling(vehicle)

    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local handlingValues = GetAllHandlingValues(vehicle)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        vehicleName = vehicleName,
        handlingFields = handlingFields,
        handlingValues = handlingValues,
        presets = savedPresets
    })

    isOpen = true
    TriggerServerEvent('ab-handling:log', vehicleName)
end

-- Close editor
local function CloseEditor()
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'close'})
    isOpen = false
end

-- Register command (restricted = true when permission is set, uses ace: command.{Config.Command})
RegisterCommand(Config.Command, function()
    if isOpen then
        CloseEditor()
    else
        OpenEditor()
    end
end, Config.Permission)

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    CloseEditor()
    cb('ok')
end)

RegisterNUICallback('updateHandling', function(data, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        for _, field in ipairs(handlingFields) do
            if field.name == data.field then
                SetHandlingValue(currentVehicle, field, data.value)
                break
            end
        end
    end
    cb('ok')
end)

RegisterNUICallback('resetHandling', function(_, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        local original = GetOriginalHandling(currentVehicle)

        if original then
            SetVehicleHighGear(currentVehicle, original.highGear)

            for _, field in ipairs(handlingFields) do
                if not field.isGear and original.values[field.name] then
                    SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', field.name, original.values[field.name])
                end
            end
        end

        cb(GetAllHandlingValues(currentVehicle))
    else
        cb({})
    end
end)

RegisterNUICallback('exportHandling', function(_, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle))
        local values = GetAllHandlingValues(currentVehicle)
        cb({values = values, vehicleName = vehicleName})
    else
        cb({values = {}, vehicleName = ''})
    end
end)

-- Save preset
RegisterNUICallback('savePreset', function(data, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        local values = GetAllHandlingValues(currentVehicle)
        savedPresets[data.name] = values
        cb({success = true, presets = savedPresets})
    else
        cb({success = false})
    end
end)

-- Load preset
RegisterNUICallback('loadPreset', function(data, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) and savedPresets[data.name] then
        local preset = savedPresets[data.name]
        for _, field in ipairs(handlingFields) do
            if preset[field.name] then
                SetHandlingValue(currentVehicle, field, preset[field.name])
            end
        end
        cb({success = true, values = GetAllHandlingValues(currentVehicle)})
    else
        cb({success = false})
    end
end)

-- Delete preset
RegisterNUICallback('deletePreset', function(data, cb)
    savedPresets[data.name] = nil
    cb({success = true, presets = savedPresets})
end)

-- Get presets
RegisterNUICallback('getPresets', function(_, cb)
    cb(savedPresets)
end)

-- ESC & close key handler (optimized - 0.00ms when closed)
CreateThread(function()
    while true do
        if isOpen then
            DisableControlAction(0, 200, true) -- ESC
            if IsDisabledControlJustPressed(0, 200) then
                CloseEditor()
            end
            if Config.CloseKey and IsControlJustPressed(0, Config.CloseKey) then
                CloseEditor()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)
