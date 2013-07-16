LoadPackage("dust");

ImagesInDClass := function(dcl)
  return DuplicateFreeList(List(dcl,
                 y->FiniteSet(ImageListOfTransformation(y),
                         DegreeOfTransformation(Representative(dcl)))));
end;

DClasses2Skeleton := function(M)
  local sk,dcls;
  sk := Skeleton(M);
  dcls := List(DClasses(M),ImagesInDClass);
  Perform(AsSortedList(Difference(SkeletonClasses(sk),
          NonImageSingletonClasses(sk))), ViewObj);
  Print("\n\n");
  Perform(AsSortedList(dcls),ViewObj);
end;

DotDClasses2 := function(ts)
  local str, i, gp, h, rel, j, k, d, l, x,tl,al,ii, ss;

  str:="";
  Append(str, "digraph  DClasses {\n ranksep=1.0;\n");
  Append(str, "node [shape=plaintext]\n");
  Append(str, "edge [color=red]\n");
  i:=0;

  al := AssociativeList();
  for j in [1..Size(DClasses(ts))] do Assign(al, j,ImagesInDClass(DClasses(ts)[j]));od;
  al := ReversedAssociativeList(al);
  ii := 1;
  Display(al);
  for j in Keys(al) do
    tl := al[j];
    ss := String(tl);
    ss := ReplacedString(ss,"[", Concatenation("subgraph cluster",String(ii),"{"));
    ss := ReplacedString(ss,",",";");
    ss := ReplacedString(ss,"]","}\n");
    Append(str,ss);
    ii := ii +1;
  od;
  for d in DClasses(ts) do
    i:=i+1;
    Append(str, String(i));
    Append(str, " [shape=box style=dotted label=<\n<TABLE BORDER=\"0\" CELLBORDER=\"1\"");
    Append(str, " CELLPADDING=\"10\" CELLSPACING=\"0\"");
    Append(str, Concatenation(" PORT=\"", String(i), "\">\n"));
    
    if IsRegularDClass(d) then
      gp:=StructureDescription(GroupHClass(d));
    fi;

    Append(str, "<TR>");
    tl := [];
    for l in LClasses(d) do
      AddSet(tl, AsSortedList(DuplicateFreeList(ImageListOfTransformation(Representative(l)))));
    od;
    Append(str, "<TD CELLPADDING=\"10\">");
    Append(str,String(AsSortedList(tl)));
     #Append(str,String(AsSortedList(DuplicateFreeList(ImageListOfTransformation(Representative(l))))));
      Append(str,"</TD>");
   # od;
    Append(str, "</TR>");

    Append(str, "</TABLE>>];\n");
  od;

  rel:=PartialOrderOfDClasses(ts);
  rel:=List([1..Length(rel)], x-> Filtered(rel[x], y-> not x=y));

  for i in [1..Length(rel)] do
    j:=Difference(rel[i], Union(rel{rel[i]})); i:=String(i);
    for k in j do
      k:=String(k);
      Append(str, Concatenation(i, " -> ", k, "\n"));
    od;
  od;

  Append(str, " }");

  return str;
end;
