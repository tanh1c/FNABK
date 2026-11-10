-- Server controls classroom doors and workshop shutters in the selected campus model.
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local campus = Workspace:WaitForChild("FNABK_Campus_PixelBuildings_PhaseC_v6", 20)
if not campus then
	warn("[CampusDoors] Campus preview not present; door service idle")
	return
end

local function occupied(door, closed)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {door}
	for _, part in ipairs(Workspace:GetPartBoundsInBox(closed, (door:GetAttribute("DoorClosedSize_v1") or door.Size) + Vector3.new(0.4, 0, 0.4), params)) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then return true end
	end
	return false
end

local count = 0
for _, door in ipairs(campus:GetDescendants()) do
	if door:IsA("BasePart") and door:GetAttribute("CampusDoor") then
		local closed, open = door:GetAttribute("DoorClosed"), door:GetAttribute("DoorOpen")
		if typeof(closed) ~= "CFrame" or typeof(open) ~= "CFrame" then
			warn("[CampusDoors] Invalid door configuration: " .. door:GetFullName())
			continue
		end
		local isOpen = door:GetAttribute("StartsOpen") == true
		local moving = false
		door.Anchored = true
		door.CFrame = if isOpen then open else closed
		local closedSize = door:GetAttribute("DoorClosedSize_v1")
		local fold = door:GetAttribute("DoorFold_v1") == true
		local openSize = if typeof(closedSize) ~= "Vector3" then nil elseif fold then Vector3.new(closedSize.X, closedSize.Y, 0.2) else Vector3.new(closedSize.X, 0.2, closedSize.Z)
		if openSize then door.Size = if isOpen then openSize else closedSize end
		door.CanCollide = not isOpen
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "CampusDoorPrompt"
		prompt.ActionText = if isOpen then "Close" else "Open"
		prompt.ObjectText = "Door"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = 6
		local promptPart = Instance.new("Part")
		promptPart.Name, promptPart.Size, promptPart.Transparency = "DoorPromptMount", Vector3.new(0.2, 0.2, 0.2), 1
		promptPart.Anchored, promptPart.CanCollide, promptPart.CanTouch, promptPart.CanQuery = true, false, false, false
		promptPart.CFrame = if math.abs(open.Position.Y-closed.Position.Y) > 5 then closed * CFrame.new(0, -door.Size.Y/2+2.5, 0) else closed
		promptPart.Parent = door
		prompt.RequiresLineOfSight = false
		prompt.Parent = promptPart
		prompt.Triggered:Connect(function(player)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if moving or not character or not root or not humanoid or humanoid.Health <= 0
				or player:GetAttribute("FNABKDowned") == true or player:GetAttribute("FNABKEliminated") == true
				or character:GetAttribute("FNABKDowned") == true or character:GetAttribute("FNABKEliminated") == true
				or (root.Position-promptPart.Position).Magnitude > 7 then return end
			local ray = RaycastParams.new()
			ray.FilterType = Enum.RaycastFilterType.Exclude
			ray.FilterDescendantsInstances = {character, door}
			ray.RespectCanCollide = true
			if Workspace:Raycast(root.Position, promptPart.Position-root.Position, ray) then return end
			local nextOpen = not isOpen
			if not nextOpen and occupied(door, closed) then return end
			moving = true
			door.CanCollide = false
			local offset, angle = door:GetAttribute("SwingHingeOffset_v1"), door:GetAttribute("SwingAngle_v1")
			if typeof(closedSize) == "Vector3" then
				local progress = Instance.new("NumberValue")
				progress.Value = if isOpen then 1 else 0
				local connection = progress.Changed:Connect(function(value)
					if fold then
						local width = closedSize.Z + (0.2 - closedSize.Z) * value
						door.Size = Vector3.new(closedSize.X, closedSize.Y, width)
						door.CFrame = closed * CFrame.new(0, 0, (closedSize.Z - width)/2)
					else
						local height = closedSize.Y + (0.2 - closedSize.Y) * value
						door.Size = Vector3.new(closedSize.X, height, closedSize.Z)
						door.CFrame = closed * CFrame.new(0, (closedSize.Y - height)/2, 0)
					end
				end)
				local tween = TweenService:Create(progress, TweenInfo.new(0.35), {Value = if nextOpen then 1 else 0})
				tween:Play()
				tween.Completed:Wait()
				connection:Disconnect()
				progress:Destroy()
				door.Size = if nextOpen then openSize else closedSize
				door.CFrame = if nextOpen then open else closed
			elseif typeof(offset) == "Vector3" and typeof(angle) == "number" then
				local progress = Instance.new("NumberValue")
				progress.Value = if isOpen then 1 else 0
				local connection = progress.Changed:Connect(function(value)
					door.CFrame = closed * CFrame.new(offset) * CFrame.Angles(0, angle * value, 0) * CFrame.new(-offset)
				end)
				local tween = TweenService:Create(progress, TweenInfo.new(0.35), {Value = if nextOpen then 1 else 0})
				tween:Play()
				tween.Completed:Wait()
				connection:Disconnect()
				progress:Destroy()
				door.CFrame = if nextOpen then open else closed
			else
				local tween = TweenService:Create(door, TweenInfo.new(0.35), {CFrame = if nextOpen then open else closed})
				tween:Play()
				tween.Completed:Wait()
			end
			isOpen = nextOpen
			-- Check again: someone can enter while the door is moving.
			if not isOpen and occupied(door, closed) then
				door.CFrame = open
				if openSize then door.Size = openSize end
				isOpen = true
			end
			door.CanCollide = not isOpen
			prompt.ActionText = if isOpen then "Close" else "Open"
			moving = false
		end)
		count += 1
	end
end
print("[CampusDoors] Configured " .. count .. " doors")
