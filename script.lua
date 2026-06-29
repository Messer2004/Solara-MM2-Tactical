-- Project Mayhem | PC Hardcore [Final Rewrite]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Hardcore Build", LoadingSubtitle = "PC Edition", ConfigurationSaving = {Enabled = false}})

local Main, Tele, Fling = Win:CreateTab("Main", nil), Win:CreateTab("Teleports", nil), Win:CreateTab("Fling", nil)
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {ESP = false, Fly = false, Aura = false, AutoGrab = false, Target = nil}

-- Utils
local function getRoleColor(p) local c = p.Character if c and (c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then return Color3.new(1,0,0) elseif c and (c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then return Color3.new(0,0,1) else return Color3.new(0,1,0) end end
local function getPlrs() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr then table.insert(t, p.Name) end end return t end

-- Fling Logic (The "Craziness")
local function performFling(target)
    if not target or not target.Character then return end
    local h = Plr.Character.HumanoidRootPart local s = h.CFrame
    for i=1, 30 do
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
        h.RotVelocity = Vector3.new(0, 99999, 0)
        task.wait(0.02)
    end
    h.CFrame = s
end

-- Main Features
Main:CreateToggle({Name = "Silent Aim [Toggle]", Callback = function(v) State.Aim = v end})
Main:CreateSlider({Name = "Aim FOV", Range = {10, 100}, CurrentValue = 50, Callback = function(v) end})

-- Teleports
local DD = Tele:CreateDropdown({Name = "Target Player", Options = getPlrs(), Callback = function(o) State.Target = game.Players[o[1]] end})
Tele:CreateButton({Name = "Refresh List", Callback = function() DD:Refresh(getPlrs(), true) end})
Tele:CreateButton({Name = "TP to Target", Callback = function() if State.Target then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})
Tele:CreateButton({Name = "TP to Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})
Tele:CreateButton({Name = "TP to Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then Plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})
Tele:CreateToggle({Name = "Auto Grab Gun", Callback = function(v) State.AutoGrab = v end})

-- Fling
Fling:CreateToggle({Name = "Fling Aura [Toggle]", Callback = function(v) State.Aura = v end})
Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then performFling(p) end end end})
Fling:CreateButton({Name = "Fling Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then performFling(p) end end end})
Fling:CreateButton({Name = "Fling Selected", Callback = function() performFling(State.Target) end})

-- Render Loop & Inputs
RS.RenderStepped:Connect(function()
    -- ESP & NoClip
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Enabled = State.ESP h.FillColor = getRoleColor(p)
        end
    end
    if State.Fly and Plr.Character then for _,v in pairs(Plr.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    
    -- Fling Aura Logic
    if State.Aura then Plr.Character.HumanoidRootPart.CFrame = Plr.Character.HumanoidRootPart.CFrame + (Cam.CFrame.LookVector * 0.5) Plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 9999, 0) end
    
    -- AutoGrab
    if State.AutoGrab then for _,v in pairs(workspace:GetChildren()) do if v.Name == "GunDrop" then local s = Plr.Character.HumanoidRootPart.CFrame Plr.Character.HumanoidRootPart.CFrame = v.CFrame task.wait(0.1) Plr.Character.HumanoidRootPart.CFrame = s end end end
end)

UIS.InputBegan:Connect(function(i, g) if g then return end
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly local h = Plr.Character.HumanoidRootPart if State.Fly then local bv = Instance.new("BodyVelocity", h) bv.Name = "FBV" bv.MaxForce = Vector3.new(9e9,9e9,9e9) RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 end end) else if h:FindFirstChild("FBV") then h.FBV:Destroy() end end
    elseif i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 25
    end
end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 16 end end)

for i=1, 600 do local _ = i end
