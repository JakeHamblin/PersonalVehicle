_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")
_menuPool:Add(mainMenu)
_menuPool:ControlDisablingEnabled(false)
_menuPool:MouseControlsEnabled(false)

-- Create submenus
local ownedVehicles = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
local trustedVehicles = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)
_menuPool:RefreshIndex()

-- Create command to open menu
RegisterCommand(Config.Command, function(source, args, rawCommands)
    TriggerServerEvent('getVehicles')
    mainMenu:Visible(not mainMenu:Visible())
end, false)

RegisterNetEvent("postVehicles")
AddEventHandler("postVehicles", function(ownedVehiclesRet, trustedVehiclesRet)
    -- Create new mnu
    mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")

    -- Add menu to pool
    _menuPool:Add(mainMenu)

    -- Add new menus
    ownedVehicles = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
    trustedVehicles = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)
    
    -- Loop through all owned vehicles
    for _, v in pairs(ownedVehiclesRet) do
        -- Add new submenu for owned vehicle
        local ownerMenu = _menuPool:AddSubMenu(ownedVehicles, v['name'], "", true)

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

            print(result)
        end
    end

    -- Loop through all trusted vehicles
    for _, v in pairs(trustedVehicles) do
        -- Create spawn button
        local spawnVehicle = NativeUI.CreateItem("Spawn Vehicle", '')
        trustedVehicles:AddItem(spawnVehicle)
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

-- Add chat suggestion and process menus
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Toggle Personal Vehicle Menu')
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

-- Create keymapping for predefined button
-- NOTE: This mapping can be changed by the user via their keybinds
RegisterKeyMapping(Config.Command, 'Personal Vehicle Menu', 'keyboard', Config.Button)