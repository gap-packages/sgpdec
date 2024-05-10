#############################################################################
##
## cascade.gi           SgpDec package
##
## Copyright (C) 2008-2022
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade transformations and permutations.
##

################################################################################
# CONSTRUCTORS #################################################################
################################################################################

# Component domains are the sets of integers [1..n] that the components of a
# (de)composition act on. This functions creates these domains when a list of
# components is given. These can be transformation semigroups, permutation
# groups or simply the size of the domain, or the domain itself.
InstallGlobalFunction(CreateComponentDomains,
function(comps)
  local domains, comp;
  domains:=[];
  for comp in comps do
    if IsTransformationSemigroup(comp) then
      Add(domains, [1..DegreeOfTransformationSemigroup(comp)]);
    elif IsPermGroup(comp) then
      Add(domains, MovedPoints(comp));
    elif IsPosInt(comp) then
      Add(domains, [1..comp]);
    else
      Add(domains, comp);
    fi;
  od;
  return domains;
end);

#todo: temporary naming
# figuring out whether we have a permutation cascade or not
FigureTypeOfCascade := function(comps,deps)
  if ForAll(comps, IsGroup)
     or
     ((not ForAny(comps, IsSemigroup))
      and ForAll(deps, x -> IsPerm(x[2]))) then
    return PermCascadeType;
  else
    return TransCascadeType;
  fi;
end;

InstallOtherMethod(Cascade, "for components and dependencies", [IsList, IsList],
function(comps, deps)
  return Cascade(comps, deps, FigureTypeOfCascade(comps, deps));
end);

# create a cascade for a given list of components (see ComponentDomains) for
# valid inputs and a list of dependencies
InstallMethod(Cascade, "for components and dependencies", [IsList, IsList, IsType],
function(comps, deps, type)
  local compdoms, depdom, depfuncs, o;
  o := Objectify(type, rec());
  compdoms:=CreateComponentDomains(comps);
  #TODO maybe there should be a ShallowCopy here? JDM
  depdom:=DependencyDomains(compdoms);
  depfuncs:=DependencyFunctions(depdom, deps);
  # setting the stored attributes of the newly created cascade
  SetDomainOf(o, EnumeratorOfCartesianProduct(compdoms));
  SetComponentDomains(o, compdoms);
  SetDependencyDomainsOf(o, depdom);
  SetDependencyFunctionsOf(o, depfuncs);
  SetNrComponents(o, Length(compdoms));
  return o;
end);

# a simple constructor that populates the object's members
# not meant for the end user at the commandline
InstallGlobalFunction(CreateCascade, #TODO call this from Cascade
function(dom, compdoms, depfuncs, depdom, type)
  local f;
  f:=Objectify(type, rec());
  SetDomainOf(f, dom);
  SetComponentDomains(f, compdoms);
  SetDependencyDomainsOf(f, depdom);
  SetDependencyFunctionsOf(f, depfuncs);
  SetNrComponents(f, Length(compdoms));
  return f;
end);

# no dependencies mean the identity transformation on all levels
# it creates a PermCascade by default
InstallGlobalFunction(IdentityCascade,
function(comps)
  return Cascade(comps,[]);
end);

# gives a random cascade for the given components (permutation groups and
# transformation semigroups) aiming for the given number of non-identity entry
InstallGlobalFunction(RandomCascade,
function(comps, numofdeps)
  local type, compdoms, depdoms, vals, len, inputs, j, k, val, depfuncs, i;

  if (not ForAll(comps, c-> IsPermGroup(c) or IsTransformationSemigroup(c))) then
    return fail; # components have to be perm groups or tss
  fi;
  # figuring out type
  if ForAll(comps, IsPermGroup) then
    type:=PermCascadeType;
  else
    type:=TransCascadeType;
  fi;

  compdoms:=CreateComponentDomains(comps);
  depdoms:=DependencyDomains(compdoms);

  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  len:=Sum(List(depdoms, Length));
  numofdeps:=Minimum([len, numofdeps]);

  inputs:=[1..len]; # indices for all input coordinates
  for i in [1..numofdeps] do
    j:=Random(inputs);
    RemoveSet(inputs, j);
    k:=1; # an awkward way of finding the right input
    while j>Length(depdoms[k]) do
      j:=j-Length(depdoms[k]);
      k:=k+1;
    od;
    val:=Random(comps[k]);
    if not IsOne(val) then
      vals[k][j]:=val;
    fi;
  od;
  depfuncs := List([1..Length(vals)],
                   x -> DependencyFunction(depdoms[x],vals[x]));

  return CreateCascade(EnumeratorOfCartesianProduct(compdoms),
                 compdoms, depfuncs, depdoms, type);
end);

