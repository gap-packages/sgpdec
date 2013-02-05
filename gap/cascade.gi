#############################################################################
###
##W  cascadetrans.gi
##Y  Copyright (C) 2011-12
##   Attila Egri-Nagy, Chrystopher L. Nehaniv, and James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###


# misc

# either list of pos ints or list of actual domains

InstallGlobalFunction(CreatePrefixDomains,
function(coll)
  local prefix, tup, i;

  if ForAll(coll, IsPosInt) then 
    Apply(coll, x-> [1..x]);
  fi;

  prefix:=EmptyPlist(Length(coll)+1);
  prefix[1]:=[[]];

  tup:=[];

  for i in [1..Length(coll)-1] do
    Add(tup, coll[i]);
    Add(prefix, EnumeratorOfCartesianProduct(tup));
  od; 
  return prefix;
end);

# dependency functions

InstallGlobalFunction(CreateDependencyFunction, 
function(func, enum)
  local record;

  record:=rec(func:=func, enum:=enum);
  return Objectify(NewType(CollectionsFamily(FamilyObj(func[2])),
   IsDependencyFunc), record);
end);

#

InstallMethod(ViewObj, "for a dependency func",
[IsDependencyFunc],
function(x)
  Print("<dependency function>");
  return;
end);

#

InstallOtherMethod(\^, "for a tuple and dependency func",
[IsList, IsDependencyFunc],
function(tup, depfunc)
  local func, enum, i, pos;
  
  func:=depfunc!.func;
  enum:=depfunc!.enum;

  i:=Length(tup)+1;
  
  if not IsBound(enum[i]) then 
    return fail;
  fi;
  
  pos:=Position(enum[i], tup);
  
  if pos=fail then 
    return fail;
  fi;

  if not IsBound(func[i][pos]) then 
    return ();
  fi;
  return func[i][pos];
end);

# creating cascades

InstallGlobalFunction(CascadeNC,
function(coll, depfunc)
  local prefix, tup, func, f, i, x;
 
  if IsListOfPermGroupsAndTransformationSemigroups(coll) then 
    coll:=ComponentDomainsOfCascadeSemigroup(coll);
  fi;

  prefix:=CreatePrefixDomains(coll);
  func:=List(prefix, x-> EmptyPlist(Length(x)));

  for x in depfunc do
    func[Length(x[1])+1][Position(prefix[Length(x[1])+1], x[1])]:=x[2];
  od;
  ShrinkAllocationPlist(func);

  return CreateCascade(EnumeratorOfCartesianProduct(coll), coll,
   prefix, func);
end);

# either: 
# 1) cascade trans and func; or
# 2) domain, component domains, prefix domain, func

InstallGlobalFunction(CreateCascade, 
function(arg)
  local f;

  if Length(arg)=2 then # cascade trans and func
    return CreateCascade(DomainOfCascade(arg[1]), 
     ComponentDomainsOfCascade(arg[1]),   
     PrefixDomainOfCascade(arg[1]), arg[2]);
  fi;
    
  f:=Objectify(CascadeType, rec());
  SetDomainOfCascade(f, arg[1]);
  SetComponentDomainsOfCascade(f, arg[2]);
  SetPrefixDomainOfCascade(f, arg[3]);
  SetDependencyFunction(f, CreateDependencyFunction(arg[4], arg[3]));
  SetNrComponentsOfCascade(f, Length(arg[2]));
  return f;
end);

#

InstallGlobalFunction(RandomCascade,
function(list, numofdeps)
  local coll, enum, tup, func, len, x, j, k, val, i;

  if not IsListOfPermGroupsAndTransformationSemigroups(list) then 
    Error("the first argument should be a list of transformation semigroups",
     " or perm groups,");
    return;
  fi;

  coll:=ComponentDomainsOfCascadeSemigroup(list); 
  
  # create the enumerator for the dependency func
  enum:=EmptyPlist(Length(coll)+1);
  enum[1]:=[[]];
  
  tup:=[];
  
  for i in [1..Length(coll)-1] do 
    Add(tup, coll[i]);
    Add(enum, EnumeratorOfCartesianProduct(tup));
  od;

  # create the function
  func:=List(enum, x-> EmptyPlist(Length(x)));
  len:=Sum(List(enum, Length));
  numofdeps:=Minimum([len, numofdeps]);

  x:=[1..len];
  for i in [1..numofdeps] do 
    j:=Random(x);
    RemoveSet(x, j);
    k:=1;
    while j>Length(enum[k]) do 
      j:=j-Length(enum[k]);
      k:=k+1;
    od;
    val:=Random(list[k]);
    if not IsOne(val) then 
      if not IsTransformation(val) then 
        val:=AsTransformation(val);
      fi;
      func[k][j]:=val;
    fi;
  od;
 
  return CreateCascade(EnumeratorOfCartesianProduct(coll), 
   coll, enum, func);
end);

