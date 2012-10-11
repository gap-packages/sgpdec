#########################################################################
## Raising/flattening should take us to the original permutation.
LagrangeTest1a := function(decomp)
local g,g_,n,c;
  Print("TEST 1A: YEAST for group elements. ___________________________\n");
  Print("g = Flatten(Raise(g)) for all elements g  of the original group:\n");
  #for providing count info
  c := 0;
  n := Order(OriginalStructureOf(decomp));
  #do a full check for the group
  for g in OriginalStructureOf(decomp) do
    g_ := AsPermutation(AsCascadedTrans(g,decomp),decomp);
    if g <> g_ then
      Print("FAIL\n");
      Error("Lagrange test1a YEAST problem! ", g , "<>",g_ ,"\n");
    else
      c := c+1;
      Print("\r", c,"/",n,"\c");
    fi;
  od;
  Print(" PASSED\n");
end;

#########################################################################
# Similarly for states
LagrangeTest1b := function(decomp)
local s,n,c;
  Print("TEST 1B:  YEAST for points._________________________________\n");
  Print("p = Flatten(Raise(p)) for all points p of the original group:\n");
  #for providing count info
  c := 0;
  n := Size(MovedPoints(OriginalStructureOf(decomp)));
  #do a full check for tof the state set
  for s in MovedPoints(OriginalStructureOf(decomp)) do
    if s <> AsPoint(AsCoords(s,decomp),decomp) then
      Print("FAIL\n");Error("Lagrange test1b YEAST problem!\n");
    else
      c := c+1;
      Print("\r", c,"/",n,"\c");
    fi;
  od;
  Print(" PASSED\n");
end;

#########################################################################
# and for actions
LagrangeTest1c := function(decomp)
local s,g,s_,g_,n,c;
  Print("TEST 1C: YEAST for actions.______________________________________\n");
  Print("p ^ g = Flatten( Raise(p) ^ Raise(g) ) for all points p and permutations g:\n");
  #for providing count info
  c := 0;
  n := Size(MovedPoints(OriginalStructureOf(decomp)))
       *Order(OriginalStructureOf(decomp));
  for g in OriginalStructureOf(decomp) do
    g_ := AsCascadedTrans(g, decomp);
    for s in MovedPoints(OriginalStructureOf(decomp)) do
      s_ := AsCoords(s,decomp);
      if s^g <> AsPoint(s_ ^ g_, decomp) then
        Print("FAIL\n");Error("Lagrange test1c YEAST problem!\n");
      else
        c := c+1;
        Print("\r", c,"/",n,"\c");
      fi;
    od;
  od;
  Print(" PASSED\n");
end;

#########################################################################
# and for group multiplication
LagrangeTest1d := function(decomp)
local h,g,h_,g_,n,c;
  Print("TEST 1D: YEAST for multiplication.______________________________________\n");
  Print("g * h = Flatten( Raise(g) * Raise(h) ) for all permutation pairs g and h:\n");
  #for providing count info
  c := 0;
  n := Order(OriginalStructureOf(decomp)) ^ 2; 

  for g in OriginalStructureOf(decomp) do
    g_ := AsCascadedTrans(g,decomp);
    for h in OriginalStructureOf(decomp) do
      h_ := AsCascadedTrans(h,decomp);
      if g*h <> AsPermutation(g_ * h_, decomp) then
        Print("FAIL\n");Error("Lagrange test1d YEAST problem!\n"); 
      else 
        c := c+1;
        Print("\r", c,"/",n,"\c");
      fi;    
    od;
  od;
  Print(" PASSED\n");
end;




#########################################################################
## Basically taking all paths as the right regular representation and do the multiplication there.
LagrangeTest2 := function(decomp)
local g,path_of_g, path_of_gh,decoded,h,ghprime,n,c;
  Print("TEST 2: Paths as the Right-Regular representation.______________\n");
  if Order(OriginalStructureOf(decomp)) <> Size(AllCoords(CascadeShellOf(decomp))) then
    Print("NOT APPLICABLE! Order of group and number of paths do not match!\n");
    return;
  fi; 
  #for providing count info
  c := 0;
  n := Order(OriginalStructureOf(decomp)) ^ 2; 
  #do a full check
  for g in OriginalStructureOf(decomp) do
    path_of_g := Perm2Coords(decomp,g);
    #no we have cascs2 as the path representing g, let's multiply it with h
    for h in OriginalStructureOf(decomp) do
      path_of_gh := path_of_g ^ AsCascadedTrans(h,decomp);
      #convert the path back to a permutation
      ghprime := Coords2Perm(decomp,path_of_gh);
 
      if g*h <> ghprime then 
        Print("FAIL\n");Error("Lagrange test2 problem!\n");
      else 
        c := c+1;
        Print("\r", c,"/",n,"\c");
      fi;    
    od;#h
  od;#g
  Print(" PASSED\n");
end;

#########################################################################
## Killing by levels.
LagrangeTest3 := function(decomp)
local i,j,path,decoded,killers,n,c;
  Print("TEST 3: Killing by levels.______________________________________\n");
  c := 0;
  n := Size(AllCoords(CascadeShellOf(decomp)));
  #do a full check
  for path in AllCoords(CascadeShellOf(decomp)) do
    killers := LevelKillers(decomp,path);
    for i in [1..Length(decomp)] do
      path := path ^ AsCascadedTrans(killers[i],decomp);
      #checking
      for j in [1..i] do
        if path[j] <> 1 then Print("FAIL\n");Error("Lagrange test3 problem!\n");
	else
	fi;
      od;
    od;
    c := c+1;
    Print("\r", c,"/",n,"\c");
  od;
  Print("PASSED\n");
end;

#######################################
LagrangeTest4 := function(decomp) #TODO it does not work for cyclic groups
local G,liftedgens,g,liftedG;
  G := OriginalStructureOf(decomp);
  Print("Test 4: Isomorphism check");
  liftedgens := [];
  for g in GeneratorsOfGroup(G) do
    Add(liftedgens,
	AsCascadedTrans(g,decomp));
  od;

  liftedG := Group(liftedgens);
  if IsomorphismGroups(G,liftedG) = fail then
    Print("FAIL\n");Error("Lagrange test4 problem!\n");
  fi;
  Print("PASSED\n");
  return liftedG;
end;


#######################################
LagrangeTest5 := function(decomp) 
local states,x,y,x_,y_,taxi,c,n;


  Print("Test 5: x2y check\n");
  c := 0;
  n := Size(MovedPoints(OriginalStructureOf(decomp))) ^ 2;


states := MovedPoints(OriginalStructureOf(decomp));

for x in states do
  for y in states do
    x_ := AsCoords(x,decomp);
    y_ := AsCoords(y,decomp);
    taxi := x2y(decomp,x_,y_);
    if y = x ^ taxi then 
      c := c+1;
      Print("\r", c,"/",n,"\c");
    else  
      Print("FAIL\n");Error("Lagrange test4 problem!\n");
    fi;
  od;
od;

  Print(" PASSED\n");

end;
