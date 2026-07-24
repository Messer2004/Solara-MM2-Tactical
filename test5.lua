-- Project Mayhem. By Messer_2004.
-- Hardcore Edition. (Xeno Optimized)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 600)
Frame.Position = UDim2.new(0.5, -200, 0.5, -300)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BackgroundTransparency = 0.1
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.Text = "Project Mayhem"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = Frame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ScrollingFrame.Parent = Frame

local function CreateButton(text, callback, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Parent = ScrollingFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateToggle(text, callback, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Parent = ScrollingFrame
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
    return btn
end

local y = 10

-- Variables
local ESPEnabled = false
local ESPBoxes = {}
local SilentRadius = 30
local WalkspeedVal = 16
local InfinityJump = false
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local FlingAuraEnabled = false
local FlyBodyVel = nil
local LastPosition = nil
local ReturnToPosition = false

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
    if player.Team and player.Team.Name == "Murderer" then
        box.Color3 = Color3.new(1, 0, 0)
    elseif player.Team and player.Team.Name == "Sheriff" then
        box.Color3 = Color3.new(0, 0.3, 1)
    else
        box.Color3 = Color3.new(0, 1, 0)
    end
    box.Transparency = 0.5
    box.Parent = hrp
    table.insert(ESPBoxes, box)
end

local function RemoveESP()
    for _, v in pairs(ESPBoxes) do v:Destroy() end
    ESPBoxes = {}
end

local function TeleportTo(pos)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function SavePosition()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LastPosition = LP.Character.HumanoidRootPart.Position
        ReturnToPosition = true
    end
end

local function ReturnToLastPosition()
    if ReturnToPosition and LastPosition then
        TeleportTo(LastPosition)
        ReturnToPosition = false
    end
end

local function FlingCharacter(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        SavePosition()
        local hrp = target.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500,200,500)).LookVector * 9999
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 0.5)
        task.wait(0.3)
        ReturnToLastPosition()
    end
end

local function GetSheriffGun()
    SavePosition()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gun" and v:IsA("Tool") then
            LP.Character.Humanoid:EquipTool(v)
            task.wait(0.3)
            ReturnToLastPosition()
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

-- Noclip
RunService.Heartbeat:Connect(function()
    if NoclipEnabled and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Fly
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

-- Infinity Jump
RunService.Heartbeat:Connect(function()
    if InfinityJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            LP.Character.Humanoid.JumpPower = 150
            LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Binds
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        if not ESPEnabled then
            ESPEnabled = true
            for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
        else
            ESPEnabled = false
            RemoveESP()
        end
    end
    if input.KeyCode == Enum.KeyCode.G then
        GetSheriffGun()
    end
    if input.KeyCode == Enum.KeyCode.X then
        ToggleFly()
    end
end)

-- GUI Buttons
CreateButton("ESP (V)", function()
    if not ESPEnabled then
        ESPEnabled = true
        for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
    else
        ESPEnabled = false
        RemoveESP()
    end
end, y) y = y + 40

CreateButton("Fly (X)", ToggleFly, y) y = y + 40

CreateButton("Kill All", KillAll, y) y = y + 40

CreateButton("Pickup Gun (G)", GetSheriffGun, y) y = y + 40

CreateToggle("Infinity Jump", function(v) InfinityJump = v end, y) y = y + 40

CreateToggle("Fling Aura", function(v) FlingAuraEnabled = v end, y) y = y + 40

CreateButton("Fling Sheriff", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Team and v.Team.Name == "Sheriff" then
            FlingCharacter(v)
        end
    end
end, y) y = y + 40

CreateButton("Fling Murderer", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Team and v.Team.Name == "Murderer" then
            FlingCharacter(v)
        end
    end
end, y) y = y + 40

CreateButton("Teleport to Map", function()
    TeleportTo(Vector3.new(0, 10, 0))
end, y) y = y + 40

CreateButton("Teleport to Lobby", function()
    TeleportTo(Vector3.new(0, 10, 0))
end, y) y = y + 40

CreateButton("Sword Flick", function()
    for i = 1, 10 do
        SetArmAngle(90, "right")
        wait(0.1)
        SetArmAngle(-90, "right")
        wait(0.1)
    end
    SetArmAngle(0, "right")
end, y) y = y + 40

CreateButton("Salute", function()
    SetArmAngle(135, "right")
end, y) y = y + 40

CreateButton("Salute + Flick", function()
    SetArmAngle(135, "right")
    for i = 1, 10 do
        SetArmAngle(90, "left")
        wait(0.1)
        SetArmAngle(-90, "left")
        wait(0.1)
    end
    SetArmAngle(0, "left")
end, y) y = y + 40

ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, y + 40)

print("Project Mayhem Loaded | Xeno Optimized")