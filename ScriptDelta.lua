local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Mobile Tactical Menu",
    LoadingTitle = "Delta Edition",
    LoadingSubtitle = "by Messer",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Main Features", 4483362458)

local Plr = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

local EspActive = false
local Flying = false
local FlySpeed = 50
local IsSprinting = false
local TargetFOV = 70
local ActiveTracks = {}
local InfJump = false

-- Переменные для мобильного Fling движка
local FlingActive = false
local SelectedPlayerName = ""

task.spawn(function()
    while task.wait() do
        if Camera.FieldOfView ~= TargetFOV then
            Camera.FieldOfView = Camera.FieldOfView + (TargetFOV - Camera.FieldOfView) * 0.15
            if math.abs(Camera.FieldOfView - TargetFOV) < 0.1 then
                Camera.FieldOfView = TargetFOV
            end
        end
    end
end)

local function GetRoleColor(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
            return Color3.fromRGB(255, 0, 0) -- Убийца
        elseif player.Character:FindFirstChild("Gun") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Gun")) then
            return Color3.fromRGB(0, 0, 255) -- Шериф
        end
    end
    return Color3.fromRGB(0, 255, 0)
end

-- Поиск игрока по роли в MM2
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

-- Цикл физики: NoClip при полёте и сам Fling
task.spawn(function()
    while task.wait() do
        local Char = Plr.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        
        if Flying or FlingActive then
            if Char then
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        -- Механика закрутки физики
        if FlingActive and HRP then
            local Velocity = HRP.Velocity
            HRP.Velocity = Vector3.new(500, 500, 500)
            HRP.RotVelocity = Vector3.new(0, 5000, 0)
            task.wait(0.01)
            HRP.Velocity = Velocity
        end
    end
end)

-- Функция атаки флингом (Телепорт -> Удар -> Возврат)
local function ActionFling(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        Rayfield:Notify({Title = "Ошибка", Content = "Цель не найдена или мертва", Duration = 2})
        return 
    end
    
    local Char = Plr.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local TargetHRP = TargetPlayer.Character.HumanoidRootPart
    local SavedCFrame = HRP.CFrame
    
    FlingActive = true
    HRP.CFrame = TargetHRP.CFrame + Vector3.new(0, 1, 0)
    task.wait(0.3)
    HRP.CFrame = TargetHRP.CFrame + Vector3.new(0, -1, 0)
    task.wait(0.2)
    FlingActive = false
    HRP.CFrame = SavedCFrame
end

local function ToggleAnimation(AnimId, SlotName)
    local Char = Plr.Character
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local Animator = Hum and Hum:FindFirstChildOfClass("Animator")
    
    if not Animator then return end
    
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
    
    local Success, Track = pcall(function()
        return Animator:LoadAnimation(Anim)
    end)
    
    if Success and Track then
        Track.Looped = true
        Track:Play()
        ActiveTracks[SlotName] = Track
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

-- Получение списка ников для Dropdown
local function GetPlayerNamesList()
    local list = {}
    for _, p in pairs(game.Players:GetChildren()) do
        if p ~= Plr then
            table.insert(list, p.Name)
        end
    end
    return list
end

--- ИНТЕРФЕЙС ОСНОВНОЙ ВКЛАДКИ ---

Tab:CreateToggle({
    Name = "Player ESP (Role Chams)",
    CurrentValue = false,
    Callback = function(Value)
        EspActive = Value
        UpdateESP()
    end,
})

Tab:CreateToggle({
    Name = "Tactical Sprint",
    CurrentValue = false,
    Callback = function(Value)
        IsSprinting = Value
        if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = IsSprinting and 25 or 16
            TargetFOV = IsSprinting and 110 or 70
        end
    end,
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
    Name = "Flight Mode & NoClip",
    CurrentValue = false,
    Callback = function(Value)
        Flying = Value
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
                        local LookDir = Camera.CFrame.LookVector
                        local MoveDir = Char.Humanoid.MoveDirection
                        
                        if MoveDir.Magnitude > 0 then
                            BV.Velocity = LookDir * FlySpeed
                        else
                            BV.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                    
                    for _, part in pairs(Char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
            end)
        else
            if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
        end
    end,
})

--- ВКЛАДКА FLING МЕСТИ НА МОБИЛКАХ ---
local FlingTab = Window:CreateTab("Messer Fling (Mobile)", 4483362458)

FlingTab:CreateToggle({
    Name = "Enable Fling Aura (Manual)",
    CurrentValue = false,
    Callback = function(Value)
        FlingActive = Value
    end,
})

local PlayerDropdown = FlingTab:CreateDropdown({
    Name = "Select Target Nickname",
    Options = GetPlayerNamesList(),
    CurrentOption = "",
    MultipleOptions = false,
    Callback = function(Option)
        SelectedPlayerName = Option[1] or Option
    end,
})

FlingTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        PlayerDropdown:Refresh(GetPlayerNamesList(), true)
    end,
})

FlingTab:CreateButton({
    Name = "Fling Selected Player",
    Callback = function()
        if SelectedPlayerName ~= "" then
            local target = game.Players:FindFirstChild(SelectedPlayerName)
            ActionFling(target)
        else
            Rayfield:Notify({Title = "Внимание", Content = "Выберите ник из списка!", Duration = 2})
        end
    end,
})

FlingTab:CreateButton({
    Name = "⚡ Fling Murderer (Убийца)",
    Callback = function()
        local target = GetPlayerByRole("Murderer")
        if target then ActionFling(target) else Rayfield:Notify({Title = "Инфо", Content = "Мардер не обнаружен", Duration = 2}) end
    end,
})

FlingTab:CreateButton({
    Name = "⚡ Fling Sheriff (Шериф)",
    Callback = function()
        local target = GetPlayerByRole("Sheriff")
        if target then ActionFling(target) else Rayfield:Notify({Title = "Инфо", Content = "Шериф не обнаружен", Duration = 2}) end
    end,
})

--- ВОЗВРАТ К СТАНДАРТНЫМ КНОПКАМ ---

Tab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        InfJump = Value
    end,
})

Tab:CreateToggle({
    Name = "Emote: Nervy Dance",
    CurrentValue = false,
    Callback = function(Value)
        ToggleAnimation(14349258288, "Nervy")
    end,
})

Tab:CreateToggle({
    Name = "Emote: King Nasir Dance",
    CurrentValue = false,
    Callback = function(Value)
        ToggleAnimation(16912306733, "Nasir")
    end,
})

Tab:CreateButton({
    Name = "Instant Center Shot",
    Callback = function()
        ShootAtCenter()
    end,
})

Tab:CreateButton({
    Name = "Minimize Menu",
    Callback = function()
        Rayfield:Destroy()
    end,
})

game:GetService("Subtitles" or "UserInputService").JumpRequest:Connect(function()
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
    Content = "Mobile Build Updated with Fling System",
    Duration = 3,
    Image = 4483362458,
})