################################################################################
# PERMUTATION CASCADE ##########################################################
################################################################################

InstallMethod(OneImmutable, "for a trans cascade",
[IsTransCascade],
function(ct)
  return CreateCascade(DomainOf(ct),
                       ComponentDomains(ct),
                       [],
                       DependencyDomainsOf(ct),
                       TransCascadeType);#IdentityCascade(ComponentDomains(ct));
end);

InstallMethod(OneImmutable, "for a permutation cascade",
[IsPermCascade],
function(ct)
  local id;
  id := IdentityCascade(ComponentDomains(ct));
  # just repackaging the Cascade id to PermCascade to get the right type
  return CreateCascade(DomainOf(id),
                 ComponentDomains(id),
                 DependencyFunctionsOf(id),
                 DependencyDomainsOf(id),
                 PermCascadeType);
end);

InstallOtherMethod(InverseMutable, "for a permutation cascade",
[IsPermCascade],
function(pc)
  local dfs, depdoms, vals, x, depfuncs, i, j;

  dfs:=DependencyFunctionsOf(pc);
  depdoms:=DependencyDomainsOf(pc);
  #empty values lookup table based on the sizes of depdoms
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  #going through all depdoms
  for i in [1..Length(depdoms)] do
    for j in [1..Length(depdoms[i])] do
      x:= OnDepArg(depdoms[i][j],dfs[i]);
      if not IsOne(x) then
        vals[i][Position(depdoms[i],OnCoordinates(depdoms[i][j],pc))]
          :=Inverse(x);
      fi;
    od;
  od;
  depfuncs := List([1..Length(vals)],
                   x -> DependencyFunction(depdoms[x],vals[x]));
  return CreateCascade(DomainOf(pc),
                 ComponentDomains(pc),
                 depfuncs,
                 depdoms,
                 PermCascadeType);
end);


################################################################################
# CHANGING REPRESENTATION ######################################################
################################################################################

InstallMethod(AsTransformation, "for trans cascade",
[IsCascade],
function(ct)
  return TransformationOp(ct, DomainOf(ct), OnCoordinates);
end);

InstallMethod(AsPermutation, "for perm cascade",
[IsPermCascade],
function(ct)
  return Permutation(ct, DomainOf(ct), OnCoordinates);
end);

