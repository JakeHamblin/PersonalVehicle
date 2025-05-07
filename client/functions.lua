-- Credit to Sc0ttM from SEM for the general function usage
-- Also, for the love of god, please document your code
-- and follow proper naming conventions for local variables

function SpawnVehicle(vehicleName)
    -- Get player ped
    local ped = GetPlayerPed(-1)

    -- Check if ped exists and is not dead
    if (DoesEntityExist(ped) and not IsEntityDead(ped)) then 
        -- See if ped is sitting in a vehicle
        if (IsPedSittingInAnyVehicle(ped)) then 
            -- Get vehicle ped is in
            local vehicle = GetVehiclePedIsIn(ped, false)

            -- See if ped is in driver seat
            if (GetPedInVehicleSeat(vehicle, -1) == ped) then 
                -- Take control of entity
                SetEntityAsMissionEntity(vehicle, true, true)

                -- Delete vehicle
                DeleteVehicle(vehicle)
            end
        end
    end

    -- Time variables for time spent waiting
    local waitTime = 0

    -- Get has of model
    local model = GetHashKey(vehicleName)

    -- Load model
    RequestModel(model)

    -- While not loaded
    while not HasModelLoaded(model) do
        -- Cancel load
        CancelEvent()

        -- Load model again
        RequestModel(model)

        -- Wait 100ms
        Citizen.Wait(100)

        -- Increment wait time
        waitTime = waitTime + 1

        -- If wait time greater than 600, cancel and return
        if waitTime > 600 then
            CancelEvent()
            return
        end
    end

    -- Get player coords
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))

    -- Create vehicle
    local vehicle = CreateVehicle(model, x + 2, y + 2, z + 1, GetEntityHeading(PlayerPedId()), true, false)

    -- Put ped into drivers seat
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

    -- Clean dirt
    SetVehicleDirtLevel(vehicle, 0)

    -- Initial modkits
    SetVehicleModKit(vehicle, 0)

    -- Set wheels as default model
    SetVehicleMod(vehicle, 23, -1, false)

    -- Remove model from loaded cache
    SetModelAsNoLongerNeeded(model)
end

function DeleteVehicle(entity)
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized(entity))
end

-- Get user input from prompt
function GetUserInput(text)
    -- Input from user
    local result = nil
        
    -- Add a text entry for text area label
    AddTextEntry("user_input", text)

    -- Display text area
    DisplayOnscreenKeyboard(1, "user_input", "", "", "", "", "", 256 + 1)

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

    return result
end