#############################################################################
##
## skeletonviz.gi           SgpDec package
##
## Copyright (C) 2010-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Visualizing several several aspects of the skeleton.
##

################################################################################
# VIZ ##########################################################################

# objects: a list of vertices, or a list of edges (their string representation)
# labels: a record used as a lookup table
# not used at the moment
Dot := function(objects, labels)
  local o,str;
  str := "";
  for o in objects do
    if IsBound(labels.(o)) then
      str := Concatenation(str, o," ",labels.(o),";\n");
    else
      str := Concatenation(str, o,";\n");
    fi;
  od;
end;

#TODO VIZ has List2CommaSeparatedString
List2Label := function(l)
local str;
  str := String(l);
  str := ReplacedString(str,"[","");
  str := ReplacedString(str,"]","");
  str := ReplacedString(str," ","");
  return str;
end;

# creating graphviz file for drawing the
InstallGlobalFunction(DotSkeletonForwardOrbit,
function(arg)
local  str, i,j,label,node,out,class,classes,set,states,G,sk,params,o,og;
  #getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;
  #setting the state names TODO this is ignored at the moment
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..999];
  fi;
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph skeleton_forward_orbit{\n");
  #drawing equivalence classes
  classes :=  SubductionClasses(sk);
  for i in [1..Length(classes)] do
    AppendTo(out,"subgraph cluster",String(i),
            "{style=filled;color=lightgrey;\n");
    for node in classes[i] do
      AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
    od;
    AppendTo(out,"}\n");
  od;
  #drawing the orbit
  o := ForwardOrbit(sk);
  og := OrbitGraph(o);
  for i in [1..Size(og)] do # the ith element of the orbit
    for j in DuplicateFreeList(og[i]) do # the images of i
      AppendTo(out,"\"",TrueValuePositionsBlistString(o[i]),
              "\" -> \"",TrueValuePositionsBlistString(o[j]),"\"",
              " [label=\"",
              List2Label(Positions(og[i],j)),
              "\"];\n");
      Display("");
    od;
  od;
  #drawing the representatives as rectangles and their covers
  for class in Union(RepresentativeSets(sk)) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class),
            "\" [shape=box,color=black];\n");
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);


# creating graphviz file for drawing the
InstallGlobalFunction(DotSkeleton,
function(arg)
local  str, i,label,node,out,class,classes,set,states,symbols,G,sk,params,tmpstring,witness;
  #getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph skeleton{\n");
  #setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..999];
  fi;
  if "symbols" in RecNames(params) then
    symbols := params.symbols;
  else
    symbols := [];
  fi;
  #defining the hierarchical levels - the nodes are named only by integers
  #these numbers appear on the side
  AppendTo(out, "{node [shape=plaintext]\n edge [style=invis]\n");
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out,Concatenation(String(i),"\n"));
    if i <= DepthOfSkeleton(sk) then
      AppendTo(out,Concatenation(String(i),"->",String(i+1),"\n"));
    fi;
  od;
  AppendTo(out,"}\n");
  #drawing equivalence classes
  classes :=  SubductionClasses(sk);
  for i in [1..Length(classes)] do
    AppendTo(out,"subgraph cluster",String(i),"{\n");
    for node in classes[i] do
      AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
    od;
    AppendTo(out,"color=\"black\";");
    if DepthOfSet(sk, node) < DepthOfSkeleton(sk) then
      G := HolonomyGroup@(sk, node);
      if not IsTrivial(G) then
        AppendTo(out,"style=\"filled\";fillcolor=\"lightgrey\";");
        if SgpDecOptionsRec.SMALL_GROUPS then
          label := StructureDescription(G);
        else
          label:= "";
        fi;
        AppendTo(out,"label=\"",label,"\"  }\n");
      else
        AppendTo(out,"  }\n");
      fi;
    else
      AppendTo(out,"  }\n");
    fi;
  od;
  #drawing the the same level elements
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out, "{rank=same;",String(i),";");
    for class in SubductionClassesOnDepth(sk,i) do
      for node in class do
        AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
      od;
    od;
    AppendTo(out,"}\n");
  od;
  #singletons
  AppendTo(out, "{rank=same;",String(DepthOfSkeleton(sk)),";");
  for node in Singletons(sk) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
  od;
  AppendTo(out,"}\n");
  #drawing the representatives as rectangles and their covers
  for class in Union(RepresentativeSets(sk)) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class),
            "\" [shape=box,color=black];\n");
    for set in TilesOf(sk,class) do
      AppendTo(out,"\"",TrueValuePositionsBlistString(class),
              "\" -> \"",TrueValuePositionsBlistString(set),"\"\n");
    witness := ImageWitness(sk,set,class); 
        if  Size(symbols) > 0 and not witness = fail then
         tmpstring := Concatenation(List(witness,x->String(symbols[x])));
         AppendTo(out,"[label=\"", tmpstring, "\"]\n");
        else
         AppendTo(out,"[label=\"", String(witness), "\"]\n");
        fi; 
    od;
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);

# creating graphviz file for drawing the partial order of skeleton classes
InstallGlobalFunction(DotSubductionEquivalencePoset,
function(arg)
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
  PrintTo(out,"digraph skeleton{\n");
  #setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..999];
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
                TrueValuePositionsBlistString(classes[i][j]))," ");
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
