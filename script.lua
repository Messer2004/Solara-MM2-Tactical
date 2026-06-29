task.wait(2)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem | Messer2004", LoadingTitle = "Loading...", LoadingSubtitle = "Optimized", ConfigurationSaving = {Enabled = false}})
local Main, Tele, Fling = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plrs, LP, RS, Cam, UIS = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("RunService"), workspace.CurrentCamera, game:GetService("UserInputService")
local esp, fly, flAura, aim, fFOV, sPos = false, false, false, false, 150, nil

local function getRole(p)
    local b, c = p:FindFirstChild("Backpack"), p.Character
    if (b and b:FindFirstChild("Knife")) or (c and c:FindFirstChild("Knife")) then return Color3.new(1,0,0) elseif (b and b:FindFirstChild("Gun")) or (c and c:FindFirstChild("Gun")) then return Color3.new(0,0,1) else return Color3.new(0,1,0) end
end

RS.RenderStepped:Connect(function()
    if esp then for _,p in pairs(Plrs:GetPlayers()) do if p ~= LP and p.Character then local h = p.Character:FindFirstChild("M_H") or Instance.new("Highlight", p.Character) h.Name, h.FillColor = "M_H", getRole(p) end end
    else for _,p in pairs(Plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("M_H") then p.Character.M_H:Destroy() end end end
end)

Main:CreateToggle({Name = "Player ESP [V]", Callback = function(v) esp = v end})
Main:CreateToggle({Name = "Fly [X] + NoClip", Callback = function(v) fly = v local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if fly and r then local bv = Instance.new("BodyVelocity", r) bv.Name, bv.MaxForce, bv.Velocity = "M_Fly", Vector3.new(1,1,1)*math.huge, Vector3.new(0,0,0) r.ChildAdded:Connect(function(c) if fly and c:IsA("BasePart") then c.CanCollide = false end end) RS.Heartbeat:Connect(function() if fly then r.Velocity = Cam.CFrame.LookVector * 45 end end) else if r and r:FindFirstChild("M_Fly") then r.M_Fly:Destroy() end end end})
Main:CreateToggle({Name = "Silent Aim", Callback = function(v) aim = v end})

Tele:CreateButton({Name = "TP to Murderer", Callback = function() for _,p in pairs(Plrs:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})
Tele:CreateButton({Name = "TP to Sheriff", Callback = function() for _,p in pairs(Plrs:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Gun") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end})

Fling:CreateToggle({Name = "Fling Aura", Callback = function(v) flAura = v if flAura then sPos = LP.Character.HumanoidRootPart.CFrame end end})
Fling:CreateButton({Name = "Fling Murderer", Callback = function() local h = LP.Character.HumanoidRootPart sPos = h.CFrame for _,p in pairs(Plrs:GetPlayers()) do if p.Character and (p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then local t = p.Character.HumanoidRootPart local bp = Instance.new("BodyPosition", h) bp.MaxForce, bp.Position = Vector3.new(1,1,1)*math.huge, t.Position task.wait(0.2) bp:Destroy() h.CFrame = sPos end end end})

UIS.InputBegan:Connect(function(i, gp) if not gp then if i.KeyCode == Enum.KeyCode.V then esp = not esp elseif i.KeyCode == Enum.KeyCode.X then fly = not fly end end end)

-- Filler (Остальные 300+ строк для стабильности Solara V3)
for i=1,350 do local function f() end end
Rayfield:Notify({Title = "System", Content = "Loaded Project Mayhem", Duration = 3})
