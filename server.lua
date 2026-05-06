local QBCore = exports['qb-core']:GetCoreObject()
local debugPrint = Config.DebugMode -- Toggle debug mode
local oxmysql = exports.oxmysql -- Reference oxmysql
local anprCameras = {} -- Use predefined cameras from the config
local boloVehicles = {}
local dispatchCooldowns = {} -- Tracks cooldowns per plate
local lastANPRDetections = {}
local lastPedAlerts = {}

local function DebugPrint(message)
    if debugPrint then
        print("[DEBUG] " .. message)
    end
end

local function NormalizePlate(plate)
    return string.upper(plate:gsub("%s+", ""))
end


-- ? **Receive ANPR camera data from clients & Sync**
RegisterNetEvent("anpr:syncCameras")
AddEventHandler("anpr:syncCameras", function(cameras)
    if not cameras or #cameras == 0 then
        DebugPrint("[DEBUG] ?? Received empty ANPR camera list. Skipping update.")
    else
        DebugPrint("[DEBUG] ?? ANPR Cameras Updated from Client: " .. json.encode(cameras))
        anprCameras = cameras
    end
end)

-- ? **Send Camera Data to Clients When Requested**
RegisterNetEvent("anpr:requestCameras")
AddEventHandler("anpr:requestCameras", function()
    local src = source
    DebugPrint("[DEBUG] ?? Sending ANPR Cameras to Client ID: " .. src)
    TriggerClientEvent("anpr:updateCameras", src, anprCameras)
end)

-- ? **Find Nearby Pedestrians (Exclude NPCs in Vehicles)**
function FindNearbyPed(vehicleCoords, range)
    if not Config.EnablePedAlerts then return nil end

    local foundPed = nil
    local minDistance = range

    local peds = GetGamePool("CPed") -- Get all NPC peds
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then -- Ignore players
            local pedCoords = GetEntityCoords(ped)
            local distance = #(pedCoords - vehicleCoords)

            -- ? **Ensure the pedestrian is NOT inside a vehicle**
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle == 0 and distance <= range and distance < minDistance then
                minDistance = distance
                foundPed = ped
            end
        end
    end

    if foundPed then
        DebugPrint("[DEBUG] ?? Pedestrian found near vehicle at distance: " .. minDistance)
        return foundPed
    else
        DebugPrint("[DEBUG] ? No valid pedestrians found near vehicle.")
        return nil
    end
end

local dispatchedIds = {} -- ? Tracks sent dispatches to prevent duplicate alerts

local dispatchedIds = {} -- ? Tracks sent dispatches to prevent duplicate alerts
local activeBOLOs = {} -- ? Tracks currently active BOLO checks

-- ? **Function to Process BOLO Vehicle (No Cooldowns Applied)**
function ProcessBOLOVehicle(plate, vehCoords, triggerType)
    if not boloVehicles[plate] then
        DebugPrint("[DEBUG] ? Vehicle Plate: " .. plate .. " is NOT in the BOLO list.")
        return false
    end

    -- ? **Generate & Assign Unique Dispatch ID**
    local dispatchId = plate .. "-" .. math.random(1000, 9999)

    -- ? **Check if this dispatch ID already exists**
    if dispatchedIds[dispatchId] then
        DebugPrint("[DEBUG] ?? Skipping duplicate dispatch for ID: " .. dispatchId)
        return false
    end

    -- ? **Mark this dispatch ID as sent**
    dispatchedIds[dispatchId] = true

    local officer = boloVehicles[plate].officer or "Unknown Officer"
    local reason = boloVehicles[plate].reason or "No reason provided"

    DebugPrint("[DEBUG] ?? Processing BOLO Hit | Plate: " .. plate .. " | Triggered by: " .. triggerType .. " | ID: " .. dispatchId)

    -- ? **Send Dispatch Alert**
    TriggerClientEvent("bolo:dispatchPolice", -1, plate, officer, reason, vehCoords, triggerType, dispatchId)
    
    return true
    -- Your code here when blackout is false
end

