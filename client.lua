local QBCore = exports['qb-core']:GetCoreObject()
local debugPrint = Config.DebugMode -- Toggle debug mode

-- Cooldown Storage (Only for Dispatch)
local dispatchCooldowns = {} -- Tracks cooldowns for each plate
local lastPlateDetected = nil -- Stores last detected plate
local sentDispatches = {} -- Stores sent dispatch IDs to prevent duplicates

local function DebugPrint(message)
    if debugPrint then
        print("[DEBUG] " .. message)
    end
end

local sentDispatches = {} -- ? Tracks sent dispatches to prevent duplicate alerts
local dispatchCooldowns = {} -- ? Tracks cooldowns per plate
local lastPlateDetected = nil
local triggerCount = {} -- ? Track number of dispatch calls per plate

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not handle or handle == -1 then return end

        local finished = false
        repeat
            coroutine.yield(vehicle)
            finished, vehicle = FindNextVehicle(handle)
        until not finished

        EndFindVehicle(handle)
    end)
end

local function GetVehicleByPlate(plate)
    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) then
            local vehPlate = GetVehicleNumberPlateText(vehicle)
            if vehPlate and vehPlate:gsub("%s+", "") == plate:gsub("%s+", "") then
                return vehicle
            end
        end
    end
    return nil
end


-- ? **Register Dispatch Event & Enforce Cooldowns**
-- ? **Register Dispatch Event & Enforce Cooldowns**
RegisterNetEvent("bolo:dispatchPolice")
AddEventHandler("bolo:dispatchPolice", function(plate, officer, reason, location, triggerType, dispatchId)
    local currentTime = GetGameTimer()
    DebugPrint("[DEBUG] DispatchID: " .. dispatchId)

    -- Ensure tables are initialized
    sentDispatches = sentDispatches or {}
    triggerCount = triggerCount or {}
    dispatchCooldowns = dispatchCooldowns or {}

    -- Prevent duplicate dispatches by ID
    if sentDispatches[dispatchId] then
        DebugPrint("[DEBUG] ? Dispatch ID already sent: " .. dispatchId)
        return
    end

    -- Cooldown check per plate
    local lastDispatchTime = dispatchCooldowns[plate] or 0
    local cooldownRemaining = (Config.Cooldown - (currentTime - lastDispatchTime)) / 1000
    if cooldownRemaining > 0 then
        DebugPrint("[DEBUG] ? Cooldown active for plate " .. plate .. " (" .. cooldownRemaining .. "s remaining)")
        return
    end
    local vehicle = GetVehicleByPlate(plate)
    if not vehicle then
        DebugPrint("[DEBUG] ? Vehicle not found for plate: " .. plate)
        return
    end
    -- Track the dispatch
    dispatchCooldowns[plate] = currentTime
    sentDispatches[dispatchId] = true
    triggerCount[plate] = (triggerCount[plate] or 0) + 1

    DebugPrint("[DEBUG] ? Dispatch triggered for plate: " .. plate .. " | Trigger count: " .. triggerCount[plate])

    -- Limit to one dispatch
    if triggerCount[plate] > 1 then
        DebugPrint("[DEBUG] ? Multiple triggers for plate " .. plate .. ", skipping extra.")
        return
    end

    -- Send ps-dispatch alert (ANPR only)
    if triggerType == "anpr" then

exports["ps-dispatch"]:CustomAlert({
    coords = location, -- Replace with the desired coordinates
    message = "ANPR Hit: " .. plate,   -- Brief message for the alert
    dispatchCode = "Grade 1", -- Custom dispatch code
    description = "ANPR HIT",   -- Description shown on the blip
    radius = 0,                       -- Radius for the blip (0 for no radius)
    sprite = 56,                      -- Blip sprite ID
    color = 2,                        -- Blip color ID
    scale = 1.0,                      -- Scale of the blip
    length = 3,                        -- Duration the blip stays on the map (in minutes)
    priority = 1,
})
        DebugPrint("[DEBUG] ?? ANPR dispatch sent via ps-dispatch")
    else
        DebugPrint("[DEBUG] ?? Unsupported triggerType: " .. tostring(triggerType))
    end

    -- Reset trigger count after cooldown
    Citizen.SetTimeout(Config.Cooldown, function()
        triggerCount[plate] = 0
    end)
end)

