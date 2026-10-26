--!strict
-- Minimal server bootstrap. Core gameplay must be implemented by the student team.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("FNABKShared")
local config = require(shared:WaitForChild("GameConfig"))
print(string.format("[FNABK] Server initialized; design round=%ds (gameplay not implemented)", config.roundDurationSeconds))
