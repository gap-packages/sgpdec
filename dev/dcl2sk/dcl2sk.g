# diagrams for showing the surjective map between the D-class and the subduction partial orders

DotMap := function(arg)
local  str, i,j,label,node,out,class,classes,set,states,G,sk,params,subduction;
  #getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;
  str := "";
  out := OutputTextString(str,true);
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph skeleton{\n");
  #setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..DegreeOfSkeleton(sk)];
  fi;
  #dot source production starts here
  AppendTo(out, "node [shape=box ];\n");
  AppendTo(out, "edge [arrowhead=none ];\n");
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