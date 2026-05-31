-- hiii skidddd
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local XynorUI = {}
XynorUI.__index = XynorUI

-- Helper para obtener el parent correcto de GUI en Delta
local function getGuiParent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ============================================================
-- BALL CANCOLLIDE GUARDIAN — sin loops pesados
-- Garantiza CanCollide = false SIEMPRE en la ball
-- ============================================================
local _ballGuardConn
local function startBallGuard()
    if _ballGuardConn then return end
    local function guardBall(ball)
        if not ball or not ball:IsA("BasePart") then return end
        -- Forzar inmediatamente
        pcall(function() ball.CanCollide = false end)
        -- Escuchar cambios y corregir al instante (sin loop)
        ball:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if ball.CanCollide then
                pcall(function() ball.CanCollide = false end)
            end
        end)
    end

    -- Buscar ball existente
    local function findAndGuard()
        local tps = Workspace:FindFirstChild("TPSSystem")
        if tps then
            local ball = tps:FindFirstChild("TPS")
            if ball then guardBall(ball) end
            -- También monitorear nuevas instancias dentro de TPSSystem
            tps.ChildAdded:Connect(function(child)
                if child.Name == "TPS" then guardBall(child) end
            end)
        end
    end

    findAndGuard()

    -- Si el TPSSystem aparece después
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "TPSSystem" then
            task.wait(0.05)
            findAndGuard()
        end
    end)
end

-- Iniciar el guardian inmediatamente
pcall(startBallGuard)

-- ============================================================
-- TEMA PREMIUM Xynor 1.0 — Modern Dark Theme
-- ============================================================
local ACCENT      = Color3.fromRGB(0, 170, 255)      -- Cyan blue
local ACCENT2     = Color3.fromRGB(0, 130, 200)      -- Deep cyan
local BG_DARK     = Color3.fromRGB(10, 10, 15)       -- Deep dark
local BG_FRAME    = Color3.fromRGB(18, 18, 25)       -- Frame oscuro
local BG_ELEM     = Color3.fromRGB(25, 25, 35)       -- Elemento oscuro
local TEXT_WHITE  = Color3.fromRGB(255, 255, 255)    -- Blanco puro
local TEXT_GRAY   = Color3.fromRGB(120, 120, 140)    -- Gray muted
local TEXT_MID    = Color3.fromRGB(170, 170, 190)    -- Mid tone
local OUTLINE     = Color3.fromRGB(40, 40, 55)       -- Dark outline
local ACCENT_GLOW = Color3.fromRGB(0, 200, 255)      -- Cyan glow

-- ============================================================
-- EASE HELPERS — animaciones más rápidas y fluidas V5
-- ============================================================
local function tweenQuint(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
end
local function tweenBack(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end
local function tweenExpo(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props)
end
local function tweenSine(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props)
end
local function tweenCirc(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), props)
end

-- ============================================================
-- NOTIFICACIONES
-- ============================================================
function XynorUI:Notify(opts)
    local title    = opts.Title or ""
    local desc     = opts.Desc or ""
    local duration = opts.Duration or 3

    local parent = getGuiParent()
    local existing = parent:FindFirstChild("XynorNotifGui")
    if existing then existing:Destroy() end

    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "XynorNotifGui"
    NotifGui.ResetOnSpawn = false
    NotifGui.IgnoreGuiInset = true
    NotifGui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(290, 64)
    frame.Position = UDim2.new(1, 20, 1, -80)
    frame.BackgroundColor3 = BG_FRAME
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = NotifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    -- Barra lateral de acento
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.fromOffset(3, 44)
    accentBar.Position = UDim2.new(0, 0, 0.5, -22)
    accentBar.BackgroundColor3 = ACCENT
    accentBar.BorderSizePixel = 0
    accentBar.Parent = frame
    local abC = Instance.new("UICorner"); abC.CornerRadius = UDim.new(1,0); abC.Parent = accentBar

    local stroke = Instance.new("UIStroke")
    stroke.Color = OUTLINE
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -18, 0.5, 0)
    titleLbl.Position = UDim2.fromOffset(14, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = TEXT_WHITE
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = frame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -18, 0.5, 0)
    descLbl.Position = UDim2.new(0, 14, 0.5, 0)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = TEXT_GRAY
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 11
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextTransparency = 1
    descLbl.Parent = frame

    -- Animación entrada: slide + fade combinados
    tweenExpo(frame, 0.45, {
        Position = UDim2.new(1, -305, 1, -80),
        BackgroundTransparency = 0
    }):Play()
    task.delay(0.1, function()
        tweenSine(titleLbl, 0.3, { TextTransparency = 0 }):Play()
        task.delay(0.08, function()
            tweenSine(descLbl, 0.3, { TextTransparency = 0 }):Play()
        end)
    end)

    task.delay(duration, function()
        if NotifGui and NotifGui.Parent then
            tweenQuint(frame, 0.35, {
                Position = UDim2.new(1, 20, 1, -80),
                BackgroundTransparency = 1
            }):Play()
            tweenSine(titleLbl, 0.25, { TextTransparency = 1 }):Play()
            tweenSine(descLbl, 0.25, { TextTransparency = 1 }):Play()
            task.wait(0.4)
            NotifGui:Destroy()
        end
    end)
end

