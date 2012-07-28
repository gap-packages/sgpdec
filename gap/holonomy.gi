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

# CODEC: INTEGERS <--> SETS
# Though the coordinate values are elements of the cover of representative,
# it still has to be converted to integers, so  a cascade shell can be built
# decoding: integers -> sets
HolonomyInts2Sets := function(hd, ints)
local sets, level;
  sets := [];
  for level in [1..Length(ints)] do
      if ints[level] = 0 then
          Add(sets,0); #zero if the level is jumped over
        else
          # the set at the position coded by the integer
          Add(sets,hd!.allcoords[level][ints[level]]);
      fi;
  od;
  return sets;
end;

# encoding: sets -> integers
HolonomySets2Ints := function(hd, sets)
local rep,level,ints,slot, sk;
  sk := SkeletonOf(hd);
  rep := TopSet(sk);
  ints := [];
  for level in [1..Length(sets)] do
    if sets[level] = 0 then
      Add(ints,0);
    else
      # TODO rep seems to be a misnomer here
      slot := Position(hd!.reps[DepthOfSet(sk,rep)], RepresentativeSet(sk,rep));
      Add(ints,Position(hd!.allcoords[level],
              sets[level],
              hd!.shifts[level][slot]));
      rep := sets[level]; #a hack to get the proper duplicated covering_set
    fi;
  od;
  return ints;
end;

#####
# CHAIN <-> COORDINATES
# sets (elements of representative covers) -> elements of a cover chain
# (successive approximation)
InstallGlobalFunction(CoverChain,
function(hd, coordinates)
local chain,P,depth,skeleton;
  skeleton := SkeletonOf(hd);
  P := TopSet(skeleton); #we start to approximate from the top set
  chain := [];
  depth := 1;
  while depth <= Length(hd) do
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
  skeleton := SkeletonOf(hd);
  #filling up with zeros - jumped over levels are abstract
  sets := List([1..Length(hd)], x->  0);
  P := TopSet(skeleton);
  #the chain can be shorter (already jumped over), so it is OK go strictly by i
  for i in [1..Length(chain)] do
    sets[DepthOfSet(skeleton, P)] := OnFiniteSets(chain[i], GetOUT(skeleton,P));
    P := chain[i];
  od;
  return sets;
end);

#TODO incorporate this into Display
InstallGlobalFunction(ActionInfoOnLevel,
function(hd, level)
local groups, numofpoints,i, movedpoints, orbitsizes;
  #first get the groups on this level
  groups := GroupComponentsOnDepth(hd, level);
  #then for each group we print the action information
  for i in [1..Length(groups)] do
    numofpoints := hd!.shifts[level][i+1] - hd!.shifts[level][i];
    #getting the orbits, but we are interested only in their sizes,
    #so we transform them immediately
    orbitsizes := List(Orbits(groups[i]), x -> Length(x));
    #this is is zero only if Orbits(..) return an empty list (trivial orbits)
    movedpoints := Sum(orbitsizes);
    Print(StructureDescription(groups[i]), " acting on ");
    Print(numofpoints ," points ");
    if movedpoints > 0 then
      if Length(orbitsizes) = 1 then
         if (numofpoints > movedpoints) then
           Print("and transitively on ", movedpoints, " points.");
         else
           Print("transitively.");
         fi;
       else
        Print("with orbit sizes: ",orbitsizes);
        if (numofpoints > movedpoints) then
          Print(", and trivially on ", numofpoints - movedpoints, " point(s).");
        else
          Print(".");
        fi;
      fi;
    else
      Print("trivially.");
    fi;
    Print("\n");
  od;
end);

#constructing a transformation semigroup out of a list of groups + constants
#if the groups act on different sets of points, then it is a direct product
#groups is a list of permutation  groups, n number of points to act on
HolonomyPermutationReset := function(groups,n)
local gens;
  #first the group generators to transformations
  #(they are shifted properly, so no problem here)
  gens := [];
  Perform(groups, function(G)
    Append(gens,List(GeneratorsOfGroup(G),x -> AsTransformation(x,n)));end);
  #the resets (constant maps)
  Perform([1..n], function(i)
    Add(gens, Transformation(ListWithIdenticalEntries(n,i)));end);
  return SemigroupByGenerators(gens);
end;
MakeReadOnlyGlobal("HolonomyPermutationReset");

#shifts the points of the action
# G - permutation group, n - current size of the set acting upon
ShiftGroupAction :=  function(G,n, shift)
local gens,origens,i,j;
  origens := GeneratorsOfGroup(G);
  gens := List(origens, x -> [1..n+shift]);#identity maps
  for i in [1..n] do
    for j in [1..Size(gens)] do
      gens[j][i+shift] := OnPoints(i,origens[j]) + shift;
    od;
  od;
  return Group(List(gens, x -> PermList(x)));
