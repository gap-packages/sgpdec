################################################################################
##  SgpDec                                    Testing for relational morphisms
##  Copyright (C) 2024                                  Attila Egri-Nagy et.al
################################################################################
# Design decision: using hash-maps for representing relations
# Hash-maps were used for experimental code, but they are flexible enough to
# be the main tool. It's easy to get the keys, and they allow partially
# represented relational morphisms.

# Applying a binary operation for all ordered pairs for set A and B, and
# returning the set of results.
InstallGlobalFunction(ElementwiseProduct,
function(A, B, binop)
  return AsSet(List(EnumeratorOfCartesianProduct(A,B),
                    p -> binop(p[1],p[2])));
end);

# Checking compatible actions for a transformation semigroup relational
# morphism from (X,S) to (Y,T).
# Aborts immediately and reports first incompatibility.
# theta: for states, hashmap from X to subsets of Y
# phi: for transformations, hashmap from S to subsets of T
# Sact, Tact: functions for the actions in the ts's, e.g., OnPoints
# TODO think about a record for all these four items
InstallGlobalFunction(IsTSRelMorph,
function(theta, phi, Sact, Tact)
  local x,s,
        inS, inT; #where is the action computed
  for x in Keys(theta) do
    for s in Keys(phi) do
      inS := theta[Sact(x,s)];
      inT := ElementwiseProduct(theta[x], phi[s], Tact);
      if not (IsSubset(inS, inT)) then
        Print("Checking ", x, "*", s, "\n"); #TODO: use Info once in SgpDec
        Print(inT, " is not a subset of ", inS, "\n");
        return false;
      fi;
    od;
  od;
  return true;
end);

# Checking relational morphism S to T (only as semigroups, not transformation
# semigroups). Aborts immediately and reports first incompatibility.
# phi: hashmap from S to subsets of T
# Smul, Tmul: multiplication operations in source and target semigroups
InstallGlobalFunction(IsSgpRelMorph,
function(phi, Smul, Tmul)
  local s1,s2,
        inS, inT; #where is the action computed
  for s1 in Keys(phi) do
    for s2 in Keys(phi) do
      inS := phi[Smul(s1,s2)];
      inT := ElementwiseProduct(phi[s1], phi[s2], Tmul);
      if not (IsSubset(inS, inT)) then
        Print("Checking ", s1, "*", s2, "\n"); #TODO: use Info once in SgpDec
        Print(inT, " is not a subset of ", inS, "\n");
        return false;
      fi;
    od;
  od;
  return true;
end);
