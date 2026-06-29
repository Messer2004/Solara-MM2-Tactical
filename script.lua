-- Project Mayhem | Hardcore Edition [Final Fixed]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Hardcore", LoadingTitle = "Finalizing...", LoadingSubtitle = "Stable Logic", ConfigurationSaving = {Enabled = false}})

local Main = Win:CreateTab("Main")
local Tele = Win:CreateTab("Teleports")
local Fling = Win:CreateTab("Fling")

local Plr = game:GetService("Players").LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local State = {ESP = false, Fly = false, Aim = false, Aura = false, Target = nil, Inf = false}
local FOV = Drawing.new("Circle")
FOV.Visible = false; FOV.Radius = 50; FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2); FOV.Color = Color3.new(1,0,0)

-- ESP & Logic Loop
RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    -- ESP
    if State.ESP then
        for _,p in pairs(game.Players:GetPlayers()) do
            if p ~= Plr and p.Character then
                local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
                h.Name = "H"; h.FillColor = Color3.new(1,0,0) -- Можно усложнить до GetRoleColor
            end
        end
    else
        for _,p in pairs(game.Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("H") then p.Character.H:Destroy() end end
    end
    -- Aura
    if State.Aura and State.Target and State.Target.Character then
        local h = Plr.Character.HumanoidRootPart
        h.CFrame = State.Target.Character.HumanoidRootPart.CFrame
        h.RotVelocity = Vector3.new(0, 5000, 0)
    end
end)

-- UI
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) State.Aim = v; FOV.Visible = v end})
Main:CreateSlider({Name = "FOV Size", Range = {10, 200}, CurrentValue = 50, Callback = function(v) FOV.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.Inf = v end})

local DD = Tele:CreateDropdown({Name = "Select Target", Options = {}, Callback = function(o) State.Target = game.Players[o[1]] end})
Tele:CreateButton({Name = "Refresh List", Callback = function() 
    local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr then table.insert(t, p.Name) end end
    DD:Refresh(t, true) 
end})

Fling:CreateToggle({Name = "Fling Aura [ON]", Callback = function(v) State.Aura = v end})
Fling:CreateButton({Name = "Fling Target (Long Hold)", Callback = function() 
    if State.Target and State.Target.Character then
        local oldPos = Plr.Character.HumanoidRootPart.CFrame
        for i = 1, 100 do -- Длительный цикл
            Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame
            task.wait(0.01)
        end
        Plr.Character.HumanoidRootPart.CFrame = oldPos
    end
end})

-- Global Binds (Железо)
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then 
        State.ESP = not State.ESP 
    elseif i.KeyCode == Enum.KeyCode.X then 
        State.Fly = not State.Fly
        Plr.Character.HumanoidRootPart.CanCollide = not State.Fly
        if State.Fly then
            local bv = Instance.new("BodyVelocity", Plr.Character.HumanoidRootPart); bv.Name = "FlyV"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero
            RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 end end)
        else
            if Plr.Character.HumanoidRootPart:FindFirstChild("FlyV") then Plr.Character.HumanoidRootPart.FlyV:Destroy() end
        end
    elseif i.KeyCode == Enum.KeyCode.Z then 
        Plr.Character.Humanoid.WalkSpeed = 25
    elseif i.KeyCode == Enum.KeyCode.Space and State.Inf then
        Plr.Character.Humanoid:ChangeState(3)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 16 end
end)

for i=1, 500 do local _ = i end -- Заполнитель
Rayfield:Notify({Title = "Project Mayhem", Content = "Final Hardcore Build Loaded", Duration = 5})
