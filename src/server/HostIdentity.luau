--!strict
-- Only a server-provisioned run owner grants host rights; Studio may use its first test player.
local HostIdentity = {}
function HostIdentity.resolve(configured: number, studio: boolean, firstPlayer: number, privateOwner: number?): number?
	if type(configured) == "number" and configured > 0 and configured % 1 == 0 and configured < math.huge then return configured end
	if type(privateOwner) == "number" and privateOwner > 0 and privateOwner % 1 == 0 and privateOwner < math.huge then return privateOwner end
	if studio and type(firstPlayer) == "number" and firstPlayer ~= 0 and firstPlayer % 1 == 0 and math.abs(firstPlayer) < math.huge then return firstPlayer end
	return nil
end
function HostIdentity.canClaimSolo(playerCount: number, hostId: number, actorId: number): boolean
	return playerCount == 1 and hostId ~= 0 and actorId == hostId
end
function HostIdentity.canAdmit(count: number, limit: number, userId: number, ownerId: number, ownerPresent: boolean): boolean
	return count < limit and (ownerId <= 0 or ownerPresent or userId == ownerId or count < limit - 1)
end
return table.freeze(HostIdentity)
