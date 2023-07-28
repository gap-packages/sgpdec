## Dot Natural subsystem code - Modified to store permutation group information without dot and symbols
result := [];  # Store permutation group information

InstallGlobalFunction(GetPermutationGroups, function(arg)
  local sk, params, states, dx, cls, x1, px1, hx1, PermGenWord, PermutatorGeneratorWords, w, W, permutationGroup;

  # Getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;

  # Setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := List([1..DegreeOfSkeleton(sk)], String);
  fi;

  SgpDecFiniteSetDisplayOn();

  for dx in [1..DepthOfSkeleton(sk)-1] do
    for cls in SubductionClassesOnDepth(sk, dx) do
      for x1 in cls do
        px1 := PermutatorGroup(sk, x1);
        hx1 := HolonomyGroup@SgpDec(sk, x1);

        if not IsTrivial(px1) then
          PermutatorGeneratorWords := [];
          W := NontrivialRoundTripWords(sk, x1);

          for w in W do
            PermGenWord := Concatenation(List(w, x -> String(x)));
            Add(PermutatorGeneratorWords, PermGenWord);
          od;

          # Store the permutation group information as a tuple
          permutationGroup := rec(
            depth := dx,
            states := x1,
            permutatorWords := PermutatorGeneratorWords
          );

          Add(result, permutationGroup);
        fi;
      od;
    od;
  od;

  return result;
end);

InstallGlobalFunction(IdempotentWordsForSubset,
function(sk,set)
local roundtrips,rtws,ids;
  if not ContainsSet(sk,set) then return fail;fi;
  rtws := RoundTripWords(sk,set);
  roundtrips := List(rtws, w->EvalWordInSkeleton(sk,w));
  ids := Filtered([1..Size(roundtrips)],
                      x-> IsIdentityOnFiniteSet(roundtrips[x],set));
  Info(SkeletonInfoClass, 2, "identity roundtrips/all roundtrips: ",
       Size(rtws), "/", Size(ids));
  return rtws{ids};
end);

# TODO: is this thorough?
# TODO: check the entire set of idempotents
InstallGlobalFunction(IdempotentsForSubset,
function(S, sk, set)
local e, IdempotentSet, ssize;
  ssize := Size(BaseSet(sk));
  IdempotentSet := [];
  for e in Idempotents(S) do
    #if FiniteSet(ImageSetOfTransformation(e), ssize) = set then
    if OnFiniteSet(BaseSet(sk), e) = set then
       Add(IdempotentSet, e);
    fi;
  od;
  return IdempotentSet;
end);

# InstallGlobalFunction(Test, function(arg)
#   S := arg[1];
  
# end);

InstallGlobalFunction(GetSubgroupIdempotents, function(arg)
  local sk, params, states, dx, cls, x1, px1, hx1, IDs, subgIds, w, W, IdempotentSet;

  # Getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;

  # Setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := List([1..DegreeOfSkeleton(sk)], String);
  fi;

  SgpDecFiniteSetDisplayOn();

  for dx in [1..DepthOfSkeleton(sk)-1] do
    for cls in SubductionClassesOnDepth(sk, dx) do
      for x1 in cls do # TODO: duplicates of sets???
        px1 := PermutatorGroup(sk, x1);
        #hx1 := HolonomyGroup@SgpDec(sk, x1);

        if not IsTrivial(px1) then
          IdempotentSet := [];
          W := IdempotentWordsForSubset(sk, x1);

          for w in W do
            IDs := EvalWordInSkeleton(sk, w);#Concatenation(List(w, x -> String(x)));
            Add(IdempotentSet, IDs);
          od;

          # Store the permutation group information as a tuple
          subgIds := rec(
            depth := dx,
            states := x1,
            idempotents := Set(IdempotentSet)
          );

          Add(result, subgIds);
        fi;
      od;
    od;
  od;

  return Set(result);
end);

