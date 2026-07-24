-- MM2 SCRIPT | RYZEN MODULE | RAYFIELD UI
-- Бинды: V (ESP), X (Fly)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({ Name = "Ryzen | MM2", LoadingTitle = "System Active", LoadingSubtitle = "Z.e.r.o.A.I", ConfigurationSaving = { Enabled = true, FolderName = "RyzenMM2" } })

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Глобальные состояния
local ESPEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local WalkspeedValue = 16
local GodMode = false
local SilentRadius = 30
local CurrentFlingTarget = nil
local ArmAngle = 0

-- // 1. ESP (Бинд V)
local function CreateESP(player)
    if player == LP then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "RyzenESP"
    highlight.Adornee = player.Character
    highlight.FillColor = player.Team == game:GetService("Teams")["Murderer"] and Color3.new(1,0,0) or Color3.new(0,1,0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.Parent = player.Character
end

UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        ESPEnabled = not ESPEnabled
        if ESPEnabled then
            for _, v in pairs(Players:GetPlayers()) do if v.Character then CreateESP(v) end end
        else
            for _, v in pairs(Players:GetPlayers()) do if v.Character then local h = v.Character:FindFirstChild("RyzenESP") if h then h:Destroy() end end end
        end
    end
end)

-- // 2. Silent Aim (радиус)
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

-- // 3. Fly (Бинд X)
UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        FlyEnabled = not FlyEnabled
        local char = LP.Character
        if FlyEnabled then
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVel.Velocity = Vector3.new(0,0,0)
            bodyVel.Parent = char.HumanoidRootPart
        else
            local bv = char:FindFirstChild("FlyVel")
            if bv then bv:Destroy() end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if FlyEnabled and LP.Character then
        local bv = LP.Character:FindFirstChild("FlyVel")
        if bv then
            local move = Vector3.new(0,0,0)
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + LP.Character.HumanoidRootPart.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - LP.Character.HumanoidRootPart.CFrame.LookVector end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - LP.Character.HumanoidRootPart.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + LP.Character.HumanoidRootPart.CFrame.RightVector end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
            bv.Velocity = move * FlySpeed
        end
    end
end)

-- // 4. Walkspeed & Infinity Jump
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = WalkspeedValue
    char:WaitForChild("Humanoid").JumpPower = 70 -- Infinity Jump через приседание
end)

-- // 5. God Mode (устойчивость)
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if GodMode and hum.Health < 30 then hum.Health = 30 end
    end)
end)

-- // 6. Fling (выбранного, шерифа/убийцы)
local function FlingCharacter(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVel.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500,200,500)).LookVector * 9999
        bodyVel.Parent = hrp
        game:GetService("Debris"):AddItem(bodyVel, 0.5)
    end
end

-- // 7. Поднятие руки на 135°
local function SetArmAngle(angle)
    local char = LP.Character
    if char and char:FindFirstChild("Right Arm") then
        local arm = char["Right Arm"]
        TweenService:Create(arm, TweenInfo.new(0.2), {CFrame = arm.CFrame * CFrame.Angles(0,0,math.rad(angle))}):Play()
    end
end

-- // 8. Телепорты и автоподбор пистолета
local function TeleportTo(pos) if LP.Character then LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos) end end
local function GetSheriffGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gun" and v:IsA("Tool") then
            LP.Character.Humanoid:EquipTool(v)
            return
        end
    end
end

-- // 9. Kill All (убийца)
local function KillAll()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Humanoid") then
            v.Character.Humanoid.Health = 0
        end
    end
end

-- // === RAYFIELD UI ===
local MainTab = Window:CreateTab({ Name = "Main", Icon = "home" })
MainTab:CreateButton({ Name = "Kill All (Убийца)", Callback = KillAll })
MainTab:CreateButton({ Name = "Автоподбор пистолета", Callback = GetSheriffGun })
MainTab:CreateButton({ Name = "Fling Sheriff & Murderer", Callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Team and (v.Team.Name == "Murderer" or v.Team.Name == "Sheriff") then FlingCharacter(v) end
    end
end})

MainTab:CreateSlider({ Name = "Walkspeed", Min = 16, Max = 200, Default = 16, Callback = function(v) WalkspeedValue = v if LP.Character then LP.Character.Humanoid.WalkSpeed = v end end })
MainTab:CreateSlider({ Name = "Fly Speed", Min = 10, Max = 200, Default = 50, Callback = function(v) FlySpeed = v end })
MainTab:CreateSlider({ Name = "Silent Aim Radius", Min = 10, Max = 200, Default = 30, Callback = function(v) SilentRadius = v end })

local Teleports = Window:CreateTab({ Name = "Teleports", Icon = "map-pin" })
Teleports:CreateButton({ Name = "В Лобби", Callback = function() TeleportTo(Vector3.new(0, 10, 0)) end })
Teleports:CreateButton({ Name = "На Карту", Callback = function() TeleportTo(Vector3.new(100, 10, 100)) end })
Teleports:CreateButton({ Name = "К Игроку (ближ.)", Callback = function() local p = GetClosestPlayer() if p then TeleportTo(p.Character.HumanoidRootPart.Position + Vector3.new(0,5,0)) end end })

local Misc = Window:CreateTab({ Name = "Misc", Icon = "sliders" })
Misc:CreateToggle({ Name = "God Mode", Default = false, Callback = function(v) GodMode = v end })
Misc:CreateToggle({ Name = "Infinity Jump (Space)", Default = false, Callback = function(v) if LP.Character then LP.Character.Humanoid.JumpPower = v and 150 or 50 end end })
Misc:CreateButton({ Name = "Поднять руку 135°", Callback = function() SetArmAngle(135) end })
Misc:CreateButton({ Name = "Сбросить руку", Callback = function() SetArmAngle(0) end })

local FlingTab = Window:CreateTab({ Name = "Fling", Icon = "target" })
FlingTab:CreateButton({ Name = "Fling выбранного (клик)", Callback = function()
    local target = GetClosestPlayer()
    if target then FlingCharacter(target) end
end})

print("Ryzen Module Active | Все бинды загружены.")