--!strict
-- SURV-01/11: hints never require optional A01 objectives.
local Hint = {}
function Hint.current(power: boolean, frequency: boolean, transmitter: boolean, sent: boolean, phase: string): string
	if not power or not frequency or not transmitter then return "Open M to find the remaining rescue stations." end
	if not sent then return "Return to the transmitter and press G to send the signal." end
	if phase == "Boarding" then return "Reach the sports field and board the helicopter." end
	if phase == "RescueWait" then return "Reach the sports field while the helicopter approaches." end
	return "Signal sent. Survive through the fifth night."
end
return table.freeze(Hint)
