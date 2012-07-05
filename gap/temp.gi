




InstallGlobalFunction(EnumeratorOfCartesianProduct, 
function(arg)

  if Length(arg)=1 then 
    return CallFuncList(LazyCartesian, arg);
  fi;

  return LazyCartesian(arg);
end);

# returning true in case the name denotes a valid member of the record
ExistsFieldInRecord :=function(record, name)
    return name in RecNames(record);
end;


SGPDEC_SingletonOrbits := function(T)
local orbits,i, sets,n,o;
    n := DegreeOfTransformationSemigroup(T);
    sets := [];
    for i in [1..n] do
      o := Orb(T,FiniteSet([i],n), OnFiniteSets);
      Enumerate(o); 
      orbits := StrongOrbitsInForwardOrbit(o);
      Perform(orbits, function(x) AddSet(sets,UnionFiniteSet(x));end);
    od;
    return List(sets, x -> AsList(x));
end;


# creating partial order modified from the library code
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

#sorting for sets of varied positions, first bigger sets then default <
BySizeSorter := function(v,w)
if Size(v) <> Size(w) then
  return Size(v)>Size(w);
else
  return v>w;
fi;
end;

BySizeSorterAscend := function(v,w)
if Size(v) <> Size(w) then
  return Size(v)<Size(w);
else
  return v<w;
fi;
end;
