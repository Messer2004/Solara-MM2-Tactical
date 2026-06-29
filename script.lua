local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({Title = "Project Mayhem | Messer2004", SubTitle = "v1.0", TabWidth = 160, Size = UDim2.fromOffset(500, 350), Acrylic = true, Theme = "Dark"})
local T1, T2, T3 = Window:AddTab({Title = "Main", Icon = "home"}), Window:AddTab({Title = "Teleports", Icon = "map"}), Window:AddTab({Title = "Fling", Icon = "zap"})

local Plrs, UIS, RS, LP, Cam = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera
local esp, fly, sprd, sprint, jmp, pickup, flAura, fConn = false, false, 16, false, false, false, false, nil

task.spawn(function()
    while task.wait() do
        local chr = LP.Character local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if (fly or flAura) and chr then for _, p in pairs(chr:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        if flAura and hrp then hrp.Velocity, hrp.RotVelocity = Cam.CFrame.LookVector * 150, Vector3.new(0, 15000, 0) end
        if pickup and hrp then local d = workspace:FindFirstChild("GunDrop") if d and d:IsA("BasePart") then local o = hrp.CFrame hrp.CFrame = d.CFrame + Vector3.new(0,1,0) task.wait(0.1) hrp.CFrame = o end end
    end
end)

T1:AddToggle("ESP", {Title = "Player ESP [V]", Default = false, Callback = function(v) esp = v if not v then for _,p in pairs(Plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MesserHighlight") then p.Character.MesserHighlight:Destroy() end end end end})
T1:AddToggle("Fly", {Title = "Flight Mode [X]", Default = false, Callback = function(v) fly = v local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if fly and r and h then local bv = Instance.new("BodyVelocity", r) bv.Name, bv.MaxForce, bv.Velocity = "MesserFlyBV", Vector3.new(1,1,1)*math.huge, Vector3.new(0,0,0) fConn = RS.Heartbeat:Connect(function() if r and h and fly then bv.Velocity = h.MoveDirection.Magnitude > 0 and Cam.CFrame.LookVector * 45 or Vector3.new(0,0,0) end end) else if fConn then fConn:Disconnect() end if r and r:FindFirstChild("MesserFlyBV") then r.MesserFlyBV:Destroy() end end end})
T1:AddToggle("Sprint", {Title = "Tactical Sprint [Z]", Default = false, Callback = function(v) sprint = v end})
T1:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 120, Callback = function(v) sprd = v end})
T1:AddToggle("InfJump", {Title = "Infinite Jump", Default = false, Callback = function(v) jmp = v end})
T1:AddToggle("AutoGun", {Title = "Auto-Pickup Gun", Default = false, Callback = function(v) pickup = v end})

T2:AddButton({Title = "TP to Murderer", Callback = function() local t = nil for _,p in pairs(Plrs:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then t = p end end if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end end})
T2:AddButton({Title = "TP to Sheriff", Callback = function() local t = nil for _,p in pairs(Plrs:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then t = p end end if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end end})

T3:AddToggle("FlingAura", {Title = "Fling Aura", Default = false, Callback = function(v) flAura = v end})

UIS.InputBegan:Connect(function(i, gp) if not gp then if i.KeyCode == Enum.KeyCode.V then esp = not esp T1.ESP:SetValue(esp) elseif i.KeyCode == Enum.KeyCode.X then fly = not fly T1.Fly:SetValue(fly) elseif i.KeyCode == Enum.KeyCode.Z then sprint = not sprint T1.Sprint:SetValue(sprint) end end end)
UIS.JumpRequest:Connect(function() if jmp and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end end)
RS.RenderStepped:Connect(function() if esp then for _,p in pairs(Plrs:GetPlayers()) do if p ~= LP and p.Character then local h = p.Character:FindFirstChild("MesserHighlight") or Instance.new("Highlight", p.Character) h.Name = "MesserHighlight" end end end end)
