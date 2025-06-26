local Config = {
    DespawnTime = 5 * 60 * 1000,
    SpawnCountPerGang = 80,
    VehicleSeats = 4,
    PedSpawnWait = 200,
    VehicleSpawnWait = 200,
    SpawnRadius = 660,
    MinSpawnDistance = 50 -- new minimum distance from target
}

local activeAttackers = {}
local activeVehicles = {}
local targetPlayerPed = nil
local targetPlayerId = nil
local attackRunning = false
local relationshipGroupHash = `GANG_ATTACKERS`

-- Setup relationship groups on resource start
CreateThread(function()
    AddRelationshipGroup("GANG_ATTACKERS")
    SetRelationshipBetweenGroups(0, relationshipGroupHash, relationshipGroupHash) -- no aggression between attackers
    SetRelationshipBetweenGroups(5, relationshipGroupHash, `PLAYER`)              -- hate players
    SetRelationshipBetweenGroups(5, `PLAYER`, relationshipGroupHash)
end)


local function playThreatAnim(ped)
    RequestAnimDict("missheistfbi3b_ig8_2")
    while not HasAnimDictLoaded("missheistfbi3b_ig8_2") do Wait(50) end
    TaskPlayAnim(ped, "missheistfbi3b_ig8_2", "hands_up_scared", 8.0, -8, 1500, 1, 0, false, false, false)
end

local function getRandomOffset(radius, minDistance)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * (radius - minDistance) + minDistance
    return math.cos(angle) * distance, math.sin(angle) * distance
end

local function spawnGangPed(targetPed)
    local model = `g_m_y_ballaeast_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

    local coords = GetEntityCoords(targetPed)
    local offsetX, offsetY = getRandomOffset(Config.SpawnRadius, Config.MinSpawnDistance)
    local spawnPos = vector3(coords.x + offsetX, coords.y + offsetY, coords.z)

    local ped = CreatePed(4, model, spawnPos.x, spawnPos.y, spawnPos.z, math.random(0, 360), true, false)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedAsEnemy(ped, true)
    SetPedCanSwitchWeapon(ped, false)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- Assign relationship group
    SetPedRelationshipGroupHash(ped, relationshipGroupHash)
    SetEntityCanBeDamagedByRelationshipGroup(ped, false, relationshipGroupHash)

    -- Combat setup
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 1424, false)

    GiveWeaponToPed(ped, `WEAPON_MICROSMG`, 9999, false, true)
    table.insert(activeAttackers, ped)

    -- Engage target only
    playThreatAnim(ped)
    TaskCombatPed(ped, targetPed, 0, 16)

    return ped
end

local function cleanupAttack()
    for _, ped in ipairs(activeAttackers) do
        if DoesEntityExist(ped) then
            ClearPedTasksImmediately(ped)
            SetEntityAsNoLongerNeeded(ped)
            DeleteEntity(ped)
        end
    end
    for _, veh in ipairs(activeVehicles) do
        if DoesEntityExist(veh) then
            SetEntityAsNoLongerNeeded(veh)
            DeleteEntity(veh)
        end
    end
    activeAttackers = {}
    activeVehicles = {}
    targetPlayerPed = nil
    targetPlayerId = nil
    attackRunning = false

    TriggerEvent('ox_lib:notify', {
        title = "MnC-pedattack",
        description = "Gang attack stopped and cleaned up.",
        type = "inform"
    })
end

-- Robust local player death monitor
CreateThread(function()
    while true do
        Wait(500) -- check twice a second

        local localPed = PlayerPedId()
        if attackRunning and IsEntityDead(localPed) then
            cleanupAttack()
            -- Do NOT break here to catch respawns if needed
            -- If you want to only cleanup once, uncomment break
            -- break
        end
    end
end)


local function monitorTarget()
    CreateThread(function()
        while attackRunning do
            Wait(1000)
            if not DoesEntityExist(targetPlayerPed) or IsEntityDead(targetPlayerPed) then
                cleanupAttack()
                break
            end
        end
    end)
end

-- Changed event names to avoid conflicts
RegisterNetEvent("mncpedattack:startAttack", function(targetId)
    if attackRunning then
        -- Notification removed to prevent spam when trying to start another attack
        return
    end

    targetPlayerId = targetId
    targetPlayerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayerId))
    if not targetPlayerPed or targetPlayerPed == -1 then
        print("Invalid target player ped.")
        return
    end

    attackRunning = true

    for i = 1, Config.SpawnCountPerGang do
        spawnGangPed(targetPlayerPed)
        Wait(Config.PedSpawnWait)
    end

    -- Auto cleanup after timeout
    SetTimeout(Config.DespawnTime, function()
        if attackRunning then
            cleanupAttack()
        end
    end)

    monitorTarget()
end)

RegisterNetEvent("mncpedattack:stopAttack", function()
    if attackRunning then
        cleanupAttack()
    else
        TriggerEvent('ox_lib:notify', {
            title = "MnC-pedattack",
            description = "No active attack to stop.",
            type = "error"
        })
    end
end)
