-- ============================================================
--  Stylo723 — 1.0
--  Redz UI | Anti-Crash | Flag Inject | Sin auto-kick
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- BALL CANCOLLIDE GUARDIAN
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
-- SECURITY / CLEAN — sin kick, solo limpieza silenciosa
-- ============================================================
pcall(function()
    for _, b in pairs(workspace.FE.Actions:GetChildren()) do
        if b.Name == " " then b:Destroy() end
    end
end)

pcall(function()
    local ch = LocalPlayer.Character
    if ch then
        for _, b in pairs(ch:GetChildren()) do
            if b.Name == " " then b:Destroy() end
        end
    end
end)

pcall(function()
    local a = workspace.FE.Actions
    if not a then return end
    if a:FindFirstChild("KeepYourHeadUp_") then
        a.KeepYourHeadUp_:Destroy()
        local r = Instance.new("RemoteEvent")
        r.Name   = "KeepYourHeadUp_"
        r.Parent = a
    end
    -- Sin kick — se ignora silenciosamente si no existe
end)

local function isWeirdName(name)
    return string.match(name, "^[a-zA-Z]+%-%d+%a*%-%d+%a*$") ~= nil
end

local function deleteWeirdRemoteEvents(parent, depth)
    depth = depth or 0
    if depth > 6 then return end  -- guard anti stack-overflow
    pcall(function()
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") and isWeirdName(child.Name) then
                child:Destroy()
            else
                deleteWeirdRemoteEvents(child, depth + 1)
            end
        end
    end)
end
pcall(function() deleteWeirdRemoteEvents(game) end)

-- ============================================================
-- CARGA DE REDZ UI — captura correcta de la librería
-- ============================================================
local RedzUI
pcall(function()
    -- Redz UI asigna la librería a _G.RedzLib o la retorna
    -- Intentamos ambas formas para máxima compatibilidad
    -- URLs ordenadas de más a menos confiable; se prueba la primera que responda
    local URLS = {
        "https://raw.githubusercontent.com/tbao143/Library-ui/main/Redzhubui",
        "https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui",
        "https://raw.githubusercontent.com/REDZDEVS/RedzUI/main/Source",
    }
    local raw
    for _, url in ipairs(URLS) do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and #result > 100 then
            raw = result
            break
        end
    end
    if not raw then return end
    local loaded = loadstring(raw)()
    -- Forma 1: la librería se retorna directamente
    if type(loaded) == "table" then
        RedzUI = loaded
    end
    -- Forma 2: queda en _G.RedzLib
    if not RedzUI and type(_G.RedzLib) == "table" then
        RedzUI = _G.RedzLib
    end
    -- Forma 3: queda en _G.RedzhubUI o similar
    if not RedzUI then
        for _, key in pairs({"RedzLib","RedzhubUI","RedzHub","Redz","RedzUi","REDZUI","RedzUI","Library"}) do
            if type(_G[key]) == "table" then
                RedzUI = _G[key]
                break
            end
        end
    end
end)

-- Fallback de seguridad: si la UI no cargó, crear stub
-- para que el resto del script no crashee
if not RedzUI then
    RedzUI = {
        CreateWindow = function(_, o)
            local w = {}
            local function stub()
                local t = {}
                setmetatable(t, {__index = function() return function() return stub() end end})
                return t
            end
            return setmetatable(w, {__index = function() return stub end})
        end,
        Notify = function() end,
    }
    warn("[Stylo723] Redz UI no pudo cargarse. Revisa la URL o tu conexion.")
end

-- ============================================================
-- VENTANA PRINCIPAL
-- ============================================================
local Window = RedzUI:CreateWindow({
    Name   = "Stylo723 — 1.0",
    Status = "Stylo Team",
})

-- ============================================================
-- PERSISTENCIA GLOBAL
-- ============================================================
if not _G._Stylo723Persist then
    _G._Stylo723Persist = {
        reachEnabled  = false,
        reachDistance = 1,
        reactPower    = 100,
        ballSpeedMult = 1.0,
        reactHookOn   = false,
        flagValue     = "",
        currentSpeed  = 100,
    }
end
local P = _G._Stylo723Persist

