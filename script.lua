local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Project Mayhem",
   LoadingTitle = "Project Mayhem",
   LoadingSubtitle = "by Messer2004",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Main", nil)
local TeleportTab = Window:CreateTab("Teleports", nil)
local FlingSection = Window:CreateTab("Fling", nil)

local espEnabled = false
local flyEnabled = false
local walkSpeedNormal = 16
local walkSpeedSprint = 25
local isSprinting = false
local infJumpEnabled = false
local autoPickupEnabled = false
local flyConnection

local silentAimEnabled = false
local silentAimFOV = 150
local showFOVCircle = false

local flingActive = false
local flingAuraActive = false
local selectedPlayerName = ""
local savedPosBeforeFling = nil

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = silentAimFOV
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Visible = showFOVCircle
        FOVCircle.Radius = silentAimFOV
        FOVCircle.Position = Camera.ViewportSize / 2
    end
end)

local function GetPlayerColor(p)
    if not p then return Color3.fromRGB(0, 255, 0) end
    local char = p.Character
    local bp = p:FindFirstChild("Backpack")
    if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 0, 0)
    elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return Color3.fromRGB(0, 0, 255)
    end
    return Color3.fromRGB(0, 255, 0)
end

local function GetPlayerByRole(role)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
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
    local MaxDistance = silentAimFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
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

    if silentAimEnabled and (tostring(Method) == "FindPartOnRayWithIgnoreList" or tostring(Method) == "Raycast") then
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

-- Поток NoClip + Фиксация скорости (Защита от падения под карту)
task.spawn(function()
    while task.wait() do
        local Char = LocalPlayer.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        
        -- Постоянный NoClip во время Fly, Атаки или Ауры
        if flyEnabled or flingActive or flingAuraActive then
            if Char then
                for _, part in pairs(Char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        if flingAuraActive and HRP and Hum and Hum.Health > 0 then
            HRP.Velocity = Camera.CFrame.LookVector * 150
            HRP.RotVelocity = Vector3.new(0, 15000, 0)
        end
    end
end)

-- Авто-подбор выпавшего пистолета
task.spawn(function()
    while task.wait(0.3) do
        if autoPickupEnabled then
            local Char = LocalPlayer.Character
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            if HRP then
                local GunDrop = workspace:FindFirstChild("GunDrop")
                if GunDrop and GunDrop:IsA("BasePart") then
                    local currentPos = HRP.CFrame
                    HRP.CFrame = GunDrop.CFrame + Vector3.new(0, 1, 0)
                    task.wait(0.1)
                    HRP.CFrame = currentPos
                end
            end
        end
    end
end)

local function ActionFling(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local Char = LocalPlayer.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if not HRP or not Hum or Hum.Health <= 0 then return end
    
    local TargetHRP = TargetPlayer.Character.HumanoidRootPart
    
    savedPosBeforeFling = HRP.CFrame -- Сейвим позицию
    flingActive = true
    
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
    
    flingActive = false
    BP:Destroy()
    BG:Destroy()
    
    HRP.Velocity = Vector3.new(0, 0, 0)
    HRP.RotVelocity = Vector3.new(0, 0, 0)
    task.wait(0.05)
    
    HRP.CFrame = savedPosBeforeFling -- Возвращаем назад
end

local function GetPlayerNamesList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local function TeleportToPosition(cframe)
    local Char = LocalPlayer.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if HRP then
        HRP.Velocity = Vector3.new(0,0,0)
        HRP.CFrame = cframe
    end
end

local function ToggleESP(Value)
    espEnabled = Value
    if espEnabled then
        RunService:BindToRenderStep("MesserESPUpdate", Enum.RenderPriority.Camera.Value, function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = player.Character:FindFirstChild("MesserHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "MesserHighlight"
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = player.Character
                    end
                    highlight.FillColor = GetPlayerColor(player)
                    highlight.OutlineColor = highlight.FillColor
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("MesserESPUpdate")
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("MesserHighlight") then
                player.Character.MesserHighlight:Destroy()
            end
        end
    end
end

local function ToggleFly(Value)
    flyEnabled = Value
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if flyEnabled and root and humanoid then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "MesserFlyBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root
        
        flyConnection = RunService.Heartbeat:Connect(function()
            if root and humanoid and flyEnabled then
                if humanoid.MoveDirection.Magnitude > 0 then
                    bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 45
                  else
                      bv.Velocity = Vector3.new(0, 0, 0)
                  end
              end
          end)
      else
          if flyConnection then flyConnection:Disconnect() end
          if root then
              local bv = root:FindFirstChild("MesserFlyBV")
              if bv then bv:Destroy() end
          end
      end
end

local function ToggleSprint(State)
    isSprinting = State
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = isSprinting and walkSpeedSprint or walkSpeedNormal
    end
end

local EspUiToggle = Tab:CreateToggle({
   Name = "Player ESP [V]",
   CurrentValue = false,
   Callback = function(Value) ToggleESP(Value) end,
})

local FlyUiToggle = Tab:CreateToggle({
   Name = "Flight Mode [X]",
   CurrentValue = false,
   Callback = function(Value) ToggleFly(Value) end,
})

local SprintUiToggle = Tab:CreateToggle({
   Name = "Tactical Sprint [Z]",
   CurrentValue = false,
   Callback = function(Value) ToggleSprint(Value) end,
})

Tab:CreateSlider({
    Name = "WalkSpeed Customizer",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        walkSpeedNormal = Value
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and not isSprinting then hum.WalkSpeed = Value end
    end
})

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value) infJumpEnabled = Value end,
})

Tab:CreateToggle({
    Name = "Auto-Pickup Gun",
    CurrentValue = false,
    Callback = function(Value) autoPickupEnabled = Value end,
})

Tab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(Value) silentAimEnabled = Value end,
})

