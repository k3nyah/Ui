-- ============================================================
--  Stylo723 — 1.0 (UI Propia - Sin dependencias externas)
--  Funciones: Flag Inject, Reach, Mossing, Reacts
--  Adaptado para móvil | Anti-Crash Global
--  Discord: https://discord.gg/ujuwhftzz5
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ============================================================
--  UI PROPIA (Ligera, táctil, escalable)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Stylo723UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local function MakeDraggable(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Ventana principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 600)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Sombra / borde
local Shadow = Instance.new("UICorner")
Shadow.CornerRadius = UDim.new(0, 12)
Shadow.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Stylo723 — 1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

MakeDraggable(TitleBar)

-- Panel de pestañas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- Contenedor de contenido
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -80)
ContentFrame.Position = UDim2.new(0, 0, 0, 80)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100,100,120)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ContentFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ScrollingFrame

-- Variables para pestañas
local tabs = {}
local currentTab = nil

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = TabContainer
    
    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, 0, 1, 0)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Visible = false
    contentHolder.Parent = ScrollingFrame
    local holderList = Instance.new("UIListLayout")
    holderList.Padding = UDim.new(0, 8)
    holderList.SortOrder = Enum.SortOrder.LayoutOrder
    holderList.Parent = contentHolder
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.btn.BackgroundTransparency = 1
            t.content.Visible = false
        end
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        contentHolder.Visible = true
        currentTab = name
    end)
    
    local tab = {btn = btn, content = contentHolder}
    table.insert(tabs, tab)
    if #tabs == 1 then
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        contentHolder.Visible = true
    end
    return contentHolder
end

local function AddLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, -10, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220,220,240)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function AddDivider(parent)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -10, 0, 1)
    line.BackgroundColor3 = Color3.fromRGB(80,80,100)
    line.BorderSizePixel = 0
    line.Parent = parent
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamSemibold
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function AddToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,60)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230,230,250)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 30)
    toggleBtn.Position = UDim2.new(1, -45, 0.5, -15)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(70,200,70) or Color3.fromRGB(120,120,140)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleBtn
    toggleBtn.Parent = frame
    
    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(70,200,70) or Color3.fromRGB(120,120,140)
        toggleBtn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    pcall(callback, state)
    return frame
end

local function AddSlider(parent, text, minv, maxv, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,60)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(230,230,250)
    lbl.TextSize = 14
    lbl.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 6)
    slider.Position = UDim2.new(0, 10, 0, 35)
    slider.BackgroundColor3 = Color3.fromRGB(80,80,100)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-minv)/(maxv-minv), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70,150,220)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local valueBtn = Instance.new("TextButton")
    valueBtn.Size = UDim2.new(0, 40, 0, 30)
    valueBtn.Position = UDim2.new(fill.Size.X.Scale, -20, 0, -12)
    valueBtn.BackgroundColor3 = Color3.fromRGB(200,200,220)
    valueBtn.Text = tostring(default)
    valueBtn.TextColor3 = Color3.fromRGB(0,0,0)
    valueBtn.TextSize = 12
    valueBtn.Parent = slider
    local valueCorner = Instance.new("UICorner")
    valueCorner.CornerRadius = UDim.new(0, 6)
    valueCorner.Parent = valueBtn
    
    local function updateSlider(val)
        val = math.clamp(val, minv, maxv)
        local perc = (val - minv) / (maxv - minv)
        fill.Size = UDim2.new(perc, 0, 1, 0)
        valueBtn.Position = UDim2.new(perc, -20, 0, -12)
        valueBtn.Text = tostring(math.floor(val))
        lbl.Text = text .. ": " .. tostring(math.floor(val))
        pcall(callback, val)
    end
    
    local dragging = false
    valueBtn.MouseButton1Down:Connect(function()
        dragging = true
        local move
        move = UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position.X
                local sliderAbsPos = slider.AbsolutePosition.X
                local sliderWidth = slider.AbsoluteSize.X
                local perc = (mousePos - sliderAbsPos) / sliderWidth
                local val = minv + perc * (maxv - minv)
                updateSlider(val)
            end
        end)
        local release
        release = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                move:Disconnect()
                release:Disconnect()
            end
        end)
    end)
    
    updateSlider(default)
    return frame
