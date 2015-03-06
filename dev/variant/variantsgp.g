Sgp2VariantMapping := function(S,a)
local n, rows,i,j,L, res, f, V;
  n := Size(S);
  L := AsSortedList(S);
  #nxn matrix (intialized with invalid value zero)
  rows := List([1..n], x->ListWithIdenticalEntries(n,0));
  #just a double loop to have all products
  for i in [1..n] do
    for j in [1..n] do
      rows[i][j] := Position(L, L[i]*a*L[j]);
    od;
  od;
  res := List([1..n], x->Transformation(Concatenation(rows[x],[x])));
  f := x -> res[Position(L,x)];
  V := Semigroup(res);
  return MappingByFunction(Domain(AsList(S)), Domain(res), f);
end;

VariantSemigroup := function(S,a)
  return Semigroup(Range(Sgp2VariantMapping(S,a)));
end;

#Building the 3x2 matrices on F2
# m - num of rows
# n - num of columns
# p - prime power for the field
# A - an nxm matrix
LinearVariantSemigroup := function(m,n,p,A)
    local tuples, allvecs, all,a;

    tuples := Tuples([0..p-1],n);
    allvecs := List(tuples,x-> Z(p)*x);
    all := Tuples(allvecs,m);
    List(all, x-> ConvertToMatrixRep(x,p));
    a := Z(p)*A;
    ConvertToMatrixRep(a,p);
    return VariantSemigroup(all,a);
end;

V := LinearVariantSemigroup(3,2,2,[[1,0,0],[0,0,0]]);
