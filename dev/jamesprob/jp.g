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

CountStronglyConnectedComps := function(n)
  local undedges,conf,c,gr,m;
  c := 0;
  undedges := UndirEdges(n);
  m := Size(undedges);
  for conf in EnumeratorOfCartesianProduct(List([1..m], x->[true, false])) do
    #Display(conf);
    gr := List([1..m], function(x)
      if conf[x] then return undedges[x];else return Reversed(undedges[x]);fi;end);
    #Display(gr);
    gr := List(gr, x-> Tuple(x));
#    Display(Size(EquivalenceClasses(
#               StronglyConnectedComponents(BinaryRelationByElements(Domain([1..n]),gr)))));
    if Size(EquivalenceClasses(
               StronglyConnectedComponents(BinaryRelationByElements(Domain([1..n]),gr)))) = 1 then
      c := c + 1;
    fi;
  od;
  Display(c);
end;