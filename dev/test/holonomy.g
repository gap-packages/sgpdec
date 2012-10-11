#for all possible chains: convert to coordinates and back, are they the same?
holonomy_testCoordinates := function(hd)
local chain, modchain, point, degree;
  Print("Testing all chains-coordinates conversions for ", hd, "\n");
  degree := DegreeOfTransformation(Representative(OriginalStructureOf(hd)));
  for point in [1..degree] do 
    Print(point, " \c");
    #for all chains down to singletons
    for chain in AllCoverChainsToSet(SkeletonOf(hd), FiniteSet([point], degree)) do
      modchain := CoverChain(hd,
                     Coordinates(hd,chain));
      if chain <> modchain then
        Print(chain , " <> ", modchain,"\n");
        Print("FAIL\n");
        Error("HOLONOMY switching back and forth between coords and chains failed!\n"); 
      fi;
    od;
  od;
  Print("\nPASSED\n");
end;

#do the action flat, then the corresponding raised action and flatten, is it the same?
holonomy_testAction := function(hd)
local i,numofstates, t, cascadedt,cs,cs_,chain;
  Print("raising state and operation, do the action and flatten the result to check...\n");
  numofstates := Size(TopSet(SkeletonOf(hd)));
  for t in  OriginalStructureOf(hd) do
    cascadedt := AsCascadedTrans(t,hd);
    for i in [1..numofstates] do
      for chain in AllCoverChainsToSet(SkeletonOf(hd), FiniteSet([i],numofstates)) do 
        cs := HolonomySets2Ints(hd, Coordinates(hd,chain));
        if i <> AsPoint(cs, hd) then
          Print("FAIL\n");
          Error("HOLONOMY a cascaded lift failed!\n"); 
        fi;
   
        cs_ := cs ^ cascadedt;
        if i^t <> AsPoint(cs_,hd) then
          Print("FAIL\n");
          Error("HOLONOMY cascaded action for ", t ," failed! for state ",i, " coded as ",chain,"\n"); 
        fi;
      od;
    od;
    Print("#\c");
  od;
  Print("\nPASSED\n");
end;


holonomy_testRaiseFlatten := function(hd)
local t;
  Print("flattening and raising all semigroup elements and testing for equality...\n");
  for t in AsList(OriginalStructureOf(hd)) do
        if t <> AsTransformation(AsCascadedTrans(t,hd),hd) then
          Print("FAIL\n");
          Error("HOLONOMY raising/flattening operations failed!\n"); 
        else
          Print("#\c");
        fi;
  od;
        Print("\nPASSED\n");
end;

#just testing a few but not all
holonomy_testProducts := function(hd)
local i,t,u,sgelements;
  sgelements := AsList(OriginalStructureOf(hd));
  Print("testing 100 random cascaded products whether they map down to the corresponding flat product...\n");
  for i in [1..100] do
    t := Random(sgelements);
    u := Random(sgelements);
    if t*u <> AsTransformation(
               AsCascadedTrans(t,hd) * AsCascadedTrans(u,hd),hd) then
      Print(LinearNotation(t),"*",LinearNotation(u)," FAIL\n");
      Error("HOLONOMY products failed!\n");
    else
      Print("#\c");
    fi;
  od;
  Print("\nPASSED\n");
end;

#this could be very long computation
holonomy_testAllProducts := function(hd)
local i,t,u,sgelements;
  sgelements := AsList(OriginalStructureOf(hd));
  Print("testing all cascaded operation products whether they map down to the corresponding flat product...\n");
    for t in sgelements do
      for u  in sgelements do
        if t*u <> AsTransformation(
               AsCascadedTrans(t,hd) * AsCascadedTrans(u,hd),hd) then
          Print(LinearNotation(t),"*",LinearNotation(u)," FAIL\n");
          Error("HOLONOMY products failed!\n");
        else
          Print("#\c");
       fi;
      od;
    od;
  Print("\nPASSED\n");
end;
