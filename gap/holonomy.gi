#############################################################################
##
## holonomy.gi           SgpDec package
##
## Copyright (C) 2010-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## A hierarchical decomposition: Holonomy coordinatization of semigroups.
##

################################################################################
# CONSTRUCTING HOLONOMY PERMUTATION RESET SEMIGROUPS ###########################

#shifts the points of the action
# 1st arg G - permutation group,
# 2nd arg shift - the amount the action is shifted by
InstallGlobalFunction(ShiftGroupAction,
function(G,shift)
local gens,origens,i,j,n;
  n := LargestMovedPoint(G);
  origens := GeneratorsOfGroup(G);
  gens := List(origens, x -> [1..n+shift]);#identity maps
  for i in [1..n] do
    for j in [1..Size(gens)] do
      gens[j][i+shift] := OnPoints(i,origens[j]) + shift;
    od;
  od;
  return Group(List(gens, x -> PermList(x)));
end);

#constructing a transformation semigroup out of a list of groups + constant maps
# 1st arg: list of permutation groups
# 2nd arg: optional, vector of shifts, ith entry tells how much
# the ith grouph is to be shifted, the last element tells the total
# number of points to act on
# if your shift vector contains overlaps, then you get something funny
InstallGlobalFunction(PermutationResetSemigroup,
function(arg)
  local gens,shiftedgroups,groups,shifts,n;
  groups := arg[1];
  #get the shifts from the second argument
  if IsBound(arg[2]) then
    shifts := arg[2];
  else
    shifts := [0];
    Perform(groups,
            function(G)
              Add(shifts, shifts[Length(shifts)] + LargestMovedPoint(G));
            end);
  fi;
  n := shifts[Length(shifts)];
  #now shift the groups
  shiftedgroups := List([1..Size(groups)],
                        i->ShiftGroupAction(groups[i],shifts[i]));
  #add the permutation generators
  gens := [];
  Perform(shiftedgroups, function(G)
    Append(gens,List(GeneratorsOfGroup(G),x -> AsTransformation(x,n)));end);
  #the resets (constant maps)
  Perform([1..n], function(i)
    Add(gens, Transformation(ListWithIdenticalEntries(n,i)));end);
  return SemigroupByGenerators(gens);
end);

################################################################################
# CONSTRUCTOR ##################################################################
InstallGlobalFunction(HolonomyDecomposition,
function(skeleton)
local holrec,depth,rep,groups,coords,n,reps, shift, shifts,t,coversets;
  # 1. put the skeleton into the record
  holrec := rec(sk:=skeleton);
  holrec.original := skeleton.ts;

  # 2. get the group components
  Info(HolonomyInfoClass, 2, "HOLONOMY"); t := Runtime();
  n := DepthOfSkeleton(holrec.sk) - 1;
  holrec.d := n;
  holrec.n := DegreeOfTransformationSemigroup(skeleton.ts);
  holrec.groupcomponents := [];
  holrec.reps := [];
  holrec.coords := [];
  holrec.allcoords := [];
  holrec.shifts := [];
  for depth in [1..n] do
    groups := [];
    coords := [];
    reps := [];
    shifts := [];
    shift := 0;
    Add(shifts,shift);

    Info(HolonomyInfoClass, 2, "Component(s) on depth ",depth); t := Runtime();
    for rep in RepresentativesOnDepth(holrec.sk,depth) do
      coversets := CoveringSetsOf(holrec.sk,rep);
      Add(groups,HolonomyGroup@(holrec.sk, rep));#stored unshifted
      shift := shift + Size(coversets);
      Add(shifts,shift);
      Add(reps,rep);
      Add(coords,coversets);
      Info(HolonomyInfoClass, 2, "  ",
           StructureDescription(groups[Length(groups)])," ",
           FormattedTimeString(Runtime() -t));t := Runtime();
    od;
    Add(holrec.shifts, shifts);
    Add(holrec.groupcomponents,groups);
    Add(holrec.reps, reps);
    Add(holrec.coords,coords);
    Add(holrec.allcoords,Concatenation(coords));
  od;
  holrec.comps := List([1..Length(holrec.groupcomponents)],
                       x -> PermutationResetSemigroup(holrec.groupcomponents[x],
                               holrec.shifts[x]));
  holrec.domain := DomainOf(IdentityCascade(holrec.comps)); #TODO this is clumsy
  return holrec;
end);

