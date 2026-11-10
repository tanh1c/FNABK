-- Controlled Studio Play server: survivor rewards and Trust (SURV-10/13).
local help = require(game.ServerScriptService.FNABKServer.SurvivorHelp)
local map = Instance.new("Folder")
local npc = Instance.new("Model")
npc.Name, npc.Parent = "StudentA", map
npc:SetAttribute("NPCType", "Student")
npc:SetAttribute("SurvivorHealth", 75)
npc:SetAttribute("StudentState", "Idle")
npc:SetAttribute("HelpRewardDay", 2)
npc:SetAttribute("FoodQuestCompleted", true)
npc:SetAttribute("TradeTaken", 2)
npc:SetAttribute("TradeWary", true)
npc:SetAttribute("TradeWaryStock", 3)
npc:SetAttribute("TradeWaryTaken", 1)
local trust = Instance.new("IntValue")
trust.Value = 60
local http = game:GetService("HttpService")
local saved = http:JSONDecode(http:JSONEncode(assert(help.snapshot(map, trust, 2))))
npc:SetAttribute("HelpRewardDay", nil); npc:SetAttribute("FoodQuestCompleted", false)
npc:SetAttribute("TradeTaken", 0); npc:SetAttribute("SurvivorHealth", 100); trust.Value = 100
npc:SetAttribute("TradeWary", false); npc:SetAttribute("TradeWaryStock", 0); npc:SetAttribute("TradeWaryTaken", 0)
assert(help.restore(map, trust, saved, 2))
assert(trust.Value == 60 and npc:GetAttribute("SurvivorHealth") == 75 and npc:GetAttribute("TradeTaken") == 2)
assert(npc:GetAttribute("TradeWary") == true and npc:GetAttribute("TradeWaryStock") == 3 and npc:GetAttribute("TradeWaryTaken") == 1)
assert(not help.award(npc, trust, 2) and help.award(npc, trust, 3) and trust.Value == 70)
npc:SetAttribute("TradeWary", false); npc:SetAttribute("TradeWaryStock", 0); npc:SetAttribute("TradeWaryTaken", 0)
saved.students[1].name = "Missing"
assert(not help.restore(map, trust, saved, 2) and trust.Value == 70 and npc:GetAttribute("HelpRewardDay") == 3)
npc:SetAttribute("StudentState", "Incapacitated")
assert(help.snapshot(map, trust, 3) == nil)
npc:SetAttribute("StudentState", "Idle")
local health = require(game.ServerScriptService.FNABKServer.SurvivorHealth)
health.Incapacitate(npc, 1)
local down = assert(help.snapshot(map, trust, 3))
assert(down.students[1].health == 0 and down.students[1].recovery <= 1)
local target = npc:Clone()
target:SetAttribute("StudentState", "Idle"); target:SetAttribute("SurvivorHealth", 100); target:SetAttribute("SurvivorRecoveryAt", nil)
target.Name = "StudentA"
local second = Instance.new("Folder")
second.Parent = workspace
target.Parent = second
assert(help.restore(second, trust, down, 3))
assert(target:GetAttribute("StudentState") == "Incapacitated" and target:GetAttribute("SurvivorHealth") == 0)
task.wait(1.2)
assert(target:GetAttribute("StudentState") == "Idle" and target:GetAttribute("SurvivorHealth") == 50)
second:Destroy()
map:Destroy(); trust:Destroy()
return "Survivor restore checks passed"
