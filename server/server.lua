local ratelimit = -1

-- Event handler for database creation
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Create table insert
        local createTable = {
            [[CREATE TABLE IF NOT EXISTS `hamblin_vehicles` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `discordID` varchar(255) NOT NULL,
            `owner` tinyint(1) NOT NULL COMMENT '0 = trusted, 1 = owner',
            `name` varchar(255) NOT NULL,
            `spawncode` varchar(255) NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY unique_user_entry (discordID, owner, spawncode)
            )]],
        }

        -- Create table if needed
        MySQL.transaction.await(createTable, nil)
    end
end)

-- Event to update restricted vehicles for all users on database changes
RegisterNetEvent('updateRestrictedVehicles')
AddEventHandler('updateRestrictedVehicles', function()
    -- Create table for restricted vehicles
    local restrictedVehicles = {}

    -- Get all vehicles in database that are restricted
    local response = MySQL.query.await('SELECT `spawncode` FROM `hamblin_vehicles` WHERE owner = 1')
    if response then
        for i = 1, #response do
            table.insert(restrictedVehicles, response[i].spawncode)
        end
    end

    -- Send updated list to all clients
    TriggerClientEvent("updateRestrictedVehicles", -1, restrictedVehicles)
end)

-- Event to get allowed and trusted vehicles
RegisterNetEvent('getVehicles')
AddEventHandler('getVehicles', function()
    if (ratelimit + 60000) < GetGameTimer() or ratelimit == -1 then
        -- Update rate limit
        ratelimit = GetGameTimer()

        -- Retain triggering user
        local src = source

        -- Initalize return tables
        local ownedVehicles = {}
        local trustedVehicles = {}
        
        -- Get Discord ID
        local discordID = GetIdentifier(src, "discord"):gsub("discord:", "")

        -- Get all vehicles assigned to Discord ID
        local response = MySQL.query.await('SELECT `owner`, `name`, `spawncode` FROM `hamblin_vehicles` WHERE `discordID` = ?', {discordID})
        if response then
            for i = 1, #response do
                -- If user is owner, add to owned vehicles
                if response[i].owner then
                    table.insert(ownedVehicles, {name = response[i].name, spawncode = response[i].spawncode})
                -- If user is trusted, add to trusted vehicles
                else
                    table.insert(trustedVehicles, {name = response[i].name, spawncode = response[i].spawncode})
                end
            end
        end

        -- Return vehicles to client
        TriggerClientEvent('postVehicles', src, ownedVehicles, trustedVehicles)
    end
end)

RegisterNetEvent('trustVehicle')
AddEventHandler('trustVehicle', function(discordID, name, spawncode)
    -- Save source
    local src = source
    local triggeringDiscordID = GetIdentifier(src, "discord"):gsub("discord:", "")

    -- Check if triggering user is owner
    local response = MySQL.query.await('SELECT COUNT(*) AS count FROM `hamblin_vehicles` WHERE discordID = ? AND owner = 1 AND spawncode = ?', {triggeringDiscordID, spawncode})

    -- Response valid and count is 1 or greater
    if response and response[1].count >= 1 then
        -- Insert into database
        local id = MySQL.insert.await('INSERT INTO `hamblin_vehicles` (discordID, owner, name, spawncode) VALUES (?, 0, ?, ?) ON DUPLICATE KEY UPDATE discordID = discordID', {discordID, name, spawncode})

        -- Check if insert successful
        if id then
            TriggerClientEvent('trustVehicle', src, true)
        else
            TriggerClientEvent('trustVehicle', src, false)
        end
    else
        TriggerClientEvent('trustVehicle', src, false)
    end

    TriggerServerEvent('updateRestrictedVehicles')
end)

-- Get's specified identifier from player
function GetIdentifier(src, identifier)
	local identifiers = GetPlayerIdentifiers(src)

	for k,v in pairs(identifiers) do
		if string.sub(v, 1, string.len(identifier..":")) == identifier..":" then
			return v
		end
	end
end