local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Solara Tactical Menu",
    LoadingTitle = "Solara PC Edition",
    LoadingSubtitle = "by Messer",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("PC Features", "rbxassetid://4483362458")
local TeleportTab = Window:CreateTab("Teleports", "rbxassetid://4483362458")
local FlingSection = Window:CreateTab("Messer Fling (Anti-Toxic)", "rbxassetid://4483362458")

local Plr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

local EspActive, Flying = false, false
local FlySpeed = 50
local IsSprinting = false
local TargetFOV = 70
local ActiveTracks = {}
local InfJump = false
local FakeDeadActive = false
local AutoPickupActive = false
local AntiFlingActive = false

local FlingActive = false
local FlingAuraActive = false
local SelectedPlayerName = ""
local SavedPositionBeforeFling = nil

local SilentAimActive = false
local SilentAimFOV = 150
local ShowFOVCircle = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = SilentAimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false

task.spawn(function()
    while task.wait() do
        if Camera.FieldOfView ~= TargetFOV then
            Camera.FieldOfView = Camera.FieldOfView + (TargetFOV - Camera.FieldOfView) * 0.15
            if math.abs(Camera.FieldOfView - TargetFOV) < 0.1 then
                Camera.FieldOfView = TargetFOV
            end
        end
        if FOVCircle then
            FOVCircle.Visible = ShowFOVCircle
            FOVCircle.Radius = SilentAimFOV
            FOVCircle.Position = Camera.ViewportSize / 2
        end
    end
end)

