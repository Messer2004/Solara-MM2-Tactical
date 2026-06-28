local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Solara Tactical Menu",
    LoadingTitle = "Solara PC Edition",
    LoadingSubtitle = "by Messer",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("PC Features", 4483362458)

local Plr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

local EspActive, Flying = false, false
local FlySpeed = 50
local IsSprinting = false
local TargetFOV = 70
local ActiveTracks = {}
local InfJump = false
local FakeDeadActive = false
local AutoPickupActive = false
local AntiFlingActive = false

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

task.spawn(function()
    while task.wait(0.1) do
        if Flying or AntiFlingActive then
            local Char = Plr.Character
            if Char then
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

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
                    BV.Velocity = LookDir * FlySpeed
                end
            end
            if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
        end)
    else
        if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
    end
end

local function CheckAndPickupGun()
    if not AutoPickupActive then return end
    local Char = Plr.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local GunDrop = workspace:FindFirstChild("GunDrop")
    if GunDrop and GunDrop:IsA("BasePart") then
        local SavedCFrame = HRP.CFrame
        HRP.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
    end
end

task.spawn(function()
    while task.wait(0.3) do
        if AutoPickupActive then
            CheckAndPickupGun()
        end
    end
end)

local function ToggleAnimation(AnimId, SlotName)
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Hum or Hum.Health <= 0 then return end
    local Animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
    
    if ActiveTracks[SlotName] then
        ActiveTracks[SlotName]:Stop()
        ActiveTracks[SlotName] = nil
        return
    end
    
    for slot, track in pairs(ActiveTracks) do
        track:Stop()
        ActiveTracks[slot] = nil
    end
    
    local Anim = Instance.new("Animation")
    Anim.AnimationId = "rbxassetid://" .. tostring(AnimId)
    
    local Success, Track = pcall(function()
        return Animator:LoadAnimation(Anim)
    end)
    
    if Success and Track then
        Track.Looped = true
        Track.Priority = Enum.AnimationPriority.Action
        Track:Play()
        ActiveTracks[SlotName] = Track
    end
end

local function ToggleFakeDeath()
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end

    FakeDeadActive = not FakeDeadActive
    
    if FakeDeadActive then
        for slot, track in pairs(ActiveTracks) do
            track:Stop()
            ActiveTracks[slot] = nil
        end
        Hum.PlatformStand = true
        HRP.CFrame = HRP.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
    else
        Hum.PlatformStand = false
        HRP.CFrame = HRP.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    end
end

local function ShootAtCenter()
    local ViewportSize = Camera.ViewportSize
    local CenterX = ViewportSize.X / 2
    local CenterY = ViewportSize.Y / 2
    VirtualInputManager:SendMouseButtonEvent(CenterX, CenterY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(CenterX, CenterY, 0, false, game, 0)
end

local function SwitchSprint()
    if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        IsSprinting = not IsSprinting
        Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
        TargetFOV = IsSprinting and 110 or 70
    end
end

Tab:CreateToggle({
    Name = "Player ESP (Role Chams) [V]",
    CurrentValue = false,
    Callback = function(Value)
        EspActive = Value
        UpdateESP()
    end,
})

Tab:CreateToggle({
    Name = "Tactical Sprint [Z]",
    CurrentValue = false,
    Callback = function(Value)
        IsSprinting = Value
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
            TargetFOV = IsSprinting and 110 or 70
        end
    end,
})

Tab:CreateToggle({
    Name = "Flight Mode & NoClip [X]",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFly(Value)
    end,
})

Tab:CreateToggle({
    Name = "Anti-Fling Protection",
    CurrentValue = false,
    Callback = function(Value)
        AntiFlingActive = Value
    end,
})

Tab:CreateToggle({
    Name = "Auto-Pickup Gun",
    CurrentValue = false,
    Callback = function(Value)
        AutoPickupActive = Value
    end,
})

Tab:CreateSlider({
    Name = "WalkSpeed Customizer",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        InfJump = Value
    end,
})

Tab:CreateToggle({
    Name = "Emote: King Nasir Dance [Numpad1]",
    CurrentValue = false,
    Callback = function(Value)
        ToggleAnimation(16912306733, "Nasir")
    end,
})

Tab:CreateToggle({
    Name = "Emote: Nervy Dance [Numpad2]",
    CurrentValue = false,
    Callback = function(Value)
        ToggleAnimation(14349258288, "Nervy")
    end,
})

Tab:CreateToggle({
    Name = "Fake Death Mode [Numpad3]",
    CurrentValue = false,
    Callback = function(Value)
        ToggleFakeDeath()
    end,
})

Tab:CreateButton({
    Name = "Instant Center Shot",
    Callback = function()
        ShootAtCenter()
    end,
})

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        EspActive = not EspActive
        UpdateESP()
    elseif input.KeyCode == Enum.KeyCode.X then
        ToggleFly(not Flying)
    elseif input.KeyCode == Enum.KeyCode.Z then
        SwitchSprint()
    elseif input.KeyCode == Enum.KeyCode.KeypadOne then
        ToggleAnimation(16912306733, "Nasir")
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
        ToggleAnimation(14349258288, "Nervy")
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then
        ToggleFakeDeath()
    elseif input.KeyCode == Enum.KeyCode.K then
        local core = game:GetService("CoreGui")
        local rf = core:FindFirstChild("Rayfield") or core:FindFirstChild("RayfieldGui")
        if rf then
            rf.Enabled = not rf.Enabled
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJump and Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        Plr.Character.Humanoid:ChangeState("Jumping")
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if EspActive then UpdateESP() end
    end
end)

Rayfield:Notify({
    Title = "Executed",
    Content = "Messer PC Build Updated",
    Duration = 3,
    Image = 4483362458,
})
