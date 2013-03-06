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
InstallGlobalFunction(CascadeNC,
function(doms, deps)
  #if components are given as semigroups then we have to get the domains
  if IsListOfPermGroupsAndTransformationSemigroups(doms) then
    doms:=ComponentDomains(doms);
  fi;

  return CreateCascade(
                 EnumeratorOfCartesianProduct(doms),
                 doms,
                 DependencyFunction(doms, deps));
end);

# either:
# 1) cascade  and depfuncs; or
# 2) domain, component domains, depfuncs
InstallGlobalFunction(CreateCascade,
function(arg)
  local f;
  # cascade and depfunc
  if Length(arg)=2 then
    return CreateCascade(
                   DomainOf(arg[1]),
                   ComponentDomains(arg[1]),
                   arg[2]);
  fi;
  f:=Objectify(CascadeType, rec());
  SetDomainOf(f, arg[1]);
  SetComponentDomains(f, arg[2]);
  SetDependencyDomainsOf(f, arg[3]!.prefixes);#ugly hack TODO
  SetDependencyFunctionsOf(f, CreateDependencyFunction(arg[3]));
  SetNrComponentsOfCascade(f, Length(arg[2]));
  return f;
end);

InstallGlobalFunction(IdentityCascade,
function(comps) return CascadeNC(comps,[]); end);

InstallGlobalFunction(RandomCascade,
function(list, numofdeps)
  local comps, prefixes, tup, vals, len, x, j, k, val, i;

  if not IsListOfPermGroupsAndTransformationSemigroups(list) then
    Error("the first argument should be a list of transformation semigroups",
     " or perm groups,");
    return;
  fi;
  comps:=ComponentDomains(list);
  # create the enumerator for the dependency func
  prefixes:=EmptyPlist(Length(comps)+1);
  prefixes[1]:=[[]];

  tup:=[];

  for i in [1..Length(comps)-1] do
    Add(tup, comps[i]);
    Add(prefixes, EnumeratorOfCartesianProduct(tup));
  od;

  # create the function
  vals:=List(prefixes, x-> EmptyPlist(Length(x)));
  len:=Sum(List(prefixes, Length));
  numofdeps:=Minimum([len, numofdeps]);

  x:=[1..len];
  for i in [1..numofdeps] do
    j:=Random(x);
    RemoveSet(x, j);
    k:=1;
    while j>Length(prefixes[k]) do
      j:=j-Length(prefixes[k]);
      k:=k+1;
    od;
    val:=Random(list[k]);
    if not IsOne(val) then
      if not IsTransformation(val) then
        val:=AsTransformation(val);
      fi;
      vals[k][j]:=val;
    fi;
  od;

  return CreateCascade(EnumeratorOfCartesianProduct(comps),
   comps, prefixes, vals);
end);

#JDM install Cascade, check args are sensible.

# changing representation

InstallMethod(AsTransformation, "for cascade",
[IsCascade],
function(ct)
return TransformationOp(ct, DomainOf(ct), OnCoordinates);
end);

#

InstallMethod(AsCascade, "for a transformation and list of domain sizes",
[IsTransformation, IsCyclotomicCollection],
function(f, comps)
  local prefix, dom, n, vals, one, x, m, pos, i, j;

  if not ForAll(comps, IsPosInt) or DegreeOfTransformation(f)<>Product(comps)
   then
    return fail;
  fi;

  prefix:=DependencyDomains(comps);
  dom:=EnumeratorOfCartesianProduct(comps);
  n:=Length(comps);
  vals:=List(prefix, x-> List([1..Length(x)], x-> []));
  one:=List(prefix, x-> BlistList([1..Length(x)], [1..Length(x)]));
  for i in [1..DegreeOfTransformation(f)] do
    x:=ShallowCopy(dom[i]);
    m:=n;
    Remove(x, m);
    pos:=Position(prefix[m], x);
    repeat
      vals[m][pos][dom[i][m]]:=dom[i^f][m];
      if dom[i][m]<>vals[m][pos][dom[i][m]] then
        one[m][pos]:=false;
      fi;
      m:=m-1;
      if m=0 then
        break;
      fi;
      Remove(x, m);
      pos:=Position(prefix[m], x);
    until IsBound(vals[m][pos][dom[i][m]]);
    if m<>0 and vals[m][pos][dom[i][m]]<>dom[i^f][m] then
      return fail;
    fi;
  od;
  #post process
  for i in [1..Length(vals)] do
    for j in [1..Length(vals[i])] do
      if one[i][j] then
        Unbind(vals[i][j]);
      else
        vals[i][j]:=TransformationNC(vals[i][j]);
      fi;
    od;
  od;

  return CreateCascade(dom, comps, prefix, vals);
end);

# action and operators

