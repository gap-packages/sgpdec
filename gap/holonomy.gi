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
local holrec,depth,rep,grpcomps,coords,d,t,tiles;
  # 1. put the skeleton into the record
  holrec := rec(sk:=skeleton);
  # 2. get the group components
  holrec.n := DegreeOfTransformationSemigroup(TransSgp(skeleton));
  holrec.domain :=
    DomainOf(IdentityCascade(
            HolonomyPermutationResetComponents(skeleton))); #TODO this is clumsy
  holrec.compdoms := ComponentDomains(
                             HolonomyPermutationResetComponents(skeleton));
  return holrec;
end);

################################################################################
# CODING OF THE HOLONOMY COMPONENT STATES ######################################

# CODEC: INTEGERS <--> SETS
# Though the coordinate values are elements of the cover of a representative,
# it still has to be converted to integers

# figures out that which slot its representative belongs to (on the same level)
GetSlot := function(set,hd)
  return Position(RepresentativeSets(hd.sk)[DepthOfSet(hd.sk,set)],
                 RepresentativeSet(hd.sk,set));
end;

# decoding: integers -> sets, integers simply code the positions hd.coordvals
InstallGlobalFunction(HolonomyInts2Sets,
function(hd, ints)
local sets, level;
  sets := [];
  for level in [1..Length(ints)] do
      if ints[level] = 0 then
          Add(sets,0); #zero if the level is jumped over
        else
          # the set at the position coded by the integer
          Add(sets,CoordVals(hd.sk)[level][ints[level]]);
      fi;
  od;
  return sets;
end);

# encoding: sets -> integers, we need to find the set in the right slot
InstallGlobalFunction(HolonomySets2Ints,
function(hd, sets)
local set,level,ints,slot, sk;
  sk := hd.sk;
  set := BaseSet(sk);
  ints := [];
  for level in [1..Length(sets)] do
    if sets[level] = 0 then
      Add(ints,0);
    else
      slot := GetSlot(set, hd); #TODO how can we make sure about the right slot?
      Add(ints,Position(CoordVals(hd.sk)[level],
              sets[level],
              Shifts(hd.sk)[level][slot]));
      set := sets[level];
    fi;
  od;
  return ints;
end);

#####
# CHAIN <-> COORDINATES
# sets (elements of representative covers) -> elements of a cover chain
# moving between the encoded set and the representative

# basically the following 2 functions are iterated to choose a set from the
# cover of a representative or another equivalent set

#we map  a representative cover set to a cover set of P
RealTile := function(reptile, P, skeleton)
  return OnFiniteSets(reptile , GetIN(skeleton, P));
end;

#we map  a cover set of P to a cover set of Rep(P)
RepTile := function(realcover, P, skeleton)
  return OnFiniteSets(realcover , GetOUT(skeleton, P));
end;

# (successive approximation)
InstallGlobalFunction(TileChain,
function(hd, coordinates)
local chain,P,depth,skeleton;
  skeleton := hd.sk;
  chain := [];
  depth := 1;
  P := BaseSet(skeleton); #we start to approximate from the top set
  while depth < DepthOfSkeleton(skeleton) do
    #we go from the cover of the rep to the cover of the chain element
    P := RealTile(coordinates[depth],P,skeleton);
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
  sets := List([1..DepthOfSkeleton(skeleton)-1], x->  0);
  P := BaseSet(skeleton);
  #the chain can be shorter (already jumped over), so it is OK go strictly by i
  for i in [1..Length(chain)] do
    sets[DepthOfSet(skeleton, P)] := RepTile(chain[i], P, skeleton);
    P := chain[i];
  od;
  return sets;
end);

#all coordinate lifts of a point
InstallGlobalFunction(AllHolonomyLifts,
function(hd, point)
local sk;
  sk := hd.sk;
  return List(AllTileChainsToSet(sk, FiniteSet([point],hd.n)),
            c -> HolonomySets2Ints(hd,Coordinates(hd,c)));
end);

################################################################################
# IMPLEMENTED METHODS FOR ABSTRACT DECOMPOSITION ###############################
InstallGlobalFunction(Interpret,
function(hd,level,state)
  return CoordVals(hd.sk)[level][state];
end);
#AsPoint
AsHolonomyPoint :=
#    "flatten a cascaded state",
#    true,
#    [IsDenseList,IsRecord],
function(cs,hd)
  local coverchain;
  coverchain := TileChain(hd, HolonomyInts2Sets(hd,cs));
  # extracting the singleton element from the cover chains
  return ListBlist([1..hd.n],coverchain[Length(coverchain)])[1];
end;#);

AsHolonomyCoords :=
#    "raise a flat state into holonomy decomposition",
#    true,
#    [IsInt, IsRecord],
function(k,hd)
  return HolonomySets2Ints(hd,
                 Coordinates(hd,
                         RandomTileChain(hd.sk,k)));
end;#);

IsConstantMap := function(t)
  return RankOfTransformation(t)=1;
end;

