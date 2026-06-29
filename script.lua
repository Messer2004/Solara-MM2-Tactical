task.wait(2)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Win = Rayfield:CreateWindow({Name = "Project Mayhem", LoadingTitle = "Project Mayhem", LoadingSubtitle = "by Messer2004", ConfigurationSaving = {Enabled = false}})
local T1, T2, T3 = Win:CreateTab("Main"), Win:CreateTab("Teleports"), Win:CreateTab("Fling")
local Plrs, UIS, RS, LP, Cam = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera
local esp, fly, sprd, sprint, jmp, pickup, aim, showFOV, fFOV = false, false, 16, 25, false, false, false, false, 150
local flActive, flAura, selPlr, sPos, fConn = false, false, "", nil, nil

local Circle = Drawing.new("Circle")
Circle.Color, Circle.Thickness, Circle.NumSides, Circle.Filled = Color3.fromRGB(255,0,0), 1.5, 64, false
RS.RenderStepped:Connect(function() Circle.Visible, Circle.Radius, Circle.Position = showFOV, fFOV, Cam.ViewportSize / 2 end)

local function getRole(p)
    if not p or not p.Character then return Color3.fromRGB(0,255,0) end
    local b, c = p:FindFirstChild("Backpack"), p.Character
    if (b and b:FindFirstChild("Knife")) or (c and c:FindFirstChild("Knife")) then return Color3.fromRGB(255,0,0) end
    if (b and b:FindFirstChild("Gun")) or (c and c:FindFirstChild("Gun")) then return Color3.fromRGB(0,0,255) end
    return Color3.fromRGB(0,255,0)
end

local function getRolePlr(r)
    for _, p in pairs(Plrs:GetPlayers()) do
        if p ~= LP and p.Character then
            local b = p:FindFirstChild("Backpack")
            if r == "m" and (p.Character:FindFirstChild("Knife") or (b and b:FindFirstChild("Knife"))) then return p end
            if r == "s" and (p.Character:FindFirstChild("Gun") or (b and b:FindFirstChild("Gun"))) then return p end
        end
    end
end

local function getClosest()
    local target, close = nil, fFOV
    for _, p in pairs(Plrs:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local pos, onScr = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScr then
                local dist = (Vector2.new(pos.X, pos.Y) - (Cam.ViewportSize / 2)).Magnitude
                if dist < close then close, target = dist, p end
            end
        end
    end
    return target
end

hookmetamethod(game, "__namecall", function(self, ...)
    local args, method = {...}, getnamecallmethod()
    if aim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and args[1] and typeof(args[1]) == "Ray" then
            args[1] = Ray.new(args[1].Origin, (t.Character.HumanoidRootPart.Position - args[1].Origin).Unit * 500)
            return self[method](self, unpack(args))
        end
    end
    return self[method](self, ...)
end)

task.spawn(function()
    while task.wait() do
        local chr = LP.Character local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if (fly or flActive or flAura) and chr then for _, p in pairs(chr:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        if flAura and hrp and chr:FindFirstChildOfClass("Humanoid") and chr:FindFirstChildOfClass("Humanoid").Health > 0 then hrp.Velocity, hrp.RotVelocity = Cam.CFrame.LookVector * 150, Vector3.new(0, 15000, 0) end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") local drop = workspace:FindFirstChild("GunDrop")
        if pickup and hrp and drop and drop:IsA("BasePart") then local old = hrp.CFrame hrp.CFrame = drop.CFrame + Vector3.new(0,1,0) task.wait(0.1) hrp.CFrame = old end
    end
end)

local function fling(t)
    local chr = LP.Character local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") or not hrp then return end
    sPos, flActive = hrp.CFrame, true
    local bg, bp = Instance.new("BodyGyro", hrp), Instance.new("BodyPosition", hrp)
    bg.MaxTorque, bg.P, bg.CFrame = Vector3.new(1,1,1)*math.huge, 5000, hrp.CFrame
    bp.MaxForce, bp.P, bp.D = Vector3.new(1,1,1)*math.huge, 20000, 100
    for i = 1, 6 do
        if not t.Character:FindFirstChild("HumanoidRootPart") then break end
        hrp.RotVelocity = Vector3.new(0, 15000, 0)
        bp.Position = (t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, (i%2==0 and 0.2 or -0.2))).Position
        task.wait(0.04)
    end
    flActive = false bp:Destroy() bg:Destroy() hrp.Velocity, hrp.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0)
    task.wait(0.05) hrp.CFrame = sPos
end

