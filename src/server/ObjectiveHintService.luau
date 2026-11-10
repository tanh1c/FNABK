--!strict
-- Shared inactivity hint reflects the current survival objectives.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hint = require(script.Parent:WaitForChild("RescueHint"))
type HintConfig = { objectiveHintDelaySeconds: number }
local ObjectiveHintService = {}

function ObjectiveHintService.Start(config: HintConfig)
	local state = ReplicatedStorage:WaitForChild("FNABKRoundState")
	local objectives = state:WaitForChild("RescueObjectives")
	local power = objectives:WaitForChild("Power") :: BoolValue
	local frequency = objectives:WaitForChild("Frequency") :: BoolValue
	local transmitter = objectives:WaitForChild("Transmitter") :: BoolValue
	local sent = objectives:WaitForChild("SignalSent") :: BoolValue
	local status = state:WaitForChild("RoundStatus") :: StringValue
	local phase = state:WaitForChild("SurvivalPhase") :: StringValue
	local remote = Instance.new("RemoteEvent")
	remote.Name, remote.Parent = "ObjectiveHint", ReplicatedStorage:WaitForChild("FNABKRemotes")
	local lastProgress, shown = os.clock(), false
	for _, value in ipairs({ power, frequency, transmitter, sent, status, phase }) do
		value.Changed:Connect(function() lastProgress, shown = os.clock(), false end)
	end
	task.spawn(function()
		while state.Parent do
			if status.Value == "Running" and not shown and os.clock() - lastProgress >= config.objectiveHintDelaySeconds then
				shown = true
				remote:FireAllClients(Hint.current(power.Value, frequency.Value, transmitter.Value, sent.Value, phase.Value))
			end
			task.wait(0.5)
		end
	end)
end
return table.freeze(ObjectiveHintService)
