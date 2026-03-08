-- Register command server-side with proper admin check
RegisterCommand(Config.Command, function(source)
    local src = source
    if src == 0 then return end

    if Config.Permission and not IsPlayerAceAllowed(src, 'command') then
        return
    end

    TriggerClientEvent('ab-handling:toggle', src)
end, false)

-- Log when a player opens the handling editor
RegisterNetEvent('ab-handling:log', function(vehicleName)
    local src = source
    print(('[ab-handling] %s (ID: %s) opened editor on %s'):format(GetPlayerName(src), src, vehicleName))
end)
