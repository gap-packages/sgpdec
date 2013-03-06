#############################################################################
##
## depfunc.gi           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Dependency function.
##

## NAMING CONVENTIONS
## deparg - dependency argument, a tuple of states (formerly prefix)
## dom - domain of dependency function
## deps - list of dependecies in the [arg, value] format
## depdoms - dependency domains, i.e. domains of dependency functions

################################################################################
# CONSTRUCTORS #################################################################
################################################################################

# constructor for dependency functions
# input: domain and list of dependencies
InstallGlobalFunction(DependencyFunction,
function(dom, deps)
  local record,depdoms,vals,d;
  #this is a subtle issue: we need an element in the domain, even on the top
  if IsEmpty(dom) then
    dom := [[]];
  fi;
  #depdoms:=CreateDependencyDomains(doms);
  vals:=EmptyPlist(Length(dom));
  for d in deps do
    #vals[Length(d[1])+1][Position(depdoms[Length(d[1])+1], d[1])]:=d[2];
    vals[Position(dom,d[1])] := d[2];
  od;
  ShrinkAllocationPlist(vals);
  return CreateDependencyFunction(dom, vals);
end);

# just creating an instance when you know the internals
InstallGlobalFunction(CreateDependencyFunction,
function(dom, vals)
  MakeImmutable(vals); #just to be on the safe side
  return Objectify(NewType(CollectionsFamily(FamilyObj(vals)),IsDependencyFunc),
                 rec(dom:=dom,vals:=vals));
end);

# Creates the list of all dependency domains of given sizes.
# These are the arguments of the dependency functions on each level.
# doms: list of pos ints or actual domains, integer x is converted to [1..x]
InstallGlobalFunction(DependencyDomains,
function(doms)
  local depdoms, tup, i;
  #converting integers to actual domains
  doms := List(doms,
               function(x) if IsPosInt(x) then return [1..x];
                           else return x; fi;end);
  #converting to domains if semigroups/groups
  if IsSemigroup(doms[1]) then
    doms := ComponentDomains(doms);
  fi;
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

# distributing dependencies into individual dependency functions
InstallGlobalFunction(Deps2DepFuncs,
function(depdoms, deps)
local dep, vals, level;
  vals := List([1..Size(depdoms)], x->[]);
  for dep in deps do
    level := Size(dep[1])+1;
    vals[level][Position(depdoms[level],dep[1])] := dep[2];
  od;
  return List([1..Size(depdoms)],
              x -> CreateDependencyFunction(depdoms[x],vals[x]));
end);

################################################################################
# ATTRIBUTES ###################################################################
################################################################################

InstallMethod(NrDependencies, "for a dependency function",
[IsDependencyFunc],
function(f)
  return Number([1..Length(f!.vals)], i-> IsBound(f!.vals[i]));
end);

###############################################################################
# STANDARD METHODS ############################################################
###############################################################################

InstallMethod(\=, "for depfunc and depfunc", IsIdenticalObj,
[IsDependencyFunc, IsDependencyFunc],
function(p,q)
  return (p!.dom = q!.dom) and (p!.vals = q!.vals);
end);


################################################################################
# ACTION #######################################################################
################################################################################

InstallGlobalFunction(OnDepArg,
function(deparg, depfunc)
  local vals, dom, i, pos;
  vals:=depfunc!.vals;
  dom:=depfunc!.dom;
  #if the argument is not in the domain
  if not(deparg in dom) then return fail; fi;
  #searching for the position of the argument tuple
  pos:=Position(dom, deparg);
  #the default value is the identity
  if not IsBound(vals[pos]) then
    return ();
  fi;
  return vals[pos];
end);

# applying to a tuple (deparg) gives the corresponding value
InstallOtherMethod(\^, "for dependency argument and dependency func",
[IsList, IsDependencyFunc], OnDepArg);

################################################################################
# PRINTING #####################################################################
################################################################################

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunc],
function(x) Print("<dependency function, ",
        String(NrDependencies(x))," deps>"); return; end);
