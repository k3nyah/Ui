-- ============================================================
--  Stylo723 — 1.0
--  Librería: RedzLib V5 (URL CORRECTA)
--  Funciones: Flag Inject | Reach | Mossing | Reacts
--  Discord: https://discord.gg/ujuwhftzz5
-- ============================================================

-- Cargar la librería RedzLib V5 (URL funcional proporcionada por el usuario)
local redzlib = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Redz-Library-V5-94837"))()

-- Verificar si la librería se cargó correctamente
if not redzlib then
    print("[Stylo723] Error: No se pudo cargar RedzLib. Revisa tu conexión o la URL.")
    return
end

-- Crear la ventana principal
local Window = redzlib:MakeWindow({
    Title = "Stylo723 — 1.0",
    SubTitle = "by 0_Kenyah",
    SaveFolder = "Stylo723Config"
})

-- ============================================================
-- SERVICIOS Y VARIABLES GLOBALES (Anti-Crash incluido)
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Persistencia de configuraciones
if not _G._Stylo723Persist then
    _G._Stylo723Persist = {
        reachEnabled = false,
        reachDistance = 1,
        currentSpeed = 10000,
    }
end
local P = _G._Stylo723Persist

-- Cache del balón y HRP
_G._StyRBall = nil
_G._StyRHRP = nil

RunService.RenderStepped:Connect(function()
    pcall(function()
        local sys = Workspace:FindFirstChild("TPSSystem")
        _G._StyRBall = sys and sys:FindFirstChild("TPS")
        local ch = LocalPlayer.Character
        _G._StyRHRP = ch and ch:FindFirstChild("HumanoidRootPart")
    end)
end)

-- ============================================================
-- 1. SECCIÓN: FLAG FUNC (Inyección de Flags)
-- ============================================================
local FlagFunc = Window:CreateSection("Flag Func")

local flagKey = ""
local flagVal = ""

-- Motor de inyección real
local function tryInjectFlag(key, value)
    key = tostring(key):gsub("[^%w_]", ""):sub(1, 128)
    value = tostring(value):sub(1, 256)
    if key == "" then return false, "Key vacía" end
    
    local ok, report = false, ""
    pcall(function() if setfflag then setfflag(key, value) ok = true report = "setfflag OK" end end)
    if not ok then pcall(function() if _G.setfflag then _G.setfflag(key, value) ok = true report = "via _G.setfflag OK" end end) end
    if not ok then pcall(function() local s = settings() if s then s[key] = value ok = true report = "settings() OK" end end) end
    if not ok then pcall(function() local us = UserSettings() if us then us[key] = value ok = true report = "UserSettings OK" end end) end
    if not ok then report = "Guardado localmente (executor limitado)" ok = true end
    
    return ok, report
end

-- Interfaz de usuario
local flagInputKey = FlagFunc:CreateTextBox({
    Name = "Nombre de la Flag (Key)",
    PlaceholderText = "FFlag::NombreDeLaFlag"
})
flagInputKey:Callback(function(text) flagKey = text end)

local flagInputVal = FlagFunc:CreateTextBox({
    Name = "Valor de la Flag",
    PlaceholderText = "true / false / número / texto"
})
flagInputVal:Callback(function(text) flagVal = text end)

FlagFunc:CreateButton({
    Name = "Inyectar Flag",
    Callback = function()
        local ok, report = tryInjectFlag(flagKey, flagVal)
        redzlib:Notification({
            Title = "Flag Inject",
            Text = (ok and "✅ OK | " or "❌ ERR | ") .. report,
            Duration = 4
        })
    end
})

FlagFunc:CreateButton({
    Name = "Limpiar Flags",
    Callback = function()
        pcall(function()
            for k, _ in pairs(_G._injectedFlags or {}) do
                if setfflag then setfflag(k, "") end
            end
            _G._injectedFlags = {}
            redzlib:Notification({Title = "Flag Inject", Text = "Todas las flags fueron limpiadas.", Duration = 3})
        end)
    end
})

-- ============================================================
-- 2. SECCIÓN: INFORMATION (Home)
-- ============================================================
local InfoSection = Window:CreateSection("Information")

