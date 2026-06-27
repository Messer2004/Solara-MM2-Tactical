local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Messer Menu [PC]",
   LoadingTitle = "Messer Tactical",
   LoadingSubtitle = "by Messer2004",
   ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Главная", nil)

local espEnabled = false
local flyEnabled = false
local walkSpeedNormal = 16
local walkSpeedSprint = 25
local flyConnection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function GetPlayerColor(p)
    if not p then return Color3.fromRGB(0, 255, 0) end
    local char = p.Character
    local bp = p:FindFirstChild("Backpack")
    if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return Color3.fromRGB(255, 0, 0)
    elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return Color3.fromRGB(0, 0, 255)
    end
    return Color3.fromRGB(0, 255, 0)
end

local EspToggle = Tab:CreateToggle({
   Name = "Включить ESP (Подсветка)",
   CurrentValue = false,
   Callback = function(Value)
      espEnabled = Value
      if espEnabled then
          RunService:BindToRenderStep("MesserESPUpdate", Enum.RenderPriority.Camera.Value, function()
              for _, player in pairs(Players:GetPlayers()) do
                  if player ~= LocalPlayer and player.Character then
                      local highlight = player.Character:FindFirstChild("MesserHighlight")
                      if not highlight then
                          highlight = Instance.new("Highlight")
                          highlight.Name = "MesserHighlight"
                          highlight.FillTransparency = 0.5
                          highlight.OutlineTransparency = 0
                          highlight.Parent = player.Character
                      end
                      highlight.FillColor = GetPlayerColor(player)
                      highlight.OutlineColor = highlight.FillColor
                  end
              end
          end)
      else
          RunService:UnbindFromRenderStep("MesserESPUpdate")
          for _, player in pairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("MesserHighlight") then
                  player.Character.MesserHighlight:Destroy()
              end
          end
      end
   end,
})

local FlyToggle = Tab:CreateToggle({
   Name = "Режим полета (Fly)",
   CurrentValue = false,
   Callback = function(Value)
      flyEnabled = Value
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      
      if flyEnabled and root and humanoid then
          local bv = Instance.new("BodyVelocity")
          bv.Name = "MesserFlyBV"
          bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
          bv.Velocity = Vector3.new(0, 0, 0)
          bv.Parent = root
          
          flyConnection = RunService.Heartbeat:Connect(function()
              if root and humanoid and flyEnabled then
                  if humanoid.MoveDirection.Magnitude > 0 then
                      bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 45
                  else
                      bv.Velocity = Vector3.new(0, 0, 0)
                  end
              end
          end)
      else
          if flyConnection then flyConnection:Disconnect() end
          if root then
              local bv = root:FindFirstChild("MesserFlyBV")
              if bv then bv:Destroy() end
          end
      end
   end,
})

local SpeedBind = Tab:CreateKeybind({
   Name = "Тактический спринт (Зажатие)",
   CurrentKeybind = "Z",
   HoldToInteract = true,
   Callback = function(State)
       local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
       if hum then
           hum.WalkSpeed = State and walkSpeedSprint or walkSpeedNormal
       end
   end,
})
