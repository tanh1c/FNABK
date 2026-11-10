-- Controlled Studio Play server; temporary campus, SURV-03/04/10.
local service = require(game.ServerScriptService.FNABKServer.BaseService)
local campus = Instance.new("Model")
campus.Name, campus.Parent = "TestBaseRestore", workspace
local buildings = Instance.new("Folder")
buildings.Name, buildings.Parent = "Buildings", campus
local building = Instance.new("Model")
building.Name, building.Parent = "TestBuilding", buildings
local floor = Instance.new("Part")
floor.Name, floor.Parent = "WalkableFloor", building
assert(not pcall(function() service.Start(campus, { version = 1, active = "Missing" }) end))
assert(not pcall(function() service.Start(campus, { version = 2, active = "TestBuilding" }) end))
local duplicate = building:Clone()
duplicate.Parent = buildings
assert(not pcall(function() service.Start(campus, { version = 1, active = "TestBuilding" }) end))
duplicate:Destroy()
floor.Parent = nil
assert(not pcall(function() service.Start(campus, { version = 1, active = "TestBuilding" }) end))
floor.Parent = building
local capture = assert(service.Start(campus, { version = 1, active = "TestBuilding" }))
assert(capture().active == "TestBuilding")
campus:Destroy()
return "Base restore checks passed"
