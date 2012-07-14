#############################################################################
##
## holonomy.gi           SgpDec package
##
## Copyright (C) 2010-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## A hierarchical decomposition: Holonomy coordinatization of semigroups.
##

#slots are the positions of the parallel components on a hierarchical level
#returns the range of indices for the component's states
_holonomy_slot_range := function(hd, set)
local slot, depth, skeleton;
  skeleton := SkeletonOf(hd);
  depth := DepthOfSet(skeleton,set);
  slot :=  Position(hd!.reps[depth], RepresentativeSet(skeleton, set));
  return [hd!.shifts[depth][slot]+1..hd!.shifts[depth][slot+1]];
end;

# CODEC: INTEGERS <--> SETS
# Though the coordinate values are elements of the cover of representative,
# it still has to be converted to integers, so  a cascade shell can be built
# decoding: integers -> sets
_holonomy_decode_coords := function(hd, ints)
local sets, level;
  sets := [];
  for level in [1..Length(ints)] do
      if ints[level] = 0 then
          Add(sets,0); #zero if the level is jumped over
        else
          # the position of the set
          Add(sets,hd!.flat_coordinates[level][ints[level]]);
      fi;
  od;
  return sets;
end;

# encoding: sets -> integers
_holonomy_encode_coords := function(hd, sets)
local rep,level,ints;
  rep := TopSet(SkeletonOf(hd));#hack -- TODO why is this a hack?
  ints := [];
  for level in [1..Length(sets)] do
      if sets[level] = 0 then
          Add(ints,0);
    else
     Add(ints,Position(hd!.flat_coordinates[level],
                       sets[level],
                       _holonomy_slot_range(hd,rep)[1]-1));
     rep := sets[level]; #this is ugly hack to get the proper duplicated covering_set
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
    #we go from the cover of the representative to the cover of the chain element 
    #Print(P, " ", depth, "\n");
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
    sets[DepthOfSet(skeleton, P)] := OnFiniteSets(chain[i] , GetOUT(skeleton,P));
    P := chain[i];
  od;
  return sets;
end
);

InstallGlobalFunction(ActionInfoOnLevel,
function(hd, level)
local groups, numofpoints,i, movedpoints, orbitsizes;
  #first get the groups on this level
  groups := GroupComponentsOnDepth(hd, level);
  #then for each group we print the action information
  for i in [1..Length(groups)] do
    numofpoints := hd!.shifts[level][i+1] - hd!.shifts[level][i];
    #getting the orbits, but we are interested only in their sizes, so transform them immediately
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
end
);

_holonomy_find_containing_set := function(hd, level, range, set)
local i;
  for i in range do
    if IsSubset(hd!.flat_coordinates[level][i], set) then
      return i;
    fi;
  od;
  Error("HOLONOMY: Finding a containing set fails! This cannot happen mathematically!\n");
  return fail;
end;


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
function(T)
  return HolonomyDecomposition(Skeleton(T));
end
);

InstallOtherMethod(HolonomyDecomposition,[IsRecord], #TODO quickfix - skeleton is a record now 
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
  holrec.flat_coordinates := [];
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
           SGPDEC_TimeString(Runtime() -t));t := Runtime();
    od;
    Add(holrec.shifts, shifts);
    Add(holrec.groupcomponents,groups);
    Add(holrec.reps, reps);
    Add(holrec.flat_coordinates,Flat(coords));
  od;

  #building the cascade shell
  holrec.cascadeshell :=
    CascadeShell(List([1..Length(holrec.groupcomponents)],
            x -> HolonomyPermutationReset(holrec.groupcomponents[x],
                    Length(holrec.flat_coordinates[x]))));
  #the permutation reset semigroups
  return Objectify(HolonomyDecompositionType, holrec);
end
);

##METHODS FROM ABSTRACT DECOMPOSITION########################################
InstallMethod(Interpret,
    "interprets a component's state",
    true,
    [IsHolonomyDecomposition,IsInt,IsInt], 0,
function(hd,level,state)
  return hd!.flat_coordinates[level][state];
end
);

InstallMethod(Flatten,
    "flatten a cascaded state",
    true,
    [IsHolonomyDecomposition,IsAbstractCascadedState], 1,
function(hd,cs)
  local coverchain;
  coverchain := CoverChain(hd, _holonomy_decode_coords(hd,cs));
  return AsList(coverchain[Length(coverchain)])[1];
end);