# special action for holonomy int coordinates dealing with 0s and constant maps
OnHolonomyCoordinates:= function(coords, ct)
local dfs, copy, out, len, i, action;
  dfs:=DependencyFunctionsOf(ct);
  len:=Length(coords);
  copy:=EmptyPlist(len);
  out:=EmptyPlist(len);
  for i in [1..len] do
    action := copy^dfs[i];
    if coords[i]=0 then
      if IsTransformation(action) and IsConstantMap(action) then
        out[i] := 1^action;
      else
        out[i] := 0;
      fi;
      copy[i]:=1; #padding with 1: it is precarious but works
    else
      out[i]:=coords[i]^action;
      copy[i]:=coords[i];
    fi;
  od;
  return out;
end;

# creating the permutation action on the tiles, shifted properly to the slot
PermutationOfTiles := function(action, depth, slot, hd)
  local tileaction, shift, width;
  tileaction := ImageListOfTransformation(
                        TransformationOp(action,
                                TileCoords(hd.sk)[depth][slot],
                                OnFiniteSets));
  #technical bit: shifting the action to the right slot
  shift := Shifts(hd.sk)[depth][slot];
  width := Size(CoordVals(hd.sk)[depth]);
  return Transformation(Concatenation(
                 [1..shift],
                 tileaction + shift,
                 [shift+Size(tileaction)+1..width]));
end;

#looking for a tile that contain the given set on a given level in a given slot
#then creating a constant map resetting to that tile
ConstantMapToATile := function(set, depth, slot, hd)
  local pos, width;
  pos := Shifts(hd.sk)[depth][slot]+1;
  while not (IsSubsetBlist(CoordVals(hd.sk)[depth][pos],set)) do
    pos := pos + 1;
  od;
  width := Size(CoordVals(hd.sk)[depth]);
  return Transformation(List([1..width],x->pos));
end;

# investigate how s acts on the given states
# returns a list of component actions, one for each level
# P represents a tilechain and we hit it by s so we get a subset chain
# and Q approximates the subset chain with a non-unique tile chain
InstallGlobalFunction(HolonomyComponentActions,
function(hd,s,coords)
local action,
      actions,
      depth,
      P,
      Q,
      Ps,
      ncoordval,
      sk,
      j,
      slot,
      set;
  sk := hd.sk; #it is used often so it's better to have it
  #initializing actions to identity
  actions := List([1..DepthOfSkeleton(sk)-1],
                  x -> One( HolonomyPermutationResetComponents(hd.sk)[x]));
  #initial successive approximation are the same for both
  P := BaseSet(sk);
  Q := P;
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if DepthOfSet(sk, Q) = depth then # we are on the right level
      slot := GetSlot(Q,hd);
      Ps := OnFiniteSets(P,s);
      if Ps = Q then #PERMUTATION###############################################
        # roundtrip: from the rep to P, then to Ps=Q, then back to Q's rep
        action := GetIN(sk,P) * s * GetOUT(sk,Q);
        # calculating the action on the covers
        actions[depth] := PermutationOfTiles(action, depth, slot, hd);
        # also, what happens to Q under s TODO is this really Qs???
        ncoordval := OnFiniteSets(coords[depth], action);
      elif IsSubsetBlist(Q,Ps)  then #CONSTANT MAP##############################
        #look for a tile of Q that contains Ps
        set := RepTile(Ps,Q,sk);
        actions[depth] := ConstantMapToATile(set, depth,slot, hd);
        ncoordval:=CoordVals(hd.sk)[depth][1^actions[depth]];# applying the constant
      else
        #this not supposed to happen, but still here until further testing
        Print(depth," HEY!!! ",TrueValuePositionsBlistString(P),"*",s,"=",
              TrueValuePositionsBlistString(Ps),"but Q=",
              TrueValuePositionsBlistString(Q),"\n");
      fi;
      # ncoordval is a tile of rep Q and we send it to a tile of Q
      Q := RealTile(ncoordval, Q, sk);
    fi;
    #if we are on the right level for P
    if DepthOfSet(sk,P) = depth then
      # P is replaced by a cover set of itself
      P:= RealTile(coords[depth],P,sk);
    fi;
  od;
  # paranoid check whether the action is in the component
  if SgpDecOptionsRec.PARANOID then
    for depth in [1..DepthOfSkeleton(sk)-1] do
      if not actions[depth] in  HolonomyPermutationResetComponents(hd.sk)[depth] then
        Error("Alien component action!");
      fi;
    od;
  fi;
  return actions;
end);

InstallGlobalFunction(HolonomyCascadeSemigroup,
function(ts)
  local hd, S;
  hd := HolonomyDecomposition(Skeleton(ts));
  S := Semigroup(List(GeneratorsOfSemigroup(ts),
               t->Cascade( HolonomyPermutationResetComponents(hd.sk),
                       HolonomyDependencies(hd,t))));
  SetHolonomyDecompositionOf(S,hd);
  SetGroupComponents(S,GroupComponents(hd.sk));
  SetComponentsOfCascadeProduct(S, HolonomyPermutationResetComponents(hd.sk));
  SetIsHolonomyCascadeSemigroup(S,true);
  return S;
end);