end

local function AddInput(parent, text, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,60)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    frame.Parent = parent
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(230,230,250)
    lbl.TextSize = 14
    lbl.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 25)
    box.Position = UDim2.new(0, 5, 0, 22)
    box.BackgroundColor3 = Color3.fromRGB(30,30,40)
    box.Text = ""
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.new(1,1,1)
    box.PlaceholderColor3 = Color3.fromRGB(150,150,170)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    box.Parent = frame
    box.FocusLost:Connect(function(enter)
        if enter then pcall(callback, box.Text) end
    end)
    return frame
end

-- ============================================================
--  BALL GUARDIAN Y SEGURIDAD (Igual que antes)
-- ============================================================
local function startBallGuard()
    local function guardBall(ball)
        if not ball or not ball:IsA("BasePart") then return end
        pcall(function() ball.CanCollide = false end)
        ball:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
        end)
    end
    local function findAndGuard()
        local tps = Workspace:FindFirstChild("TPSSystem")
        if tps then
            local ball = tps:FindFirstChild("TPS")
            if ball then guardBall(ball) end
            tps.ChildAdded:Connect(function(child)
                if child.Name == "TPS" then guardBall(child) end
            end)
        end
    end
    findAndGuard()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "TPSSystem" then task.wait(0.05) findAndGuard() end
    end)
end
pcall(startBallGuard)

pcall(function()
    for _, b in pairs(workspace.FE.Actions:GetChildren()) do if b.Name == " " then b:Destroy() end end
    local ch = LocalPlayer.Character
    if ch then for _, b in pairs(ch:GetChildren()) do if b.Name == " " then b:Destroy() end end end
    local a = workspace.FE.Actions
    if a and a:FindFirstChild("KeepYourHeadUp_") then
        a.KeepYourHeadUp_:Destroy()
        local r = Instance.new("RemoteEvent")
        r.Name = "KeepYourHeadUp_"
        r.Parent = a
    end
end)

-- ============================================================
--  PERSISTENCIA GLOBAL
-- ============================================================
if not _G._Stylo723Persist then
    _G._Stylo723Persist = {
        reachEnabled = false, reachDistance = 1, reactPower = 10000,
        currentSpeed = 10000,
    }
end
local P = _G._Stylo723Persist

if not _G._StyRBall then _G._StyRBall = nil end
if not _G._StyRHRP then _G._StyRHRP = nil end