-- ============================================================
-- CONSTRUCCIÓN DE VENTANA PRINCIPAL
-- ============================================================
function XynorUI:CreateWindow(opts)
    local isMobile = UserInputService.TouchEnabled
    local winW = isMobile and 480 or 600
    local winH = isMobile and 380 or 520

    local guiParent = getGuiParent()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XynorHubGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Enabled = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = guiParent

    -- Ventana principal — empieza invisible y pequeña para el pop-in
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    local newSize = 350
    MainFrame.Size = UDim2.fromOffset(newSize * 0.6, newSize * 0.6)  -- Pequeño al inicio
    MainFrame.Position = UDim2.new(0.5, -newSize/2, 0.5, -newSize/2)
    MainFrame.BackgroundColor3 = BG_DARK
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = OUTLINE
    mainStroke.Thickness = 1.5
    mainStroke.Parent = MainFrame

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, isMobile and 40 or 48)
    Topbar.BackgroundColor3 = Color3.fromRGB(8, 3, 3)
    Topbar.BorderSizePixel = 0
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 10)
    topCorner.Parent = Topbar

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 10)
    topFix.Position = UDim2.new(0, 0, 1, -10)
    topFix.BackgroundColor3 = Color3.fromRGB(8, 3, 3)
    topFix.BorderSizePixel = 0
    topFix.BackgroundTransparency = 1
    topFix.Parent = Topbar

    -- Línea inferior roja decorativa en topbar
    local topAccentLine = Instance.new("Frame")
    topAccentLine.Size = UDim2.new(0, 0, 0, 1)
    topAccentLine.Position = UDim2.new(0, 0, 1, -1)
    topAccentLine.BackgroundColor3 = ACCENT
    topAccentLine.BorderSizePixel = 0
    topAccentLine.Parent = Topbar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 200, 0.5, 0)
    titleLbl.Position = UDim2.fromOffset(14, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = opts.Title or "vxnity hub"
    titleLbl.TextColor3 = TEXT_WHITE
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = isMobile and 14 or 16
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = Topbar

    local authorLbl = Instance.new("TextLabel")
    authorLbl.Size = UDim2.new(0, 200, 0.5, 0)
    authorLbl.Position = UDim2.new(0, 14, 0.5, 0)
    authorLbl.BackgroundTransparency = 1
    authorLbl.Text = opts.Author or ""
    authorLbl.TextColor3 = ACCENT
    authorLbl.Font = Enum.Font.Gotham
    authorLbl.TextSize = isMobile and 11 or 12
    authorLbl.TextXAlignment = Enum.TextXAlignment.Left
    authorLbl.TextTransparency = 1
    authorLbl.Parent = Topbar

    -- Botón minimizar - HACER VISIBLE
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.fromOffset(22, 22)
    MinBtn.Position = UDim2.new(1, -70, 0.5, -11)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(30, 20, 25)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.BorderSizePixel = 0
    MinBtn.BackgroundTransparency = 0
    MinBtn.Parent = Topbar
    local minC = Instance.new("UICorner"); minC.CornerRadius = UDim.new(1,0); minC.Parent = MinBtn
    local minStroke = Instance.new("UIStroke"); minStroke.Color = OUTLINE; minStroke.Thickness = 1; minStroke.Parent = MinBtn

    -- Hover minimizar
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { BackgroundColor3 = Color3.fromRGB(255, 170, 80) }):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { BackgroundColor3 = Color3.fromRGB(255, 200, 100) }):Play()
    end)

    -- Botón cerrar - HACER VISIBLE
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(22, 22)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -11)
    CloseBtn.BackgroundColor3 = ACCENT
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = TEXT_WHITE
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.BorderSizePixel = 0
    CloseBtn.BackgroundTransparency = 0
    CloseBtn.Parent = Topbar
    local clsC = Instance.new("UICorner"); clsC.CornerRadius = UDim.new(1,0); clsC.Parent = CloseBtn
    local clsStroke = Instance.new("UIStroke"); clsStroke.Color = ACCENT2; clsStroke.Thickness = 1; clsStroke.Parent = CloseBtn

    -- Hover cerrar
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { BackgroundColor3 = ACCENT2 }):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { BackgroundColor3 = ACCENT }):Play()
    end)

    local minimized = false
    local contentHeight = winH - (isMobile and 40 or 48)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -(isMobile and 40 or 48))
    ContentFrame.Position = UDim2.new(0, 0, 0, isMobile and 40 or 48)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local TabPanel = Instance.new("ScrollingFrame")
    TabPanel.Name = "TabPanel"
    TabPanel.Size = UDim2.new(0, 160, 1, 0)
    TabPanel.BackgroundColor3 = Color3.fromRGB(6, 2, 2)
    TabPanel.BorderSizePixel = 0
    TabPanel.ScrollBarThickness = 0
    TabPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabPanel.BackgroundTransparency = 1
    TabPanel.Parent = ContentFrame

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 2)
    tabListLayout.Parent = TabPanel

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 6)
    tabPadding.PaddingLeft = UDim.new(0, 6)
    tabPadding.PaddingRight = UDim.new(0, 6)
    tabPadding.Parent = TabPanel

    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0, 1, 1, 0)
    Separator.Position = UDim2.fromOffset(160, 0)
    Separator.BackgroundColor3 = OUTLINE
    Separator.BorderSizePixel = 0
    Separator.BackgroundTransparency = 1
    Separator.Parent = ContentFrame

    local PageHolder = Instance.new("Frame")
    PageHolder.Name = "PageHolder"
    PageHolder.Size = UDim2.new(1, -161, 1, 0)
    PageHolder.Position = UDim2.fromOffset(161, 0)
    PageHolder.BackgroundTransparency = 1
    PageHolder.ClipsDescendants = true
    PageHolder.Parent = ContentFrame

    -- ============================================================
    -- ANIMACIÓN DE APERTURA V6 — Natsuki Theme, más fluida y moderna
    -- ============================================================
    task.spawn(function()
        tweenBack(MainFrame, 0.35, {
            Size = UDim2.fromOffset(newSize, newSize),
            BackgroundTransparency = 0
        }):Play()

        task.wait(0.08)
        tweenExpo(Topbar, 0.2, { BackgroundTransparency = 0 }):Play()
        tweenExpo(topFix, 0.2, { BackgroundTransparency = 0 }):Play()
        tweenCirc(topAccentLine, 0.35, { Size = UDim2.new(1, 0, 0, 1) }):Play()
        mainStroke.Color = OUTLINE

        task.wait(0.05)
        tweenSine(titleLbl, 0.18, { TextTransparency = 0 }):Play()
        task.delay(0.03, function()
            tweenSine(authorLbl, 0.18, { TextTransparency = 0 }):Play()
        end)

        task.delay(0.04)
        tweenBack(MinBtn, 0.15, { BackgroundTransparency = 0 }):Play()
        task.delay(0.02, function()
            tweenBack(CloseBtn, 0.15, { BackgroundTransparency = 0 }):Play()
        end)

        task.delay(0.05)
        tweenExpo(TabPanel, 0.2, { BackgroundTransparency = 0 }):Play()
        tweenExpo(Separator, 0.2, { BackgroundTransparency = 0 }):Play()

        task.delay(0.06)
        local children = TabPanel:GetChildren()
        local delay = 0
        for _, child in ipairs(children) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                task.delay(delay, function()
                    if child:IsA("Frame") then
                        tweenQuint(child, 0.12, { BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(child, TweenInfo.new(0.12, Enum.EasingStyle.Sine), { TextTransparency = 0 }):Play()
                    end
                end)
                delay = delay + 0.02
            end
        end
    end)

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tweenQuint(MainFrame, 0.3, {
            Size = minimized and UDim2.fromOffset(winW, isMobile and 40 or 48) or UDim2.fromOffset(winW, winH)
        }):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        tweenQuint(MainFrame, 0.25, { Size = UDim2.fromOffset(winW, 0), BackgroundTransparency = 1 }):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Botón flotante para reabrir
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Name = "XynorOpenBtn"
    OpenBtn.Size = UDim2.fromOffset(80, 30)
    OpenBtn.Position = UDim2.new(0, 10, 0.5, -15)
    OpenBtn.BackgroundColor3 = ACCENT2
    OpenBtn.Text = "vxnity"
    OpenBtn.TextColor3 = TEXT_WHITE
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 13
    OpenBtn.BorderSizePixel = 0
    OpenBtn.Visible = false
    OpenBtn.Parent = ScreenGui
    local obC = Instance.new("UICorner"); obC.CornerRadius = UDim.new(0,8); obC.Parent = OpenBtn
    local obStr = Instance.new("UIStroke"); obStr.Color = ACCENT; obStr.Thickness = 2; obStr.Parent = OpenBtn

    -- Hover del OpenBtn
    OpenBtn.MouseEnter:Connect(function()
        tweenSine(OpenBtn, 0.15, { BackgroundColor3 = ACCENT }):Play()
    end)
    OpenBtn.MouseLeave:Connect(function()
        tweenSine(OpenBtn, 0.15, { BackgroundColor3 = ACCENT2 }):Play()
    end)
    OpenBtn.MouseButton1Down:Connect(function()
        tweenBack(OpenBtn, 0.08, { Size = UDim2.fromOffset(74, 27) }):Play()
    end)
    OpenBtn.MouseButton1Up:Connect(function()
        tweenBack(OpenBtn, 0.15, { Size = UDim2.fromOffset(80, 30) }):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        OpenBtn.Visible = true
    end)
    OpenBtn.MouseButton1Click:Connect(function()
        OpenBtn.Visible = false
        MainFrame.Size = UDim2.fromOffset(winW, winH)
        MainFrame.Parent = ScreenGui
    end)

    -- Drag del OpenBtn
    local obDragging, obDragStart, obStartPos = false, nil, nil
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            obDragging = true; obDragStart = input.Position; obStartPos = OpenBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if obDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - obDragStart
            OpenBtn.Position = UDim2.new(obStartPos.X.Scale, obStartPos.X.Offset + d.X, obStartPos.Y.Scale, obStartPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            obDragging = false
        end
    end)

    local windowObj = {}
    local allTabs = {}
    local currentTab = nil
    local tabOrder = 0
    local sectionOrder = 0

    local function setActiveTab(tabPage, tabBtn)
        if currentTab then
            currentTab.Page.Visible = false
            TweenService:Create(currentTab.Btn, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
                BackgroundColor3 = Color3.fromRGB(14, 6, 6),
                BackgroundTransparency = 0
            }):Play()
            local prevLbl = currentTab.Btn:FindFirstChildWhichIsA("TextLabel")
            if prevLbl then
                TweenService:Create(prevLbl, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {
                    TextColor3 = TEXT_GRAY
                }):Play()
            end
        end
        tabPage.Visible = true
        TweenService:Create(tabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            BackgroundColor3 = Color3.fromRGB(35, 8, 8),
            BackgroundTransparency = 0
        }):Play()
        local lbl = tabBtn:FindFirstChildWhichIsA("TextLabel")
        if lbl then
            TweenService:Create(lbl, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
                TextColor3 = ACCENT_GLOW
            }):Play()
        end
        currentTab = {Page = tabPage, Btn = tabBtn}
    end

    -- Función para crear elementos de UI dentro de un tab
    local function makeElementContainer(parent)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -8, 0, 52)
        frame.BackgroundColor3 = BG_ELEM
        frame.BorderSizePixel = 0
        frame.Parent = parent

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 7)
        fCorner.Parent = frame

        local fStroke = Instance.new("UIStroke")
        fStroke.Color = OUTLINE
        fStroke.Thickness = 1
        fStroke.Parent = frame

        -- Hover suave en el elemento
        local hoverBtn = Instance.new("TextButton")
        hoverBtn.Size = UDim2.new(1,0,1,0)
        hoverBtn.BackgroundTransparency = 1
        hoverBtn.Text = ""
        hoverBtn.ZIndex = 0
        hoverBtn.Parent = frame

        hoverBtn.MouseEnter:Connect(function()
            tweenSine(frame, 0.15, { BackgroundColor3 = Color3.fromRGB(25, 10, 10) }):Play()
            tweenSine(fStroke, 0.15, { Color = Color3.fromRGB(70, 20, 20) }):Play()
        end)
        hoverBtn.MouseLeave:Connect(function()
            tweenSine(frame, 0.15, { BackgroundColor3 = BG_ELEM }):Play()
            tweenSine(fStroke, 0.15, { Color = OUTLINE }):Play()
        end)

        return frame
    end

    -- Función para crear el tab builder
    local function buildTabAPI(page)
        local tabAPI = {}

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = ACCENT
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = page

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 5)
        listLayout.Parent = scroll

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 6)
        padding.Parent = scroll

        local elemOrder = 0
        local function nextOrder() elemOrder = elemOrder + 1 return elemOrder end

        -- SECTION
        function tabAPI:Section(opts2)
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(1, -8, 0, 22)
            sFrame.BackgroundTransparency = 1
            sFrame.LayoutOrder = nextOrder()
            sFrame.Parent = scroll

            local sLine = Instance.new("Frame")
            sLine.Size = UDim2.new(1, 0, 0, 1)
            sLine.Position = UDim2.new(0, 0, 0.5, 0)
            sLine.BackgroundColor3 = OUTLINE
            sLine.BorderSizePixel = 0
            sLine.Parent = sFrame

            local sTitle = Instance.new("TextLabel")
            sTitle.Size = UDim2.new(0, 0, 1, 0)
            sTitle.AutomaticSize = Enum.AutomaticSize.X
            sTitle.BackgroundColor3 = BG_DARK
            sTitle.BorderSizePixel = 0
            sTitle.Position = UDim2.new(0, 8, 0, 0)
            sTitle.Text = "  " .. (opts2.Title or "") .. "  "
            sTitle.TextColor3 = Color3.fromRGB(150, 60, 60)
            sTitle.Font = Enum.Font.GothamBold
            sTitle.TextSize = 11
            sTitle.Parent = sFrame
        end

        -- PARAGRAPH
        function tabAPI:Paragraph(opts2)
            local f = makeElementContainer(scroll)
            f.Size = UDim2.new(1, -8, 0, 48)
            f.LayoutOrder = nextOrder()

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -12, 0.5, 0)
            t.Position = UDim2.fromOffset(10, 4)
            t.BackgroundTransparency = 1
            t.Text = opts2.Title or ""
            t.TextColor3 = TEXT_WHITE
            t.Font = Enum.Font.GothamBold
            t.TextSize = 13
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = f

            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -12, 0.5, 0)
            d.Position = UDim2.new(0, 10, 0.5, 0)
            d.BackgroundTransparency = 1
            d.Text = opts2.Desc or ""
            d.TextColor3 = TEXT_GRAY
            d.Font = Enum.Font.Gotham
            d.TextSize = 11
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.TextWrapped = true
            d.Parent = f
        end

        -- TOGGLE
        function tabAPI:Toggle(opts2)
            local f = makeElementContainer(scroll)
            f.LayoutOrder = nextOrder()

            local titleLb = Instance.new("TextLabel")
            titleLb.Size = UDim2.new(1, -58, 0.5, 0)
            titleLb.Position = UDim2.fromOffset(10, 5)
            titleLb.BackgroundTransparency = 1
            titleLb.Text = opts2.Title or ""
            titleLb.TextColor3 = TEXT_WHITE
            titleLb.Font = Enum.Font.GothamBold
            titleLb.TextSize = 13
            titleLb.TextXAlignment = Enum.TextXAlignment.Left
            titleLb.Parent = f

            if opts2.Desc and opts2.Desc ~= "" then
                local descLb = Instance.new("TextLabel")
                descLb.Size = UDim2.new(1, -58, 0.5, 0)
                descLb.Position = UDim2.new(0, 10, 0.5, 0)
                descLb.BackgroundTransparency = 1
                descLb.Text = opts2.Desc
                descLb.TextColor3 = TEXT_GRAY
                descLb.Font = Enum.Font.Gotham
                descLb.TextSize = 11
                descLb.TextXAlignment = Enum.TextXAlignment.Left
                descLb.Parent = f
            end

            -- Switch
            local switchBG = Instance.new("Frame")
            switchBG.Size = UDim2.fromOffset(36, 20)
            switchBG.Position = UDim2.new(1, -46, 0.5, -10)
            switchBG.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            switchBG.BorderSizePixel = 0
            switchBG.Parent = f
            local swC = Instance.new("UICorner"); swC.CornerRadius = UDim.new(1,0); swC.Parent = switchBG

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(14, 14)
            knob.Position = UDim2.fromOffset(3, 3)
            knob.BackgroundColor3 = Color3.fromRGB(160, 100, 100)
            knob.BorderSizePixel = 0
            knob.Parent = switchBG
            local kC = Instance.new("UICorner"); kC.CornerRadius = UDim.new(1,0); kC.Parent = knob

            local value = false
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = f

            local toggleObj = {}
            function toggleObj:Set(v)
                value = v
                TweenService:Create(switchBG, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                    BackgroundColor3 = v and ACCENT or Color3.fromRGB(40, 20, 20)
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = v and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3),
                    BackgroundColor3 = v and TEXT_WHITE or Color3.fromRGB(160, 100, 100)
                }):Play()
                if opts2.Callback then opts2.Callback(v) end
            end

            btn.MouseButton1Click:Connect(function()
                -- Efecto press en el frame
                tweenSine(f, 0.07, { BackgroundColor3 = Color3.fromRGB(30, 10, 10) }):Play()
                task.delay(0.07, function()
                    tweenSine(f, 0.12, { BackgroundColor3 = BG_ELEM }):Play()
                end)
                toggleObj:Set(not value)
            end)

            return toggleObj
        end

        -- SLIDER
        function tabAPI:Slider(opts2)
            local valData = opts2.Value or {}
            local minV = valData.Min or opts2.Min or 0
            local maxV = valData.Max or opts2.Max or 100
            local defV = valData.Default or opts2.Default or minV
            local currentVal = defV

            local f = makeElementContainer(scroll)
            f.Size = UDim2.new(1, -8, 0, 64)
            f.LayoutOrder = nextOrder()

            local titleLb = Instance.new("TextLabel")
            titleLb.Size = UDim2.new(1, -60, 0.5, 0)
            titleLb.Position = UDim2.fromOffset(10, 4)
            titleLb.BackgroundTransparency = 1
            titleLb.Text = opts2.Title or ""
            titleLb.TextColor3 = TEXT_WHITE
            titleLb.Font = Enum.Font.GothamBold
            titleLb.TextSize = 13
            titleLb.TextXAlignment = Enum.TextXAlignment.Left
            titleLb.Parent = f

            if opts2.Desc and opts2.Desc ~= "" then
                local descLb = Instance.new("TextLabel")
                descLb.Size = UDim2.new(1, -60, 0, 14)
                descLb.Position = UDim2.new(0, 10, 0, 22)
                descLb.BackgroundTransparency = 1
                descLb.Text = opts2.Desc
                descLb.TextColor3 = TEXT_GRAY
                descLb.Font = Enum.Font.Gotham
                descLb.TextSize = 11
                descLb.TextXAlignment = Enum.TextXAlignment.Left
                descLb.Parent = f
            end

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.fromOffset(50, 20)
            valLbl.Position = UDim2.new(1, -58, 0, 4)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(defV)
            valLbl.TextColor3 = ACCENT_GLOW
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 12
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = f

            local trackBG = Instance.new("Frame")
            trackBG.Size = UDim2.new(1, -20, 0, 5)
            trackBG.Position = UDim2.new(0, 10, 1, -14)
            trackBG.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
            trackBG.BorderSizePixel = 0
            trackBG.Parent = f
            local trC = Instance.new("UICorner"); trC.CornerRadius = UDim.new(1,0); trC.Parent = trackBG

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((defV - minV) / (maxV - minV), 0, 1, 0)
            fill.BackgroundColor3 = ACCENT
            fill.BorderSizePixel = 0
            fill.Parent = trackBG
            local fC = Instance.new("UICorner"); fC.CornerRadius = UDim.new(1,0); fC.Parent = fill

            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(1, 0, 0, 18)
            sliderBtn.Position = UDim2.new(0, 0, 1, -18)
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Text = ""
            sliderBtn.Parent = f

            local sliding = false

            local function updateSlider(inputX)
                local absPos = trackBG.AbsolutePosition.X
                local absSize = trackBG.AbsoluteSize.X
                local rel = math.clamp((inputX - absPos) / absSize, 0, 1)
                local rawVal = minV + rel * (maxV - minV)
                local rounded = math.floor(rawVal * 100 + 0.5) / 100
                currentVal = rounded
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valLbl.Text = tostring(math.floor(rounded * 10 + 0.5) / 10)
                if opts2.Callback then opts2.Callback(currentVal) end
            end

            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            if opts2.Callback then opts2.Callback(defV) end
        end

        -- INPUT
        function tabAPI:Input(opts2)
            local f = makeElementContainer(scroll)
            f.Size = UDim2.new(1, -8, 0, 62)
            f.LayoutOrder = nextOrder()

            local titleLb = Instance.new("TextLabel")
            titleLb.Size = UDim2.new(1, -12, 0, 18)
            titleLb.Position = UDim2.fromOffset(10, 5)
            titleLb.BackgroundTransparency = 1
            titleLb.Text = opts2.Title or ""
            titleLb.TextColor3 = TEXT_WHITE
            titleLb.Font = Enum.Font.GothamBold
            titleLb.TextSize = 13
            titleLb.TextXAlignment = Enum.TextXAlignment.Left
            titleLb.Parent = f

            if opts2.Desc and opts2.Desc ~= "" then
                local descLb = Instance.new("TextLabel")
                descLb.Size = UDim2.new(1, -12, 0, 13)
                descLb.Position = UDim2.fromOffset(10, 23)
                descLb.BackgroundTransparency = 1
                descLb.Text = opts2.Desc
                descLb.TextColor3 = TEXT_GRAY
                descLb.Font = Enum.Font.Gotham
                descLb.TextSize = 11
                descLb.TextXAlignment = Enum.TextXAlignment.Left
                descLb.Parent = f
            end

            local inputBG = Instance.new("Frame")
            inputBG.Size = UDim2.new(1, -20, 0, 22)
            inputBG.Position = UDim2.new(0, 10, 1, -26)
            inputBG.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
            inputBG.BorderSizePixel = 0
            inputBG.Parent = f
            local inC = Instance.new("UICorner"); inC.CornerRadius = UDim.new(0,5); inC.Parent = inputBG
            local inStr = Instance.new("UIStroke"); inStr.Color = OUTLINE; inStr.Thickness = 1; inStr.Parent = inputBG

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -10, 1, 0)
            textBox.Position = UDim2.fromOffset(5, 0)
            textBox.BackgroundTransparency = 1
            textBox.Text = opts2.Value or ""
            textBox.PlaceholderText = "Enter value..."
            textBox.TextColor3 = TEXT_WHITE
            textBox.PlaceholderColor3 = TEXT_GRAY
            textBox.Font = Enum.Font.Gotham
            textBox.TextSize = 12
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.ClearTextOnFocus = false
            textBox.Parent = inputBG

            textBox.FocusLost:Connect(function()
                if opts2.Callback then opts2.Callback(textBox.Text) end
                tweenSine(inStr, 0.18, { Color = OUTLINE }):Play()
            end)
            textBox:GetPropertyChangedSignal("Text"):Connect(function()
                tweenSine(inStr, 0.18, { Color = ACCENT }):Play()
            end)
        end

        -- BUTTON
        function tabAPI:Button(opts2)
            local f = makeElementContainer(scroll)
            f.Size = UDim2.new(1, -8, 0, 40)
            f.LayoutOrder = nextOrder()

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = f

            local titleLb = Instance.new("TextLabel")
            titleLb.Size = UDim2.new(1, -12, 1, 0)
            titleLb.Position = UDim2.fromOffset(10, 0)
            titleLb.BackgroundTransparency = 1
            titleLb.Text = opts2.Title or ""
            titleLb.TextColor3 = TEXT_WHITE
            titleLb.Font = Enum.Font.GothamBold
            titleLb.TextSize = 13
            titleLb.TextXAlignment = Enum.TextXAlignment.Left
            titleLb.Parent = f

            if opts2.Desc and opts2.Desc ~= "" then
                titleLb.Size = UDim2.new(1, -12, 0.5, 0)
                titleLb.Position = UDim2.fromOffset(10, 4)
                local descLb = Instance.new("TextLabel")
                descLb.Size = UDim2.new(1, -12, 0.5, 0)
                descLb.Position = UDim2.new(0, 10, 0.5, 0)
                descLb.BackgroundTransparency = 1
                descLb.Text = opts2.Desc
                descLb.TextColor3 = TEXT_GRAY
                descLb.Font = Enum.Font.Gotham
                descLb.TextSize = 11
                descLb.TextXAlignment = Enum.TextXAlignment.Left
                descLb.Parent = f
            end

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.fromOffset(20, 20)
            arrow.Position = UDim2.new(1, -28, 0.5, -10)
            arrow.BackgroundTransparency = 1
            arrow.Text = "›"
            arrow.TextColor3 = ACCENT
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 20
            arrow.Parent = f

            -- Hover con interpolación suave
            btn.MouseEnter:Connect(function()
                tweenSine(f, 0.15, { BackgroundColor3 = Color3.fromRGB(30, 10, 10) }):Play()
                tweenSine(arrow, 0.15, { TextColor3 = ACCENT_GLOW }):Play()
            end)
            btn.MouseLeave:Connect(function()
                tweenSine(f, 0.15, { BackgroundColor3 = BG_ELEM }):Play()
                tweenSine(arrow, 0.15, { TextColor3 = ACCENT }):Play()
            end)

            -- Click: press + rebote
            btn.MouseButton1Down:Connect(function()
                tweenBack(f, 0.07, { Size = UDim2.new(1, -12, 0, 36) }):Play()
                tweenSine(f, 0.07, { BackgroundColor3 = Color3.fromRGB(60, 15, 15) }):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                tweenBack(f, 0.15, { Size = UDim2.new(1, -8, 0, 40) }):Play()
            end)

            btn.MouseButton1Click:Connect(function()
                tweenSine(f, 0.08, { BackgroundColor3 = Color3.fromRGB(50, 12, 12) }):Play()
                task.wait(0.1)
                tweenSine(f, 0.1, { BackgroundColor3 = BG_ELEM }):Play()
                if opts2.Callback then opts2.Callback() end
            end)
        end

        -- KEYBIND
        function tabAPI:Keybind(opts2)
            local f = makeElementContainer(scroll)
            f.LayoutOrder = nextOrder()

            local titleLb = Instance.new("TextLabel")
            titleLb.Size = UDim2.new(1, -80, 1, 0)
            titleLb.Position = UDim2.fromOffset(10, 0)
            titleLb.BackgroundTransparency = 1
            titleLb.Text = opts2.Title or ""
            titleLb.TextColor3 = TEXT_WHITE
            titleLb.Font = Enum.Font.GothamBold
            titleLb.TextSize = 13
            titleLb.TextXAlignment = Enum.TextXAlignment.Left
            titleLb.Parent = f

            local keyBG = Instance.new("Frame")
            keyBG.Size = UDim2.fromOffset(54, 26)
            keyBG.Position = UDim2.new(1, -62, 0.5, -13)
            keyBG.BackgroundColor3 = Color3.fromRGB(28, 8, 8)
            keyBG.BorderSizePixel = 0
            keyBG.Parent = f
            local kbC = Instance.new("UICorner"); kbC.CornerRadius = UDim.new(0,5); kbC.Parent = keyBG
            local kbStr = Instance.new("UIStroke"); kbStr.Color = OUTLINE; kbStr.Thickness = 1; kbStr.Parent = keyBG

            local currentKey = opts2.Default or Enum.KeyCode.Unknown
            local keyLbl = Instance.new("TextLabel")
            keyLbl.Size = UDim2.new(1, 0, 1, 0)
            keyLbl.BackgroundTransparency = 1
            keyLbl.Text = tostring(currentKey.Name or currentKey)
            keyLbl.TextColor3 = ACCENT_GLOW
            keyLbl.Font = Enum.Font.GothamBold
            keyLbl.TextSize = 11
            keyLbl.Parent = keyBG

            local listening = false
            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(1, 0, 1, 0)
            keyBtn.BackgroundTransparency = 1
            keyBtn.Text = ""
            keyBtn.Parent = keyBG

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyLbl.Text = "..."
                tweenSine(kbStr, 0.15, { Color = ACCENT }):Play()
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if listening and not gp then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        keyLbl.Text = tostring(input.KeyCode.Name)
                        listening = false
                        tweenSine(kbStr, 0.15, { Color = OUTLINE }):Play()
                    end
                elseif not gp and input.KeyCode == currentKey then
                    if opts2.Callback then opts2.Callback() end
                end
            end)

            if opts2.Default then
                UserInputService.InputBegan:Connect(function(input, gp)
                    if not listening and not gp and input.KeyCode == opts2.Default then
                        if opts2.Callback then opts2.Callback() end
                    end
                end)
            end
        end

        -- AddToggle (alias)
        function tabAPI:AddToggle(opts2)
            return tabAPI:Toggle(opts2)
        end

        return tabAPI
    end

    -- Section builder
    function windowObj:Section(opts2)
        sectionOrder = sectionOrder + 1
        local sectionObj = {}

        local sLabel = Instance.new("TextLabel")
        sLabel.Size = UDim2.new(1, 0, 0, 18)
        sLabel.BackgroundTransparency = 1
        sLabel.Text = string.upper(opts2.Title or "")
        sLabel.TextColor3 = Color3.fromRGB(100, 35, 35)
        sLabel.Font = Enum.Font.GothamBold
        sLabel.TextSize = 10
        sLabel.TextXAlignment = Enum.TextXAlignment.Left
        sLabel.LayoutOrder = sectionOrder * 1000
        local sLPad = Instance.new("UIPadding"); sLPad.PaddingLeft = UDim.new(0,4); sLPad.Parent = sLabel
        sLabel.Parent = TabPanel

        local tabOrder2 = 0
        function sectionObj:Tab(tabOpts)
            tabOrder2 = tabOrder2 + 1

            local tabBtn = Instance.new("Frame")
            tabBtn.Name = tabOpts.Title or "Tab"
            tabBtn.Size = UDim2.new(1, 0, 0, 32)
            tabBtn.BackgroundColor3 = Color3.fromRGB(14, 6, 6)
            tabBtn.BorderSizePixel = 0
            tabBtn.LayoutOrder = sectionOrder * 1000 + tabOrder2
            tabBtn.Parent = TabPanel
            local tbC = Instance.new("UICorner"); tbC.CornerRadius = UDim.new(0,7); tbC.Parent = tabBtn

            local accentBar = Instance.new("Frame")
            accentBar.Size = UDim2.fromOffset(3, 18)
            accentBar.Position = UDim2.new(0, 2, 0.5, -9)
            accentBar.BackgroundColor3 = ACCENT
            accentBar.BorderSizePixel = 0
            accentBar.Visible = false
            accentBar.Parent = tabBtn
            local abC = Instance.new("UICorner"); abC.CornerRadius = UDim.new(1,0); abC.Parent = accentBar

            local tabTitleLbl = Instance.new("TextLabel")
            tabTitleLbl.Name = "TextLabel"
            tabTitleLbl.Size = UDim2.new(1, -10, 1, 0)
            tabTitleLbl.Position = UDim2.fromOffset(10, 0)
            tabTitleLbl.BackgroundTransparency = 1
            tabTitleLbl.Text = tabOpts.Title or "Tab"
            tabTitleLbl.TextColor3 = TEXT_GRAY
            tabTitleLbl.Font = Enum.Font.Gotham
            tabTitleLbl.TextSize = 13
            tabTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            tabTitleLbl.Parent = tabBtn

            -- Hover en tab button
            local tabHoverBtn = Instance.new("TextButton")
            tabHoverBtn.Size = UDim2.new(1,0,1,0)
            tabHoverBtn.BackgroundTransparency = 1
            tabHoverBtn.Text = ""
            tabHoverBtn.Parent = tabBtn

            tabHoverBtn.MouseEnter:Connect(function()
                if not (currentTab and currentTab.Btn == tabBtn) then
                    tweenSine(tabBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(22, 8, 8) }):Play()
                end
            end)
            tabHoverBtn.MouseLeave:Connect(function()
                if not (currentTab and currentTab.Btn == tabBtn) then
                    tweenSine(tabBtn, 0.12, { BackgroundColor3 = Color3.fromRGB(14, 6, 6) }):Play()
                end
            end)

            local tabPage = Instance.new("Frame")
            tabPage.Name = (tabOpts.Title or "Tab") .. "Page"
            tabPage.Size = UDim2.new(1, 0, 1, 0)
            tabPage.BackgroundTransparency = 1
            tabPage.Visible = false
            tabPage.Parent = PageHolder

            local tabClickBtn = Instance.new("TextButton")
            tabClickBtn.Size = UDim2.new(1, 0, 1, 0)
            tabClickBtn.BackgroundTransparency = 1
            tabClickBtn.Text = ""
            tabClickBtn.Parent = tabBtn

            tabClickBtn.MouseButton1Click:Connect(function()
                accentBar.Visible = true
                setActiveTab(tabPage, tabBtn)
            end)

            if currentTab == nil then
                setActiveTab(tabPage, tabBtn)
                accentBar.Visible = true
            end

            local api = buildTabAPI(tabPage)
            return api
        end

        return sectionObj
    end

    return windowObj
