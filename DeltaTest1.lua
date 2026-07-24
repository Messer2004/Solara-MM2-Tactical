-- MM2 RYZEN | DELTA MOBILE OPTIMIZED
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({ Name = "Ryzen | MM2", LoadingTitle = "Mobile Active", LoadingSubtitle = "Z.e.r.o.A.I", ConfigurationSaving = { Enabled = true, FolderName = "RyzenMM2_M" } })

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Состояния (все управление через GUI)
local ESP = false
local Fly = false
local FlySpeed = 40
local WalkspeedVal = 16
local God = false
local SilentRad = 30
local JumpInf = false

-- Функции (без изменений в логике)
local function CreateESP(p)
    if p == LP then return end
    local h = Instance.new("Highlight")
    h.Name = "RyzenESP"
    h.Adornee = p.Character
    h.FillColor = p.Team and p.Team.Name == "Murderer" and Color3.new(1,0,0) or Color3.new(0,1,0)
    h.FillTransparency = 0.5
    h.OutlineColor = Color3.new(1,1,1)
    h.Parent = p.Character
end

local function ToggleESP()
    ESP = not ESP
    if ESP then for _, v in pairs(Players:GetPlayers()) do if v.Character then CreateESP(v) end end
    else for _, v in pairs(Players:GetPlayers()) do if v.Character then local h = v.Character:FindFirstChild("RyzenESP") if h then h:Destroy() end end end end
end

local function GetClosest()
    local closest, dist = nil, SilentRad
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then closest, dist = v, mag end
        end
    end
    return closest
end

local function ToggleFly()
    Fly = not Fly
    local char = LP.Character
    if Fly then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = char.HumanoidRootPart
    else
        local bv = char:FindFirstChild("FlyVel")
        if bv then bv:Destroy() end
    end
end

-- Управление полетом через сенсорные кнопки (всплывают при активации Fly)
local flyDir = Vector3.new(0,0,0)
UIS.TouchEnabled = true
UIS.TouchStarted:Connect(function(touch)
    if not Fly then return end
    local pos = touch.Position
    local screen = game:GetService("GuiService"):GetScreenResolution()
    local center = Vector2.new(screen.X/2, screen.Y/2)
    local dir = (pos - center).Unit
    flyDir = Vector3.new(dir.X, 0, dir.Y)
end)

RunService.Heartbeat:Connect(function()
    if Fly and LP.Character then
        local bv = LP.Character:FindFirstChild("FlyVel")
        if bv then
            local move = flyDir * FlySpeed
            if flyDir.Y ~= 0 then move = move + Vector3.new(0, flyDir.Y * FlySpeed, 0) end
            bv.Velocity = move
        end
    end
end)

local function Fling(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500,200,500)).LookVector * 9999
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 0.5)
    end
end

local function KillAll()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Humanoid") then
            v.Character.Humanoid.Health = 0
        end
    end
end

LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = WalkspeedVal
    char:WaitForChild("Humanoid").JumpPower = JumpInf and 150 or 50
    char:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function()
        if God and char.Humanoid.Health < 30 then char.Humanoid.Health = 30 end
    end)
end)

-- // GUI (увеличенные кнопки для пальцев)
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
Main:CreateButton({ Name = "ESP (вкл/выкл)", Callback = ToggleESP })
Main:CreateButton({ Name = "Fly (вкл/выкл)", Callback = ToggleFly })
Main:CreateButton({ Name = "Kill All", Callback = KillAll })
Main:CreateButton({ Name = "Fling ближнего", Callback = function() local t = GetClosest() if t then Fling(t) end end })
Main:CreateButton({ Name = "Подобрать пистолет", Callback = function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gun" and v:IsA("Tool") then LP.Character.Humanoid:EquipTool(v) return end
    end
end})

Main:CreateSlider({ Name = "Walkspeed", Min = 16, Max = 200, Default = 16, Callback = function(v) WalkspeedVal = v if LP.Character then LP.Character.Humanoid.WalkSpeed = v end end })
Main:CreateSlider({ Name = "Fly Speed", Min = 10, Max = 150, Default = 40, Callback = function(v) FlySpeed = v end })
Main:CreateSlider({ Name = "Silent Aim Radius", Min = 5, Max = 200, Default = 30, Callback = function(v) SilentRad = v end })

local Misc = Window:CreateTab({ Name = "Misc", Icon = "sliders" })
Misc:CreateToggle({ Name = "God Mode", Default = false, Callback = function(v) God = v end })
Misc:CreateToggle({ Name = "Infinity Jump", Default = false, Callback = function(v) JumpInf = v if LP.Character then LP.Character.Humanoid.JumpPower = v and 150 or 50 end end })
Misc:CreateButton({ Name = "Телепорт в лобби", Callback = function() if LP.Character then LP.Character.HumanoidRootPart.CFrame = CFrame.new(0,10,0) end end })
Misc:CreateButton({ Name = "Телепорт на карту", Callback = function() if LP.Character then LP.Character.HumanoidRootPart.CFrame = CFrame.new(100,10,100) end end })
Misc:CreateButton({ Name = "Телепорт к игроку", Callback = function() local p = GetClosest() if p then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0) end end })

print("Ryzen Mobile Active | Delta Optimized")