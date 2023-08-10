# diagrams for showing the surjective map between the D-class and the subduction partial orders

#developed with 0.9.5

LoadPackage("datastructures");

# grouping elements of a collection based on their outputs by function f
Classify := function (coll,f)
  local m, k;
  m := HashMap();
  Perform(coll,
          function (x)
            k := f(x);
            if k in m then
              AddSet(m[k], x); #mutable!
            else
              m[k] := [x];
            fi;
            return;
          end);
  return m;
end;

# drawing the surjective morphism from the partial order of D-classes to the partial
# order of subduction equivalence classes
DotSurHom := function(ts)
  local  str, i,j,out,dcls, dpo, states, classes, subduction, sk, img,
  DClass2SubductionClass, gdcls;

  dcls := GreensDClasses(ts);
  dpo := OutNeighbours(PartialOrderOfDClasses(ts));
  sk := Skeleton(ts);
  DClass2SubductionClass :=
    function(dcl)
      return SubductionClassOfSet(sk,
              FiniteSet(
                ImageListOfTransformation(Representative(dcl)),
                DegreeOfSkeleton(sk)));
    end;
  str := "";
  out := OutputTextString(str,true);
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph surhom{\n");
  AppendTo(out, "node [shape=circle];\n");

  AppendTo(out, "subgraph cluster_D{\n");  
  #### D class poset ####
  #nodes
  #we draw the collapsed D-classes in a cluster
  gdcls := Values(Classify(dcls, DClass2SubductionClass));
  for i in [1..Length(gdcls)] do
    AppendTo(out, Concatenation("subgraph cluster_D", String(i),"{\n"));
    Perform(gdcls[i],
            function(dcl) #we still use the node name by the position is dcls for edges
              AppendTo(out, Concatenation("D",String(Position(dcls,dcl)),
                                          " [label=\"\"]\n"));
            end);
    AppendTo(out,"}\n");
  od;
  #edges
  for i in [1..Length(dcls)] do
      for j in dpo[i] do
        AppendTo(out,Concatenation("D",String(i),"->D",String(j),";\n"));
      od;
  od;
  AppendTo(out,"}\n");

  #### subduction poset ###
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
    img := DClass2SubductionClass(dcls[i]);
    AppendTo(out,Concatenation("D",String(i),"->S",String(Position(classes,img)),
      "[color=red];\n"));
  od;

  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end;