end;
MakeReadOnlyGlobal("ShiftGroupAction");

#CONSTRUCTOR##################################################
InstallMethod(HolonomyDecomposition, [IsTransformationSemigroup],
function(T) return HolonomyDecomposition(Skeleton(T));end);

InstallOtherMethod(HolonomyDecomposition,[IsRecord], #skeleton is a record now
function(skeleton)
local holrec,depth,rep,groups,coords,n,reps, shift, shifts,t,coversets;
  # 1. put the skeleton into the record
  holrec := rec(skeleton:=skeleton);
  holrec.original := skeleton.ts;

  # 2. get the group components
  Info(HolonomyInfoClass, 2, "HOLONOMY"); t := Runtime();
  n := DepthOfSkeleton(holrec.skeleton) - 1;
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
    for rep in RepresentativesOnDepth(holrec.skeleton,depth) do
      coversets := CoveringSetsOf(holrec.skeleton,rep);
      Add(groups,
          ShiftGroupAction(CoverGroup(holrec.skeleton, rep),
                  Size(coversets),shift));
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
    Add(holrec.allcoords,Flat(coords));
  od;

  #building the cascade shell
  holrec.cascadeshell :=
    CascadeShell(List([1..Length(holrec.groupcomponents)],
            x -> HolonomyPermutationReset(holrec.groupcomponents[x],
                    Length(holrec.allcoords[x]))));
  #the permutation reset semigroups
  return Objectify(HolonomyDecompositionType, holrec);
end);

##METHODS FROM ABSTRACT DECOMPOSITION########################################
InstallMethod(Interpret,
    "interprets a component's state",
    true,
    [IsHolonomyDecomposition,IsInt,IsInt], 0,
function(hd,level,state)
  return hd!.allcoords[level][state];
end);

InstallMethod(Flatten,
    "flatten a cascaded state",
    true,
    [IsHolonomyDecomposition,IsAbstractCascadedState], 1,
function(hd,cs)
  local coverchain;
  coverchain := CoverChain(hd, HolonomyInts2Sets(hd,cs));
  return AsList(coverchain[Length(coverchain)])[1];
end);

InstallMethod(Raise,
    "raise a flat state into holonomy decomposition",
    true,
    [IsHolonomyDecomposition,IsInt], 1,
function(hd,k)
  return CascadedState(CascadeShellOf(hd),
                 HolonomySets2Ints(hd,
                         Coordinates(hd,
                                 RandomCoverChain(hd!.skeleton,k))));
end);

