#for all possible chains: convert to coordinates and back, are they the same?
HolonomyTestCoordinates := function(hd)
local chain, modchain, point, degree,c;
  Print("TEST chain = CoverChain(Coordinates(chain))?\n");
  degree := DegreeOfTransformation(Representative(OriginalStructureOf(hd)));
  c := 0;
  for point in [1..degree] do
    c := c+1;Print("\r", c,"/",degree,"\c");
    #for all chains down to singletons
    for chain in AllCoverChainsToSet(SkeletonOf(hd),FiniteSet([point],degree))do
      modchain := CoverChain(hd,
                     Coordinates(hd,chain));
      if chain <> modchain then
        Print(chain , " <> ", modchain,"\c\n");
        Error("HOLONOMY chain-coords conversion FAIL!\n");
      fi;
    od;
  od;
  Print(" PASSED\n");
end;

# testing the coordinatized action. Is it really a homomorphism?
HolonomyTestAction := function(hd)
local i,numofstates, t, cascadedt,cs,cs_,chain,c,n;
  Print("TEST i^t=AsPoint(AsCoords(i)^AsCascadedTrans(t))?\n");
  numofstates := Size(TopSet(SkeletonOf(hd)));
  n := numofstates * Size(OriginalStructureOf(hd));
  c := 0;
  for t in  OriginalStructureOf(hd) do
    cascadedt := AsCascadedTrans(t,hd);
    for i in [1..numofstates] do
      for chain in AllCoverChainsToSet(SkeletonOf(hd),
              FiniteSet([i],numofstates)) do
        cs := HolonomySets2Ints(hd, Coordinates(hd,chain));
        if i <> AsPoint(cs, hd) then
          Error("HOLONOMY  coordinate lift FAIL!\n");
        fi;
        cs_ := cs ^ cascadedt;
        if i^t <> AsPoint(cs_,hd) then
          Error("HOLONOMY action ",t," FAIL! State ",i," coded as ",chain,"\n");
        fi;
      od;
      c := c+1;Print("\r", c,"/",n,"\c");
    od;
  od;
  Print(" PASSED\n");
end;

HolonomyTestSemigroupElements := function(hd)
local t,n,c;
  Print("TEST t=AsTransformation(AsCascadedTrans(t))\n");
  n := Size(OriginalStructureOf(hd));
  c := 0;
  for t in AsList(OriginalStructureOf(hd)) do
    if t <> AsTransformation(AsCascadedTrans(t,hd),hd) then
      Error("HOLONOMY semigroup elements FAIL!\n");
    else
      c := c+1;Print("\r", c,"/",n,"\c");
    fi;
  od;
  Print(" PASSED\n");
end;

#just testing a few but not all
HolonomyTestSomeProducts := function(hd,n)
local i,t,u,sgelements,c;
  sgelements := AsList(OriginalStructureOf(hd));
  Print("TEST t*u=AsTransformation(AsCascadedTrans(t)*AsCascadedTrans(u))?\n");
  c := 0;
  for i in [1..n] do
    t := Random(sgelements);
    u := Random(sgelements);
    if t*u <> AsTransformation(
               AsCascadedTrans(t,hd) * AsCascadedTrans(u,hd),hd) then
      Print(LinearNotation(t),"*",LinearNotation(u)," FAIL\n");
      Error("HOLONOMY products failed!\n");
    else
      c := c+1;Print("\r", c,"/",n,"\c");
    fi;
  od;
  Print(" PASSED\n");
end;

#this could be very long computation
HolonomyTestAllProducts := function(hd)
local i,t,u,sgelements,c;
  sgelements := AsList(OriginalStructureOf(hd));
  Print("TEST t*u=AsTransformation(AsCascadedTrans(t)*AsCascadedTrans(u))?\n");
  n := Size(sgelements)^2;
  c := 0;
  for t in sgelements do
    for u  in sgelements do
      if t*u <> AsTransformation(
                 AsCascadedTrans(t,hd) * AsCascadedTrans(u,hd),hd) then
        Print(LinearNotation(t),"*",LinearNotation(u)," FAIL\n");
        Error("HOLONOMY products failed!\n");
      else
        c := c+1;Print("\r", c,"/",n,"\c");
      fi;
    od;
  od;
  Print(" PASSED\n");
end;
