#############################################################################
##
## depfunctable.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Functions for handling of tables of dependency functions.
##
## An elementary dependency is simple argument-value pair. For each length
## (the ith level dependecies) there
## is a list containing the elementary dependencies in parallel lists.
## The dependency table is finally a list containing the ith level dependencies
## in its ith slot.

#TODO implement sorted lists for entries

# for creating dependency table by giving dependency function maps in a list
# of argument-value pairs (the default dependency function value is () )
InstallGlobalFunction(DependencyTable,
function(pairs)
local  pair, depfunctable;
  #creating new dependency function table
  depfunctable := [];
  #and just registering these new dependencies
  for pair in pairs do
    RegisterNewDependency(depfunctable,pair[1],pair[2]);
  od;
  return  depfunctable;
end);

#returns true if l1 matches l2, l1 is more abstract then l2,
# i.e. for all i, l1[i] = l2[i] OR l1[i]=0
InstallGlobalFunction(IsStrictlyMoreAbstract,
function(l1, l2)
  #if size differs then they are not even comparable, if equal then not strict
  if (Length(l1) <> Length(l2)) or (l1 = l2) then return false; fi;
  #equality already tested for the list so we check corresponding positions
  return ForAll([1..Length(l1)], i ->  (l1[i] = l2[i] or l1[i] = 0));
end);

InstallGlobalFunction(IsOverlapping,
function(l1, l2)
  if (Length(l1) <> Length(l2)) then
    Print("#W overlapping defined only for same-length coordinate tuples");
    return false;
  fi;
  #if not equal then one of them should be *
  return ForAll([1..Length(l1)], i -> (l1[i]=l2[i]) or (l1[i]=0) or (l2[i]=0));
end);

InstallGlobalFunction(RegisterNewDependency,
function(depfunctable, newarg,newaction)
local matches,updated,i,args,actions,level;
  #first we get the proper lists
  level := Length(newarg) + 1;
  #we may not have any entry yet, then we create the empty table
  if not IsBound(depfunctable[level]) then
    depfunctable[level] := [[],[]];
  fi;
  #for convenience we have these variables
  args := depfunctable[level][1];
  actions := depfunctable[level][2];
  #finding all matching entries and check the action
  matches := [];
  for i in [1..Length(args)] do
    if IsOverlapping(args[i], newarg) then
      if newaction <> actions[i] then
        Error("action mismatch in registering dependency");
      fi;
      Add(matches,i);
    fi;
  od;
  #finding the proper (the most abstract) entry
  updated := false;
  for i in matches do
    if (newarg = args[i]) or IsStrictlyMoreAbstract(args[i],newarg) then
      #do nothing, the stored entry is more abstract
      updated := true;
      break;
    elif  IsStrictlyMoreAbstract(newarg, args[i]) then
      #update the arg to be more abstract
      args[i] := newarg;
      updated := true;
      break;
    fi;
  od;
  #if no matching entry was found, simply add the new dependency
  if not updated then
    Add(args,newarg);
    Add(actions,newaction);
  fi;
end);

InstallGlobalFunction(SearchDepFuncTable,
function(depfunctable, arg)
local i, args, actions,level;
  level := Length(arg) + 1;
  if not IsBound(depfunctable[level]) then
    return fail;
  fi;
  args := depfunctable[level][1];
  actions := depfunctable[level][2];
  for i in [1..Length(args)] do
    if args[i] = arg or IsStrictlyMoreAbstract(args[i], arg) then
      return actions[i];
    fi;
  od;
  return fail;
end);

#this is a low-level display function that is due to be replaced with
#a more integrated one
InstallGlobalFunction(ShowDependencies,
function(depfunctable)
local i,j;
  for i in [1..Length(depfunctable)] do
    if IsBound(depfunctable[i]) then
      for j in [1..Length(depfunctable[i][1])] do
        Print(depfunctable[i][1][j], " -> ");
        if IsPerm( depfunctable[i][2][j]) then
          Print(depfunctable[i][2][j], "\n");
        else
          Print(SimplerLinearNotation(depfunctable[i][2][j]), "\n");
        fi;
      od;
    fi;
  od;
end);