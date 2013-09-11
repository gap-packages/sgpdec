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
