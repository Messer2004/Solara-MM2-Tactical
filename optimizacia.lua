local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

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

local function optimize(v)
    if v:IsA("BasePart") then
        local name = v.Name:lower()
        if not v.CanCollide and (name:find("grass") or name:find("bush") or name:find("plant") or name:find("foliage") or v.Material == Enum.Material.Leaves) then
            v:Destroy()
            return
        end
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
    end
    if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v:Destroy()
    end
end

for _, v in ipairs(game:GetDescendants()) do
    optimize(v)
end
game.DescendantAdded:Connect(optimize)
