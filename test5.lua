local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Libraries/Rayfield-Library/main/Source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Project Mayhem | Messer2004",
    LoadingTitle = "Hardcore Build",
    LoadingSubtitle = "Rayfield V2",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)
local TeleTab = Window:CreateTab("Teleports", 4483362458)
local FlingTab = Window:CreateTab("Fling", 4483362458)

local Plr = game:GetService("Players").LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

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
    SpinFling = false
}

local FOV = Drawing.new("Circle")
FOV.Visible = false
FOV.Radius = 50
FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Thickness = 1.5

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
    if c and (c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 50, 50)
    elseif c and (c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then
        return Color3.fromRGB(50, 150, 255)
    else
        return Color3.fromRGB(50, 255, 50)
    end
end

local function runFling(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    if not Plr.Character or not Plr.Character:FindFirstChild("HumanoidRootPart") then return end

    local h = Plr.Character.HumanoidRootPart
    local s = h.CFrame
    for i = 1, 60 do
        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then break end
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
        h.RotVelocity = Vector3.new(0, 80000, 0)
        task.wait(0.01)
    end
    h.Velocity = Vector3.zero
    h.RotVelocity = Vector3.zero
    h.CFrame = s
end

local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = FOV.Radius

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then
                local pos, onScreen = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = p
                    end
                end
            end
        end
    end
    return closestPlayer
end

RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"
            h.Enabled = State.ESP
            h.FillColor = getCol(p)
        end
    end

    if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Plr.Character.HumanoidRootPart
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")

        if hum then
            local speedMultiplier = UIS:IsKeyDown(Enum.KeyCode.Z) and 25 or State.BaseWS
            if hum.WalkSpeed ~= speedMultiplier then
                hum.WalkSpeed = speedMultiplier
            end

            if State.GodMode then
                if hum.MaxHealth ~= 500 then hum.MaxHealth = 500 end
                if hum.Health < 500 then hum.Health = 500 end
            end
        end

        if (State.Fly or State.AntiFling or State.SpinFling) then
            for _, v in pairs(Plr.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        if State.SpinFling then
            hrp.RotVelocity = Vector3.new(0, 99999, 0)
            local origVel = hrp.Velocity
            hrp.Velocity = Vector3.new(origVel.X, 0, origVel.Z) + (hrp.CFrame.LookVector * 0.01)
        elseif not State.Aura then
            hrp.RotVelocity = Vector3.zero
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

MainTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v) State.ESP = v end
})

MainTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        State.Aim = v
        FOV.Visible = v
    end
})

MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) FOV.Radius = v end
})

MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) State.Inf = v end
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        State.BaseWS = v
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            Plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

MainTab:CreateToggle({
    Name = "GodMode (500 HP)",
    CurrentValue = false,
    Callback = function(v)
        State.GodMode = v
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            if v then
                hum.MaxHealth = 500
                hum.Health = 500
            else
                hum.MaxHealth = 100
                hum.Health = math.min(hum.Health, 100)
            end
        end
    end
})

local PlayerDropdown = TeleTab:CreateDropdown({
    Name = "Target Player",
    Options = {"None"},
    CurrentOption = "None",
    Callback = function(Option)
        local name = type(Option) == "table" and Option[1] or Option
        State.Target = game.Players:FindFirstChild(name)
    end
})

TeleTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        local list = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Plr then table.insert(list, p.Name) end
        end
        PlayerDropdown:Refresh(list)
    end
})

TeleTab:CreateButton({
    Name = "TP Target",
    Callback = function()
        if State.Target and State.Target.Character and State.Target.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = State.Target.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleTab:CreateButton({
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

FlingTab:CreateToggle({
    Name = "AntiFling (NoClip)",
    CurrentValue = false,
    Callback = function(v) State.AntiFling = v end
})

FlingTab:CreateToggle({
    Name = "Spin Fling",
    CurrentValue = false,
    Callback = function(v) State.SpinFling = v end
})

FlingTab:CreateToggle({
    Name = "Fling Aura",
    CurrentValue = false,
    Callback = function(v) State.Aura = v end
})

FlingTab:CreateButton({
    Name = "Fling Murderer",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
                runFling(p)
            end
        end
    end
})

FlingTab:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then
                runFling(p)
            end
        end
    end
})

FlingTab:CreateButton({
    Name = "Fling Selected Target",
    Callback = function()
        if State.Target then runFling(State.Target) end
    end
})

UIS.InputBegan:Connect(function(i, g)
    if g then return end

    if i.KeyCode == Enum.KeyCode.V then
        State.ESP = not State.ESP
    elseif i.KeyCode == Enum.KeyCode.X then
        State.Fly = not State.Fly
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            local h = Plr.Character.HumanoidRootPart
            if State.Fly then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FBV"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = h
                
                task.spawn(function()
                    while State.Fly do
                        bv.Velocity = Cam.CFrame.LookVector * 60
                        task.wait()
                    end
                    bv:Destroy()
                end)
            end
        end
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
