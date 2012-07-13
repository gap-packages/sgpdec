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
local i;                
  #if size differs then they are not even comparable
  if (Length(l1) <> Length(l2)) or (l1 = l2) then return false; fi;
  for i in [1..Length(l1)] do
    #equality already tested for the full list so we check corresponding positions
    if not (l1[i] = l2[i] or l1[i] = 0) then return false; fi;
  od;
  return true;  
end
);

InstallGlobalFunction(IsOverlapping,
function(l1, l2)
local i;
  if (Length(l1) <> Length(l2)) then 
    Print("#W overlapping defined only for same-length coordinate tuples");
    return false;
  fi;
  for i in [1..Length(l1)] do
    #if not equal then one of them should be *  
    if not ( (l1[i]=l2[i]) or (l1[i]=0) or (l2[i]=0)) then
      return false;
    fi;
  od;
  return true;
end
);

InstallGlobalFunction(RegisterNewDependency,
function(depfunctable, newarg,newaction)
local matches,updated,i,args,actions,level;
    #first we get the proper lists
    level := Length(newarg) + 1;
    if not IsBound(depfunctable[level]) then 
      depfunctable[level] := [[],[]];
    fi;
    args := depfunctable[level][1];
    actions := depfunctable[level][2];
    #finding matching entries and check the action
    matches := [];
    for i in [1..Length(args)] do
      if IsOverlapping(args[i], newarg) then
        if newaction <> actions[i] then Error("action mismatch in registering dependency"); fi; 
        Add(matches,i);
      fi;
    od; 
    #finding the proper entry
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
    if not updated then 
      Add(args,newarg);
      Add(actions,newaction);  
    fi;
end
);

InstallGlobalFunction(SearchDepFuncTable,
function(depfunctable, arg)
local i, args, actions,level;
    #first we get the proper lists
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
end
);


_depfunctable_Coordinates2String := function(coords)
local str,i;
  str := "C(";
  for i in [1..Length(coords)] do
    if coords[i] > 0 then 
      str := Concatenation(str,StringPrint(coords[i]));
    else
      str := Concatenation(str,"*");
    fi;
    if i < Length(coords) then
      str := Concatenation(str,",");
    fi;
  od;
  str := Concatenation(str,")");
  return str;
end;

InstallGlobalFunction(ShowDependencies,
function(depfunctable)
local i,j;
  for i in [1..Length(depfunctable)] do
    if IsBound(depfunctable[i]) then
      for j in [1..Length(depfunctable[i][1])] do
        Print(_depfunctable_Coordinates2String(depfunctable[i][1][j]), " -> ");
        if IsPerm( depfunctable[i][2][j]) then
          Print(depfunctable[i][2][j], "\n");
        else
          Print(SimplerLinearNotation(depfunctable[i][2][j]), "\n");            
        fi;              
      od;
    fi;
  od;
end
);