-- Cache global de balón y HRP
if not _G._StyRBall then _G._StyRBall = nil end
if not _G._StyRHRP  then _G._StyRHRP  = nil end

if not _G._StyCacheWorker then
    _G._StyCacheWorker = RunService.RenderStepped:Connect(function()
        pcall(function()
            local sys        = Workspace:FindFirstChild("TPSSystem")
            _G._StyRBall     = sys and sys:FindFirstChild("TPS")
            local ch         = LocalPlayer.Character
            _G._StyRHRP      = ch and ch:FindFirstChild("HumanoidRootPart")
        end)
    end)
end

if not _G._StyCharConn then
    _G._StyCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
        pcall(function()
            _G._StyRHRP = char:WaitForChild("HumanoidRootPart", 3)
            if P.reachEnabled and _G._StyReachRestart then
                task.wait(0.05)
                _G._StyReachRestart()
            end
        end)
    end)
end

-- ============================================================
-- SECTION: FLAG FUNC
-- ============================================================
local FlagSection = Window:CreateSection("Flag Func")

local _flagCurrentValue = tostring(P.flagValue or "")
local _flagActive       = false

local function safeFlagInject(rawInput)
    local result = ""
    pcall(function()
        local numVal = tonumber(rawInput)
        if numVal then
            local safeVal     = math.clamp(numVal, -1e30, 1e30)
            _flagCurrentValue = tostring(safeVal)
            P.flagValue       = _flagCurrentValue
            if _G._StyRBall and _G._StyRBall.Parent then
                pcall(function() _G._StyRBall.CanCollide = false end)
            end
        else
            local sanitized   = tostring(rawInput or "")
            if #sanitized > 256 then sanitized = sanitized:sub(1, 256) end
            _flagCurrentValue = sanitized
            P.flagValue       = sanitized
        end
        result = _flagCurrentValue
    end)
    if result == "" then
        _flagCurrentValue = ""
        P.flagValue       = ""
    end
    return _flagCurrentValue
end

FlagSection:CreateToggle({
    Name     = "Flag Inject",
    Default  = false,
    Callback = function(state)
        pcall(function()
            _flagActive = state
            local result = safeFlagInject(_flagCurrentValue)
            RedzUI:Notify({
                Title    = "Stylo723",
                Content  = state and ("Flag activo: " .. tostring(result)) or "Flag desactivado.",
                Duration = 2,
            })
        end)
    end,
})

FlagSection:CreateInput({
    Name                     = "Flag Value",
    PlaceholderText          = "Numero o texto...",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(text)
        pcall(function()
            local result = safeFlagInject(text)
            if _flagActive then
                RedzUI:Notify({ Title = "Flag", Content = "Aplicado: " .. tostring(result), Duration = 2 })
            end
        end)
    end,
})

FlagSection:CreateButton({
    Name     = "Inject Now",
    Callback = function()
        pcall(function()
            local result = safeFlagInject(_flagCurrentValue)
            RedzUI:Notify({ Title = "Flag Inject", Content = "OK: " .. tostring(result), Duration = 2 })
        end)
    end,
})

FlagSection:CreateButton({
    Name     = "Reset Flag",
    Callback = function()
        pcall(function()
            _flagCurrentValue = ""
            P.flagValue       = ""
            _flagActive       = false
            RedzUI:Notify({ Title = "Flag", Content = "Reseteado.", Duration = 2 })
        end)
    end,
})

-- ============================================================
-- SECTION: INFORMATION — HOME
-- ============================================================
local InfoSection = Window:CreateSection("Information")

local HomeTab = InfoSection:CreateTab({
    Name = "Home",
    Icon = "rbxassetid://7733960981",
})

HomeTab:CreateLabel("Stylo723 — 1.0")
HomeTab:CreateLabel("Script Version: 1.0 | TPS Street Soccer")
HomeTab:CreateLabel("User: " .. tostring(LocalPlayer.Name))
HomeTab:CreateLabel("Rank: Premium User")
HomeTab:CreateDivider()
HomeTab:CreateLabel("Discord: https://discord.gg/ujuwhftzz5")
HomeTab:CreateDivider()
HomeTab:CreateLabel("Changelog v1.0:")
HomeTab:CreateLabel("Migracion a Redz UI | Flag Func | Reacts mejorados")

