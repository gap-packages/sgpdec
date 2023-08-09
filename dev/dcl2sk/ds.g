LoadPackage("datastructures"); #for hashmaps

ReversedHashMap := function(m) #todo, do a more functional (I mean nicer) version
local nm,k,val,l;
  nm := HashMap();
  for k in Keys(m) do
      val := m[k];
      if val in Keys(nm) then
          l := nm[val];
          AddSet(l,k); #mutable values!
      else
          nm[val] := [k];
      fi;
  od;
  return nm;
end;

ImagesInDClass := function(dcl)
  return DuplicateFreeList(List(dcl,
                 y->FiniteSet(ImageListOfTransformation(y),
                         DegreeOfTransformation(Representative(dcl)))));
end;

RegRepSgp := function(ts)
  return Semigroup(List(Generators(ts),
                 x->TransformationOp(x,AsList(ts),\*)));
end;

RegRepMon := function(ts)
  return Monoid(List(Generators(ts),
                 x->TransformationOp(x,AsList(ts),\*)));
end;

DClasses2Skeleton := function(M)
  local sk,dcls;
  sk := Skeleton(M);
  dcls := List(DClasses(M),ImagesInDClass);
  Perform(AsSortedList(Difference(SubductionClasses(sk),
          NonImageSingletonClasses(sk))), ViewObj);
  Print("\n\n");
  Perform(AsSortedList(dcls),ViewObj);
end;

#highly distorted version of Semigroups' DotDClasses
DotDClasses2 := function(ts)
  local str, i, gp, h, rel, j, k, d, l, x,tl,al,ii, s, dc2str, D;
  str:="";
  Append(str, "//dot\n digraph  DClasses {\n ranksep=1.0;\n");
  Append(str, "node [shape=plaintext]\n");
  Append(str, "edge [color=red]\n");
  i:=0;
  al := HashMap();
  #dc2str := AssociativeList();
  for j in [1..Size(DClasses(ts))] do
    al[j] := ImagesInDClass(DClasses(ts)[j]);
  od;
  al := ReversedHashMap(al);
  ii := 1;
  for j in Keys(al) do
    tl := al[j];
    s := String(tl);
    s := ReplacedString(s,"[",
                  Concatenation("subgraph cluster",String(ii),"{ "));
    s := ReplacedString(s,",",";");
    s := ReplacedString(s,"]","}\n");
    Append(str,s);
    ii := ii +1;
  od;
  for d in DClasses(ts) do
    i:=i+1;
    Append(str, String(i));
    Append(str, " [shape=box style=dotted label=<\n");
    Append(str, "<TABLE BORDER=\"0\" CELLBORDER=\"1\"");
    Append(str, " CELLPADDING=\"10\" CELLSPACING=\"0\"");
    Append(str, Concatenation(" PORT=\"", String(i), "\">\n"));
    if IsRegularDClass(d) then
      gp:=StructureDescription(GroupHClass(d));
    fi;
    tl := [];
    for l in LClasses(d) do
      AddSet(tl, AsSortedList(
              DuplicateFreeList(ImageListOfTransformation(Representative(l)))));
    od;
    Append(str, "<TR>");
    Append(str, "<TD CELLPADDING=\"10\">");
    s := String(AsSortedList(tl));
    s := ReplacedString(s,"[","{");
    s := ReplacedString(s,"]","}");
    s := ReplacedString(s,"{ {","{");
    s := ReplacedString(s,"} }","}");    
    Append(str,s);
    
    Append(str,"</TD>");
    Append(str, "</TR>");
    Append(str, "</TABLE>>];\n");
  od;

   D := PartialOrderOfDClasses(ts);
  rel := OutNeighbours(DigraphReflexiveTransitiveReduction(D));
  for i in [1 .. Length(rel)] do
    ii := String(i);
    for k in rel[i] do
      Append(str, Concatenation(ii, " -> ", String(k), "\n"));
    od;
  od;
  Append(str, " }");
  return str;
end;
