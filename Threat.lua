local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Unknown Threat", LoadingTitle = "Hardcore Build", LoadingSubtitle = "UT PC Edition", ConfigurationSaving = {Enabled = false}})

local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local State = {Aim = false, ESP = false, Fly = false, Aura = false, Inf = false, AntiFling = false, Target = nil, BaseWS = 16, FOVSize = 50}
local FOV = Drawing.new("Circle") 
FOV.Visible = false; FOV.Radius = 50; FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2); FOV.Color = Color3.fromRGB(255, 0, 0); FOV.Thickness = 1.5

local function getCol(p) 
    local bp = p:FindFirstChild("Backpack")
    local ch = p.Character
    if (ch and (ch:FindFirstChild("Knife") or ch:FindFirstChild("Blade"))) or (bp and (bp:FindFirstChild("Knife") or bp:FindFirstChild("Blade"))) then 
        return Color3.new(1,0,0) 
    elseif (ch and (ch:FindFirstChild("Pistol") or ch:FindFirstChild("Revolver") or ch:FindFirstChild("Gun"))) or (bp and (bp:FindFirstChild("Pistol") or bp:FindFirstChild("Revolver") or bp:FindFirstChild("Gun"))) then 
        return Color3.new(0,0,1) 
    end
    return Color3.new(0,1,0)
end

local function amIHero()
    local ch = Plr.Character
    if ch and (ch:FindFirstChild("Pistol") or ch:FindFirstChild("Revolver") or ch:FindFirstChild("Gun")) then
        return true
    end
    return false
end

local function getClosestPlayer()
    local closest, dist = nil, State.FOVSize
    local filterByThreat = amIHero()
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if filterByThreat and getCol(p) ~= Color3.new(1,0,0) then 
                continue 
            end
            local pos, onScreen = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
                if mouseDist < dist then
                    closest = p
                    dist = mouseDist
                end
            end
        end
    end
    return closest
end

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local h = Plr.Character.HumanoidRootPart local s = h.CFrame
    for i = 1, 60 do
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
        h.RotVelocity = Vector3.new(0, 80000, 0)
        task.wait(0.01)
    end
    h.Velocity = Vector3.zero h.RotVelocity = Vector3.zero h.CFrame = s
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if State.Aim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if method == "Raycast" then
                args[2] = (target.Character.Head.Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(Cam.CFrame.Position, (target.Character.Head.Position - Cam.CFrame.Position).Unit * 1000)
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H")
            if State.ESP then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "H"
                    h.Parent = p.Character
                end
                h.Enabled = true
                h.FillColor = getCol(p)
                h.OutlineColor = Color3.new(1,1,1)
                h.FillThickness = 0.5
            else
                if h then h.Enabled = false end
            end
        end
    end
    if not State.Aura and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then Plr.Character.HumanoidRootPart.RotVelocity = Vector3.zero end
    if (State.Fly or State.AntiFling) and Plr.Character then for _,v in pairs(Plr.Character:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if State.Aura then Plr.Character.HumanoidRootPart.CFrame = Plr.Character.HumanoidRootPart.CFrame + (Cam.CFrame.LookVector * 0.6) Plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 60000, 0) end
    if State.Inf and UIS:IsKeyDown(Enum.KeyCode.Space) and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.HumanoidRootPart.Velocity = Vector3.new(Plr.Character.HumanoidRootPart.Velocity.X, 50, Plr.Character.HumanoidRootPart.Velocity.Z) end
end)

Main:CreateToggle({Name = "ESP", Callback = function(v) State.ESP = v end})
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) State.Aim = v; FOV.Visible = v end})
Main:CreateSlider({Name = "FOV Size", Range = {10, 200}, CurrentValue = 50, Callback = function(v) State.FOVSize = v; FOV.Radius = v end})
Main:CreateToggle({Name = "Infinite Jump", Callback = function(v) State.Inf = v end})
Main:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, CurrentValue = 16, Callback = function(v) State.BaseWS = v if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = v end end})

local DD = Tele:CreateDropdown({Name = "Target", Options = {}, Callback = function(o) State.Target = game.Players:FindFirstChild(o[1] or o) end})
Tele:CreateButton({Name = "Refresh", Callback = function() local t = {} for _,p in pairs(game.Players:GetPlayers()) do if p~=Plr then table.insert(t, p.Name) end end DD:Refresh(t, true) end})
Tele:CreateButton({Name = "TP Target", Callback = function() if State.Target then Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame end end})
Tele:CreateButton({Name = "PickUp Gun", Callback = function() 
    local g = workspace:FindFirstChild("DroppedGun") or workspace:FindFirstChild("Pistol") or workspace:FindFirstChild("GunDrop") or (workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("GunDrop"))
    if g and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        local h = Plr.Character.HumanoidRootPart local s = h.CFrame h.CFrame = g.CFrame task.wait(0.2) h.CFrame = s 
    end 
end})

Fling:CreateToggle({Name = "AntiFling (NoClip Mode)", Callback = function(v) State.AntiFling = v end})
Fling:CreateToggle({Name = "Fling Aura", Callback = function(v) State.Aura = v end})
Fling:CreateButton({Name = "Fling Threat (Murderer)", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if getCol(p) == Color3.new(1,0,0) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Police (Sheriff)", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if getCol(p) == Color3.new(0,0,1) then runFling(p) end end end})
Fling:CreateButton({Name = "Fling Selected (By Nick)", Callback = function() if State.Target then runFling(State.Target) end end})

UIS.InputBegan:Connect(function(i, g) if g then return end
    if i.KeyCode == Enum.KeyCode.V then State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then State.Fly = not State.Fly local h = Plr.Character.HumanoidRootPart if State.Fly then local bv = Instance.new("BodyVelocity", h); bv.Name = "FBV"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); RS.Heartbeat:Connect(function() if State.Fly then bv.Velocity = Cam.CFrame.LookVector * 60 end end) else if h:FindFirstChild("FBV") then h.FBV:Destroy() end end
    elseif i.KeyCode == Enum.KeyCode.Z then if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = 25 Cam.FieldOfView = 110 end
    end
end)
UIS.InputEnded:Connect(function(i) 
    if i.KeyCode == Enum.KeyCode.Z then if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then Plr.Character.Humanoid.WalkSpeed = State.BaseWS Cam.FieldOfView = 70 end end 
end)

for i=1, 600 do local _ = i end
