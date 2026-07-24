local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Hardcore Build", LoadingSubtitle = "Final", ConfigurationSaving = {Enabled = false}})

local Main = Win:CreateTab("Main")
local Tele = Win:CreateTab("Teleports")
local Fling = Win:CreateTab("Fling")

local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {
    Aim = false, 
    ESP = false, 
    Fly = false, 
    Aura = false, 
    Inf = false, 
    AntiFling = false, 
    Target = nil, 
    BaseWS = 16, 
    GodMode = false, 
    SpinFling = false,
    Sharpening = false,
    Salute = false,
    CombinedSalute = false
}
local FOV = Drawing.new("Circle") 
FOV.Visible = false; FOV.Radius = 50; FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2); FOV.Color = Color3.fromRGB(255, 0, 0); FOV.Thickness = 1.5

local function findDroppedGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name == "GunDrop" or v.Name == "Gun") then
            return v:FindFirstChild("Point") or v:FindFirstChildWhichIsA("BasePart")
        elseif v:IsA("BasePart") and (v.Name == "GunDrop" or v.Name == "Gun") then
            return v
        end
    end
    return nil
end

local function getCol(p) 
    local c = p.Character 
    if c and (c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then return Color3.new(1,0,0) 
    elseif c and (c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then return Color3.new(0,0,1) 
    else return Color3.new(0,1,0) end 
end

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local h = Plr.Character.HumanoidRootPart 
    local s = h.CFrame
    for i = 1, 60 do
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
        h.RotVelocity = Vector3.new(0, 80000, 0)
        task.wait(0.01)
    end
    h.Velocity = Vector3.zero 
    h.RotVelocity = Vector3.zero 
    h.CFrame = s
end

local function stopArmAnimations(hum)
    if not hum then return end
    for _, track in pairs(hum:GetPlayingAnimationTracks()) do
        if track.Animation and (track.Animation.AnimationId:find("idle") or track.Animation.AnimationId:find("walk") or track.Animation.AnimationId:find("run") or track.Animation.AnimationId:find("hold")) then
            track:Stop()
        end
    end
end

local function KillAll()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end

-- Silent Aim Fix
local function GetClosestPlayer()
    local closest, dist = nil, FOV.Radius
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (v.Character.HumanoidRootPart.Position - Plr.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then closest, dist = v, mag end
        end
    end
    return closest
end

-- Silent Aim Hook
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if State.Aim and self == Plr and key == "Mouse" then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            return {Target = target.Character.HumanoidRootPart}
        end
    end
    return oldIndex(self, key)
end)

Plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.BaseWS
end)

RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"; h.Enabled = State.ESP; h.FillColor = getCol(p)
        end
    end

    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Plr.Character.HumanoidRootPart
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")

        local tor = Plr.Character:FindFirstChild("Torso") or Plr.Character:FindFirstChild("UpperTorso")
        local rArm = tor and (tor:FindFirstChild("Right Shoulder") or (Plr.Character:FindFirstChild("RightUpperArm") and Plr.Character:FindFirstChild("RightUpperArm"):FindFirstChild("RightShoulder")))
        local lArm = tor and (tor:FindFirstChild("Left Shoulder") or (Plr.Character:FindFirstChild("LeftUpperArm") and Plr.Character:FindFirstChild("LeftUpperArm"):FindFirstChild("LeftShoulder")))
        local tool = Plr.Character:FindFirstChildOfClass("Tool")

        if hum then
            if State.GodMode then
                if hum.MaxHealth ~= 500 then hum.MaxHealth = 500 end
                if hum.Health < 500 then hum.Health = 500 end
            else
                if hum.MaxHealth ~= 100 then hum.MaxHealth = 100 end
            end
        end

        if (State.Fly or State.AntiFling or State.SpinFling) then 
            for _,v in pairs(Plr.Character:GetChildren()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end 
        end

        -- Arm Animations Fix
        if not (State.Sharpening or State.Salute or State.CombinedSalute) then
            if rArm and rArm:IsA("Motor6D") then
                rArm.C0 = CFrame.new(1, 0.5, 0)
                rArm.C1 = CFrame.new(0, 0, 0)
            end
            if lArm and lArm:IsA("Motor6D") then
                lArm.C0 = CFrame.new(-1, 0.5, 0)
                lArm.C1 = CFrame.new(0, 0, 0)
            end
        else
            stopArmAnimations(hum)
        end

        if State.Sharpening and not State.CombinedSalute then
            local offset = math.sin(tick() * 38) * 0.85
            if tool and tool:FindFirstChild("GripConstraint") == nil then
                tool.Grip = CFrame.new(0, 0, offset)
            end
            if rArm and rArm:IsA("Motor6D") then
                rArm.C0 = CFrame.new(1, 0.5 + (offset * 0.3), offset) * CFrame.Angles(math.rad(90), 0, 0)
                rArm.C1 = CFrame.new(0, 0, 0)
            end
        end

        if State.Salute and not State.CombinedSalute then
            if rArm and rArm:IsA("Motor6D") then
                rArm.C0 = CFrame.new(1, 1, -0.5) * CFrame.Angles(math.rad(135), 0, math.rad(-30))
                rArm.C1 = CFrame.new(0, 0, 0)
            end
        end

        if State.CombinedSalute then
            if rArm and rArm:IsA("Motor6D") then
                rArm.C0 = CFrame.new(1, 1, -0.5) * CFrame.Angles(math.rad(135), 0, math.rad(-30))
                rArm.C1 = CFrame.new(0, 0, 0)
            end
            local offset = math.sin(tick() * 38) * 0.85
            if lArm and lArm:IsA("Motor6D") then
                lArm.C0 = CFrame.new(-1, 0.5 + (offset * 0.3), offset) * CFrame.Angles(math.rad(90), 0, 0)
                lArm.C1 = CFrame.new(0, 0, 0)
            end
        end

        if State.SpinFling then
            hrp.RotVelocity = Vector3.new(0, 99999, 0)
            local originalVelocity = hrp.Velocity
            hrp.Velocity = Vector3.new(originalVelocity.X, 0, originalVelocity.Z) + (hrp.CFrame.LookVector * 0.01)
        elseif not State.Aura then 
            hrp.RotVelocity = Vector3.new(0, 0, 0) 
        end

        if State.Aura then 
            hrp.CFrame = hrp.CFrame + (Cam.CFrame.LookVector * 0.6) 
            hrp.RotVelocity = Vector3.new(0, 60000, 0) 
        end

        if State.Inf and UIS:IsKeyDown(Enum.KeyCode.Space) and hum then 
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z) 
        end
    end
end)

