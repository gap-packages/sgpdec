# diagrams for showing the surjective map between the D-class and the subduction partial orders

DotSurHom := function(ts)
local  str, i,j,label,node,out,class,classes,set,states,G,sk,params,subduction;
dcls := GreensDClasses(ts);
dpo := PartialOrderofDClasses(ts);

str := "";
out := OutputTextString(str,true);
SetPrintFormattingStatus(out,false); #no formatting, line breaks
PrintTo(out,"//dot\ndigraph surhom{\n");
AppendTo(out, "node [shape=box ];\n");
AppendTo(out, "edge [arrowhead=none];\n");
  #drawing equivalence classes
  classes :=  SubductionClasses(sk);
  #making it really into a Hasse diagram
  subduction := HasseDiagramBinaryRelation(
                        TransitiveClosureBinaryRelation(
                                ReflexiveClosureBinaryRelation(
                                        RepSubductionCoverBinaryRelation(sk))));
  #nodes
  for i in [1..Length(classes)] do
    if not classes[i][1] in NonImageSingletons(sk) then
      AppendTo(out, String(i));
      AppendTo(out, " [label=\"");
      for j in [1..Length(classes[i])] do
        AppendTo(out,List2Label(
                TrueValuePositionsBlistString(classes[i][j],states))," ");
      od;
      AppendTo(out, "\"];\n");
    fi;
  od;
  #edges
  for i in [1..Length(classes)] do
    if not classes[i][1] in NonImageSingletons(sk) then
      for j in Images(subduction, i) do
        AppendTo(out,Concatenation(String(i),"->",String(j),";\n"));
      od;
    fi;
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);