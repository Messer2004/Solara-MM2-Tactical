if setfpscap then setfpscap(240) end

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9

local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
if atmos then atmos:Destroy() end

local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    terrain.Decoration = false
    local clouds = terrain:FindFirstChildOfClass("Clouds")
    if clouds then clouds:Destroy() end
end

local cam = Workspace.CurrentCamera
if cam then
    cam:GetPropertyChangedSignal("CFrame"):Connect(function()
        local plr = Players.LocalPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                cam.FieldOfView = 70 
            end
        end
    end)
end

local function optimize(v)
    if v:IsA("BasePart") and not v:IsA("Terrain") then
        local name = v.Name:lower()
        if name:find("grass") or name:find("bush") or name:find("plant") or name:find("foliage") or name:find("tree") or name:find("leaf") or name:find("leaves") or name:find("trunk") then
            v:Destroy()
            return
        end
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    if v:IsA("MeshPart") then
        v.TextureID = ""
    end
    if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v:Destroy()
    end
end

for _, v in ipairs(game:GetDescendants()) do
    optimize(v)
end
game.DescendantAdded:Connect(optimize)
