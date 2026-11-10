-- Server controls the occasional flicker of the existing roadside lamps.
local Workspace = game:GetService("Workspace")

local campus = Workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6", 20)
local lamps = campus and campus:WaitForChild("MarketplaceStreetLamps_15472204631_v1", 20)
if not lamps then return end

for _, lamp in ipairs(lamps:GetChildren()) do
	if lamp:GetAttribute("StreetLampFlicker") then
		task.spawn(function()
			local lights, bulbs = {}, {}
			for _, instance in ipairs(lamp:GetDescendants()) do
				if instance:IsA("Light") then table.insert(lights, instance) end
				if instance:IsA("BasePart") and instance.Material == Enum.Material.Neon then
					table.insert(bulbs, instance)
				end
			end
			while lamp:IsDescendantOf(Workspace) do
				task.wait(math.random(25, 60))
				for _, light in ipairs(lights) do light.Enabled = false end
				for _, bulb in ipairs(bulbs) do bulb.Material = Enum.Material.SmoothPlastic end
				task.wait(0.4)
				for _, light in ipairs(lights) do light.Enabled = true end
				for _, bulb in ipairs(bulbs) do bulb.Material = Enum.Material.Neon end
			end
		end)
	end
end