-- ============================================================
-- SECTION: MAIN — REACH
-- ============================================================
local MainSection = Window:CreateSection("main :3")

local ReachTab = MainSection:CreateTab({
    Name = "Reach",
    Icon = "rbxassetid://7733960981",
})

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
        end)
    end)
end

_G._StyReachRestart = function()
    if P.reachEnabled then pcall(startReach) end
end

ReachTab:CreateLabel("Leg Reach — Method A")

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
    Name      = "Reach Distance",
    Range     = {1, 15},
    Default   = 1,
    Increment = 1,
    Callback  = function(val)
        pcall(function()
            reachDistance   = tonumber(val) or 1
            P.reachDistance = reachDistance
        end)
    end,
})

ReachTab:CreateDivider()
ReachTab:CreateLabel("Leg Reach — Method B")

ReachTab:CreateInput({
    Name                     = "Leg Hitbox (R6)",
    PlaceholderText          = "Minimo: 1",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(value)
        pcall(function()
            local v = math.max(tonumber(value) or 1, 0.1)
            local c = LocalPlayer.Character
            if not c then return end
            for _, n in pairs({"Right Leg", "Left Leg"}) do
                local p = c:FindFirstChild(n)
                if p then p.Size = Vector3.new(v, 2, v); p.CanCollide = false end
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(v, 2, v); hrp.CanCollide = false end
        end)
    end,
})

ReachTab:CreateInput({
    Name                     = "Legs Size (R15)",
    PlaceholderText          = "Minimo: 1",
    RemoveTextAfterFocusLost = false,
    Callback                 = function(value)
        pcall(function()
            local v = math.max(tonumber(value) or 1, 0.1)
            local c = LocalPlayer.Character
            if not c then return end
            for _, n in pairs({"RightLowerLeg", "LeftLowerLeg"}) do
                local p = c:FindFirstChild(n)
                if p then p.Size = Vector3.new(v, 2, v); p.CanCollide = false end
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(v, 2, v); hrp.CanCollide = false end
        end)
    end,
})

ReachTab:CreateButton({
    Name     = "Fake Legs (Appear Normal)",
    Callback = function()
        pcall(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid  = character:WaitForChild("Humanoid")
            if humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end
            for _, side in pairs({"Left", "Right"}) do
                local real = character[side .. " Leg"]
                real.Transparency = 1
                real.Massless     = true
                local fake = Instance.new("Part", character)
                fake.Name      = side .. " Leg Fake"
                fake.CanCollide = false
                fake.Color      = real.Color
                fake.Size       = Vector3.new(1, 2, 1)
                fake.Position   = real.Position
                local motor = Instance.new("Motor6D", character.Torso)
                motor.Part0 = character.Torso
                motor.Part1 = fake
                if side == "Left" then
                    motor.C0 = CFrame.new(-1,-1,0,0,0,-1,0,1,0,1,0,0)
                    motor.C1 = CFrame.new(-0.5,1,0,0,0,-1,0,1,0,1,0,0)
                else
                    motor.C0 = CFrame.new(1,-1,0,0,0,1,0,1,0,-1,0,0)
                    motor.C1 = CFrame.new(0.5,1,0,0,0,1,0,1,0,-1,0,0)
                end
            end
        end)
    end,
})

-- ============================================================
-- SECTION: MAIN — MOSSING
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
-- SECTION: MAIN — REACTS
-- ============================================================
local ReactTab = MainSection:CreateTab({
    Name = "Reacts",
    Icon = "rbxassetid://7733960981",
})

local REACT_ACTIONS = {
    Kick   = true, KickC1 = true, Tackle = true, Header = true,
    SaveRA = true, SaveLA = true, SaveRL  = true, SaveLL = true, SaveT = true,
}

-- Variables de velocidad — declaradas aqui, usadas en todo el bloque
local currentSpeed    = P.currentSpeed  or 100
local ballSpeedMult   = P.ballSpeedMult or 1.0
local currentReactPower = P.reactPower  or 100

