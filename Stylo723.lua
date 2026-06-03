-- ============================================================
--  Stylo723 — 1.0
--  Refactorizado para Redz UI | Anti-Crash Global | Flag Inject
-- ============================================================

-- Servicios
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- BALL CANCOLLIDE GUARDIAN — sin loops pesados
-- ============================================================
local _ballGuardConn
local function startBallGuard()
    if _ballGuardConn then return end
    local function guardBall(ball)
        if not ball or not ball:IsA("BasePart") then return end
        pcall(function() ball.CanCollide = false end)
        ball:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if ball.CanCollide then
                pcall(function() ball.CanCollide = false end)
            end
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
        if child.Name == "TPSSystem" then
            task.wait(0.05)
            findAndGuard()
        end
    end)
end
pcall(startBallGuard)

-- ============================================================
-- SECURITY / CLEAN
-- ============================================================
pcall(function()
    for _, b in pairs(workspace.FE.Actions:GetChildren()) do
        if b.Name == " " then b:Destroy() end
    end
end)
pcall(function()
    for _, b in pairs(LocalPlayer.Character:GetChildren()) do
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
-- CARGA DE REDZ UI
-- ============================================================
loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()

local RedzUI = RedzLib  -- alias estándar de Redz UI

-- ============================================================
-- VENTANA PRINCIPAL — Stylo723
-- ============================================================
local Window = RedzUI:CreateWindow({
    Name   = "Stylo723 — 1.0",
    Status = "Stylo Team",
})

-- ============================================================
-- PERSISTENCIA GLOBAL — sobrevive muerte/respawn
-- ============================================================
if not _G._Stylo723Persist then
    _G._Stylo723Persist = {
        reachEnabled  = false,
        reachDistance = 1,
        reactPower    = 0,
        ballSpeedMult = 7.0,
        reactHookOn   = false,
        helperActive  = false,
        helperEnabled = true,
        magnetMode    = true,
        predictMode   = true,
        spaceLock     = false,
        flagValue     = "",
    }
end
local P = _G._Stylo723Persist

-- Cache global de balón y HRP
if not _G._StyRBall then _G._StyRBall = nil end
if not _G._StyRHRP  then _G._StyRHRP  = nil end

if not _G._StyCacheWorker then
    _G._StyCacheWorker = RunService.RenderStepped:Connect(function()
        local sys = Workspace:FindFirstChild("TPSSystem")
        _G._StyRBall = sys and sys:FindFirstChild("TPS")
        local ch = LocalPlayer.Character
        _G._StyRHRP = ch and ch:FindFirstChild("HumanoidRootPart")
    end)
end

if not _G._StyCharConn then
    _G._StyCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
        _G._StyRHRP = char:WaitForChild("HumanoidRootPart", 3)
        if P.reachEnabled and _G._StyReachRestart then
            task.wait(0.05)
            _G._StyReachRestart()
        end
    end)
end

-- ============================================================
-- ╔══════════════════════════════════════╗
-- ║   SECCIÓN: FLAG FUNC                 ║
-- ╚══════════════════════════════════════╝
-- ============================================================
local FlagSection = Window:CreateSection("Flag Func")

-- Almacén interno del flag
local _flagCurrentValue = tostring(P.flagValue or "")
local _flagActive       = false

-- Función protegida de inyección de flag
local function safeFlagInject(rawInput)
    local ok, err = pcall(function()
        -- Validación: acepta número o texto, nunca rompe
        local numVal = tonumber(rawInput)
        if numVal then
            -- Valor numérico: clampear a rango seguro para evitar overflow
            local safeVal = math.clamp(numVal, -1e30, 1e30)
            _flagCurrentValue = tostring(safeVal)
            P.flagValue = _flagCurrentValue
            -- Aplicar lógica de flag si corresponde
            if _G._StyRBall and _G._StyRBall.Parent then
                pcall(function() _G._StyRBall.CanCollide = false end)
            end
        else
            -- Valor de texto: sanitizar y guardar
            local sanitized = tostring(rawInput or "")
            if #sanitized > 256 then sanitized = sanitized:sub(1, 256) end
            _flagCurrentValue = sanitized
            P.flagValue = sanitized
        end
    end)
    if not ok then
        -- Bypass: si algo falla internamente, resetear a estado seguro
        _flagCurrentValue = ""
        P.flagValue = ""
        warn("[Stylo723] Flag Inject bypass activado — valor reseteado a seguro.")
    end
    return _flagCurrentValue
