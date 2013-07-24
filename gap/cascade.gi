#############################################################################
###
##W  cascade.gi
##Y  Copyright (C) 2011-12
#   Attila Egri-Nagy, Chrystopher L. Nehaniv, and James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################

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
     or DegreeOfTransformation(f)<>Product(domsizes) then
    Print("#W number of points not equal to number of coordinate values\n");
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

InstallMethod(\*, "for cascades",
[IsCascade, IsCascade],
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
InstallMethod(NrDependenciesOfCascade, "for a cascade",
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
   Length(String(NrDependenciesOfCascade(f)))-8 then
    Append(str, ", ");
    Append(str, String(NrDependenciesOfCascade(f)));
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
# drawing #####################################################################
################################################################################
InstallGlobalFunction(DotCascade,
function(ct)
  local str, out,
        vertices, vertexlabels,
        edges,
        dom,
        deps, coordsname,
        level, newcoordsname, edge, i, dep, coord, DotPrintGraph,
        emptyvlabel,greyedgelabelprefix,
        livevlabelprefix,livelabelprefix, edgeDB,arg, val;
  #-----------------------------------------------------------------------------
  # printing the graph data to the stream
  DotPrintGraph := function(outstream, vs, vlabels,es)
    local i;
    #Print(vlabels);
    for i in [1..Size(vs)] do
      if IsBound(vlabels.(vs[i])) then
        AppendTo(outstream, vs[i]," ",vlabels.(vs[i]),";\n");
      else
        AppendTo(outstream, vs[i],"\n");
      fi;
    od;
    for i in [1..Size(es)] do
      AppendTo(outstream, es[i],";\n");
    od;
  end;
  #-----------------------------------------------------------------------------
  str := "";
  edgeDB := []; # to keep track of the already drawn black edges
  #no label vertex
  emptyvlabel :=
    " [color=grey,width=0.1,height=0.1,fontsize=11,label=\"\"]";
  greyedgelabelprefix := " [color=grey,label=\"";
  livelabelprefix := " [color=black,label=\"";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph ct{\n");
  PrintTo(out," node", emptyvlabel, ";\n");
  PrintTo(out," edge ", "[color=grey,fontsize=11,fontcolor=grey]", ";\n");
  vertices := []; #as strings
  vertexlabels := rec();#using the record as a lookup table
  edges := []; #as strings
  #first we draw the intereseting paths, the ones that are in a nontrivial dep
  deps := DependenciesOfCascade(ct);
  for dep in deps do
    arg := dep[1];
    val := dep[2];
    coordsname := "n";
    AddSet(vertices, coordsname);
    for level in [1..Size(arg)] do
      coord := arg[level];
      newcoordsname := Concatenation(coordsname,"_",String(coord));
      edge := Concatenation(coordsname ," -> ", newcoordsname,livelabelprefix,
                      String(coord),
                      "\",fontcolor=black]");
      AddSet(edgeDB, [coordsname,newcoordsname]);
      AddSet(edges, edge);
      #we can now forget about the
      coordsname := newcoordsname;
      AddSet(vertices, coordsname);
    od;
    #coordsnames are created like n_#1_#2_...._#n
    #putting the proper label there as we are at the end of the coordinates
    vertexlabels.(coordsname):=Concatenation(livelabelprefix,
                                       CompactNotation(val),"\"]");
  od;
  #now putting the gray edges for the remaining vertices
  dom := DomainOf(ct);
  for dep in dom do
    level := 0;
    coordsname := "n";
    repeat
      AddSet(vertices, coordsname);
      level := level + 1;
      if level < Size(dep) then
        coord := dep[level];
        newcoordsname := Concatenation(coordsname,"_",String(coord));
        if not ([coordsname, newcoordsname] in edgeDB) then
          edge := Concatenation(coordsname ," -> ", newcoordsname,
                          greyedgelabelprefix,
                          String(coord),
                          "\"]");
          AddSet(edges, edge);
        fi;
        coordsname := newcoordsname;
      fi;
    until level > Size(dep);
  od;
  #finally printing the graph data
  DotPrintGraph(out, vertices, vertexlabels, edges);
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
