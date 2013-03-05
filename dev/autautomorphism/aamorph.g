PadWithZeros := function(number, length)
local s,l, zeros, i;

  s := StringPrint(number);
  l := Length(s);
  zeros := "";
  for i in [1..length-l] do
    zeros := Concatenation(zeros,"0");
  od;
  return Concatenation(zeros,s);
end;

T4 := FullTransformationSemigroup(4);
T5 := FullTransformationSemigroup(5);

#returns true if (pi1,pi2) is a symmetry for the transformations 
IsSymmetryPairOfTransformations := function(transformations,pi1,pi2)
local x,X,i;
  X := [1..DegreeOfTransformation(transformations[1])];
  for i in [1..Length(transformations)] do
    for x in X do
      if not ((x^pi1)^transformations[i^pi2] = (x^transformations[i])^pi1) then
        return false;           
      fi;
    od;
  od;
  return true;
end;

IsStateSymmetryOfTransformations := function(transformations,pi1)
local x,X,i;
  X := [1..DegreeOfTransformation(transformations[1])];
  for i in [1..Length(transformations)] do
    for x in X do
      if not ((x^pi1)^transformations[i] = (x^transformations[i])^pi1) then
        return false;           
      fi;
    od;
  od;
  return true;
end;


GeneralAutMorphGroupOfTransformations := function(transformations)
local pi1, pi2, pairs;
  pairs := [];
  for pi1 in SymmetricGroup(IsPermGroup, [1..DegreeOfTransformation(transformations[1])]) do
    for pi2 in SymmetricGroup(IsPermGroup,[1..Length(transformations)]) do
      if IsSymmetryPairOfTransformations(transformations, pi1, pi2) then
        Add(pairs, [pi1,pi2]);
      fi;
    od;
  od;
  return pairs;
end;


StateAutMorphGroupOfTransformations := function(transformations)
local pi1, symmetries;
  symmetries := [];
  for pi1 in SymmetricGroup(IsPermGroup, [1..DegreeOfTransformation(transformations[1])]) do

      if IsStateSymmetryOfTransformations(transformations, pi1) then
        Add(symmetries, pi1);
      fi;

  od;
  return symmetries;
end;

#-----------

IsEverythingReachable := function(state, ts)
local n, imageset;
  n := DegreeOfTransformation(Representative(ts));
  imageset := ImageSetsInList(FiniteSetWithSizeOfUniverse([state],n),ts);
  if Length(imageset) = n then 
    return true;
  else 
    return false;
  fi;
  
end;



IsStronglyConnected := function(ts)
local n, i;
  n := DegreeOfTransformation(Representative(ts));
  for i in [1..n] do
    if not IsEverythingReachable(i,ts) then
      return false;
    fi;
  od;
  return true;
end;



search := function(ts)
local t1, t2, gens, ts2,c;
  c := 1;
  for t1 in ts do
    for t2 in ts do    
      ts2 := SemigroupByGenerators([t1,t2]);
      if (not (t1 = t2)) and (IsEverythingReachable(1,ts2)) and (not IsStronglyConnected(ts2)) then 
        gens := (StateAutMorphGroupOfTransformations([t1,t2]));
        if Length(gens) > 1 then
        
          Print(StructureDescription(Group(gens)));
          Display([t1,t2]);
          drawAutomaton(PadWithZeros(c,6),[t1,t2]);
          c := c + 1;
        fi;
      fi;
    od;
  od;
end;