################################################################################
# CODING OF THE HOLONOMY COMPONENT STATES ######################################

# CODEC: INTEGERS <--> SETS
# Though the coordinate values are elements of the cover of representative,
# it still has to be converted to integers, so  a cascade shell can be built
# decoding: integers -> sets
InstallGlobalFunction(HolonomyInts2Sets,
function(hd, ints)
local sets, level;
  sets := [];
  for level in [1..Length(ints)] do
      if ints[level] = 0 then
          Add(sets,0); #zero if the level is jumped over
        else
          # the set at the position coded by the integer
          Add(sets,hd.allcoords[level][ints[level]]);
      fi;
  od;
  return sets;
end);

# encoding: sets -> integers
InstallGlobalFunction(HolonomySets2Ints,
function(hd, sets)
local rep,level,ints,slot, sk;
  sk := hd.sk;
  rep := TopSet(sk);
  ints := [];
  for level in [1..Length(sets)] do
    if sets[level] = 0 then
      Add(ints,0);
    else
      # TODO rep seems to be a misnomer here
      slot := Position(hd.reps[DepthOfSet(sk,rep)], RepresentativeSet(sk,rep));
      Add(ints,Position(hd.allcoords[level],
              sets[level],
              hd.shifts[level][slot]));
      rep := sets[level]; #a hack to get the proper duplicated covering_set
    fi;
  od;
  return ints;
end);

#####
# CHAIN <-> COORDINATES
# sets (elements of representative covers) -> elements of a cover chain
# (successive approximation)
InstallGlobalFunction(CoverChain,
function(hd, coordinates)
local chain,P,depth,skeleton;
  skeleton := hd.sk;
  P := TopSet(skeleton); #we start to approximate from the top set
  chain := [];
  depth := 1;
  while depth <= hd.d do
    #we go from the cover of the rep to the cover of the chain element
    P := OnFiniteSets(coordinates[depth] , GetIN(skeleton, P));
    Add(chain,P);
    depth :=  DepthOfSet(skeleton,P);
  od;
  return chain;
end);

#the inverse of successive approximation
InstallGlobalFunction(Coordinates,
function(hd, chain)
local sets,i, P, skeleton;
  skeleton := hd.sk;
  #filling up with zeros - jumped over levels are abstract
  sets := List([1..hd.d], x->  0);
  P := TopSet(skeleton);
  #the chain can be shorter (already jumped over), so it is OK go strictly by i
  for i in [1..Length(chain)] do
    sets[DepthOfSet(skeleton, P)] := OnFiniteSets(chain[i], GetOUT(skeleton,P));
    P := chain[i];
  od;
  return sets;
end);

#all coordinate lifts of a point
InstallGlobalFunction(AllHolonomyLifts,
function(hd, point)
local sk;
  sk := hd.sk;
  return List(AllCoverChainsToSet(sk, FiniteSet([point],sk.degree)),
            c -> HolonomySets2Ints(hd,Coordinates(hd,c)));
end);

################################################################################
# IMPLEMENTED METHODS FOR ABSTRACT DECOMPOSITION ###############################
InstallGlobalFunction(Interpret,
function(hd,level,state)
  return hd.allcoords[level][state];
end);
#AsPoint
AsHolonomyPoint :=
#    "flatten a cascaded state",
#    true,
#    [IsDenseList,IsRecord],
function(cs,hd)
  local coverchain;
  coverchain := CoverChain(hd, HolonomyInts2Sets(hd,cs));
  return ListBlist([1..hd.n],coverchain[Length(coverchain)])[1];
