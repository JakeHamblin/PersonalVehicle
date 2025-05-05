-- https://github.com/Sc0ttM/SEM_InteractionMenu/blob/master/menu.lua

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
end)

RegisterNetEvent("postVehicles")
AddEventHandler("postVehicles", function(ownedVehiclesRet, trustedVehiclesRet)
    -- Create new mnu
    mainMenu = NativeUI.CreateMenu("Personal Vehicle", "Spawn your personal vehicles")

    -- Add menu to pool
    _menuPool:Add(mainMenu)

    -- Add new menus
    ownedVehicles = _menuPool:AddSubMenu(mainMenu, "Owned Vehicles", "All of the vehicles you own", true)
    trustedVehicles = _menuPool:AddSubMenu(mainMenu, "Trusted Vehicles", "All of the vehicles you are trusted to", true)

    -- Update menu
    _menuPool:ControlDisablingEnabled(false)
    _menuPool:MouseControlsEnabled(false)
    _menuPool:RefreshIndex()
    _menuPool:ProcessMenus()
    
    -- Loop through all owned vehicles
    for k, v in pairs(ownedVehiclesRet) do
        local createdVehicle = NativeUI.CreateItem(v['name'], '')
        ownedVehicles:AddItem(createdVehicle)
        createdVehicle:RightLabel(v['spawncode'])

        createdVehicle.Activated = function(ParentMenu, SelectedItem)
            SpawnVehicle(v['spawncode'])
        end
    end

    for k, v in pairs(trustedVehicles) do
    end

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