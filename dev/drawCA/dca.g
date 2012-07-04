tab2list := function(dft)
local i,j,deps;
  deps := []; 
  for i in [1..Length(dft)] do
    if IsBound(dft[i]) then
    for j in [1..Length(dft[i][1])] do
      Add(deps, [dft[i][1][j], dft[i][2][j]]);
    od;
    fi;
  od;
  return deps;
end;

dca := function(filename, cascgens)
local  t, n, i,j,label,cstr,state_sets,deps, labels, dep,level,maplist,str,map,maps,maplabels,pos;
  
  filename := Concatenation(filename,".dot");  
  PrintTo(filename,"digraph cascaut{\n");
  AppendTo(filename,"rankdir=LR node [shape=circle]\n");

  cstr := CascadedStructureOf(cascgens[1]);
  state_sets := StateSets(cstr);
  #nodenames 
  # i for levels, j for states
  for i in [1..Length(state_sets)] do
    AppendTo(filename,"subgraph cluster",StringPrint(i),"{ label=Level",StringPrint(i)," "); 
    for j in [1..Length(state_sets[i])] do
      AppendTo(filename,"L",StringPrint(i),"S",StringPrint(j),"[label=",StringPrint(j),"]\n");
    od;
    AppendTo(filename,"}\n"); 
    #rank
    AppendTo(filename,"{rank=same",StringPrint(i),";"); 
    for j in [1..Length(state_sets[i])] do
      AppendTo(filename,"L",StringPrint(i),"S",StringPrint(j),";");
    od;
    AppendTo(filename,"}\n"); 
  od;
  #invisible arrows for top-down ordering
  AppendTo(filename,"{node [shape=plaintext] edge [style=invis]\n");
  for i in [1..Length(state_sets)-1] do
    AppendTo(filename,"L",StringPrint(i),"S1->L",StringPrint(i+1),"S1\n");
  od;

  AppendTo(filename,"}\n"); 

  #and the transitions
  maps := [];  #parallel lists
  maplabels := [];
  labels := "abcdefghijklmnopqrstuvxyz";
  for i in [1..Length(cascgens)] do

  deps := tab2list(DepFuncTableFromCascOp(cascgens[i]));#DependencyMapsFromCascadedOperation(cascgens[i]);
    for dep in deps do
      level := Length(dep[1]) +1;
      maplist := AsListOfMaps(dep[2],Size(state_sets[level]));
      for j in [1..Length(maplist)] do
        if j <> maplist[j] then
          label := StringPrint(dep[1]);
          label := ReplacedString(label,"[","(");
          label := ReplacedString(label,"]",")");
          label := ReplacedString(label," ","");
          if label="()" then label := ""; fi;
          str := "";
          str[1] := labels[i];
          label := Concatenation(label, str);
          map := Concatenation("L",StringPrint(level),"S",StringPrint(j),"->",
                   "L",StringPrint(level),"S",StringPrint(maplist[j]));
          pos := Position(maps,map);
          if pos = fail then #new element
            Add(maps,map);
            Add(maplabels,Concatenation(" [label=\"",label));
          else
            maplabels[pos] := Concatenation(maplabels[pos],",",label);
          fi;

        fi;
      od;
    od;
  od;
  #now writing out
  for i in [1..Length(maps)] do 
    AppendTo(filename,maps[i],maplabels[i],"\"]\n");

  od;
  AppendTo(filename,"}\n");

end;

