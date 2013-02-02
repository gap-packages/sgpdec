PointMutation := function(gens)
  local ngens,i,j,l;
  ngens := ShallowCopy(gens);
  #we pick a generator
  i := Random([1..Length(ngens)]);
  l := ShallowCopy(ImageListOfTransformation(ngens[i]));
  j := Random([1..Length(l)]);
  l[j] := Random([1..Length(l)]);
  ngens[i] := Transformation(l);
  return ngens;
end;

PointMutationTS := function(ts)
  return Semigroup(PointMutation(
                 GeneratorsOfSemigroup(ts)));
end;