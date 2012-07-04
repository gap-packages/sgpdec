# Homogeneous permutation group networks. The same group is placed into all of the nodes. When we apply a generator to one node, the same permutation is applied to neighbouring ones. The graph is directed, and is represented by a list of pairs.

#investigating the graph for the number of nodes
hgn_getNumberOfNodesInGraph := function(graph)
local n,vertex;
  n:= 0;
  for vertex in graph do
    if vertex[1] > n then n := vertex[1];fi;
    if vertex[2] > n then n := vertex[2];fi;
  od; 
  return n;
end;

# get the nodes to be changed (i.e. the one which is 'pressed' and its neighbours)
hgn_getNodesToBeChanged := function(node, graph)
local nodes,vertex;
  nodes := [];
  Add(nodes,node);
  for vertex in graph do
    if vertex[1] = node then Add(nodes,vertex[2]);fi;
  od; 
  Print("Node ", node, " is connected to nodes ", nodes,"\n");
  return nodes;
end;

#flattening generators for homogenous group network connected along a digraph (i.e. generating the state set for the network and investigate how 'pressing the button by a generator' acts on the whole system
hgn_Generators := function(permgroup, graph)
local orderedgens,orderedstates,gens,tmplist,stateset,state,i,newstate,numofnodes,node,gen,newgen;

  numofnodes := hgn_getNumberOfNodesInGraph(graph);
  #for numbering the new generators we need to index the original generators 
  orderedgens := SortedList(AsList(GeneratorsOfGroup(permgroup)));

  #ordered states
  tmplist := [];
  stateset := SetOfPermutationGroupToActOn(permgroup);
  for i in [1..numofnodes] do 
    Add(tmplist,stateset);
  od;
  orderedstates := Cartesian(tmplist);
  Print(Length(orderedstates)," states.\n");
  #now we are ready to construct the generators
  gens := [];
  for node in [1..numofnodes] do
    Print("Generators for node ",node,"\n");
    for gen in orderedgens do
      Print("Generators for gen ",gen,"\n");
      newgen := [];
      for state in orderedstates do
        #first copy state
        newstate := ShallowCopy(state);
	Print(Position(orderedstates,state),"-");
	#TODO not efficient but this is not time critical
	for i in hgn_getNodesToBeChanged(node,graph) do


	    newstate[i] := newstate[i] ^ gen;

	od;
	Print(Position(orderedstates,newstate),", ");
	Add(newgen,Position(orderedstates, newstate));
        
      od;
      Print("\n",gens,"\n\n");
      Add(gens,PermList(newgen));
    od;
  od;


  return gens;
end;


LoadAllGroupInfo();
graph := [
    [1,2],[1,4],
    [2,1],[2,3],
    [3,2],[3,4],
    [4,1],[4,3]
];