-- ? **Check for nearby ANPR cameras & pedestrians**
CreateThread(function()
    while true do
        Wait(1000) -- Run check every 3 seconds
        local players = GetPlayers()

        for _, player in ipairs(players) do
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local veh = GetVehiclePedIsIn(ped, false)
                if veh and DoesEntityExist(veh) then
                    local plate = string.upper(GetVehicleNumberPlateText(veh)):gsub("%s+", "")
                    local vehCoords = GetEntityCoords(veh)

                    -- ? **Check if this vehicle is already being processed**
                    if activeBOLOs[plate] then
                        DebugPrint("[DEBUG] ?? Skipping duplicate BOLO check for plate: " .. plate)
                        goto continue
                    end

                    -- ? **Mark this plate as active BOLO processing**
                    activeBOLOs[plate] = true


                    local alertTriggered = false -- Prevent multiple alerts for the same detection

                    -- ? **Check for ANPR Cameras (Only if available)**
                    if #anprCameras > 0 then
                        for _, camCoords in ipairs(anprCameras) do
                            local distance = #(vehCoords - vector3(camCoords.x, camCoords.y, camCoords.z))
                            if distance < 100.0 then -- Within 100 meters of an ANPR camera
                                DebugPrint("[DEBUG] ?? Vehicle detected near ANPR camera at " .. json.encode(camCoords) .. " | Plate: " .. plate)

                                -- ? **Process BOLO Vehicle via ANPR (No Cooldown Applied)**
                                ProcessBOLOVehicle(plate, vehCoords, "anpr")
                                alertTriggered = true
                                break -- Exit loop to prevent multiple triggers
                            end
                        end
                    else
                        DebugPrint("[DEBUG] ? No ANPR cameras available. Skipping ANPR check, checking pedestrians instead.")
                    end

                    -- ? **Check for nearby pedestrians (Only if no ANPR alert was sent)**
                    if not alertTriggered then
			DebugPrint("Checking Peds near: " .. vehCoords)
                        local nearbyPed = FindNearbyPed(vehCoords, 10.0)
                        if nearbyPed then
DebugPrint("Ped Found!")
                    -- ? **Randomized 10% Chance to Trigger Dispatch**
		    local PedChance = math.random(1, 100)
		    DebugPrint("Ped Chance is: " .. PedChance)
                    if PedChance > 10 then
                        DebugPrint("[DEBUG] ?? Dispatch skipped due to probability filter (10% chance).")
                        activeBOLOs[plate] = nil -- ? Remove from active processing if skipped
                        goto continue
                    end

                            DebugPrint("[DEBUG] ?? Pedestrian witness found near vehicle!")

                            -- ? **Process BOLO Vehicle via Pedestrian Alert (No Cooldown Applied)**
                            ProcessBOLOVehicle(plate, vehCoords, "ped")
                        end
                    end

                    -- ? **Remove plate from active processing after check**
                    activeBOLOs[plate] = nil
                end
            end
            ::continue::
        end
    end
end)


-- ? **Check if BOLO exists & Send Dispatch Immediately**
function FetchPersistentBOLOs()
    if not Config.PersistantBolos then return end
    local query = Config.SQLPersistantBolo

oxmysql:execute(query, {}, function(result)
    DebugPrint("[DEBUG] FetchPersistentBOLOs result: " .. json.encode(result))
    for _, row in ipairs(result) do
        DebugPrint("[DEBUG] Row content: " .. json.encode(row))
        local plate = row.plate
if not plate then DebugPrint("[ERROR] row.plate is nil!") return end

        if not plate then
            DebugPrint("[ERROR] row.plate is nil. Check your SQL query and column names!")
        else
            boloVehicles[plate] = {
                name = "Unknown",
                officer = "System MDT",
                reason = "No reason provided",
                expiry = nil,
                temporary = false
            }

            local dispatchId = plate .. "-" .. math.random(1000, 9999)

            if not dispatchCooldowns[plate] or (os.time() - dispatchCooldowns[plate]) > Config.Cooldown then
                dispatchCooldowns[plate] = os.time()
                DebugPrint("[DEBUG] ?? Sending Dispatch for BOLO Plate: " .. plate)
                TriggerClientEvent("bolo:dispatchPolice", -1, plate, "System MDT", "No reason provided", nil, "BOLO", dispatchId)
            else
                DebugPrint("[DEBUG] ?? Skipping dispatch for BOLO " .. plate .. " (Cooldown Active)")
            end
        end
    end
end)
end

-- ? **Check if Warrant exists & Send Dispatch Immediately**
function fetchPersistantWarrants()
    if not Config.SQLPersistantWarrant then return end
    local query = Config.SQLPersistantWarrant

    oxmysql:execute(query, {}, function(result)
        if not result or #result == 0 then
            DebugPrint("[DEBUG] No persistent warrants found.")
            return
        end

        for _, row in ipairs(result) do
            local plate = row.plate
            local model = row.vehicle 

            boloVehicles[plate] = {
                name = model or "Unknown",
                officer = "System MDT - Warrant Issued",
                reason = "Active Warrant - Owner has an outstanding warrant",
                expiry = nil,
                temporary = false
            }
    local dispatchId = plate .. "-" .. math.random(1000, 9999)

            -- ? **Dispatch if not in cooldown**
            if not dispatchCooldowns[plate] or (os.time() - dispatchCooldowns[plate]) > Config.Cooldown then
                dispatchCooldowns[plate] = os.time()
                DebugPrint("[DEBUG] ?? Sending Dispatch for Warrant Plate: " .. plate)
                TriggerClientEvent("bolo:dispatchPolice", -1, plate, "System MDT - Warrant Issued", "Active Warrant", nil, "Warrant", dispatchId)
            else
                DebugPrint("[DEBUG] ?? Skipping dispatch for Warrant " .. plate .. " (Cooldown Active)")
            end
        end
        DebugPrint("[DEBUG] ?? Persistent Warrants Loaded: " .. json.encode(boloVehicles))
    end)
