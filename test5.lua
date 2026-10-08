local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({
    Name = "Project Mayhem | Messer2004", 
    LoadingTitle = "Hardcore Build", 
    LoadingSubtitle = "Final Edition", 
    ConfigurationSaving = {Enabled = false}
})

local Main = Win:CreateTab("Main")
local Tele = Win:CreateTab("Teleports")
local Troll = Win:CreateTab("Trolling")

local Plr = game:GetService("Players").LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local State = {
    Aim = false, 
    ESP = false, 
    Inf = false, 
    Target = nil, 
    BaseWS = 16,
    FOVRadius = 50
}

-- FOV Circle setup
local FOV = Drawing.new("Circle") 
FOV.Visible = false
FOV.Radius = State.FOVRadius
FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Thickness = 1.5

-- Role Helpers
local function getMurderer()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            if p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then
                return p
            end
        end
    end
    return nil
end

local function getCol(p) 
    local c = p.Character 
    if c and (c:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))) then 
        return Color3.fromRGB(255, 0, 0) -- Murder (Red)
    elseif c and (c:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))) then 
        return Color3.fromRGB(0, 100, 255) -- Sheriff (Blue)
    else 
        return Color3.fromRGB(0, 255, 0) -- Innocent (Green)
    end 
end

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

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not Plr.Character or not Plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local h = Plr.Character.HumanoidRootPart
    local s = h.CFrame
    for i = 1, 60 do
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then break end
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
        h.RotVelocity = Vector3.new(0, 80000, 0)
        task.wait(0.01)
    end
    h.Velocity = Vector3.zero
    h.RotVelocity = Vector3.zero
    h.CFrame = s
end

local function grabGunAction()
    local gunPart = findDroppedGun()
    if gunPart and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        local h = Plr.Character.HumanoidRootPart 
        local s = h.CFrame 
        h.CFrame = gunPart.CFrame 
        task.wait(0.15) 
        h.CFrame = s 
    end 
end

-- Silent Aim Hooking (Aiming ONLY at Murderer inside FOV)
local rawmetatable = getrawmetatable(game)
local oldNamecall = rawmetatable.__namecall
setreadonly(rawmetatable, false)

rawmetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if State.Aim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast" or method == "FindPartOnRay") then
        local murd = getMurderer()
        if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Cam:WorldToViewportPoint(murd.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist <= State.FOVRadius then
                    if method == "Raycast" then
                        args[2] = (murd.Character.HumanoidRootPart.Position - args[1]).Unit * 1000
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(rawmetatable, true)

-- Character Spawn Handler
Plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.BaseWS
end)

-- Main Loop
RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    
    -- ESP
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"
            h.Enabled = State.ESP
            h.FillColor = getCol(p)
        end
    end
    
    -- WalkSpeed Management
    if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        local targetSpeed = UIS:IsKeyDown(Enum.KeyCode.Z) and 25 or State.BaseWS
        if hum.WalkSpeed ~= targetSpeed then
            hum.WalkSpeed = targetSpeed
        end
    end
    
    -- Infinite Jump
    if State.Inf and UIS:IsKeyDown(Enum.KeyCode.Space) and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(Plr.Character.HumanoidRootPart.Velocity.X, 50, Plr.Character.HumanoidRootPart.Velocity.Z) 
    end
end)

-- 1. MAIN TAB
Main:CreateToggle({Name = "ESP", Callback = function(v) State.ESP = v end})
Main:CreateToggle({Name = "Silent Aim (Murder Only)", Callback = function(v) State.Aim = v; FOV.Visible = v end})
Main:CreateSlider({Name = "FOV Size", Range = {10, 300}, CurrentValue = 50, Callback = function(v) State.FOVRadius = v; FOV.Radius = v end})
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

-- 2. TELEPORTS TAB
Tele:CreateButton({
    Name = "TP to Murder", 
    Callback = function() 
        local m = getMurderer()
        if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
        end
    end
})

Tele:CreateButton({
    Name = "TP to Sheriff", 
    Callback = function() 
        local s = getSheriff()
        if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
        end
    end
})

local DD = Tele:CreateDropdown({Name = "Target Player", Options = {}, Callback = function(o) State.Target = game.Players:FindFirstChild(o[1] or o) end})

Tele:CreateButton({
    Name = "Refresh Players", 
    Callback = function() 
        local t = {} 
        for _, p in pairs(game.Players:GetPlayers()) do 
            if p ~= Plr then table.insert(t, p.Name) end 
        end 
        DD:Refresh(t, true) 
    end
})

Tele:CreateButton({
    Name = "TP to Target", 
    Callback = function() 
        if State.Target and State.Target.Character and State.Target.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then 
            Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame 
        end 
    end
})

Tele:CreateButton({
    Name = "Grab Gun (Press V)", 
    Callback = function() 
        grabGunAction()
    end
})

-- 3. TROLLING TAB
Troll:CreateButton({
    Name = "Fling Murderer", 
    Callback = function() 
        local m = getMurderer()
        if m then runFling(m) end
    end
})

Troll:CreateButton({
    Name = "Fling Sheriff", 
    Callback = function() 
        local s = getSheriff()
        if s then runFling(s) end
    end
})

Troll:CreateButton({
    Name = "Fling Selected Target", 
    Callback = function() 
        if State.Target then runFling(State.Target) end 
    end
})

-- Keybinds
UIS.InputBegan:Connect(function(i, g) 
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then 
        grabGunAction()
    elseif i.KeyCode == Enum.KeyCode.Z then 
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then 
            Plr.Character.Humanoid.WalkSpeed = 25 
            Cam.FieldOfView = 110 
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