# if the components are given then for groups permutations are produced
# if not, just transformations, even if it is a bijection
InstallMethod(AsCascade,
        "for a transformation and list of domain sizes or components",
        [IsTransformation, IsDenseList],
function(f, compsordomsizes)
  local depdoms,dom,n,vals,one,args,level,pos,i,j,depfuncs,coords,new, compdoms,
        domsizes;

  compdoms := CreateComponentDomains(compsordomsizes);
  domsizes := List(compdoms, Size);
  #sanity check on the domain sizes
  if not ForAll(domsizes, IsPosInt)
     or DegreeOfTransformation(f)>Product(domsizes) then
    Print("#W number of points bigger than the number of coordinate values\n");
    return fail;
  fi;
  #the actual algorithm#########################################################
  depdoms:=DependencyDomains(domsizes);
  dom:=EnumeratorOfCartesianProduct(compdoms);
  n:=Length(domsizes);
  #vals collecting the images of individual points
  vals:=List(depdoms, x-> List([1..Length(x)], x-> []));
  #initially we assume that it is the identity everywhere (array of flags)
  one:=List(depdoms, x-> BlistList([1..Length(x)], [1..Length(x)]));
  #for all points of the transformations check how the corresponding path moves
  for i in [1..DegreeOfTransformation(f)] do
    coords := dom[i]; #the coordinatized original point i
    new := dom[i^f];
    #we copy coords, as we will remove its elements one by one
    args:=ShallowCopy(coords);
    for level in Reversed([1..n]) do
      Remove(args, level);
      #the position in dependency domain on the level
      pos:=Position(depdoms[level], args);
      if IsBound(vals[level][pos][coords[level]])
         and vals[level][pos][coords[level]] <>  new[level] then
        Print("#W not in the wreath product\n");
        return fail;
      else
        #registering even the trivial map is important as it may conflict
        vals[level][pos][coords[level]] := new[level];
        #if we find a nontrivial map, then we flip the bit and unbind later
        if coords[level] <> new[level] then
          one[level][pos] := false;
        fi;
      fi;
    od;
  od;
  #post process - turning the image lists into transformations##################
  for i in [1..Length(vals)] do
    for j in [1..Length(vals[i])] do
      if one[i][j] then
        Unbind(vals[i][j]);
      else
        if IsPermGroup(compsordomsizes[i]) then
          vals[i][j]:=PermList(vals[i][j]);
        else
          vals[i][j]:=TransformationNC(vals[i][j]);
        fi;
      fi;
    od;
  od;
  #creating the dependency function objects#####################################
  depfuncs := List([1..Length(vals)],
                   x -> DependencyFunction(depdoms[x],vals[x]));
  return CreateCascade(dom, compdoms, depfuncs, depdoms, TransCascadeType);
end);

# dispatching to AsCascade for transformations after figuring out the degree
InstallOtherMethod(AsCascade,
        "for a permutation and list of domain sizes or components",
        [IsPerm, IsDenseList],
function(p, compsordomsizes)
  local domsizes;
  return AsCascade(AsTransformation(p), compsordomsizes);
end);

# acting on coordinates by a cascade transformation
InstallGlobalFunction(OnCoordinates,
function(coords, ct)
  local dfs, prefix, out, len, i;

  dfs:=DependencyFunctionsOf(ct);
  len:=Length(coords);
  # prefix contains the dependency function arguments, built one by one
  prefix:=EmptyPlist(len);
  out:=EmptyPlist(len);

  for i in [1..len] do
    out[i]:=OnPoints(coords[i], OnDepArg(prefix, dfs[i]));
    prefix[i]:=coords[i];
  od;
  return out;
end);

# registering the above action as a method for ^
#InstallOtherMethod(\^, "for coordinate list and cascade", #TODO after Cascade became List this caused trouble
#[IsList, IsCascade], OnCoordinates);

# cascade composition (wreath product multiplication), registered as *
# assuming that they have the same dependency domains TODO: shall we check?
InstallGlobalFunction(CascadeComposition,
function(f,g)
  local dep_f, dep_g, depdoms, vals, x, i, j, depfuncs,type;

  dep_f:=DependencyFunctionsOf(f);
  dep_g:=DependencyFunctionsOf(g);
  depdoms:=DependencyDomainsOf(f);
  #empty values lookup table based on the sizes of depdoms
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  #going through all depency domains
  for i in [1..Length(depdoms)] do
    #and for all coordinate prefixes in the domain
    for j in [1..Length(depdoms[i])] do
      x:= OnDepArg(depdoms[i][j],
                   dep_f[i]) #the acion of f on the coordinate prefix
          *  #permutation or transformation composition
          OnDepArg(OnCoordinates(depdoms[i][j],f), #transformed by f
                   dep_g[i]); #the action of g on those
      if not IsOne(x) then #identity is the defualt, no need to store
        vals[i][j]:=x;
      fi;
    od;
  od;
  #if they are both permutation cascades, then they produce permutation cascade
  if (IsPermCascade(f)) and (IsPermCascade(g)) then
    type := PermCascadeType;
  else
    type := TransCascadeType;
  fi;
  depfuncs := List([1..Length(vals)],
                   x -> DependencyFunction(depdoms[x],vals[x]));
  return CreateCascade(DomainOf(f), ComponentDomains(f), depfuncs, depdoms,
  type);
end);

