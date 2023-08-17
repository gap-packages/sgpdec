#holonomy decomposition for the right regular representation of T3

#returns the right regular transformation representation of an element s
#of the semigroup S
RightRegularTransRep := function(s,S)
  return TransformationOp(s,S, OnRight);
end;

# returns a semigroup which is the right regular representation of semigroup
# S, redefining the generators only
RightRegularTransformationSemigroup := function(S)
  return Semigroup(List(Generators(S),
                   s -> RightRegularTransRep(s,S)));
end;
#MakeReadOnlyGlobal("RightRegularTransformationSemigroup");

toRR := function(S)
  return MappingByFunction(S, RightRegularTransformationSemigroup(S),
                           s -> RightRegularTransRep(s,S));
end;


