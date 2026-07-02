local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Hardcore Build", LoadingSubtitle = "Final", ConfigurationSaving = {Enabled = false}})

local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")

local State = {Aim = false, ESP = false, Fly = false, Aura = false, Inf = false, AntiFling = false, Target = nil, BaseWS = 16}
local FOV = Drawing.new("Circle") 
FOV.Visible = false; FOV.Radius = 50; FOV.Color = Color3.fromRGB(255, 0, 0); FOV.Thickness = 1.5; FOV.Filled = false

local function getCol(p) 
    local c = p.Character 
    if c and (c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then return Color3.new(1,0,0) 
    elseif c and (c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then return Color3.new(0,0,1) 
    else return Color3.new(0,1,0) end 
end

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local char = Plr.Character local h = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid")
    if not h or not hum or hum.Health <= 0 then return end
    
    local targetHRP = target.Character.HumanoidRootPart
    local savedCFrame = h.CFrame
    State.Aura = true

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 3000
    bg.CFrame = h.CFrame
    bg.Parent = h
    
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bp.P = 15000
    bp.D = 100
    bp.Parent = h

    for i = 1, 8 do
        if not targetHRP or not targetHRP.Parent then break end
        h.RotVelocity = Vector3.new(0, 99999, 0)
        bp.Position = (targetHRP.CFrame * CFrame.new(0, 0, -0.5)).Position
        task.wait(0.04)
        bp.Position = (targetHRP.CFrame * CFrame.new(0, 0, 0.5)).Position
        task.wait(0.04)
    end
    
    State.Aura = false
    bp:Destroy() bg:Destroy()
    h.Velocity = Vector3.zero h.RotVelocity = Vector3.zero h.CFrame = savedCFrame
end

local function getClosestToCenter()
    local target, closest = nil, FOV.Radius
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScreen = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < closest then 
                    closest = dist 
                    target = p 
                end
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"; h.Enabled = State.ESP; h.FillColor = getCol(p)
        end
    end
    
    if State.Aim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = getClosestToCenter()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    if State.Aura and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        Plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 99999, 0)
    elseif not State.Aura and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        Plr.Character.HumanoidRootPart.RotVelocity = Vector3.zero 
    end
    
    if (State.Fly or State.AntiFling or State.Aura) and Plr.Character then 
        for _,v in pairs(Plr.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end 
    end
    
    if State.Inf and UIS:IsKeyDown(Enum.KeyCode.Space) and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(Plr.Character.HumanoidRootPart.Velocity.X, 50, Plr.Character.HumanoidRootPart.Velocity.Z) 
    end
end)

Main:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) State.ESP = v end})
Main:CreateToggle({Name = "Silent Aim (Hold LMB)", CurrentValue = false, Callback = function(v) State.Aim = v; FOV.Visible = v end})
Main:CreateSlider({Name = "FOV Size", Range = {10, 200}, CurrentValue = 50, Callback = function(v) FOV.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) State.Inf = v end})
Main:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, CurrentValue = 16, Callback = function(v) State.BaseWS = v if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = v end end})

local DD = Tele:CreateDropdown({Name = "Target", Options = {}, Callback = function(o) State.Target = game.Players:FindFirstChild(o[1] or o) end})
Tele:CreateButton({Name = "Refresh", Callback = function() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p~=Plr then table.insert(t, p.Name) end end DD:Refresh(t, true) end})
Tele:CreateButton({Name = "TP Target", Callback = function() if State.Target and State.Target.Character then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})

Tele:CreateButton({Name = "PickUp Gun", Callback = function() 
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        local targetGun = nil
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "GunDrop" or v.Name == "Gun" then
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    targetGun = v
                    break
                elseif v:IsA("Model") and v.PrimaryPart then
                    targetGun = v.PrimaryPart
                    break
                elseif v:IsA("Model") and v:FindFirstChildOfClass("BasePart") then
                    targetGun = v:FindFirstChildOfClass("BasePart")
                    break
                end
            end
        end
        
        if targetGun then 
            local h = Plr.Character.HumanoidRootPart 
            local savedPos = h.CFrame 
            h.CFrame = targetGun.CFrame 
            task.wait(0.3) 
            h.CFrame = savedPos 
        else
            Rayfield:Notify({Name = "Error", Content = "Gun not found in workspace", Duration = 2})
        end
    end 
end})

Fling:CreateToggle({Name = "AntiFling (NoClip Mode)", CurrentValue = false, Callback = function(v) State.AntiFling = v end})
Fling:CreateToggle({Name = "Fling Kill Aura", CurrentValue = false, Callback = function(v) State.Aura = v end})
Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Selected (By Nick)", Callback = function() if State.Target then runFling(State.Target) end end})

UIS.InputBegan:Connect(function(i, g) if g then return end
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly local h = Plr.Character.HumanoidRootPart if State.Fly then local bv = Instance.new("BodyVelocity", h); bv.Name = "FBV"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 end end) else if h:FindFirstChild("FBV") then h.FBV:Destroy() end end
    elseif i.KeyCode == Enum.KeyCode.Z then if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = 25 Cam.FieldOfView = 110 end
    end
end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Z then if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = State.BaseWS Cam.FieldOfView = 70 end end end)