-- ============================================================
-- HELPERS INTERNOS DE REACTS
-- ============================================================
local function getAtt(ball)
    local att = ball:FindFirstChild("_StyAtt")
    if not att then
        att        = Instance.new("Attachment")
        att.Name   = "_StyAtt"
        att.Parent = ball
    end
    return att
end

local function removeLV(ball)
    pcall(function()
        local lv = ball:FindFirstChild("_StyLV")
        if lv then lv:Destroy() end
    end)
end

-- ============================================================
-- NUCLEO DE DISPARO
-- Usa LinearVelocity constraint (fuerza real del engine)
-- + AssemblyLinearVelocity como refuerzo inmediato
-- + snap de posicion solo si el ball esta muy lejos
-- + limpia velocidad residual antes de aplicar nueva
-- ============================================================
local function fireReact(dir, speed, snapFwd, liftY)
    pcall(function()
        local ball = _G._StyRBall
        local hrp  = _G._StyRHRP
        if not (ball and ball.Parent and hrp) then return end

        local s  = math.clamp(tonumber(speed) or currentSpeed, 1, 5000)
        local fwd = dir or hrp.CFrame.LookVector
        local sf  = snapFwd or 0.4
        local ly  = liftY   or 0

        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        pcall(function() ball.CanCollide = false end)

        -- Snap solo si el ball esta lejos (>6 studs)
        -- Esto elimina el delay visual en los otros clientes
        local dist = (ball.Position - hrp.Position).Magnitude
        if dist > 6 then
            ball.CFrame = CFrame.new(
                hrp.Position + fwd * sf + Vector3.new(0, ly, 0)
            )
        end

        -- Limpiar velocidades residuales
        ball.AssemblyLinearVelocity  = Vector3.zero
        ball.AssemblyAngularVelocity = Vector3.zero

        -- LinearVelocity constraint: fuerza fisica real
        -- MaxForce = math.huge obliga al engine a aplicarla
        -- sin que el physics stepper la descarte
        removeLV(ball)
        local att = getAtt(ball)
        local lv  = Instance.new("LinearVelocity")
        lv.Name                   = "_StyLV"
        lv.Attachment0            = att
        lv.MaxForce               = math.huge
        lv.RelativeTo             = Enum.ActuatorRelativeTo.World
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity         = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * s
        lv.Parent                 = ball

        -- Refuerzo directo encima
        ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * s

        -- Destruir constraint en el siguiente frame
        -- para que el ball siga libre (no queda flotando)
        task.defer(function()
            pcall(function()
                removeLV(ball)
                if ball and ball.Parent then
                    -- Si la velocidad bajo demasiado, reinyectar
                    if ball.AssemblyLinearVelocity.Magnitude < s * 0.4 then
                        ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * s
                    end
                end
            end)
        end)
    end)
end

-- ============================================================
-- NAMECALL HOOK — unico, instalado una sola vez en _G
-- ============================================================
local function enableReactHook()
    pcall(function()
        if _G._StyReactHookInstalled then return end
        _G._StyReactHookInstalled = true

        local meta        = getrawmetatable(game)
        local oldNamecall = meta.namecall
        setreadonly(meta, false)

        meta.namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and REACT_ACTIONS[tostring(self)] then
                pcall(function()
                    local ball = _G._StyRBall
                    local hrp  = _G._StyRHRP
                    if not (ball and ball.Parent and hrp) then return end
                    fireReact(hrp.CFrame.LookVector, currentSpeed, 0.4, 0)
                end)
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(meta, true)
    end)
end

enableReactHook()

-- ============================================================
-- TIERS DE VELOCIDAD
-- Escala progresiva real — cada tier se siente distinto
-- ============================================================
local TIERS = {
    { name = "React 100",  speed = 100  },
    { name = "React 200",  speed = 200  },
    { name = "React 350",  speed = 350  },
    { name = "React 500",  speed = 500  },
    { name = "React 700",  speed = 700  },
    { name = "React 1000", speed = 1000 },
}

ReactTab:CreateLabel("Select Speed Tier")

