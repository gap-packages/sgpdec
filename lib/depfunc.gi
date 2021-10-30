#############################################################################
##
## depfunc.gi           SgpDec package
##
## (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2021
##
## Dependency function. A lookup for [arg,val] pairs.
##

## NAMING CONVENTIONS
## depfunc - dependency function
## deparg - dependency argument, a tuple of states (formerly prefix)
## deps - list of dependecies in the [arg, value] format
## dom - domain of dependency function
## depdoms - dependency domains, i.e. domains of dependency functions

################################################################################
# CONSTRUCTORS #################################################################
################################################################################

# constructor for dependency functions
# input: domain and list of dependencies
InstallGlobalFunction(DependencyFunction,
function(dom, list)
  local record,depdoms,vals,d;
  #this is a subtle issue: we need an element in the domain, even on the top
  if IsEmpty(dom) then
    dom := [[]];
  fi;
  # if list is empty then the we have an empty lookup table
  if IsEmpty(list) then
    vals := [];
  # if list contains mappings then we have to process them
  elif IsBound(list[1]) and IsList(list[1]) then
    vals:=EmptyPlist(Length(dom));
    for d in list do
      vals[Position(dom,d[1])] := d[2];
    od;
  #otherwise we received a lookup table
  else
    vals := list;
  fi;
  ShrinkAllocationPlist(vals);
  MakeImmutable(vals); #just to be on the safe side
  return Objectify(DependencyFunctionType,rec(dom:=dom,vals:=vals));
end);

# distributing dependencies into individual dependency functions
# according to their level
InstallGlobalFunction(DependencyFunctions,
function(depdoms, deps)
local dep, vals, level;
  vals := List([1..Size(depdoms)], x->[]);
  for dep in deps do
    level := Size(dep[1])+1; #argument size gives depth
    vals[level][Position(depdoms[level],dep[1])] := dep[2];
  od;
  return List([1..Size(depdoms)],
              x -> DependencyFunction(depdoms[x],vals[x]));
end);

# Creates the list of all dependency domains of given sizes.
# These are the arguments of the dependency functions on each level.
# doms: list of pos ints or actual domains, integer x is converted to [1..x]
InstallGlobalFunction(DependencyDomains,
function(doms)
  local depdoms, tup, i;
  doms := CreateComponentDomains(doms);
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

# extracting dependencies according in [arg, val] format
InstallGlobalFunction(Dependencies,
function(df)
  local deps,i,dom,vals;
  vals := df!.vals;
  dom := df!.dom;
  deps := [];
  for i in [1..Size(vals)] do
    if IsBound(vals[i]) then
      Add(deps, [dom[i], vals[i]]);
    fi;
  od;
  return deps;
end);

#just the compacted list of values of the depfunc
InstallGlobalFunction(DependencyValues,
function(df)
  return DuplicateFreeList(Compacted(df!.vals));
end);

################################################################################
# ATTRIBUTES ###################################################################
################################################################################

InstallMethod(NrDependencies, "for a dependency function",
[IsDependencyFunction],
function(f)
  return Number([1..Length(f!.vals)], i-> IsBound(f!.vals[i]));
end);

# to have controlled access to the domain, TODO not 100% sure about this
InstallMethod(DomainOf,[IsDependencyFunction], df-> df!.dom);

###############################################################################
# STANDARD METHODS ############################################################
###############################################################################

InstallMethod(\=, "for depfunc and depfunc", IsIdenticalObj,
[IsDependencyFunction, IsDependencyFunction],
function(p,q)
  return p!.dom = q!.dom and p!.vals = q!.vals;
end);

InstallMethod(\<, "for depfunc and depfunc", IsIdenticalObj,
[IsDependencyFunction, IsDependencyFunction],
function(p,q)
  if p!.dom <> q!.dom then return fail; fi;
  return p!.vals < q!.vals;
end);

################################################################################
# ACTION #######################################################################
################################################################################

# applying to a tuple (deparg) gives the corresponding value
InstallGlobalFunction(OnDepArg,
function(deparg, depfunc)
  local vals, dom, i, pos;
  dom:=depfunc!.dom;
  #if the argument is not in the domain
  if not(deparg in dom) then return fail; fi;
  #searching for the position of the argument tuple
  pos:=Position(dom, deparg);
  vals:=depfunc!.vals;
  #the default value is the identity
  if not IsBound(vals[pos]) then
    return ();
  fi;
  return vals[pos];
end);

# jus registering the above action as a method for ^
InstallOtherMethod(\^, "for dependency argument and dependency func",
[IsList, IsDependencyFunction], OnDepArg);

################################################################################
# PRINTING #####################################################################
################################################################################

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunction],
function(x) Print("<depfunc of depth ",
        String(Size(Representative(DomainOf(x)))+1)," with ",
        String(NrDependencies(x))," deps>"); return; end);

InstallMethod(DisplayString, "for a dependency function",
[IsDependencyFunction],
function(df)
  local vals, dom, i, str;
  str := Concatenation("Dependency function of depth ",
    String(Size(Representative(DomainOf(df)))+1)," with ",
    String(NrDependencies(df))," dependencies.");
  vals := df!.vals;
  dom := df!.dom;
  if IsBound(vals[1]) then
    Append(str, "\n");
    Append(str,String(dom[1]));
    Append(str," -> ");
    Append(str, PrintString(vals[1]));
  fi;
  for i in [2..Size(vals)] do
    if IsBound(vals[i]) then
      Append(str,"\n");
      Append(str,Concatenation(String(dom[i])," -> "));
      Append(str,PrintString(vals[i]));
    fi;
  od;
  Append(str,"\n");
  return str;
end);