local function tp(cf) local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if h then h.Velocity, h.CFrame = Vector3.new(0,0,0), cf end end

local function toggleESP(v)
    esp = v
    if esp then RS:BindToRenderStep("MUpdate", 200, function() for _, p in pairs(Plrs:GetPlayers()) do if p ~= LP and p.Character then local h = p.Character:FindFirstChild("MesserHighlight") or Instance.new("Highlight", p.Character) h.Name, h.FillTransparency, h.OutlineTransparency, h.FillColor, h.OutlineColor = "MesserHighlight", 0.5, 0, getRole(p), h.FillColor end end end)
    else RS:UnbindFromRenderStep("MUpdate") for _, p in pairs(Plrs:GetPlayers()) do if p.Character and p.Character:FindFirstChild("MesserHighlight") then p.Character.MesserHighlight:Destroy() end end end
end

local function toggleFly(v)
    fly = v local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if fly and r and h then local bv = Instance.new("BodyVelocity", r) bv.Name, bv.MaxForce, bv.Velocity = "MesserFlyBV", Vector3.new(1,1,1)*math.huge, Vector3.new(0,0,0) fConn = RS.Heartbeat:Connect(function() if r and h and fly then bv.Velocity = h.MoveDirection.Magnitude > 0 and Cam.CFrame.LookVector * 45 or Vector3.new(0,0,0) end end)
    else if fConn then fConn:Disconnect() end if r and r:FindFirstChild("MesserFlyBV") then r.MesserFlyBV:Destroy() end end
end

local function toggleSprint(v) sprint = v local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = sprint and sprint or sprd end end

local toggle1 = T1:CreateToggle({Name = "Player ESP [V]", CurrentValue = false, Callback = toggleESP})
local toggle2 = T1:CreateToggle({Name = "Flight Mode [X]", CurrentValue = false, Callback = toggleFly})
local toggle3 = T1:CreateToggle({Name = "Tactical Sprint [Z]", CurrentValue = false, Callback = toggleSprint})
T1:CreateSlider({Name = "WalkSpeed", Range = {16, 120}, Increment = 1, CurrentValue = 16, Callback = function(v) sprd = v if not sprint and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end})
T1:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) jmp = v end})
T1:CreateToggle({Name = "Auto-Pickup Gun", CurrentValue = false, Callback = function(v) pickup = v end})
T1:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) aim = v end})
T1:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) showFOV = v end})
T1:CreateSlider({Name = "FOV Radius", Range = {30, 500}, Increment = 5, CurrentValue = 150, Callback = function(v) fFOV = v end})

T2:CreateButton({Name = "TP to Lobby", Callback = function() local l = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("LobbyLocation") tp(l and l.CFrame+Vector3.new(0,3,0) or CFrame.new(-108, 138, 16)) end})
T2:CreateButton({Name = "TP to Murderer", Callback = function() local t = getRolePlr("m") if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then tp(t.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)) end end})
T2:CreateButton({Name = "TP to Sheriff", Callback = function() local t = getRolePlr("s") if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then tp(t.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3)) end end})

T3:CreateToggle({Name = "Fling Aura (Camera)", CurrentValue = false, Callback = function(v) flAura = v if not v and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Velocity, LP.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0) end end})
local function getPlrs() local l = {} for _, p in pairs(Plrs:GetPlayers()) do if p ~= LP then table.insert(l, p.Name) end end return l end
local dropD = T3:CreateDropdown({Name = "Select Target", Options = getPlrs(), CurrentOption = "", MultipleOptions = false, Callback = function(o) selPlr = typeof(o) == "table" and (o[1] or o.Value) or o end})
T3:CreateButton({Name = "Refresh Target List", Callback = function() dropD:Refresh(getPlrs(), true) end})
T3:CreateButton({Name = "Fling Target", Callback = function() if selPlr ~= "" then fling(Plrs:FindFirstChild(selPlr)) end end})
T3:CreateButton({Name = "Fling Murderer", Callback = function() fling(getRolePlr("m")) end})

UIS.InputBegan:Connect(function(input, gp) if not gp then if input.KeyCode == Enum.KeyCode.V then toggle1:Set(not esp) elseif input.KeyCode == Enum.KeyCode.X then toggle2:Set(not fly) elseif input.KeyCode == Enum.KeyCode.Z then toggle3:Set(not sprint) end end end)
UIS.JumpRequest:Connect(function() if jmp and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end end)
Rayfield:Notify({Title = "Executed", Content = "Project Mayhem Loaded", Duration = 3})
