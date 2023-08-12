################################################################################
##
## holonomy.gi           SgpDec package
##
## Copyright (C) 2008-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## A hierarchical decomposition: Holonomy coordinatization of transformation
## semigroups.
##

################################################################################
# CODING OF THE HOLONOMY COMPONENT STATES ######################################

# CODEC: INTEGERS <--> SETS
# The coordinate values are subsets of the state set (the tiles of a 
# representative subsets). However, in order to define transformations of them
# we need to encode them by integers.

# figures out that which slot its representative belongs to (on the same level)
# choosing a parallel component
# finding the position of the representative set on the depth of the input
GetSlot := function(set,sk)
  return Position(RepresentativeSets(sk)[DepthOfSet(sk,set)],
                 RepresentativeSet(sk,set));
end;
MakeReadOnlyGlobal("GetSlot");

# decoding: integers -> sets, integers simply code the positions in CoordVals
InstallGlobalFunction(HolonomyInts2Sets,
function(sk, ints)
  return List([1..Length(ints)],
              level -> CoordVals(sk)[level][ints[level]]);
end);

# encoding: sets -> integers, we need to find the set in the right slot
InstallGlobalFunction(HolonomySets2Ints,
function(sk, sets)
local set,level,ints,slot;
  set := BaseSet(sk);
  ints := EmptyPlist(Size(sets));
  for level in [1..Length(sets)] do
    if IsBlist(sets[level]) then
      slot := GetSlot(set, sk);
      ints[level] := Position(CoordVals(sk)[level],
                             sets[level],
                             Shifts(sk)[level][slot]);
      set := sets[level];
    else
      ints[level] := 1;
    fi;
  od;
  return ints;
end);

#####
# CHAIN <-> COORDINATES
# sets (tiles of representative sets) -> elements of a tile chain
# moving between the encoded set and the representative

# basically the following 2 functions are iterated to choose a set from the
# tiles of a representative set or another equivalent set

#we map  a representative tile to a tile of P
InstallGlobalFunction(RealTile,
function(reptile, P, skeleton)
  return OnFiniteSet(reptile , FromRep(skeleton, P));
end);

#we map  a tile of P to a tile of Rep(P)
InstallGlobalFunction(RepTile,
function(realtile, P, skeleton)
  return OnFiniteSet(realtile , ToRep(skeleton, P));
end);

# decoding: set coordinate values -> tile chain
InstallGlobalFunction(DecodeCoords,
        function(sk, coordinates)
  local chain,P,depth;
  chain := [];
  depth := 1;
  P := BaseSet(sk); #we start to approximate from the top set
  while IsBound(coordinates[depth]) #so it works for prefixes
        and depth < DepthOfSkeleton(sk) do
    P := RealTile(coordinates[depth],P,sk);
    Add(chain,P);
    depth :=  DepthOfSet(sk,P);
  od;
  return chain;
end);

# encoding: tile chain -> set coordinate values
InstallGlobalFunction(EncodeChain,
function(sk, chain)
  local sets,i;
  #filling up with ones - jumped over levels are abstract but we cannot use zero
  sets := ListWithIdenticalEntries(DepthOfSkeleton(sk)-1, 1);
  for i in [2..Length(chain)] do
    sets[DepthOfSet(sk, chain[i-1])] := RepTile(chain[i], chain[i-1], sk);
  od;
  return sets;
end);

# this cuts off the base set TODO almost like EncodeChain
InstallGlobalFunction(PositionedChain,
        function(sk, chain)
  local positioned,i;
  positioned := ListWithIdenticalEntries(DepthOfSkeleton(sk)-1, 1);
  for i in [2..Length(chain)] do
    positioned[DepthOfSet(sk, chain[i-1])] := chain[i];
  od;
  return positioned;
end);

################################################################################
# IMPLEMENTED METHODS FOR ABSTRACT DECOMPOSITION ###############################
InstallGlobalFunction(Interpret,
function(sk,level,state)
  return CoordVals(sk)[level][state];
end);

InstallGlobalFunction(AsHolonomyPoint,
function(cs,sk)
  return ChainRoot(DecodeCoords(sk, HolonomyInts2Sets(sk,cs)));
end);

InstallOtherMethod(AsPoint, "for a coordinate tuple and a skeleton",
                   [IsList, IsSkeleton],
                   AsHolonomyPoint);

# all encoded holonomy coordinate tuples of a state k
AllHolonomyCoords := function(k,sk)
  return List(ChainsBetween(sk,BaseSet(sk),FiniteSet([k],DegreeOfSkeleton(sk))),
              x -> HolonomySets2Ints(sk, EncodeChain(sk,x)));
end;

# just a random holonomy coordinate tuple for a state k
InstallGlobalFunction(AsHolonomyCoords,
function(k,sk)
  return HolonomySets2Ints(sk,
                 EncodeChain(sk,
                         RandomChain(sk,k)));
end);