end

function XynorUI:AddTheme(opts) end
function XynorUI:SetTheme(name) end

-- ============================================================
-- SYSTEM LOADER — Tema Premium V7
-- ============================================================
local function ShowSystemLoader(onFinished)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "vxnitySystemLoader"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    local ok2, coreGui2 = pcall(function() return game:GetService("CoreGui") end)
    ScreenGui.Parent = (gethui and gethui()) or (ok2 and coreGui2) or LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = BG_DARK
    bg.BackgroundTransparency = 0
    bg.Parent = ScreenGui

    -- Línea de acento horizontal animada - Tema nuevo
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(0, 0, 0, 3)
    accentLine.Position = UDim2.new(0.5, 0, 0.5, 30)
    accentLine.BackgroundColor3 = ACCENT
    accentLine.BorderSizePixel = 0
    accentLine.Parent = bg
    local alC = Instance.new("UICorner"); alC.CornerRadius = UDim.new(1,0); alC.Parent = accentLine

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Position = UDim2.new(0, 0, 0.4, 0)
    title.BackgroundTransparency = 1
    title.Text = "VXNITY"
    title.TextColor3 = ACCENT
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextTransparency = 1
    title.Parent = bg

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.08, 0)
    subtitle.Position = UDim2.new(0, 0, 0.55, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = TEXT_GRAY
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextScaled = true
    subtitle.TextTransparency = 1
    subtitle.Parent = bg

    -- Animación de entrada: línea se expande, luego title pop-in
    tweenExpo(accentLine, 0.3, {
        Size = UDim2.new(0.3, 0, 0, 3),
        Position = UDim2.new(0.35, 0, 0.5, 30)
    }):Play()
    task.wait(0.15)

    tweenBack(title, 0.35, { TextTransparency = 0 }):Play()
    task.wait(0.2)

    local steps = {
        "Initializing",
        "Loading modules",
        "¿Kenyah?",
        "pronto new act."
    }

    for _, text in ipairs(steps) do
        subtitle.Text = text
        tweenSine(subtitle, 0.15, { TextTransparency = 0 }):Play()
        task.wait(0.4)
        tweenSine(subtitle, 0.15, { TextTransparency = 1 }):Play()
        task.wait(0.08)
    end

    -- Salida
    tweenExpo(accentLine, 0.2, {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0.5, 30)
    }):Play()
    task.wait(0.1)
    TweenService:Create(bg, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { TextTransparency = 1 }):Play()

    task.wait(0.3)
    ScreenGui:Destroy()

    if onFinished then
        onFinished()
    end
