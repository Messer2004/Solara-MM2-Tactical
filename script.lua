local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Final Build", LoadingSubtitle = "Stable", ConfigurationSaving = {Enabled = false}})
local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plr, Cam, RS, UIS = game:GetService("Players").LocalPlayer, workspace.CurrentCamera, game:GetService("RunService"), game:GetService("UserInputService")
local fly, sprint = false, false

local function GetRoleColor(p)
    local char = p.Character
    if (char and char:FindFirstChild("Knife")) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then return Color3.fromRGB(255, 0, 0) end
    if (char and char:FindFirstChild("Gun")) or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then return Color3.fromRGB(0, 0, 255) end
    return Color3.fromRGB(0, 255, 0)
end

RS.RenderStepped:Connect(function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local h = p.Character:FindFirstChild("M_ESP") or Instance.new("Highlight", p.Character)
            h.Name, h.FillColor = "M_ESP", GetRoleColor(p)
        end
    end
end)

local function ToggleFly(v)
    fly = v local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if fly and hrp then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyV" bv.MaxForce = Vector3.new(1,1,1)*9e9
        RS.Heartbeat:Connect(function() if fly then bv.Velocity = Cam.CFrame.LookVector * 60 for _,p in pairs(Plr.Character:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
    elseif hrp and hrp:FindFirstChild("FlyV") then hrp.FlyV:Destroy() end
end

local function DropKick(t)
    local h = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not t or not t.Character or not h then return end
    local sC = h.CFrame
    h.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
    t.Character.HumanoidRootPart:ApplyImpulse(Cam.CFrame.LookVector * 50000 + Vector3.new(0, 5000, 0))
    task.wait(0.2) h.CFrame = sC
end

Main:CreateToggle({Name = "Fly Mode [X]", Callback = ToggleFly})
Main:CreateToggle({Name = "Tactical Sprint [Z]", Callback = function(v) sprint = v Plr.Character.Humanoid.WalkSpeed = v and 25 or 16 end})
Fling:CreateButton({Name = "DropKick (Kick & Launch)", Callback = function() for _,p in pairs(game.Players:GetPlayers()) do if p ~= Plr and p.Character then DropKick(p) end end end})

UIS.InputBegan:Connect(function(i, gp)
    if not gp then
        if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 25
        elseif i.KeyCode == Enum.KeyCode.X then ToggleFly(not fly) end
    end
end)
UIS.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.Z then Plr.Character.Humanoid.WalkSpeed = 16 end end)

local s = {} for i=1,350 do s["S_"..i] = i*2 end
Rayfield:Notify({Title = "Project Mayhem", Content = "Combat Modules Loaded", Duration = 3})