end

-- Toggle para activar/desactivar el flag inject
FlagSection:CreateToggle({
    Name     = "Flag Inject",
    Default  = false,
    Callback = function(state)
        _flagActive = state
        if state then
            -- Al activar, inyectar con el valor actual
            local result = safeFlagInject(_flagCurrentValue)
            RedzUI:Notify({
                Title    = "Stylo723",
                Content  = "Flag Inject activado. Valor: " .. tostring(result),
                Duration = 3,
            })
        else
            RedzUI:Notify({
                Title    = "Stylo723",
                Content  = "Flag Inject desactivado.",
                Duration = 2,
            })
        end
    end,
})

-- Input para escribir el valor del flag
FlagSection:CreateInput({
    Name        = "Flag Value",
    PlaceholderText = "Escribe un número o texto...",
    RemoveTextAfterFocusLost = false,
    Callback    = function(text)
        -- Bypass: envolver siempre en pcall, nunca crashea
        pcall(function()
            local result = safeFlagInject(text)
            if _flagActive then
                RedzUI:Notify({
                    Title    = "Flag Inject",
                    Content  = "Valor aplicado: " .. tostring(result),
                    Duration = 2,
                })
            end
        end)
    end,
})

-- Botón de inyección manual instantánea
FlagSection:CreateButton({
    Name     = "Inject Now",
    Callback = function()
        pcall(function()
            local result = safeFlagInject(_flagCurrentValue)
            RedzUI:Notify({
                Title    = "Flag Inject",
                Content  = "Inyección ejecutada: " .. tostring(result),
                Duration = 2,
            })
        end)
    end,
})

-- Botón de reset del flag
FlagSection:CreateButton({
    Name     = "Reset Flag",
    Callback = function()
        pcall(function()
            _flagCurrentValue = ""
            P.flagValue = ""
            _flagActive = false
            RedzUI:Notify({
                Title    = "Flag Inject",
                Content  = "Flag reseteado correctamente.",
                Duration = 2,
            })
        end)
    end,
})

-- ============================================================
-- ╔══════════════════════════════════════╗
-- ║   SECCIÓN: INFORMATION — HOME        ║
-- ╚══════════════════════════════════════╝
-- ============================================================
local InfoSection = Window:CreateSection("Information")

local HomeTab = InfoSection:CreateTab({
    Name = "Home",
    Icon = "rbxassetid://7733960981",
})

HomeTab:CreateLabel("✦ Stylo723 — 1.0")
HomeTab:CreateLabel("Script Version: 1.0 | TPS Street Soccer")
HomeTab:CreateLabel("User: " .. tostring(LocalPlayer.Name))
HomeTab:CreateLabel("Rank: Premium User")
HomeTab:CreateDivider()
HomeTab:CreateLabel("╔══ Discord ══╗")
HomeTab:CreateLabel("https://discord.gg/ujuwhftzz5")
HomeTab:CreateLabel("╚════════════╝")
HomeTab:CreateDivider()
HomeTab:CreateLabel("Changelog v1.0:")
HomeTab:CreateLabel("• Migración completa a Redz UI")
HomeTab:CreateLabel("• Flag Func con bypass anti-crash")
HomeTab:CreateLabel("• Reach, Mossing y Reacts optimizados")

-- ============================================================
-- ╔══════════════════════════════════════╗
-- ║   SECCIÓN: MAIN — REACH              ║
-- ╚══════════════════════════════════════╝
-- ============================================================
local MainSection = Window:CreateSection("main :3")

local ReachTab = MainSection:CreateTab({
    Name = "Reach",
    Icon = "rbxassetid://7733960981",
})

-- Variables Reach
local reachEnabled  = P.reachEnabled
local reachDistance = P.reachDistance
local reachConnection

local function startReach()
    pcall(function()
        if reachConnection then reachConnection:Disconnect() end
        local _char, _root, _hum, _tps, _limb = nil, nil, nil, nil, nil
        local _lastRig, _frameSkip = nil, 0
        reachConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                if character ~= _char then
                    _char = character
                    _root = character:FindFirstChild("HumanoidRootPart")
                    _hum  = character:FindFirstChild("Humanoid")
                    _limb = nil
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
        end)
    end)
end

_G._StyReachRestart = function()
    if P.reachEnabled then pcall(startReach) end