Main:CreateToggle({Name = "ESP", Callback = function(v) State.ESP = v end})
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) State.Aim = v; FOV.Visible = v end})
Main:CreateSlider({Name = "FOV Size", Range = {10, 200}, CurrentValue = 50, Callback = function(v) FOV.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.Inf = v end})

-- Walkspeed Fix
Main:CreateSlider({
    Name = "WalkSpeed", 
    Range = {16, 120}, 
    CurrentValue = 16, 
    Callback = function(v) 
        State.BaseWS = v 
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            Plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v 
        end 
    end
})

Main:CreateToggle({
    Name = "GodMode (500 HP)", 
    Callback = function(v) 
        State.GodMode = v 
        if v and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 500
            hum.Health = 500
        elseif not v and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 100
            if hum.Health > 100 then hum.Health = 100 end
        end 
    end
})

-- Kill All Button
Main:CreateButton({Name = "Kill All", Callback = KillAll})

local DD = Tele:CreateDropdown({Name = "Target", Options = {}, Callback = function(o) State.Target = game.Players:FindFirstChild(o[1] or o) end})
Tele:CreateButton({Name = "Refresh", Callback = function() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p~=Plr then table.insert(t, p.Name) end end DD:Refresh(t, true) end})
Tele:CreateButton({Name = "TP Target", Callback = function() if State.Target and State.Target.Character and State.Target.Character:FindFirstChild("HumanoidRootPart") then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})

Tele:CreateButton({
    Name = "PickUp Gun (G)", 
    Callback = function() 
        local gunPart = findDroppedGun()
        if gunPart and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
            local h = Plr.Character.HumanoidRootPart 
            local s = h.CFrame 
            h.CFrame = gunPart.CFrame 
            task.wait(0.2) 
            h.CFrame = s 
        end 
    end
})

Fling:CreateToggle({Name = "AntiFling (NoClip)", Callback = function(v) State.AntiFling = v end})
Fling:CreateToggle({Name = "Spin Fling", Callback = function(v) State.SpinFling = v end})
Fling:CreateToggle({Name = "Fling Aura", Callback = function(v) State.Aura = v end})

Fling:CreateToggle({Name = "Точить шпагу", Callback = function(v) State.Sharpening = v end})
Fling:CreateToggle({Name = "Римский салют", Callback = function(v) State.Salute = v end})
Fling:CreateToggle({Name = "Салют с точкой шпаги", Callback = function(v) State.CombinedSalute = v end})

Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Selected", Callback = function() if State.Target then runFling(State.Target) end end})

UIS.InputBegan:Connect(function(i, g) if g then return end
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then 
        State.Fly = not State.Fly 
        local h = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
        if State.Fly and h then 
            local bv = Instance.new("BodyVelocity", h); 
            bv.Name = "FBV"; 
            bv.MaxForce = Vector3.new(9e9,9e9,9e9); 
            RS.Heartbeat:Connect(function() 
                if State.Fly and bv then 
                    bv.Velocity = Cam.CFrame.LookVector * 60 
                end 
            end) 
        else 
            if h and h:FindFirstChild("FBV") then h.FBV:Destroy() end 
        end
    elseif i.KeyCode == Enum.KeyCode.Z then 
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            Plr.Character.Humanoid.WalkSpeed = 25 
            Cam.FieldOfView = 110 
        end
    elseif i.KeyCode == Enum.KeyCode.G then
        local gunPart = findDroppedGun()
        if gunPart and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
            local h = Plr.Character.HumanoidRootPart 
            local s = h.CFrame 
            h.CFrame = gunPart.CFrame 
            task.wait(0.2) 
            h.CFrame = s 
        end
    end
end)

UIS.InputEnded:Connect(function(i) 
    if i.KeyCode == Enum.KeyCode.Z then 
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            Plr.Character.Humanoid.WalkSpeed = State.BaseWS 
            Cam.FieldOfView = 70 
        end 
    end 
end)