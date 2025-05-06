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
            PRIMARY KEY (`id`)
            )]],
        }

        -- Create table if needed
        MySQL.transaction.await(createTable, nil)
    end
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
        TriggerClientEvent("postVehicles", src, ownedVehicles, trustedVehicles)
    end
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