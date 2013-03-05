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

## naming conventions
## deparg - dependency argument, a tuple of states (formerly prefix)

# Creates the list of all dependency domains of given sizes.
# These are the arguments of the dependency functions on each level.
# doms: list of pos ints or actual domains, integer x is converted to [1..x]
InstallGlobalFunction(CreateDependencyDomains,
function(doms)
  local depdoms, tup, i;
  #converting integers to actual domains
  doms := List(doms,
          function(x) if IsPosInt(x) then return [1..x]; else return x; fi;end);
  #JDM Why +1? To avoid reallocation?
  depdoms:=EmptyPlist(Length(doms)+1);
  #the top level depdoms is just the empty list
  depdoms[1]:=[[]];
  tup:=[]; #we add the components one by one
  for i in [1..Length(doms)-1] do
    Add(tup, doms[i]);
    Add(depdoms, EnumeratorOfCartesianProduct(tup));
  od;
  return depdoms;
end);

# constructor for dependency functions
# input: component domains and list of dependencies
InstallGlobalFunction(DependencyFunction,
function(doms, deps)
  local record,depdoms,vals,d;

  depdoms:=CreateDependencyDomains(doms);
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));

  for d in deps do
    vals[Length(d[1])+1][Position(depdoms[Length(d[1])+1], d[1])]:=d[2];
  od;
  ShrinkAllocationPlist(vals);
  return CreateDependencyFunction(depdoms, vals);
end);

# constructor when you the internals
InstallGlobalFunction(CreateDependencyFunction,
function(doms, deps)
  local record;
  record:=rec(vals:=vals, depdoms:=depdoms);
  return Objectify(NewType(CollectionsFamily(FamilyObj(vals[2])),
   IsDependencyFunc), record);
end);

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunc],
function(x) Print("<dependency function>"); return; end);

# applying to a tuple (deparg) gives the corresponding value
InstallOtherMethod(\^, "for dependency argument and dependency func",
[IsList, IsDependencyFunc],
function(deparg, depfunc)
  local vals, depdoms, i, pos;

  vals:=depfunc!.vals;
  depdoms:=depfunc!.depdoms;
  i:=Length(deparg)+1;
  #in case the argument tuple is longer
  if not IsBound(depdoms[i]) then
    return fail;
  fi;
  #searching for the position of the argument tuple
  pos:=Position(depdoms[i], deparg);
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
