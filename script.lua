local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolaraMM2Menu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UUDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Tactical"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(0, 180, 0, 30)
EspToggle.Position = UDim2.new(0, 20, 0, 45)
EspToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspToggle.Text = "ESP: OFF"
EspToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggle.Font = Enum.Font.SourceSans
EspToggle.TextSize = 14
EspToggle.Parent = MainFrame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspToggle

local CoinToggle = Instance.new("TextButton")
CoinToggle.Size = UDim2.new(0, 180, 0, 30)
CoinToggle.Position = UDim2.new(0, 20, 0, 85)
CoinToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CoinToggle.Text = "Coin Collect: OFF"
CoinToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CoinToggle.Font = Enum.Font.SourceSans
CoinToggle.TextSize = 14
CoinToggle.Parent = MainFrame

local CoinCorner = Instance.new("UICorner")
CoinCorner.CornerRadius = UDim.new(0, 6)
CoinCorner.Parent = CoinToggle

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0, 180, 0, 30)
SpeedToggle.Position = UDim2.new(0, 20, 0, 125)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedToggle.Text = "Sprint (Shift): OFF"
SpeedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedToggle.Font = Enum.Font.SourceSans
SpeedToggle.TextSize = 14
SpeedToggle.Parent = MainFrame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedToggle

local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local espActive = false
local coinActive = false
local speedActive = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local function setupHighlight(character)
        task.spawn(function()
            while character and character.Parent and espActive do
                local highlight = character:FindFirstChild("SolaraESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "SolaraESP"
                    highlight.Parent = character
                end
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                
                local bp = player:FindFirstChild("Backpack")
                if (bp and bp:FindFirstChild("Knife")) or character:FindFirstChild("Knife") then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif (bp and bp:FindFirstChild("Gun")) or character:FindFirstChild("Gun") then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                task.wait(1)
            end
        end)
    end
    if player.Character then setupHighlight(player.Character) end
    player.CharacterAdded:Connect(setupHighlight)
end

EspToggle.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        EspToggle.Text = "ESP: ON"
        EspToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
    else
        EspToggle.Text = "ESP: OFF"
        EspToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("SolaraESP")
                if h then h:Destroy() end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    if espActive then ApplyESP(p) end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X and coinActive then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Coin_Sub" or obj.Name == "Coin" or (obj:IsA("TouchTransmitter") and obj.Parent.Name == "Coin") then
                    local coinPart = obj:IsA("TouchTransmitter") and obj.Parent or obj
                    if coinPart:IsA("BasePart") then
                        coinPart.CFrame = root.CFrame
                        break
                    end
                end
            end
        end
    end
end)

CoinToggle.MouseButton1Click:Connect(function()
    coinActive = not coinActive
    if coinActive then
        CoinToggle.Text = "Coin Collect (X): ON"
        CoinToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        CoinToggle.Text = "Coin Collect: OFF"
        CoinToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.LeftShift and speedActive then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 25 end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

SpeedToggle.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    if speedActive then
        SpeedToggle.Text = "Sprint (Shift): ON"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        SpeedToggle.Text = "Sprint (Shift): OFF"
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)