Tab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Callback = function(Value) showFOVCircle = Value end,
})

Tab:CreateSlider({
    Name = "Aim FOV Radius",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(Value) silentAimFOV = Value end,
})

-- Вкладка: Телепорты
TeleportTab:CreateButton({
    Name = "TP to Lobby",
    Callback = function()
        local Lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyLocation")
        TeleportToPosition(Lobby and (Lobby.CFrame + Vector3.new(0, 3, 0)) or CFrame.new(-108, 138, 16))
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Murderer",
    Callback = function()
        local target = GetPlayerByRole("Murderer")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            TeleportToPosition(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Sheriff",
    Callback = function()
        local target = GetPlayerByRole("Sheriff")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            TeleportToPosition(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end,
})

-- Вкладка: Флинг движок
FlingSection:CreateToggle({
    Name = "Fling Aura (Camera)",
    CurrentValue = false,
    Callback = function(Value)
        flingAuraActive = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
        end
    end,
})

local PlayerDropdown = FlingSection:CreateDropdown({
    Name = "Select Target",
    Options = GetPlayerNamesList(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(Option) 
        selectedPlayerName = typeof(Option) == "table" and (Option[1] or Option.Value) or Option 
    end,
})

FlingSection:CreateButton({
    Name = "Refresh Target List",
    Callback = function() PlayerDropdown:Refresh(GetPlayerNamesList(), true) end,
})

FlingSection:CreateButton({
    Name = "Fling Selected Target",
    Callback = function()
        if selectedPlayerName ~= "" then
            local target = Players:FindFirstChild(selectedPlayerName)
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

-- Обработка биндов
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        local newState = not espEnabled
        EspUiToggle:Set(newState)
    elseif input.KeyCode == Enum.KeyCode.X then
        local newState = not flyEnabled
        FlyUiToggle:Set(newState)
    elseif input.KeyCode == Enum.KeyCode.Z then
        local newState = not isSprinting
        SprintUiToggle:Set(newState)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

Rayfield:Notify({
    Title = "Executed",
    Content = "Project Mayhem Loaded",
    Duration = 3
})