end;#);

AsHolonomyCoords :=
#    "raise a flat state into holonomy decomposition",
#    true,
#    [IsInt, IsRecord],
function(k,hd)
  return HolonomySets2Ints(hd,
                 Coordinates(hd,
                         RandomCoverChain(hd.sk,k)));
end;#);

InstallGlobalFunction(HolonomyComponentActions,
function(hd,s,states)
local action,
      pos,
      actions,
      depth,
      P,
      Q,
      Ps,
      Qs,
      sk,
      j,
      coversetaction,
      slot,
      set,
      shift,
      width;
  sk := hd.sk; #it is used often so it's better to have it
  #initializing actions to identity
  actions := List([1..hd.d], x -> One(hd.comps[x]));
  #initial successive approximation are the same for both
  P := TopSet(sk);
  Q := P;
  for depth in [1..hd.d] do
    if DepthOfSet(sk, Q) = depth then # we are on the right level
      slot := Position(hd.reps[depth], RepresentativeSet(sk, Q));
      Ps := OnFiniteSets(P , s);
      if Ps = Q then #PERMUTATION
        action := GetIN(sk,P)
                  * s
                  * GetOUT(sk,Q);
        Qs := OnFiniteSets(states[depth], action);
        # calculating the action on the covers
        coversetaction := ImageListOfTransformation(TransformationOp(action,
                                  hd.coords[depth][slot],
                                  OnFiniteSets));
        shift := hd.shifts[depth][slot];
        width := Size(hd.allcoords[depth]);
        actions[depth]:=Transformation(Concatenation(
                                [1..shift],
                                coversetaction + shift,
                                [shift+Size(coversetaction)+1..width]));
        # paranoid check whether the action is in the component
        if SgpDecOptionsRec.PARANOID then
          if not actions[depth] in hd.comps[depth] then
            Error("Alien component action!");
          fi;
        fi;
      elif IsSubsetBlist(Q,Ps)  then #CONSTANT MAP
            #look for a tile of Q that contains
        set := OnFiniteSets(Ps , GetOUT(sk,Q));
        pos := hd.shifts[depth][slot] +1;
        while not (IsSubsetBlist(hd.allcoords[depth][pos],set)) do
          pos := pos + 1;
        od;
        actions[depth] := Transformation(
                                  List([1..Length(hd.allcoords[depth])],
                                       x->pos));
        Qs :=  hd.allcoords[depth][pos];
      else
        #this not supposed to happen, but still here until further testing
        Print(depth, "HEY!!! ",P, " * ", s ," = ", Ps, " but Q= ",Q,"\n" );
      fi;
      Q :=  OnFiniteSets(Qs , GetIN(sk,Q));
    fi; #if we are on the right level for Q

    if DepthOfSet(sk,P) = depth then
      P:= OnFiniteSets(states[depth] , GetIN(sk, P));
    fi;
  od;
  return actions;
end);

InstallGlobalFunction(HolonomyCascadeSemigroup,
function(ts)
  local hd;
  hd := HolonomyDecomposition(Skeleton(ts));
  return Semigroup(List(GeneratorsOfSemigroup(ts),
                 t->Cascade(hd.comps,
                         HolonomyDependencies(hd,t))));
end);

InstallGlobalFunction(HolonomyDependencies,
function(hd, t)
local i,state,sets,actions,depfuncs;
  #identity needs no further calculations
  #if IsOne(t) then return [];fi;
  depfuncs := [];
  #we go through all states
  for state in hd.domain do
    sets := HolonomyInts2Sets(hd,state);
    #get the component actions on a state
    actions := HolonomyComponentActions(hd, t, sets);
    #examine whether there is a nontrivial action, then add
    for i in [1..Length(actions)] do
      if not IsOne(actions[i]) then
        AddSet(depfuncs,[state{[1..(i-1)]},actions[i]]);
      fi;
    od;
  od;
  return depfuncs; #TODO maybe sort them into a graded list
end);


