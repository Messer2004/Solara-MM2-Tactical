-- Project Mayhem | Full Rewrite [Stable]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Loading...", LoadingSubtitle = "Stable PC Build", ConfigurationSaving = {Enabled = false}})

local Main, Tele, Fling = Win:CreateTab("Main", nil), Win:CreateTab("Teleports", nil), Win:CreateTab("Fling", nil)
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {ESP = false, Fly = false, Aim = false, Sprint = false, InfJump = false, FlingAura = false}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible, FOVCircle.Radius, FOVCircle.Thickness, FOVCircle.NumSides, FOVCircle.Filled = false, 10, 1.5, 64, false
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

local function GetRoleColor(p)
    local char = p.Character
    if (char and char:FindFirstChild("Knife")) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then return Color3.fromRGB(255,0,0) end
    if (char and char:FindFirstChild("Gun")) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then return Color3.fromRGB(0,0,255) end
    return Color3.fromRGB(0,255,0)
end

Main:CreateToggle({Name = "Player ESP [V]", Callback = function(v) State.ESP = v end})
Main:CreateToggle({Name = "Flight + NoClip [X]", Callback = function(v) 
    State.Fly = v 
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if v and hrp then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyV" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 for _,p in pairs(Plr.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
    elseif hrp and hrp:FindFirstChild("FlyV") then hrp.FlyV:Destroy() end
end})

Main:CreateToggle({Name = "Silent Aim", Callback = function(v) State.Aim = v FOVCircle.Visible = v end})
Main:CreateSlider({Name = "Aim FOV Size", Range = {10, 100}, CurrentValue = 10, Callback = function(v) FOVCircle.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.InfJump = v end})
Main:CreateSlider({Name = "WalkSpeed Customizer", Range = {16, 120}, CurrentValue = 16, Callback = function(v) Plr.Character.Humanoid.WalkSpeed = v end})
Main:CreateToggle({Name = "Tactical Sprint [Z]", Callback = function(v) State.Sprint = v end})

Tele:CreateButton({Name = "TP to Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})
Tele:CreateButton({Name = "TP to Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})

Fling:CreateToggle({Name = "Fling Aura [Toggle]", Callback = function(v) State.FlingAura = v end})
Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then local h = Plr.Character.HumanoidRootPart local s = h.CFrame local bp = Instance.new("BodyPosition", h) bp.MaxForce = Vector3.new(9e9,9e9,9e9) bp.Position = p.Character.HumanoidRootPart.Position task.wait(0.3) bp:Destroy() h.CFrame = s end end end})

UIS.InputBegan:Connect(function(i, gp)
    if not gp then
        if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
        elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly
        elseif i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 25 end
    end
end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 16 end end)

RS.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    if State.ESP then for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr and p.Character then local h = p.Character:FindFirstChild("M_ESP") or Instance.new("Highlight", p.Character) h.Name, h.FillColor = "M_ESP", GetRoleColor(p) end end else for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("M_ESP") then p.Character.M_ESP:Destroy() end end end
end)

for i=1, 350 do local _ = i*1 end
Rayfield:Notify({Title = "Project Mayhem", Content = "Loaded", Duration = 3})
