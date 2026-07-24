-- Project Mayhem. By Messer_2004.
-- Hardcore Edition.

loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({
    Name = "Project Mayhem",
    LoadingTitle = "Project Mayhem",
    LoadingSubtitle = "By Messer_2004",
    ConfigurationSaving = { Enabled = true, FolderName = "ProjectMayhem" }
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- Variables
local ESPEnabled = false
local ESPBoxes = {}
local SilentRadius = 30
local WalkspeedVal = 16
local InfinityJump = false
local TacticalSprint = false
local NormalFov = Camera.FieldOfView
local SelectedPlayer = nil
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local AntiFlingEnabled = false
local FlingAuraEnabled = false
local FlyBodyVel = nil
local GodMode = false

-- Functions
local function CreateESP(player)
    if player == LP or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 5, 1)
    box.Adornee = hrp
    box.ZIndex = 0
    box.AlwaysOnTop = true
    
    -- Цвета: Красный - убийца, Синий - шериф, Зеленый - мирный
    if player.Team and player.Team.Name == "Murderer" then
        box.Color3 = Color3.new(1, 0, 0) -- Красный
    elseif player.Team and player.Team.Name == "Sheriff" then
        box.Color3 = Color3.new(0, 0.3, 1) -- Синий
    else
        box.Color3 = Color3.new(0, 1, 0) -- Зеленый
    end
    
    box.Transparency = 0.5
    box.Parent = hrp
    
    table.insert(ESPBoxes, box)
end

local function RemoveESP()
    for _, v in pairs(ESPBoxes) do v:Destroy() end
    ESPBoxes = {}
end

local function ToggleESP()
    ESPEnabled = not ESPEnabled
    if ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            CreateESP(v)
        end
    else
        RemoveESP()
    end
end

local function GetClosestPlayer()
    local closest, dist = nil, SilentRadius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then closest, dist = v, mag end
        end
    end
    return closest
end

local function TeleportTo(pos)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function FlingCharacter(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500,200,500)).LookVector * 9999
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 0.5)
    end
end

local function GetSheriffGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gun" and v:IsA("Tool") then
            LP.Character.Humanoid:EquipTool(v)
            return
        end
    end
end

local function KillAll()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Humanoid") then
            v.Character.Humanoid.Health = 0
        end
    end
end

local function SetArmAngle(angle, arm)
    local char = LP.Character
    if char then
        local targetArm = arm == "left" and char:FindFirstChild("Left Arm") or char:FindFirstChild("Right Arm")
        if targetArm then
            TweenService:Create(targetArm, TweenInfo.new(0.2), {CFrame = targetArm.CFrame * CFrame.Angles(0,0,math.rad(angle))}):Play()
        end
    end
end

local function ToggleFly()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        NoclipEnabled = true
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.Name = "FlyVel"
            FlyBodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
            FlyBodyVel.Velocity = Vector3.new(0,0,0)
            FlyBodyVel.Parent = char.HumanoidRootPart
        end
    else
        NoclipEnabled = false
        if FlyBodyVel then
            FlyBodyVel:Destroy()
            FlyBodyVel = nil
        end
    end
end

local function ToggleAntiFling()
    AntiFlingEnabled = not AntiFlingEnabled
    if AntiFlingEnabled then
        NoclipEnabled = true
    else
        NoclipEnabled = false
    end
end

-- Noclip Handler
RunService.Heartbeat:Connect(function()
    if NoclipEnabled and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Fly Handler
RunService.Heartbeat:Connect(function()
    if FlyEnabled and FlyBodyVel then
        local move = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + LP.Character.HumanoidRootPart.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - LP.Character.HumanoidRootPart.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - LP.Character.HumanoidRootPart.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + LP.Character.HumanoidRootPart.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        FlyBodyVel.Velocity = move * FlySpeed
    end
end)

-- Fling Aura
RunService.Heartbeat:Connect(function()
    if FlingAuraEnabled and LP.Character then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist < 10 then
                    FlingCharacter(v)
                end
            end
        end
    end
end)

-- Binds
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ToggleESP()
    end
    if input.KeyCode == Enum.KeyCode.Z then
        TacticalSprint = not TacticalSprint
        if LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = TacticalSprint and 25 or WalkspeedVal
            end
        end
        Camera.FieldOfView = TacticalSprint and 80 or NormalFov
    end
    if input.KeyCode == Enum.KeyCode.G then
        GetSheriffGun()
    end
    if input.KeyCode == Enum.KeyCode.X then
        ToggleFly()
    end
end)

