# nullement ui library
> a clean, lightweight roblox lua ui library — nullement style

![version](https://img.shields.io/badge/version-1.0-7c3aed?style=flat-square)
![platform](https://img.shields.io/badge/platform-roblox-7c3aed?style=flat-square)
![executor](https://img.shields.io/badge/executor-xeno%20%2F%20synapse%20%2F%20fluxus-7c3aed?style=flat-square)

---

## loading

```lua
local Null = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/nullement_lib.lua"
))()
```

---

## quick start

```lua
local Null = loadstring(game:HttpGet("YOUR_RAW_URL"))()

-- create window
local win = Null:Window({
    title    = "my hub",
    subtitle = "v1.0",
    key      = Enum.KeyCode.RightShift,  -- toggle minimize
})

-- create tab
local tab = win:Tab("AIMBOT", "🎯")

-- add components
tab:Toggle("Silent Aim", "locks onto target silently", false, function(v)
    print("silent aim:", v)
end)

tab:Slider("FOV", 10, 360, 90, function(v)
    print("fov:", v)
end, "°")

tab:Button("Teleport", "teleport to spawn", function()
    print("button clicked")
end)
```

---

## window options

```lua
local win = Null:Window({
    title     = "my hub",      -- window title (also used as gui name)
    subtitle  = "v1.0",        -- small text below title in sidebar
    key       = Enum.KeyCode.RightShift,  -- key to toggle minimize
    width     = 540,           -- window width  (default: 540)
    height    = 500,           -- window height (default: 500)
    sideWidth = 108,           -- sidebar width (default: 108)
})
```

---

## tabs

```lua
local tab = win:Tab("TAB NAME", "icon")
-- icon can be any emoji or text character
-- examples: "🎯" "👁" "⚡" "🛡" "📊" "⚙" "🔧"
```

---

## components

### toggle
```lua
local ctrl = tab:Toggle(
    "Feature Name",        -- label
    "short description",   -- subtitle text
    false,                 -- default value (true/false)
    function(value)        -- callback
        print(value)       -- true or false
    end
)

ctrl:Set(true)   -- set value programmatically
ctrl:Get()       -- get current value
```

---

### slider
```lua
local ctrl = tab:Slider(
    "Walk Speed",    -- label
    16,              -- min value
    100,             -- max value
    50,              -- default value
    function(value)  -- callback
        print(value)
    end,
    " studs"         -- optional suffix (shown after value)
)

ctrl:Set(75)   -- set value
ctrl:Get()     -- get current value
```

---

### button
```lua
tab:Button(
    "Button Label",         -- label
    "optional description", -- subtitle (pass nil to hide)
    function()              -- callback
        print("clicked")
    end,
    Color3.fromRGB(140, 60, 255)  -- optional custom color
)
```

---

### dropdown
```lua
local ctrl = tab:Dropdown(
    "Target Part",                    -- label
    {"Head", "HumanoidRootPart", "Torso"},  -- options list
    "Head",                           -- default selection
    function(value)                   -- callback
        print("selected:", value)
    end
)

ctrl:Set("Torso")   -- set selected option
ctrl:Get()          -- get current selection
```

---

### keybind
```lua
local ctrl = tab:Keybind(
    "Toggle Key",          -- label
    Enum.KeyCode.Q,        -- default key
    function(key)          -- callback (fires when new key is set)
        print("new key:", key)
    end
)

ctrl:Get()                    -- get current KeyCode
ctrl:Set(Enum.KeyCode.E)      -- set key programmatically
```

---

### input (textbox)
```lua
local ctrl = tab:Input(
    "Player Name",      -- label
    "enter name...",    -- placeholder text
    function(text, pressedEnter)  -- callback (fires on focus lost)
        print("input:", text)
        print("pressed enter:", pressedEnter)
    end
)

ctrl:Get()           -- get current text
ctrl:Set("Roblox")   -- set text
```

---

### separator
```lua
tab:Separator("SECTION TITLE")
-- creates a labeled divider line between components
```

---

### label
```lua
tab:Label("some info text", "dim")
-- styles: "normal" | "dim" | "accent" | "success" | "danger" | "warn"
```

---

### color display
```lua
local ctrl = tab:ColorDisplay(
    "ESP Color",
    Color3.fromRGB(140, 60, 255)  -- color to preview
)

ctrl:Set(Color3.fromRGB(255, 100, 100))  -- update preview color
```

---

### progress bar
```lua
local ctrl = tab:Progress(
    "Health",   -- label
    100         -- default value (0-100)
)

ctrl:Set(75)   -- update value (auto colors: green > 60, yellow > 30, red <= 30)
ctrl:Get()     -- get current value
```

---

## toast notifications

```lua
-- from window
win.Toast("message", "icon", Color3.fromRGB(140, 60, 255), 2)

-- global (no window needed)
Null.Toast("saved!", "✅", Color3.fromRGB(55, 215, 90), 2)

-- arguments: msg, icon, color, duration(seconds)
```

---

## full example

```lua
local Null = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local win = Null:Window({
    title    = "nullhub",
    subtitle = "v1.0",
    key      = Enum.KeyCode.RightShift,
})

-- ── AIMBOT TAB ──────────────────────────────────────
local aim = win:Tab("AIMBOT", "🎯")

aim:Separator("TARGETING")

local silentAim = aim:Toggle("Silent Aim", "snaps to target on click", false, function(v)
    -- your code
end)

local fovSlider = aim:Slider("FOV", 10, 360, 90, function(v)
    -- your code
end, "°")

aim:Dropdown("Target Part", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v)
    -- your code
end)

aim:Separator("KEYBINDS")

aim:Keybind("Aim Key", Enum.KeyCode.Q, function(k)
    -- your code
end)

-- ── ESP TAB ─────────────────────────────────────────
local esp = win:Tab("ESP", "👁")

esp:Separator("VISUALS")

esp:Toggle("Enabled", "show player highlights", false, function(v)
    -- your code
end)

esp:Toggle("Tracers", "lines to each player", false, function(v)
    -- your code
end)

esp:Slider("Max Distance", 50, 1000, 300, function(v)
    -- your code
end, " st")

-- ── SETTINGS TAB ────────────────────────────────────
local set = win:Tab("SETTINGS", "⚙")

set:Separator("GENERAL")

set:Button("Save Config", "saves current settings", function()
    Null.Toast("config saved!", "✅", Color3.fromRGB(55, 215, 90), 2)
end)

set:Button("Reset Config", "resets everything to default", function()
    silentAim:Set(false)
    fovSlider:Set(90)
    Null.Toast("config reset", "🔄", Color3.fromRGB(140, 60, 255), 2)
end, Color3.fromRGB(225, 55, 55))
```

---

## theme colors

| name    | rgb                  | use                        |
|---------|----------------------|----------------------------|
| BG      | `8, 5, 16`           | main window background     |
| SURFACE | `15, 10, 26`         | sidebar + component cards  |
| CARD    | `20, 13, 34`         | inputs + toggle track      |
| BORDER  | `65, 30, 115`        | strokes + dividers         |
| ACCENT  | `140, 60, 255`       | active states + highlights |
| ACCENTL | `185, 115, 255`      | lighter accent details     |
| TEXT    | `225, 205, 255`      | primary labels             |
| DIM     | `105, 80, 148`       | secondary / subtitle text  |

---

## compatibility

| executor | status |
|----------|--------|
| Xeno     | ✅     |
| Synapse X| ✅     |
| Fluxus   | ✅     |
| KRNL     | ✅     |
| Script-Ware | ✅  |

---

## notes

- works on both **desktop** and **mobile** (☰ button shown when minimized on mobile)
- drag window by grabbing the **sidebar**
- press your toggle key (default `RightShift`) to minimize/restore
- all controls return a `ctrl` object with `:Get()` and `:Set()` methods
- `tab:Dropdown` opens inline, no overlapping frames

---

*made by nullement*
