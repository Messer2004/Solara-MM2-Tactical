local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({
    Name = "Violence District | Project Mayhem", 
    LoadingTitle = "Violence District", 
    LoadingSubtitle = "Killer & Survivor Edition", 
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Win:CreateTab("General")
local KillerTab = Win:CreateTab("Killer")
local SurvTab = Win:CreateTab("Survivor")

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local State = {
    ESP = false,
    BaseWS = 16,
    SprintWS = 25,
    SprintFOV = 110,
    DefaultFOV = 70,
    IsSprinting = false,
    NoCooldown = false,
    OneHit = false,
    HitboxSize = 2,
    FastRepair = false,
    NoSkillcheck = false,
    GodMode = false
}

MainTab:CreateToggle({
    Name = "ESP", 
    Callback = function(v) 
        State.ESP = v 
    end
})

MainTab:CreateSlider({
    Name = "WalkSpeed", 
    Range = {16, 100}, 
    Increment = 1,
    CurrentValue = 16, 
    Callback = function(v) 
        State.BaseWS = v 
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") and not State.IsSprinting then
            Plr.Character.Humanoid.WalkSpeed = v
        end
    end
})

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z then
        State.IsSprinting = true
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = State.SprintWS
            Cam.FieldOfView = State.SprintFOV
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Z then
        State.IsSprinting = false
        if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            Plr.Character.Humanoid.WalkSpeed = State.BaseWS
            Cam.FieldOfView = State.DefaultFOV
        end
    end
end)

KillerTab:CreateToggle({
    Name = "No Attack Cooldown", 
    Callback = function(v) 
        State.NoCooldown = v 
    end
})

KillerTab:CreateToggle({
    Name = "One Hit Kill", 
    Callback = function(v) 
        State.OneHit = v 
    end
})

KillerTab:CreateSlider({
    Name = "Hitbox Multiplier", 
    Range = {2, 15}, 
    Increment = 1,
    CurrentValue = 2, 
    Callback = function(v) 
        State.HitboxSize = v 
    end
})

SurvTab:CreateToggle({
    Name = "Fast Generator Repair", 
    Callback = function(v) 
        State.FastRepair = v 
    end
})

SurvTab:CreateToggle({
    Name = "Disable Skillchecks", 
    Callback = function(v) 
        State.NoSkillcheck = v 
    end
})

SurvTab:CreateToggle({
    Name = "GodMode (1000 HP)", 
    Callback = function(v) 
        State.GodMode = v 
        if v and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
            local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            hum.MaxHealth = 1000
            hum.Health = 1000
        end
    end
})

RS.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("ESP_Highlight")
            if State.ESP then
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.Parent = p.Character
                end
                h.Enabled = true
            elseif h then
                h.Enabled = false
            end

            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if State.HitboxSize > 2 then
                    hrp.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                else
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end
    
    if State.GodMode and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        if hum.Health < 1000 then
            hum.MaxHealth = 1000
            hum.Health = 1000
        end
    end
end)
