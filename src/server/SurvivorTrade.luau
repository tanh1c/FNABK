--!strict
-- SURV-13: offer quantity is limited by Trust without discarding hidden stock.
local Trade = {}
function Trade.available(trust: number, initial: number, taken: number): number
	assert(initial >= 0 and initial % 1 == 0 and taken >= 0 and taken % 1 == 0 and taken <= initial)
	if trust < 30 or initial == 0 then return 0 end
	local limit = if trust >= 70 then initial else math.max(1, math.floor(initial / 2))
	return math.max(0, limit - taken)
end
return table.freeze(Trade)