-- Character Added
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = WalkspeedVal
    if InfinityJump then
        char.Humanoid.JumpPower = 150
    end
    wait(0.1)
    if FlyEnabled then
        ToggleFly()
    end
end)

-- Infinity Jump
RunService.Heartbeat:Connect(function()
    if InfinityJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            LP.Character.Humanoid.JumpPower = 150
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Main Tab
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
Main:CreateButton({ Name = "ESP (V)", Callback = ToggleESP })
Main:CreateSlider({ Name = "Silent Aim Radius", Min = 10, Max = 200, Default = 30, Callback = function(v) SilentRadius = v end })
Main:CreateSlider({ Name = "Walkspeed", Min = 16, Max = 200, Default = 16, Callback = function(v)
    WalkspeedVal = v
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = TacticalSprint and 25 or v
    end
end})
Main:CreateToggle({ Name = "Infinity Jump", Default = false, Callback = function(v)
    InfinityJump = v
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = v and 150 or 50
    end
end})
Main:CreateButton({ Name = "Kill All", Callback = KillAll })
Main:CreateButton({ Name = "Fly (X) + Noclip", Callback = ToggleFly })
Main:CreateSlider({ Name = "Fly Speed", Min = 10, Max = 200, Default = 50, Callback = function(v) FlySpeed = v end })
Main:CreateToggle({ Name = "Anti-Fling (Noclip)", Default = false, Callback = function(v)
    ToggleAntiFling()
end})
Main:CreateToggle({ Name = "Fling Aura", Default = false, Callback = function(v)
    FlingAuraEnabled = v
    if v then
        NoclipEnabled = true
    else
        NoclipEnabled = false
    end
end})

-- Teleports Tab
local Teleports = Window:CreateTab({ Name = "Teleports", Icon = "map-pin" })
Teleports:CreateButton({ Name = "Teleport to Map", Callback = function()
    TeleportTo(Vector3.new(0, 10, 0))
end})
Teleports:CreateButton({ Name = "Teleport to Lobby", Callback = function()
    TeleportTo(Vector3.new(0, 10, 0))
end})
local PlayerList = {}
for _, v in pairs(Players:GetPlayers()) do
    table.insert(PlayerList, v.Name)
end
Teleports:CreateDropdown({ Name = "Teleport to Player", Options = PlayerList, CurrentOption = "", Callback = function(opt)
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name == opt then
            SelectedPlayer = v
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                TeleportTo(v.Character.HumanoidRootPart.Position)
            end
        end
    end
end})
Teleports:CreateButton({ Name = "Pickup Sheriff Gun (G)", Callback = GetSheriffGun })

-- Fling Tab
local FlingTab = Window:CreateTab({ Name = "Fling", Icon = "target" })
local FlingList = {}
for _, v in pairs(Players:GetPlayers()) do
    table.insert(FlingList, v.Name)
end
FlingTab:CreateDropdown({ Name = "Fling Player", Options = FlingList, CurrentOption = "", Callback = function(opt)
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name == opt then
            FlingCharacter(v)
        end
    end
end})
FlingTab:CreateButton({ Name = "Fling Sheriff", Callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Team and v.Team.Name == "Sheriff" then
            FlingCharacter(v)
        end
    end
end})
FlingTab:CreateButton({ Name = "Fling Murderer", Callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Team and v.Team.Name == "Murderer" then
            FlingCharacter(v)
        end
    end
end})

-- Trolling Tab
local Trolling = Window:CreateTab({ Name = "Trolling", Icon = "smile" })
Trolling:CreateButton({ Name = "Sword Flick", Callback = function()
    for i = 1, 10 do
        SetArmAngle(90, "right")
        wait(0.1)
        SetArmAngle(-90, "right")
        wait(0.1)
    end
    SetArmAngle(0, "right")
end})
Trolling:CreateButton({ Name = "Salute", Callback = function()
    SetArmAngle(135, "right")
end})
Trolling:CreateButton({ Name = "Salute + Flick", Callback = function()
    SetArmAngle(135, "right")
    for i = 1, 10 do
        SetArmAngle(90, "left")
        wait(0.1)
        SetArmAngle(-90, "left")
        wait(0.1)
    end
    SetArmAngle(0, "left")
end})

print("Project Mayhem Loaded")