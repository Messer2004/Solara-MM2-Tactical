local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
    end
end

local function clean(v)
    if v:IsA("BasePart") then 
        v.Material = Enum.Material.SmoothPlastic 
    end
    if v:IsA("Texture") or v:IsA("Decal") then 
        v:Destroy() 
    end
    if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then 
        v.Enabled = false 
    end
end

for _, v in ipairs(game:GetDescendants()) do 
    clean(v) 
end
game.DescendantAdded:Connect(clean)