# registering the above compsition as a method for *
InstallMethod(\*, "for cascades", [IsCascade, IsCascade], CascadeComposition);

InstallMethod(\<, "for cascade and cascade", IsIdenticalObj,
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunctionsOf(p) < DependencyFunctionsOf(q);
end);

InstallOtherMethod(\=, "for cascade and cascade",
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunctionsOf(p) = DependencyFunctionsOf(q);
end);

# attributes
# the number of nontrivial dependency function values
InstallOtherMethod(NrDependencies, "for a cascade",
[IsCascade],
function(f)
  return Sum(DependencyFunctionsOf(f),
   x-> NrDependencies(x));
end);

# returning the dependencies back in a flat list
# not for time critical code, but DotCascade can be made representation agnostic
InstallGlobalFunction(DependenciesOfCascade,
function(ct)
  return Concatenation(List(DependencyFunctionsOf(ct),
                 df -> Dependencies(df)));
end);

################################################################################
# printing #####################################################################
################################################################################
InstallMethod(ViewObj, "for a cascade",
[IsCascade],
function(f)
  local str, x;

  if IsTransCascade(f) then
    str:="<trans ";
  else
    str:="<perm ";
  fi;
  Append(str, "cascade with ");
  Append(str, String(NrComponents(f)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponents(f)*3)-12
   then
    Append(str, " with (");
    for x in ComponentDomains(f) do
      Append(str, String(Length(x)));
      Append(str, ", ");
    od;
    Remove(str, Length(str));
    Remove(str, Length(str));
    Append(str, ") pts");
  fi;
  if Length(str)<SizeScreen()[1]-
   Length(String(NrDependencies(f)))-8 then
    Append(str, ", ");
    Append(str, String(NrDependencies(f)));
    Append(str, " dependencies");
  fi;

  Append(str, ">");
  Print(str);
  return;
end);

InstallMethod(PrintObj, "for a cascade",
[IsCascade],
function(c)
  Print("Cascade( ");
  Print(ComponentDomains(c));
  Print(", ");
  Print(DependenciesOfCascade(c));
  Print(" )");
  return;
end);

InstallMethod(PrintString, "for a cascade",
[IsCascade],
function(c)
  local str;

  str:="Cascade( ";
  Append(str, PrintString(ComponentDomains(c)));
  Append(str, ", ");
  Append(str, PrintString(DependenciesOfCascade(c)));
  Append(str, " )");
  return str;
end);

InstallMethod(Display, "for a cascade",
[IsCascade],
function(c)
  Perform(DependencyFunctionsOf(c),Display);
  return;
end);

##### IsList methods #### implementing some minimal list functionality
# just for being hashed by HashBasic in datastructures
InstallMethod(Length, "for a cascade",
[IsCascade],
function(c)
  return Length(DependencyFunctionsOf(c));
end);

InstallMethod(IsFinite, "for a cascade",
[IsCascade],
function(c)
  return true;
end);


InstallOtherMethod(IsBound\[\], "for a casacde and an index",
[IsCascade,IsInt],
function(c,i)
  return IsBound(DependencyFunctionsOf(c)[i]);
end);

InstallOtherMethod(\[\], "for a cascade and an index",
[IsCascade,IsInt],
function(c,i)
  return Dependencies(DependencyFunctionsOf(c)[i]);
end);

################################################################################
## drawing #####################################################################
################################################################################
# 1: a cascade
# 2(opt): some extra info string, that will be  printed in a box
InstallGlobalFunction(DotCascade,
function(arg)
  local str, out,
        vertices, vertexlabels,
        edges, edgelabels,
        dep, coordsname,
        level, newcoordsname, edge, coord,
        edgeDB,depargs, recdraw, depfuncs, n, compdoms,
        EMPTYVERTEXLABEL,GREYLABELPREFIX,BLACKLABELPREFIX;
  EMPTYVERTEXLABEL:="[color=grey,width=0.1,height=0.1,fontsize=11,label=\"\"]";
  GREYLABELPREFIX := " [color=grey,label=\"";
  BLACKLABELPREFIX := " [color=black,label=\"";
  #-----------------------------------------------------------------------------
  recdraw := function(coordprefix, nodename,inscope) #inscope sg above not fixed
    local l,i,nontrivial,childname,val;
    nontrivial := false;
    l := Length(coordprefix);
    val := coordprefix^depfuncs[l+1];
    if IsOne(val) then
      if inscope then
      PrintTo(out,Concatenation(nodename,
              BLACKLABELPREFIX,"\"];\n"));
      fi;
      #otherwise do nothing, empty gray label is default
    else
      PrintTo(out,Concatenation(nodename,
              BLACKLABELPREFIX,
              SimplerAttractorCycleNotation(val),"\"];\n"));
      nontrivial := true;
    fi;
    if l+1 = n then return; fi;
    for i in compdoms[l+1] do
      #drawing
      childname := Concatenation(nodename,"_", String(i));
      if (inscope or nontrivial) then
        PrintTo(out,Concatenation(nodename ," -- ", childname,
                BLACKLABELPREFIX, String(i),"\"];\n"));
      else
        PrintTo(out,Concatenation(nodename ," -- ", childname,
                GREYLABELPREFIX, String(i),"\",fontcolor=grey];\n"));
      fi;
      recdraw(Concatenation(coordprefix, [i]), childname,nontrivial or inscope);
    od;
  end;
  #-----------------------------------------------------------------------------
  depfuncs := DependencyFunctionsOf(arg[1]);
  compdoms := ComponentDomains(arg[1]);
  n := Size(depfuncs);
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"//dot\ngraph ct{\n");
  PrintTo(out," node",EMPTYVERTEXLABEL,";\n");
  PrintTo(out," edge ", "[color=grey,fontsize=11,fontcolor=black]", ";\n");
  recdraw([],"n",false);
  #finally printing the top label if needed
  if IsBound(arg[2]) then
    PrintTo(out,"orig [shape=record,label=\"",arg[2],"\",color=\"black\"];\n");
    PrintTo(out,"orig--n [style=invis];\n");
  fi;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);

