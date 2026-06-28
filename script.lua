local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Mobile Tactical Menu",
    LoadingTitle = "Delta & Solara",
    LoadingSubtitle = "by Messer",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("Features", 4483362458)
local Plr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local EspActive, Flying = false, false
local FlySpeed = 50
local IsSprinting = false

-- Таблица для контроля запущенных анимаций
local ActiveTracks = {}

-- Функция для проигрывания/остановки кастомных анимаций
local function ToggleAnimation(AnimId, SlotName)
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Animator = Hum and Hum:FindFirstChildOfClass("Animator")
    
    if not Animator then return end
    
    -- Если анимация уже играет — останавливаем её
    if ActiveTracks[SlotName] then
        ActiveTracks[SlotName]:Stop()
        ActiveTracks[SlotName] = nil
        return
    end
    
    -- Останавливаем другие кастомные треки из нашего меню перед запуском нового
    for slot, track in pairs(ActiveTracks) do
        track:Stop()
        ActiveTracks[slot] = nil
    end
    
    -- Создаем и загружаем новую анимацию
    local Anim = Instance.new("Animation")
    Anim.AnimationId = "rbxassetid://" .. tostring(AnimId)
    
    local Success, Track = pcall(function()
        return Animator:LoadAnimation(Anim)
    end)
    
    if Success and Track then
        Track.Looped = true
        Track:Play()
        ActiveTracks[SlotName] = Track
    end
end

-- Плавное изменение FOV
local TargetFOV = 70
task.spawn(function()
    while task.wait() do
        if Camera.FieldOfView ~= TargetFOV then
            Camera.FieldOfView = Camera.FieldOfView + (TargetFOV - Camera.FieldOfView) * 0.15
            if math.abs(Camera.FieldOfView - TargetFOV) < 0.1 then
                Camera.FieldOfView = TargetFOV
            end
        end
    end
end)

local function GetRoleColor(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
            return Color3.fromRGB(255, 0, 0)
        elseif player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
            return Color3.fromRGB(0, 0, 255)
        end
    end
    return Color3.fromRGB(0, 255, 0)
end

local function UpdateESP()
    for _, player in pairs(game.Players:GetChildren()) do
        if player ~= Plr and player.Character then
            local current = player.Character:FindFirstChild("EspMesser")
            if EspActive then
                local targetColor = GetRoleColor(player)
                if not current then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "EspMesser"
                    highlight.FillColor = targetColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = player.Character
                else
                    current.FillColor = targetColor
                end
            elseif not EspActive and current then
                current:Destroy()
            end
        end
    end
end

local function ToggleFly(State)
    Flying = State
    local Char = Plr.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local HRP = Char.HumanoidRootPart
    
    if Flying then
        local BV = Instance.new("BodyVelocity")
        BV.Name = "FlyVelocity"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Parent = HRP
        
        task.spawn(function()
            while Flying and task.wait() do
                if Char:FindFirstChild("Humanoid") then
                    local LookDir = Camera.CFrame.LookVector
                    local MoveDir = Char.Humanoid.MoveDirection
                    
                    if MoveDir.Magnitude > 0 then
                        BV.Velocity = LookDir * FlySpeed
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
        end)
    else
        if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
    end
end

-- Бинды управления механизмами
Tab:CreateKeybind({
    Name = "Sprint (Z)",
    CurrentKeybind = "Z",
    HoldToToggle = false,
    Callback = function()
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            IsSprinting = not IsSprinting
            Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
            TargetFOV = IsSprinting and 110 or 70
        end
    end,
})

Tab:CreateKeybind({
    Name = "ESP Roles (V)",
    CurrentKeybind = "V",
    HoldToToggle = false,
    Callback = function() 
        EspActive = not EspActive
        UpdateESP()
    end,
})

Tab:CreateKeybind({
    Name = "Fly & NoClip (F)",
    CurrentKeybind = "F",
    HoldToToggle = false,
    Callback = function() ToggleFly(not Flying) end
})

-- Бинды на анимации-насмешки
Tab:CreateKeybind({
    Name = "Nervy Dance (N)",
    CurrentKeybind = "N",
    HoldToToggle = false,
    Callback = function()
        ToggleAnimation(14349258288, "Nervy")
    end
})

Tab:CreateKeybind({
    Name = "King Nasir Dance (K)",
    CurrentKeybind = "K",
    HoldToToggle = false,
    Callback = function()
        ToggleAnimation(16912306733, "Nasir")
    end
})

task.spawn(function()
    while task.wait(0.5) do
        if EspActive then UpdateESP() end
    end
end)