# we build the dependency function arguments one position at a time from coords
# for efficiency reasons
InstallGlobalFunction(OnHolonomyCoords,
function(coords, ct)
  local dfs, copy, out, len, i, action;
  dfs:=DependencyFunctionsOf(ct);
  len:=Length(coords);
  copy:=EmptyPlist(len); #same as [], but avoids over and re-allocations
  out:=EmptyPlist(len);
  for i in [1..len] do
    action := OnDepArg(copy,dfs[i]); # copy^dfs[i];
    out[i]:=coords[i]^action; #action can be perm or transf
    copy[i]:=coords[i]; # we grow
  od;
  return out;
end);

# creating the permutation action on the tiles, shifted properly to the slot
PermutationOfTiles := function(action, depth, slot, sk)
  local tileaction, shift;
  tileaction := ImageListOfTransformation(
                        TransformationOp(action,
                                TileCoords(sk)[depth][slot],
                                OnFiniteSet));
  #technical bit: shifting the action to the right slot
  shift := Shifts(sk)[depth][slot];
  return Transformation(Concatenation(
                 [1..shift],
                 tileaction + shift));
end;
MakeReadOnlyGlobal("PermutationOfTiles");

#looking for a tile that contain the given set on a given level in a given slot
#the above is not true any more since we do a dominating tile chain first TODO
#then creating a constant map resetting to that tile
ConstantMapToATile := function(subtile, depth, slot, sk)
  local pos; # the position of the tile that contains set
  pos := Position(CoordVals(sk)[depth],subtile,Shifts(sk)[depth][slot]);
  #just a constant transformation pointing to this tile (encoded as an integer)
   return Transformation(List([1..Size(CoordVals(sk)[depth])+1],x->pos));
end;
MakeReadOnlyGlobal("ConstantMapToATile");

# returns the current state of approximations for each level given
# a positioned chain
ApproximationStages := function(sk, ptc)
  local P,result,depth;
  P := BaseSet(sk);
  result := [];
  for depth in [1..DepthOfSkeleton(sk)-1] do
    Add(result,P);
    if depth = DepthOfSet(sk,P) then
      P := ptc[depth];
    fi;
  od;
  return result;
end;
MakeReadOnlyGlobal("ApproximationStages");

# implementing the core idea of holonomy: if we stay in an equivalence class
# then we permute, otherwise choose a tile (which is already chosen by the
# dominating chain)
# P,Q - the current stage of approximations for source and target chains
# Qtile - the chosen tile (for constants), s - the transformation
HolonomyCore := function(sk, P,Q, Qtile,s, depth)
  local Ps;
  Ps := OnFiniteSet(P,s); #TODO this is already in CPs
  if Ps  = Q then #PERMUTATION
    return PermutationOfTiles(FromRep(sk,P) * s * ToRep(sk,Q),#roundtrip
                              depth,GetSlot(Q,sk),sk);
  else #elif IsSubsetBlist(Q, Ps) then #CONSTANT
    # testing for sub is not needed - see HEYBUG story
    return ConstantMapToATile(RepTile(Qtile,Q,sk),
                              depth,GetSlot(Q,sk),sk);
  fi;
end;
MakeReadOnlyGlobal("HolonomyCore");

# investigate how s acts on the given chain CP
# returns a list of encoded component actions, one for each level
InstallGlobalFunction(HolonomyComponentActions,
function(sk, s, CP)
  local star, CPs, # chain CP hit by s
        CQ, # the chain dominating CPs
        depth, # the current depth
        cas, # encoded component actions
        positionedQ, # positioned CQ the get tile of choice
        stagesP, stagesQ; #the current state of approximations in chains CP, CQ
  cas := ListWithIdenticalEntries(DepthOfSkeleton(sk)-1, IdentityTransformation);
  CPs := OnSequenceOfSets(CP,s);
  CQ := DominatingChain(sk,CPs);
  stagesP := ApproximationStages(sk,PositionedChain(sk,CP));
  positionedQ := PositionedChain(sk,CQ);
  stagesQ := ApproximationStages(sk,positionedQ);
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if depth = DepthOfSet(sk,stagesQ[depth]) then
      cas[depth] := HolonomyCore(sk, stagesP[depth], stagesQ[depth],
                            positionedQ[depth], s, depth);
    else
      #jumped over level, we simply choose state 1 for the constant map
      cas[depth] :=  ConstantTransformation(Size(CoordVals(sk)[depth]),1);
    fi;
  od;
  return cas;
end);

InstallMethod(HolonomyCascadeSemigroup, "for a skeleton", [IsSkeleton],
function(sk)
  local S;
  S := Semigroup(List(Generators(TransSgp(sk)), t->AsHolonomyCascade(t,sk)));
  SetSkeletonOf(S,sk);
  SetComponentsOfCascadeProduct(S, HolonomyPermutationResetComponents(sk));
  SetIsHolonomyCascadeSemigroup(S,true);
  return S;
end);