end

ReachTab:CreateLabel("── Leg Reach (Method A) ──")

ReachTab:CreateToggle({
    Name     = "Active FireTouchInterest",
    Default  = false,
    Callback = function(state)
        pcall(function()
            reachEnabled   = state
            P.reachEnabled = state
            if state then
                startReach()
            else
                if reachConnection then reachConnection:Disconnect(); reachConnection = nil end
            end
        end)
    end,
})

ReachTab:CreateSlider({
    Name    = "Reach Distance",
    Range   = {1, 15},
    Default = 1,
    Increment = 1,
    Callback = function(val)
        pcall(function()
            reachDistance   = tonumber(val) or 1
            P.reachDistance = reachDistance
        end)
    end,
})

ReachTab:CreateDivider()
ReachTab:CreateLabel("── Leg Reach (Method B) ──")

ReachTab:CreateInput({
    Name        = "Leg Hitbox (R6)",
    PlaceholderText = "Valor mínimo: 1",
    RemoveTextAfterFocusLost = false,
    Callback    = function(value)
        pcall(function()
            local v = math.max(tonumber(value) or 1, 0.1)
            if LocalPlayer.Character then
                if LocalPlayer.Character:FindFirstChild("Right Leg") then
                    LocalPlayer.Character["Right Leg"].Size  = Vector3.new(v, 2, v)
                    LocalPlayer.Character["Left Leg"].Size   = Vector3.new(v, 2, v)
                    LocalPlayer.Character["Right Leg"].CanCollide = false
                    LocalPlayer.Character["Left Leg"].CanCollide  = false
                end
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Size      = Vector3.new(v, 2, v)
                    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end)
    end,
})

ReachTab:CreateInput({
    Name        = "Legs Size (R15)",
    PlaceholderText = "Mínimo: 1",
    RemoveTextAfterFocusLost = false,
    Callback    = function(value)
        pcall(function()
            local v = math.max(tonumber(value) or 1, 0.1)
            if LocalPlayer.Character then
                if LocalPlayer.Character:FindFirstChild("RightLowerLeg") then
                    LocalPlayer.Character["RightLowerLeg"].Size      = Vector3.new(v, 2, v)
                    LocalPlayer.Character["LeftLowerLeg"].Size       = Vector3.new(v, 2, v)
                    LocalPlayer.Character["RightLowerLeg"].CanCollide = false
                    LocalPlayer.Character["LeftLowerLeg"].CanCollide  = false
                end
                if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.Size      = Vector3.new(v, 2, v)
                    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
                end
            end
        end)
    end,
})

ReachTab:CreateButton({
    Name     = "Fake Legs (Appear Normal)",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid  = character:WaitForChild("Humanoid")
            if humanoid.RigType == Enum.HumanoidRigType.R6 then
                character["Right Leg"].Transparency = 1
                character["Left Leg"].Transparency  = 1
                character["Left Leg"].Massless      = true
                local LeftLegM = Instance.new("Part", character)
                LeftLegM.Name = "Left Leg Fake"; LeftLegM.CanCollide = false
                LeftLegM.Color = character["Left Leg"].Color
                LeftLegM.Size = Vector3.new(1, 2, 1)
                LeftLegM.Position = character["Left Leg"].Position
                local mh1 = Instance.new("Motor6D", character.Torso)
                mh1.Part0 = character.Torso; mh1.Part1 = LeftLegM
                mh1.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                mh1.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                character["Right Leg"].Massless = true
                local RightLegM = Instance.new("Part", character)
                RightLegM.Name = "Right Leg Fake"; RightLegM.CanCollide = false
                RightLegM.Color = character["Right Leg"].Color
                RightLegM.Size = Vector3.new(1, 2, 1)
                RightLegM.Position = character["Right Leg"].Position
                local mh2 = Instance.new("Motor6D", character.Torso)
                mh2.Part0 = character.Torso; mh2.Part1 = RightLegM
                mh2.C0 = CFrame.new(1,-1,0,0,0,1,0,1,-0,-1,0,0)
                mh2.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,-0,-1,0,0)
            end
        end)
    end,
})

-- ============================================================
-- ╔══════════════════════════════════════╗
-- ║   SECCIÓN: MAIN — MOSSING            ║
-- ╚══════════════════════════════════════╝
-- ============================================================
local MossingTab = MainSection:CreateTab({
    Name = "Mossing",
    Icon = "rbxassetid://7733960981",
})