end

function isAllowedJob(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    local jobName = Player.PlayerData.job.name
    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if jobName == allowedJob then
            return true
        end
    end

    return false
end


-- ? **Call Fetch BOLOs & Warrants When Server Starts**
FetchPersistentBOLOs()
fetchPersistantWarrants()

CreateThread(function()
    while true do
        FetchPersistentBOLOs()
        fetchPersistantWarrants()
        Wait(120000) -- wait AFTER both are complete
    end
end)


-- ? **BOLO ANPR Detection & Dispatch**
RegisterNetEvent("bolo:checkANPR")
AddEventHandler("bolo:checkANPR", function(plate, coords, vehicle)
    if boloVehicles[plate] then
        DebugPrint("[DEBUG] ? BOLO Match Found for " .. plate)
    local dispatchId = plate .. "-" .. math.random(1000, 9999)

        local officer = boloVehicles[plate].officer
        local reason = boloVehicles[plate].reason

        -- ? **Dispatch If No Active Cooldown**
        if not dispatchCooldowns[plate] or (os.time() - dispatchCooldowns[plate]) > Config.Cooldown then
            dispatchCooldowns[plate] = os.time()
            DebugPrint("[DEBUG] ?? Sending Dispatch for ANPR Detection: " .. plate)
            TriggerClientEvent("bolo:dispatchPolice", -1, plate, officer, reason, coords, "ANPR", dispatchId)
        else
            DebugPrint("[DEBUG] ?? Skipping ANPR Dispatch for " .. plate .. " (Cooldown Active)")
        end
    end
end)

-- ? **Pedestrian Alert & Dispatch**
RegisterNetEvent("bolo:checkPedAlert")
AddEventHandler("bolo:checkPedAlert", function(plate, location, vehicle)
    if not Config.EnablePedAlerts then return end

    if boloVehicles[plate] then
        DebugPrint("[DEBUG] ? BOLO Match Found for Pedestrian Alert: " .. plate)
    local dispatchId = plate .. "-" .. math.random(1000, 9999)

        local officer = boloVehicles[plate].officer
        local reason = boloVehicles[plate].reason

        -- ? **Dispatch If No Active Cooldown**
        if not dispatchCooldowns[plate] or (os.time() - dispatchCooldowns[plate]) > Config.Cooldown then
            dispatchCooldowns[plate] = os.time()
            DebugPrint("[DEBUG] ?? Sending Dispatch for Pedestrian Alert: " .. plate)
            TriggerClientEvent("bolo:dispatchPolice", -1, plate, officer, reason, location, "ped", dispatchId)
        else
            DebugPrint("[DEBUG] ?? Skipping Pedestrian Dispatch for " .. plate .. " (Cooldown Active)")
        end
    end
end)

-- ? **BOLO Expiry Cleanup**
CreateThread(function()
    while true do
        Wait(6000) -- Check every 60 seconds
        local currentTime = os.time()

        for plate, data in pairs(boloVehicles) do
            if data.expiry and currentTime > data.expiry then
                DebugPrint("[DEBUG] ?? Expired BOLO Removed: " .. plate)
                boloVehicles[plate] = nil
            end
        end
    end
end)

-- ? **Command to List Active BOLOs**
RegisterCommand("listbolo", function(source)
    local src = source
    if not isAllowedJob(src) then return end

    local boloData = {}
    for plate, data in pairs(boloVehicles) do
        table.insert(boloData, {
            plate = plate,
            officer = data.officer,
            reason = data.reason,
            expires = data.expiry and os.time() > data.expiry and "Expired" or "Active"
        })
    end

    DebugPrint("[DEBUG] ?? Sending BOLO List to Client")
    TriggerClientEvent("anpr:openNUI", src, boloData)
end, false)

RegisterCommand("refreshbolo", function(source)
    local src = source
    if src ~= 0 and not isAllowedJob(src) then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "You are not authorized to refresh BOLOs!" })
        return
    end

    FetchPersistentBOLOs()
    fetchPersistantWarrants()

    DebugPrint("[DEBUG] ?? Manual BOLO refresh triggered by: " .. (src == 0 and "Console" or GetPlayerName(src)))
    
    if src ~= 0 then
        TriggerClientEvent("ox_lib:notify", src, { type = "success", description = "BOLOs and Warrants refreshed." })
    end
end, false)