RunService.RenderStepped:Connect(function()
    pcall(function()
        local sys = Workspace:FindFirstChild("TPSSystem")
        _G._StyRBall = sys and sys:FindFirstChild("TPS")
        local ch = LocalPlayer.Character
        _G._StyRHRP = ch and ch:FindFirstChild("HumanoidRootPart")
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    pcall(function()
        _G._StyRHRP = char:WaitForChild("HumanoidRootPart", 3)
        if P.reachEnabled and _G._StyReachRestart then task.wait(0.05) _G._StyReachRestart() end
    end)
end)

-- ============================================================
--  FLAG FUNC (Inyección de FastFlags)
-- ============================================================
local flagTab = CreateTab("Flag Func")
AddLabel(flagTab, "Stylo723 — Fast Flag Injector")
AddDivider(flagTab)
AddLabel(flagTab, "Escribe el nombre de la Flag y su valor.")
AddLabel(flagTab, "Ej: FFlag::DebugForceFastGPUTextureDeallocation = true")
AddDivider(flagTab)

local flagKey = ""
local flagVal = ""

AddInput(flagTab, "Flag Name (Key)", "FFlag::Nombre", function(text) flagKey = tostring(text):sub(1,128) end)
AddInput(flagTab, "Flag Value", "true / false / numero", function(text) flagVal = tostring(text):sub(1,256) end)

local function tryInjectFlag(key, value)
    key = tostring(key):gsub("[^%w_]", ""):sub(1,128)
    value = tostring(value):sub(1,256)
    if key == "" then return false, "Key vacía" end
    local ok, report = false, ""
    pcall(function() if setfflag then setfflag(key, value) ok = true report = "setfflag OK" end end)
    if not ok then pcall(function() if _G.setfflag then _G.setfflag(key, value) ok = true report = "via _G.setfflag" end end) end
    if not ok then pcall(function() local s = settings() if s then s[key] = value ok = true report = "settings()" end end) end
    if not ok then pcall(function() local us = UserSettings() if us then us[key] = value ok = true report = "UserSettings" end end) end
    if not ok then report = "Guardado localmente (executor no soporta flags)" ok = true end
    return ok, report
end

AddButton(flagTab, "Inject Flag", function()
    pcall(function()
        local ok, report = tryInjectFlag(flagKey, flagVal)
        AddLabel(flagTab, "→ " .. (ok and "OK" or "ERR") .. " | " .. report .. " | " .. flagKey .. " = " .. flagVal):Destroy()
    end)
end)

AddButton(flagTab, "Remove Flag", function()
    if flagKey == "" then return end
    pcall(function() if setfflag then setfflag(flagKey, "") end end)
    AddLabel(flagTab, "→ Flag eliminada: " .. flagKey):Destroy()
end)

AddButton(flagTab, "Clear All Flags", function()
    pcall(function()
        for k,_ in pairs(_G._injectedFlags or {}) do if setfflag then setfflag(k,"") end end
        _G._injectedFlags = {}
        AddLabel(flagTab, "→ Todas las flags limpiadas"):Destroy()
    end)
end)

-- ============================================================
--  HOME (Información)
-- ============================================================
local homeTab = CreateTab("Home")
AddLabel(homeTab, "Stylo723 — 1.0")
AddLabel(homeTab, "Script Version: 1.0 | TPS Street Soccer")
AddLabel(homeTab, "User: " .. LocalPlayer.Name)
AddDivider(homeTab)
AddLabel(homeTab, "Discord Oficial:")
AddLabel(homeTab, "discord.gg/ujuwhftzz5")
AddDivider(homeTab)
AddLabel(homeTab, "Sectores activos: Reach | Mossing | Reacts | Flag Func")

-- ============================================================
--  REACH
-- ============================================================
local reachTab = CreateTab("Reach")
local reachEnabled = P.reachEnabled
local reachDistance = P.reachDistance
local reachConnection

local function startReach()
    pcall(function()
        if reachConnection then reachConnection:Disconnect() end
        local _char, _root, _hum, _tps, _limb, _lastRig, _frameSkip = nil, nil, nil, nil, nil, nil, 0
        reachConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                if character ~= _char then
                    _char = character
                    _root = character:FindFirstChild("HumanoidRootPart")
                    _hum = character:FindFirstChild("Humanoid")
                    _limb = nil
                end
                if not (_root and _hum) then return end
                _frameSkip = _frameSkip + 1
                if _frameSkip >= 3 then
                    _frameSkip = 0
                    local sys = Workspace:FindFirstChild("TPSSystem")
                    _tps = sys and sys:FindFirstChild("TPS")
                end
                if not _tps then return end
                if (_root.Position - _tps.Position).Magnitude > reachDistance then return end
                local rig = _hum.RigType
                if rig ~= _lastRig or not _limb or not _limb.Parent then
                    _lastRig = rig
                    local pf = Lighting:FindFirstChild(LocalPlayer.Name)
                    local foot = pf and pf:FindFirstChild("PreferredFoot")
                    if foot then
                        local nm = (rig == Enum.HumanoidRigType.R6) and ((foot.Value == 1) and "Right Leg" or "Left Leg") or ((foot.Value == 1) and "RightLowerLeg" or "LeftLowerLeg")
                        _limb = _char:FindFirstChild(nm)
                    end
                end
                if _limb then
                    firetouchinterest(_limb, _tps, 0)
                    firetouchinterest(_limb, _tps, 1)
                end
            end)
        end)
    end)
end

_G._StyReachRestart = function()
    if P.reachEnabled then pcall(startReach) end
end