# Read("C://Users//thoma//Desktop//ECE 5C//Research//hex.g");
# x1 := FiniteSet([1,5,65,86]);
# x2 := FiniteSet([5,65,86]);
# e1s := IdempotentsForSubset(Game, skel, x1);
# e2s := IdempotentsForSubset(Game, skel, x2);
# e1 := e1s[1];
# e2 := e2s[1];
# G1 := SchutzenbergerGroup(HClass(Game, e1));
# CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet, rec(shreier := true, orbitgraph := true)));
# CalI2 := []; #Cal_I2 = all idempotents with images that are members of CalX2;
# for Xt in CalX2 do
#   CalI2 := Concatenation(CalI2, IdempotentsForSubset(Game, skel, Xt));
# od;

# Test Case:
# S := FullTransformationSemigroup(4);
# sk := Skeleton(S);
# DisplayHolonomyComponents(sk);
# CheckEssentialDependency(S, sk, 1, 2);
# CheckEssentialDependency(S, sk, 2, 3);

# x1 := FiniteSet([1,2,3,4]);
# x2 := FiniteSet([1,2,3], 4);
# e1s := IdempotentsForSubset(S, sk, x1);
# e2s := IdempotentsForSubset(S, sk, x2);
# e1 := e1s[1];
# e2 := e2s[1];
# G1 := SchutzenbergerGroup(HClass(S, e1));
# CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet, rec(schreier := true, orbitgraph := true)));
# CalI2 := []; #Cal_I2 = all idempotents with images that are members of CalX2;
# for Xt in CalX2 do
#   CalI2 := Concatenation(CalI2, IdempotentsForSubset(S, sk, Xt));
# od;

InstallGlobalFunction(CheckEssentialDependency, function(S, sk, d1, d2)
  # d1 is lower than d2 so larger set
  local G1, G2, CalX2, CalI2, J, x1, x2, e1, Xt, j, JGroup;

  G1 := SubductionClassesOnDepth(sk, d1);
  G2 := SubductionClassesOnDepth(sk, d2);

  for x1 in Concatenation(G1) do
    for x2 in Concatenation(G2) do
      if IsSubsetBlist(x1, x2) then
        # Find idempotent:
        for e1 in IdempotentsForSubset(S, sk, x1) do

          G1 := SchutzenbergerGroup(HClass(S, e1));
          # GeneratorsOfGroup(G1);
          # StructureDescription(G1);

          CalX2 := Enumerate(Orb(G1, x2, OnFiniteSet, rec(schreier := true, orbitgraph := true)));
          CalI2 := []; #Cal_I2 = all idempotents with images that are members of CalX2;
          for Xt in CalX2 do
            CalI2 := Concatenation(CalI2, IdempotentsForSubset(S, sk, Xt));
          od;

          # need help!
          J := Semigroup(CalI2);
          JGroup := PermutatorGroup(Skeleton(J), x2);
          if Size(JGroup) > 1 then
            return JGroup;
          fi;

          # For all elements from J: if it permutes x2, then we are done (return True)
          # for e2 in IdempotentsForSubset(S, sk, x2) do
          #   e2 := Idempotents(Semigroup([e1 * e2 * e1]))[1];
          # od;
        od;

      fi;
    od;
  od;
  return Group(());
end);




