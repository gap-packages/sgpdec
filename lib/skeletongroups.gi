#############################################################################
##
## skeletongroups.gi           SgpDec package
##
## Copyright (C) 2010-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Groups acting on subsets of the state set.
##

################################################################################
### words and transformation for moving between sets and representatives
###  with a primitive caching method to avoid double calculation

#just empty lists in the beginning, built on demand, very scary mutable list!!
#indexed by the set's position in the orbit
#this is memoization
InstallMethod(FromRepMaps, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(FromRepWords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(ToRepMaps, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(ToRepWords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);


#returns a word  that takes the representative to the set A
InstallGlobalFunction(FromRepw,
function(sk, A)
local pos, scc,o;
  o := ForwardOrbit(sk);
  pos := Position(o, A);
  if not IsBound(FromRepWords(sk)[pos]) then
    scc := OrbSCCLookup(o)[pos];
    FromRepWords(sk)[pos] :=
      Concatenation(
              TraceSchreierTreeOfSCCBack(o,scc,SkeletonTransversal(sk)[scc]),
              TraceSchreierTreeOfSCCForward(o, scc, pos));
  fi;
  if SgpDecOptionsRec.STRAIGHTWORD_REDUCTION then
    FromRepWords(sk)[pos] := Reduce2StraightWord(FromRepWords(sk)[pos],
                                     Generators(sk),
                                     IdentityTransformation, OnRight);
  fi;
  return FromRepWords(sk)[pos];
end);

#evaluates the word as transformation and stores it
InstallGlobalFunction(FromRep,
function(sk, A)
local pos;
  pos := Position(ForwardOrbit(sk), A);
  if not IsBound(FromRepMaps(sk)[pos]) then
    FromRepMaps(sk)[pos] := EvalWordInSkeleton(sk, FromRepw(sk,A));
  fi;
  return FromRepMaps(sk)[pos];
end);

#returns a word  that takes A to its representative
InstallGlobalFunction(ToRepw,
function(sk, A)
local pos, scc, n, outw, fg, inw, out,l,o;
  o := ForwardOrbit(sk);
  pos := Position(o, A);
  if not IsBound(ToRepWords(sk)[pos]) then
    scc := OrbSCCLookup(o)[pos];
    outw :=
      Concatenation(
              TraceSchreierTreeOfSCCBack(o, scc, pos),
              TraceSchreierTreeOfSCCForward(o,scc,
                      SkeletonTransversal(sk)[scc]));
    out := EvalWordInSkeleton(sk, outw);
    inw := FromRepw(sk,A);
    #now doing it properly (Lemma 5.9. in ENA PhD thesis)
    n := First(PositiveIntegers,
               x-> IsIdentityOnFiniteSet( (FromRep(sk,A) * out)^(x+1),
                       RepresentativeSet(sk,A)));
    l := [];
    Add(l, outw);
    fg := Flat([inw,outw]);
    Add(l, ListWithIdenticalEntries(n,fg));
    ToRepWords(sk)[pos] := Flat(l);
    if SgpDecOptionsRec.STRAIGHTWORD_REDUCTION then
      ToRepWords(sk)[pos] := Reduce2StraightWord(ToRepWords(sk)[pos],
                                     Generators(sk),
                                     IdentityTransformation, OnRight);
    fi;
  fi;
  return ToRepWords(sk)[pos];
end);

#evaluates the word as transformation and stores it
InstallGlobalFunction(ToRep,
function(sk, A)
local pos;
  pos := Position(ForwardOrbit(sk), A);
  if not IsBound(ToRepMaps(sk)[pos]) then
    ToRepMaps(sk)[pos] := EvalWordInSkeleton(sk,ToRepw(sk,A));
  fi;
  return ToRepMaps(sk)[pos];
end);

################################################################################
### PERMUTATOR #################################################################
################################################################################
#roundtrips from the representative conjugated to the given set
InstallGlobalFunction(RoundTripWords,
function(sk,set)
local roundtrips,i,j,nset,scc,word,o;
  o := ForwardOrbit(sk);
  roundtrips := [];

  #we grab the equivalence class of the set, its strongly connected component
  scc := List(OrbSCC(o)[OrbSCCLookup(o)[Position(o, set)]],x->o[x]);
  Sort(scc); #for quicker lookup
  #Print(set, " " , scc, "\n");
  #for all elements of the equivalence class of the set
  for i in [1..Length(scc)] do
    #for all generators #TODO do this with orbitgraph
    for j in [1..Length(Generators(sk))] do
      #we hit an element in the class by a generator
      nset := OnFiniteSet(scc[i],Generators(sk)[j]);
      #if it stays in the class then it will give rise to a permutator
      if nset in scc then
        word :=  Concatenation(FromRepw(sk,scc[i]),[j],ToRepw(sk,nset));
        AddSet(roundtrips, word);
      fi;
    od;
  od;
  #conjugation here - we have to relocate the roundtrips to the set
  roundtrips := List(roundtrips,
                      x -> Concatenation(ToRepw(sk,set), x, FromRepw(sk,set)));
  if SgpDecOptionsRec.STRAIGHTWORD_REDUCTION then
    #reducing on sets yield alien actions
    roundtrips := List(roundtrips,
                       x -> Reduce2StraightWord(x,
                               Generators(sk),
                               (),
                               \*));
    # straightening may introduce duplicates #TODO Does it really?
    roundtrips := DuplicateFreeList(roundtrips);
  fi;
  return roundtrips;
end);

InstallGlobalFunction(NontrivialRoundTripWords,
function(sk,set)
local roundtrips,rtws,nontrivs;
  if not ContainsSet(sk,set) then return fail;fi;
  rtws := RoundTripWords(sk,set);
  roundtrips := List(rtws, w->EvalWordInSkeleton(sk,w));
  nontrivs := Filtered([1..Size(roundtrips)],
                      x->not IsIdentityOnFiniteSet(roundtrips[x],set));
  Info(SkeletonInfoClass, 2, "Nonidentity roundtrips/all roundtrips: ",
       Size(rtws), "/", Size(nontrivs));
  return rtws{nontrivs};
end);

#TODO this is brute force! any other idea?
InstallGlobalFunction(PermutatorSemigroupElts,
function(ts,set)
  return Filtered(ts, t -> OnFiniteSet(set,t) = set);
end);

InstallGlobalFunction(PermutatorGroup,
function(sk,set)
local permgens,gens,n, permgenwords;
  permgens := List(NontrivialRoundTripWords(sk,set),
                   w -> EvalWordInSkeleton(sk,w));
  gens := AsSet(List(permgens,
                  t -> AsPermutation(
                          RestrictedTransformation(t,
                                  ListBlist([1..Size(set)],set)))));
  Info(SkeletonInfoClass, 2,
       "Permutator group generators/nonidentity roundtrips: ",
       Size(gens), "/", Size(permgens));
  if IsEmpty(gens) then
    return Group(());
  else
    return Group(gens);
  fi;
end);

################################################################################
# HOLONOMY GROUPS ##############################################################
################################################################################
InstallGlobalFunction(PermutatorHolonomyHomomorphism,
function(sk,set)
  local permgroup,imggens,homgens;
  permgroup := PermutatorGroup(sk,set);
  imggens := List(GeneratorsOfGroup(permgroup),
                  g->AsPermutation(
                          TransformationOp(g,
                                  TilesOf(sk,set),
                                  OnFiniteSet)));
  homgens := DuplicateFreeList(imggens);
  return GroupHomomorphismByImages(permgroup,
                 Group(homgens),
                 GeneratorsOfGroup(permgroup),
                 imggens);
end);

InstallGlobalFunction(HolonomyGroup@,
function(sk,set)
  return Image(PermutatorHolonomyHomomorphism(sk,set));
end);

InstallMethod(GroupComponents, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local d,groups;
  groups := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    Add(groups,
        List(RepresentativeSets(sk)[d],
             rep -> HolonomyGroup@(sk, rep)));
  od;
  return groups;
end);

InstallMethod(TileCoords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local d,coords,l,rep;
  coords := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    l := [];
    for rep in RepresentativeSets(sk)[d] do
      Add(l,TilesOf(sk, rep));
    od;
    Add(coords,l);
  od;
  return coords;
end);

InstallMethod(CoordVals, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List(TileCoords(sk), Concatenation);
end);

InstallMethod(Shifts, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local tilecoords,d,l,s,shifts;
  shifts := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    l := List(TileCoords(sk)[d], Size);
    s := List([0..Size(l)], x->Sum(l{[1..x]}));
    Add(shifts, s);
  od;
  return shifts;
end);

################################################################################
# CONSTRUCTING HOLONOMY PERMUTATION RESET SEMIGROUPS ###########################

#constructing a transformation semigroup out of a group + constant maps
# 1st arg: group
# 2nd arg: the number of points to act on (could be important for trivial group)
InstallGlobalFunction(PermutationResetSemigroup,
function(arg)
  local G,n,gens;
  G := arg[1];
  if IsBound(arg[2]) then
    n := arg[2];
  else
    n := LargestMovedPoint(G);
  fi;
  #group generators converted to transformations
  gens := List(GeneratorsOfGroup(G),x -> AsTransformation(x,n)) ;
  #the resets (constant maps)
  Perform([1..n], function(i)
    Add(gens, Transformation(ListWithIdenticalEntries(n,i)));end);
  return SemigroupByGenerators(gens);
end);

InstallMethod(HolonomyPermutationResetComponents,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local grpcomps;
  grpcomps := GroupComponents(sk);
  return List([1..Length(grpcomps)],
              x -> PermutationResetSemigroup(
                      DisjointUnionPermGroup(grpcomps[x],Shifts(sk)[x]),
                      Size(CoordVals(sk)[x])));
end);

################################################################################
# util wrapping function for the often called BuildByWords
# to fend off likely future changes
InstallGlobalFunction(EvalWordInSkeleton,
function(sk, w)
  return BuildByWord(w, Generators(sk), (), OnRight);
end);

################################################################################
# DISPLAY

#needed for the Display string
NumOfPointsInSlot := function(sk, level, slot)
  return Shifts(sk)[level][slot+1] - Shifts(sk)[level][slot];
end;
MakeReadOnlyGlobal("NumOfPointsInSlot");

# this was duplicated in holonomy.gi, hence the separate function
DisplayStringHolonomyComponents := function(sk)
  local groupnames,level, i,l,groups,str;
  groupnames := [];
  for level in [1..DepthOfSkeleton(sk)-1] do
    l := [];
    groups := GroupComponents(sk)[level];
    for i in [1..Length(groups)]  do
      if IsTrivial(groups[i]) then
        Add(l, String(NumOfPointsInSlot(sk,level,i)));
      elif SgpDecOptionsRec.SMALL_GROUPS then
        Add(l, Concatenation("(",String(NumOfPointsInSlot(sk,level,i)),
                             ",", StructureDescription(groups[i]),")"));
      else
        Add(l, Concatenation("(",String(NumOfPointsInSlot(sk,level,i)),
                             ",|G|=", String(Order(groups[i])),")"));
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
end;
MakeReadOnlyGlobal("DisplayStringHolonomyComponents");

InstallGlobalFunction(DisplayHolonomyComponents,
function(skeleton)
  Print(DisplayStringHolonomyComponents(skeleton));
end);

# for compact displaying - used for experiments with many decompositions
# #levels |image set| #coordinate_tuples #structure
HolonomyInfoString := function(skeleton)
  local reps, l, n ,s, sizes, numofstates, structure;
  reps := RepresentativeSets(skeleton);
  sizes := List([1..Size(reps)-1],
                d -> List(reps[d],
                          r -> (Size(TilesOf(skeleton, r)))));
  numofstates := Product(List(sizes,Sum));
  sizes := List([1..Size(reps)-1],
                d -> List(reps[d],
                          r -> Concatenation(String(Size(TilesOf(skeleton, r))),
                                             ","
                                            ,StructureDescription(HolonomyGroup@SgpDec(skeleton,r):short))));
  s :=  JoinStringsWithSeparator(List(sizes,
                                      x->JoinStringsWithSeparator(x,"|")),
                                 "||");
  return JoinStringsWithSeparator([DepthOfSkeleton(skeleton),
                                   Size(ForwardOrbit(skeleton)),
                                   numofstates,
                                   s]," ");
end;
MakeReadOnlyGlobal("HolonomyInfoString");