AddLabel(reachTab, "Leg Reach — FireTouchInterest")
AddToggle(reachTab, "Active FireTouchInterest", reachEnabled, function(state)
    reachEnabled = state
    P.reachEnabled = state
    if state then startReach() else if reachConnection then reachConnection:Disconnect() end end
end)
AddSlider(reachTab, "Reach Distance", 1, 15, reachDistance, function(val) reachDistance = val; P.reachDistance = val end)
AddDivider(reachTab)
AddLabel(reachTab, "Hitbox Resize (R6/R15)")
AddInput(reachTab, "Leg Size (R6)", "Ej: 2", function(v)
    local sz = math.max(tonumber(v) or 1, 0.1)
    local c = LocalPlayer.Character
    if c then
        for _,n in pairs({"Right Leg","Left Leg"}) do
            local p = c:FindFirstChild(n)
            if p then p.Size = Vector3.new(sz,2,sz); p.CanCollide = false end
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Size = Vector3.new(sz,2,sz); hrp.CanCollide = false end
    end
end)
AddInput(reachTab, "Legs Size (R15)", "Ej: 2", function(v)
    local sz = math.max(tonumber(v) or 1, 0.1)
    local c = LocalPlayer.Character
    if c then
        for _,n in pairs({"RightLowerLeg","LeftLowerLeg"}) do
            local p = c:FindFirstChild(n)
            if p then p.Size = Vector3.new(sz,2,sz); p.CanCollide = false end
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Size = Vector3.new(sz,2,sz); hrp.CanCollide = false end
    end
end)

-- ============================================================
--  MOSSING (Head Reach)
-- ============================================================
local mossingTab = CreateTab("Mossing")
local headEnabled = false
local headSize = Vector3.new(1,1.5,1)
local headTrans = 0.5
local headOffset = Vector3.new(0,0,0)
local headBox, headConn

local function updateHeadBox()
    if headBox then headBox:Destroy() end
    headBox = Instance.new("Part")
    headBox.Size = headSize
    headBox.Transparency = headTrans
    headBox.Anchored = true
    headBox.CanCollide = false
    headBox.Color = Color3.fromRGB(200,30,30)
    headBox.Material = Enum.Material.Neon
    headBox.Name = "HeadReachBox"
    headBox.Parent = Workspace
end

local function startHeadReach()
    if not headEnabled then return end
    if headConn then headConn:Disconnect() end
    updateHeadBox()
    local _head, _tps, _char = nil, nil, nil
    headConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            if char ~= _char then _char = char; _head = char:FindFirstChild("Head") end
            if not _head then return end
            local sys = Workspace:FindFirstChild("TPSSystem")
            _tps = sys and sys:FindFirstChild("TPS")
            if not _tps then return end
            if _tps.CanCollide then _tps.CanCollide = false end
            headBox.CFrame = _head.CFrame * CFrame.new(headOffset)
            local rel = headBox.CFrame:PointToObjectSpace(_tps.Position)
            local hs = headBox.Size * 0.5
            if math.abs(rel.X)<=hs.X and math.abs(rel.Y)<=hs.Y and math.abs(rel.Z)<=hs.Z then
                firetouchinterest(_head, _tps, 0)
                firetouchinterest(_head, _tps, 1)
            end
        end)
    end)
end

AddToggle(mossingTab, "Active Moss Reach", false, function(state)
    headEnabled = state
    if state then startHeadReach() else if headConn then headConn:Disconnect() end if headBox then headBox:Destroy() end end
end)
AddSlider(mossingTab, "Range X", 0, 50, 1, function(val) headSize = Vector3.new(val, headSize.Y, headSize.Z); if headEnabled then updateHeadBox() end end)
AddSlider(mossingTab, "Range Y", 0, 50, 1.5, function(val) headSize = Vector3.new(headSize.X, val, headSize.Z); headOffset = Vector3.new(headOffset.X, val/2.5, headOffset.Z); if headEnabled then updateHeadBox() end end)
AddSlider(mossingTab, "Range Z", 0, 50, 1, function(val) headSize = Vector3.new(headSize.X, headSize.Y, val); if headEnabled then updateHeadBox() end end)
AddToggle(mossingTab, "Stealth Mode", false, function(v) headTrans = v and 1 or 0.5; if headBox then headBox.Transparency = headTrans end end)

-- ============================================================
--  REACTS (Con hook y velocidad x100)
-- ============================================================
local reactTab = CreateTab("Reacts")
local currentSpeed = P.currentSpeed or 10000
local REACT_ACTIONS = {Kick=true, KickC1=true, Tackle=true, Header=true, SaveRA=true, SaveLA=true, SaveRL=true, SaveLL=true, SaveT=true}

