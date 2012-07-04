#recursively builds a maximum path in a poset 
#rel -  the transitively reduced relation (Hasse Diagram)
#path - the actual path, it is changing during the recursion, maximal length path copied to maxpath
# mp - a record containing the field maxpath - technical solution for the problem of keeping the max reference the same during recursion 
_buildPath := function(rel, path, mp)
local imgs,i;
  #if the current path is longer then record it in maxpath
  if Length(path) > Length(mp.maxpath) then mp.maxpath := ShallowCopy(path); fi;
  #take the images of the last point in the current path
  imgs := Images(rel, LastElementOfList(path));
  #for all elements in the image, do the recursion
  for i in imgs do
    Add(path, i);
    _buildPath(rel, path, mp);
    Remove(path); #this removes the last element (just added before the recursive call)
  od;
end;

# returns the length of a maximal D-class chain of the given semigroup
DClassChainLength := function(S)
local dclasses, poset, mp,i,max;
  
  dclasses := GreensDClasses(S);  # library call for getting the D classes
  poset := AsBinaryRelationOnPoints(  # technical bit, to have it on point (integers) instead of classes
      HasseDiagramBinaryRelation(   # just the transitive reduced
          PartialOrderByOrderingFunction( # creating the partial order of the D classes
              Domain(dclasses),
              IsGreensLessThanOrEqual)));

  max := 0;
  #for all D-class as a starting point  we call the recursive pathbuilder
  for i in AsList(Source(poset)) do
     mp := rec(maxpath:=[]);
     _buildPath(poset, [i],mp);
     if (Length(mp.maxpath)>max) then max := Length(mp.maxpath);fi;
     #Print(i," ", Length(mp.maxpath), " ", mp.maxpath, "\n");
  od;
  return max;
end;

###example usage
SetInfoLevel(SkeletonInfoClass,0);
for i in [1..100] do
  gens := [RandomTransformation(6), RandomTransformation(6)];
  S := Semigroup(gens);
  Print("SkeletonDepth vs. maxDClassChain: ",DepthOfSkeleton(Skeleton(S)) ," / ", DClassChainLength(S), "\n" );
od;