#JDM install Cascade, check args are sensible.

# changing representation

InstallMethod(AsTransformation, "for cascade",
[IsCascade],
function(ct)
return TransformationOp(ct, DomainOfCascade(ct), OnCoordinates);
end);

#

InstallMethod(AsCascade, "for a transformation and list of domain sizes",
[IsTransformation, IsCyclotomicCollection],
function(f, coll)
  local prefix, dom, n, func, one, x, m, pos, i, j;
  
  if not ForAll(coll, IsPosInt) or DegreeOfTransformation(f)<>Product(coll)
   then 
    return fail;
  fi;

  prefix:=CreatePrefixDomains(coll);
  dom:=EnumeratorOfCartesianProduct(coll);
  n:=Length(coll);
  func:=List(prefix, x-> List([1..Length(x)], x-> []));
  one:=List(prefix, x-> BlistList([1..Length(x)], [1..Length(x)]));
   
  for i in [1..DegreeOfTransformation(f)] do
    x:=ShallowCopy(dom[i]);
    m:=n;
    Remove(x, m);
    pos:=Position(prefix[m], x);
    repeat
      func[m][pos][dom[i][m]]:=dom[i^f][m];
      if dom[i][m]<>func[m][pos][dom[i][m]] then
        one[m][pos]:=false;
      fi;
      m:=m-1;
      if m=0 then
        break;
      fi;
      Remove(x, m);
      pos:=Position(prefix[m], x);
    until IsBound(func[m][pos][dom[i][m]]);
    if m<>0 and func[m][pos][dom[i][m]]<>dom[i^f][m] then 
      return fail;
    fi;
  od;
 
  #post process
  for i in [1..Length(func)] do
    for j in [1..Length(func[i])] do
      if one[i][j] then
        Unbind(func[i][j]);
      else
        func[i][j]:=TransformationNC(func[i][j]);
      fi;
    od;
  od;

  return CreateCascade(dom, coll, prefix, func);
end);

# printing

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
    for x in ComponentDomainsOfCascade(f) do
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

#

InstallMethod(PrintObj, "for a cascade",
[IsCascade], ViewObj);

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

#

InstallMethod(\*, "for cascades", IsIdenticalObj,
[IsCascade, IsCascade],
function(f,g)
  local dep_f, dep_g, prefix, func, x, i, j;
  
  dep_f:=DependencyFunction(f);
  dep_g:=DependencyFunction(g);
  prefix:=PrefixDomainOfCascade(f);

  func:=List(prefix, x-> EmptyPlist(Length(x)));

  for i in [1..Length(prefix)] do 
    for j in [1..Length(prefix[i])] do 
      x:=prefix[i][j]^dep_f*OnCoordinates(prefix[i][j], f)^dep_g;
      if not IsOne(x) then 
        func[i][j]:=x;
      fi;
    od;
  od;
  return CreateCascade(f, func);      
end);

#

InstallMethod(\=, "for cascade and cascade", IsIdenticalObj,
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunction(p)!.func = DependencyFunction(q)!.func;
end);

#

InstallOtherMethod(\<, "for cascade op and cascade op",
[IsCascade, IsCascade],
function(p,q)
  return DependencyFunction(p)!.func < DependencyFunction(q)!.func;
end);

# attributes

InstallMethod(NrDependenciesOfCascade, "for a cascade",
[IsCascade],
function(f)

  return Sum(List(DependencyFunction(f)!.func, 
   x-> Number([1..Length(x)], i-> IsBound(x[i]))));
end);

#old

# MonomialGenerators require the orbits of singletons under semigroup action
SingletonOrbits := function(T)
local i, sets,o;
    sets := [];
    for i in [1..DegreeOfTransformationSemigroup(T)] do
      o := Orb(T,i, OnPoints);
      Enumerate(o);
      AddSet(sets,AsSortedList(o));
    od;
    return sets;
end;