InstallMethod(ComponentActions,
    "component actions of an original transformation in holonomy decomposition",
    true,
    [IsHolonomyDecomposition,IsTransformation, IsList], 0,
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
  sk := SkeletonOf(hd); #it is used often so it's better to have it
  #initializing actions to identity
  actions := List([1..Length(hd)], x -> One(hd[x]));
  #initial successive approximation are the same for both
  P := TopSet(sk);
  Q := P;
  for depth in [1..Length(hd)] do
    if DepthOfSet(sk, Q) = depth then # we are on the right level
      slot := Position(hd!.reps[depth], RepresentativeSet(sk, Q));
      Ps := OnFiniteSets(P , s);
      if Ps = Q then #PERMUTATION
        action := GetIN(sk,P)
                  * s
                  * GetOUT(sk,Q);
        Qs := OnFiniteSets(states[depth], action);
            # calculating the action on the covers
        coversetaction := ActionOn(hd!.coords[depth][slot],
                                  action,
                                  OnFiniteSets);
        shift := hd!.shifts[depth][slot];
        width := Size(hd!.allcoords[depth]);
        actions[depth]:=Transformation(Concatenation(
                                [1..shift],
                                coversetaction + shift,
                                [shift+Size(coversetaction)+1..width]));
        # paranoid check whether the action is in the component
        if SgpDecOptionsRec.PARANOID then
          if not actions[depth] in hd[depth] then
            Error("Alien component action!");
          fi;
        fi;
      elif IsSubset(Q,Ps)  then #CONSTANT MAP
            #look for a tile of Q that contains
        set := OnFiniteSets(Ps , GetOUT(sk,Q));
        pos := hd!.shifts[depth][slot] +1;
        while not (IsSubset(hd!.allcoords[depth][pos],set)) do
          pos := pos + 1;
        od;
        actions[depth] := Transformation(
                                  List([1..Length(hd!.allcoords[depth])],
                                       x->pos));
        Qs :=  hd!.allcoords[depth][pos];
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

#this just enumerates the tile chains, convert to coordinates,
#calls for the component actions, and records if nontrivial
InstallMethod(Raise,
    "raise a transformation into holonomy decomposition",
    true,
    [IsHolonomyDecomposition,IsTransformation], 1,
function(decomp,t)
local j,tilechain, tilechains, actions,depfunctable,arg, state;
  if IsOne(t) then
    return IdentityCascadedTransformation(CascadeShellOf(decomp));
  fi;
  #the states already coded as coset representatives
  tilechains := AllCoverChains(SkeletonOf(decomp));
  #the lookup for the new dependencies
  depfunctable := [];
  #we go through all states
  for tilechain in tilechains  do
    state := Coordinates(decomp,tilechain);
    actions := ComponentActions(decomp,t,state);
    #examine whether there is a nontrivial action, then add
    for j in [1..Length(actions)] do
      if not IsOne(actions[j]) then
        arg := HolonomySets2Ints(decomp,state{[1..(j-1)]});
        RegisterNewDependency(depfunctable, arg, actions[j]);
      fi;
    od;
  od;
  return CascadedTransformation(CascadeShellOf(decomp),depfunctable);
end);

InstallMethod(Flatten,
    "flattens a cascaded operation in holonomy",
    true,
    [IsHolonomyDecomposition,IsCascadedTransformation], 1,
function(hd,co)
local l, i;
  l := [];
  for i in AsList(TopSet(SkeletonOf(hd))) do
    l[i] := Flatten(hd,Raise(hd,i) ^ co);
  od;
  return Transformation(l);
end);

#Flattening the whole decomposition (gives back the original semigroup)
#TODO this should be wrapped in the semigroup homomorphism
InstallOtherMethod(Flatten,
    "flattening a hierarchical decomposition",
    true,
    [IsHolonomyDecomposition], 0,
function( hd )
    local g,gens;
    gens := [];
    for g in GeneratorsOfSemigroup(OriginalStructureOf((hd))) do
        Add(gens,Flatten(Raise(hd,g)));
    od;
    return Semigroup(gens);
end);

######################ACCESS FUNCTIONS############################
InstallGlobalFunction(SkeletonOf,
function(hd) return hd!.skeleton;end);

InstallGlobalFunction(GroupComponentsOnDepth,
function(hd, depth) return hd!.groupcomponents[depth];end);

#changing the representative
InstallGlobalFunction(ChangeCoveredSet,
function(hd, set)
local skeleton,oldrep, pos, depth,i, coversets;
  if IsSingleton(set) then
    Print("#W not changing singleton representative\n");return;
  fi;
  skeleton := SkeletonOf(hd);
  oldrep := RepresentativeSet(skeleton,set);
  ChangeRepresentativeSet(skeleton,set);
  depth := DepthOfSet(skeleton, set);
  pos := Position(hd!.reps[depth], oldrep);
  hd!.reps[depth][pos] := set;
  coversets := CoveringSetsOf(skeleton, set);
  for i in [1..Length(coversets)] do
    hd!.allcoords[depth][hd!.shifts[depth][pos]+i] := coversets[i];
  od;
  #TODO!! we may have lost the CoverGroup's mapping
  #to coordinate points as integers, but for the time being
  #it does not seem to matter
end);

####################OLD FUNCTIONS#################################
# The size of the cascade shell is the number components.
InstallMethod(Length,"for holonomy decompositions",
        true,[IsHolonomyDecomposition],
function(hd)
  # just delegating the task to the cascade shell
  return Length(hd!.cascadeshell);
end);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for holonomy decompositions",
    [ IsHolonomyDecomposition, IsPosInt ],
function( hd, pos )
  # just delegating the task to the cascade shell
  return hd!.cascadeshell[pos];
end);

#quick print of the components
InstallMethod( Display,"for a holonomy decomposition",
        [ IsHolonomyDecomposition ],
function( hd )
local groupindicators,i;
  if SgpDecOptionsRec.SMALL_GROUPS then
    groupindicators := List(List([1..Length(hd)], x->
                               List(GroupComponentsOnDepth(hd,x))),
                            y -> List(y, z -> StructureDescription(z)));
  else
    groupindicators :=
      List(List([1..Length(hd)],x->
              List(GroupComponentsOnDepth(hd,x))),y ->
           List(y,function(z)
      if Order(z) = 1 then
        return "I";
      else
        return Concatenation("G",String(Order(z)));
      fi;end));
  fi;

  #just printing all the group indicators
  for i in [1..Length(groupindicators)] do
    Print(i,": ");
    Perform(groupindicators[i], function(x) Print(x," ");end);
    if i < Length(groupindicators) then
      Print("\n");
    fi;
  od;
end);

#####DRAWING
# gone to the skeleton, maybe a completely new view for holonomy will come here