UndirEdges := function(n)
  local i,j,edges;
  edges := [];
  for i in [1..n] do
    for j in [1..i-1] do
      Add(edges, [j,i]);
    od;
  od;
  return edges;
end;