local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

local ESP_ON = false
local FLY_ON = false
local INF_JUMP = false
local GOD_MODE = false
local NO_FOG = false

local sg = Instance.new("ScreenGui")
sg.Name = "M"
sg.Parent = game:GetService("CoreGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 250)
f.Position = UDim2.new(0.5, -100, 0.5, -125)
f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
f.BackgroundTransparency = 0.2
f.Active = true
f.Draggable = true
f.Parent = sg

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 30)
t.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
t.Text = "PM"
t.TextColor3 = Color3.new(1, 1, 1)
t.TextScaled = true
t.Parent = f

local c = Instance.new("TextButton")
c.Size = UDim2.new(0, 25, 0, 25)
c.Position = UDim2.new(1, -30, 0, 2)
c.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
c.Text = "X"
c.TextColor3 = Color3.new(1, 1, 1)
c.Parent = f
c.MouseButton1Click:Connect(function() sg:Destroy() end)

local sc = Instance.new("ScrollingFrame")
sc.Size = UDim2.new(1, 0, 1, -30)
sc.Position = UDim2.new(0, 0, 0, 30)
sc.BackgroundTransparency = 1
sc.CanvasSize = UDim2.new(0, 0, 0, 400)
sc.Parent = f

local function tog(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.Text = text .. " [OFF]"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.Parent = sc
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = text .. (s and " [ON]" or " [OFF]")
        if text == "ESP" then
            ESP_ON = s
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("E")
                    if not h then
                        h = Instance.new("BoxHandleAdornment")
                        h.Name = "E"
                        h.Size = Vector3.new(4, 5, 1)
                        h.Adornee = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                        h.AlwaysOnTop = true
                        h.Color3 = p.Team and (p.Team.Name == "Axis" and Color3.new(1,0,0) or Color3.new(0,0.5,1)) or Color3.new(0,1,0)
                        h.Transparency = 0.5
                        h.Parent = p.Character
                    end
                    h.Enabled = s
                end
            end
        elseif text == "Fly" then
            FLY_ON = s
            if s and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "F"
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = LP.Character.HumanoidRootPart
            elseif LP.Character then
                local bv = LP.Character:FindFirstChild("F")
                if bv then bv:Destroy() end
            end
        elseif text == "Inf Jump" then
            INF_JUMP = s
        elseif text == "God Mode" then
            GOD_MODE = s
            if s and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                LP.Character.Humanoid.MaxHealth = 999
                LP.Character.Humanoid.Health = 999
            end
        elseif text == "No Fog" then
            NO_FOG = s
            Lighting.FogEnd = s and 99999 or 1000
        end
    end)
    return b
end

local y = 10
tog("ESP", y) y = y + 35
tog("Fly", y) y = y + 35
tog("Inf Jump", y) y = y + 35
tog("God Mode", y) y = y + 35
tog("No Fog", y) y = y + 35
sc.CanvasSize = UDim2.new(0, 0, 0, y + 50)

RS.Heartbeat:Connect(function()
    if not LP.Character then return end
    if FLY_ON then
        local bv = LP.Character:FindFirstChild("F")
        if bv then
            local m = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then m = m + Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then m = m - Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then m = m - Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then m = m + Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then m = m + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then m = m - Vector3.new(0, 1, 0) end
            bv.Velocity = m * 50
        end
    end
    if INF_JUMP then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h and UIS:IsKeyDown(Enum.KeyCode.Space) then
            h.JumpPower = 150
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if GOD_MODE then
        local h = LP.Character:FindFirstChildOfClass("Humanoid")
        if h then
            h.MaxHealth = 999
            if h.Health < 999 then h.Health = 999 end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.V then
        ESP_ON = not ESP_ON
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h = p.Character:FindFirstChild("E")
                if h then h.Enabled = ESP_ON end
            end
        end
    end
    if i.KeyCode == Enum.KeyCode.X then
        FLY_ON = not FLY_ON
        if FLY_ON and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "F"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Parent = LP.Character.HumanoidRootPart
        elseif LP.Character then
            local bv = LP.Character:FindFirstChild("F")
            if bv then bv:Destroy() end
        end
    end
end)

print("PM Loaded")