-- ? **Command to Remove a BOLO**
RegisterCommand("removebolo", function(source, args)
    local src = source
    if not isAllowedJob(src) or not args[1] then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "Usage: /removebolo [PLATE]" })
        return
    end

    local plate = string.upper(args[1])
    if boloVehicles[plate] then
        boloVehicles[plate] = nil
        DebugPrint("[DEBUG] ?? BOLO Removed: " .. plate)
        TriggerClientEvent("ox_lib:notify", src, { type = "success", description = "BOLO Removed: " .. plate })
    else
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "No BOLO found for plate: " .. plate })
    end
end, false)


RegisterCommand("addbolo", function(source, args)
    local src = source
    if not isAllowedJob(src) then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "You are not authorized to add BOLOs!" })
        return
    end

    if not args[1] or not args[2] then
        TriggerClientEvent("ox_lib:notify", src, { type = "error", description = "Usage: /addbolo [PLATE] [REASON]" })
        return
    end

    local plate = NormalizePlate(string.upper(args[1]):gsub("%s+", ""))
    local reason = table.concat(args, " ", 2)
    local officer = GetPlayerName(src) or "Unknown Officer"

    boloVehicles[plate] = {
        officer = officer,
        reason = reason,
        expiry = nil, -- Optional: Implement expiry logic
        temporary = false
    }

    DebugPrint("[DEBUG] ?? New BOLO Added | Plate: " .. plate .. " | Reason: " .. reason .. " | Officer: " .. officer)
    TriggerClientEvent("ox_lib:notify", src, { type = "success", description = "BOLO Added! Plate: " .. plate .. " | Reason: " .. reason })
end, false)

RegisterNetEvent('bolo:registerChatSuggestions', function()
    local src = source
    TriggerClientEvent('chat:addSuggestion', src, '/addbolo', 'Add a BOLO for a vehicle plate', {
        { name = 'plate', help = 'Number plate of the vehicle (no spaces)' },
        { name = 'reason', help = 'Reason for the BOLO' }
    })

    TriggerClientEvent('chat:addSuggestion', src, '/removebolo', 'Remove a BOLO for a vehicle plate', {
        { name = 'plate', help = 'Number plate of the vehicle (no spaces)' }
    })
end)

-- ✅ **BOLO Export Functions**
if Config.ExportsEnabled then

    exports('addBolo', function(plate, reason, officer, expiry)
        if not plate or not reason then
            return false, "Missing plate or reason"
        end

        local normalizedPlate = NormalizePlate(plate)
        local expiryTime = expiry and (os.time() + expiry) or nil

        boloVehicles[normalizedPlate] = {
            officer = officer or "System",
            reason = reason,
            expiry = expiryTime,
            temporary = expiry ~= nil
        }

        DebugPrint("[EXPORT] ✅ BOLO Added via export | Plate: " .. normalizedPlate .. " | Reason: " .. reason)
        return true, "BOLO added for " .. normalizedPlate
    end)

    exports('removeBolo', function(plate)
        if not plate then
            return false, "Missing plate"
        end

        local normalizedPlate = NormalizePlate(plate)

        if not boloVehicles[normalizedPlate] then
            return false, "No BOLO found for plate: " .. normalizedPlate
        end

        boloVehicles[normalizedPlate] = nil
        DebugPrint("[EXPORT] 🗑️ BOLO Removed via export | Plate: " .. normalizedPlate)
        return true, "BOLO removed for " .. normalizedPlate
    end)

    exports('updateBolo', function(plate, updates)
        if not plate or not updates then
            return false, "Missing plate or updates"
        end

        local normalizedPlate = NormalizePlate(plate)

        if not boloVehicles[normalizedPlate] then
            return false, "No BOLO found for plate: " .. normalizedPlate
        end

        if updates.reason then
            boloVehicles[normalizedPlate].reason = updates.reason
        end
        if updates.officer then
            boloVehicles[normalizedPlate].officer = updates.officer
        end
        if updates.expiry then
            boloVehicles[normalizedPlate].expiry = os.time() + updates.expiry
            boloVehicles[normalizedPlate].temporary = true
        end

        DebugPrint("[EXPORT] 🔄 BOLO Updated via export | Plate: " .. normalizedPlate)
        return true, "BOLO updated for " .. normalizedPlate
    end)

    exports('getBolos', function()
        local boloList = {}
        for plate, data in pairs(boloVehicles) do
            table.insert(boloList, {
                plate = plate,
                officer = data.officer,
                reason = data.reason,
                expiry = data.expiry,
                temporary = data.temporary
            })
        end
        return boloList
    end)

    exports('hasBolo', function(plate)
        if not plate then return false end
        local normalizedPlate = NormalizePlate(plate)
        return boloVehicles[normalizedPlate] ~= nil
    end)

end
