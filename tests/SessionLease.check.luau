-- Studio server: fake atomic store; no Roblox data is written. SURV-10.
local Lease = require(game.ServerScriptService.FNABKServer.SessionLease)
local value, fail = nil, false
local store = {}
function store:UpdateAsync(_, transform)
	if fail then error("simulated failure") end
	local updated = transform(value)
	if updated then value = updated end
	return updated
end
assert(Lease.update(store, "slot", "server-a", "acquire"))
assert(not Lease.update(store, "slot", "server-b", "acquire"))
assert(Lease.update(store, "slot", "server-a", "save", "complete snapshot"))
assert(value.snapshot == "complete snapshot")
assert(not Lease.update(store, "slot", "server-b", "save", "bad"))
fail = true
local ok, why = Lease.update(store, "slot", "server-a", "save", "replacement")
assert(not ok and why == "StoreFailure" and value.snapshot == "complete snapshot")
fail = false
value.lease.expires = os.time() - 1
assert(not Lease.update(store, "slot", "server-a", "save", "stale"))
local acquired, reason, snapshot = Lease.update(store, "slot", "server-b", "acquire")
assert(acquired and reason == nil and snapshot == "complete snapshot")
assert(not Lease.update(store, "slot", "server-a", "release"))
assert(Lease.update(store, "slot", "server-b", "renew"))
assert(Lease.update(store, "slot", "server-b", "release") and value.lease == nil)
assert(Lease.update(store, "slot", "server-a", "acquire"))
local retried = { version = 1, snapshot = "previous" }
local raceStore = {}
function raceStore:UpdateAsync(_, transform)
	assert(transform(retried)) -- first proposal loses a concurrent update
	retried.lease = { token = "server-b", expires = os.time() + 60 }
	return transform(retried)
end
assert(not Lease.update(raceStore, "slot", "server-a", "acquire"))
assert(retried.lease.token == "server-b" and retried.snapshot == "previous")
local emptyResultStore = {}
function emptyResultStore:UpdateAsync(_, transform) transform(nil); return nil end
ok, why = Lease.update(emptyResultStore, "slot", "server-a", "acquire")
assert(not ok and why == "StoreFailure")
value = { version = 99, snapshot = "old data" }
ok, why = Lease.update(store, "slot", "server-a", "acquire")
assert(not ok and why == "InvalidRecord" and value.snapshot == "old data")
return "Session lease checks passed"
