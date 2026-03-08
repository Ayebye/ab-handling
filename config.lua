Config = {}

-- Command to open the handling editor
Config.Command = 'handling'

-- Restrict command to admins only (true/false)
-- When true, only players with admin permissions can use the editor
-- Set to false to allow everyone
Config.Permission = true

-- Alternative close key (alongside ESC)
-- Uses FiveM control IDs: https://docs.fivem.net/docs/game-references/controls/
-- Set to false to disable
Config.CloseKey = 177 -- Backspace / Phone Cancel

-- Chat notification settings
Config.ChatNotify = true

-- Locale strings (change these to your language if needed)
Config.Locale = {
    not_in_vehicle = 'You must be in a vehicle.',
}