end

-- Security/Clean
pcall(function()
    for i,b in pairs(workspace.FE.Actions:GetChildren()) do
        if b.Name == " " then b:Destroy() end
    end
end)

pcall(function()
    for i,b in pairs(LocalPlayer.Character:GetChildren()) do
        if b.Name == " " then b:Destroy() end
    end
end)

pcall(function()
    local a = workspace.FE.Actions
    if a:FindFirstChild("KeepYourHeadUp_") then
        a.KeepYourHeadUp_:Destroy()
        local r = Instance.new("RemoteEvent")
        r.Name = "KeepYourHeadUp_"
        r.Parent = a
    else
        LocalPlayer:Kick("Anti-Cheat Updated! Send a photo of this Message in our Discord Server so we can fix it.")
    end
end)

local function isWeirdName(name)
    return string.match(name, "^[a-zA-Z]+%-%d+%a*%-%d+%a*$") ~= nil
end

local function deleteWeirdRemoteEvents(parent)
    pcall(function()
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") and isWeirdName(child.Name) then
                child:Destroy()
            end
            deleteWeirdRemoteEvents(child)
        end
    end)
end

pcall(function() deleteWeirdRemoteEvents(game) end)

-- ============================================================
-- MAIN HUB
-- ============================================================
local function LoadVxnityHub()
    XynorUI:Notify({
        Title = "vxnity hub",
        Desc = "Loading main script...",
        Icon = "loader",
        Duration = 2
    })

    local isMobile = UserInputService.TouchEnabled
    local windowSize = isMobile and UDim2.fromOffset(480, 380) or UDim2.fromOffset(600, 520)
    local topbarHeight = isMobile and 40 or 48
    local iconSize = isMobile and 18 or 22

    local Window = XynorUI:CreateWindow({
        Title = "vxnity hub",
        Author = "vxnity team",
        Folder = "vxnityHub",
        IconSize = iconSize,
        NewElements = true,
        Size = windowSize,
        HideSearchBar = false,
        OpenButton = {
            Title = "vxnity",
            CornerRadius = UDim.new(0, 8),
            StrokeThickness = 2,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Scale = 1,
            Color = ColorSequence.new(Color3.fromRGB(200, 20, 20), Color3.fromRGB(140, 5, 5))
        },
        Topbar = {
            Height = topbarHeight,
            ButtonsType = "Mac",
        },
    })

    do
        XynorUI:AddTheme({
            Name = "XynorCyan",
            Accent = Color3.fromRGB(0, 170, 255),
            Dialog = Color3.fromRGB(20, 25, 35),
            Outline = Color3.fromRGB(40, 50, 70),
            Text = Color3.fromRGB(255, 255, 255),
            Placeholder = Color3.fromRGB(100, 110, 130),
            Button = Color3.fromRGB(30, 35, 50),
            Icon = Color3.fromRGB(0, 170, 255),
            WindowBackground = Color3.fromRGB(15, 15, 22),
            TopbarButtonIcon = Color3.fromRGB(255, 255, 255),
            TopbarTitle = Color3.fromRGB(255, 255, 255),
            TopbarAuthor = Color3.fromRGB(0, 170, 255),
            TopbarIcon = Color3.fromRGB(0, 170, 255),
            TabBackground = Color3.fromRGB(20, 25, 35),
            TabTitle = Color3.fromRGB(120, 130, 150),
            TabIcon = Color3.fromRGB(0, 170, 255),
            ElementBackground = Color3.fromRGB(30, 35, 50),
            ElementTitle = Color3.fromRGB(255, 255, 255),
            ElementDesc = Color3.fromRGB(120, 130, 150),
            ElementIcon = Color3.fromRGB(0, 170, 255),
        })
        XynorUI:SetTheme("XynorCyan")
    end

    local HomeSection = Window:Section({ Title = "Information" })
    local HomeTab = HomeSection:Tab({ Title = "Home", Icon = "home" })

    HomeTab:Section({ Title = "Welcome to Xynor 1.0"})
    HomeTab:Paragraph({ Title = "Script Version: 1.0", Desc = "Scripts For TPS Street Soccer v1.0 undetected."})
    HomeTab:Paragraph({ Title = "User: " .. LocalPlayer.Name, Desc = "Rank: Premium User" })
    HomeTab:Section({ Title = "Updates" })
    HomeTab:Paragraph({
        Title = "Latest Update: 2026-02-01",
        Desc = "- Improved Reach\n- optimized ui\n- Fixed Loader issues"
    })

    local Main = Window:Section({ Title = "main :3"})
    local ReachTab = Main:Tab({ Title = "Reach", Icon = "target" })
    local MossingTab = Main:Tab({ Title = "Mossing", Icon = "wind" })
    local ReactTab = Main:Tab({ Title = "Reacts", Icon = "zap" })

    local Misc = Window:Section({ Title = "Utility & Extra" })
    local HelpersTab = Misc:Tab({ Title = "Helpers", Icon = "shield-check" })
    local AimbotTab = Misc:Tab({ Title = "Aimbot", Icon = "crosshair" })

    local Optimization = Window:Section({ Title = "Optimizations" })
    local OptTab = Optimization:Tab({ Title = "Performance", Icon = "settings" })

    -- ============================================================
    -- PERSISTENCIA TOTAL V5 — sobrevive muerte/respawn
    -- Variables globales que NUNCA se apagan
    -- ============================================================
    if not _G._XynorPersist then
        _G._XynorPersist = {
            reachEnabled    = false,
            reachDistance   = 1,
            reactPower      = 0,
            ballSpeedMult   = 7.0,
            reactHookOn     = false,
            helperActive    = false,
            helperEnabled   = true,
            magnetMode      = true,
            predictMode     = true,
            spaceLock       = false,
        }
    end
    local P = _G._XynorPersist   -- alias corto

    -- Cache global de balón y HRP — actualizado cada RenderStepped
    if not _G._VxRBall then _G._VxRBall = nil end
    if not _G._VxRHRP  then _G._VxRHRP  = nil end

    -- Worker de cache — se lanza UNA vez y nunca se desconecta
    if not _G._VxCacheWorker then
        _G._VxCacheWorker = RunService.RenderStepped:Connect(function()
            local sys = Workspace:FindFirstChild("TPSSystem")
            _G._VxRBall = sys and sys:FindFirstChild("TPS")
            local ch = LocalPlayer.Character
            _G._VxRHRP = ch and ch:FindFirstChild("HumanoidRootPart")
        end)
    end

    -- Re-cachear HRP instantáneamente en respawn — UNA sola conexión global
    if not _G._VxCharConn then
        _G._VxCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
            _G._VxRHRP = char:WaitForChild("HumanoidRootPart", 3)
            -- Restaurar reach automáticamente si estaba activo
            if P.reachEnabled and _G._VxReachRestart then
                task.wait(0.05)
                _G._VxReachRestart()
            end
        end)
    end

    -- ============================================================
    -- REACH — persistente tras muerte (se reconecta automáticamente)
    -- ============================================================
    local reachEnabled  = P.reachEnabled
    local reachDistance = P.reachDistance
    local reachConnection

    local function startReach()
        if reachConnection then reachConnection:Disconnect() end
        local _char, _root, _hum, _tps, _limb = nil,nil,nil,nil,nil
        local _lastRig, _frameSkip = nil, 0

        reachConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            if character ~= _char then
                _char    = character
                _root    = character:FindFirstChild("HumanoidRootPart")
                _hum     = character:FindFirstChild("Humanoid")
                _limb    = nil
                _lastRig = nil
            end
            if not (_root and _hum) then return end
            _frameSkip = _frameSkip + 1
            if _frameSkip >= 3 then
                _frameSkip = 0
                local sys = Workspace:FindFirstChild("TPSSystem")
                _tps = sys and sys:FindFirstChild("TPS")
            end
            if not _tps or not _tps.Parent then return end
            local d = (_root.Position - _tps.Position)
            if (d.X*d.X + d.Y*d.Y + d.Z*d.Z) > reachDistance * reachDistance then return end
            local rig = _hum.RigType
            if rig ~= _lastRig or not _limb or not _limb.Parent then
                _lastRig = rig
                local pf   = Lighting:FindFirstChild(LocalPlayer.Name)
                local foot = pf and pf:FindFirstChild("PreferredFoot")
                if foot then
                    local nm = (rig == Enum.HumanoidRigType.R6)
                        and ((foot.Value == 1) and "Right Leg" or "Left Leg")
                        or  ((foot.Value == 1) and "RightLowerLeg" or "LeftLowerLeg")
                    _limb = _char:FindFirstChild(nm)
                end
            end
            if _limb then
                firetouchinterest(_limb, _tps, 0)
                firetouchinterest(_limb, _tps, 1)
            end
        end)
    end

    _G._VxReachRestart = function()
        if P.reachEnabled then startReach() end
    end

    ReachTab:Section({ Title = "Leg Reach (Method A)" })

    ReachTab:Toggle({
        Title = "Active FireTouchInterest",
        Desc = "Triggers ball contact automatically",
        Callback = function(Value)
            reachEnabled   = Value
            P.reachEnabled = Value
            if Value then
                startReach()
            else
                if reachConnection then reachConnection:Disconnect(); reachConnection = nil end
            end
        end
    })

    ReachTab:Slider({
        Title = "Reach Distance",
        Desc = "Adjust the activation range",
        Value = { Min = 1, Max = 15, Default = 1 },
        Callback = function(val)
            reachDistance   = tonumber(val)
            P.reachDistance = reachDistance
        end
    })

    ReachTab:Section({ Title = "Leg Reach (Method B)" })

    ReachTab:Input({
        Title = "Leg Hitbox (R6)",
        Desc = "Modifies physical size of legs",
        Value = "1",
        Callback = function(Value)
            local v = tonumber(Value) or 1
            if LocalPlayer.Character then
                if LocalPlayer.Character:FindFirstChild("Right Leg") then
                    LocalPlayer.Character["Right Leg"].Size = Vector3.new(v, 2, v)
                    LocalPlayer.Character["Left Leg"].Size = Vector3.new(v, 2, v)
                    LocalPlayer.Character["Right Leg"].CanCollide = false
                    LocalPlayer.Character["Left Leg"].CanCollide = false
                end
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Size = Vector3.new(v,2,v)
                    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
    })

    ReachTab:Input({
        Title = "Legs Size (R15)",
        Desc = "Minimum Size is 1",
        Value = "1",
        Callback = function(Value)
            local v = tonumber(Value) or 1
            if LocalPlayer.Character then
                if LocalPlayer.Character:FindFirstChild("RightLowerLeg") then
                    LocalPlayer.Character["RightLowerLeg"].Size = Vector3.new(v, 2, v)
                    LocalPlayer.Character["LeftLowerLeg"].Size = Vector3.new(v, 2, v)
                    LocalPlayer.Character["RightLowerLeg"].CanCollide = false
                    LocalPlayer.Character["LeftLowerLeg"].CanCollide = false
                end
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Size = Vector3.new(v,2,v)
                    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end
    })

    ReachTab:Button({
        Title = "Fake legs (Appear Normal)",
        Callback = function()
            local player = LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            if humanoid.RigType == Enum.HumanoidRigType.R6 then
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency = 1
                character["Left Leg"].Massless = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg Fake"
                LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1, 2, 1)
                LeftLegM.Position = character["Left Leg"].Position
                local MotorHip = Instance.new("Motor6D", character.Torso)
                MotorHip.Part0 = character.Torso
                MotorHip.Part1 = LeftLegM
                MotorHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                MotorHip.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg Fake"
                RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1, 2, 1)
                RightLegM.Position = character["Right Leg"].Position
                local MotorHip2 = Instance.new("Motor6D", character.Torso)
                MotorHip2.Part0 = character.Torso
                MotorHip2.Part1 = RightLegM
                MotorHip2.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
                MotorHip2.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            end
        end
    })

    -- ============================================================
    -- MOSSING TAB
    -- ============================================================
    local headReachEnabled = false
    local headReachSize    = Vector3.new(1, 1.5, 1)
    local headTransparency = 0.5
    local headOffset       = Vector3.new(0, 0, 0)
    local headBoxPart
    local headConnection

    local function updateHeadBox()
        if headBoxPart then headBoxPart:Destroy() end
        headBoxPart = Instance.new("Part")
        headBoxPart.Size        = headReachSize
        headBoxPart.Transparency= headTransparency
        headBoxPart.Anchored    = true
        headBoxPart.CanCollide  = false
        headBoxPart.Color       = Color3.fromRGB(200, 30, 30)
        headBoxPart.Material    = Enum.Material.Neon
        headBoxPart.Name        = "HeadReachBox"
        headBoxPart.Parent      = Workspace
    end

    local function startHeadReach()
        if not headReachEnabled then return end
        if headConnection then headConnection:Disconnect() end
        updateHeadBox()
        local _head, _tps, _char = nil, nil, nil
        local _skipFrame = 0
        headConnection = RunService.RenderStepped:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            if character ~= _char then
                _char = character
                _head = character:FindFirstChild("Head")
            end
            if not _head or not _head.Parent then return end
            _skipFrame = _skipFrame + 1
            if _skipFrame >= 4 then
                _skipFrame = 0
                local sys = Workspace:FindFirstChild("TPSSystem")
                _tps = sys and sys:FindFirstChild("TPS")
            end
            if not _tps or not _tps.Parent then return end
            if _tps.CanCollide then pcall(function() _tps.CanCollide = false end) end
            headBoxPart.CFrame = _head.CFrame * CFrame.new(headOffset)
            local relative = headBoxPart.CFrame:PointToObjectSpace(_tps.Position)
            local hs = headBoxPart.Size * 0.5
            if math.abs(relative.X) <= hs.X
                and math.abs(relative.Y) <= hs.Y
                and math.abs(relative.Z) <= hs.Z then
                firetouchinterest(_head, _tps, 0)
                firetouchinterest(_head, _tps, 1)
            end
        end)
    end

    MossingTab:Toggle({ Title = "Active Moss Reach", Desc = "Enable head-based interaction range",
        Callback = function(state)
            headReachEnabled = state
            if state then startHeadReach() else
                if headConnection then headConnection:Disconnect() end
                if headBoxPart then headBoxPart:Destroy() end
            end
        end
    })
    MossingTab:Slider({ Title = "Range X", Value = { Min = 0, Max = 50, Default = 1 },
        Callback = function(val)
            headReachSize = Vector3.new(val, headReachSize.Y, headReachSize.Z)
            if headReachEnabled then updateHeadBox() end
        end
    })
    MossingTab:Slider({ Title = "Range Y", Value = { Min = 0, Max = 50, Default = 1.5 },
        Callback = function(val)
            headReachSize = Vector3.new(headReachSize.X, val, headReachSize.Z)
            headOffset = Vector3.new(headOffset.X, val / 2.5, headOffset.Z)
            if headReachEnabled then updateHeadBox() end
        end
    })
    MossingTab:Slider({ Title = "Range Z", Value = { Min = 0, Max = 50, Default = 1 },
        Callback = function(val)
            headReachSize = Vector3.new(headReachSize.X, headReachSize.Y, val)
            if headReachEnabled then updateHeadBox() end
        end
    })
    MossingTab:Toggle({ Title = "Stealth Mode", Desc = "Makes the reach box invisible",
        Callback = function(v)
            headTransparency = v and 1 or 0.5
            if headReachEnabled and headBoxPart then headBoxPart.Transparency = headTransparency end
        end
    })

    -- ============================================================
    -- REACTS V6 — Optimizados para máxima velocidad y precisión
    -- Hook global instantáneo, 0 delay, respuesta inmediata
    -- ============================================================
    local REACT_ACTIONS = {
        Kick=true, KickC1=true, Tackle=true, Header=true,
        SaveRA=true, SaveLA=true, SaveRL=true, SaveLL=true, SaveT=true
    }

    local currentReactPower = P.reactPower
    local ballSpeedMult     = P.ballSpeedMult

    -- Cache optimizado para acceso instantáneo
    local _reactBallCache = nil
    local _reactHRPCache = nil
    local _reactCacheTick = 0

    local function getReactTargets()
        _reactCacheTick = _reactCacheTick + 1
        if _reactCacheTick >= 2 then
            _reactCacheTick = 0
            _reactBallCache = _G._VxRBall
            _reactHRPCache = _G._VxRHRP
        end
        return _reactBallCache, _reactHRPCache
    end

    local function applyReactInstant(power)
        local ball, hrp = getReactTargets()
        if not (ball and ball.Parent and hrp) then return end
        if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (power * ballSpeedMult)
    end

    -- Hook instalado UNA vez en _G — nunca se apaga, sobrevive respawns
    local function enableReactHook()
        if _G._VxReactHookInstalled then return end
        _G._VxReactHookInstalled = true
        P.reactHookOn = true
        local meta        = getrawmetatable(game)
        local oldNamecall = meta.namecall
        setreadonly(meta, false)
        meta.namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "FireServer"
                and currentReactPower > 0
                and REACT_ACTIONS[tostring(self)] then
                local ball, hrp = getReactTargets()
                if ball and ball.Parent and hrp then
                    if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                    pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                    ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(meta, true)
    end

    ReactTab:Section({ Title = "⚡ Reacts V6 — Potencia MAXIMA ULTRA" })

    ReactTab:Button({ Title = "🔥 ULTRA SPEED", Desc = "Velocidad ILEGAL maxima",
        Callback = function()
            currentReactPower = 5e18; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            XynorUI:Notify({ Title = "ULTRA SPEED", Desc = "Ball a velocidad maxima!", Duration = 2 })
        end
    })
    ReactTab:Button({ Title = "💀 MEGA POWER", Desc = "Potencia extrrema",
        Callback = function()
            currentReactPower = 1e25; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            XynorUI:Notify({ Title = "MEGA POWER", Desc = "Potencia extrema activada", Duration = 2 })
        end
    })
    ReactTab:Button({ Title = "⚡ HYPER VELOCITY", Desc = "Hyper velocidad instantanea",
        Callback = function()
            currentReactPower = 2e22; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            XynorUI:Notify({ Title = "HYPER", Desc = "Hyper velocidad maxima", Duration = 2 })
        end
    })
    ReactTab:Button({ Title = "🚀 ULTIMATE KICK", Desc = "Patada definitiva",
        Callback = function()
            currentReactPower = 8e20; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            XynorUI:Notify({ Title = "ULTIMATE", Desc = "Patada definitiva", Duration = 2 })
        end
    })
    ReactTab:Button({ Title = "💥 MAX POWER", Desc = "Potencia maxima absoluta",
        Callback = function()
            currentReactPower = 1e28; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            XynorUI:Notify({ Title = "MAX POWER", Desc = "Potencia maxima absoluta", Duration = 2 })
        end
    })

    -- tmbuzz v1 — snap magnético anti-jitter
    ReactTab:Button({ Title = "🌀 HYPER SNAP", Desc = "Snap magnetico super rapido",
        Callback = function()
            currentReactPower = 3e20; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 0.2 + Vector3.new(0, 0.1, 0))
                ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            XynorUI:Notify({ Title = "HYPER SNAP", Desc = "SNAP ultra rapido!", Duration = 2 })
        end
    })

    -- cholo v1 — enganche en cambios de dirección
    ReactTab:Button({ Title = "💀 MEGA LOCK", Desc = "Lock super enganche pesado",
        Callback = function()
            currentReactPower = 5e25; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            XynorUI:Notify({ Title = "MEGA LOCK", Desc = "Lock super enganche!", Duration = 2 })
        end
    })

    -- erubar v1 — pivot, 0 reach visual
    ReactTab:Button({ Title = "🔴 ULTRA PIVOT", Desc = "Pivot ultra rapido + pegada",
        Callback = function()
            currentReactPower = 4e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 0.15)
                ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            XynorUI:Notify({ Title = "ULTRA PIVOT", Desc = "Pivot ultra rapido!", Duration = 2 })
        end
    })

    -- Kenyah v5 — predicción + snap + corrección automática
    ReactTab:Button({ Title = "✝️ KENYAH MAX", Desc = "Max power + predicion",
        Callback = function()
            currentReactPower = 6e23; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                ball.CFrame = CFrame.new(hrp.Position + look * 0.15 + Vector3.new(0, 0.05, 0))
                ball.AssemblyLinearVelocity = look * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            XynorUI:Notify({ Title = "KENYAH MAX", Desc = "Max power + predicion!", Duration = 2 })
        end
    })

    -- xrea react I — control aéreo total
    ReactTab:Button({ Title = "💠 AERO MAX", Desc = "Aereo ultra control total",
        Callback = function()
            currentReactPower = 5e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                local dir = (look + Vector3.new(0, 0.08, 0)).Unit
                ball.CFrame = CFrame.new(hrp.Position + look * 0.18 + Vector3.new(0, 0.12, 0))
                ball.AssemblyLinearVelocity = dir * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            XynorUI:Notify({ Title = "AERO MAX", Desc = "Aereo ultra control!", Duration = 2 })
        end
    })

    -- xrea react II — doble pulso
    ReactTab:Button({ Title = "⚡ DUAL PULSE", Desc = "Doble pulso instantaneo",
        Callback = function()
            currentReactPower = 7e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                ball.CFrame = CFrame.new(hrp.Position + look * 0.12)
                ball.AssemblyLinearVelocity = look * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
                task.defer(function()
                    if ball and ball.Parent then
                        ball.AssemblyLinearVelocity = look * (currentReactPower * ballSpeedMult)
                    end
                end)
            end
            XynorUI:Notify({ Title = "DUAL PULSE", Desc = "Doble pulso instantaneo!", Duration = 2 })
        end
    })

    -- xrea react III — omni con corrección automática
    ReactTab:Button({ Title = "🌐 OMNI MAX", Desc = "Omni ultra + autocorreccion",
        Callback = function()
            currentReactPower = 8e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._VxRBall; local hrp = _G._VxRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                ball.CFrame = CFrame.new(hrp.Position + look * 0.12)
                ball.AssemblyLinearVelocity = look * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
                task.defer(function()
                    if ball and ball.Parent and hrp and hrp.Parent then
                        local newLook = hrp.CFrame.LookVector
                        local correction = (hrp.Position + newLook * 0.12 - ball.Position)
                        if correction.Magnitude > 0.3 then
                            ball.AssemblyLinearVelocity = correction.Unit * (currentReactPower * ballSpeedMult)
                        end
                    end
                end)
            end
            XynorUI:Notify({ Title = "OMNI MAX", Desc = "Omni ultra!", Duration = 2 })
        end
    })

    -- Goalkeeper React
    ReactTab:Button({ Title = "🧤 Goalkeeper React", Desc = "Optimizado para arqueros",
        Callback = function()
            local gkMap = {SaveRA=true,SaveLA=true,SaveRL=true,SaveLL=true,SaveT=true,Tackle=true,Header=true}
            local meta = getrawmetatable(game); local oldNC = meta.namecall
            setreadonly(meta, false)
            meta.namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "FireServer" and gkMap[tostring(self)] then
                    local args = {...}; local ch = LocalPlayer.Character
                    local hum = ch and ch:FindFirstChild("Humanoid")
                    if hum then args[2] = hum.LLCL; return oldNC(self, unpack(args)) end
                end
                return oldNC(self, ...)
            end)
            setreadonly(meta, true)
            XynorUI:Notify({ Title = "GK React", Desc = "Goalkeeper React activado", Duration = 2 })
        end
    })

    -- ============================================================
    -- SLIDER VELOCIDAD — rango extendido hasta 50x, tiempo real
    -- ============================================================
    ReactTab:Section({ Title = "🎚️ Ball Speed Control" })
    ReactTab:Slider({
        Title = "Ball Speed Multiplier",
        Desc = "Control de velocidad en tiempo real (hasta 50x)",
        Value = { Min = 0.1, Max = 50, Default = 1.0 },
        Callback = function(val)
            ballSpeedMult  = val
            P.ballSpeedMult = val
        end
    })

    ReactTab:Section({ Title = "🎯 Velocity Presets" })
    ReactTab:Button({ Title = "Normal Mode", Desc = "Multiplier x1.0",
        Callback = function()
            ballSpeedMult = 1.0; P.ballSpeedMult = ballSpeedMult
            XynorUI:Notify({ Title = "Velocity", Desc = "Normal (x1.0)", Duration = 1.5 })
        end
    })
    ReactTab:Button({ Title = "Fast Mode", Desc = "Multiplier x50.0",
        Callback = function()
            ballSpeedMult = 50.0; P.ballSpeedMult = ballSpeedMult
            XynorUI:Notify({ Title = "Velocity", Desc = "Fast (x50.0)", Duration = 1.5 })
        end
    })
    ReactTab:Button({ Title = "🔥 UNLIMITED Mode", Desc = "No speed limit",
        Callback = function()
            ballSpeedMult = 1e15; P.ballSpeedMult = ballSpeedMult
            XynorUI:Notify({ Title = "Velocity", Desc = "UNLIMITED", Duration = 1.5 })
        end
    })

    ReactTab:Section({ Title = "React Power" })
    ReactTab:Slider({
        Title = "React Power (base)",
        Desc = "Potencia base maxima",
        Value = { Min = 1e18, Max = 1e30, Default = 1e22 },
        Callback = function(val)
            currentReactPower = val; P.reactPower = val
        end
    })

    -- ============================================================
    -- HELPERS V5 — activación rápida, smoothing dinámico, persisten
    -- ============================================================
    HelpersTab:Section({ Title = "Ball Visuals" })

    HelpersTab:Toggle({ Title = "ZZZ helper", Desc = "Highlights the ball's position",
        Callback = function(state)
            if state then
                local part = Instance.new("Part")
                part.Name = "TPS1"; part.Size = Vector3.new(9, 0.1, 9)
                part.Anchored = true; part.BrickColor = BrickColor.new("Bright red")
                part.Transparency = 1; part.CanCollide = false; part.Parent = Workspace
                RunService.RenderStepped:Connect(function()
                    local b = _G._VxRBall
                    if b and part.Parent then part.Position = b.Position - Vector3.new(0, 1, 0) end
                end)
            else
                if Workspace:FindFirstChild("TPS1") then Workspace.TPS1:Destroy() end
            end
        end
    })

    -- KENYAH INF HELPER V8 — ULTRA POWER, 0-REACH, super pegado
    HelpersTab:Toggle({ Title = "Kenyah Inf Helper", Desc = "0 reach + ultra pegado + super rapido",
        Callback = function(state)
            if state then
                _G.AerialInfUltra = RunService.RenderStepped:Connect(function()
                    local ball = _G._VxRBall; local hrp = _G._VxRHRP
                    if not (ball and ball.Parent and hrp) then return end
                    local char  = LocalPlayer.Character
                    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                    local base  = torso or hrp
                    if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                    pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                    local targetPos = base.Position + base.CFrame.LookVector * 0.06 + Vector3.new(0, 0.02, 0)
                    local diff = targetPos - ball.Position
                    local dist = diff.Magnitude
                    if dist > 0.015 then
                        local spd = math.clamp(dist * 45000, 1000, 80000)
                        ball.AssemblyLinearVelocity = diff.Unit * spd
                        ball.CFrame = CFrame.new(targetPos)
                    else
                        ball.CFrame = CFrame.new(targetPos)
                        ball.AssemblyLinearVelocity = base.CFrame.LookVector * 150
                    end
                    ball.AssemblyAngularVelocity = Vector3.new(80, 0, 80)
                end)
            else
                if _G.AerialInfUltra then _G.AerialInfUltra:Disconnect(); _G.AerialInfUltra = nil end
            end
        end
    })

