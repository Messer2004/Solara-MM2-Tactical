local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Steal an Egg | Fly & God",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Fly 1000 + Anti-Ragdoll",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local flying = false
local flySpeed = 1000
local flyVelocity
local flyGyro
local flyConnection

local Tab = Window:CreateTab("Movement", 4483362458)
Tab:CreateSection("Fly Settings")

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "studs/s",
    CurrentValue = 1000,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        flySpeed = Value
    end
})

local function enableFly()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    humanoid.PlatformStand = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyGyro.CFrame = root.CFrame
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not flyVelocity or not flyGyro then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            flyVelocity.Velocity = dir.Unit * flySpeed
        else
            flyVelocity.Velocity = Vector3.zero
        end
        flyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
    end)
end

local function disableFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
    local char = lp.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

Tab:CreateToggle({
    Name = "Fly (WASD + Space/Ctrl)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flying = Value
        if Value then
            enableFly()
        else
            disableFly()
        end
    end
})

local Tab2 = Window:CreateTab("Protection", 4483362458)
Tab2:CreateSection("Anti-Ragdoll / No Knockback")

local antiRagdollEnabled = true
Tab2:CreateToggle({
    Name = "Anti-Ragdoll (No Knockback)",
    CurrentValue = true,
    Flag = "AntiRagdollToggle",
    Callback = function(Value)
        antiRagdollEnabled = Value
    end
})

RunService.Heartbeat:Connect(function()
    if not antiRagdollEnabled then return end
    local char = lp.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

Rayfield:Notify({
    Title = "Loaded",
    Content = "Fly 1000 + Anti-Ragdoll active.",
    Duration = 5,
    Image = 4483362458
})