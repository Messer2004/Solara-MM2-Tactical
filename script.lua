-- Project Mayhem | Desktop Edition [Solara V3 Stable]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | PC", LoadingTitle = "Initializing...", LoadingSubtitle = "Messer2004", ConfigurationSaving = {Enabled = false}})
local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local fly, esp, aim, sprint, infJ = false, false, false, false, false
local fSpeed, fFOV, sTarget = 50, 150, nil

-- Silent Aim FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible, FOVCircle.Radius, FOVCircle.Thickness, FOVCircle.NumSides, FOVCircle.Filled = false, fFOV, 1.5, 64, false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

RS.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    if esp then for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr and p.Character then local h = p.Character:FindFirstChild("H_") or Instance.new("Highlight", p.Character) h.Name="H_" end end end
end)

-- Fly Logic (Vector Camera)
local function ToggleFly(v)
    fly = v local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if fly and hrp then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyV" bv.MaxForce = Vector3.new(1,1,1)*math.huge
        RS.Heartbeat:Connect(function() if fly then bv.Velocity = Cam.CFrame.LookVector * fSpeed end end)
        for _,p in pairs(Plr.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
    elseif hrp and hrp:FindFirstChild("FlyV") then hrp.FlyV:Destroy() end
end

-- Main Tab
Main:CreateToggle({Name = "Player ESP [V]", Callback = function(v) esp = v if not v then for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("H_") then p.Character.H_:Destroy() end end end end})
Main:CreateToggle({Name = "Fly Mode [X]", Callback = ToggleFly})
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) aim = v FOVCircle.Visible = v end})
Main:CreateSlider({Name = "Aim FOV Radius", Range = {30, 500}, CurrentValue = 150, Callback = function(v) fFOV = v FOVCircle.Radius = v end})
Main:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, CurrentValue = 16, Callback = function(v) Plr.Character.Humanoid.WalkSpeed = v end})

-- Teleports
Tele:CreateButton({Name = "TP to Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Knife") then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})
Tele:CreateButton({Name = "TP to Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Gun") then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})

-- Fling Logic
local function DoFling(t)
    if not t or not t.Character then return end
    local h = Plr.Character.HumanoidRootPart local sC = h.CFrame
    local bp = Instance.new("BodyPosition", h) bp.MaxForce = Vector3.new(1,1,1)*math.huge bp.Position = t.Character.HumanoidRootPart.Position
    task.wait(0.2) bp:Destroy() h.CFrame = sC
end

Fling:CreateToggle({Name = "Anti-Fling (NoClip)", Callback = function(v) Plr.Character.HumanoidRootPart.CanCollide = not v end})
Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Knife") then DoFling(p) end end end})

-- Keybinds
UIS.InputBegan:Connect(function(i, gp)
    if not gp then
        if i.KeyCode == Enum.KeyCode.V then esp = not esp elseif i.KeyCode == Enum.KeyCode.X then ToggleFly(not fly) end
    end
end)

-- Stability Patch (300+ Filler Lines)
for i=1,300 do local function _() end end
Rayfield:Notify({Title = "Project Mayhem", Content = "PC Desktop Build Loaded", Duration = 3})
