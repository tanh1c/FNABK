-- Confirm preserved step tops and required added-floor flights.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local adjusted=0
for _,b in ipairs(bs:GetChildren()) do
 for _,v in ipairs(b:GetDescendants()) do
  if v:IsA("BasePart") and v:GetAttribute("BeforeStairClearanceSize_v1") then
   local size,frame=v:GetAttribute("BeforeStairClearanceSize_v1"),v:GetAttribute("BeforeStairClearanceCFrame_v1")
   assert(v.Anchored and v.CanCollide and math.abs(v.Size.Y-.2)<.01)
   assert(math.abs((v.Position.Y+v.Size.Y/2)-(frame.Position.Y+size.Y/2))<.01)
   adjusted+=1
  end
 end
end
assert(adjusted==480)
for _,pair in ipairs({{"A4",{4}},{"C6",{3,4}}}) do
 for _,f in ipairs(pair[2]) do
  local folder=assert(bs[pair[1]].StairClearanceExtensions_v1:FindFirstChild("Flight_"..string.format("%02d",f)))
  local steps=0
  for _,v in ipairs(folder:GetChildren()) do
   if v:IsA("BasePart") and v.Name:match("_Step_%d+") then assert(v.CanCollide and math.abs(v.Size.Y-.2)<.01);steps+=1 end
  end
  assert(steps==16)
 end
end
return "480 retained upper tread tops; three added flights have 16 collidable steps each"
