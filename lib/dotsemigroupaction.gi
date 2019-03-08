# this file contains methods for producing strings that contain dot format
# descriptions of various types of objects.

# please keep the file alphabetized.

#

# Usage: a small semigroup with generators.

# Returns: a string.

# Notes: this does not draw a meaningful picture if applied to a transformation
# semigroup.


###

# Usage: semigroup, list, action. For example,
# DotSemigroupAction(s, Elements(s), OnRight);
# DotSemigroupAction(s, Combinations([1..4]), OnSets);
# DotSemigroupAction(s, [1..4], OnPoints);

# try the above with a group!

# Returns: a string

# Notes: generalizes Draw for a transformation semigroup.

# AN's code, hash tables should be removed from here. Edge labels don't work
# properly.

if not TestPackageAvailability("orb", "3.7")=fail then
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
          " -> \"", StringPrint(act(list[i],gens[t])), "\"");
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
fi;



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

if not TestPackageAvailability("orb", "3.7")=fail then
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
fi;

########################################################## 


#EOF