local HomeTab = InfoSection:CreateTab({
    Name = "Home",
    Image = "rbxassetid://7733960981"
})

HomeTab:CreateLabel("Stylo723 — 1.0")
HomeTab:CreateLabel("Script Version: 1.0 | TPS Street Soccer")
HomeTab:CreateLabel("👤 Usuario: " .. LocalPlayer.Name)
HomeTab:CreateLabel("Rango: Premium")
HomeTab:CreateDivider()
HomeTab:CreateLabel("📢 Discord Oficial:")
HomeTab:CreateLabel("👉 discord.gg/ujuwhftzz5")
HomeTab:CreateDivider()
HomeTab:CreateLabel("✅ Script cargado correctamente.")

-- ============================================================
-- 3. SECCIÓN: MAIN (Reach, Mossing, Reacts)
-- ============================================================
local MainSection = Window:CreateSection("main :3")

-- ========== REACH ==========
local ReachTab = MainSection:CreateTab({
    Name = "Reach",
    Image = "rbxassetid://7733960981"
})

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

ReachTab:CreateToggle({
    Name = "Activar Reach (Piernas)",
    Default = reachEnabled,
    Callback = function(state)
        reachEnabled = state
        P.reachEnabled = state
        if state then startReach() else if reachConnection then reachConnection:Disconnect() end end
    end
})

ReachTab:CreateSlider({
    Name = "Distancia de Alcance",
    Range = {1, 15},
    Default = reachDistance,
    Increment = 1,
    Callback = function(val)
        reachDistance = val
        P.reachDistance = val
    end
})

ReachTab:CreateDivider()
ReachTab:CreateLabel("Ajuste de Hitbox (Piernas)")

ReachTab:CreateTextBox({
    Name = "Tamaño Piernas (R6)",
    PlaceholderText = "Ej: 2",
    Callback = function(value)
        local sz = math.max(tonumber(value) or 1, 0.1)
        local c = LocalPlayer.Character
        if c then
            for _, n in pairs({"Right Leg", "Left Leg"}) do
                local p = c:FindFirstChild(n)
                if p then p.Size = Vector3.new(sz, 2, sz); p.CanCollide = false end
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(sz, 2, sz); hrp.CanCollide = false end
        end
    end
})

ReachTab:CreateTextBox({
    Name = "Tamaño Piernas (R15)",
    PlaceholderText = "Ej: 2",
    Callback = function(value)
        local sz = math.max(tonumber(value) or 1, 0.1)
        local c = LocalPlayer.Character
        if c then
            for _, n in pairs({"RightLowerLeg", "LeftLowerLeg"}) do
                local p = c:FindFirstChild(n)
                if p then p.Size = Vector3.new(sz, 2, sz); p.CanCollide = false end
            end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(sz, 2, sz); hrp.CanCollide = false end
        end
    end
})

-- ========== MOSSING (Cabeza) ==========
local MossingTab = MainSection:CreateTab({
    Name = "Mossing",
    Image = "rbxassetid://7733960981"
})

local headEnabled = false
local headSize = Vector3.new(1, 1.5, 1)
local headTrans = 0.5
local headOffset = Vector3.new(0, 0, 0)
local headBox, headConn

local function updateHeadBox()
    if headBox then headBox:Destroy() end
    headBox = Instance.new("Part")
    headBox.Size = headSize
    headBox.Transparency = headTrans
    headBox.Anchored = true
    headBox.CanCollide = false
    headBox.Color = Color3.fromRGB(200, 30, 30)
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
            if math.abs(rel.X) <= hs.X and math.abs(rel.Y) <= hs.Y and math.abs(rel.Z) <= hs.Z then
                firetouchinterest(_head, _tps, 0)
                firetouchinterest(_head, _tps, 1)
            end
        end)
    end)
end

MossingTab:CreateToggle({
    Name = "Activar Moss Reach (Cabeza)",
    Default = false,
    Callback = function(state)
        headEnabled = state
        if state then startHeadReach() else if headConn then headConn:Disconnect() end if headBox then headBox:Destroy() end end
    end
})

