local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Hardcore Build", LoadingSubtitle = "Final", ConfigurationSaving = {Enabled = false}})

local Main = Win:CreateTab("Main")
local Tele = Win:CreateTab("Teleports")
local Fling = Win:CreateTab("Fling")

local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {
    MurdererAim = false, 
    ESP = false, 
    Fly = false, 
    Aura = false, 
    Inf = false, 
    AntiFling = false, 
    Target = nil, 
    BaseWS = 16, 
    GodMode = false, 
    SpinFling = false,
    CameraStretch = false
}

local AIM_RADIUS = 50

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

local function getMurdererTarget()
    local maxDist = AIM_RADIUS
    local targetChar = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character:FindFirstChild("Knife") then
                local pos, onScreen = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        targetChar = p.Character
                    end
                end
            end
        end
    end
    return targetChar
end

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChildOfClass("Humanoid") then return end
    local thub = target.Character:FindFirstChildOfClass("Humanoid")
    local thp = target.Character.HumanoidRootPart
    local h = Plr.Character.HumanoidRootPart 
    local s = h.CFrame
    
    local oldType = Cam.CameraType
    Cam.CameraType = Enum.CameraType.Scriptable
    
    while thub.Health > 0 and target.Parent and thp.Position.Y < 2000 do
        h.CFrame = thp.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
        h.RotVelocity = Vector3.new(0, 500000, 0)
        task.wait()
    end
    
    h.Velocity = Vector3.zero 
    h.RotVelocity = Vector3.zero 
    h.CFrame = s
    Cam.CameraType = oldType
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if State.MurdererAim and method == "FireServer" and self.Name == "ShootGun" then
        local targetMurderer = getMurdererTarget()
        if targetMurderer and targetMurderer:FindFirstChild("HumanoidRootPart") then
            args[1] = targetMurderer.HumanoidRootPart.Position
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

Plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.BaseWS
end)

RS.RenderStepped:Connect(function()
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"; h.Enabled = State.ESP; h.FillColor = getCol(p)
            
            if State.AntiFling and p.Character:FindFirstChild("HumanoidRootPart") then
                local opponentHrp = p.Character.HumanoidRootPart
                if (opponentHrp.RotVelocity.Magnitude > 500 or opponentHrp.Velocity.Magnitude > 500) and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (Plr.Character.HumanoidRootPart.Position - opponentHrp.Position).Magnitude
                    if distance < 15 then
                        opponentHrp.Velocity = Vector3.new(0, 500000, 0)
                        opponentHrp.CFrame = opponentHrp.CFrame * CFrame.new(0, 10000, 0)
                    end
                end
            end
        end
    end
    
    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Plr.Character.HumanoidRootPart
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        
        if hum then
            local targetSpeed = State.BaseWS
            if UIS:IsKeyDown(Enum.KeyCode.Z) then
                targetSpeed = 25
            end
            if hum.WalkSpeed ~= targetSpeed then
                hum.WalkSpeed = targetSpeed
            end
            
            if State.GodMode then
                if hum.MaxHealth ~= 2000 then hum.MaxHealth = 2000 end
                if hum.Health < 2000 then hum.Health = 2000 end
            end
        end
        
        if State.CameraStretch then
            Cam.FieldOfView = UIS:IsKeyDown(Enum.KeyCode.Z) and 125 or 110
        else
            Cam.FieldOfView = UIS:IsKeyDown(Enum.KeyCode.Z) and 110 or 70
        end
        
        if (State.Fly or State.AntiFling or State.SpinFling) then 
            for _,v in pairs(Plr.Character:GetChildren()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
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
Main:CreateToggle({Name = "Доводчик на Мардера (Нож)", Callback = function(v) State.MurdererAim = v end})
Main:CreateToggle({Name = "Эффект растяга камеры", Callback = function(v) State.CameraStretch = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.Inf = v end})

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
    Name = "GodMode (2000 HP)", 
    Callback = function(v) 
        State.GodMode = v 
        if v and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 2000
            hum.Health = 2000
        elseif not v and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 100
            hum.Health = 100
        end 
    end
})

local DD = Tele:CreateDropdown({Name = "Target", Options = {}, Callback = function(o) State.Target = game.Players:FindFirstChild(o[1] or o) end})
Tele:CreateButton({Name = "Refresh", Callback = function() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p~=Plr then table.insert(t, p.Name) end end DD:Refresh(t, true) end})
Tele:CreateButton({Name = "TP Target", Callback = function() if State.Target then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})

Tele:CreateButton({
    Name = "PickUp Gun", 
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

Fling:CreateToggle({Name = "Ultra AntiFling (Counter Fling)", Callback = function(v) State.AntiFling = v end})
Fling:CreateToggle({Name = "Spin Fling", Callback = function(v) State.SpinFling = v end})
Fling:CreateToggle({Name = "Fling Aura", Callback = function(v) State.Aura = v end})

Fling:CreateButton({Name = "Fling Murderer", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Sheriff", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Selected", Callback = function() if State.Target then runFling(State.Target) end end})

UIS.InputBegan:Connect(function(i, g) if g then return end
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly local h = Plr.Character.HumanoidRootPart if State.Fly then local bv = Instance.new("BodyVelocity", h); bv.Name = "FBV"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 end end) else if h:FindFirstChild("FBV") then h.FBV:Destroy() end end
    end
end)
