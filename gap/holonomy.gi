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
# CODING OF THE HOLONOMY COMPONENT STATES ######################################

# CODEC: INTEGERS <--> SETS
# Though the coordinate values are elements of the cover of a representative,
# it still has to be converted to integers

# figures out that which slot its representative belongs to (on the same level)
GetSlot := function(set,sk)
  return Position(RepresentativeSets(sk)[DepthOfSet(sk,set)],
                 RepresentativeSet(sk,set));
end;

# decoding: integers -> sets, integers simply code the positions sk.coordvals
InstallGlobalFunction(HolonomyInts2Sets,
function(sk, ints)
local sets, level;
  sets := ListWithIdenticalEntries(Length(ints),0); #default: 0 (jumped over)
  for level in [1..Length(ints)] do
    if ints[level] > 0 then
      # the set at the position coded by the integer
      sets[level] := CoordVals(sk)[level][ints[level]];
    fi;
  od;
  return sets;
end);

# encoding: sets -> integers, we need to find the set in the right slot
InstallGlobalFunction(HolonomySets2Ints,
function(sk, sets)
local set,level,ints,slot;
  set := BaseSet(sk);
  ints := ListWithIdenticalEntries(Length(sets),0); #default: 0 (jumped over)
  for level in [1..Length(sets)] do
    if sets[level] <> 0 then
      slot := GetSlot(set, sk); #TODO how can we make sure about the right slot?
      ints[level] := Position(CoordVals(sk)[level],
                             sets[level],
                             Shifts(sk)[level][slot]);
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
  return OnFiniteSet(reptile , GetIN(skeleton, P));
end;

#we map  a cover set of P to a cover set of Rep(P)
RepTile := function(realcover, P, skeleton)
  return OnFiniteSet(realcover , GetOUT(skeleton, P));
end;

# (successive approximation)
InstallGlobalFunction(TileChain,
function(sk, coordinates)
local chain,P,depth,skeleton;
  skeleton := sk;
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
InstallGlobalFunction(SetCoordinates,
function(sk, chain)
local sets,i, P, skeleton;
  skeleton := sk;
  #filling up with zeros - jumped over levels are abstract
  sets := ListWithIdenticalEntries(DepthOfSkeleton(skeleton)-1, 0);
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
function(sk, point)
  return List(AllTileChainsToSet(sk, FiniteSet([point],DegreeOfSkeleton(sk))),
            c -> HolonomySets2Ints(sk,SetCoordinates(sk,c)));
end);

################################################################################
# IMPLEMENTED METHODS FOR ABSTRACT DECOMPOSITION ###############################
InstallGlobalFunction(Interpret,
function(sk,level,state)
  return CoordVals(sk)[level][state];
end);
#AsPoint
AsHolonomyPoint :=
#    "flatten a cascaded state",
#    true,
#    [IsDenseList,IsRecord],
function(cs,sk)
  local coverchain;
  coverchain := TileChain(sk, HolonomyInts2Sets(sk,cs));
  # extracting the singleton element from the cover chains
  return ListBlist([1..DegreeOfSkeleton(sk)],
                 coverchain[Length(coverchain)])[1];
end;#);

AsHolonomyCoords :=
#    "raise a flat state into holonomy decomposition",
#    true,
#    [IsInt, IsRecord],
function(k,sk)
  return HolonomySets2Ints(sk,
                 SetCoordinates(sk,
                         RandomTileChain(sk,k)));
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
PermutationOfTiles := function(action, depth, slot, sk)
  local tileaction, shift, width;
  tileaction := ImageListOfTransformation(
                        TransformationOp(action,
                                TileCoords(sk)[depth][slot],
                                OnFiniteSet));
  #technical bit: shifting the action to the right slot
  shift := Shifts(sk)[depth][slot];
  width := Size(CoordVals(sk)[depth]);
  return Transformation(Concatenation(
                 [1..shift],
                 tileaction + shift,
                 [shift+Size(tileaction)+1..width]));
end;

#looking for a tile that contain the given set on a given level in a given slot
#then creating a constant map resetting to that tile
ConstantMapToATile := function(set, depth, slot, sk)
  local pos, width;
  pos := Shifts(sk)[depth][slot]+1;
  while not (IsSubsetBlist(CoordVals(sk)[depth][pos],set)) do
    pos := pos + 1;
  od;
  width := Size(CoordVals(sk)[depth]);
  return Transformation(List([1..width],x->pos));
end;

# investigate how s acts on the given states
# returns a list of component actions, one for each level
# P represents a tilechain and we hit it by s so we get a subset chain
# and Q approximates the subset chain with a non-unique tile chain
InstallGlobalFunction(HolonomyComponentActions,
function(sk,s,coords)
local action,
      actions,
      depth,
      P,
      Q,
      Ps,
      ncoordval,
      j,
      slot,
      set;
  #initializing actions to identity
  actions := List([1..DepthOfSkeleton(sk)-1],
                  x -> One( HolonomyPermutationResetComponents(sk)[x]));
  #initial successive approximation are the same for both
  P := BaseSet(sk);
  Q := P;
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if DepthOfSet(sk, Q) = depth then # we are on the right level
      slot := GetSlot(Q,sk);
      Ps := OnFiniteSet(P,s);
      if Ps = Q then #PERMUTATION###############################################
        # roundtrip: from the rep to P, then to Ps=Q, then back to Q's rep
        action := GetIN(sk,P) * s * GetOUT(sk,Q);
        # calculating the action on the tiles
        actions[depth] := PermutationOfTiles(action, depth, slot, sk);
        # also, what happens to Q under s TODO is this really Qs???
        ncoordval := OnFiniteSet(coords[depth], action);
      elif IsSubsetBlist(Q,Ps)  then #CONSTANT MAP##############################
        #look for a tile of Q that contains Ps
        set := RepTile(Ps,Q,sk);
        actions[depth] := ConstantMapToATile(set, depth,slot, sk);
        ncoordval:=CoordVals(sk)[depth][1^actions[depth]];# applying the constant
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
      if not actions[depth] in  HolonomyPermutationResetComponents(sk)[depth] then
        Print(actions[depth], " not in ", HolonomyPermutationResetComponents(sk)[depth],"\n");
        Error("Alien component action!");
      fi;
    od;
  fi;
  return actions;
end);

InstallGlobalFunction(HolonomyCascadeSemigroup,
function(ts)
  local sk, S;
  sk := Skeleton(ts);
  S := Semigroup(List(GeneratorsOfSemigroup(ts),
               t->Cascade( HolonomyPermutationResetComponents(sk),
                       HolonomyDependencies(sk,t))));
  SetSkeletonOf(S,sk);
  SetComponentsOfCascadeProduct(S, HolonomyPermutationResetComponents(sk));
  SetIsHolonomyCascadeSemigroup(S,true);
  return S;
end);

#this just enumerates the tile chains, convert to coordinates,
#calls for the component actions, and records if nontrivial
InstallGlobalFunction(HolonomyDependencies,
function(sk, t)
local i,state,sets,actions,depfuncs,holdom,cst;
  #identity needs no further calculations
  if IsOne(t) then return [];fi;
  depfuncs := [];
  #we go through all states
  holdom := Union(List([1..DegreeOfSkeleton(sk)],
                    i -> AllHolonomyLifts(sk,i)));
  for state in holdom do
    sets := HolonomyInts2Sets(sk,state);
    #get the component actions on a state
    actions := HolonomyComponentActions(sk, t, sets);
    #examine whether there is a nontrivial action, then add
    for i in [1..Length(actions)] do
      if not IsOne(actions[i]) then
        if i = 1 then
          AddSet(depfuncs,[[],actions[1]]);
        else
          for cst in
            AllConcreteCoords(ComponentDomains(
                    HolonomyPermutationResetComponents(sk)),
                  state{[1..(i-1)]}) do
            AddSet(depfuncs,[cst,actions[i]]);
          od;
        fi;
      fi;
    od;
  od;
  return depfuncs; #TODO maybe sort them into a graded list
end);

InstallGlobalFunction(AsHolonomyCascade,
function(t,sk)
  return Cascade( HolonomyPermutationResetComponents(sk),
                 HolonomyDependencies(sk,t));
end);

InstallGlobalFunction(AsHolonomyTransformation,
function(co,sk)
local l, i;
  l := [];
  for i in ListBlist([1..DegreeOfSkeleton(sk)],
          BaseSet(sk)) do
    l[i]:=AsHolonomyPoint(OnHolonomyCoordinates(AsHolonomyCoords(i,sk),co),sk);
  od;
  return Transformation(l);
end);

# cascade to ts
InstallOtherMethod(HomomorphismTransformationSemigroup,
        "for a holonomy cascade semigroup",
[IsHolonomyCascadeSemigroup],
function(cS)
  local T,sk,f;
  sk := SkeletonOf(cS);
  f := c -> AsHolonomyTransformation(c, sk);
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

#TODO does this work?
#changing the representative
#InstallGlobalFunction(ChangeCoveredSet,
#function(sk, set)
#local skeleton,oldrep, pos, depth,i, tiles;
#  if IsSingleton(set) then
#    Print("#W not changing singleton representative\n");return;
#  fi;
#  skeleton := sk;
#  oldrep := RepresentativeSet(skeleton,set);
#  ChangeRepresentativeSet(skeleton,set);
#  depth := DepthOfSet(skeleton, set);
#  pos := Position(sk.reps[depth], oldrep);
#  sk.reps[depth][pos] := set;
#  tiles := TilesOf(skeleton, set);
#  for i in [1..Length(tiles)] do
#    CoordVals(sk)[depth][Shifts(sk)[depth][pos]+i] := tiles[i];
#  od;
#end);

################################################################################
# REIMPLEMENTED GAP OPERATIONS #################################################

NumOfPointsInSlot := function(sk, level, slot)
  return Shifts(sk)[level][slot+1] - Shifts(sk)[level][slot];
end;
MakeReadOnlyGlobal("NumOfPointsInSlot");

#detailed print of the components
InstallMethod(DisplayString,"for a holonomy decomposition",
        [ IsHolonomyCascadeSemigroup ],
function(HCS)
  local groupnames,level, i,l,groups,sk,str;;
  sk := SkeletonOf(HCS);
  groupnames := [];
  for level in [1..DepthOfSkeleton(sk)-1] do
    l := [];
    groups := GroupComponents(SkeletonOf(HCS))[level];
    for i in [1..Length(groups)]  do
      if IsTrivial(groups[i]) then
        Add(l, String(NumOfPointsInSlot(sk,level,i)));
      elif SgpDecOptionsRec.SMALL_GROUPS then
        Add(l, Concatenation("(",String(NumOfPointsInSlot(sk,level,i)),
                ",", StructureDescription(groups[i]),")"));
      else
        Add(l, Concatenation("(",String(NumOfPointsInSlot(sk,level,i)),
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

# a straightforward implementation for multiplication for sets
InstallGlobalFunction(SetwiseProduct,
function(S,T)
  local ST,s,t;
  ST := [];
  for s in S do
    for t in T do
      AddSet(ST,s*t);
    od;
  od;
  return ST;
end);
