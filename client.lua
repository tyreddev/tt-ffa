
local QBCore = exports['qb-core']:GetCoreObject()
local inFFA = false
local currentFFAWeapon = nil
local WEAPON_G20P_HASH = GetHashKey("WEAPON_G20P")

CreateThread(function()
    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)

    while not HasModelLoaded(model) do Wait(10) end

    local npc = CreatePed(4, model, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1, Config.NPC.heading, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                label = "FFA'ya Gir",
                icon = "fa-solid fa-gun",
                action = function(entity)

                    TriggerServerEvent("ffa:sunucu:katil")
                end
            }
        },
        distance = 2.0
    })
end)

local function StartFFALoops()
    
    CreateThread(function()
        local isDead = false
        while inFFA do
            Wait(1000)
            local ped = PlayerPedId()
            if IsEntityDead(ped) and not isDead then
                isDead = true
                Wait(1000)
                
                TriggerServerEvent("ffa:sunucu:canlandir")
                Wait(500)
                
                local random = Config.FFASpawns[math.random(1, #Config.FFASpawns)]
                SetEntityCoords(ped, random.x, random.y, random.z)
                
                SetEntityHealth(ped, 200)
                SetPedArmour(ped, 100)
                
                RemoveAllPedWeapons(ped, true)
                GiveWeaponToPed(ped, WEAPON_G20P_HASH, 250, false, true)
                SetPedAmmo(ped, WEAPON_G20P_HASH, 999)
                SetCurrentPedWeapon(ped, WEAPON_G20P_HASH, true)
                
                CreateThread(function()
                     for i=1, 5 do 
                        SetCurrentPedWeapon(ped, WEAPON_G20P_HASH, true)
                        Wait(100)
                     end
                end)
                
                isDead = false
            end
        end
    end)

    CreateThread(function()
        while inFFA do
            Wait(0)
            local ped = PlayerPedId()
            if currentFFAWeapon then
                 if not HasPedGotWeapon(ped, currentFFAWeapon, false) then
                    GiveWeaponToPed(ped, currentFFAWeapon, 250, false, true)
                    SetPedAmmo(ped, currentFFAWeapon, 999)
                    SetCurrentPedWeapon(ped, currentFFAWeapon, true)
                 end
            else
                Wait(500)
            end
        end
    end)
end

RegisterNetEvent("ffa:istemci:girildi", function()
  --  pcall(function()
    --    exports['tt-gamemode']:ExitFightMode()
    --end)
    
    inFFA = true
    currentFFAWeapon = WEAPON_G20P_HASH
    
    Wait(100)
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)

    RemoveAllPedWeapons(ped, true)
    GiveWeaponToPed(ped, WEAPON_G20P_HASH, 250, false, true)
    SetPedAmmo(ped, WEAPON_G20P_HASH, 999)
    SetCurrentPedWeapon(ped, WEAPON_G20P_HASH, true)
    
    StartFFALoops()
    TriggerEvent('menu-ffa:ac')
    SendNUIMessage({
        action = "show"
    })
end)

RegisterNetEvent("ffa:istemci:cikildi", function()
    inFFA = false
    currentFFAWeapon = nil
    TriggerEvent('menu-ffa:kapa')
    SendNUIMessage({
        action = "hide"
    })
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
end)

RegisterNetEvent("ffa:istemci:canZirhGeriYukle", function(health, armor)
    Wait(10)
    local ped = PlayerPedId()
    SetEntityHealth(ped, health)
    SetPedArmour(ped, armor)
end)

RegisterNetEvent("ffa:istemci:dogul", function()
    local ped = PlayerPedId()
    local random = Config.FFASpawns[math.random(1, #Config.FFASpawns)]
    SetEntityCoords(ped, random.x, random.y, random.z)
    
    GiveWeaponToPed(ped, WEAPON_G20P_HASH, 250, false, true)
    SetPedAmmo(ped, WEAPON_G20P_HASH, 999)
    SetCurrentPedWeapon(ped, WEAPON_G20P_HASH, true)
end)

RegisterNetEvent("ffa:istemci:don", function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    
   -- pcall(function()
     --   exports['tt-gamemode']:EnterFightMode()
    --end)
end)

RegisterNetEvent("ffa:istemci:zorlaGeriDon", function(coords)
    inFFA = false
    currentFFAWeapon = nil
    
    local ped = PlayerPedId()
    
    RemoveAllPedWeapons(ped, true)
    
    DoScreenFadeOut(50)
    Wait(50)
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, true)
    SetEntityHeading(ped, 0.0)

    FreezeEntityPosition(ped, true)
    Wait(10)
    FreezeEntityPosition(ped, false)
    
    RemoveAllPedWeapons(ped, true)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    
    Wait(50)
    DoScreenFadeIn(50)
    
    Wait(50)
    DoScreenFadeIn(50)
    TriggerEvent('menu-ffa:kapa')
    SendNUIMessage({
        action = "hide"
    })
end)

RegisterCommand('+leaveFFA', function()
    if inFFA then
        TriggerServerEvent("ffa:sunucu:ayril")
    end
end, false)

RegisterCommand('-leaveFFA', function() end, false)

RegisterKeyMapping('+leaveFFA', 'FFA\'dan Ayrıl', 'keyboard', 'F9')

RegisterCommand('+healffa', function()
    if not inFFA then return end
    if IsPedDeadOrDying(PlayerPedId(), 1) then return end
    
    QBCore.Functions.Progressbar("heal_ffa", "Can yenileniyor...", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mp_suicide",
        anim = "pill",
        flags = 49,
    }, {}, {}, function()
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        SetEntityHealth(ped, 200)
        QBCore.Functions.Notify('Canın yenilendi!', 'success')
    end, function()
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        QBCore.Functions.Notify('İptal edildi!', 'error')
    end)
end)

RegisterCommand('+armorffa', function()
    if not inFFA then return end
    if IsPedDeadOrDying(PlayerPedId(), 1) then return end
    
    QBCore.Functions.Progressbar("armor_ffa", "Zırh yenileniyor...", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "clothingshirt",
        anim = "try_shirt_positive_d",
        flags = 49,
    }, {}, {}, function()
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        SetPedArmour(ped, 100)
        QBCore.Functions.Notify('Zırhın yenilendi!', 'success')
    end, function()
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        QBCore.Functions.Notify('İptal edildi!', 'error')
    end)
end)

RegisterKeyMapping('+healffa', 'FFA Can Yenile', 'keyboard', '3')
RegisterKeyMapping('+armorffa', 'FFA Zırh Yenile', 'keyboard', '4')

exports('IsPlayerInFFA', function()
    return inFFA
end)
