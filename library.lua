--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║              nullement  ui  library                       ║
    ║              v1.0  —  loadstring edition                  ║
    ╠═══════════════════════════════════════════════════════════╣
    ║  USAGE:                                                   ║
    ║                                                           ║
    ║  local Null = loadstring(game:HttpGet(                    ║
    ║    "https://raw.githubusercontent.com/YOUR/REPO/         ║
    ║     main/nullement_lib.lua"))()                           ║
    ║                                                           ║
    ║  local win = Null:Window({                                ║
    ║      title   = "my hub",                                  ║
    ║      subtitle = "v1.0",                                   ║
    ║      key     = Enum.KeyCode.RightShift, -- toggle key     ║
    ║  })                                                       ║
    ║                                                           ║
    ║  local tab = win:Tab("AIMBOT", "🎯")                     ║
    ║                                                           ║
    ║  tab:Toggle("Silent Aim", "fires without aiming", false,  ║
    ║      function(v) print(v) end)                            ║
    ║                                                           ║
    ║  tab:Slider("FOV", 10, 360, 90,                          ║
    ║      function(v) print(v) end)                            ║
    ║                                                           ║
    ║  tab:Button("Teleport", "tp to spawn",                   ║
    ║      function() print("clicked") end)                     ║
    ║                                                           ║
    ║  tab:Dropdown("Target Part", {"Head","HRP","Torso"}, "Head",║
    ║      function(v) print(v) end)                            ║
    ║                                                           ║
    ║  tab:Keybind("Aimbot Key", Enum.KeyCode.Q,               ║
    ║      function(key) print(key) end)                        ║
    ║                                                           ║
    ║  tab:Input("Player Name", "enter name...",               ║
    ║      function(v) print(v) end)                            ║
    ║                                                           ║
    ║  tab:Label("some info text", "dim")                       ║
    ║  tab:Separator("SECTION TITLE")                           ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local LP = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════════════════════════
local T = {
    BG      = Color3.fromRGB(8,    5,  16),
    SURFACE = Color3.fromRGB(15,  10,  26),
    CARD    = Color3.fromRGB(20,  13,  34),
    BORDER  = Color3.fromRGB(65,  30, 115),
    ACCENT  = Color3.fromRGB(140,  60, 255),
    ACCENTL = Color3.fromRGB(185, 115, 255),
    TEXT    = Color3.fromRGB(225, 205, 255),
    DIM     = Color3.fromRGB(105,  80, 148),
    WHITE   = Color3.fromRGB(255, 255, 255),
    RED     = Color3.fromRGB(225,  55,  55),
    GREEN   = Color3.fromRGB(55,  215,  90),
    YELLOW  = Color3.fromRGB(255, 210,  50),
    BLACK   = Color3.fromRGB(0,    0,   0),
}

-- ════════════════════════════════════════════════════════════
--  INTERNAL HELPERS
-- ════════════════════════════════════════════════════════════
local function tween(obj, props, t_, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj,
        TweenInfo.new(t_ or 0.18,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out),
        props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color     = col   or T.BORDER
    s.Thickness = thick or 1
    return s
end

local function padding(p, t_, r, b, l)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop    = UDim.new(0, t_ or 6)
    pad.PaddingRight  = UDim.new(0, r  or 6)
    pad.PaddingBottom = UDim.new(0, b  or 6)
    pad.PaddingLeft   = UDim.new(0, l  or 6)
    return pad
end

-- ════════════════════════════════════════════════════════════
--  TOAST NOTIFICATION (global)
-- ════════════════════════════════════════════════════════════
local _toastHolder = nil
local function _ensureToastHolder()
    if _toastHolder and _toastHolder.Parent then return _toastHolder end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NullToastHolder"; sg.ResetOnSpawn = false
    sg.DisplayOrder = 9999; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LP.PlayerGui end
    _toastHolder = sg
    return sg
end

local function toast(msg, icon, col, dur)
    dur = dur or 2; col = col or T.ACCENT; icon = icon or "✦"
    local holder = _ensureToastHolder()
    local t = Instance.new("Frame", holder)
    t.Size = UDim2.new(0, 0, 0, 36)
    t.Position = UDim2.new(1, -16, 1, -56)
    t.AnchorPoint = Vector2.new(1, 1)
    t.BackgroundColor3 = T.CARD
    t.BorderSizePixel = 0
    corner(t, 8); stroke(t, col, 1.5)
    local ls = Instance.new("Frame", t)
    ls.Size = UDim2.new(0, 3, 1, 0)
    ls.BackgroundColor3 = col; ls.BorderSizePixel = 0; corner(ls, 3)
    local iL = Instance.new("TextLabel", t)
    iL.Size = UDim2.new(0, 28, 1, 0); iL.Position = UDim2.new(0, 8, 0, 0)
    iL.BackgroundTransparency = 1; iL.Text = icon
    iL.Font = Enum.Font.GothamBold; iL.TextSize = 15; iL.TextColor3 = col
    local mL = Instance.new("TextLabel", t)
    mL.Position = UDim2.new(0, 38, 0, 0); mL.BackgroundTransparency = 1
    mL.Text = msg; mL.Font = Enum.Font.GothamBold; mL.TextSize = 11
    mL.TextColor3 = T.TEXT; mL.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function()
        task.wait()
        local w = math.clamp(mL.TextBounds.X + 54, 120, 320)
        mL.Size = UDim2.new(0, w - 46, 1, 0)
        tween(t, {Size = UDim2.new(0, w, 0, 36)}, 0.22, Enum.EasingStyle.Back)
        task.wait(dur)
        tween(t, {Size = UDim2.new(0, 0, 0, 36), BackgroundTransparency = 1}, 0.18)
        task.delay(0.2, function() pcall(function() t:Destroy() end) end)
    end)
end

-- ════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ════════════════════════════════════════════════════════════
local Null = {}
Null.__index = Null
Null._windows = {}

-- ════════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════════
function Null:Window(cfg)
    cfg = cfg or {}
    local title    = cfg.title    or "nullement"
    local subtitle = cfg.subtitle or "v1.0"
    local toggleKey= cfg.key      or Enum.KeyCode.RightShift
    local winW     = cfg.width    or 540
    local winH     = cfg.height   or 500
    local sideW    = cfg.sideWidth or 108

    -- kill old instance with same title
    pcall(function()
        local old = CoreGui:FindFirstChild("Null_"..title)
        if old then old:Destroy() end
    end)

    -- screen gui
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local sg = Instance.new("ScreenGui")
    sg.Name           = "Null_"..title
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LP.PlayerGui end

    -- open button (shown when minimized)
    local openBtn = Instance.new("TextButton", sg)
    openBtn.Size = UDim2.new(0, 130, 0, 34)
    openBtn.Position = UDim2.new(0.5, -65, 0, 8)
    openBtn.BackgroundColor3 = T.SURFACE
    openBtn.BorderSizePixel = 0
    openBtn.Text = ""; openBtn.ZIndex = 300
    openBtn.Visible = false; corner(openBtn, 10)
    stroke(openBtn, T.ACCENT, 1.5)
    local oBtnIcon = Instance.new("TextLabel", openBtn)
    oBtnIcon.Size = UDim2.new(0, 28, 1, 0)
    oBtnIcon.BackgroundTransparency = 1; oBtnIcon.Text = "☰"
    oBtnIcon.Font = Enum.Font.GothamBold; oBtnIcon.TextSize = 15
    oBtnIcon.TextColor3 = T.ACCENT
    local oBtnLbl = Instance.new("TextLabel", openBtn)
    oBtnLbl.Size = UDim2.new(1, -32, 1, 0); oBtnLbl.Position = UDim2.new(0, 28, 0, 0)
    oBtnLbl.BackgroundTransparency = 1; oBtnLbl.Text = title
    oBtnLbl.Font = Enum.Font.GothamBold; oBtnLbl.TextSize = 11
    oBtnLbl.TextColor3 = T.TEXT; oBtnLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- main frame
    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = T.BG
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    corner(Main, 14); stroke(Main, T.BORDER, 1.5)

    task.wait(0.1)
    tween(Main, {
        Size     = UDim2.new(0, winW, 0, winH),
        Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- drag via sidebar
    local dragging, dragStart, dragOrigin = false, nil, nil
    local isMinimized = false
    local isVisible   = true

    local function minimize()
        isMinimized = true
        tween(Main, {Size = UDim2.new(0, winW, 0, 0), BackgroundTransparency = 0.3}, 0.22)
        task.delay(0.23, function()
            Main.Visible = false
            openBtn.Visible = true
            openBtn.Size = UDim2.new(0, 0, 0, 34)
            tween(openBtn, {Size = UDim2.new(0, 130, 0, 34)}, 0.28, Enum.EasingStyle.Back)
        end)
    end

    local function restore()
        isMinimized = false
        openBtn.Visible = false
        Main.Visible = true
        Main.Size = UDim2.new(0, winW * 0.88, 0, winH * 0.88)
        Main.BackgroundTransparency = 0.5
        tween(Main, {
            Size = UDim2.new(0, winW, 0, winH),
            BackgroundTransparency = 0
        }, 0.32, Enum.EasingStyle.Back)
    end

    openBtn.MouseButton1Click:Connect(restore)

    -- toggle key
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == toggleKey then
            if isMinimized then restore() else minimize() end
        end
    end)

    -- ── SIDEBAR ──────────────────────────────────────────
    local sidebar = Instance.new("Frame", Main)
    sidebar.Size = UDim2.new(0, sideW, 1, 0)
    sidebar.BackgroundColor3 = T.SURFACE
    sidebar.BorderSizePixel = 0
    local sbBorder = Instance.new("Frame", sidebar)
    sbBorder.Size = UDim2.new(0, 1, 1, 0)
    sbBorder.Position = UDim2.new(1, -1, 0, 0)
    sbBorder.BackgroundColor3 = T.BORDER
    sbBorder.BorderSizePixel = 0

    -- drag on sidebar
    sidebar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; dragOrigin = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(
                dragOrigin.X.Scale, dragOrigin.X.Offset + d.X,
                dragOrigin.Y.Scale, dragOrigin.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- logo
    local sbStrip = Instance.new("Frame", sidebar)
    sbStrip.Size = UDim2.new(0, 3, 0, 22)
    sbStrip.Position = UDim2.new(0, 8, 0, 16)
    sbStrip.BackgroundColor3 = T.ACCENT
    sbStrip.BorderSizePixel = 0; corner(sbStrip, 2)

    local sbTitle = Instance.new("TextLabel", sidebar)
    sbTitle.Size = UDim2.new(1, -18, 0, 14)
    sbTitle.Position = UDim2.new(0, 18, 0, 13)
    sbTitle.BackgroundTransparency = 1; sbTitle.Text = title
    sbTitle.Font = Enum.Font.GothamBold; sbTitle.TextSize = 10
    sbTitle.TextColor3 = T.TEXT; sbTitle.TextXAlignment = Enum.TextXAlignment.Left

    local sbSub = Instance.new("TextLabel", sidebar)
    sbSub.Size = UDim2.new(1, -18, 0, 11)
    sbSub.Position = UDim2.new(0, 18, 0, 27)
    sbSub.BackgroundTransparency = 1; sbSub.Text = subtitle
    sbSub.Font = Enum.Font.Code; sbSub.TextSize = 9
    sbSub.TextColor3 = T.ACCENT; sbSub.TextXAlignment = Enum.TextXAlignment.Left

    local sbDiv = Instance.new("Frame", sidebar)
    sbDiv.Size = UDim2.new(1, -16, 0, 1)
    sbDiv.Position = UDim2.new(0, 8, 0, 48)
    sbDiv.BackgroundColor3 = T.BORDER; sbDiv.BorderSizePixel = 0

    -- minimize + unload buttons
    local minBtn = Instance.new("TextButton", sidebar)
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(0, 8, 1, -36)
    minBtn.BackgroundColor3 = T.CARD; minBtn.BorderSizePixel = 0
    minBtn.Text = "─"; minBtn.TextColor3 = T.DIM
    minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 11; corner(minBtn, 5)
    minBtn.MouseButton1Click:Connect(minimize)

    local closeBtn = Instance.new("TextButton", sidebar)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 1, -36)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"; closeBtn.TextColor3 = T.RED
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 11; corner(closeBtn, 5)
    stroke(closeBtn, Color3.fromRGB(100, 30, 30), 1)
    closeBtn.MouseButton1Click:Connect(function()
        tween(Main, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.22, function() sg:Destroy() end)
    end)

    -- strip pulse
    task.spawn(function()
        local t_ = 0
        while sbStrip and sbStrip.Parent do
            t_ += 0.06
            sbStrip.BackgroundColor3 = T.ACCENT:Lerp(
                Color3.fromRGB(200, 130, 255), (math.sin(t_) + 1) / 2 * 0.5)
            task.wait(0.05)
        end
    end)

    -- ── CONTENT AREA ─────────────────────────────────────
    local contentArea = Instance.new("Frame", Main)
    contentArea.Size = UDim2.new(1, -sideW, 1, 0)
    contentArea.Position = UDim2.new(0, sideW, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants = true

    -- ── TAB SYSTEM ───────────────────────────────────────
    local tabBtns  = {}
    local tabPages = {}
    local tabY     = 56    -- y offset for first tab button in sidebar
    local activeTab = nil
    local tabCount  = 0

    local function switchTab(name)
        activeTab = name
        for n, pg in pairs(tabPages) do pg.Visible = n == name end
        for n, d  in pairs(tabBtns) do
            local on = n == name
            tween(d.btn, {BackgroundColor3 = on and Color3.fromRGB(30, 15, 55) or T.BG}, 0.14)
            d.strip.Visible  = on
            d.stroke.Color   = on and T.ACCENT or T.BORDER
            d.stroke.Transparency = on and 0 or 0.6
            d.lbl.TextColor3 = on and T.TEXT or T.DIM
        end
    end

    -- ════════════════════════════════════════════════════
    --  WINDOW OBJECT (returned to user)
    -- ════════════════════════════════════════════════════
    local Win = {}
    Win._sg          = sg
    Win._main        = Main
    Win._sidebar     = sidebar
    Win._contentArea = contentArea
    Win._tabBtns     = tabBtns
    Win._tabPages    = tabPages
    Win._tabY        = tabY
    Win._sideW       = sideW

    Win.Minimize = minimize
    Win.Restore  = restore
    Win.Toast    = toast

    -- ── TAB CREATOR ──────────────────────────────────────
    function Win:Tab(name, icon)
        tabCount += 1
        icon = icon or "•"

        local yPos = tabY + (tabCount - 1) * 44

        -- sidebar button
        local btn = Instance.new("TextButton", sidebar)
        btn.Size = UDim2.new(1, -12, 0, 36)
        btn.Position = UDim2.new(0, 6, 0, yPos)
        btn.BackgroundColor3 = tabCount == 1 and Color3.fromRGB(30, 15, 55) or T.BG
        btn.BorderSizePixel = 0; btn.Text = ""; corner(btn, 7)
        local bStroke = stroke(btn, tabCount == 1 and T.ACCENT or T.BORDER, 1)
        bStroke.Transparency = tabCount == 1 and 0 or 0.6

        local bStrip = Instance.new("Frame", btn)
        bStrip.Size = UDim2.new(0, 3, 0, 16)
        bStrip.Position = UDim2.new(0, 2, 0.5, -8)
        bStrip.BackgroundColor3 = T.ACCENT
        bStrip.BorderSizePixel = 0; corner(bStrip, 2)
        bStrip.Visible = tabCount == 1

        local bIcon = Instance.new("TextLabel", btn)
        bIcon.Size = UDim2.new(0, 22, 1, 0)
        bIcon.Position = UDim2.new(0, 8, 0, 0)
        bIcon.BackgroundTransparency = 1; bIcon.Text = icon
        bIcon.Font = Enum.Font.GothamBold; bIcon.TextSize = 14
        bIcon.TextColor3 = T.TEXT

        local bLbl = Instance.new("TextLabel", btn)
        bLbl.Size = UDim2.new(1, -32, 1, 0)
        bLbl.Position = UDim2.new(0, 30, 0, 0)
        bLbl.BackgroundTransparency = 1; bLbl.Text = name
        bLbl.Font = Enum.Font.GothamBold; bLbl.TextSize = 9
        bLbl.TextColor3 = tabCount == 1 and T.TEXT or T.DIM
        bLbl.TextXAlignment = Enum.TextXAlignment.Left

        tabBtns[name] = {btn = btn, strip = bStrip, stroke = bStroke, lbl = bLbl}

        -- page
        local page = Instance.new("ScrollingFrame", contentArea)
        page.Size = UDim2.new(1, -8, 1, -8)
        page.Position = UDim2.new(0, 0, 0, 4)
        page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = T.BORDER
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = tabCount == 1
        tabPages[name] = page

        -- auto canvas size via UIListLayout
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        padding(page, 6, 6, 6, 6)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        if tabCount == 1 then activeTab = name end

        btn.MouseButton1Click:Connect(function() switchTab(name) end)

        -- ════════════════════════════════════════════════
        --  TAB OBJECT (returned to user)
        -- ════════════════════════════════════════════════
        local Tab = {}
        Tab._page   = page
        Tab._layout = layout
        Tab._order  = 0

        local function nextOrder()
            Tab._order += 1
            return Tab._order
        end

        -- ── SEPARATOR ────────────────────────────────────
        function Tab:Separator(label)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1, 0, 0, 18)
            f.BackgroundTransparency = 1
            f.BorderSizePixel = 0
            f.LayoutOrder = nextOrder()
            local lbl = Instance.new("TextLabel", f)
            lbl.Size = UDim2.new(0, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label or ""
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
            lbl.TextColor3 = T.DIM
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.AutomaticSize = Enum.AutomaticSize.X
            task.wait()
            local div = Instance.new("Frame", f)
            div.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 8), 0, 1)
            div.Position = UDim2.new(0, lbl.AbsoluteSize.X + 6, 0.5, 0)
            div.BackgroundColor3 = T.BORDER; div.BorderSizePixel = 0
            return f
        end

        -- ── LABEL ────────────────────────────────────────
        -- style: "normal" | "dim" | "accent" | "success" | "danger"
        function Tab:Label(text, style_)
            local colMap = {
                normal  = T.TEXT,
                dim     = T.DIM,
                accent  = T.ACCENT,
                success = T.GREEN,
                danger  = T.RED,
                warn    = T.YELLOW,
            }
            local col = colMap[style_ or "dim"] or T.DIM
            local lbl = Instance.new("TextLabel", page)
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.BackgroundTransparency = 1; lbl.BorderSizePixel = 0
            lbl.Text = text; lbl.Font = Enum.Font.Code; lbl.TextSize = 10
            lbl.TextColor3 = col; lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true; lbl.LayoutOrder = nextOrder()
            -- allow multiline
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            return lbl
        end

        -- ── TOGGLE ───────────────────────────────────────
        function Tab:Toggle(label, desc, default_, callback)
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, 0, 0, 52)
            row.BackgroundColor3 = T.SURFACE
            row.BorderSizePixel = 0; corner(row, 10)
            local rs = stroke(row, T.BORDER, 1); rs.Transparency = 0.5
            row.LayoutOrder = nextOrder()

            local dot = Instance.new("Frame", row)
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.Position = UDim2.new(0, 10, 0.5, -3)
            dot.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            dot.BorderSizePixel = 0; corner(dot, 3)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -70, 0, 18)
            lbl.Position = UDim2.new(0, 22, 0, 7)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
            lbl.TextColor3 = T.TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local sub = Instance.new("TextLabel", row)
            sub.Size = UDim2.new(1, -70, 0, 14)
            sub.Position = UDim2.new(0, 22, 0, 27)
            sub.BackgroundTransparency = 1; sub.Text = desc or ""
            sub.Font = Enum.Font.Gotham; sub.TextSize = 9
            sub.TextColor3 = T.DIM; sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.TextWrapped = true

            local tog = Instance.new("Frame", row)
            tog.Size = UDim2.new(0, 44, 0, 22)
            tog.Position = UDim2.new(1, -50, 0.5, -11)
            tog.BackgroundColor3 = T.CARD; tog.BorderSizePixel = 0; corner(tog, 11)

            local knob = Instance.new("Frame", tog)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = T.WHITE
            knob.BorderSizePixel = 0; corner(knob, 8)

            local isOn = false
            local function setOn(v, silent)
                isOn = v
                tween(tog,  {BackgroundColor3 = v and T.ACCENT or T.CARD}, 0.14)
                tween(knob, {Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.14)
                dot.BackgroundColor3 = v and T.ACCENT or Color3.fromRGB(55, 55, 55)
                rs.Color = v and T.ACCENT or T.BORDER
                if not silent and callback then callback(v) end
            end

            -- apply default
            if default_ then setOn(true, true) end

            local tb = Instance.new("TextButton", row)
            tb.Size = UDim2.new(1, 0, 1, 0)
            tb.BackgroundTransparency = 1; tb.Text = ""
            tb.MouseButton1Click:Connect(function() setOn(not isOn) end)

            -- hover
            tb.MouseEnter:Connect(function()
                tween(row, {BackgroundColor3 = T.CARD}, 0.1)
            end)
            tb.MouseLeave:Connect(function()
                tween(row, {BackgroundColor3 = T.SURFACE}, 0.1)
            end)

            local ctrl = {}
            function ctrl:Set(v) setOn(v) end
            function ctrl:Get() return isOn end
            return ctrl
        end

        -- ── SLIDER ───────────────────────────────────────
        function Tab:Slider(label, min_, max_, default_, callback, suffix)
            suffix = suffix or ""
            local card = Instance.new("Frame", page)
            card.Size = UDim2.new(1, 0, 0, 56)
            card.BackgroundColor3 = T.SURFACE
            card.BorderSizePixel = 0; corner(card, 10)
            stroke(card, T.BORDER, 1); card.LayoutOrder = nextOrder()

            local nL = Instance.new("TextLabel", card)
            nL.Size = UDim2.new(0.6, 0, 0, 16); nL.Position = UDim2.new(0, 10, 0, 7)
            nL.BackgroundTransparency = 1; nL.Text = label
            nL.Font = Enum.Font.GothamBold; nL.TextSize = 11; nL.TextColor3 = T.TEXT
            nL.TextXAlignment = Enum.TextXAlignment.Left

            local vL = Instance.new("TextLabel", card)
            vL.Size = UDim2.new(0.38, 0, 0, 16); vL.Position = UDim2.new(0.62, 0, 0, 7)
            vL.BackgroundTransparency = 1; vL.Text = tostring(default_)..suffix
            vL.Font = Enum.Font.Code; vL.TextSize = 11; vL.TextColor3 = T.ACCENT
            vL.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", card)
            track.Size = UDim2.new(1, -20, 0, 5); track.Position = UDim2.new(0, 10, 0, 36)
            track.BackgroundColor3 = T.CARD; track.BorderSizePixel = 0; corner(track, 3)
            stroke(track, T.BORDER, 1)

            local fill = Instance.new("Frame", track)
            local initPct = (default_ - min_) / (max_ - min_)
            fill.Size = UDim2.new(initPct, 0, 1, 0)
            fill.BackgroundColor3 = T.ACCENT
            fill.BorderSizePixel = 0; corner(fill, 3)

            local thumb = Instance.new("TextButton", track)
            thumb.Size = UDim2.new(0, 14, 0, 14)
            thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            thumb.Position = UDim2.new(initPct, 0, 0.5, 0)
            thumb.BackgroundColor3 = T.WHITE
            thumb.BorderSizePixel = 0; thumb.Text = ""
            corner(thumb, 7); stroke(thumb, T.ACCENTL, 1.5)

            local currentVal = default_
            local sDrag = false

            thumb.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or
                   i.UserInputType == Enum.UserInputType.Touch then
                    sDrag = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or
                   i.UserInputType == Enum.UserInputType.Touch then
                    sDrag = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if not sDrag then return end
                local tx  = track.AbsolutePosition.X
                local tw_ = track.AbsoluteSize.X
                local pct = math.clamp((i.Position.X - tx) / tw_, 0, 1)
                local val = math.floor(min_ + (max_ - min_) * pct)
                currentVal = val
                fill.Size  = UDim2.new(pct, 0, 1, 0)
                thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                vL.Text = tostring(val)..suffix
                if callback then callback(val) end
            end)

            -- click on track
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local tx  = track.AbsolutePosition.X
                    local tw_ = track.AbsoluteSize.X
                    local pct = math.clamp((i.Position.X - tx) / tw_, 0, 1)
                    local val = math.floor(min_ + (max_ - min_) * pct)
                    currentVal = val
                    fill.Size  = UDim2.new(pct, 0, 1, 0)
                    thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                    vL.Text = tostring(val)..suffix
                    if callback then callback(val) end
                end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                local pct = math.clamp((v - min_) / (max_ - min_), 0, 1)
                currentVal = v
                fill.Size = UDim2.new(pct, 0, 1, 0)
                thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                vL.Text = tostring(v)..suffix
                if callback then callback(v) end
            end
            function ctrl:Get() return currentVal end
            return ctrl
        end

        -- ── BUTTON ───────────────────────────────────────
        function Tab:Button(label, desc, callback, col)
            col = col or T.ACCENT
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(1, 0, 0, desc and 46 or 36)
            btn.BackgroundColor3 = T.SURFACE
            btn.BorderSizePixel = 0; corner(btn, 10)
            local bs = stroke(btn, T.BORDER, 1); bs.Transparency = 0.5
            btn.Text = ""; btn.LayoutOrder = nextOrder()

            local strip = Instance.new("Frame", btn)
            strip.Size = UDim2.new(0, 3, 1, -16)
            strip.Position = UDim2.new(0, 0, 0, 8)
            strip.BackgroundColor3 = col; strip.BorderSizePixel = 0; corner(strip, 2)

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, -20, 0, 16)
            lbl.Position = UDim2.new(0, 14, 0, desc and 7 or 10)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
            lbl.TextColor3 = col; lbl.TextXAlignment = Enum.TextXAlignment.Left

            if desc then
                local sub = Instance.new("TextLabel", btn)
                sub.Size = UDim2.new(1, -20, 0, 13)
                sub.Position = UDim2.new(0, 14, 0, 26)
                sub.BackgroundTransparency = 1; sub.Text = desc
                sub.Font = Enum.Font.Gotham; sub.TextSize = 9
                sub.TextColor3 = T.DIM; sub.TextXAlignment = Enum.TextXAlignment.Left
            end

            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundColor3 = T.CARD}, 0.1)
                bs.Transparency = 0
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundColor3 = T.SURFACE}, 0.1)
                bs.Transparency = 0.5
            end)
            btn.MouseButton1Down:Connect(function()
                tween(strip, {BackgroundColor3 = col:Lerp(T.WHITE, 0.3)}, 0.05)
            end)
            btn.MouseButton1Up:Connect(function()
                tween(strip, {BackgroundColor3 = col}, 0.1)
            end)
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        -- ── DROPDOWN ─────────────────────────────────────
        function Tab:Dropdown(label, options, default_, callback)
            local selected = default_ or options[1]
            local isOpen   = false

            local wrap = Instance.new("Frame", page)
            wrap.Size = UDim2.new(1, 0, 0, 52)
            wrap.BackgroundColor3 = T.SURFACE
            wrap.BorderSizePixel = 0; corner(wrap, 10)
            stroke(wrap, T.BORDER, 1); wrap.LayoutOrder = nextOrder()
            wrap.ClipsDescendants = false

            local lbl = Instance.new("TextLabel", wrap)
            lbl.Size = UDim2.new(0.55, 0, 0, 20)
            lbl.Position = UDim2.new(0, 10, 0, 7)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
            lbl.TextColor3 = T.TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left

            -- selected value display
            local selBtn = Instance.new("TextButton", wrap)
            selBtn.Size = UDim2.new(0.42, 0, 0, 26)
            selBtn.Position = UDim2.new(0.56, 0, 0.5, -13)
            selBtn.BackgroundColor3 = T.CARD; selBtn.BorderSizePixel = 0
            corner(selBtn, 6); stroke(selBtn, T.BORDER, 1)
            selBtn.Text = ""

            local selLbl = Instance.new("TextLabel", selBtn)
            selLbl.Size = UDim2.new(1, -24, 1, 0)
            selLbl.Position = UDim2.new(0, 8, 0, 0)
            selLbl.BackgroundTransparency = 1; selLbl.Text = selected
            selLbl.Font = Enum.Font.GothamBold; selLbl.TextSize = 10
            selLbl.TextColor3 = T.ACCENT; selLbl.TextXAlignment = Enum.TextXAlignment.Left

            local arrow = Instance.new("TextLabel", selBtn)
            arrow.Size = UDim2.new(0, 16, 1, 0)
            arrow.Position = UDim2.new(1, -18, 0, 0)
            arrow.BackgroundTransparency = 1; arrow.Text = "▾"
            arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 10
            arrow.TextColor3 = T.DIM

            -- dropdown list
            local dropList = Instance.new("Frame", wrap)
            dropList.Size = UDim2.new(0.42, 0, 0, 0)
            dropList.Position = UDim2.new(0.56, 0, 1, 4)
            dropList.BackgroundColor3 = T.CARD
            dropList.BorderSizePixel = 0; corner(dropList, 8)
            stroke(dropList, T.BORDER, 1)
            dropList.ClipsDescendants = true
            dropList.ZIndex = 10

            local dropLayout = Instance.new("UIListLayout", dropList)
            dropLayout.Padding = UDim.new(0, 2)
            padding(dropList, 4, 4, 4, 4)

            -- build option buttons
            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton", dropList)
                ob.Size = UDim2.new(1, 0, 0, 24)
                ob.BackgroundColor3 = T.CARD; ob.BorderSizePixel = 0
                corner(ob, 5); ob.Text = opt
                ob.Font = Enum.Font.GothamBold; ob.TextSize = 10
                ob.TextColor3 = opt == selected and T.ACCENT or T.DIM
                ob.ZIndex = 11
                ob.MouseEnter:Connect(function()
                    tween(ob, {BackgroundColor3 = T.BORDER:Lerp(T.CARD, 0.5)}, 0.08)
                end)
                ob.MouseLeave:Connect(function()
                    tween(ob, {BackgroundColor3 = T.CARD}, 0.08)
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    selLbl.Text = opt
                    -- reset all colors
                    for _, c in ipairs(dropList:GetChildren()) do
                        if c:IsA("TextButton") then
                            c.TextColor3 = T.DIM
                        end
                    end
                    ob.TextColor3 = T.ACCENT
                    -- close
                    isOpen = false
                    tween(arrow, {Rotation = 0}, 0.14)
                    tween(dropList, {Size = UDim2.new(0.42, 0, 0, 0)}, 0.18)
                    tween(wrap, {Size = UDim2.new(1, 0, 0, 52)}, 0.18)
                    if callback then callback(opt) end
                end)
            end

            local targetH = dropLayout.AbsoluteContentSize.Y + 12

            selBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                tween(arrow, {Rotation = isOpen and 180 or 0}, 0.14)
                if isOpen then
                    tween(dropList, {Size = UDim2.new(0.42, 0, 0, targetH)}, 0.2, Enum.EasingStyle.Back)
                    tween(wrap,     {Size = UDim2.new(1, 0, 0, 52 + targetH + 8)}, 0.2)
                else
                    tween(dropList, {Size = UDim2.new(0.42, 0, 0, 0)}, 0.16)
                    tween(wrap,     {Size = UDim2.new(1, 0, 0, 52)}, 0.16)
                end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                selected = v; selLbl.Text = v
                if callback then callback(v) end
            end
            function ctrl:Get() return selected end
            return ctrl
        end

        -- ── KEYBIND ──────────────────────────────────────
        function Tab:Keybind(label, default_, callback)
            local currentKey = default_ or Enum.KeyCode.Unknown
            local isListening = false

            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = T.SURFACE
            row.BorderSizePixel = 0; corner(row, 10)
            stroke(row, T.BORDER, 1); row.LayoutOrder = nextOrder()

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0.55, 0, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
            lbl.TextColor3 = T.TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local keyBtn = Instance.new("TextButton", row)
            keyBtn.Size = UDim2.new(0.4, 0, 0, 26)
            keyBtn.Position = UDim2.new(0.57, 0, 0.5, -13)
            keyBtn.BackgroundColor3 = T.CARD; keyBtn.BorderSizePixel = 0
            corner(keyBtn, 6); stroke(keyBtn, T.BORDER, 1)

            local function keyName(k)
                local n = tostring(k):gsub("Enum.KeyCode.", "")
                return n
            end

            keyBtn.Text = keyName(currentKey)
            keyBtn.Font = Enum.Font.GothamBold; keyBtn.TextSize = 10
            keyBtn.TextColor3 = T.ACCENT

            keyBtn.MouseButton1Click:Connect(function()
                if isListening then return end
                isListening = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = T.YELLOW
                tween(keyBtn, {BackgroundColor3 = T.BORDER:Lerp(T.CARD, 0.3)}, 0.1)
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not isListening then return end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = inp.KeyCode
                    isListening = false
                    keyBtn.Text = keyName(currentKey)
                    keyBtn.TextColor3 = T.ACCENT
                    tween(keyBtn, {BackgroundColor3 = T.CARD}, 0.1)
                    if callback then callback(currentKey) end
                end
            end)

            local ctrl = {}
            function ctrl:Get() return currentKey end
            function ctrl:Set(k) currentKey = k; keyBtn.Text = keyName(k) end
            return ctrl
        end

        -- ── INPUT (TextBox) ───────────────────────────────
        function Tab:Input(label, placeholder, callback)
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, 0, 0, 52)
            row.BackgroundColor3 = T.SURFACE
            row.BorderSizePixel = 0; corner(row, 10)
            stroke(row, T.BORDER, 1); row.LayoutOrder = nextOrder()

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -20, 0, 16)
            lbl.Position = UDim2.new(0, 10, 0, 6)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
            lbl.TextColor3 = T.TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", row)
            box.Size = UDim2.new(1, -20, 0, 22)
            box.Position = UDim2.new(0, 10, 0, 24)
            box.BackgroundColor3 = T.CARD; box.BorderSizePixel = 0
            corner(box, 6); stroke(box, T.BORDER, 1)
            box.PlaceholderText = placeholder or "type here..."
            box.PlaceholderColor3 = T.DIM
            box.Text = ""; box.Font = Enum.Font.Code; box.TextSize = 10
            box.TextColor3 = T.TEXT; box.ClearTextOnFocus = false
            padding(box, 0, 6, 0, 6)

            box.Focused:Connect(function()
                tween(box, {BackgroundColor3 = T.BORDER:Lerp(T.CARD, 0.3)}, 0.1)
            end)
            box.FocusLost:Connect(function(enter)
                tween(box, {BackgroundColor3 = T.CARD}, 0.1)
                if callback then callback(box.Text, enter) end
            end)

            local ctrl = {}
            function ctrl:Get() return box.Text end
            function ctrl:Set(v) box.Text = v end
            return ctrl
        end

        -- ── COLOR DISPLAY (read-only color preview) ───────
        function Tab:ColorDisplay(label, color)
            local row = Instance.new("Frame", page)
            row.Size = UDim2.new(1, 0, 0, 40)
            row.BackgroundColor3 = T.SURFACE
            row.BorderSizePixel = 0; corner(row, 10)
            stroke(row, T.BORDER, 1); row.LayoutOrder = nextOrder()

            local preview = Instance.new("Frame", row)
            preview.Size = UDim2.new(0, 28, 0, 28)
            preview.Position = UDim2.new(0, 8, 0.5, -14)
            preview.BackgroundColor3 = color or T.ACCENT
            preview.BorderSizePixel = 0; corner(preview, 6)
            stroke(preview, T.BORDER, 1)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 44, 0, 0)
            lbl.BackgroundTransparency = 1; lbl.Text = label
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
            lbl.TextColor3 = T.TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local ctrl = {}
            function ctrl:Set(c) preview.BackgroundColor3 = c end
            return ctrl
        end

        -- ── PROGRESS BAR (live updating) ──────────────────
        function Tab:Progress(label, default_)
            local val = default_ or 0
            local card = Instance.new("Frame", page)
            card.Size = UDim2.new(1, 0, 0, 46)
            card.BackgroundColor3 = T.SURFACE
            card.BorderSizePixel = 0; corner(card, 10)
            stroke(card, T.BORDER, 1); card.LayoutOrder = nextOrder()

            local nL = Instance.new("TextLabel", card)
            nL.Size = UDim2.new(0.6, 0, 0, 16); nL.Position = UDim2.new(0, 10, 0, 6)
            nL.BackgroundTransparency = 1; nL.Text = label
            nL.Font = Enum.Font.GothamBold; nL.TextSize = 11; nL.TextColor3 = T.TEXT
            nL.TextXAlignment = Enum.TextXAlignment.Left

            local vL = Instance.new("TextLabel", card)
            vL.Size = UDim2.new(0.38, 0, 0, 16); vL.Position = UDim2.new(0.62, 0, 0, 6)
            vL.BackgroundTransparency = 1; vL.Text = tostring(val).."%"
            vL.Font = Enum.Font.Code; vL.TextSize = 11; vL.TextColor3 = T.ACCENT
            vL.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", card)
            track.Size = UDim2.new(1, -20, 0, 5); track.Position = UDim2.new(0, 10, 0, 32)
            track.BackgroundColor3 = T.CARD; track.BorderSizePixel = 0; corner(track, 3)

            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new(val / 100, 0, 1, 0)
            fill.BackgroundColor3 = T.ACCENT
            fill.BorderSizePixel = 0; corner(fill, 3)

            local ctrl = {}
            function ctrl:Set(v)
                val = math.clamp(v, 0, 100)
                local col = val > 60 and T.GREEN or val > 30 and T.YELLOW or T.RED
                tween(fill, {Size = UDim2.new(val / 100, 0, 1, 0), BackgroundColor3 = col}, 0.2)
                vL.Text = tostring(math.floor(val)).."%"
            end
            function ctrl:Get() return val end
            return ctrl
        end

        return Tab
    end

    -- store and return
    table.insert(Null._windows, Win)
    return Win
end

-- ════════════════════════════════════════════════════════════
--  GLOBAL TOAST ACCESS
-- ════════════════════════════════════════════════════════════
Null.Toast = toast

-- ════════════════════════════════════════════════════════════
--  DESTROY ALL
-- ════════════════════════════════════════════════════════════
function Null:DestroyAll()
    for _, win in ipairs(self._windows) do
        pcall(function() win._sg:Destroy() end)
    end
    self._windows = {}
    pcall(function()
        CoreGui:FindFirstChild("NullToastHolder"):Destroy()
    end)
end

return Null
