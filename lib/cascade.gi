#############################################################################
##
## cascade.gi           SgpDec package
##
## Copyright (C) 2008-2019
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Cascade transformations and permutations.
##

################################################################################
# CONSTRUCTORS #################################################################
################################################################################

#  ways to create cascades
# 1. Cascade, giving components/component domains and a list of dependencies
# 2. by giving dependency functions
InstallGlobalFunction(Cascade,
function(doms, deps)
  local isgroup, type, compdoms, depdom, depfuncs, f, x;

  if IsListOfPermGroupsAndTransformationSemigroups(doms) then
    compdoms:=ComponentDomains(doms);
  else
    compdoms:=List(doms,
               function(x) if IsPosInt(x) then return [1..x];
                           else return x; fi;end);
  fi;

  if ForAll(doms, IsGroup) then
    f:=Objectify(PermCascadeType, rec());
  else
    f:=Objectify(TransCascadeType, rec());
  fi;

  #maybe there should be a ShallowCopy here? JDM
  depdom:=DependencyDomains(compdoms);
  depfuncs:=DependencyFunctions(depdom, deps);

  SetDomainOf(f, EnumeratorOfCartesianProduct(compdoms));
  SetComponentDomains(f, compdoms);
  SetDependencyDomainsOf(f, depdom);
  SetDependencyFunctionsOf(f, depfuncs);
  SetNrComponents(f, Length(compdoms));
  return f;
end);

#

InstallGlobalFunction(CreateCascade,
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

#

InstallGlobalFunction(IdentityCascade,
function(comps)
  return Cascade(comps,[]);
end);

#

InstallGlobalFunction(RandomCascade,
function(list, numofdeps)
  local isgroup, type, comps, depdoms, vals, len, x, j, k, val, depfuncs, i;

  if not IsDenseList(list) then
    Error("usage: <doms> should be a dense list of transformation semigroup\n",
    " or permutation groups,");
    return;
  else
    isgroup:=true;
    for x in list do
      if not IsPermGroup(x) then
        isgroup:=false;
        if not IsTransformationSemigroup(x) then
          Error("usage: <doms> should be a dense list of transformation",
          " semigroup or permutation groups,");
          return;
        fi;
      fi;
    od;
  fi;

  if isgroup then
    type:=PermCascadeType;
  else
    type:=TransCascadeType;
  fi;

  comps:=ComponentDomains(list);
  # create the enumerator for the dependency func
  depdoms:=DependencyDomains(comps);

  # create the function
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  len:=Sum(List(depdoms, Length));
  numofdeps:=Minimum([len, numofdeps]);

  x:=[1..len];
  for i in [1..numofdeps] do
    j:=Random(x);
    RemoveSet(x, j);
    k:=1;
    while j>Length(depdoms[k]) do
      j:=j-Length(depdoms[k]);
      k:=k+1;
    od;
    val:=Random(list[k]);
    if not IsOne(val) then
      vals[k][j]:=val;
    fi;
  od;
  depfuncs := List([1..Length(vals)],
                   x -> DependencyFunction(depdoms[x],vals[x]));

  return CreateCascade(EnumeratorOfCartesianProduct(comps),
                 comps, depfuncs, depdoms, type);
end);

################################################################################
# PERMUTATION CASCADE ##########################################################
################################################################################

InstallMethod(OneImmutable, "for a trans cascade",
[IsTransCascade],
function(ct)
  return IdentityCascade(ComponentDomains(ct));
end);

InstallMethod(OneImmutable, "for a permutation cascade",
[IsPermCascade],
function(ct)
  local id;
  id := IdentityCascade(ComponentDomains(ct));
  #TODO this is just repackaging the Cascade id to PermCascade;
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
  depdoms:=DependencyDomainsOf(pc); #TODO get rid of this
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
        knowcomps, comps, domsizes;
  #deciding what input we got###################################################
  if IsListOfPermGroupsAndTransformationSemigroups(compsordomsizes) then
    comps := compsordomsizes;
    domsizes := List(ComponentDomains(comps), c -> Size(c));
    knowcomps := true;
  else
    domsizes := compsordomsizes;
    knowcomps := false;
  fi;
  #sanity check on the domain sizes
  if not ForAll(domsizes, IsPosInt)
     or DegreeOfTransformation(f)>Product(domsizes) then
    Print("#W number of points bigger than the number of coordinate values\n");
    return fail;
  fi;
  #the actual algorithm#########################################################
  depdoms:=DependencyDomains(domsizes);
  compdoms := List(domsizes,x -> [1..x]);
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
      #while not IsBound(vals[level][pos][coords[level]]) do
      Remove(args, level);
      #the position in dependency domain on the level
      pos:=Position(depdoms[level], args);
      if IsBound(vals[level][pos][coords[level]])
         and vals[level][pos][coords[level]] <>  new[level] then
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
        if knowcomps and IsPermGroup(comps[i]) then
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
  #TODO detecting the input twice looks pretty bad
  #deciding what input we got
  if IsListOfPermGroupsAndTransformationSemigroups(compsordomsizes) then
    domsizes := List(ComponentDomains(compsordomsizes), c -> Size(c));
  else
    domsizes := compsordomsizes;
  fi;
  AsCascade(AsTransformation(p), Product(domsizes), compsordomsizes);
end);

# action and operators

InstallGlobalFunction(OnCoordinates,
function(coords, ct)
  local dfs, copy, out, len, i;

  dfs:=DependencyFunctionsOf(ct);
  len:=Length(coords);
  copy:=EmptyPlist(len);
  out:=EmptyPlist(len);

  for i in [1..len] do
    out[i]:=coords[i]^(copy^dfs[i]);
    copy[i]:=coords[i];
  od;
  return out;
end);

# registering the above action as a method for ^
InstallOtherMethod(\^, "for coordinate list and cascade",
[IsList, IsCascade], OnCoordinates);

InstallGlobalFunction(OnCascade,
function(f,g)
  local dep_f, dep_g, depdoms, vals, x, i, j, depfuncs,type;

  dep_f:=DependencyFunctionsOf(f);
  dep_g:=DependencyFunctionsOf(g);
  depdoms:=DependencyDomainsOf(f); #TODO get rid of this
  #empty values lookup table based on the sizes of depdoms
  vals:=List(depdoms, x-> EmptyPlist(Length(x)));
  #going through all depdoms
  for i in [1..Length(depdoms)] do
    for j in [1..Length(depdoms[i])] do
      x:= OnDepArg(depdoms[i][j],dep_f[i])
          * OnDepArg(OnCoordinates(depdoms[i][j],f),dep_g[i]);
      if not IsOne(x) then
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

# registering the above action as a method for *
InstallMethod(\*, "for cascades", [IsCascade, IsCascade], OnCascade);

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

# returning the dependencies back in a list
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
  recdraw := function(coordprefix, nodename,inscope)
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
              SimplerCompactNotation(val),"\"];\n"));
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
