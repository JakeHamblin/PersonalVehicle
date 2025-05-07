_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")
_menuPool:Add(mainMenu)
_menuPool:ControlDisablingEnabled(false)
_menuPool:MouseControlsEnabled(false)

-- Create submenus
local ownedVehiclesMenus = nil
local trustedVehiclesMenus = nil
_menuPool:RefreshIndex()

-- Vehicle checking
local restrictedVehicles = {}
local allowedVehicles = {}
local lastVehicleChecked = nil
TriggerServerEvent('Hamblin:updateRestrictedVehicles')

-- Create command to open menu
RegisterCommand(Config.OpenMenuCommand, function(source, args, rawCommands)
    TriggerServerEvent('Hamblin:getVehicles')
    mainMenu:Visible(true)
    _menuPool:ProcessMenus()
end, false)

-- Update restricted vehicles on database change
RegisterNetEvent('Hamblin:updateRestrictedVehicles')
AddEventHandler('Hamblin:updateRestrictedVehicles', function(vehicles)
    restrictedVehicles = vehicles
end)

-- Get vehicles that user is allowed to use
RegisterNetEvent('Hamblin:postVehicles')
AddEventHandler('Hamblin:postVehicles', function(ownedVehiclesMenusRet, trustedVehiclesMenusRet)
    -- Get current vehicle menu state
    local showMenu = mainMenu:Visible()

    -- Close all menus
    _menuPool:CloseAllMenus()
    _menuPool:RefreshIndex()
    _menuPool:ProcessMenus()

    -- Create new menu
    mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")

    -- Add menu to pool
    _menuPool:Add(mainMenu)

    -- Add new menus
    ownedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
    trustedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)

    lastVehicleChecked = nil
    allowedVehicles = {}
    
    -- Loop through all owned vehicles
    for _, v in pairs(ownedVehiclesMenusRet) do
        -- Add vehicle to allowed table
        table.insert(allowedVehicles, v['spawncode'])

        -- Add new submenu for owned vehicle
        local ownerMenu = _menuPool:AddSubMenu(ownedVehiclesMenus, v['name'], "", true)

        -- Create spawn button
        local spawnVehicle = NativeUI.CreateItem("Spawn Vehicle", '')
        ownerMenu:AddItem(spawnVehicle)
        spawnVehicle:RightLabel(v['spawncode'])

        -- When spawn clicked
        spawnVehicle.Activated = function(parentMenu, selectedItem)
            -- Spawn Vehicle
            SpawnVehicle(v['spawncode'])
        end

        -- Create trust button
        local trustVehicle = NativeUI.CreateItem("Trust Vehicle", '')
        ownerMenu:AddItem(trustVehicle)
        trustVehicle:RightLabel('')

        -- When vehicle trust clicked
        trustVehicle.Activated = function(parentMenu, selectedItem)
            -- Input from user
            local result = GetUserInput("Please enter a Discord ID to trust the vehicle to:")

            -- If result isn't nil, is a string, contains only digits, and is 17 or more digits
            if result and type(result) == "string" and result:match("^%d+$") and #result >= 17 then
                -- Trigger server event to trust vehicle to user
                TriggerServerEvent('Hamblin:trustVehicle', result, v['name'], v['spawncode'])
            end
        end

        -- Create untrust button
        local untrustVehicle = NativeUI.CreateItem("Untrust Vehicle", '')
        ownerMenu:AddItem(untrustVehicle)
        untrustVehicle:RightLabel('')

        -- When vehicle trust clicked
        untrustVehicle.Activated = function(parentMenu, selectedItem)
            -- Input from user
            local result = GetUserInput("Please enter a Discord ID to untrust from the vehicle:")

            -- If result isn't nil, is a string, contains only digits, and is 17 or more digits
            if result and type(result) == "string" and result:match("^%d+$") and #result >= 17 then
                -- Trigger server event to trust vehicle to user
                TriggerServerEvent('Hamblin:untrustVehicle', result, v['spawncode'])
            end
        end
    end

    -- Loop through all trusted vehicles
    for _, v in pairs(trustedVehiclesMenusRet) do
        -- Add vehicle to allowed table
        table.insert(allowedVehicles, v['spawncode'])

        -- Create spawn button
        local spawnVehicle = NativeUI.CreateItem("Spawn Vehicle", '')
        trustedVehiclesMenus:AddItem(spawnVehicle)
        spawnVehicle:RightLabel(v['spawncode'])

        -- When spawn click
        spawnVehicle.Activated = function(parentMenu, selectedItem)
            -- Spawn vehicle
            SpawnVehicle(v['spawncode'])
        end
    end

    -- Update menu
    _menuPool:ControlDisablingEnabled(false)
    _menuPool:MouseControlsEnabled(false)
    _menuPool:RefreshIndex()
    _menuPool:ProcessMenus()

    -- Show menu
    mainMenu:Visible(showMenu)
end)

-- Show chat message from trust event
RegisterNetEvent('Hamblin:trustActionStatus')
AddEventHandler('Hamblin:trustActionStatus', function(type, success)
    if success then
        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {0, 0, 0},
            args = {'[Personal Vehicle]', 'User has been '..type..'ed'},
        })
    else
        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {0, 0, 0},
            args = {'[Personal Vehicle]', 'Error while '..type..'ing user'},
        })
    end
end)

-- Add chat suggestion and process menus
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.OpenMenuCommand, 'Toggle Personal Vehicle Menu')
    TriggerEvent('chat:addSuggestion', '/' .. Config.SetVehicleOwnerCommand, 'Toggle Personal Vehicle Menu', {
        {name = "Discord ID", help = "Discord ID to add personal vehicle to"},
        {name = "Spawncode", help = "Spawn code of personal vehicle to add"},
        {name = "Vehicle Name", help = "Name of personal vehicle to add"}
    })
    TriggerServerEvent('Hamblin:getVehicles')
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

-- Check for restricted vehicle usage
Citizen.CreateThread(function()
    while true do
        -- Get player ped
        local ped = GetPlayerPed(-1)

        -- Delay to prevent accidental delete
        Citizen.Wait(1000)
        
        -- See if ped is in a vehicle
        if IsPedInAnyVehicle(ped, false) then
            -- Get vehicle they are in
            local vehicle = GetVehiclePedIsUsing(ped)

            -- If ped is in driver seat and vehicle has not previously been approved
            if GetPedInVehicleSeat(vehicle, -1) == ped and lastVehicleChecked ~= GetEntityModel(vehicle) then
                -- Set variable for determining if needed to be deleted
                local allowed = true

                -- Loop through all restricted vehicles
                for _, v in pairs(restrictedVehicles) do
                    -- If vehicle is restricted
                    if GetHashKey(v) == GetEntityModel(vehicle) then
                        print("Found restricted vehicle")
                        -- Default allowed to false
                        allowed = false
                        
                        -- Loop through allowed vehicles
                        for _, i in pairs(allowedVehicles) do
                            -- If vehicle is allowed, add override
                            if GetHashKey(i) == GetEntityModel(vehicle) then
                                print("Gave override")
                                allowed = true
                                lastVehicleChecked = GetEntityModel(vehicle)
                            end
                        end
                    end
                end
                
                if not allowed then
                    -- Take control of vehicle
                    SetEntityAsMissionEntity(vehicle, true, true)
                    
                    DeleteVehicle(vehicle)
                end
            end
        end
    end
end)

-- Create keymapping for predefined button
-- NOTE: This mapping can be changed by the user via their keybinds
RegisterKeyMapping(Config.OpenMenuCommand, 'Personal Vehicle Menu', 'keyboard', Config.Button)