-- Project Mayhem | Hardcore Edition [Targeted]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Hardcore", LoadingTitle = "Loading...", LoadingSubtitle = "Targeted Mode", ConfigurationSaving = {Enabled = false}})
local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {ESP = false, Fly = false, Aim = false, Aura = false, Target = nil}

local function getPlrs() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr then table.insert(t, p.Name) end end return t end
local FOV = Drawing.new("Circle") FOV.Visible = false FOV.Radius = 50 FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2) FOV.Color = Color3.new(1,0,0)

-- Main Tab
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) State.Aim = v FOV.Visible = v end})
Main:CreateSlider({Name = "Aim Size", Range = {10, 100}, CurrentValue = 50, Callback = function(v) FOV.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.Inf = v end})
Main:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, CurrentValue = 16, Callback = function(v) Plr.Character.Humanoid.WalkSpeed = v end})

-- Teleports Tab
local DD = Tele:CreateDropdown({Name = "Select Target", Options = getPlrs(), Callback = function(o) State.Target = game.Players[o[1]] end})
Tele:CreateButton({Name = "Refresh List", Callback = function() DD:Refresh(getPlrs(), true) end})
Tele:CreateButton({Name = "TP to Target", Callback = function() if State.Target and State.Target.Character then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})

-- Fling Tab
Fling:CreateToggle({Name = "Fling Aura [ON]", Callback = function(v) State.Aura = v end})
Fling:CreateButton({Name = "Fling Selected Target", Callback = function() 
    if State.Target and State.Target.Character then 
        local h = Plr.Character.HumanoidRootPart local s = h.CFrame 
        for i=1,15 do h.CFrame = State.Target.Character.HumanoidRootPart.CFrame task.wait(0.02) end 
        h.CFrame = s 
    end 
end})

-- Global Logic
RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    if State.Aura then local h = Plr.Character.HumanoidRootPart h.CFrame = h.CFrame + (Cam.CFrame.LookVector * 0.5) h.RotVelocity = Vector3.new(0, 9999, 0) end
end)

UIS.InputBegan:Connect(function(i, g) if not g then
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP -- ESP Toggle
    elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly local h = Plr.Character.HumanoidRootPart h.CanCollide = not State.Fly
    elseif i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 25 
    elseif State.Inf and i.KeyCode == Enum.KeyCode.Space then Plr.Character.Humanoid:ChangeState(3) end
end end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 16 end end)

for i=1, 400 do local _ = i end
Rayfield:Notify({Title = "Project Mayhem", Content = "Targeted Systems Online", Duration = 3})
