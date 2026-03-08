# ab-handling

A free, standalone real-time vehicle handling editor for FiveM by **Ayebye Development**.

## Features

- **No restrictions** - Full slider ranges based on what GTA V actually supports
- **Live preview** - See changes in real-time as you adjust values
- **Categories** - Engine, brakes, traction, suspension, and damage
- **Export** - Generates complete handling.meta XML you can copy/paste
- **Presets** - Save and load your favorite handling configurations
- **Permission system** - Lock the editor behind ace permissions
- **Standalone** - Works on all frameworks (QBCore, ESX, standalone)
- **0.00ms idle** - Zero performance impact when the editor is closed

## Installation

1. Download and place in your `resources` folder as `ab-handling`
2. Add `ensure ab-handling` to your `server.cfg`
3. Grant permissions to admins (see below)

## Permissions

The editor uses FiveM's ace permission system. Add these lines to your `server.cfg`:

```cfg
# Grant to a specific player via license
add_ace identifier.license:xxxxxxxxxxxxxxx command.handling allow

# Grant to a specific player via steam
add_ace identifier.steam:xxxxxxxxxxxxxxx command.handling allow

# Grant to a group (if using a framework)
add_ace group.admin command.handling allow
add_ace group.developer command.handling allow

# Grant to everyone (dev server only!)
add_ace builtin.everyone command.handling allow
```

## Usage

1. Get into a vehicle
2. Type `/handling` in chat
3. Adjust values with sliders or input fields
4. Click "Export" to get handling.meta XML
5. Copy the XML and paste it into your handling.meta file
6. Press ESC or click X to close

## Config

Edit `config.lua` to customize:

```lua
Config.Command = 'handling'        -- Command to open the editor
Config.Permission = true           -- Restrict to ace (command.handling), false = everyone
Config.CloseKey = 177              -- Alternative close key control ID (false = disable)
Config.ChatNotify = true           -- Show chat notifications
Config.Locale = { ... }           -- Change notification messages
```

## Handling Categories

| Category   | Description                           |
|------------|---------------------------------------|
| Engine     | Acceleration, top speed, gears        |
| Brakes     | Brake force, handbrake, steering      |
| Traction   | Grip, traction loss, lateral          |
| Suspension | Suspension, anti-roll, ride height    |
| Damage     | Collision, weapon, deformation        |

## Credits

Made by **Ayebye Development** - Join our Discord for more free scripts!
