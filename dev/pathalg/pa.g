K0 := function(G)
  local n, AE,det,M,diag;
  n := Size(G);
  AE := CollapsedAdjacencyMat(CayleyGraph(G,GeneratorsOfGroup(G)));
  M := IdentityMat(n) - AE;
  det := Determinant(M);
  diag := DiagonalOfMat(SmithNormalFormIntegerMat(M));
  return [det, diag];
end;