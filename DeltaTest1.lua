-- Project Mayhem | Delta Mobile Edition
-- By Messer_2004 | Fully Optimized for Delta

loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Library:CreateWindow({
    Name = "Project Mayhem",
    LoadingTitle = "Project Mayhem",
    LoadingSubtitle = "By Messer_2004 | Delta",
    ConfigurationSaving = { Enabled = true, FolderName = "ProjectMayhem_Delta" }
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- States
local State = {
    ESP = false,
    SilentAim = false,
    SilentRadius = 50,
    Walkspeed = 16,
    InfJump = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    AntiFling = false,
    GodMode = false,
    Target = nil,
    Sprint = false
}

local ESPObjects = {}
local FlyBV = nil
local FlyConnection = nil
local NoclipConnection = nil
local InfJumpConnection = nil
local GodModeConnection = nil
local AntiFlingConnection = nil

-- Functions
local function GetPlayerTeam(player)
    local char = player.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return "Murderer"
    elseif char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

local function CreateESP(player)
    if player == LP or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local team = GetPlayerTeam(player)
    local color = team == "Murderer" and Color3.new(1, 0, 0) or team == "Sheriff" and Color3.new(0, 0.3, 1) or Color3.new(0, 1, 0)
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Size = Vector3.new(4, 5, 1)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 0
    box.Color3 = color
    box.Transparency = 0.5
    box.Parent = hrp
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = player.Character
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Parent = player.Character
    
    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "ESP_Name"
    nameTag.Size = UDim2.new(0, 200, 0, 50)
    nameTag.Adornee = hrp
    nameTag.AlwaysOnTop = true
    nameTag.Parent = hrp
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Parent = nameTag
    
    table.insert(ESPObjects, box)
    table.insert(ESPObjects, highlight)
    table.insert(ESPObjects, nameTag)
end

local function RemoveESP()
    for _, v in pairs(ESPObjects) do
        v:Destroy()
    end
    ESPObjects = {}
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

local function GetClosestMurderer()
    local closest, dist = nil, State.SilentRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local team = GetPlayerTeam(p)
            if team == "Murderer" then
                local mag = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if mag < dist then
                    closest, dist = p, mag
                end
            end
        end
    end
    return closest
end

local function TeleportTo(pos)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function FlingCharacter(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = target.Character.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = CFrame.new(hrp.Position, hrp.Position + Vector3.new(500, 200, 500)).LookVector * 9999
    bv.Parent = hrp
    game:GetService("Debris"):AddItem(bv, 0.5)
end

local function GetSheriffGun()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Gun" and v:IsA("Tool") then
            if LP.Character then
                LP.Character.Humanoid:EquipTool(v)
            end
            return
        end
    end
end

local function KillAll()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            p.Character.Humanoid.Health = 0
        end
    end
end

local function ToggleFly()
    State.Fly = not State.Fly
    State.Noclip = State.Fly
    if State.Fly and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Name = "FlyBV"
        FlyBV.MaxForce = Vector3.new(4000, 4000, 4000)
        FlyBV.Velocity = Vector3.new(0, 0, 0)
        FlyBV.Parent = LP.Character.HumanoidRootPart
    elseif LP.Character then
        local bv = LP.Character:FindFirstChild("FlyBV")
        if bv then bv:Destroy() end
        FlyBV = nil
    end
end

-- Character Added
LP.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    hum.WalkSpeed = State.Walkspeed
    if State.GodMode then
        hum.MaxHealth = 999
        hum.Health = 999
    end
end)

-- Clean up old connections
local function CleanupConnections()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    if InfJumpConnection then InfJumpConnection:Disconnect() InfJumpConnection = nil end
    if GodModeConnection then GodModeConnection:Disconnect() GodModeConnection = nil end
    if AntiFlingConnection then AntiFlingConnection:Disconnect() AntiFlingConnection = nil end
end

-- Setup connections
CleanupConnections()

-- Fly loop
FlyConnection = RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if State.Fly and FlyBV then
        local move = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        FlyBV.Velocity = move * State.FlySpeed
    end
end)

-- Noclip loop
NoclipConnection = RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if State.Noclip then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Infinity Jump loop
InfJumpConnection = RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if State.InfJump then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum.JumpPower = 150
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- God Mode loop
GodModeConnection = RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if State.GodMode then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 999
            if hum.Health < 999 then hum.Health = 999 end
        end
    end
end)