InstallGlobalFunction(OnCoordinates,
function(coords, ct)
  local dep, copy, out, len, i;

  dep:=DependencyFunction(ct);
  len:=Length(coords);
  copy:=EmptyPlist(len);
  out:=EmptyPlist(len);

  for i in [1..len] do
    out[i]:=coords[i]^(copy^dep);
    copy[i]:=coords[i];
  od;
  return out;
end);

InstallMethod(\*, "for cascades", IsIdenticalObj,
[IsCascade, IsCascade],
function(f,g)
  local dep_f, dep_g, prefix, vals, x, i, j;

  dep_f:=DependencyFunction(f);
  dep_g:=DependencyFunction(g);
  prefix:=DependencyDomainsOf(f);
  #empty values lookup table based on the sizes of prefixes
  vals:=List(prefix, x-> EmptyPlist(Length(x)));
  #going through all prefixes
  for i in [1..Length(prefix)] do
    for j in [1..Length(prefix[i])] do
      x:= prefix[i][j]^dep_f * OnCoordinates(prefix[i][j],f)^dep_g;
      if not IsOne(x) then
        vals[i][j]:=x;
      fi;
    od;
  od;
  return CreateCascade(f, vals);
end);

InstallMethod(\=, "for cascade and cascade", IsIdenticalObj,
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunction(p)!.vals = DependencyFunction(q)!.vals;
end);

InstallOtherMethod(\<, "for cascade op and cascade op",
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunction(p)!.vals < DependencyFunction(q)!.vals;
end);

# attributes
# the number of nontrivial dependency function values
InstallMethod(NrDependenciesOfCascade, "for a cascade",
[IsCascade],
function(f)
  return Sum(List(DependencyFunction(f)!.vals,
   x-> Number([1..Length(x)], i-> IsBound(x[i]))));
end);

# returning the dependencies back in a list
# not for time critical code, but DotCascade can be made representation agnostic
InstallGlobalFunction(DependenciesOfCascade,
function(ct)
  local deps,i,j,df,vals,prefixes;
  df := DependencyFunction(ct);
  vals := df!.vals;
  prefixes := df!.prefixes;
  deps := [];
  for i in [1..Size(vals)] do
    for j in [1..Size(vals[i])] do
      if IsBound(vals[i][j]) then
        Add(deps, [prefixes[i][j], vals[i][j]]);
      fi;
    od;
  od;
  return deps;
end);

################################################################################
# printing #####################################################################
################################################################################
InstallMethod(ViewObj, "for a cascade",
[IsCascade],
function(f)
  local str, x;

  str:="<cascade with ";
  Append(str, String(NrComponentsOfCascade(f)));
  Append(str, " levels");

  if Length(str)<SizeScreen()[1]-(NrComponentsOfCascade(f)*3)-12
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
[IsCascade], ViewObj);

InstallMethod(Display, "for a cascade",
[IsCascade],
function(c)
  local df, vals, prefixes, i,j;
  df := DependencyFunction(c);
  vals := df!.vals;
  prefixes := df!.prefixes;
  for i in [1..NrComponentsOfCascade(c)] do
    for j in [1..Size(vals[i])] do
      if IsBound(vals[i][j]) then
        Print(String(prefixes[i][j])," -> ");
        #TODO String(vals[i][j]) return <object>
        Display(vals[i][j]);
      fi;
    od;
  od;
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
        livevlabelprefix,livelabelprefix, edgeDB;
  #-----------------------------------------------------------------------------
  # printing the graph data to the stream
  DotPrintGraph := function(outstream, vs, vlabels,es)
    local i;
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
    " [shape=box,color=grey,width=0.1,height=0.1,fontsize=11,label=\"\"]";
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
    level := 0;
    coordsname := "n";
    repeat
      AddSet(vertices, coordsname);
      level := level + 1;
      #adding a default label
      vertexlabels.(coordsname):= Concatenation(livelabelprefix,"\"]");
      #if there is an edge still, then draw it
      if level <= Size(dep[1]) then
        coord := dep[1][level];
        newcoordsname := Concatenation(coordsname,"_",String(coord));
        edge := Concatenation(coordsname ," -> ", newcoordsname,livelabelprefix,
                        String(coord),
                        "\",fontcolor=black]");
        AddSet(edgeDB, [coordsname,newcoordsname]);
        AddSet(edges, edge);
        #we can now forget about the
        coordsname := newcoordsname;
      fi;
    until level > Size(dep[1]);
    #coordsnames are created like n_#1_#2_...._#n
    #putting the proper label there as we are at the end of the coordinates
    vertexlabels.(coordsname) := Concatenation(livelabelprefix,
                                         String(dep[2]),"\"]");
  od;
  #now putting the gray edges for the remaining vertices
  dom := DomainOf(ct);
  for dep in dom do
    level := 0;
    coordsname := "n";
    repeat
      AddSet(vertices, coordsname);
      level := level + 1;
      if level <= Size(dep) then
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
