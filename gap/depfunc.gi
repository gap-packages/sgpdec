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
## depfunc - dependency function
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
  MakeImmutable(vals); #just to be on the safe side
  ShrinkAllocationPlist(vals);
  return Objectify(DependencyFunctionType,rec(dom:=dom,vals:=vals));
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
              x -> DependencyFunction(depdoms[x],vals[x]));
end);

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
  local i, pvals, qvals;
  if p.dom <> q.dom then return false; fi;
  #local variables for speeding up record member access
  pvals := p!.vals;
  qvals := q!.vals;
  if IsEmpty(pvals) and IsEmpty (qvals) then return true; fi;
  for i in [1..Size(p!.dom)] do
    if (not IsBound(pvals[i])) and (not IsBound(qvals[i])) then
      break; # that is good
    fi;
    if IsBound(pvals[i]) and IsBound(qvals[i]) and  pvals[i] = qvals[i] then
      break; #that's also good
    fi;
    return false;
  od;
  return true;
end);

InstallMethod(\<, "for depfunc and depfunc", IsIdenticalObj,
[IsDependencyFunction, IsDependencyFunction],
        function(p,q)
  local pval, qval,i;
  #first compare the domains
  if p!.dom <> q!.dom then return p!.dom < q!.dom; fi;
  for i in [1..Size(p!.dom)] do
    if IsBound(p!.vals[i]) then
      pval := p!.vals[i];
    else
      pval := ();
    fi;
    if IsBound(q!.vals[i]) then
      qval := q!.vals[i];
    else
      qval := ();
    fi;
    #TODO this was a quick fix to avoid () < Transformation([...]) problem
    if AsTransformation(pval) < AsTransformation(qval) then
      return true;
    else
      return false;
    fi;
  od;
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
[IsList, IsDependencyFunction], OnDepArg);

################################################################################
# PRINTING #####################################################################
################################################################################

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunction],
function(x) Print("<depfunc of depth ",
        String(Size(Representative(DomainOf(x)))+1)," with ",
        String(NrDependencies(x))," deps>"); return; end);

InstallMethod(Display, "for a dependency function",
[IsDependencyFunction],
function(df)
  local vals, dom, i;
  Print("Dependency function of depth ",
        String(Size(Representative(DomainOf(df)))+1)," with ",
        String(NrDependencies(df))," dependencies.\n");
  vals := df!.vals;
  dom := df!.dom;
  for i in [1..Size(vals)] do
    if IsBound(vals[i]) then
      Print(String(dom[i])," -> ");
      #TODO String(vals[i][j]) return <object>
      Display(vals[i]);
    fi;
  od;
  return;
end);
