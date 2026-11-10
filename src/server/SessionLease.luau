--!strict
-- SURV-10: atomic lease transitions for one host slot. Not wired to live saves.
local Lease = {}
-- ponytail: provisional 90-second lease; tune renewal and skew margins with live service tests.
local TTL = 90

function Lease.update(store: any, key: string, token: string, operation: string, snapshot: string?): (boolean, string?, string?)
	if type(key) ~= "string" or #key == 0 or #key > 50 or type(token) ~= "string" or #token == 0 or #token > 128
		or (operation ~= "acquire" and operation ~= "renew" and operation ~= "save" and operation ~= "release")
		or (operation == "save" and (type(snapshot) ~= "string" or #snapshot == 0 or #snapshot > 3000000)) then
		return false, "InvalidRequest"
	end
	local reason = "Conflict"
	local accepted = false
	local ok, committed = pcall(function()
		return store:UpdateAsync(key, function(record)
			accepted, reason = false, "Conflict"
			if record ~= nil and (type(record) ~= "table" or record.version ~= 1
				or (record.snapshot ~= nil and (type(record.snapshot) ~= "string" or #record.snapshot > 3000000))
				or (record.lease ~= nil and (type(record.lease) ~= "table" or type(record.lease.token) ~= "string"
					or type(record.lease.expires) ~= "number" or record.lease.expires ~= record.lease.expires
					or math.abs(record.lease.expires) == math.huge))) then
				reason = "InvalidRecord"; return nil
			end
			local now = os.time()
			local current = record and record.lease
			local owned = current and current.token == token and current.expires > now
			if operation == "acquire" then
				if current and current.expires > now and current.token ~= token then return nil end
			elseif not owned then return nil end
			local nextRecord = { version = 1, snapshot = if operation == "save" then snapshot else record and record.snapshot,
				lease = if operation == "release" then nil else { token = token, expires = now + TTL } }
			accepted = true
			return nextRecord
		end)
	end)
	if not ok then return false, "StoreFailure" end
	if not accepted then return false, reason end
	if type(committed) ~= "table" then return false, "StoreFailure" end
	return true, nil, committed.snapshot
end

return table.freeze(Lease)
