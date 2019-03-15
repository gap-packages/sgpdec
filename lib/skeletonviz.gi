#############################################################################
##
## skeletonviz.gi           SgpDec package
##
## Copyright (C) 2010-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Visualizing several several aspects of the skeleton.
##

# Usage: semigroup, list, action. For example,
# DotSemigroupAction(s, Elements(s), OnRight);
# DotSemigroupAction(s, Combinations([1..4]), OnSets);
# DotSemigroupAction(s, [1..4], OnPoints);

# try the above with a group!

# Returns: a string

# Notes: generalizes Draw for a transformation semigroup.

# AN's code, hash tables should be removed from here. Edge labels don't work
# properly.

InstallGlobalFunction(DotSemigroupAction,
function(s, list, act)
  local gens, str, ht, entries, label, edge, currentlabel, t, i;

  gens := GeneratorsOfSemigroup(s);
  str:="";
  Append(str, "//dot\ndigraph aut{\n");
  Append(str, "node [shape=circle]");
  Append(str, "edge [len=1.2]");
  ht:=HTCreate("1 -> 2");
  entries := [];
  
  for t in [1..Size(gens)] do
    label := Concatenation("", String(t));
    for i in [1..Length(list)] do
      if list[i] <> act(list[i], gens[t]) then
        edge := Concatenation("\"", StringPrint(list[i]), "\"",
                              " -> \"",
                              StringPrint(act(list[i],gens[t])), "\"");
        currentlabel :=  HTValue(ht, edge);
        if currentlabel = fail then
          HTAdd(ht,edge,label);
          Add(entries, edge);
        else
          HTUpdate(ht,edge,Concatenation(currentlabel,",",label));
        fi;
      fi;
    od;
  od;
  #nodenames
  for edge in entries do
    Append(str,Concatenation(edge , "[label=\"", HTValue(ht,edge) ,
                             "\"]\n"));
  od;
  Append(str,"}\n");
  return str;
end);

#############################################################################
# Extension of DotSemigroupAction to show node names and generator names
# by C L Nehaniv, June 2013
#                  Updated 27 February 2019 
#

# Usage: semigroup, list, action, list of node names, list of generator names. 
# For example,
# DotSemigroupActionWithNames(s, Elements(s), OnRight,NodeNames,GeneratorNames);
# DotSemigroupActionWithNames(s, Combinations([1..4]), OnSets,NodeNames,GeneratorNames);
# DotSemigroupActionWithNames(s, [1..4], OnPoints,NodeNames,GeneratorNames);

InstallGlobalFunction(DotSemigroupActionWithNames,
function(s, list, act, nodenames, generatornames)
  local gens, str, ht, entries, label, edge, currentlabel, t, i;

  gens := GeneratorsOfSemigroup(s);
  str:="";
  Append(str, "//dot\ndigraph aut{\n");
  Append(str, "node [shape=circle]");
  Append(str, "edge [len=1.2]");
  ht:=HTCreate("1 -> 2");
  entries := [];
  
  for t in [1..Size(gens)] do
    label := Concatenation("", String(generatornames[t]));
    for i in [1..Length(list)] do
      if list[i] <> act(list[i], gens[t]) then
        edge := Concatenation("\"", StringPrint(nodenames[list[i]]), "\"",
                              " -> \"", StringPrint(nodenames[act(list[i],gens[t])]), "\"");
        currentlabel :=  HTValue(ht, edge);
        if currentlabel = fail then
          HTAdd(ht,edge,label);
          Add(entries, edge);
        else
          HTUpdate(ht,edge,Concatenation(currentlabel,",",label));
        fi;
      fi;
    od;
  od;
  #nodenames
  for edge in entries do
    Append(str,Concatenation(edge , "[label=\"", HTValue(ht,edge) ,
                             "\"]\n"));
  od;
  Append(str,"}\n");
  return str;
end);

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
MakeReadOnlyGlobal("Dot");

#TODO VIZ has List2CommaSeparatedString
List2Label := function(l)
local str;
  str := String(l);
  str := ReplacedString(str,"[","");
  str := ReplacedString(str,"]","");
  str := ReplacedString(str," ","");
  return str;
end;
MakeReadOnlyGlobal("List2Label");

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
    states := [1..DegreeOfSkeleton(sk)];
  fi;
  str := "";
  out := OutputTextString(str,true);
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph skeleton_forward_orbit{\n");
  #drawing equivalence classes
  classes :=  SubductionClasses(sk);
  for i in [1..Length(classes)] do
    AppendTo(out,"subgraph cluster",String(i),
            "{style=filled;color=lightgrey;\n");
    for node in classes[i] do
      AppendTo(out,"\"",TrueValuePositionsBlistString(node,states),"\";");
    od;
    AppendTo(out,"}\n");
  od;
  #drawing the orbit
  o := ForwardOrbit(sk);
  og := OrbitGraph(o);
  for i in [1..Size(og)] do # the ith element of the orbit
    for j in DuplicateFreeList(og[i]) do # the images of i
      AppendTo(out,"\"",TrueValuePositionsBlistString(o[i],states),
              "\" -> \"",TrueValuePositionsBlistString(o[j],states),"\"",
              " [label=\"",
              List2Label(Positions(og[i],j)),  # TODO : allow symbols as transition labels
              "\"];\n");
    od;
  od;
  #drawing the representatives as rectangles and their covers
  for class in Union(RepresentativeSets(sk)) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class,states),
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
  SetPrintFormattingStatus(out,false); #no formatting, line breaks
  PrintTo(out,"//dot\ndigraph skeleton{ newrank=true;\n");
  #setting the state names
  if "states" in RecNames(params) then
    states := params.states;
     else
    states := [1..DegreeOfSkeleton(sk)];
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
      AppendTo(out,"\"",TrueValuePositionsBlistString(node,states),"\";");
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
        AppendTo(out,"\"",TrueValuePositionsBlistString(node,states),"\";");
      od;
    od;
    AppendTo(out,"}\n");
  od;
  #singletons
  AppendTo(out, "{rank=same;",String(DepthOfSkeleton(sk)),";");
  for node in Singletons(sk) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(node,states),"\";");
  od;
  AppendTo(out,"}\n");
  #drawing the representatives as rectangles and their covers
  for class in Union(RepresentativeSets(sk)) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class,states),
            "\" [shape=box,color=black];\n");
    for set in TilesOf(sk,class) do
      AppendTo(out,"\"",TrueValuePositionsBlistString(class,states),
              "\" -> \"",TrueValuePositionsBlistString(set,states),"\"\n");
      witness := ImageWitness(sk,set,class);
      if witness = fail then
        AppendTo(out,"[style=\"dotted\"]\n");
      else
        if  Size(symbols) > 0 then
          tmpstring := Concatenation(List(witness,x->String(symbols[x])));
          AppendTo(out,"[label=\"", tmpstring, "\"]\n");
        else
          AppendTo(out,"[label=\"", String(witness), "\"]\n");
        fi; 
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