for _, tier in ipairs(TIERS) do
    local t = tier
    ReactTab:CreateButton({
        Name     = t.name,
        Callback = function()
            pcall(function()
                currentSpeed        = t.speed
                currentReactPower   = t.speed
                P.currentSpeed      = t.speed
                P.reactPower        = t.speed
                RedzUI:Notify({
                    Title    = t.name,
                    Content  = "Velocidad activa: " .. tostring(t.speed),
                    Duration = 2,
                })
            end)
        end,
    })
end

-- ============================================================
-- SLIDER FINO — control manual de 1 a 1000
-- ============================================================
ReactTab:CreateDivider()
ReactTab:CreateLabel("Manual Speed Control")

ReactTab:CreateSlider({
    Name      = "React Speed",
    Range     = {1, 1000},
    Default   = 100,
    Increment = 1,
    Callback  = function(val)
        pcall(function()
            local v             = math.clamp(tonumber(val) or 100, 1, 1000)
            currentSpeed        = v
            currentReactPower   = v
            P.currentSpeed      = v
            P.reactPower        = v
        end)
    end,
})

-- ============================================================
-- DISPAROS MANUALES
-- ============================================================
ReactTab:CreateDivider()
ReactTab:CreateLabel("Manual Fire")

ReactTab:CreateButton({
    Name     = "Ground Shot",
    Callback = function()
        pcall(function()
            local hrp = _G._StyRHRP
            if not hrp then return end
            fireReact(hrp.CFrame.LookVector, currentSpeed, 0.4, 0)
            RedzUI:Notify({ Title = "Ground Shot", Content = tostring(currentSpeed) .. " s/s", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "Lifted Shot",
    Callback = function()
        pcall(function()
            local hrp = _G._StyRHRP
            if not hrp then return end
            local look  = hrp.CFrame.LookVector
            local angle = math.rad(20)
            local dir   = Vector3.new(
                look.X * math.cos(angle),
                math.sin(angle),
                look.Z * math.cos(angle)
            ).Unit
            fireReact(dir, currentSpeed, 0.4, 0)
            RedzUI:Notify({ Title = "Lifted Shot", Content = tostring(currentSpeed) .. " s/s | 20deg", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "Aerial Shot",
    Callback = function()
        pcall(function()
            local hrp = _G._StyRHRP
            if not hrp then return end
            local look  = hrp.CFrame.LookVector
            local angle = math.rad(35)
            local dir   = Vector3.new(
                look.X * math.cos(angle),
                math.sin(angle),
                look.Z * math.cos(angle)
            ).Unit
            fireReact(dir, currentSpeed, 0.3, 0)
            RedzUI:Notify({ Title = "Aerial Shot", Content = tostring(currentSpeed) .. " s/s | 35deg", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "Snap and Fire",
    Callback = function()
        pcall(function()
            local ball = _G._StyRBall
            local hrp  = _G._StyRHRP
            if not (ball and hrp) then return end
            pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
            pcall(function() ball.CanCollide = false end)
            local look = hrp.CFrame.LookVector
            ball.CFrame = CFrame.new(hrp.Position + look * 0.3 + Vector3.new(0, 0.1, 0))
            ball.AssemblyLinearVelocity  = Vector3.zero
            ball.AssemblyAngularVelocity = Vector3.zero
            task.wait()
            fireReact(look, currentSpeed, 0, 0)
            RedzUI:Notify({ Title = "Snap and Fire", Content = tostring(currentSpeed) .. " s/s", Duration = 1 })
        end)
    end,
})

ReactTab:CreateButton({
    Name     = "Goalkeeper Clear",
    Callback = function()
        pcall(function()
            local hrp = _G._StyRHRP
            if not hrp then return end
            local look  = hrp.CFrame.LookVector
            local angle = math.rad(15)
            local dir   = Vector3.new(
                look.X * math.cos(angle),
                math.sin(angle),
                look.Z * math.cos(angle)
            ).Unit
            fireReact(dir, currentSpeed, 0.4, 0)
            RedzUI:Notify({ Title = "GK Clear", Content = tostring(currentSpeed) .. " s/s", Duration = 1 })
        end)
    end,
})

-- ============================================================
-- NOTIFICACION INICIAL
-- ============================================================
RedzUI:Notify({
    Title    = "Stylo723",
    Content  = "Script cargado. Bienvenido!",
    Duration = 4,
})
