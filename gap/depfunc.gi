#############################################################################
##
## depfunc.gi           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Dependency functions.
##

# Creates the list of all prefixes of a given size. These are the arguments of
# the dependency functions on each level.
# comps: list of pos ints or actual domains, integer x is converted to [1..x]
InstallGlobalFunction(CreateDependencyDomains,
function(comps)
  local prefix, tup, i;
  #converting integers to actual domains
  comps := List(comps,
          function(x) if IsPosInt(x) then return [1..x]; else return x; fi;end);
  #JDM Why +1? To avoid reallocation?
  prefix:=EmptyPlist(Length(comps)+1);
  #the top level prefix is just the empty list
  prefix[1]:=[[]];
  tup:=[]; #we add the components one by one
  for i in [1..Length(comps)-1] do
    Add(tup, comps[i]);
    Add(prefix, EnumeratorOfCartesianProduct(tup));
  od;
  return prefix;
end);

# constructor for dependency functions
InstallGlobalFunction(CreateDependencyFunction,
function(prefixes, vals)
  local record;
  record:=rec(vals:=vals, prefixes:=prefixes);
  return Objectify(NewType(CollectionsFamily(FamilyObj(vals[2])),
   IsDependencyFunc), record);
end);

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunc],
function(x) Print("<dependency function>"); return; end);

# applying to a tuple (prefix) gives the corresponding value
InstallOtherMethod(\^, "for a tuple and dependency func",
[IsList, IsDependencyFunc],
function(tup, depfunc)
  local vals, prefixes, i, pos;

  vals:=depfunc!.vals;
  prefixes:=depfunc!.prefixes;
  i:=Length(tup)+1;
  #in case the argument tuple is longer
  if not IsBound(prefixes[i]) then
    return fail;
  fi;
  #searching for the position of the argument tuple
  pos:=Position(prefixes[i], tup);
  #if it is not there, then the argument is not comaptible with df
  if pos=fail then
    return fail;
  fi;
  #the default value is the identity
  if not IsBound(vals[i][pos]) then
    return ();
  fi;
  return vals[i][pos];
end);
