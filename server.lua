-- Special thanks to Woopi for documenting usage of JSON with FiveM
local ratelimit = -1

-- Event to get allowed and trusted vehicles
RegisterNetEvent('getVehicles')
AddEventHandler('getVehicles', function(name, score)
    if (ratelimit + 60000) < GetGameTimer() or ratelimit == -1 then
        -- Update rate limit
        ratelimit = GetGameTimer()
        
        -- Get Discord ID
        local discordID = GetIdentifier(source, "discord"):gsub("discord:", "")

        -- Load file
        local loadFile = LoadResourceFile(GetCurrentResourceName(), "./vehicles.json")
        local extract = json.decode(loadFile)
        local ownedVehicles = {}
        local trustedVehicles = {}

        -- Loop through owned vehicles
        for k,v in pairs(extract['owned']) do
            -- Find matches
            if v['discord'] == discordID then
                ownedVehicles[#ownedVehicles] = {name = v['name'], spawncode = v['spawncode']}
            end
        end

        -- Loop through trusted vehicles
        for k,v in pairs(extract['trusted']) do
            -- Find matches
            if v['discord'] == discordID then
                trustedVehicles[#trustedVehicles] = {name = v['name'], spawncode = v['spawncode']}
            end
        end

        -- Return vehicles to client
        TriggerClientEvent("postVehicles", source, ownedVehicles, trustedVehicles)
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