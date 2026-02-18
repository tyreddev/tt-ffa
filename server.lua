local QBCore = exports['qb-core']:GetCoreObject()

local PlayerBuckets = {} 
local LastPositions = {} 
local SavedInventories = {}
local SavedHealthArmor = {}

local FFA_BUCKET = 77 

local PersistentData = {}

RegisterNetEvent("ffa:sunucu:katil", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if PlayerBuckets[src] then
        TriggerClientEvent('QBCore:Notify', src, "Zaten FFA alanındasın!", "error")
        return
    end

    local citizenid = Player.PlayerData.citizenid
    
    LastPositions[src] = GetEntityCoords(GetPlayerPed(src))
    
    local ped = GetPlayerPed(src)
    local health = GetEntityHealth(ped)
    local armor = GetPedArmour(ped)
    SavedHealthArmor[src] = {health = health, armor = armor}

    local inventory = exports.ox_inventory:GetInventoryItems(src)
    SavedInventories[src] = {}
    
    for slot, item in pairs(inventory) do
        if item then
            SavedInventories[src][slot] = {
                name = item.name,
                count = item.count,
                slot = item.slot,
                metadata = item.metadata
            }
        end
    end
    
    PersistentData[citizenid] = {
        position = LastPositions[src],
        inventory = SavedInventories[src],
        health = SavedHealthArmor[src].health,
        armor = SavedHealthArmor[src].armor,
        timestamp = os.time(),
        inFFA = true
    }
    
    
    exports.ox_inventory:ClearInventory(src)

    SetPlayerRoutingBucket(src, FFA_BUCKET)
    PlayerBuckets[src] = FFA_BUCKET

    TriggerClientEvent("ffa:istemci:girildi", src)
    
    Wait(100)
    
    TriggerClientEvent("ffa:istemci:dogul", src)
    
    Wait(100)

    TriggerClientEvent("ffa:istemci:silahKusan", src)
end)

RegisterNetEvent("ffa:sunucu:mermiDoldur", function()
end)

RegisterNetEvent("ffa:sunucu:canlandir", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if PlayerBuckets[src] ~= FFA_BUCKET then return end

    Player.Functions.SetMetaData("isdead", false)
    Player.Functions.SetMetaData("inlaststand", false)
    
    TriggerClientEvent('hospital:client:Revive', src)
end)

RegisterNetEvent("ffa:sunucu:ayril", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or not LastPositions[src] then return end

    local citizenid = Player.PlayerData.citizenid

    TriggerClientEvent("ffa:istemci:cikildi", src)
    
    Wait(500)

    SetPlayerRoutingBucket(src, 500)
    PlayerBuckets[src] = nil

    exports.ox_inventory:ClearInventory(src)
    
    Wait(300)
    
    if SavedInventories[src] then
        for slot, item in pairs(SavedInventories[src]) do
            exports.ox_inventory:AddItem(src, item.name, item.count, item.metadata, item.slot)
        end
    end

    local fightArenaCoords = vector3(2162.3589, 4080.8833, 1091.7701)
    TriggerClientEvent("ffa:istemci:don", src, fightArenaCoords)
    
    Wait(500)

    if SavedHealthArmor[src] then
        TriggerClientEvent("ffa:istemci:canZirhGeriYukle", src, SavedHealthArmor[src].health, SavedHealthArmor[src].armor)
    end

    LastPositions[src] = nil
    SavedInventories[src] = nil
    SavedHealthArmor[src] = nil
    
    if PersistentData[citizenid] then
        PersistentData[citizenid] = nil
    end
    
    TriggerClientEvent('QBCore:Notify', src, "FFA alanından ayrıldın!", "error")
end)



AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName("tt-ffa") == resourceName then
    end
end)