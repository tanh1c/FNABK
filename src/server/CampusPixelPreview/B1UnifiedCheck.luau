-- Edit-mode smoke check; does not replace a player traversal test.
return function()
	local b1 = workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings.B1
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {b1}
	params.RespectCanCollide = true
	assert(not workspace:Raycast(Vector3.new(5457.125,3,1736), Vector3.new(0,0,-15), params), "Main entrance blocked")
	for _, x in ipairs({5416,5508}) do
		for floor=1,3 do
			local y=3+(floor-1)*12.85714
			assert(not workspace:Raycast(Vector3.new(x,y,1680),Vector3.new(0,0,20),params), "Wing join blocked")
			for z=1680,1694,2 do assert(workspace:Raycast(Vector3.new(x,y,z),Vector3.new(0,-5,0),params), "Wing route lacks floor") end
		end
	end
	for floor=1,3 do
		local y=3+(floor-1)*12.85714
		assert(not workspace:Raycast(Vector3.new(5416,y,1694),Vector3.new(92,0,0),params), "Crossbar corridor blocked")
		for x=5416,5508,4 do assert(workspace:Raycast(Vector3.new(x,y,1694),Vector3.new(0,-5,0),params), "Crossbar route lacks floor") end
	end
	for _, x in ipairs({5403,5508}) do
		assert(workspace:Raycast(Vector3.new(x,3,1569),Vector3.new(0,0,10),params), "Wing end open")
	end
	local stairs = 0
	for _, p in ipairs(b1:GetChildren()) do if p.Name:match("^Stair_") then stairs += 1 end end
	assert(stairs == 32, "Missing stairs")
	return "B1 entrance, three supported wing-to-wing routes, wing ends and stair count checked"
end