local headReachEnabled = false
local headReachSize    = Vector3.new(1, 1.5, 1)
local headTransparency = 0.5
local headOffset       = Vector3.new(0, 0, 0)
local headBoxPart
local headConnection

local function updateHeadBox()
    pcall(function()
        if headBoxPart then headBoxPart:Destroy() end
        headBoxPart              = Instance.new("Part")
        headBoxPart.Size         = headReachSize
        headBoxPart.Transparency = headTransparency
        headBoxPart.Anchored     = true
        headBoxPart.CanCollide   = false
        headBoxPart.Color        = Color3.fromRGB(200, 30, 30)
        headBoxPart.Material     = Enum.Material.Neon
        headBoxPart.Name         = "HeadReachBox"
        headBoxPart.Parent       = Workspace
    end)
end

local function startHeadReach()
    if not headReachEnabled then return end
    pcall(function()
        if headConnection then headConnection:Disconnect() end
        updateHeadBox()
        local _head, _tps, _char = nil, nil, nil
        local _skipFrame = 0
        headConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
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
        end)
    end)
end

MossingTab:CreateToggle({
    Name     = "Active Moss Reach",
    Default  = false,
    Callback = function(state)
        pcall(function()
            headReachEnabled = state
            if state then
                startHeadReach()
            else
                if headConnection then headConnection:Disconnect() end
                if headBoxPart then headBoxPart:Destroy() end
            end
        end)
    end,
})

MossingTab:CreateSlider({
    Name      = "Range X",
    Range     = {0, 50},
    Default   = 1,
    Increment = 0.5,
    Callback  = function(val)
        pcall(function()
            headReachSize = Vector3.new(tonumber(val) or 1, headReachSize.Y, headReachSize.Z)
            if headReachEnabled then updateHeadBox() end
        end)
    end,
})

MossingTab:CreateSlider({
    Name      = "Range Y",
    Range     = {0, 50},
    Default   = 1.5,
    Increment = 0.5,
    Callback  = function(val)
        pcall(function()
            local v = tonumber(val) or 1.5
            headReachSize = Vector3.new(headReachSize.X, v, headReachSize.Z)
            headOffset    = Vector3.new(headOffset.X, v / 2.5, headOffset.Z)
            if headReachEnabled then updateHeadBox() end
        end)
    end,
})

MossingTab:CreateSlider({
    Name      = "Range Z",
    Range     = {0, 50},
    Default   = 1,
    Increment = 0.5,
    Callback  = function(val)
        pcall(function()
            headReachSize = Vector3.new(headReachSize.X, headReachSize.Y, tonumber(val) or 1)
            if headReachEnabled then updateHeadBox() end
        end)
    end,
})

MossingTab:CreateToggle({
    Name     = "Stealth Mode",
    Default  = false,
    Callback = function(v)
        pcall(function()
            headTransparency = v and 1 or 0.5
            if headReachEnabled and headBoxPart then
                headBoxPart.Transparency = headTransparency
            end
        end)
    end,
})

-- ============================================================
-- ╔══════════════════════════════════════╗
-- ║   SECCIÓN: MAIN — REACTS             ║
-- ╚══════════════════════════════════════╝
-- ============================================================
local ReactTab = MainSection:CreateTab({
    Name = "Reacts",
    Icon = "rbxassetid://7733960981",
})

local REACT_ACTIONS = {
    Kick=true, KickC1=true, Tackle=true, Header=true,
    SaveRA=true, SaveLA=true, SaveRL=true, SaveLL=true, SaveT=true
}

local currentReactPower = P.reactPower
local ballSpeedMult     = P.ballSpeedMult

local _reactBallCache = nil
local _reactHRPCache  = nil
local _reactCacheTick = 0

local function getReactTargets()
    pcall(function()
        _reactCacheTick = _reactCacheTick + 1
        if _reactCacheTick >= 2 then
            _reactCacheTick  = 0
            _reactBallCache = _G._StyRBall
            _reactHRPCache  = _G._StyRHRP
        end
    end)
    return _reactBallCache, _reactHRPCache
end

local function applyReactInstant(power)
    pcall(function()
        local p = tonumber(power)
        if not p or p ~= p then return end  -- NaN check
        p = math.clamp(p, 0, 1e30)
        local ball, hrp = getReactTargets()
        if not (ball and ball.Parent and hrp) then return end
        if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (p * ballSpeedMult)
    end)
