Read("actioncheck.g");
#check actions for errors ('above'-actions) and carries
checkActions4Trouble := function(level,actions)
local i, carries;

  for i in [1..level-1] do
    if actions[i] <> () then Error("ERROR: unexpected action on a level above!");fi;
  od;
  carries := [];
  for i in [level+1..Length(actions)] do
    if actions[i] <> () then Error("ERROR: unexpected action on a level below!");fi;
  od;
  return carries;
end;



#in a lagrange decomposition on a level we would like to go from point src to pint dest (possibly messing up levels below, but not above) 
troubleMaker := function(ld,level,srcpoint, destpoint)
local srcrep, destrep, x2yperm, x2ycascop, locations,i;
  
  if srcpoint = destpoint then ; Print("Nothing to do here, and the test would give wrong results!\n");return;fi;
  
  #converting points to coset representatives
  srcrep := Image(ConvertersFromCanonicalOf(ld)[level], srcpoint);
  destrep := Image(ConvertersFromCanonicalOf(ld)[level], destpoint);

  #these elements of the group should be in the normal subgroup of the level but no in the one(s) below
  #Print("SrcRep element of subgroup? ", srcrep in SeriesOf(ld)[level],"\n");
  #Print("SrcRep element of subgroup below? ", srcrep in SeriesOf(ld)[level+1],"\n");

  #Print("DestRep element of subgroup? ", destrep in SeriesOf(ld)[level],"\n");
  #Print("DestRep element of subgroup below? ", destrep in SeriesOf(ld)[level+1],"\n");

  #now we combine those as x^-1*y
  x2yperm := Inverse(srcrep) * destrep;
  #and do similar checks for localizing it
  Print("x2yPerm element of subgroup? ", x2yperm in SeriesOf(ld)[level],"\n");
  Print("x2yPerm element of subgroup below? ", x2yperm in SeriesOf(ld)[level+1],"\n");
  
  if not ( (x2yperm in SeriesOf(ld)[level]) and (not(x2yperm in SeriesOf(ld)[level+1])) ) then Print("Miscontained element trouble with ",level,",",srcpoint,",",destpoint," in ", StructureDescription(OriginalStructureOf(ld)),"\n");fi; 

  #raising it
  x2ycascop := Raise(ld, x2yperm);
  locations := whereAreTheActions(x2ycascop);
  for i in [1..level-1] do
    if locations[i] <> () then Print("ERROR: unexpected action on a level above!",level,",",srcpoint,",",destpoint," in ", StructureDescription(OriginalStructureOf(ld)),"\n");fi;
    od;
  for i in [level+1..Length(ld)] do
    if locations[i] <> () then Print("Unexpected action below ",level,",",srcpoint,",",destpoint," in ", StructureDescription(OriginalStructureOf(ld)),"\n");fi;
    od;

end;

troubleSystematicCheck := function(ld)
local level,src,dest,stateset;
    for level in [1..Length(ld)] do
      stateset := SetOfPermutationGroupToActOn(ld[level]);
      for src in stateset do
        for dest in stateset do
          if src <> dest then troubleMaker(ld,level,src,dest);fi;
        od;
      od;
    od;
end;
