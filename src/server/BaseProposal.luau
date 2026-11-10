--!strict
-- SURV-03/04: host confirmation after a server-timed announcement.
local Proposal = {}
export type State = { sequence: number, pending: { id: number, building: string, host: number, readyAt: number }? }

function Proposal.new(): State
	return { sequence = 0, pending = nil }
end

function Proposal.begin(state: State, building: string, host: number, now: number): number?
	if state.pending or type(building) ~= "string" or building == "" or type(host) ~= "number"
		or host == 0 or host % 1 ~= 0 or type(now) ~= "number" or now ~= now or math.abs(now) == math.huge then return nil end
	state.sequence += 1
	state.pending = { id = state.sequence, building = building, host = host, readyAt = now + 10 }
	return state.sequence
end

function Proposal.confirm(state: State, id: number, actor: number, now: number): string?
	local pending = state.pending
	if not pending or id ~= pending.id or actor ~= pending.host or type(now) ~= "number" or now ~= now or now < pending.readyAt then return nil end
	state.pending = nil
	return pending.building
end

function Proposal.cancel(state: State)
	state.pending = nil
end

return table.freeze(Proposal)
