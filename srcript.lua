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
                    -- Расчет направления движения относительно взгляда камеры
                    local LookDir = Camera.CFrame.LookVector
                    local MoveDir = Char.Humanoid.MoveDirection
                    
                    if MoveDir.Magnitude > 0 then
                        -- Если зажаты кнопки движения, летим в сторону взгляда
                        BV.Velocity = LookDir * FlySpeed
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                
                -- Логика NoClip (отключение коллизий во время полета)
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

Tab:CreateKeybind({
    Name = "Sprint (Z)",
    CurrentKeybind = "Z",
    HoldToToggle = false,
    Callback = function()
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            IsSprinting = not IsSprinting
            Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
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

task.spawn(function()
    while task.wait(0.5) do
        if EspActive then UpdateESP() end
    end
end)

