# diagrams for showing the surjective map between the D-class and the subduction partial orders

DotSurHom := function(ts)
  local  str, i,j,out,dcls, dpo, states, classes, subduction, sk, img;
  dcls := GreensDClasses(ts);
  dpo := OutNeighbours(PartialOrderOfDClasses(ts));

  str := "";
  out := OutputTextString(str,true);
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph surhom{\n");
  AppendTo(out, "node [shape=circle];\n");
  #AppendTo(out, "edge [arrowhead=none];\n");

  AppendTo(out, "subgraph cluster_D{\n");  
  #### D class poset ####
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

  #### subduction poset ###
  sk := Skeleton(ts);
  states := [1..DegreeOfSkeleton(sk)];
  #drawing equivalence classes
  classes :=  RealImageSubductionClasses(sk);
  #this is a Hasse diagram
  subduction := RepSubductionCoverBinaryRelation(sk);
  AppendTo(out, "subgraph cluster_S{\n");
  #nodes
  for i in [1..Length(classes)] do
      AppendTo(out, Concatenation("S",String(i)));
      AppendTo(out, " [label=\"");
      for j in [1..Length(classes[i])] do
        AppendTo(out,List2Label(
                TrueValuePositionsBlistString(classes[i][j],states))," ");
      od;
      AppendTo(out, "\",shape=box];\n");
  od;
  #edges
  for i in [1..Length(classes)] do
      for j in Images(subduction, i) do
        AppendTo(out,Concatenation("S",String(i),"->S",String(j),";\n"));
      od;
  od;
  AppendTo(out,"}\n");

  #now the connection
  for i in [1..Length(dcls)] do
    img := FiniteSet(ImageListOfTransformation(Representative(dcls[i])), DegreeOfSkeleton(sk));

    AppendTo(out,Concatenation("D",String(i),"->S",String(Position(classes, SubductionClassOfSet(sk,img))),"[color=red];\n"));
  od;


  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end;