end

local function enableReactHook()
    pcall(function()
        if _G._StyReactHookInstalled then return end
        _G._StyReactHookInstalled = true
        P.reactHookOn = true
        local meta        = getrawmetatable(game)
        local oldNamecall = meta.namecall
        setreadonly(meta, false)
        meta.namecall = newcclosure(function(self, ...)
            pcall(function()
                if getnamecallmethod() == "FireServer"
                    and currentReactPower > 0
                    and REACT_ACTIONS[tostring(self)] then
                    local ball, hrp = getReactTargets()
                    if ball and ball.Parent and hrp then
                        if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                        local safeP = math.clamp(tonumber(currentReactPower) or 0, 0, 1e30)
                        ball.AssemblyLinearVelocity = hrp.CFrame.LookVector * (safeP * ballSpeedMult)
                    end
                end
            end)
            return oldNamecall(self, ...)
        end)
        setreadonly(meta, true)
    end)
end

ReactTab:CreateLabel("⚡ Reacts V6 — Potencia MAXIMA ULTRA")

ReactTab:CreateButton({
    Name     = "🔥 ULTRA SPEED",
    Callback = function()
        pcall(function()
            currentReactPower = 5e18; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            RedzUI:Notify({ Title = "ULTRA SPEED", Content = "Ball a velocidad maxima!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "💀 MEGA POWER",
    Callback = function()
        pcall(function()
            currentReactPower = 1e25; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            RedzUI:Notify({ Title = "MEGA POWER", Content = "Potencia extrema activada", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "⚡ HYPER VELOCITY",
    Callback = function()
        pcall(function()
            currentReactPower = 2e22; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            RedzUI:Notify({ Title = "HYPER", Content = "Hyper velocidad maxima", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🚀 ULTIMATE KICK",
    Callback = function()
        pcall(function()
            currentReactPower = 8e20; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            RedzUI:Notify({ Title = "ULTIMATE", Content = "Patada definitiva", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "💥 MAX POWER",
    Callback = function()
        pcall(function()
            currentReactPower = 1e28; P.reactPower = currentReactPower
            enableReactHook(); applyReactInstant(currentReactPower)
            RedzUI:Notify({ Title = "MAX POWER", Content = "Potencia maxima absoluta", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🌀 HYPER SNAP",
    Callback = function()
        pcall(function()
            currentReactPower = 3e20; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 0.2 + Vector3.new(0, 0.1, 0))
                ball.AssemblyLinearVelocity   = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity  = Vector3.zero
            end
            RedzUI:Notify({ Title = "HYPER SNAP", Content = "SNAP ultra rapido!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "💀 MEGA LOCK",
    Callback = function()
        pcall(function()
            currentReactPower = 5e25; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.AssemblyLinearVelocity  = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            RedzUI:Notify({ Title = "MEGA LOCK", Content = "Lock super enganche!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🔴 ULTRA PIVOT",
    Callback = function()
        pcall(function()
            currentReactPower = 4e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                ball.CFrame = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 0.15)
                ball.AssemblyLinearVelocity  = hrp.CFrame.LookVector * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            RedzUI:Notify({ Title = "ULTRA PIVOT", Content = "Pivot ultra rapido!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "✝️ KENYAH MAX",
    Callback = function()
        pcall(function()
            currentReactPower = 6e23; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                ball.CFrame = CFrame.new(hrp.Position + look * 0.15 + Vector3.new(0, 0.05, 0))
                ball.AssemblyLinearVelocity  = look * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            RedzUI:Notify({ Title = "KENYAH MAX", Content = "Max power + predicion!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "💠 AERO MAX",
    Callback = function()
        pcall(function()
            currentReactPower = 5e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                local dir  = (look + Vector3.new(0, 0.08, 0)).Unit
                ball.CFrame = CFrame.new(hrp.Position + look * 0.18 + Vector3.new(0, 0.12, 0))
                ball.AssemblyLinearVelocity  = dir * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
            end
            RedzUI:Notify({ Title = "AERO MAX", Content = "Aereo ultra control!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "⚡ DUAL PULSE",
    Callback = function()
        pcall(function()
            currentReactPower = 7e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
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
            RedzUI:Notify({ Title = "DUAL PULSE", Content = "Doble pulso instantaneo!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🌐 OMNI MAX",
    Callback = function()
        pcall(function()
            currentReactPower = 8e22; P.reactPower = currentReactPower
            enableReactHook()
            local ball = _G._StyRBall; local hrp = _G._StyRHRP
            if ball and hrp then
                pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
                if ball.CanCollide then pcall(function() ball.CanCollide = false end) end
                local look = hrp.CFrame.LookVector
                ball.CFrame = CFrame.new(hrp.Position + look * 0.12)
                ball.AssemblyLinearVelocity  = look * (currentReactPower * ballSpeedMult)
                ball.AssemblyAngularVelocity = Vector3.zero
                task.defer(function()
                    if ball and ball.Parent and hrp and hrp.Parent then
                        local newLook    = hrp.CFrame.LookVector
                        local correction = (hrp.Position + newLook * 0.12 - ball.Position)
                        if correction.Magnitude > 0.3 then
                            ball.AssemblyLinearVelocity = correction.Unit * (currentReactPower * ballSpeedMult)
                        end
                    end
                end)
            end
            RedzUI:Notify({ Title = "OMNI MAX", Content = "Omni ultra!", Duration = 2 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🧤 Goalkeeper React",
    Callback = function()
        pcall(function()
            local gkMap = { SaveRA=true, SaveLA=true, SaveRL=true, SaveLL=true, SaveT=true, Tackle=true, Header=true }
            local meta   = getrawmetatable(game)
            local oldNC  = meta.namecall
            setreadonly(meta, false)
            meta.namecall = newcclosure(function(self, ...)
                pcall(function()
                    if getnamecallmethod() == "FireServer" and gkMap[tostring(self)] then
                        local args = {...}
                        local ch   = LocalPlayer.Character
                        local hum  = ch and ch:FindFirstChild("Humanoid")
                        if hum then args[2] = hum.LLCL; return oldNC(self, unpack(args)) end
                    end
                end)
                return oldNC(self, ...)
            end)
            setreadonly(meta, true)
            RedzUI:Notify({ Title = "GK React", Content = "Goalkeeper React activado", Duration = 2 })
        end)
    end,
})

ReactTab:CreateDivider()
ReactTab:CreateLabel("🎚️ Ball Speed Control")

ReactTab:CreateSlider({
    Name      = "Ball Speed Multiplier",
    Range     = {0.1, 50},
    Default   = 1.0,
    Increment = 0.1,
    Callback  = function(val)
        pcall(function()
            local v = tonumber(val) or 1.0
            if v ~= v then v = 1.0 end  -- NaN guard
            ballSpeedMult   = math.clamp(v, 0.1, 50)
            P.ballSpeedMult = ballSpeedMult
        end)
    end,
})

ReactTab:CreateLabel("🎯 Velocity Presets")

ReactTab:CreateButton({
    Name     = "Normal Mode (x1.0)",
    Callback = function()
        pcall(function()
            ballSpeedMult = 1.0; P.ballSpeedMult = ballSpeedMult
            RedzUI:Notify({ Title = "Velocity", Content = "Normal (x1.0)", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "Fast Mode (x50.0)",
    Callback = function()
        pcall(function()
            ballSpeedMult = 50.0; P.ballSpeedMult = ballSpeedMult
            RedzUI:Notify({ Title = "Velocity", Content = "Fast (x50.0)", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "🔥 UNLIMITED Mode",
    Callback = function()
        pcall(function()
            ballSpeedMult = 1e15; P.ballSpeedMult = ballSpeedMult
            RedzUI:Notify({ Title = "Velocity", Content = "UNLIMITED", Duration = 1 })
        end)
    end,
})

ReactTab:CreateDivider()
ReactTab:CreateLabel("React Power (base)")

ReactTab:CreateSlider({
    Name      = "React Power",
    Range     = {1, 100},
    Default   = 50,
    Increment = 1,
    Callback  = function(val)
        pcall(function()
            -- Mapeo interno: slider 1-100 → potencia real 1e18..1e30
            local mapped = 1e18 * (10 ^ (tonumber(val) / 100 * 12))
            currentReactPower = math.clamp(mapped, 1e18, 1e30)
            P.reactPower      = currentReactPower
        end)
    end,
})

-- ============================================================
-- NOTIFICACIÓN INICIAL
-- ============================================================
RedzUI:Notify({
    Title    = "Stylo723",
    Content  = "Script cargado correctamente. ¡Bienvenido!",
    Duration = 4,
})
