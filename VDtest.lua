-- [CURE] Violence District - Ryzen Chit v2.1 (Исправленный ESP)
-- Библиотека: Rayfield

loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- === СОСТОЯНИЯ ===
local state = {
    esp = false,
    fov = 70,
    godMode = false
}

-- === БИНДЫ ===
local binds = {
    esp = Enum.KeyCode.V,
    tacticalSprint = Enum.KeyCode.Z
}

-- === КОРРЕКТНОЕ ОПРЕДЕЛЕНИЕ МАНЬЯКА ===
local function isManiac(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    -- 1. Проверка через атрибут Killer (основной признак в The Cure)
    if humanoid:GetAttribute("Killer") == true then
        return true
    end
    
    -- 2. Проверка через команду (Team)
    if player.Team and player.Team.Name:lower():find("killer") then
        return true
    end
    
    -- 3. Проверка через специальный тег (если есть)
    if player:FindFirstChild("IsKiller") and player.IsKiller.Value == true then
        return true
    end
    
    return false
end

-- === GODMODE ===
local function enableGodMode()
    if not Character then return end
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetAttribute("NoDamage", true)
        humanoid.BreakJointsOnDeath = false
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if state.godMode then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

-- === TACTICAL SPRINT ===
local function toggleSprint()
    if not Character then return end
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = (humanoid.WalkSpeed == 16) and 25 or 16
    end
end

-- === ESP (ЗЕЛЁНЫЕ СУРВЫ, КРАСНЫЙ МАНЬЯК) ===
local espObjects = {}
local function updateESP()
    if not state.esp then
        for _, obj in pairs(espObjects) do
            if obj then obj.Visible = false end
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("PrimaryPart") then continue end
        
        local root = char.PrimaryPart
        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then continue end
        
        -- ТОЛЬКО ТЕПЕРЬ ОПРЕДЕЛЯЕМ МАНЬЯКА БЕЗ ОШИБОК
        local isManiacPlayer = isManiac(player)
        local color = isManiacPlayer and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
        
        if not espObjects[player] then
            espObjects[player] = Drawing.new("Box")
            espObjects[player].Thickness = 2
            espObjects[player].Transparency = 1
        end
        
        local espObj = espObjects[player]
        espObj.Color = color
        espObj.Visible = true
        espObj.Size = Vector2.new(100, 200)
        espObj.Position = Vector2.new(pos.X - 50, pos.Y - 100)
    end
end

-- === ИЗМЕНЕНИЕ FOV ===
local function setFOV(value)
    Camera.FieldOfView = value
end

-- === БИНДЫ ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == binds.esp then
        state.esp = not state.esp
        if not state.esp then
            for _, obj in pairs(espObjects) do
                if obj then obj.Visible = false end
            end
        end
    end
    
    if input.KeyCode == binds.tacticalSprint then
        toggleSprint()
    end
end)

-- === ЦИКЛ ===
RunService.Heartbeat:Connect(function()
    if state.godMode then enableGodMode() end
    if state.esp then updateESP() end
end)

-- === RAYFIELD GUI ===
local Window = Rayfield:CreateWindow({
    Name = "Ryzen | CURE Chit",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "Система Ryzen v2.1",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RyzenCure",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("General", nil)

MainTab:CreateToggle({
    Name = "ESP (V)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(value)
        state.esp = value
        if not value then
            for _, obj in pairs(espObjects) do
                if obj then obj.Visible = false end
            end
        end
    end
})

MainTab:CreateSlider({
    Name = "FOV",
    Range = {1, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = Camera.FieldOfView,
    Flag = "FOVSlider",
    Callback = function(value)
        Camera.FieldOfView = value
    end
})

MainTab:CreateToggle({
    Name = "GodMode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(value)
        state.godMode = value
        if value then enableGodMode() end
    end
})

Rayfield:Notify({
    Title = "Ryzen System",
    Content = "ESP исправлен. Маньяк определяется по атрибуту Killer, а не по оружию.",
    Duration = 5
})