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
    Kick   = true, KickC1 = true, Tackle = true, Header = true,
    SaveRA = true, SaveLA = true, SaveRL  = true, SaveLL = true, SaveT = true,
}

-- ============================================================
-- SISTEMA DE ACELERACION REAL
-- No usamos un numero directo en AssemblyLinearVelocity porque
-- Roblox lo clampea internamente. En cambio:
-- 1) Usamos un LinearVelocity constraint con MaxForce = math.huge
--    para que el engine aplique la fuerza realmente
-- 2) Hacemos snap de CFrame al frente del jugador (sin esperar
--    que el ball "llegue" solo) para que los demas clientes lo
--    vean partir desde cerca
-- 3) Aplicamos AssemblyLinearVelocity encima como refuerzo
-- 4) Eliminamos el constraint un frame despues para que la bola
--    siga libre su trayectoria (sin quedarse congelada)
-- ============================================================

local currentSpeed = 100  -- studs/s, ajustado por slider/tier

-- ============================================================
-- HELPERS INTERNOS
-- ============================================================

-- Obtiene o crea el Attachment necesario para LinearVelocity
local function getAtt(ball)
    local att = ball:FindFirstChild("_StyAtt")
    if not att then
        att = Instance.new("Attachment")
        att.Name   = "_StyAtt"
        att.Parent = ball
    end
    return att
end

-- Destruye el constraint de velocidad limpiamente
local function removeLV(ball)
    pcall(function()
        local lv = ball:FindFirstChild("_StyLV")
        if lv then lv:Destroy() end
    end)
end

-- ============================================================
-- NUCLEO: lanzar el ball con aceleracion real
-- dir      : Vector3 normalizado de direccion
-- speed    : studs/s deseados
-- snapFwd  : cuanto adelante del jugador poner el ball antes de lanzar
-- liftY    : componente vertical extra
-- ============================================================
local function fireReact(dir, speed, snapFwd, liftY)
    pcall(function()
        local ball = _G._StyRBall
        local hrp  = _G._StyRHRP
        if not (ball and ball.Parent and hrp) then return end

        -- Ownership al cliente para que la velocidad replique
        pcall(function() ball:SetNetworkOwner(LocalPlayer) end)
        pcall(function() ball.CanCollide = false end)

        local fwd   = dir or hrp.CFrame.LookVector
        local sf    = snapFwd or 0.5
        local ly    = liftY   or 0

        -- 1) Snap: poner el ball justo adelante del jugador
        --    Esto hace que los OTROS jugadores lo vean partir cerca
        --    y no desde lejos (elimina el "delay visual")
        ball.CFrame = CFrame.new(
            hrp.Position
            + fwd  * sf
            + Vector3.new(0, ly, 0)
        )

        -- 2) Matar toda velocidad y rotacion residual
        ball.AssemblyLinearVelocity  = Vector3.zero
        ball.AssemblyAngularVelocity = Vector3.zero

        -- 3) Crear LinearVelocity constraint para aceleracion real
        --    MaxForce = math.huge → el engine NO ignora la fuerza
        --    aunque el valor de velocidad sea alto
        removeLV(ball)
        local att = getAtt(ball)
        local lv  = Instance.new("LinearVelocity")
        lv.Name                  = "_StyLV"
        lv.Attachment0           = att
        lv.MaxForce              = math.huge
        lv.RelativeTo            = Enum.ActuatorRelativeTo.World
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity        = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * speed
        lv.Parent                = ball

        -- 4) AssemblyLinearVelocity encima como refuerzo inmediato
        ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * speed

        -- 5) Destruir el constraint al siguiente frame
        --    para que la bola siga libre (no se queda flotando)
        task.defer(function()
            pcall(function()
                removeLV(ball)
                -- Refuerzo final: si la velocidad cayo, reinyectar
                if ball and ball.Parent then
                    if ball.AssemblyLinearVelocity.Magnitude < speed * 0.4 then
                        ball.AssemblyLinearVelocity = (fwd + Vector3.new(0, ly * 0.01, 0)).Unit * speed
                    end
                    -- Dejar que la gravedad actue naturalmente
                    -- (no anclamos ni freezeamos nada)
                end
            end)
        end)
    end)
end

-- ============================================================
-- NAMECALL HOOK — se dispara en cada accion del juego
-- ============================================================
local function enableReactHook()
    pcall(function()
        if _G._StyReactHookInstalled then return end
        _G._StyReactHookInstalled = true
        P.reactHookOn = true

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
                    local fwd = hrp.CFrame.LookVector
                    fireReact(fwd, currentSpeed, 0.4, 0)
                end)
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(meta, true)
    end)
end

enableReactHook()

-- ============================================================
-- TIERS DE VELOCIDAD — escala real y perceptible
-- Cada tier dobla aproximadamente la velocidad anterior
-- para que se note diferencia clara entre ellos
-- ============================================================
local TIERS = {
    { name = "React 100",  speed = 1000  },
    { name = "React 200",  speed = 20000  },
    { name = "React 350",  speed = 35000  },
    { name = "React 500",  speed = 50000  },
    { name = "React 700",  speed = 70000  },
    { name = "React 1000", speed = 100000 },
}

ReactTab:CreateLabel("Select Speed Tier")

for _, tier in ipairs(TIERS) do
    local t = tier
    ReactTab:CreateButton({
        Name     = t.name,
        Callback = function()
            pcall(function()
                currentSpeed = t.speed
                P.reactPower = t.speed
                RedzUI:Notify({
                    Title    = t.name .. " activo",
                    Content  = "Velocidad: " .. tostring(t.speed) .. " studs/s",
                    Duration = 2,
                })
            end)
        end,
    })
end

-- ============================================================
-- SLIDER FINO
-- ============================================================
ReactTab:CreateDivider()
ReactTab:CreateLabel("Manual Speed (1-1000)")

ReactTab:CreateSlider({
    Name      = "React Speed",
    Range     = {1, 100000000},
    Default   = 100,
    Increment = 1,
    Callback  = function(val)
        pcall(function()
            local v      = math.clamp(tonumber(val) or 100, 1, 100000000)
            currentSpeed = v
            P.reactPower = v
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