# 1: a cascade
# 2(opt): some extra info string, that will be  printed in a box
InstallGlobalFunction(DotCascadeAction,
function(arg)
  local str, out,
        vertices, vertexlabels,
        edges, edgelabels,
        dep, coordsname,
        level, newcoordsname, edge, coord,
        edgeDB,depargs, recdraw, depfuncs, n, compdoms,
        EMPTYVERTEXLABEL,GREYLABELPREFIX,BLACKLABELPREFIX;
  EMPTYVERTEXLABEL:="[color=black,width=0.1,height=0.1,label=\"\"]";
  BLACKLABELPREFIX := " [color=black,label=\"";
  #-----------------------------------------------------------------------------
  recdraw := function(coordprefix, nodename)
    local l,i,childname,val;
    l := Length(coordprefix);
    if l = n then return; fi;
    val := coordprefix^depfuncs[l+1];
    PrintTo(out,Concatenation(nodename,EMPTYVERTEXLABEL,";\n"));
    for i in compdoms[l+1] do
      #drawing
      childname := Concatenation(nodename,"_", String(i));
      PrintTo(out,Concatenation(nodename ," -- ", childname,
              BLACKLABELPREFIX, String(i^val),"\"];\n"));
      recdraw(Concatenation(coordprefix, [i]), childname);
    od;
  end;
  #-----------------------------------------------------------------------------
  depfuncs := DependencyFunctionsOf(arg[1]);
  compdoms := ComponentDomains(arg[1]);
  n := Size(depfuncs);
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"//dot\ngraph ct{\n");
  PrintTo(out," node",EMPTYVERTEXLABEL,";\n");
  PrintTo(out," edge ", "[color=grey,fontsize=11,fontcolor=black]", ";\n");
  recdraw([],"n");
  #finally printing the top label if needed
  if IsBound(arg[2]) then
    PrintTo(out,"orig [shape=record,label=\"",arg[2],"\",color=\"black\"];\n");
    PrintTo(out,"orig--n [style=invis];\n");
  fi;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