# gap> Print(WeakControlWords);
# function ( sk, X, Y )
#     local Xp, Xclass;
#     if IsSubsetBlist( X, Y ) then
#         Xp := X;
#     else
#         Xclass := SubductionClassOfSet( sk, X );
#         Xp := First( Xclass, function ( XC )
#                 return IsSubsetBlist( XC, Y );
#             end );
#     fi;
#     if Xp = fail then
#         return fail;
#     fi;
#     return [ ImageWitness( sk, Xp, X ), ImageWitness( sk, Y, Xp ) ];
# end
# gap> SubductionClassOfSet(skel, {68, 73, 86});
# Syntax error: identifier expected
# SubductionClassOfSet(skel, {68, 73, 86});
#                             ^^
# gap> SubductionClassOfSet(skel, [68, 73, 86]);
# Error, hash function not applicable to key of type plain list of cyclotomics at /opt/gap-v4.12.2/.libs/../pkg/orb/gap/hash.gi:264 called from
# HT_Hash( ht, x ) at /opt/gap-v4.12.2/.libs/../pkg/orb/gap/hash.gi:480 called from
# HTValue( orb!.ht, ob ) at /opt/gap-v4.12.2/.libs/../pkg/orb/gap/orbits.gi:443 called from
# Position( o, set ) at /opt/gap-v4.12.2/.libs/../pkg/sgpdec-lb//lib/skeleton.gi:271 called from
# <function "SubductionClassOfSet">( <arguments> )
#  called from read-eval loop at *stdin*:6
# you can 'quit;' to quit to outer loop, or
# you can 'return;' to continue
# brk> SubductionClassOfSet(skel, FiniteSet([68, 73, 86]));
# [ {62,79,86}, {1,80,86}, {1,6,86}, {32,48,86}, {1,34,86}, {1,4,86}, {23,32,86}, {28,38,86}, {1,54,86}, {1,2,86},
#   {32,33,86}, {41,43,86}, {1,45,86}, {1,5,86}, {24,32,86}, {42,46,86}, {1,57,86}, {1,56,86}, {6,61,86}, {1,66,86},
#   {6,70,86}, {1,62,86}, {2,80,86}, {1,65,86}, {4,77,86}, {1,17,86}, {1,32,86}, {2,33,86}, {14,43,86}, {1,78,86},
#   {7,50,86}, {1,72,86}, {3,47,86}, {6,35,86}, {45,62,86}, {1,83,86}, {55,63,86}, {1,75,86}, {5,85,86}, {1,9,86},
#   {49,68,86}, {1,74,86}, {1,81,86}, {1,67,86}, {2,78,86}, {1,7,86}, {6,72,86}, {1,68,86}, {2,72,86}, {1,14,86},
#   {6,78,86}, {1,63,86}, {2,75,86}, {1,3,86}, {4,78,86}, {1,16,86}, {1,22,86}, {5,72,86}, {32,47,86}, {1,48,86},
#   {5,51,86}, {2,59,86}, {1,64,86}, {5,77,86}, {1,11,86}, {13,32,86}, {1,41,86}, {6,45,86}, {5,44,86}, {31,32,86},
#   {1,46,86}, {5,53,86}, {6,57,86}, {61,68,86}, {5,56,86}, {4,25,86}, {1,18,86}, {32,40,86}, {1,38,86}, {6,55,86},
#   {5,54,86}, {6,12,86}, {5,27,86}, {1,10,86}, {32,37,86}, {1,8,86}, {6,80,86}, {1,69,86}, {4,79,86}, {5,73,86},
#   {2,70,86}, {65,84,86}, {1,71,86}, {5,82,86}, {6,58,86}, {60,66,86}, {65,85,86}, {5,74,86}, {6,73,86}, {4,76,86},
#   {4,83,86}, {1,19,86}, {21,32,86}, {30,32,86}, {5,25,86}, {6,20,86}, {5,26,86}, {32,43,86}, {1,35,86}, {4,45,86},
#   {5,55,86}, {5,49,86}, {4,81,86}, {4,82,86}, {32,50,86}, {6,79,86}, {5,76,86}, {5,81,86}, {4,46,86}, {22,56,86},
#   {1,61,86}, {4,41,86}, {19,45,86}, {1,26,86}, {5,38,86}, {11,55,86}, {1,27,86}, {6,48,86}, {51,63,86}, {59,66,86},
#   {58,69,86}, {1,79,86}, {1,73,86}, {5,34,86}, {5,71,86}, {6,75,86}, {5,83,86}, {68,84,86}, {5,75,86}, {4,80,86},
#   {10,32,86}, {5,8,86}, {6,9,86}, {4,16,86}, {4,22,86}, {6,11,86}, {25,62,86}, {12,69,86}, {27,68,86}, {1,44,86},
#   {38,50,86}, {1,55,86}, {35,47,86}, {1,49,86}, {4,14,86}, {19,78,86}, {1,25,86}, {6,66,86}, {62,78,86}, {63,72,86},
#   {1,76,86}, {68,75,86}, {67,80,86}, {4,64,86}, {1,15,86}, {19,80,86}, {1,20,86}, {5,7,86}, {11,72,86}, {3,6,86},
#   {47,48,86}, {1,51,86}, {6,52,86}, {5,65,86}, {8,71,86}, {1,85,86}, {11,75,86}, {1,12,86}, {39,48,86}, {30,35,86},
#   {34,42,86}, {18,32,86}, {4,15,86}, {5,16,86}, {6,17,86}, {6,19,86}, {25,63,86}, {20,69,86}, {5,22,86}, {4,44,86},
#   {6,49,86}, {38,51,86}, {35,58,86}, {1,60,86}, {4,62,86}, {6,69,86}, {63,73,86}, {66,70,86}, {68,73,86}, {67,79,86},
#   {2,66,86}, {14,78,86}, {1,82,86}, {7,72,86}, {65,75,86}, {1,77,86}, {64,80,86}, {4,67,86}, {19,79,86}, {5,68,86},
#   {11,73,86} ]
# brk> quit;
# gap> SubductionClassOfSet(skel, FiniteSet([1,5,27,86]))
# > ;
# [ {1,6,48,86}, {6,58,69,86}, {1,68,73,86}, {1,2,72,86}, {1,5,65,86}, {6,11,75,86}, {1,25,62,86}, {1,6,79,86},
#   {1,5,68,86}, {1,4,16,86}, {1,18,32,86}, {1,5,34,86}, {1,4,22,86}, {1,6,17,86}, {1,32,48,86}, {1,4,46,86},
#   {6,35,58,86}, {1,60,66,86}, {1,4,80,86}, {1,5,16,86}, {1,10,32,86}, {1,4,41,86}, {1,6,9,86}, {1,4,67,86},
#   {1,4,15,86}, {1,6,19,86}, {6,20,69,86}, {1,63,73,86}, {1,2,75,86}, {1,3,6,86}, {32,47,48,86}, {1,38,51,86},
#   {1,5,54,86}, {1,6,11,86}, {6,12,69,86}, {1,62,79,86}, {1,2,80,86}, {1,5,7,86}, {6,11,72,86}, {1,27,68,86},
#   {1,4,81,86}, {1,5,22,86}, {1,5,83,86}, {1,4,14,86}, {6,19,78,86}, {1,25,63,86}, {1,5,74,86}, {1,6,73,86},
#   {1,2,66,86}, {6,66,70,86}, {1,62,78,86}, {1,63,72,86}, {1,4,76,86}, {5,65,75,86}, {1,11,75,86}, {1,4,25,86},
#   {1,6,12,86}, {1,4,62,86}, {4,64,80,86}, {1,19,80,86}, {1,5,25,86}, {1,5,8,86}, {1,5,26,86}, {1,6,20,86},
#   {6,19,79,86}, {1,49,68,86}, {1,5,38,86}, {6,11,55,86}, {6,11,73,86}, {1,12,69,86}, {1,4,79,86}, {1,5,73,86},
#   {1,6,66,86}, {4,67,80,86}, {1,19,79,86}, {5,68,75,86}, {1,11,73,86}, {1,5,27,86}, {1,67,79,86}, {1,2,78,86},
#   {1,5,76,86}, {1,5,81,86}, {2,59,66,86}, {1,65,75,86}, {1,4,77,86}, {1,6,75,86}, {1,6,69,86}, {2,66,70,86},
#   {1,14,78,86}, {1,5,82,86}, {1,7,72,86}, {1,4,82,86}, {1,64,80,86}, {1,5,77,86}, {1,6,80,86} ]
# gap> WeakControlWords(skel, FiniteSet([68,73,86]), FiniteSet([1,6,75,86]))
# > ;
# fail
# gap> WeakControlWords(skel, FiniteSet([1,6,75,86]), FiniteSet([68,73,86]))
# > ;
# [ [ 2, 2, 6, 6, 7 ], [ 5, 4, 6, 7 ] ]
# gap> ImageWitness(skel,  FiniteSet([1,6,75,86]), FiniteSet([68,73,86])
# > ;
# Syntax error: ) expected
# ;
# ^
# gap> ImageWitness(skel,  FiniteSet([1,6,75,86]), FiniteSet([68,73,86]));
# fail
# gap> ImageWitness(skel,

# Test on X^X