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
MakeReadOnlyGlobal("ActionOn");