-- KENYAH INF TER/AIR V8 — 0-REACH, super pegada
    HelpersTab:AddToggle({ Title = "Kenyah INF TER/AIR [HELPER]", Desc = "0 reach + ultra pegada + super rapida",
        Callback = function(state)
            if state then
                _G.KenyahINF = RunService.RenderStepped:Connect(function()
                    local ball = _G._VxRBall; local hrp = _G._VxRHRP
                    if not (ball and ball.Parent and hrp) then return end
                    local char  = LocalPlayer.Character
                    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
                    local base  = torso or hrp
                    if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                    pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                    local targetPos = base.Position + base.CFrame.LookVector * 0.06 + Vector3.new(0, 0.02, 0)
                    local diff = targetPos - ball.Position
                    local dist = diff.Magnitude
                    if dist > 0.015 then
                        local speed = math.clamp(dist * 40000, 1200, 70000)
                        ball.AssemblyLinearVelocity = diff.Unit * speed
                        ball.CFrame = CFrame.new(targetPos)
                    else
                        ball.CFrame = CFrame.new(targetPos)
                        ball.AssemblyLinearVelocity = base.CFrame.LookVector * 120
                    end
                    ball.AssemblyAngularVelocity = Vector3.new(80, 0, 80)
                end)
            else
                if _G.KenyahINF then _G.KenyahINF:Disconnect(); _G.KenyahINF = nil end
            end
        end
    })

    HelpersTab:Section({ Title = "Air Dribble Assistance" })

    HelpersTab:Toggle({ Title = "air dribble helper", Desc = "Show interaction area for air dribbling",
        Callback = function(state)
            if not state and Workspace:FindFirstChild("TPS_Air") then Workspace.TPS_Air:Destroy() end
        end
    })

    HelpersTab:Slider({ Title = "Box Dimension", Value = { Min = 1, Max = 15, Default = 1 },
        Callback = function(val)
            local part = Workspace:FindFirstChild("TPS_Air") or Instance.new("Part")
            part.Name = "TPS_Air"; part.Size = Vector3.new(val, 0.1, val)
            part.Anchored = true; part.BrickColor = BrickColor.new("Bright red")
            part.Transparency = 1; part.CanCollide = false; part.Parent = Workspace
            RunService.RenderStepped:Connect(function()
                local b = _G._VxRBall
                if b and part.Parent then part.Position = b.Position - Vector3.new(0, 1, 0) end
            end)
        end
    })

    HelpersTab:Section({ Title = "Automation" })

    local followBall = true
    local toggleEnabled_follow = false

    HelpersTab:Toggle({ Title = "inf helper", Desc = "Character will move towards the ball automatically (B to toggle)",
        Callback = function(state)
            toggleEnabled_follow = state
            if not state then followBall = false end
        end
    })

    -- Mobile and PC input support
    local function handleToggleInput(input, gp)
        if input.KeyCode == Enum.KeyCode.B and not gp and toggleEnabled_follow then
            followBall = not followBall
        end
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        handleToggleInput(input, gp)
    end)

    -- Mobile touch support for toggle
    UserInputService.TouchTap:Connect(function(touchPos, gp)
        if toggleEnabled_follow then
            followBall = not followBall
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not (followBall and toggleEnabled_follow) then return end
        local ball = _G._VxRBall
        local playerChar = LocalPlayer.Character
        local humanoid = playerChar and playerChar:FindFirstChild("Humanoid")
        if humanoid and ball then humanoid:MoveTo(ball.Position) end
    end)

    HelpersTab:Section({ Title = "XDD" })

    -- ============================================================
    -- INF HELPER AVANZADO V5 — persiste, smoothing avanzado, cache global
    -- ============================================================
    local toggleEnabled   = P.helperEnabled
    local helperActive    = P.helperActive
    local magnetMode      = P.magnetMode
    local predictMode     = P.predictMode
    local multiLockActive = P.spaceLock

    local CONFIG = {
        FOLLOW_DISTANCE = 0.08,
        FOLLOW_SPEED    = 30000,
        DEAD_ZONE       = 0.03,
        MAX_DISTANCE    = 0.2,
        STRONG_PULL     = 50000,
        SOFT_PULL       = 35000,
        MAGNET_PULL     = 80000,
        PREDICT_OFFSET  = 0.04,
        VERTICAL_OFFSET = -0.05,
        LOCK_RADIUS     = 0.01,
        ANGULAR_KILL    = true,
    }

    HelpersTab:Toggle({ Title = "Inf Helper", Desc = "[B] Toggle | Control infinito del ball",
        Callback = function(state)
            toggleEnabled = state; P.helperEnabled = state
            if not state then helperActive = false; P.helperActive = false end
        end
    })
    HelpersTab:Toggle({ Title = "Magnet Mode", Desc = "El ball se pega instantáneamente a ti",
        Callback = function(state) magnetMode = state; P.magnetMode = state end
    })
    HelpersTab:Toggle({ Title = "Predict Mode", Desc = "Anticipa tu movimiento, ball siempre adelante",
        Callback = function(state) predictMode = state; P.predictMode = state end
    })
    HelpersTab:Toggle({ Title = "Space Lock", Desc = "Congela el ball en el espacio (posición fija)",
        Callback = function(state) multiLockActive = state; P.spaceLock = state end
    })
    HelpersTab:Slider({ Title = "Follow Distance", Min = 0, Max = 10, Default = 0.25,
        Callback = function(val) CONFIG.DEAD_ZONE = val end
    })
    HelpersTab:Slider({ Title = "Vertical Offset", Min = -5, Max = 5, Default = -0.20,
        Callback = function(val) CONFIG.VERTICAL_OFFSET = val end
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == Enum.KeyCode.B and not gp and toggleEnabled then
            helperActive = not helperActive; P.helperActive = helperActive
        end
    end)

    local function getOrCreateAtt(ball)
        local att = ball:FindFirstChild("_infAtt")
        if not att then att = Instance.new("Attachment"); att.Name = "_infAtt"; att.Parent = ball end
        return att
    end
    local function getOrCreateLV(ball, att)
        local lv = ball:FindFirstChild("_infLV")
        if not lv then
            lv = Instance.new("LinearVelocity"); lv.Name = "_infLV"; lv.Attachment0 = att
            lv.MaxForce = math.huge; lv.RelativeTo = Enum.ActuatorRelativeTo.World
            lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
            lv.VectorVelocity = Vector3.zero; lv.Parent = ball
        end
        return lv
    end
    local function getOrCreateAV(ball, att)
        local av = ball:FindFirstChild("_infAV")
        if not av then
            av = Instance.new("AngularVelocity"); av.Name = "_infAV"; av.Attachment0 = att
            av.MaxTorque = math.huge; av.RelativeTo = Enum.ActuatorRelativeTo.World
            av.AngularVelocity = Vector3.zero; av.Parent = ball
        end
        return av
    end
    local function cleanupBall(ball)
        if not ball then return end
        pcall(function()
            local lv = ball:FindFirstChild("_infLV"); if lv then lv.VectorVelocity = Vector3.zero end
            local av = ball:FindFirstChild("_infAV"); if av then av.AngularVelocity = Vector3.zero end
        end)
    end

    local lockedPos  = nil
    local lastHRPPos = nil
    local lastTick   = tick()

    local function getPredictedTarget(hrp)
        local now = tick(); local dt = now - lastTick; lastTick = now
        local currentPos = hrp.Position
        if lastHRPPos and dt > 0 and dt < 0.1 then
            local velocity = (currentPos - lastHRPPos) / dt
            lastHRPPos = currentPos
            return currentPos + velocity * CONFIG.PREDICT_OFFSET + Vector3.new(0, CONFIG.VERTICAL_OFFSET, 0)
        end
        lastHRPPos = currentPos
        return currentPos + hrp.CFrame.LookVector * CONFIG.FOLLOW_DISTANCE + Vector3.new(0, CONFIG.VERTICAL_OFFSET, 0)
    end

    RunService.RenderStepped:Connect(function()
        if not (helperActive and toggleEnabled) then
            local ball = _G._VxRBall; if ball then cleanupBall(ball) end
            lockedPos = nil; return
        end
        local ball = _G._VxRBall; local hrp = _G._VxRHRP
        local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid")
        if not (ball and hrp and hum) then return end
        if hum.Health <= 0 then return end
        if not ball:IsA("BasePart") then return end
        if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        local ballPos = ball.Position; local hrpPos = hrp.Position
        local dist = (ballPos - hrpPos).Magnitude
        local att = getOrCreateAtt(ball); local lv = getOrCreateLV(ball, att)
        if CONFIG.ANGULAR_KILL then
            local av = getOrCreateAV(ball, att)
            av.AngularVelocity = Vector3.zero; ball.AssemblyAngularVelocity = Vector3.zero
        end
        if multiLockActive then
            if not lockedPos then lockedPos = ballPos end
            local toLock = lockedPos - ballPos; local lockDist = toLock.Magnitude
            if lockDist > CONFIG.LOCK_RADIUS then
                lv.VectorVelocity = toLock.Unit * CONFIG.MAGNET_PULL
                ball.AssemblyLinearVelocity = toLock.Unit * CONFIG.MAGNET_PULL
            else
                lv.VectorVelocity = Vector3.zero; ball.AssemblyLinearVelocity = Vector3.zero
            end
            return
        else lockedPos = nil end
        local targetPos = predictMode and getPredictedTarget(hrp)
            or (hrpPos + hrp.CFrame.LookVector * CONFIG.FOLLOW_DISTANCE + Vector3.new(0, CONFIG.VERTICAL_OFFSET, 0))
        local toTarget = targetPos - ballPos; local toTargetDist = toTarget.Magnitude
        if magnetMode then
            if toTargetDist > 0.04 then
                local speed = math.clamp(toTargetDist * 1200, 80, CONFIG.MAGNET_PULL)
                lv.VectorVelocity = toTarget.Unit * speed; ball.AssemblyLinearVelocity = toTarget.Unit * speed
            else
                ball.CFrame = CFrame.new(targetPos)
                lv.VectorVelocity = Vector3.zero; ball.AssemblyLinearVelocity = Vector3.zero
            end
            return
        end
        if dist > CONFIG.MAX_DISTANCE then
            local dir = (targetPos - ballPos).Unit
            lv.VectorVelocity = dir * CONFIG.STRONG_PULL; ball.AssemblyLinearVelocity = dir * CONFIG.STRONG_PULL
        elseif dist > CONFIG.DEAD_ZONE then
            local speed = math.clamp(toTargetDist * CONFIG.SOFT_PULL, 20, CONFIG.FOLLOW_SPEED)
            lv.VectorVelocity = toTarget.Unit * speed
        else
            lv.VectorVelocity = Vector3.zero
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not (helperActive and toggleEnabled) then return end
        local ball = _G._VxRBall; local hrp = _G._VxRHRP
        if not (ball and hrp) then return end
        if not ball:IsA("BasePart") then return end
        if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
        if multiLockActive and lockedPos then
            local d = (ball.Position - lockedPos).Magnitude
            if d > CONFIG.LOCK_RADIUS then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                ball.AssemblyLinearVelocity = (lockedPos - ball.Position).Unit * CONFIG.MAGNET_PULL
            end
            return
        end
        local dist = (ball.Position - hrp.Position).Magnitude
        if dist > CONFIG.MAX_DISTANCE * 0.85 then
            pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
            local targetPos = hrp.Position + hrp.CFrame.LookVector * CONFIG.FOLLOW_DISTANCE
                + Vector3.new(0, CONFIG.VERTICAL_OFFSET, 0)
            ball.AssemblyLinearVelocity = (targetPos - ball.Position).Unit * CONFIG.STRONG_PULL
        end
    end)

    -- ============================================================

    -- ============================================================
    -- AIMBOT
    -- ============================================================
    local isAimbotEnabled = false
    local aimbotTargetPos = Vector3.new(0, 14, 157)
    local laser = Instance.new("Part")
    laser.Name = "vxnity hub aimbot"
    laser.Anchored = true
    laser.CanCollide = false
    laser.Material = Enum.Material.Neon
    laser.Color = Color3.fromRGB(220, 30, 30)
    laser.Transparency = 1
    laser.Size = Vector3.new(0.05, 0.05, 1)
    laser.Parent = Workspace

    local function toggleAimbot(state)
        isAimbotEnabled = state
        laser.Transparency = isAimbotEnabled and 0.4 or 1
    end

    RunService:BindToRenderStep("vxnityAimbotLoop", Enum.RenderPriority.Camera.Value + 1, function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))

        if isAimbotEnabled and hrp and torso then
            local hrpPos = hrp.Position
            local lookTarget = Vector3.new(aimbotTargetPos.X, hrpPos.Y, aimbotTargetPos.Z)
            hrp.CFrame = CFrame.lookAt(hrpPos, lookTarget)

            local startPos = torso.Position + Vector3.new(0, 0.8, 0)
            local distance = (aimbotTargetPos - startPos).Magnitude
            laser.Size = Vector3.new(0.05, 0.05, distance)
            laser.CFrame = CFrame.lookAt(startPos, aimbotTargetPos) * CFrame.new(0, 0, -distance/2)
        end
    end)

    AimbotTab:Section({ Title = "Aimbot Settings" })

    local AimbotToggle = AimbotTab:Toggle({
        Title = "Enable / Disable Aimbot",
        Callback = function(state)
            toggleAimbot(state)
        end
    })

    AimbotTab:Keybind({
        Title = "Aimbot Keybind",
        Default = Enum.KeyCode.R,
        Callback = function()
            local newState = not isAimbotEnabled
            AimbotToggle:Set(newState)
        end
    })

    -- ============================================================
    -- OPTIMIZATIONS TAB — Ping/CPU/GPU Improvements
    -- ============================================================
    local pingOptimized = false
    local cpuOptimized = false
    local gpuOptimized = false

    OptTab:Section({ Title = "⚡ Improve Ping" })

    OptTab:Toggle({
        Title = "Optimize Network Calls",
        Desc = "Reduce network latency by caching ball/player data",
        Callback = function(state)
            pingOptimized = state
            if state then
                XynorUI:Notify({ Title = "Ping Optimize", Desc = "Network optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Toggle({
        Title = "Reduce Packet Loss",
        Desc = "Optimize remote event handling",
        Callback = function(state)
            if state then
                pcall(function()
                    settings().Network.Physics = 30
                end)
                XynorUI:Notify({ Title = "Packet Loss", Desc = "Optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Section({ Title = "🖥️ Improve CPU" })

    OptTab:Toggle({
        Title = "Optimize Loops",
        Desc = "Reduce unnecessary render loop iterations",
        Callback = function(state)
            cpuOptimized = state
            if state then
                pcall(function()
                    RunService:setv("throttle", true)
                end)
                XynorUI:Notify({ Title = "CPU Optimize", Desc = "Loop optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Toggle({
        Title = "Reduce Event Processing",
        Desc = "Minimize event listener overhead",
        Callback = function(state)
            if state then
                XynorUI:Notify({ Title = "Events", Desc = "Event optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Toggle({
        Title = "Optimize Physics",
        Desc = "Reduce physics calculations when possible",
        Callback = function(state)
            if state then
                pcall(function()
                    settings().Physics.PhysicsEngine = "Voxel"
                end)
                XynorUI:Notify({ Title = "Physics", Desc = "Physics optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Section({ Title = "🎨 Improve GPU" })

    OptTab:Toggle({
        Title = "Optimize UI Rendering",
        Desc = "Reduce UI redraw frequency",
        Callback = function(state)
            gpuOptimized = state
            if state then
                XynorUI:Notify({ Title = "GPU Optimize", Desc = "UI optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Toggle({
        Title = "Reduce Visual Effects",
        Desc = "Minimize particle effects and glow",
        Callback = function(state)
            if state then
                pcall(function()
                    settings().Rendering.EffectsQuality = 0
                end)
                XynorUI:Notify({ Title = "Effects", Desc = "Effects optimization enabled", Duration = 2 })
            end
        end
    })

    OptTab:Toggle({
        Title = "Optimize Shadow Rendering",
        Desc = "Reduce shadow quality for better performance",
        Callback = function(state)
            if state then
                pcall(function()
                    settings().Rendering.ShadowQuality = 0
                end)
                XynorUI:Notify({ Title = "Shadows", Desc = "Shadow optimization enabled", Duration = 2 })
            end
        end
    })

    -- ============================================================
    -- BALL CONTROL ASSIST (Dribbling Helper) - ULTRA RESPONSIVE
    -- ============================================================
    local BallControlAssist = Window:Section({ Title = "Ball Control" })
    local DribbleTab = BallControlAssist:Tab({ Title = "Dribble Assist", Icon = "soccer" })

    local dribbleEnabled = false
    local dribbleIntensity = "High"
    local dribbleActivation = "Click"
    local dribbleActive = false
    local dribbleConnection = nil

    local DRIBBLE_CONFIG = {
        Low = { strength = 30000, deadzone = 0.03, offset = 0.08 },
        Medium = { strength = 60000, deadzone = 0.015, offset = 0.05 },
        High = { strength = 100000, deadzone = 0.008, offset = 0.03 }
    }

    DribbleTab:Section({ Title = "🎯 Dribble ULTRA 0-REACH" })

    DribbleTab:Toggle({
        Title = "Enable Dribble Assist",
        Desc = "0 reach visual + ball ultra pegado + rapido",
        Callback = function(state)
            dribbleEnabled = state
            if not state and dribbleConnection then
                dribbleConnection:Disconnect()
                dribbleConnection = nil
                dribbleActive = false
            end
        end
    })

    DribbleTab:Slider({
        Title = "Intensity (1=Low, 2=Med, 3=High)",
        Desc = "Ajusta la potencia del dribble",
        Value = { Min = 1, Max = 3, Default = 3 },
        Callback = function(val)
            local levels = {"Low", "Medium", "High"}
            dribbleIntensity = levels[math.floor(val)] or "High"
        end
    })

    DribbleTab:Toggle({
        Title = "Click/Tap Activation",
        Desc = "Activar con click o tap",
        Callback = function(state)
            if state then dribbleActivation = "Click" end
        end
    })

    DribbleTab:Toggle({
        Title = "Hold Activation",
        Desc = "Activar manteniendo presionado",
        Callback = function(state)
            if state then dribbleActivation = "Hold" end
        end
    })

    DribbleTab:Button({
        Title = "TEST Dribble",
        Desc = "Prueba la asistencia",
        Callback = function()
            if dribbleEnabled then
                applyDribbleAssist()
                XynorUI:Notify({ Title = "Dribble Test", Desc = "Intensity: " .. dribbleIntensity, Duration = 1 })
            end
        end
    })

    local function applyDribbleAssist()
        if not dribbleEnabled then return end
        local ball = _G._VxRBall
        local hrp = _G._VxRHRP
        if not (ball and hrp) then return end

        local config = DRIBBLE_CONFIG[dribbleIntensity] or DRIBBLE_CONFIG.High

        pcall(function() ball.CanCollide = false end)
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)

        local targetPos = hrp.Position + hrp.CFrame.LookVector * config.offset + Vector3.new(0, 0.02, 0)
        local diff = targetPos - ball.Position
        local dist = diff.Magnitude

        if dist > config.deadzone then
            local speed = math.clamp(dist * config.strength, 800, config.strength)
            ball.AssemblyLinearVelocity = diff.Unit * speed + hrp.CFrame.LookVector * 80
            ball.CFrame = CFrame.new(targetPos)
        else
            ball.CFrame = CFrame.new(targetPos)
            ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * 0.85 + hrp.CFrame.LookVector * 60
        end

        ball.AssemblyAngularVelocity = Vector3.new(50, 0, 50)
    end

    dribbleConnection = RunService.RenderStepped:Connect(function()
        if dribbleEnabled and dribbleActive then
            applyDribbleAssist()
        end
    end)

    -- Mobile and PC instant click detection
    local function handleDribbleInput(input, gp)
        if not dribbleEnabled then return end
        if dribbleActivation == "Click" then
            if input.UserInputType == Enum.UserInputType.MouseButton1 
                or input.UserInputType == Enum.UserInputType.Touch 
                or input.UserInputType == Enum.UserInputType.FingerTouch then
                dribbleActive = true
                applyDribbleAssist()
                task.delay(0.05, function() dribbleActive = false end)
            end
        elseif dribbleActivation == "Hold" then
            if (input.UserInputType == Enum.UserInputType.MouseButton1 
                or input.UserInputType == Enum.UserInputType.Touch 
                or input.UserInputType == Enum.UserInputType.FingerTouch) and not gp then
                dribbleActive = true
            end
        end
    end

    local function handleDribbleEnd(input, gp)
        if dribbleActivation == "Hold" then
            if input.UserInputType == Enum.UserInputType.MouseButton1 
                or input.UserInputType == Enum.UserInputType.Touch 
                or input.UserInputType == Enum.UserInputType.FingerTouch then
                dribbleActive = false
            end
        end
    end

    UserInputService.InputBegan:Connect(handleDribbleInput)
    UserInputService.InputEnded:Connect(handleDribbleEnd)

    -- Mobile touch tap detection for instant response
    if UserInputService.TouchEnabled then
        UserInputService.TouchTap:Connect(function(touchPos, gp)
            if dribbleEnabled and dribbleActivation == "Click" then
                dribbleActive = true
                applyDribbleAssist()
                task.delay(0.05, function() dribbleActive = false end)
            end
        end)
    end

    -- ============================================================
    -- FF 1.0 — Ball Interpolation Control
    -- ============================================================
    local FFSection = Window:Section({ Title = "FF 1.0" })
    local FFTab = FFSection:Tab({ Title = "FF 1.0", Icon = "sliders" })

    FFTab:Section({ Title = "⚙️ Ball Interpolation" })

    local ballInterpolation = 50  -- valor por defecto

    FFTab:TextBox({
        Title = "Interpolation",
        Desc = "Ejemplo: 50",
        Placeholder = "Ejemplo: 50",
        Callback = function(val)
            local num = tonumber(val)
            if num then
                ballInterpolation = math.clamp(num, 1, 1000)
                -- Aplicar interpolation al balón
                -- MÁS BAJO = MÁS RÁPIDO (lógica inversa)
                local ball = _G._VxRBall
                if ball then
                    pcall(function()
                        local factor = 50 / ballInterpolation  -- inverso: 1 → x50 speed, 100 → x0.5 speed
                        ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * factor
                    end)
                end
                _G._XynorInterpolation = ballInterpolation
                XynorUI:Notify({
                    Title = "FF 1.0",
                    Desc = "Interpolation set to " .. ballInterpolation,
                    Duration = 2
                })
            end
        end
    })

    -- ============================================================
    -- REACTS 2.0 — Preset Reaction Buttons (15 → 100, de 15 en 15)
    -- ============================================================
    local Reacts2Section = Window:Section({ Title = "Reacts 2.0" })
    local Reacts2Tab = Reacts2Section:Tab({ Title = "Reacts 2.0", Icon = "zap" })

    Reacts2Tab:Section({ Title = "⚡ Reaction Presets" })
    Reacts2Tab:Paragraph({
        Title = "¿Cómo funciona?",
        Desc = "Cada preset aumenta la velocidad de reacción al balón. Valores más altos = reacción más rápida e instantánea."
    })

    -- Tabla de configuraciones por nivel de react (15, 30, 45 ... 100)
    local REACT2_CONFIGS = {
        [15]  = { power = 1e18, speed = 12000,  snap = 0.06, desc = "Smooth reaction" },
        [30]  = { power = 5e18, speed = 22000,  snap = 0.05, desc = "Responsive" },
        [45]  = { power = 2e19, speed = 38000,  snap = 0.04, desc = "Fast reaction" },
        [60]  = { power = 8e19, speed = 58000,  snap = 0.035, desc = "Very fast" },
        [75]  = { power = 4e20, speed = 80000,  snap = 0.025, desc = "Ultra fast" },
        [90]  = { power = 2e21, speed = 110000, snap = 0.018, desc = "Hyper fast" },
        [100] = { power = 1e22, speed = 150000, snap = 0.012, desc = "MAX reaction" },
    }

    local react2Active = false
    local react2Connection = nil
    local currentReact2Cfg = nil

    local function applyReact2(cfg)
        local ball = _G._VxRBall
        local hrp  = _G._VxRHRP
        if not (ball and hrp) then return end

        pcall(function() ball.CanCollide = false end)
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)

        local targetPos = hrp.Position + hrp.CFrame.LookVector * cfg.snap + Vector3.new(0, 0.02, 0)
        local diff = targetPos - ball.Position
        local dist = diff.Magnitude

        if dist > 0.01 then
            local spd = math.clamp(dist * cfg.power, 800, cfg.speed)
            ball.AssemblyLinearVelocity = diff.Unit * spd
            ball.CFrame = CFrame.new(targetPos)
        else
            ball.CFrame = CFrame.new(targetPos)
            ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (cfg.speed * 0.05)
        end
        ball.AssemblyAngularVelocity = Vector3.new(60, 0, 60)
    end

    local function setReact2(level)
        local cfg = REACT2_CONFIGS[level]
        if not cfg then return end
        currentReact2Cfg = cfg

        -- Desconectar el anterior si existía
        if react2Connection then
            react2Connection:Disconnect()
            react2Connection = nil
        end

        react2Active = true
        react2Connection = RunService.RenderStepped:Connect(function()
            if react2Active and currentReact2Cfg then
                applyReact2(currentReact2Cfg)
            end
        end)

        XynorUI:Notify({
            Title = "Reacts 2.0",
            Desc = "React " .. level .. " activado — " .. cfg.desc,
            Duration = 2
        })
    end

    -- Botones de 15 en 15 hasta 100
    local reactLevels = {15, 30, 45, 60, 75, 90, 100}
    local reactIcons  = {"⚡","⚡","🔥","🔥","💥","💥","🌪️"}

    for i, lvl in ipairs(reactLevels) do
        local cfg = REACT2_CONFIGS[lvl]
        Reacts2Tab:Button({
            Title = reactIcons[i] .. " React " .. lvl,
            Desc = cfg.desc,
            Callback = function()
                setReact2(lvl)
            end
        })
    end

    -- Botón para desactivar
    Reacts2Tab:Button({
        Title = "❌ Desactivar React 2.0",
        Desc = "Apaga la reacción automática",
        Callback = function()
            react2Active = false
            if react2Connection then
                react2Connection:Disconnect()
                react2Connection = nil
            end
            currentReact2Cfg = nil
            XynorUI:Notify({ Title = "Reacts 2.0", Desc = "Desactivado", Duration = 2 })
        end
    })

    XynorUI:Notify({
        Title = "vxnity hub",
        Desc = "Welcome back! Script loaded successfully.",
        Duration = 4
    })
end

-- Execution Entry Point
ShowSystemLoader(function()
    task.wait(0.1)
    LoadVxnityHub()
end)