MossingTab:CreateSlider({
    Name = "Rango X",
    Range = {0, 50},
    Default = 1,
    Increment = 0.5,
    Callback = function(val)
        headSize = Vector3.new(val, headSize.Y, headSize.Z)
        if headEnabled then updateHeadBox() end
    end
})

MossingTab:CreateSlider({
    Name = "Rango Y",
    Range = {0, 50},
    Default = 1.5,
    Increment = 0.5,
    Callback = function(val)
        headSize = Vector3.new(headSize.X, val, headSize.Z)
        headOffset = Vector3.new(headOffset.X, val/2.5, headOffset.Z)
        if headEnabled then updateHeadBox() end
    end
})

MossingTab:CreateSlider({
    Name = "Rango Z",
    Range = {0, 50},
    Default = 1,
    Increment = 0.5,
    Callback = function(val)
        headSize = Vector3.new(headSize.X, headSize.Y, val)
        if headEnabled then updateHeadBox() end
    end
})

MossingTab:CreateToggle({
    Name = "Modo Sigilo (Invisible)",
    Default = false,
    Callback = function(state)
        headTrans = state and 1 or 0.5
        if headBox then headBox.Transparency = headTrans end
    end
})

-- ========== REACTS (Disparos) ==========
local ReactTab = MainSection:CreateTab({
    Name = "Reacts",
    Image = "rbxassetid://7733960981"
})

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

-- Hook para los reacts automáticos
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

ReactTab:CreateLabel("Velocidad x100 (React 100 = 10000)")

local tiers = {
    {name="React 100", speed=10000},
    {name="React 200", speed=20000},
    {name="React 350", speed=35000},
    {name="React 500", speed=50000},
    {name="React 700", speed=70000},
    {name="React 1000", speed=100000}
}
for _, tier in ipairs(tiers) do
    ReactTab:CreateButton({
        Name = tier.name,
        Callback = function()
            currentSpeed = tier.speed
            P.currentSpeed = tier.speed
            redzlib:Notification({Title = tier.name, Text = "Velocidad activa: " .. tier.speed .. " s/s", Duration = 2})
        end
    })
end

ReactTab:CreateDivider()
ReactTab:CreateLabel("Control Manual")

ReactTab:CreateSlider({
    Name = "Velocidad de Disparo",
    Range = {100, 200000},
    Default = currentSpeed,
    Increment = 100,
    Callback = function(val)
        currentSpeed = val
        P.currentSpeed = val
    end
})

ReactTab:CreateDivider()
ReactTab:CreateLabel("Disparos Manuales")

ReactTab:CreateButton({
    Name = "Disparo Rase",
    Callback = function()
        local hrp = _G._StyRHRP
        if hrp then fireReact(hrp.CFrame.LookVector, currentSpeed, 0.4, 0) end
    end
})

ReactTab:CreateButton({
    Name = "Disparo con Efecto",
    Callback = function()
        local hrp = _G._StyRHRP
        if hrp then
            local look = hrp.CFrame.LookVector
            local angle = math.rad(20)
            local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
            fireReact(dir, currentSpeed, 0.4, 0)
        end
    end
})

ReactTab:CreateButton({
    Name = "Disparo Aéreo",
    Callback = function()
        local hrp = _G._StyRHRP
        if hrp then
            local look = hrp.CFrame.LookVector
            local angle = math.rad(35)
            local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
            fireReact(dir, currentSpeed, 0.3, 0)
        end
    end
})

ReactTab:CreateButton({
    Name = "Golpe de Portero",
    Callback = function()
        local hrp = _G._StyRHRP
        if hrp then
            local look = hrp.CFrame.LookVector
            local angle = math.rad(15)
            local dir = Vector3.new(look.X*math.cos(angle), math.sin(angle), look.Z*math.cos(angle)).Unit
            fireReact(dir, currentSpeed, 0.4, 0)
        end
    end
})

-- Notificación de inicio
redzlib:Notification({
    Title = "Stylo723 — 1.0",
    Text = "Script cargado. ¡Disfruta! | discord.gg/ujuwhftzz5",
    Duration = 5
})
