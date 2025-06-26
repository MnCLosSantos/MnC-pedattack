local QBCore = exports['qb-core']:GetCoreObject()

local attackInProgress = false
local currentTargetId = nil

RegisterCommand("pedattack", function(source, args)
    if attackRunning then
        -- Notification removed to prevent spam when trying to start another attack
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not GetPlayerName(targetId) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "MnC-pedattack",
            description = "Invalid player ID!",
            type = "error"
        })
        return
    end

    local Player = QBCore.Functions.GetPlayer(targetId)
    local targetName = Player and (Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname) or GetPlayerName(targetId)

    attackInProgress = true
    currentTargetId = targetId

    -- Trigger the attack only for the target player
    TriggerClientEvent("mncpedattack:startAttack", targetId, targetId)

    TriggerClientEvent('ox_lib:notify', source, {
        title = "MnC-pedattack",
        description = "Attack sent to " .. targetName,
        type = "success"
    })

    -- Server-wide notify everyone
    TriggerClientEvent('ox_lib:notify', -1, {
        title = "MnC-pedattack",
        description = targetName .. " is under attack!",
        type = "inform"
    })
end, true)

RegisterCommand("stoppedattack", function(source)
    if not attackInProgress then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "MnC-pedattack",
            description = "No active attack to stop.",
            type = "error"
        })
        return
    end

    attackInProgress = false
    currentTargetId = nil

    -- Tell all clients to stop attack and clean up
    TriggerClientEvent("mncpedattack:stopAttack", -1)

    TriggerClientEvent('ox_lib:notify', source, {
        title = "MnC-pedattack",
        description = "Stopped all gang attacks.",
        type = "inform"
    })

    -- Optional: notify all players attack stopped
    TriggerClientEvent('ox_lib:notify', -1, {
        title = "MnC-pedattack",
        description = "Gang attack has been stopped.",
        type = "inform"
    })
end, true)

-- Optional: reset state on player disconnect if they were target
AddEventHandler('playerDropped', function(reason)
    local src = source
    if attackInProgress and currentTargetId == src then
        attackInProgress = false
        currentTargetId = nil
        TriggerClientEvent("mncpedattack:stopAttack", -1)
        TriggerClientEvent('ox_lib:notify', -1, {
            title = "MnC-pedattack",
            description = "Gang attack stopped because the target left the server.",
            type = "inform"
        })
    end
end)
