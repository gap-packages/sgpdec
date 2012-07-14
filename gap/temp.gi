################################################################################
# some technical code - likely to be replaced by GAP library calls (once found)
################################################################################

#just a wrapper of dust's LazyCartesian until the enumerator is implemented
InstallGlobalFunction(EnumeratorOfCartesianProduct,
function(arg)

  if Length(arg)=1 then
    return CallFuncList(LazyCartesian, arg);
  fi;

  return LazyCartesian(arg);
end);

################################################################################
# turning the action of a permutation on some points into a permutation
# used for acting on cosets, finite sets
# TODO Is there a GAP function to do this?
ActionOn := function(points,g,action)
local l;
  l := [];
  Perform([1..Length(points)],
          function(i)
            Add(l, PositionCanonical(points, action(points[i],g)));
          end);
  return l;
end;
MakeReadOnlyGlobal("ActionOm");

# creating partial order modified from the library code
# bypassing checks
#for speed reasons
PartialOrderByOrderingFunctionNC := function(d,of)
local i,j,        # iterators
      tup;        # set of defining tuples

  ## Construct a set of tuples which defines the partial order
  tup :=[];
  for i in d do
    for j in d do
      if of(i,j) then
        Add(tup,Tuple([i,j]));
      fi;
    od;
  od;
  return  BinaryRelationByElements(d,tup);
end;

#this is a specialized version of HasseDiagram
#knowing the underlying partial order, checks bypassed
#for speed reasons
HasseDiagramOfSubsets := function(orderedsubsets)
local i, j,           # iterators
      d,              # elements of underlying domain
      tups,           # elements of the hasse diagram relation
      h,              # the resulting hasse diagram
      # internal functions:
      CoveringSubsets;  #    to find the cover of an element

  CoveringSubsets := function(set) #TODO this can be improved by recursion
    local covers, pos, flag,s;
    if Size(set) = 1 then return []; fi;
    covers := [];
    pos := Position(orderedsubsets, set) - 1;
    while pos > 0 do
      if IsProperFiniteSubset(set, orderedsubsets[pos]) then
        flag := true;
        for s in covers do
          if IsProperFiniteSubset(s,orderedsubsets[pos]) then
            flag := false;
            break;
          fi;
        od;
        if flag then Add(covers,orderedsubsets[pos]);fi;
      fi;
      pos := pos - 1;
    od;
    return covers;
  end;

  d := Domain(orderedsubsets);
  tups := [];
  for i in d do
    for j in CoveringSubsets(i) do
      Add(tups, Tuple([i, j]));
    od;
  od;
  h := GeneralMappingByElements(d,d, tups);
  SetIsHasseDiagram(h, true);
  return h;
end;