################################################################################
# some technical code - likely to be replaced by GAP library calls (once found)
################################################################################


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

#Iterator for PositiveIntegers
#this to be removed once it gets in GAPlib
InstallMethod(Iterator,
    "for `PositiveIntegers'",
    [ IsPositiveIntegers ],
        PositiveIntegers -> IteratorByFunctions(
                rec(
                    NextIterator := function(iter)
                      iter!.counter:= iter!.counter + 1;
                      return iter!.counter;
                end,
                IsDoneIterator := ReturnFalse,
                ShallowCopy := iter -> rec( counter:= iter!.counter ),
                counter := 0)));# 0, since we first increment then return