#this just enumerates the tile chains, convert to coordinates,
#calls for the component actions, and records if nontrivial
InstallGlobalFunction(HolonomyDependencies,
function(hd, t)
local i,state,sets,actions,depfuncs,holdom,cst;
  #identity needs no further calculations
  #if IsOne(t) then return [];fi;
  depfuncs := [];
  #we go through all states
  holdom := Union(List([1..hd.n], i -> AllHolonomyLifts(hd,i)));
  #padding with 1: it is precarious but works
  #holdom := List(holdom,
  #               x->List(x,
  #                      function(i)if i=0 then return 1;else return i;fi;end));
  #Print(holdom,"cukki\c\n");
  for state in holdom do
    sets := HolonomyInts2Sets(hd,state);
    #get the component actions on a state
    actions := HolonomyComponentActions(hd, t, sets);
    #examine whether there is a nontrivial action, then add
    for i in [1..Length(actions)] do
      if not IsOne(actions[i]) then
        #Display(state{[1..(i-1)]});
        if i = 1 then
          AddSet(depfuncs,[[],actions[1]]);
        else
          for cst in AllConcreteCoords(hd.compdoms,state{[1..(i-1)]}) do
            #Print("-"); Display(cst);
            #AddSet(depfuncs,[cst,actions[i]]);
            AddSet(depfuncs,[cst,actions[i]]);
          od;
        fi;
      fi;
    od;
  od;
  return depfuncs; #TODO maybe sort them into a graded list
end);

InstallGlobalFunction(AsHolonomyCascade,
function(t,hd)
  return Cascade( HolonomyPermutationResetComponents(hd.sk),
                 HolonomyDependencies(hd,t));
end);

InstallGlobalFunction(AsHolonomyTransformation,
function(co,hd)
local l, i;
  l := [];
  for i in ListBlist([1..hd.n],
          BaseSet(hd.sk)) do
    l[i]:=AsHolonomyPoint(OnHolonomyCoordinates(AsHolonomyCoords(i,hd),co),hd);
  od;
  return Transformation(l);
end);

# cascade to ts
InstallOtherMethod(HomomorphismTransformationSemigroup, "for a cascade product",
[IsHolonomyCascadeSemigroup],
function(cS)
  local T,hd,f;
  hd := HolonomyDecompositionOf(cS);
  f := c -> AsHolonomyTransformation(c, hd);
  T:=Semigroup(List(GeneratorsOfSemigroup(cS),f));
  return MappingByFunction(cS,T,f);
end);

# ts to cascade
HolonomyLifting := function(S)
  local cS,hd,f;
  cS := HolonomyCascadeSemigroup(S);
  hd := HolonomyDecompositionOf(cS);
  f := t -> AsHolonomyCascade(t, hd);
  return MappingByFunction(S,cS,f);
end;

#TODO does this work?
#changing the representative
#InstallGlobalFunction(ChangeCoveredSet,
#function(hd, set)
#local skeleton,oldrep, pos, depth,i, tiles;
#  if IsSingleton(set) then
#    Print("#W not changing singleton representative\n");return;
#  fi;
#  skeleton := hd.sk;
#  oldrep := RepresentativeSet(skeleton,set);
#  ChangeRepresentativeSet(skeleton,set);
#  depth := DepthOfSet(skeleton, set);
#  pos := Position(hd.reps[depth], oldrep);
#  hd.reps[depth][pos] := set;
#  tiles := TilesOf(skeleton, set);
#  for i in [1..Length(tiles)] do
#    CoordVals(hd.sk)[depth][Shifts(hd.sk)[depth][pos]+i] := tiles[i];
#  od;
#end);

################################################################################
# HOLONOMY ACCESS
################################################################################
# TODO slated for removal
InstallGlobalFunction(UnderlyingSetsForHolonomyGroups,
function(holonomycascadesgp)
  return HolonomyDecompositionOf(holonomycascadesgp).reps;
end);

InstallGlobalFunction(UnderlyingSetsForHolonomyGroupsOnDepth,
function(holonomycascadesgp, depth)
  return HolonomyDecompositionOf(holonomycascadesgp).reps[depth];
end);

################################################################################
# REIMPLEMENTED GAP OPERATIONS #################################################

NumOfPointsInSlot := function(hd, level, slot)
  return Shifts(hd.sk)[level][slot+1] - Shifts(hd.sk)[level][slot];
end;
MakeReadOnlyGlobal("NumOfPointsInSlot");

#detailed print of the components
InstallMethod(DisplayString,"for a holonomy decomposition",
        [ IsHolonomyCascadeSemigroup ],
function(HCS)
  local groupnames,level, i,l,groups,hd,str;;
  hd := HolonomyDecompositionOf(HCS);
  groupnames := [];
  for level in [1..DepthOfSkeleton(hd.sk)-1] do
    l := [];
    groups := GroupComponents(HCS)[level];
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
  str := "";
  for i in [1..Length(groupnames)] do
    Append(str, Concatenation(String(i),":"));
    Perform(groupnames[i], function(x) Append(str,Concatenation(" ",x));end);
    Append(str,"\n");
  od;
  return str;
end);
