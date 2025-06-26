local Config = {
    DespawnTime = 5 * 60 * 1000,
    SpawnCountPerGang = 80,
    VehicleSeats = 4,
    PedSpawnWait = 200,
    VehicleSpawnWait = 200,
    SpawnRadius = 660
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

local function getRandomOffset(radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * radius
    return math.cos(angle) * distance, math.sin(angle) * distance
end

local function spawnGangPed(targetPed)
    local model = `g_m_y_ballaeast_01`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end

    local coords = GetEntityCoords(targetPed)
    local offsetX, offsetY = getRandomOffset(Config.SpawnRadius)
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
            DeleteEntity(ped)
        end
    end
    for _, veh in ipairs(activeVehicles) do
        if DoesEntityExist(veh) then
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

RegisterNetEvent("zaps:spawnBallasAttack", function(targetId)
    if attackRunning then
        TriggerEvent('ox_lib:notify', {
            title = "MnC-pedattack",
            description = "An attack is already in progress!",
            type = "error"
        })
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

RegisterNetEvent("zaps:stopAttack", function()
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