local function GetRoleColor(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
            return Color3.fromRGB(255, 0, 0)
        elseif player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
            return Color3.fromRGB(0, 0, 255)
        end
    end
    return Color3.fromRGB(0, 255, 0)
end

local function GetPlayerByRole(role)
    for _, p in pairs(game.Players:GetChildren()) do
        if p ~= Plr and p.Character then
            if role == "Murderer" and (p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife"))) then
                return p
            elseif role == "Sheriff" and (p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun"))) then
                return p
            end
        end
    end
    return nil
end

local function GetClosestPlayerInFOV()
    local ClosestPlayer = nil
    local MaxDistance = SilentAimFOV

    for _, p in pairs(game.Players:GetChildren()) do
        if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local ScreenPos, IsOnScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if IsOnScreen then
                local DistanceToCenter = (Vector2.new(ScreenPos.X, ScreenPos.Y) - (Camera.ViewportSize / 2)).Magnitude
                if DistanceToCenter < MaxDistance then
                    MaxDistance = DistanceToCenter
                    ClosestPlayer = p
                end
            end
        end
    end
    return ClosestPlayer
end

local Namecall
Namecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if SilentAimActive and (tostring(Method) == "FindPartOnRayWithIgnoreList" or tostring(Method) == "Raycast") then
        local Target = GetClosestPlayerInFOV()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            if Args[1] and typeof(Args[1]) == "Ray" then
                local Origin = Args[1].Origin
                local Direction = (Target.Character.HumanoidRootPart.Position - Origin).Unit * 500
                Args[1] = Ray.new(Origin, Direction)
                return Namecall(Self, unpack(Args))
            end
        end
    end
    return Namecall(Self, ...)
end)

local function UpdateESP()
    for _, player in pairs(game.Players:GetChildren()) do
        if player ~= Plr and player.Character then
            local current = player.Character:FindFirstChild("EspMesser")
            if EspActive then
                local targetColor = GetRoleColor(player)
                if not current then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "EspMesser"
                    highlight.FillColor = targetColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = player.Character
                else
                    current.FillColor = targetColor
                end
            elseif not EspActive and current then
                current:Destroy()
            end
        end
    end
end

task.spawn(function()
    while task.wait() do
        local Char = Plr.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        
        if Flying or AntiFlingActive or FlingActive or FlingAuraActive then
            if Char then
                for _, part in pairs(Char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        if FlingAuraActive and HRP and Hum and Hum.Health > 0 then
            HRP.Velocity = Camera.CFrame.LookVector * 150
            HRP.RotVelocity = Vector3.new(0, 15000, 0)
        end
    end
end)

local function ToggleFly(State)
    Flying = State
    local Char = Plr.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local HRP = Char.HumanoidRootPart
    
    if Flying then
        local BV = Instance.new("BodyVelocity")
        BV.Name = "FlyVelocity"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Parent = HRP
        
        task.spawn(function()
            while Flying and task.wait() do
                if Char:FindFirstChild("Humanoid") then
                    BV.Velocity = Camera.CFrame.LookVector * FlySpeed
                end
            end
            if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
        end)
    else
        if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
    end
end

local function ActionFling(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local Char = Plr.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum or Hum.Health <= 0 then return end
    
    local TargetHRP = TargetPlayer.Character.HumanoidRootPart
    
    SavedPositionBeforeFling = HRP.CFrame
    FlingActive = true
    
    local BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BG.P = 5000
    BG.CFrame = HRP.CFrame
    BG.Parent = HRP
    
    local BP = Instance.new("BodyPosition")
    BP.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BP.P = 20000
    BP.D = 100
    BP.Parent = HRP

    for i = 1, 6 do
        if not TargetHRP or not TargetHRP.Parent then break end
        HRP.RotVelocity = Vector3.new(0, 15000, 0)
        BP.Position = (TargetHRP.CFrame * CFrame.new(0, 0, -0.2)).Position
        task.wait(0.04)
        BP.Position = (TargetHRP.CFrame * CFrame.new(0, 0, 0.2)).Position
        task.wait(0.04)
    end
    
    FlingActive = false
    BP:Destroy()
    BG:Destroy()
    
    HRP.Velocity = Vector3.new(0, 0, 0)
    HRP.RotVelocity = Vector3.new(0, 0, 0)
    task.wait(0.05)
    
    HRP.CFrame = SavedPositionBeforeFling
end

local function CheckAndPickupGun()
    if not AutoPickupActive then return end
    local Char = Plr.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local GunDrop = workspace:FindFirstChild("GunDrop")
    if GunDrop and GunDrop:IsA("BasePart") then
        local SavedCFrame = HRP.CFrame
        HRP.CFrame = GunDrop.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
    end
end

task.spawn(function()
    while task.wait(0.3) do
        if AutoPickupActive then CheckAndPickupGun() end
    end
end)

local function ToggleAnimation(AnimId, SlotName)
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not Hum or Hum.Health <= 0 then return end
    local Animator = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)
    
    if ActiveTracks[SlotName] then
        ActiveTracks[SlotName]:Stop()
        ActiveTracks[SlotName] = nil
        return
    end
    
    for slot, track in pairs(ActiveTracks) do
        track:Stop()
        ActiveTracks[slot] = nil
    end
    
    local Anim = Instance.new("Animation")
    Anim.AnimationId = "rbxassetid://" .. tostring(AnimId)
    
    local Success, Track = pcall(function() return Animator:LoadAnimation(Anim) end)
    if Success and Track then
        Track.Looped = true
        Track.Priority = Enum.AnimationPriority.Action
        Track:Play()
        ActiveTracks[SlotName] = Track
    end
end

local function ToggleFakeDeath()
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not HRP then return end

    FakeDeadActive = not FakeDeadActive
    if FakeDeadActive then
        for slot, track in pairs(ActiveTracks) do track:Stop() ActiveTracks[slot] = nil end
        Hum.PlatformStand = true
        HRP.CFrame = HRP.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
    else
        Hum.PlatformStand = false
        HRP.CFrame = HRP.CFrame * CFrame.Angles(math.rad(90), 0, 0)
    end
end

local function ShootAtCenter()
    local ViewportSize = Camera.ViewportSize
    local CenterX = ViewportSize.X / 2
    local CenterY = ViewportSize.Y / 2
    VirtualInputManager:SendMouseButtonEvent(CenterX, CenterY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(CenterX, CenterY, 0, false, game, 0)
end

local function SwitchSprint()
    if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        IsSprinting = not IsSprinting
        Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
        TargetFOV = IsSprinting and 110 or 70
    end
end

local function GetPlayerNamesList()
    local list = {}
    for _, p in pairs(game.Players:GetChildren()) do
        if p ~= Plr then table.insert(list, p.Name) end
    end
    return list
end

local function TeleportToPosition(cframe)
    local Char = Plr.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if HRP then
        HRP.Velocity = Vector3.new(0,0,0)
        HRP.CFrame = cframe
    end
end

TeleportTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        local Lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyLocation")
        if Lobby then 
            TeleportToPosition(Lobby.CFrame + Vector3.new(0, 3, 0)) 
        else
            TeleportToPosition(CFrame.new(-108, 138, 16))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Active Map",
    Callback = function()
        local NormalStages = workspace:FindFirstChild("NormalStages")
        if NormalStages and #NormalStages:GetChildren() > 0 then
            local Map = NormalStages:GetChildren()[1]
            local SpawnArea = Map:FindFirstChildOfClass("SpawnLocation") or Map:FindFirstChild("Spawn") or Map
            TeleportToPosition(SpawnArea.CFrame + Vector3.new(0, 5, 0))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Murderer",
    Callback = function()
        local target = GetPlayerByRole("Murderer")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            TeleportToPosition(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        local target = GetPlayerByRole("Sheriff")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            TeleportToPosition(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if SelectedPlayerName ~= "" then
            local target = game.Players:FindFirstChild(SelectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                TeleportToPosition(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
            end
        end
    end,
})

Tab:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = false,
    Callback = function(Value) SilentAimActive = Value end,
})

Tab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(Value) ShowFOVCircle = Value end,
})

Tab:CreateSlider({
    Name = "Silent Aim FOV Radius",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(Value) SilentAimFOV = Value end,
})

Tab:CreateToggle({
    Name = "Player ESP (Role Chams) [V]",
    CurrentValue = false,
    Callback = function(Value) EspActive = Value UpdateESP() end,
})

Tab:CreateToggle({
    Name = "Tactical Sprint [Z]",
    CurrentValue = false,
    Callback = function(Value)
        IsSprinting = Value
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
            TargetFOV = IsSprinting and 110 or 70
        end
    end,
})

Tab:CreateToggle({
    Name = "Flight Mode & NoClip [X]",
    CurrentValue = false,
    Callback = function(Value) ToggleFly(Value) end
})

FlingSection:CreateToggle({
    Name = "Enable Fling Engine Aura",
    CurrentValue = false,
    Callback = function(Value)
        FlingAuraActive = Value
        if not Value and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            Plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
        end
    end,
})

local PlayerDropdown = FlingSection:CreateDropdown({
    Name = "Select Target Nickname",
    Options = GetPlayerNamesList(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(Option) 
        SelectedPlayerName = typeof(Option) == "table" and (Option[1] or Option.Value) or Option 
    end,
})

FlingSection:CreateButton({
    Name = "Refresh Player List",
    Callback = function() PlayerDropdown:Refresh(GetPlayerNamesList(), true) end,
})

FlingSection:CreateButton({
    Name = "Fling Selected Player",
    Callback = function()
        if SelectedPlayerName ~= "" then
            local target = game.Players:FindFirstChild(SelectedPlayerName)
            ActionFling(target)
        end
    end,
})

FlingSection:CreateButton({
    Name = "Fling Murderer",
    Callback = function()
        local target = GetPlayerByRole("Murderer")
        if target then ActionFling(target) end
    end,
})

FlingSection:CreateButton({
    Name = "Fling Sheriff",
    Callback = function()
        local target = GetPlayerByRole("Sheriff")
        if target then ActionFling(target) end
    end,
})

Tab:CreateToggle({
    Name = "Anti-Fling Protection",
    CurrentValue = false,
    Callback = function(Value) AntiFlingActive = Value end,
})

Tab:CreateToggle({
    Name = "Auto-Pickup Gun",
    CurrentValue = false,
    Callback = function(Value) AutoPickupActive = Value end,
})

Tab:CreateSlider({
    Name = "WalkSpeed Customizer",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value) InfJump = Value end,
})

Tab:CreateToggle({
    Name = "Emote: King Nasir Dance [Numpad1]",
    CurrentValue = false,
    Callback = function(Value) ToggleAnimation(16912306733, "Nasir") end,
})

Tab:CreateToggle({
    Name = "Emote: Nervy Dance [Numpad2]",
    CurrentValue = false,
    Callback = function(Value) ToggleAnimation(14349258288, "Nervy") end,
})

Tab:CreateToggle({
    Name = "Fake Death Mode [Numpad3]",
    CurrentValue = false,
    Callback = function(Value) ToggleFakeDeath() end,
})

Tab:CreateButton({
    Name = "Instant Center Shot",
    Callback = function() ShootAtCenter() end,
})

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        EspActive = not EspActive
        UpdateESP()
    elseif input.KeyCode == Enum.KeyCode.X then
        ToggleFly(not Flying)
    elseif input.KeyCode == Enum.KeyCode.Z then
        SwitchSprint()
    elseif input.KeyCode == Enum.KeyCode.KeypadOne then
        ToggleAnimation(16912306733, "Nasir")
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
        ToggleAnimation(14349258288, "Nervy")
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then
        ToggleFakeDeath()
    elseif input.KeyCode == Enum.KeyCode.K then
        local core = game:GetService("CoreGui")
        local rf = core:FindFirstChild("Rayfield") or core:FindFirstChild("RayfieldGui")
        if rf then rf.Enabled = not rf.Enabled end
    end
end)

UIS.JumpRequest:Connect(function()
    if InfJump and Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
        Plr.Character.Humanoid:ChangeState("Jumping")
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if EspActive then UpdateESP() end
    end
end)

Rayfield:Notify({
    Title = "Executed",
    Content = "Messer PC Build Updated",
    Duration = 3,
    Image = 4483362458,
})
