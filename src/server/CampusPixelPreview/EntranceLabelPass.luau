-- Distinguish entrance signs from other unnumbered access openings.
local bs=workspace.FNABK_Campus_PixelBuildings_PhaseC_v6.Buildings
local selected={}
for _,id in ipairs({"B3","B4","B9","C4","C5","Facility7"}) do
 local b=bs[id];local entry=b.CenterFacingEntrance_v1;local candidate
 for _,p in ipairs(b:GetDescendants()) do
  if p:IsA("BasePart") and p.Name=="ClassroomNumber" and p:GetAttribute("RoomLabel")=="LỐI ĐI"
   and (p.Position-entry.EntryCanopy.Position).Magnitude<3.5 then
   assert(not candidate,"Ambiguous entrance plate: "..id);candidate=p
  end
 end
 assert(candidate,"Missing entrance plate: "..id)
 local labels={}
 for _,v in ipairs(candidate:GetDescendants()) do if v:IsA("TextLabel") then table.insert(labels,v) end end
 assert(#labels==2)
 table.insert(selected,{candidate,labels})
end
for _,item in ipairs(selected) do
 item[1]:SetAttribute("BeforeEntranceLabel_v1",item[1]:GetAttribute("RoomLabel"))
 item[1]:SetAttribute("RoomLabel","LỐI VÀO")
 for _,label in ipairs(item[2]) do label.Text="LỐI VÀO" end
end
return "Labeled six confirmed main entrances"
