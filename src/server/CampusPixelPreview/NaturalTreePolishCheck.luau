local root=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6
local output=root.CampusTreePolish_v1
local folders={root.CampusGrass_v1,root.CampusParkDetails_v1,root.CampusNarrowPlanting_v1,root.CampusPerimeterPlanting_v1,root.CampusNaturalLandscape_v1,output}
local allTrees,seats,entries={},{},{}
for _,folder in ipairs(folders) do for _,v in ipairs(folder:GetDescendants()) do
 if v:IsA("Model") and v:FindFirstChild("Trunk") then table.insert(allTrees,v)
 elseif v:IsA("Seat") then table.insert(seats,v.Position) end
end end
for _,p in ipairs(root.Buildings:GetDescendants()) do
 if p:IsA("BasePart") and p:GetAttribute("CampusDoor") and (p.Name:find("Main") or p.Name:find("Entry")) then local c=p:GetAttribute("DoorClosed");if c then table.insert(entries,c.Position) end end
end
local function far(pos,list,distance)
 for _,q in ipairs(list) do assert(Vector3.new(pos.X-q.X,0,pos.Z-q.Z).Magnitude>=distance,"Tree too close to seat or entry") end
end
local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={root.Buildings,root.CampusBoundaryAndGates_v1}
local upgraded,added,styles=0,0,{}
for _,folder in ipairs(folders) do
 for _,area in ipairs(folder:GetChildren()) do
  local grass=root.CampusExactGrass_v1:FindFirstChild(area.Name)
  if grass then
   local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={grass};ray.RespectCanCollide=true
   for _,tree in ipairs(area:GetDescendants()) do if tree:IsA("Model") and tree:GetAttribute("PolishedTree_v1") then
    local trunk=tree.Trunk;local oldSize=assert(trunk:GetAttribute("BeforeTreePolishSize_v1"));local oldFrame=assert(trunk:GetAttribute("BeforeTreePolishFrame_v1"))
    local base=trunk.Position-Vector3.new(0,trunk.Size.Y/2,0);local oldBase=oldFrame.Position-Vector3.new(0,oldSize.Y/2,0)
    assert((base-oldBase).Magnitude<.02 and trunk.CanCollide)
     local _,size=tree:GetBoundingBox();local varied=tree:GetAttribute("TreeVariety_v1")~=nil
     assert(size.Y>=(varied and 13 or 16) and size.Y<=(varied and 28 or 24) and size.X<=12 and size.Z<=12)
    for _,x in ipairs({-5.5,0,5.5}) do for _,z in ipairs({-5.5,0,5.5}) do
     assert(workspace:Raycast(base+Vector3.new(x,5,z),Vector3.new(0,-10,0),ray),"Tree canopy outside grass: "..tree:GetFullName())
    end end
    for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(base.X,12,base.Z),Vector3.new(12,24,12),overlap)) do assert(not part.CanCollide,"Tree overlaps "..part:GetFullName()) end
    far(base,seats,8);far(base,entries,25)
    local detail=assert(tree:FindFirstChild("DetailedCanopy_v1"));local style=assert(tree:GetAttribute("TreeStyle_v1"));styles[style]=true
    local foliage,branches,fronds=0,0,0
    for _,p in ipairs(detail:GetChildren()) do
     assert(p:IsA("BasePart") and not p.CanCollide and not p.CanQuery)
     if p.Name=="Foliage" then foliage+=1 elseif p.Name=="Branch" then branches+=1 elseif p.Name=="Frond" then fronds+=1 end
    end
    if style==0 then assert(fronds==7) else assert(branches==4 and foliage==5) end
    if tree:IsDescendantOf(output) then
     added+=1
     for _,other in ipairs(allTrees) do if other~=tree then local q=other.Trunk.Position;assert(Vector3.new(base.X-q.X,0,base.Z-q.Z).Magnitude>=11.99,"New trees too close") end end
    else
     upgraded+=1;local saved=0
     for _,p in ipairs(tree:GetChildren()) do if p:IsA("BasePart") and (p.Name=="Crown" or p.Name=="Canopy" or p.Name=="UpperCanopy") then
      assert(p:GetAttribute("BeforeTreePolishTransparency_v1")~=nil and p.Transparency==1);saved+=1
     end end
     assert(saved>0)
    end
   end end
  end
  task.wait()
 end
end
local kindCount=0;for _ in pairs(styles) do kindCount+=1 end
assert(#allTrees==201 and upgraded==124 and added==34 and kindCount==5)
assert(output:GetAttribute("UpgradedTreeCount")==upgraded and output:GetAttribute("NewTreeCount")==added)
return "124 renewed trees and 34 additional trees checked for height, planting bounds and clearance"
