_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")
_menuPool:Add(mainMenu)
_menuPool:ControlDisablingEnabled(false)
_menuPool:MouseControlsEnabled(false)

-- Create submenus
local ownedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
local trustedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)
_menuPool:RefreshIndex()

-- Vehicle checking
local restrictedVehicles = {}
local allowedVehicles = {}
local lastVehicleChecked = nil
TriggerServerEvent('updateRestrictedVehicles')

-- Create command to open menu
RegisterCommand(Config.Command, function(source, args, rawCommands)
    TriggerServerEvent('getVehicles')
    mainMenu:Visible(not mainMenu:Visible())
end, false)

RegisterNetEvent('updateRestrictedVehicles')
AddEventHandler('updateRestrictedVehicles', function(vehicles)
    restrictedVehicles = vehicles
end)

RegisterNetEvent('postVehicles')
AddEventHandler('postVehicles', function(ownedVehiclesMenusRet, trustedVehiclesMenusRet)
    -- Create new mnu
    mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")

    -- Add menu to pool
    _menuPool:Add(mainMenu)

    -- Add new menus
    ownedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
    trustedVehiclesMenus = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)

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
            local result = nil
            
            -- Add a text entry for text area label
            AddTextEntry("discord_id_select", "Please enter a Discord ID to trust the vehicle to:")

            -- Display text area
            DisplayOnscreenKeyboard(1, "discord_id_select", "", "", "", "", "", 256 + 1)

            -- While text area is still open
            while(UpdateOnscreenKeyboard() == 0) do
                DisableAllControlActions(0);
                Wait(0);
            end

            -- If result is not nil
            if(GetOnscreenKeyboardResult()) then
                -- Place result into result
                result = GetOnscreenKeyboardResult()
            end

            -- If result isn't nil, is a string, contains only digits, and is 17 or more digits
            if result and type(result) == "string" and result:match("^%d+$") and #result >= 17 then
                -- Convert user input to integer
                local discordID = tonumber(result)

                -- Trigger server event to trust vehicle to user
                TriggerServerEvent('trustVehicle', discordID, v['name'], v['spawncode'])
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
    mainMenu:Visible(not mainMenu:Visible())
end)

RegisterNetEvent('trustVehicle')
AddEventHandler('trustVehicle', function(success)
    if success then
        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {0, 0, 0},
            args = {'Personal Vehicle', 'User has been trusted'},
        })
    else
        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {0, 0, 0},
            args = {'Personal Vehicle', 'Error while trusting user'},
        })
    end
end)

-- Add chat suggestion and process menus
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Toggle Personal Vehicle Menu')
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()

        -- Get player ped
        local ped = GetPlayerPed(-1)
        
        -- See if ped is in a vehicle
        if IsPedInAnyVehicle(ped, false) then
            -- Get vehicle they are in
            local vehicle = GetVehiclePedIsUsing(ped)

            -- Set variable for determining if needed to be deleted
            local allowed = false

            -- If ped is in driver seat and vehicle has not previously been approved
            if GetPedInVehicleSeat(vehicle, -1) == ped and lastVehicleChecked ~= GetEntityModel(vehicle) then
                for _, v in pairs(restrictedVehicles) do
                    if GetHashKey(v) == GetEntityModel(vehicle) then
                        for _, i in pairs(allowedVehicles) do
                            if GetHashKey(i) == GetEntityModel(vehicle) then
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
RegisterKeyMapping(Config.Command, 'Personal Vehicle Menu', 'keyboard', Config.Button)