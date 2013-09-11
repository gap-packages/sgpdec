#todo: make these constants
SGPDEC_DOT_EMPTYVERTEXLABEL :=
  " [color=grey,width=0.1,height=0.1,fontsize=11,label=\"\"]";
SGPDEC_DOT_GREYLABELPREFIX := " [color=grey,label=\"";
SGPDEC_DOT_BLACKLABELPREFIX := " [color=black,label=\"";
# printing the graph data to the stream
SGPDEC_DotLabelledGraphParts := function(outstream, objects, labels)
local i;
  for i in [1..Size(objects)] do
    if IsBound(labels.(objects[i])) then
      AppendTo(outstream, objects[i]," ",labels.(objects[i]),";\n");
    else
      AppendTo(outstream, objects[i],"\n");
    fi;
  od;
end;