-- Anti-Fling loop
AntiFlingConnection = RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if State.AntiFling and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if hrp.Velocity.magnitude > 100 then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Silent Aim hook
local oldMouse
oldMouse = hookmetamethod(game, "__index", function(self, key)
    if State.SilentAim and self == LP and key == "Mouse" then
        local target = GetClosestMurderer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            return {Target = target.Character.HumanoidRootPart}
        end
    end
    return oldMouse(self, key)
end)

-- Binds
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        ToggleESP()
    end
    if input.KeyCode == Enum.KeyCode.X then
        ToggleFly()
    end
    if input.KeyCode == Enum.KeyCode.G then
        GetSheriffGun()
    end
    if input.KeyCode == Enum.KeyCode.K then
        KillAll()
    end
    if input.KeyCode == Enum.KeyCode.F then
        if State.Target then
            FlingCharacter(State.Target)
        end
    end
    if input.KeyCode == Enum.KeyCode.B then
        TeleportTo(Vector3.new(0, 10, 0))
    end
    if input.KeyCode == Enum.KeyCode.L then
        TeleportTo(Vector3.new(0, 10, 0))
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

Main:CreateToggle({ Name = "Silent Aim", Default = false, Callback = function(v) State.SilentAim = v end })

Main:CreateSlider({
    Name = "Silent Radius",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v) State.SilentRadius = v end
})

Main:CreateSlider({
    Name = "Walkspeed",
    Min = 16,
    Max = 120,
    Default = 16,
    Callback = function(v)
        State.Walkspeed = v
        if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = v
        end
    end
})

Main:CreateToggle({ Name = "Infinity Jump", Default = false, Callback = function(v) State.InfJump = v end })

Main:CreateButton({ Name = "Fly + Noclip (X)", Callback = ToggleFly })

Main:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(v) State.FlySpeed = v end
})

Main:CreateToggle({ Name = "Anti-Fling", Default = false, Callback = function(v) State.AntiFling = v end })

Main:CreateToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(v)
        State.GodMode = v
        if v and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character.Humanoid.MaxHealth = 999
            LP.Character.Humanoid.Health = 999
        end
    end
})

Main:CreateButton({ Name = "Kill All (K)", Callback = KillAll })

-- Teleports Tab
local Teleports = Window:CreateTab({ Name = "Teleports", Icon = "map-pin" })

Teleports:CreateButton({ Name = "Teleport to Map (B)", Callback = function()
    TeleportTo(Vector3.new(0, 10, 0))
end })

Teleports:CreateButton({ Name = "Teleport to Lobby (L)", Callback = function()
    TeleportTo(Vector3.new(0, 10, 0))
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
                TeleportTo(p.Character.HumanoidRootPart.Position)
                State.Target = p
            end
        end
    end
})

Teleports:CreateButton({ Name = "Teleport to Sheriff", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetPlayerTeam(p) == "Sheriff" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            TeleportTo(p.Character.HumanoidRootPart.Position)
            State.Target = p
        end
    end
end })

Teleports:CreateButton({ Name = "Teleport to Murderer", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetPlayerTeam(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            TeleportTo(p.Character.HumanoidRootPart.Position)
            State.Target = p
        end
    end
end })

Teleports:CreateButton({ Name = "Pickup Sheriff Gun (G)", Callback = GetSheriffGun })

-- Fling Tab
local FlingTab = Window:CreateTab({ Name = "Fling", Icon = "target" })

FlingTab:CreateDropdown({
    Name = "Fling Player (F)",
    Options = PlayerList,
    CurrentOption = "",
    Callback = function(opt)
        if not opt or opt == "" then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == opt then
                State.Target = p
                FlingCharacter(p)
            end
        end
    end
})

FlingTab:CreateButton({ Name = "Fling Sheriff", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetPlayerTeam(p) == "Sheriff" then
            FlingCharacter(p)
        end
    end
end })

FlingTab:CreateButton({ Name = "Fling Murderer", Callback = function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetPlayerTeam(p) == "Murderer" then
            FlingCharacter(p)
        end
    end
end })

print("Project Mayhem | Delta Mobile Loaded")