-- ? **ANPR Detection System (No Cooldowns Applied)**
Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000) -- Check every second
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, camera in ipairs(Config.AnprCameras) do
            local distance = #(playerCoords - camera.coords)
            if distance < camera.radius then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    local plate = GetVehicleNumberPlateText(vehicle)

                    DebugPrint("[DEBUG] ?? Triggering ANPR check for plate: " .. plate .. " at " .. tostring(camera.coords))

                    -- ? **Trigger Server-Side ANPR Check (No Cooldowns Here)**
                    TriggerServerEvent("bolo:checkANPR", plate, camera.coords, vehicle)
                end
            end
        end
    end
end)

-- ? **Ensure ANPR Cameras Stay Updated**
CreateThread(function()
    while true do
        if not Config.EnableLGModsSpeedAnpr then return end
        Citizen.Wait(10000) -- Refresh ANPR cameras every 10 seconds
        DebugPrint("[DEBUG] ?? Requesting latest ANPR cameras from client...")
        DetectANPRCameras()
    end
end)

RegisterNetEvent("anpr:updateCameras")
AddEventHandler("anpr:updateCameras", function(cameras)
    if not Config.EnableLGModsSpeedAnpr then return end
    anprCameras = cameras or {}
    DebugPrint("[DEBUG] ? ANPR cameras updated: " .. json.encode(anprCameras))
end)

-- ? **Find ANPR Cameras on the Map**
function DetectANPRCameras()
    if not Config.EnableLGModsSpeedAnpr then return nil end

    anprCameras = {} -- Reset ANPR camera list
    local entityHandle, entity = FindFirstObject()
    local found = false
    DebugPrint("[DEBUG] ?? Scanning for ANPR Cameras...")

    repeat
        if DoesEntityExist(entity) then
            local model = GetEntityModel(entity)
            if model == Config.ModelHash then
                local coords = GetEntityCoords(entity)
                table.insert(anprCameras, coords)
                DebugPrint("[DEBUG] ?? ANPR Camera Found at: " .. tostring(coords))
            end
        end
        found, entity = FindNextObject(entityHandle)
    until not found

    EndFindObject(entityHandle)

    if #anprCameras > 0 then
        DebugPrint("[DEBUG] ? Sending ANPR Cameras to Server: " .. json.encode(anprCameras))
        TriggerServerEvent("anpr:syncCameras", anprCameras)
    else
        DebugPrint("[DEBUG] ? No ANPR Cameras Detected!")
    end
end

CreateThread(function()
    Wait(5000) -- Wait for the map to load
    DetectANPRCameras() -- Detect ANPR cameras
end)

-- ? **Handle NUI Events (BOLO Management)**
RegisterNUICallback("bolo:add", function(data, cb)
    DebugPrint("?? Received BOLO Add request:", json.encode(data))

    if not data.plate or not data.reason then
        cb({ success = false, error = "Missing plate or reason" })
        return
    end

    -- ? **Send request to the server**
    TriggerServerEvent("bolo:add:submit", data)
    cb({ success = true })
end)

RegisterNetEvent('anpr:openNUI')
AddEventHandler('anpr:openNUI', function(boloData)
    SendNUIMessage({ action = 'openBoloMenu', data = boloData })
    SetNuiFocus(true, true)
end)

RegisterNetEvent("bolo:openAddForm", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "openAddBoloForm" })
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("bolo:remove", function(data, cb)
    TriggerServerEvent("bolo:remove", data.plate)
    cb({ success = true })
end)

RegisterNetEvent("bolo:removeSuccess", function(plate)
    SendNUIMessage({ type = "removeBolo", plate = plate })
end)

RegisterNetEvent("anpr:boloAdded")
AddEventHandler("anpr:boloAdded", function(data)
    local currentTime = GetGameTimer() / 1000
    local remainingTime = data.expires - currentTime

    if remainingTime > 0 then
        local minutesRemaining = math.floor(remainingTime / 60)
        data.expires = minutesRemaining .. " mins"
    else
        data.expires = "Expired"
    end

    SendNUIMessage({ type = "openBolo", data = data })
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("^3[ANPR System]^0 Client-side script loaded.")
        TriggerServerEvent('bolo:registerChatSuggestions')
    end
end)

CreateThread(function()
    DebugPrint("?? ANPR System has been loaded. Support at: https://discord.eddieslife247.co.uk/")
end)