MakeReadOnlyGlobal("SingletonOrbits");

#constructing monomial generators for the wreath product
#on each level for each path of a component orbit representative we
#put the component generators
InstallGlobalFunction(MonomialWreathProductGenerators,
function(comps)
local mongens, depth, compgen, gens, prefixes,prefix, newprefix, newprefixes,
      orbitreprs, orbits, orbit, orbrep;
  prefixes := [ [] ]; #the top level
  mongens := [];

  for depth in [1..Length(comps)] do
    #getting the component generators
    gens := GeneratorsOfSemigroup(comps[depth]);
  #adding dependencies to coordinate fragments (prefixes) on current level
    for prefix in prefixes do
      Perform(gens,
        function(g)
          Add(mongens,
              CascadeNC(
                      ComponentDomainsOfCascadeSemigroup	(comps),
                      [[prefix,g]]));
        end);
    od;
    od;
#getting the orbit reprs on level
    orbitreprs := [];
    if IsGroup(comps[depth]) then
      Perform(Orbits(comps[depth]),
              function(o) Add(orbitreprs,o[1]);end
                );
    else
      Perform(SingletonOrbits(comps[depth]),
              function(o) Append(orbitreprs,o);end
                );
    fi;

    #extending all prefixes with the orbitreprs on level
    newprefixes := [];
    for prefix in prefixes do
      for orbrep in orbitreprs do
        #the extension
        newprefix := ShallowCopy(prefix);
        Add(newprefix, orbrep);
        Add(newprefixes, newprefix);
 prefixes := newprefixes;
    od;
  od;
  return mongens;
end);

#JDM revise this...

InstallGlobalFunction(DotCascade,
function(ct)
  local csh, str, out, vertices, vertexlabels, edges, deps, coordsname,
        level, newnn, edge, i, dep, coord;

  #csh := CascadeShellOf(ct);
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph ct{\n");
  #putting an extra node on the top as the title of the graph
  #AppendTo(out,"orig [label=\"", params.title ,"\",color=\"white\"];\n");
  #AppendTo(out,"orig -> n [style=\"invis\"];\n");

  vertices := [];
  vertexlabels := rec();#HTCreate("a string");
  edges := [];
  #extracting dependencies
  deps := DependencyMapsFromCascade(ct);
  coordsname := "n";
  Add(vertices, coordsname);
  #adding a default label
  vertexlabels.(coordsname) := " [width=0.2,height=0.2,label=\"\"]";
  #just to be on the safe side
  Sort(vertices); Sort(edges);
  for dep in deps do
    #coordsnames are created like n_#1_#2_...._#n
    coordsname := "n";
    level := 1;
    for coord in dep[1] do
      newnn := Concatenation(coordsname,"_",String(coord));
      edge := Concatenation(coordsname ," -> ", newnn," [label=\"",
                      String(csh!.coordval_converters[level](coord)),
                      "\"]");
      if not (edge in edges) then
        # we just add the full edge
        Add(edges,edge, PositionSorted(edges,edge));
      fi;
      #we can now forget about the
      coordsname := newnn;
      level := level + 1;
      if not (coordsname in vertices) then
        i := PositionSorted(vertices, coordsname);
        Add(vertices, coordsname, i);
        #adding a default label
        vertexlabels.(coordsname) := " [width=0.2,height=0.2,label=\"\"]";
      fi;
    od;

    #putting the proper label there as we are at the end of the coordinates
    vertexlabels.(coordsname) := Concatenation(" [label=\"",
            String(csh!.coordtrans_converters[level](dep[2])),"\"]");
  od;
  # finally writing them into the dot file
  for i in [1..Size(vertices)] do
    AppendTo(out, vertices[i]," ",vertexlabels.(vertices[i]),";\n");
  od;
  for edge in edges do
    AppendTo(out, edge,";\n");
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);

#EOF

InstallMethod(Display, "for a cascade",
[IsCascade],
function(c)
  local df, func, enum, str, x, i,j;
  df := DependencyFunction(c);
  func := df!.func;
  enum := df!.enum;
  #str:="";
  for i in [1..NrComponentsOfCascade(c)] do
    for j in [1..Size(func[i])] do
      if IsBound(func[i][j]) then
        Print(String(enum[i][j])," -> ");
        #TODO String(func[i][j]) return <object>
        Display(func[i][j]);
      fi;
    od;
  od;
  return;
end);
