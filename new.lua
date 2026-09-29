local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Project Mayhem | Messer2004",
    Icon = "crosshair",
    Author = "Messer2004",
    Folder = "ProjectMayhemConfig",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,
})

local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local TeleTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local TrollTab = Window:Tab({ Title = "Trolling", Icon = "zap" })

local MainSec = MainTab:Section({ Title = "Main Features" })
local TeleSec = TeleTab:Section({ Title = "Teleportation & Utility" })
local TrollSec = TrollTab:Section({ Title = "Fling Controls" })

local Plr = game:GetService("Players").LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local State = {
    ESP = false,
    BaseWS = 16,
    InfJump = false,
    SilentAim = false,
    FOVRadius = 50,
    TargetPlayer = nil
}

local FOV = Drawing.new("Circle")
FOV.Visible = false
FOV.Radius = State.FOVRadius
FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Thickness = 1.5

local function getCol(p)
    local c = p.Character
    if c and (c:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 0, 0) -- Red Murder
    elseif c and (c:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then
        return Color3.fromRGB(0, 100, 255) -- Blue Sheriff
    else
        return Color3.fromRGB(0, 255, 0) -- Green Innocents
    end
end

local function getMurderer()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            if p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then
                return p
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            if p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun") then
                return p
            end
        end
    end
    return nil
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
        h.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))
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
        local prevPos = h.CFrame
        h.CFrame = gunPart.CFrame
        task.wait(0.15)
        h.CFrame = prevPos
    end
end

-- Silent Aim (Targeting ONLY Murderer within FOV)
local rawmetatable = getrawmetatable(game)
local oldNamecall = rawmetatable.__namecall
setreadonly(rawmetatable, false)

rawmetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if State.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast" or method == "FindPartOnRay") then
        local murd = getMurderer()
        if murd and murd.Character and murd.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Cam:WorldToViewportPoint(murd.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist <= FOV.Radius then
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

-- Main Loop
RS.RenderStepped:Connect(function()
    FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)

    -- ESP
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("H") or Instance.new("Highlight", p.Character)
            h.Name = "H"
            h.Enabled = State.ESP
            h.FillColor = getCol(p)
        end
    end

    -- WalkSpeed
    if Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Plr.Character:FindFirstChildOfClass("Humanoid")
        if hum.WalkSpeed ~= State.BaseWS then
            hum.WalkSpeed = State.BaseWS
        end
    end
end)

-- Jump Request for InfJump
game:GetService("UserInputService").JumpRequest:Connect(function()
    if State.InfJump and Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid") then
        Plr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Hotkey 'V' for Grab Gun
UIS.InputBegan:Connect(function(input, g)
    if g then return end
    if input.KeyCode == Enum.KeyCode.V then
        grabGunAction()
    end
end)

-- 1. MAIN TAB
MainSec:Toggle({
    Title = "ESP",
    Desc = "Red: Murder | Blue: Sheriff | Green: Innocent",
    Value = false,
    Callback = function(v) State.ESP = v end
})

MainSec:Slider({
    Title = "WalkSpeed",
    Desc = "Adjust character movement speed",
    Min = 16,
    Max = 120,
    Value = 16,
    Callback = function(v) State.BaseWS = v end
})

MainSec:Toggle({
    Title = "Infinity Jump",
    Desc = "Jump continuously in the air",
    Value = false,
    Callback = function(v) State.InfJump = v end
})

MainSec:Toggle({
    Title = "Silent Aim",
    Desc = "Shots target ONLY Murderer in FOV",
    Value = false,
    Callback = function(v)
        State.SilentAim = v
        FOV.Visible = v
    end
})

MainSec:Slider({
    Title = "FOV Size",
    Desc = "Adjust Silent Aim FOV radius",
    Min = 10,
    Max = 300,
    Value = 50,
    Callback = function(v)
        State.FOVRadius = v
        FOV.Radius = v
    end
})

-- 2. TELEPORT TAB
TeleSec:Button({
    Title = "TP to Murder",
    Desc = "Teleport directly to Murderer",
    Callback = function()
        local m = getMurderer()
        if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = m.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleSec:Button({
    Title = "TP to Sheriff",
    Desc = "Teleport directly to Sheriff",
    Callback = function()
        local s = getSheriff()
        if s and s.Character and s.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = s.Character.HumanoidRootPart.CFrame
        end
    end
})

local PlayerDropdown = TeleSec:Dropdown({
    Title = "Select Target",
    Desc = "Select player from server",
    Values = {"None"},
    Value = "None",
    Callback = function(option)
        local name = type(option) == "table" and option[1] or option
        State.TargetPlayer = game.Players:FindFirstChild(name)
    end
})

TeleSec:Button({
    Title = "Refresh Players",
    Desc = "Update list of available players",
    Callback = function()
        local list = {}
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Plr then table.insert(list, p.Name) end
        end
        PlayerDropdown:Refresh(list)
    end
})

TeleSec:Button({
    Title = "TP to Target",
    Desc = "Teleport to selected player from dropdown",
    Callback = function()
        if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
            Plr.Character.HumanoidRootPart.CFrame = State.TargetPlayer.Character.HumanoidRootPart.CFrame
        end
    end
})

TeleSec:Button({
    Title = "Grab Gun (Or Press 'V')",
    Desc = "Teleport to dropped gun and back",
    Callback = function()
        grabGunAction()
    end
})

-- 3. TROLLING TAB
TrollSec:Button({
    Title = "Fling Murder",
    Desc = "Push Murderer out of bounds",
    Callback = function()
        local m = getMurderer()
        if m then runFling(m) end
    end
})

TrollSec:Button({
    Title = "Fling Sheriff",
    Desc = "Push Sheriff out of bounds",
    Callback = function()
        local s = getSheriff()
        if s then runFling(s) end
    end
})

TrollSec:Button({
    Title = "Fling Target",
    Desc = "Push selected target from dropdown",
    Callback = function()
        if State.TargetPlayer then runFling(State.TargetPlayer) end
    end
})