#this just enumerates the tile chains, convert to coordinates,
#calls for the component actions, and records if nontrivial

# ENA this will go to AsCascadedTrans

AsHolonomyCascade :=
function(t,decomp)
  return Cascade(decomp.comps,HolonomyDependencies(decomp,t));
end;

AsTrans :=
function(co,hd)
local l, i;
  l := [];
  for i in ListBlist([1..DegreeOfTransformationSemigroup(hd.original)],TopSet(hd.sk)) do
    l[i] := AsHolonomyPoint(OnCoordinates(AsHolonomyCoords(i,hd),co),hd);
  od;
  return Transformation(l);
end;

#Flattening the whole decomposition (gives back the original semigroup)
#TODO this should be wrapped in the semigroup homomorphism
#AsSgp :=
#function( hd )
#    local g,gens;
#    gens := [];
#    for g in GeneratorsOfSemigroup(hd.original) do
#        Add(gens,AsTrans(AsCascadedTrans(g,hd)));
#    od;
#    return Semigroup(gens);
#end;

################################################################################
# ACCESS FUNCTIONS #############################################################
InstallGlobalFunction(GroupComponentsOnDepth,
function(hd, depth) return hd.groupcomponents[depth];end);

#changing the representative
InstallGlobalFunction(ChangeCoveredSet,
function(hd, set)
local skeleton,oldrep, pos, depth,i, coversets;
  if IsSingleton(set) then
    Print("#W not changing singleton representative\n");return;
  fi;
  skeleton := hd.sk;
  oldrep := RepresentativeSet(skeleton,set);
  ChangeRepresentativeSet(skeleton,set);
  depth := DepthOfSet(skeleton, set);
  pos := Position(hd.reps[depth], oldrep);
  hd.reps[depth][pos] := set;
  coversets := CoveringSetsOf(skeleton, set);
  for i in [1..Length(coversets)] do
    hd.allcoords[depth][hd.shifts[depth][pos]+i] := coversets[i];
  od;
  #TODO!! we may have lost the CoverGroup's mapping
  #to coordinate points as integers, but for the time being
  #it does not seem to matter
end);

################################################################################
# REIMPLEMENTED GAP OPERATIONS #################################################


#InstallMethod(PrintObj,"for a holonomy decomposition",
#        [ IsRecord ],
#function( hd )
#  Print("<holonomy decomposition of ",hd.original, ">");
#end);

NumOfPointsInSlot := function(hd, level, slot)
  return hd.shifts[level][slot+1] - hd.shifts[level][slot];
end;
MakeReadOnlyGlobal("NumOfPointsInSlot");

#detailed print of the components
DisplayHolDec := #,"for a holonomy decomposition",
        #[ IsRecord ],
function(hd)
  local groupnames,level, i,l,groups;
  groupnames := [];
  for level in [1..hd.d] do
    l := [];
    groups := GroupComponentsOnDepth(hd, level);
    for i in [1..Length(groups)]  do
      if IsTrivial(groups[i]) then
        Add(l, String(NumOfPointsInSlot(hd,level,i)));
      elif SgpDecOptionsRec.SMALL_GROUPS then
        Add(l, Concatenation("(",String(NumOfPointsInSlot(hd,level,i)),
                ",", StructureDescription(groups[i]),")"));
      else
        Add(l, Concatenation("(",String(NumOfPointsInSlot(hd,level,i)),
                ",G", String(Order(groups[i])),")"));
      fi;
    od;
    Add(groupnames,l);
  od;
  for i in [1..Length(groupnames)] do
    Print(i,":");
    Perform(groupnames[i], function(x) Print(" ",x);end);
    Print("\n");
  od;
end;#);
