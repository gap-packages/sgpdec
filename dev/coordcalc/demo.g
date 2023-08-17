# TODO: review, this codo may use old API

#demonstrating the coordinate manipulation algorithm (like generalized arithmetic)

#check actions for errors ('above'-actions) and carries
checkActions := function(level,actions)
local i;
  for i in [1..level-1] do
    if actions[i] <> () then Error("ERROR: unexpected action on a level above!");fi;
  od;
  for i in [level+1..Length(actions)] do
    if actions[i] <> () then Error("ERROR: unexpected action on a level below!");fi;
  od;
end;



#############################THE REAL STUFF STARTS HERE
#transforming cascaded state src into dest by coordinatewise manipulation 
x2ycoordwisedemo := function(ld, src, dest)
local level,taxi,msrc,otaxi,actions,i, conjugator,converter,decoded;

  if VERBOSE then Print("We would like to go to ", AsList(dest), " from ", AsList(src), "\n\n");fi;
  #making the source mutable as we do several coordinae changes
  msrc := ShallowCopy(src); 
  conjugator := ();
  #on each level top-down
  for level in [1..Length(src)] do
  #in case we are already there
      converter := ConvertersFromCanonicalOf(ld)[level];
    if (msrc[level] = dest[level]) then
            if VERBOSE then Print("Nothing to do on level ", level,"\n\n");fi;
    else
            if VERBOSE then Print("On level ", level, " we need to find an element of the component ",
            StructureDescription(ld[level]), " which takes ", msrc[level], " to ", 
            dest[level], "\n"); fi;

      #finding a suitable component action: src^-1*dest -- well we don't really do it in the component but in a subgroup of the original
      otaxi := Inverse(Image(converter, msrc[level])) *
                      Image(converter, dest[level]);

      #but we need to conjugate it:
      otaxi := Inverse(conjugator)*otaxi*(conjugator);

      if VERBOSE then Print("A suitable  element of the original group (in a subgroup in the series)",otaxi,"\n");fi;
      if VERBOSE then Print("Element of subgroup? ", otaxi in SeriesOf(ld)[level],"\n");fi;
      #calculate component actions
      actions := ComponentActions(ld,otaxi,DecodeCosetReprs(ld,msrc));
      if VERBOSE then Print("Its component actions: ", actions,"\n");fi;

      checkActions(level,actions);

      #do the action
      for i in [1..Length(msrc)] do
        msrc[i] := msrc[i] ^ actions[i];
      od;
      if VERBOSE then Display(msrc);fi;
      if VERBOSE then Print("\n");fi;
    fi;
    #modifying conjugator - just attaching the current levels' coordval as repr
    conjugator := Image(converter,msrc[level]) * conjugator;
  od;
  if msrc <> AsList(dest) then Error("ERROR: coordinate manipulation failed! ", msrc," instead of ", AsList(dest));fi;
end;


comprehenisiveCoordCalcCheck := function(ld)
local perm1,perm2,cs1,cs2;
for perm1 in OriginalStructureOf(ld) do
    for perm2 in OriginalStructureOf(ld) do
      cs1 := Perm2CascadedState(ld,perm1);
      cs2 := Perm2CascadedState(ld,perm2);
      x2ycoordwisedemo(ld,cs1,cs2);
    od;
  od;
end;
