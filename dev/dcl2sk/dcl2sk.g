# diagrams for showing the surjective map between the D-class and the subduction partial orders

DotSurHom := function(ts)
  local  str, i,j,out,dcls, dpo;
  dcls := GreensDClasses(ts);
  dpo := OutNeighbours(PartialOrderOfDClasses(ts));

  str := "";
  out := OutputTextString(str,true);
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph surhom{\n");
  AppendTo(out, "node [shape=circle];\n");
  #AppendTo(out, "edge [arrowhead=none];\n");
  
  #nodes
  for i in [1..Length(dcls)] do
    AppendTo(out, Concatenation("D",String(i)," [label=\"\"]\n"));
  od;
  #edges
  for i in [1..Length(dcls)] do
      for j in dpo[i] do
        AppendTo(out,Concatenation("D",String(i),"->D",String(j),";\n"));
      od;
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end;