InstallMethod(Raise,
    "raise a flat state into holonomy decomposition",
    true,
    [IsHolonomyDecomposition,IsInt], 1,
function(hd,k)
  return CascadedState(CascadeShellOf(hd),
                 _holonomy_encode_coords(hd,
                         Coordinates(hd,
                                 RandomCoverChain(hd!.skeleton,k))));
end
);


InstallMethod(ComponentActions,
    "component actions of an original transformation in holonomy decomposition",
    true,
    [IsHolonomyDecomposition,IsTransformation, IsList], 0,
function(decomp,s,tiles)
local action,pos,actions,i, P, Q,Ps,Qs, skeleton,l,j,range,list;
  skeleton := SkeletonOf(decomp); # it is used frequently so it's better to have the reference
  #initializing actions to identity
  actions := List([1..Length(decomp)], i -> One(decomp[i]));
  #initial successive approximation are the same for both
  P := TopSet(skeleton);
  Q := P;
  for i in [1..Length(decomp)] do
    if DepthOfSet(skeleton, Q) = i then # we are on the right level
      Ps := OnFiniteSets(P , s);
      if Ps = Q then #permutation
        action := GetIN(skeleton,P)
                  * s
                  * GetOUT(skeleton,Q);
        Qs := OnFiniteSets(tiles[i], action);
        # calculating the action on the covers
        # list - the covering sets on a given level,
        # range - holonomy slot range, t is the action
        range := _holonomy_slot_range(decomp, Q);
        list := decomp!.flat_coordinates[i];
        l := [1..Length(list)];
        for j in range  do
          l[j] :=  Position(list,
                           OnFiniteSets(list[j],action),
                           range[1]-1);
        od;
        actions[i] :=Transformation(l);

        # paranoid check whether the action is in the component
        if SgpDecOptionsRec.PARANOID then
          if not actions[i] in decomp[i] then
            Error("Alien component action!");
          fi;
        fi;
      elif IsSubset(Q,Ps)  then #constant
        #look for a tile of Q that contains
        pos := _holonomy_find_containing_set(decomp,
                       i,
                       _holonomy_slot_range(decomp, Q),
                       OnFiniteSets(Ps , GetOUT(skeleton,Q)));
        actions[i] := Transformation(
                              List([1..Length(decomp!.flat_coordinates[i])],
                                   x->pos));
        Qs :=  decomp!.flat_coordinates[i][pos];
      else
        Print(i, "~~HEY~~ ",P, " * ", s ," = ", Ps, " but Q= ",Q,"\n" );
      fi;
      Q :=  OnFiniteSets(Qs , GetIN(skeleton,Q));
    fi; #if we are on the right level for Q

    if DepthOfSet(skeleton,P) = i then
      P:= OnFiniteSets(tiles[i] , GetIN(skeleton, P));
    fi;
  od;
  return actions;
end
);


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
        arg := _holonomy_encode_coords(decomp,state{[1..(j-1)]});
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
end
);

# Collapsing the whole cascade shell (as Flatten gives back the original structure)
InstallOtherMethod(Flatten,
    "collapsing a hierarchical decomposition",
    true,
    [IsHolonomyDecomposition], 0,
function( hd )
    local g,gens;
    gens := [];
    for g in GeneratorsOfSemigroup(OriginalStructureOf((hd))) do
        Add(gens,Flatten(Raise(hd,g)));
    od;
    return Semigroup(gens);
end
);

######################ACCESS FUNCTIONS############################
InstallGlobalFunction(SkeletonOf,
function(hd)
  return hd!.skeleton;
end
);

InstallGlobalFunction(GroupComponentsOnDepth,
function(hd, depth)
  return hd!.groupcomponents[depth];
end
);

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
    hd!.flat_coordinates[depth][hd!.shifts[depth][pos]+i] := coversets[i];
  od;
  #TODO!! we may have lost the CoverGroup's mapping
  #to coordinate points as integers, but for the time being
  #it does not seem to matter
end
);


####################OLD FUNCTIONS#################################
# The size of the cascade shell is the number components.
InstallMethod(Length,"for holonomy decompositions",
        true,[IsHolonomyDecomposition],
function(hd)
  # just delegating the task to the cascade shell
  return Length(hd!.cascadeshell);
end
);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for holonomy decompositions",
    [ IsHolonomyDecomposition, IsPosInt ],
function( hd, pos )
  # just delegating the task to the cascade shell
  return hd!.cascadeshell[pos];
end
);

#quick print of the components
InstallMethod( PrintObj,"for a holonomy decomposition",
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
        return Concatenation("G",StringPrint(Order(z)));
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