InstallOtherMethod(HolonomyCascadeSemigroup, "for a transformation semigroup", [IsSemigroup],
function(ts)
  return HolonomyCascadeSemigroup(Skeleton(ts));
end);

#this just enumerates the tile chains, convert to coordinates,
#calls for the component actions, and records if nontrivial
InstallGlobalFunction(AsHolonomyCascade,
function(t,sk)
local i,state,actions,depfuncs,cst, cascade,tilechain,holdom;
  depfuncs := [];
  #holdom := [];
  #we go through all tile chains
  if not IsOne(t) then
    for tilechain in Chains(sk) do
      state := HolonomySets2Ints(sk, EncodeChain(sk,tilechain));
      #Add(holdom, state);
      #get the component actions on the tile chain
      actions := HolonomyComponentActions(sk, t, tilechain);
      #examine whether there is a nontrivial action, then add
      for i in [1..Length(actions)] do
        if not IsOne(actions[i]) then
          AddSet(depfuncs,[state{[1..(i-1)]},actions[i]]);
        fi;
      od;
    od;
  fi;
  cascade := Cascade(HolonomyPermutationResetComponents(sk),depfuncs);
  #SetRestrictedDomain(cascade, holdom);
  return cascade;
end);

InstallGlobalFunction(AsHolonomyTransformation,
function(co,sk)
local l, i;
  l := [];
  for i in [1..DegreeOfSkeleton(sk)] do
    l[i]:=AsHolonomyPoint(OnHolonomyCoords(AsHolonomyCoords(i,sk),co),sk);
  od;
  return Transformation(l);
end);

# cascade sg onto the original
InstallOtherMethod(HomomorphismTransformationSemigroup,
        "for a holonomy cascade semigroup",
[IsHolonomyCascadeSemigroup],
function(cS)
  local T,sk,f;
  sk := SkeletonOf(cS);
  f := ct -> AsHolonomyTransformation(ct, sk);
  T:=Semigroup(List(GeneratorsOfSemigroup(cS),f));
  return MappingByFunction(cS,T,f);
end);

# ts to cascade, TODO this is not a set valued morphism yet!!
InstallGlobalFunction(HolonomyRelationalMorphism,
function(S)
  local cS,sk,f;
  cS := HolonomyCascadeSemigroup(S);
  sk := SkeletonOf(cS);
  f := t -> AsHolonomyCascade(t, sk);
  return MappingByFunction(S,cS,f);
end);

################################################################################
# REIMPLEMENTED GAP OPERATIONS #################################################

#detailed print of the components (function body moved to skeletongroups.gi)
InstallMethod(DisplayString,"for a holonomy decomposition",
        [ IsHolonomyCascadeSemigroup ],
function(HCS)
  return DisplayStringHolonomyComponents(SkeletonOf(HCS));
end);

################################################################################
# test functions
# testing the map down
TestHolonomyEmulation := function(sk)
  local hom,hcs;
  hcs := HolonomyCascadeSemigroup(sk);
  hom := HomomorphismTransformationSemigroup(hcs);
  return AsSet(TransSgp(sk)) = AsSet(Range(hom));
end;

TestHolonomyCascadeMultiplication := function(x,y,sk)
  local xcs,ycs,xy,xycs,xyf,matching;
  xcs := AsHolonomyCascade(x,sk);
  ycs := AsHolonomyCascade(y,sk);
  xy := x*y;
  xycs := xcs*ycs;
  xyf := AsHolonomyTransformation(xycs,sk);
  matching := xy = xyf;
  if (not matching) then Print("Expected: ", xy, " Result: ", xyf); fi;
  return matching;
end;

TestHolonomyRelationalMorphism := function(sk)
  local S;
  S := TransSgp(sk);
  return ForAll(S,
                x-> ForAll(S,
                           y -> TestHolonomyCascadeMultiplication(x,y,sk)));
end;

# checking the action on all holonomy  coordinate tuples
# TODO - all lift cascades of semigorup elements
TestHolonomyAction := function(sk)
  local S, hcoords, p, s, xcs, p_;
  S := TransSgp(sk);
  hcoords := List([1..DegreeOfSkeleton(sk)], x->AllHolonomyCoords(x,sk));
  for s in S do
    xcs := AsHolonomyCascade(s,sk);
    for p in [1..DegreeOfSkeleton(sk)] do
      p_ := p^s;
      if not ForAll(hcoords[p],
                    x -> p_ = AsPoint(OnHolonomyCoords(x,xcs),sk))
      then
        Error(s);
      fi;
    od; #p
    #Print("#\c");
  od; #s
  return true;
end;