InstallGlobalFunction(DotChainActions,
function(sk, t)
  local f,str,out;
  #-----------------------------------------------------------------------------
  f := function(prefix, indices, parentnode)
    local tiles, i, node;
    node := Concatenation("n", ReplacedString(String(indices),",","_"));
    RemoveCharacters(node, "[] ");
    PrintTo(out, node, "[shape=record,label=\"",
            TrueValuePositionsBlistString(OnFiniteSet(prefix[Size(prefix)],t)),
            "\",color=\"black\"];\n");
    if not IsEmpty(parentnode) then
      PrintTo(out, parentnode ,"--", node,"\n");
    fi;
    # and the recursion
    tiles := TilesOf(sk, prefix[Size(prefix)]);
    for i in [1..Size(tiles)] do
      Add(prefix,tiles[i]);
      Add(indices,i);
      f(prefix,indices,node);
      Remove(prefix);
      Remove(indices);
    od;
  end;
  #-----------------------------------------------------------------------------
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"//dot\ngraph chains{\n");

  f([BaseSet(sk)], [1], "");

  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);

#only works nicely for very small trees, dist params need to be tweaked for big
InstallGlobalFunction(TikzChainActions,
function(sk, t)
  local f,str,out;
  #-----------------------------------------------------------------------------
  f := function(prefix)
    local tiles, i, node;
    if Size(prefix)=1 then
      PrintTo(out, "\\node {");
    else
      PrintTo(out, " child { node{");
    fi;
    node := TrueValuePositionsBlistString(OnFiniteSet(prefix[Size(prefix)],t));
    node := ReplacedString(node, "{", "\\{");
    node := ReplacedString(node, "}", "\\}");
    PrintTo(out,"$",node,"$}");
    # and the recursion
    tiles := TilesOf(sk, prefix[Size(prefix)]);
    for i in [1..Size(tiles)] do
      Add(prefix,tiles[i]);
      f(prefix);
      Remove(prefix);
    od;
    if Size(prefix)=1 then
      PrintTo(out, ";");
    else
      PrintTo(out, "}");
    fi;

  end;
  #-----------------------------------------------------------------------------
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"%latex\n");
  PrintTo(out,"\\documentclass{minimal}\\usepackage{tikz}");
  PrintTo(out,"\\usetikzlibrary{trees}\\begin{document}\n\n\\begin{tikzpicture}\n");
  PrintTo(out, "[level distance=1cm,level 1/.style={sibling distance=1.3cm},");
  PrintTo(out, "level 2/.style={sibling distance=.6cm}]\n\n");
  f([BaseSet(sk)]);
  AppendTo(out,"\\end{tikzpicture}\n\n\\end{document}\n");
  CloseStream(out);
  return str;
end);



# Return dot list of Permutator Groups of Representations
InstallGlobalFunction(DotRepPermutatorGroups,
function(arg)
 local sk, params, states,symbols,dx,x1,px1, hx1, dot, PermGenWord, PermutatorGeneratorLabels,w, W, dotlist;

 #getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;

  #setting the state and symbol names

 if "states" in RecNames(params) then
    states := params.states;
     else
    states := List([1..DegreeOfSkeleton(sk)],String);
  fi;
  if "symbols" in RecNames(params) then
    symbols := params.symbols;
  else
    symbols := List([1..Size(Generators(TransSgp(sk)))],String);
  fi;

dotlist:=[];

for dx in [1..DepthOfSkeleton(sk)-1] do
   for  x1 in RepresentativeSetsOnDepth(sk,dx) do
     px1 := PermutatorGroup(sk,x1);
       hx1 := HolonomyGroup@SgpDec(sk,x1); 
     if not IsTrivial(px1)  then
              PermutatorGeneratorLabels:=[];
              W := NontrivialRoundTripWords(sk,x1);
               for w in W do #print the permutator generator words using named transitions
                  PermGenWord:=Concatenation(List(w,x->symbols[x]));   
                  Add(PermutatorGeneratorLabels,PermGenWord);
                    od; 
           dot:=DotSemigroupActionWithNames(px1,[1..DegreeOfSkeleton(sk)],OnPoints,states,PermutatorGeneratorLabels);
           Add(dotlist,dot);
       fi;
      od;
   od;

return dotlist;
end);



InstallGlobalFunction(SplashList,
function(dotlist)
local dot;
for dot in dotlist do Splash(dot); od;
end); 
