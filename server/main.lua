-- Log when a player opens the handling editor
RegisterNetEvent('ab-handling:log', function(vehicleName)
    local src = source
    print(('[ab-handling] %s (ID: %s) opened editor on %s'):format(GetPlayerName(src), src, vehicleName))
end)
