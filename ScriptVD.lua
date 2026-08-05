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

local Plr = game:GetService("Players").LocalPlayer
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

local function getPlayerColor(p)
    local char = p.Character
    if not char then return Color3.fromRGB(0, 255, 100) end
    
    local isKiller = false
    if p.Team and string.find(p.Team.Name:lower(), "killer") then
        isKiller = true
    elseif p:FindFirstChild("IsKiller") or char:FindFirstChild("IsKiller") or char:FindFirstChild("Killer") then
        isKiller = true
    else
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and (string.find(item.Name:lower(), "weapon") or string.find(item.Name:lower(), "knife") or string.find(item.Name:lower(), "kill")) then
                isKiller = true
                break
            end
        end
    end

    if isKiller then
        return Color3.fromRGB(255, 0, 0)
    else
        return Color3.fromRGB(0, 255, 100)
    end
end

MainTab:CreateToggle({
    Name = "ESP", 
    Callback = function(v) 
        State.ESP = v 
    end
})

MainTab:CreateSlider({
    Name = "WalkSpeed", 
    Range = {16, 100}, 
    CurrentValue = 16,
    Increment = 1,
    Suffix = " WS",
    Callback = function(v) 
        State.BaseWS = v 
    end
})

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Z then
        State.IsSprinting = true
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Z then
        State.IsSprinting = false
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
    Range = {2, 30}, 
    CurrentValue = 2,
    Increment = 1,
    Suffix = " Studs",
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
    Name = "GodMode + Anti-Knock", 
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
    if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        if State.IsSprinting or UIS:IsKeyDown(Enum.KeyCode.Z) then
            hum.WalkSpeed = State.SprintWS
            Cam.FieldOfView = math.clamp(Cam.FieldOfView + 2, State.DefaultFOV, State.SprintFOV)
        else
            hum.WalkSpeed = State.BaseWS
            if Cam.FieldOfView > State.DefaultFOV then
                Cam.FieldOfView = math.clamp(Cam.FieldOfView - 2, State.DefaultFOV, State.SprintFOV)
            end
        end
    end

    if State.HitboxSize > 2 and Plr.Character then
        local tool = Plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, part in pairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    part.CanCollide = false
                end
            end
        end
    end

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("ESP_Highlight")
            if not h then
                h = Instance.new("Highlight")
                h.Name = "ESP_Highlight"
                h.Parent = p.Character
            end
            h.Enabled = State.ESP
            h.FillColor = getPlayerColor(p)
        end
    end
    
    if State.GodMode and Plr.Character then
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health < 1000 then
                hum.MaxHealth = 1000
                hum.Health = 1000
            end
            
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            
            if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        
        if Plr.Character:FindFirstChild("Knocked") then
            Plr.Character.Knocked.Value = false
        end
        if Plr.Character:FindFirstChild("Downed") then
            Plr.Character.Downed.Value = false
        end
    end
end)
