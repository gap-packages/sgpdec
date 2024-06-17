
################################################################################
##  SgpDec        Surjective morphisms, input for the Covering Lemma algorithm
##  Copyright (C) 2024                                  Attila Egri-Nagy et.al
################################################################################
### CREATING SURJECTIVE MORPHISMS, constructing theta and phi ##################

################################################################################
#### The n(n-1) method #########################################################
# STATES: subsets of the state set missing one point
# creates a relation on states for the full transformation semigroup
# a state goes to a set of all states except itself, self-inverse theta
# the n(n-1) - slowest decomposition method
InstallGlobalFunction(ThetaForPermutationResets,
function(n) #we only need the number of states, the degree
  return HashMap(List([1..n],
                      x -> [x, Difference([1..n],[x])]));
end);

# TRANSFORMATIONS: permutations or constant maps
# deciding whether a transformation is actually a permutation
# note: IsPerm is about the type of the object, not what it is doing
IsPermutation := function(t)
  return DegreeOfTransformation(t) #this seems to be computed by max moved point
         =
         Size(AsSet(ImageListOfTransformation(t)));
end;
MakeReadOnlyGlobal("IsPermutation");

# mapping s to phi(s) - a transformation to a set of transformations
# if it is a permutation, then the image is the same,
# otherwise to a set of constant maps to points not in the image
# the degree of transformation given by n
PermutationOrResets := function(s,n)
  if IsPermutation(s) then
    return [s]; # still a set, but a singleton
  else
    # warning: giving n to ImageListOfTransformation is crucial here!
    # otherwise, we may add constant maps for the ignored highest fixed point(s)
    return List(Difference([1..n],AsSet(ImageListOfTransformation(s,n))),
                x -> ConstantTransformation(n,x));
  fi;
end;
MakeReadOnlyGlobal("PermutationOrResets");

# complementing ThetaForPermutationResets
InstallGlobalFunction(PhiForPermutationResets,
function(S)
  local n;
  n := DegreeOfTransformationSemigroup(S);
  return HashMap(List(S, s -> [s, PermutationOrResets(s,n)]));
end);

################################################################################
### State Set Congruence Method ################################################
InstallGlobalFunction(ThetaForCongruence,
function(partition)
  local rl, pairs;
  rl := ReverseLookup(partition);
  pairs := List(partition, #go through all equivalence classes
                eqcl -> List(eqcl, #for all points we map them to their eqclass index
                             x -> [x, [Position(partition, rl[x])]]));
  return HashMap(Concatenation(pairs));
end);

# S - set of transformations, not necessarily a semigroup
InstallGlobalFunction(PhiForCongruence,
function(partition, S)
  local rl, congact;
  rl := ReverseLookup(partition);
  congact := function(s)
    return Transformation(List(partition,
                               eqcl ->
                                    Position(partition,
                                             rl[First(OnSets(eqcl,s))])));
  end;
  return HashMap(List(S, s ->[s, [congact(s)]]));
end);

################################################################################
### extreme collapsing #########################################################
#evertyhing goes to state 1
InstallGlobalFunction(ThetaForConstant,
function(states)
  return HashMap(List(states, x-> [x,[1]]));
end);

#everyting goes to the identity
InstallGlobalFunction(PhiForConstant,
function(transformations)
  return HashMap(List(transformations, s-> [s,[IdentityTransformation]]));
end);

################################################################################
### local transformation monoid by idempotent e ################################
InstallGlobalFunction(ThetaForLocalMonoid,
function(states, e)
  return HashMap(List(states, x-> [x,[OnPoints(x,e)]]));
end);

InstallGlobalFunction(PhiForLocalMonoid,
function(transformations, e)
  return HashMap(List(transformations, s-> [s,[e*s*e]]));
end);