local function fireReact(dir, speed, snapFwd, liftY)
    pcall(function()
        local ball = _G._StyRBall
        local hrp = _G._StyRHRP
        if not (ball and hrp) then return end
        speed = math.clamp(speed, 1, 999999)
        local fwd = dir or hrp.CFrame.LookVector
        local sf = snapFwd or 0.4
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        ball.CanCollide = false
        if (ball.Position - hrp.Position).Magnitude > 6 then
            ball.CFrame = CFrame.new(hrp.Position + fwd*sf + Vector3.new(0, liftY or 0, 0))
        end
        ball.AssemblyLinearVelocity = Vector3.zero
        local att = ball:FindFirstChild("_StyAtt") or Instance.new("Attachment", ball)
        att.Name = "_StyAtt"
        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = (fwd + Vector3.new(0, (liftY or 0)*0.01, 0)).Unit * speed
        lv.Parent = ball
        ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, (liftY or 0)*0.01, 0)).Unit * speed
        task.defer(function()
            pcall(function()
                if lv then lv:Destroy() end
                if ball and ball.Parent and ball.AssemblyLinearVelocity.Magnitude < speed*0.4 then
                    ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, (liftY or 0)*0.01, 0)).Unit * speed
                end
            end)
        end)
    end)
end

-- Hook namecall
pcall(function()
    if not _G._StyReactHookInstalled then
        _G._StyReactHookInstalled = true
        local meta = getrawmetatable(game)
        local old = meta.namecall
        setreadonly(meta, false)
        meta.namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and REACT_ACTIONS[tostring(self)] then
                pcall(function()
                    local hrp = _G._StyRHRP
                    if hrp then fireReact(hrp.CFrame.LookVector, currentSpeed, 0.4, 0) end
                end)
            end
            return old(self, ...)
        end)
        setreadonly(meta, true)
    end
end)

AddLabel(reactTab, "Velocidad x100 (React 100 = 10000)")
local tiers = {{"React 100",10000},{"React 200",20000},{"React 350",35000},{"React 500",50000},{"React 700",70000},{"React 1000",100000}}
for _,t in ipairs(tiers) do
    AddButton(reactTab, t[1], function() currentSpeed = t[2]; P.currentSpeed = t[2]; AddLabel(reactTab, "→ Velocidad: "..t[2]):Destroy() end)
end
AddDivider(reactTab)
AddSlider(reactTab, "React Speed", 100, 200000, currentSpeed, function(v) currentSpeed = v; P.currentSpeed = v end)
AddDivider(reactTab)
AddButton(reactTab, "Ground Shot", function()
    local hrp = _G._StyRHRP
    if hrp then fireReact(hrp.CFrame.LookVector, currentSpeed, 0.4, 0) end
end)
AddButton(reactTab, "Lifted Shot", function()
    local hrp = _G._StyRHRP
    if hrp then
        local look = hrp.CFrame.LookVector
        local angle = math.rad(20)
        local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
        fireReact(dir, currentSpeed, 0.4, 0)
    end
end)
AddButton(reactTab, "Aerial Shot", function()
    local hrp = _G._StyRHRP
    if hrp then
        local look = hrp.CFrame.LookVector
        local angle = math.rad(35)
        local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
        fireReact(dir, currentSpeed, 0.3, 0)
    end
end)
AddButton(reactTab, "Snap and Fire", function()
    local ball, hrp = _G._StyRBall, _G._StyRHRP
    if ball and hrp then
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        ball.CanCollide = false
        local look = hrp.CFrame.LookVector
        ball.CFrame = CFrame.new(hrp.Position + look*0.3 + Vector3.new(0,0.1,0))
        ball.AssemblyLinearVelocity = Vector3.zero
        task.wait()
        fireReact(look, currentSpeed, 0, 0)
    end
end)
AddButton(reactTab, "Goalkeeper Clear", function()
    local hrp = _G._StyRHRP
    if hrp then
        local look = hrp.CFrame.LookVector
        local angle = math.rad(15)
        local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
        fireReact(dir, currentSpeed, 0.4, 0)
    end
end)

-- Notificación de inicio
AddLabel(homeTab, "Script cargado correctamente. ¡Disfruta Stylo723!")
