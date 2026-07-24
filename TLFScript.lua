-- The Lost Front | Project Mayhem Mobile
-- By Messer_2004 | Delta Optimized + Rayfield

loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({
    Name = "Project Mayhem | TLF",
    LoadingTitle = "Project Mayhem",
    LoadingSubtitle = "By Messer_2004",
    ConfigurationSaving = { Enabled = true, FolderName = "ProjectMayhem_TLF" }
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- States
local State = {
    ESP = false,
    Aim = false,
    FOV = 60,
    Walkspeed = 16,
    Fly = false,
    Noclip = false,
    InfJump = false,
    GodMode = false,
    NoRecoil = false,
    NoFog = false,
    Fullbright = false,
    Target = nil,
    FlySpeed = 50,
    Sprint = false
}

-- ESP Boxes table
local ESPBoxes = {}

-- Functions
local function CreateESP(player)
    if player == LP or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    if not hrp then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Size = Vector3.new(4, 5, 1)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 0
    
    if player.Team then
        if player.Team.Name == "Axis" then
            box.Color3 = Color3.new(1, 0, 0)
        elseif player.Team.Name == "Allies" then
            box.Color3 = Color3.new(0, 0.3, 1)
        else
            box.Color3 = Color3.new(0, 1, 0)
        end
    else
        box.Color3 = Color3.new(0, 1, 0)
    end
    
    box.Transparency = 0.5
    box.Parent = hrp
    box.Enabled = State.ESP
    table.insert(ESPBoxes, box)
end

local function RemoveESP()
    for _, v in pairs(ESPBoxes) do
        v:Destroy()
    end
    ESPBoxes = {}
end

local function ToggleESP()
    State.ESP = not State.ESP
    if State.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            CreateESP(p)
        end
    else
        RemoveESP()
    end
end

local function GetClosestPlayer()
    local closest, dist = nil, State.FOV
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                closest, dist = p, mag
            end
        end
    end
    return closest
end

local function ToggleFly()
    State.Fly = not State.Fly
    State.Noclip = State.Fly
    if State.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = LP.Character.HumanoidRootPart
    elseif LP.Character then
        local bv = LP.Character:FindFirstChild("FlyBV")
        if bv then bv:Destroy() end
    end
end

-- Character Added handler
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.Walkspeed
    hum.JumpPower = State.InfJump and 150 or 50
    
    if State.GodMode then
        hum.MaxHealth = 999
        hum.Health = 999
    end
    
    -- No Recoil via tool check
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.ChildAdded:Connect(function(subChild)
                if subChild:IsA("NumberValue") and subChild.Name:lower():find("recoil") then
                    subChild:Destroy()
                end
            end)
        end
    end)
end)

-- Main loops
RS.RenderStepped:Connect(function()
    -- Silent Aim target finder
    if State.Aim then
        State.Target = GetClosestPlayer()
    end
    
    -- No Fog
    if State.NoFog then
        Lighting.FogEnd = 99999
    else
        Lighting.FogEnd = 1000
    end
    
    -- Fullbright
    if State.Fullbright then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    
    -- Noclip
    if State.Noclip then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
    
    -- Fly
    if State.Fly then
        local bv = LP.Character:FindFirstChild("FlyBV")
        if bv then
            local move = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            bv.Velocity = move * State.FlySpeed
        end
    end
    
    -- Infinity Jump
    if State.InfJump then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum.JumpPower = 150
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    -- God Mode
    if State.GodMode then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 999
            if hum.Health < 999 then hum.Health = 999 end
        end
    end
end)

-- Binds (V, X, Z)
UIS.InputBegan:Connect(function(input, g)
    if g then return end
    if input.KeyCode == Enum.KeyCode.V then
        ToggleESP()
    end
    if input.KeyCode == Enum.KeyCode.X then
        ToggleFly()
    end
    if input.KeyCode == Enum.KeyCode.Z then
        State.Sprint = not State.Sprint
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = State.Sprint and 35 or State.Walkspeed
        end
    end
end)

-- Main Tab
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })

Main:CreateButton({ Name = "ESP (V)", Callback = ToggleESP })

Main:CreateToggle({ Name = "Silent Aim", Default = false, Callback = function(v) State.Aim = v end })

Main:CreateSlider({ 
    Name = "Aim FOV", 
    Min = 10, 
    Max = 200, 
    Default = 60, 
    Callback = function(v) State.FOV = v end 
})

Main:CreateSlider({ 
    Name = "Walkspeed", 
    Min = 16, 
    Max = 120, 
    Default = 16, 
    Callback = function(v) 
        State.Walkspeed = v 
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = State.Sprint and 35 or v
        end
    end 
})

Main:CreateToggle({ Name = "Infinity Jump", Default = false, Callback = function(v) State.InfJump = v end })

Main:CreateButton({ Name = "Fly (X)", Callback = ToggleFly })

Main:CreateSlider({ 
    Name = "Fly Speed", 
    Min = 10, 
    Max = 200, 
    Default = 50, 
    Callback = function(v) State.FlySpeed = v end 
})

Main:CreateToggle({ Name = "God Mode (999 HP)", Default = false, Callback = function(v) 
    State.GodMode = v 
    if v and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        hum.MaxHealth = 999
        hum.Health = 999
    end
end })

-- Visual Tab
local Visual = Window:CreateTab({ Name = "Visual", Icon = "eye" })

Visual:CreateToggle({ Name = "No Recoil", Default = false, Callback = function(v) State.NoRecoil = v end })

Visual:CreateToggle({ Name = "No Fog", Default = false, Callback = function(v) State.NoFog = v end })

Visual:CreateToggle({ Name = "Fullbright", Default = false, Callback = function(v) State.Fullbright = v end })

-- Teleports Tab
local Teleports = Window:CreateTab({ Name = "Teleports", Icon = "map-pin" })

Teleports:CreateButton({ Name = "Teleport to Map Center", Callback = function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end })

Teleports:CreateButton({ Name = "Teleport to Lobby", Callback = function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end })

local PlayerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(PlayerList, p.Name) end
end

Teleports:CreateDropdown({ 
    Name = "Teleport to Player", 
    Options = PlayerList, 
    CurrentOption = "", 
    Callback = function(opt)
        if not opt or opt == "" then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == opt and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end 
})

-- Fling Tab
local FlingTab = Window:CreateTab({ Name = "Fling", Icon = "target" })

local function FlingCharacter(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = target.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500, 200, 500)).LookVector * 9999
    bv.Parent = hrp
    game:GetService("Debris"):AddItem(bv, 0.5)
end

FlingTab:CreateDropdown({ 
    Name = "Fling Player", 
    Options = PlayerList, 
    CurrentOption = "", 
    Callback = function(opt)
        if not opt or opt == "" then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == opt then
                FlingCharacter(p)
            end
        end
    end 
})

FlingTab:CreateButton({ Name = "Fling Axis", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == "Axis" then
            FlingCharacter(p)
        end
    end
end })

FlingTab:CreateButton({ Name = "Fling Allies", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == "Allies" then
            FlingCharacter(p)
        end
    end
end })

print("Project Mayhem | The Lost Front Mobile Loaded")