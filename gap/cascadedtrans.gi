#############################################################################
###
##W  cascadedtrans.gi
##Y  Copyright (C) 2011-12
##   Attila Egri-Nagy, Chrystopher L. Nehaniv, and James D. Mitchell
###
###  Licensing information can be found in the README file of this package.
###
##############################################################################
###

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

# Cascaded permutations and transformations.

InstallGlobalFunction(CascadedTransformationNC,
function(coll, depfunc)
  local enum, tup, func, f, i, x;
 
  if IsListOfPermGroupsAndTransformationSemigroups(coll) then 
    coll:=DomainsOfCascadeProductComponents(coll);
  fi;

  enum:=EmptyPlist(Length(coll)+1);
  enum[1]:=[[]];
  
  tup:=[];
  
  for i in [1..Length(coll)-1] do 
    Add(tup, coll[i]);
    Add(enum, EnumeratorOfCartesianProduct(tup));
  od;

  func:=List(enum, x-> EmptyPlist(Length(x)));

  for x in depfunc do
    func[Length(x[1])+1][Position(enum[Length(x[1])+1], x[1])]:=x[2];
  od;
  ShrinkAllocationPlist(func);

  return CreateCascadedTransformation(EnumeratorOfCartesianProduct(coll), coll,
  enum, func);
end);

# either: 
# 1) cascaded trans and func; or
# 2) domain, component domains, prefix domain, func

InstallGlobalFunction(CreateCascadedTransformation, 
function(arg)
  local f;

  if Length(arg)=2 then # cascaded trans and func
    return CreateCascadedTransformation(DomainOfCascadedTransformation(arg[1]), 
     ComponentDomainsOfCascadedTransformation(arg[1]),   
     PrefixDomainOfCascadedTransformation(arg[1]), arg[2]);
  fi;
    
  f:=Objectify(CascadedTransformationType, rec());
  SetDomainOfCascadedTransformation(f, arg[1]);
  SetComponentDomainsOfCascadedTransformation(f, arg[2]);
  SetPrefixDomainOfCascadedTransformation(f, arg[3]);
  SetDependencyFunction(f, CreateDependencyFunction(arg[4], arg[3]));
  return f;
end);

#

InstallGlobalFunction(RandomCascadedTransformation,
function(list, numofdeps)
  local coll, enum, tup, func, len, x, j, k, f, i;

  if not IsListOfPermGroupsAndTransformationSemigroups(list) then 
    Error("insert meaningful error message,");
    return;
  fi;

  coll:=DomainsOfCascadeProductComponents(list); 
  
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
    func[k][j]:=Random(list[k]);
  od;
 
  return CreateCascadedTransformation(EnumeratorOfCartesianProduct(coll), 
   coll, enum, func);
end);

#JDM install CascadedTransformation, check args are sensible.

#

InstallMethod(ViewObj, "for a cascaded transformation",
[IsCascadedTransformation],
function(f)
  local prefix, midfix, suffix, x;

  prefix:="<cascaded transformation";
  midfix:=" on ";
  
  for x in ComponentDomainsOfCascadedTransformation(f) do 
    Append(midfix, String(x));
    Append(midfix, ", ");
  od;
  Remove(midfix, Length(midfix));
  Remove(midfix, Length(midfix));

  suffix:=">";

  Print(prefix);
  if Length(prefix)+Length(midfix)+Length(suffix)<=SizeScreen()[1] then
    Print(midfix);
  else 
    midfix:=" on ";

  fi;
  Print(suffix);
  return;
end);

#

InstallMethod(PrintObj, "for a cascaded transformation",
[IsCascadedTransformation], ViewObj);

#

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

InstallOtherMethod(AsTransformation,
"for cascaded transformation",
[IsCascadedTransformation],
function(ct)
return TransformationOp(ct, DomainOfCascadedTransformation(ct), OnCoordinates);
end);

#

InstallMethod(\*, "for cascaded transformations", IsIdenticalObj,
[IsCascadedTransformation, IsCascadedTransformation],
function(f,g)
  local dep_f, enum, func, fg, i, j;
  
  dep_f:=DependencyFunction(f);
  enum:=PrefixDomainOfCascadedTransformation(f);

  func:=List(enum, x-> EmptyPlist(Length(x)));

  for i in [1..Length(enum)] do 
    for j in [1..Length(enum[i])] do 
      func[i][j]:=enum[i][j]^dep_f*OnCoordinates(enum[i][j], g)^dep_f;
    od;
  od;
  return CreateCascadedTransformation(f, func);      
end);

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
              CascadedTransformationNC(
                      DomainsOfCascadeProductComponents(comps),
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
#

InstallMethod(IsomorphismTransformationSemigroup, "for a cascade product",
[IsCascadeProduct],
function(s)
  local t, inv;
  t:=Semigroup(List(GeneratorsOfSemigroup(s), AsTransformation));
  inv:=function(f)
    local prefix, dom, n, func, visited, one, i, x, m, pos, j;
    prefix:=PrefixDomainOfCascadeProduct(s);
    dom:=DomainOfCascadeProduct(s);
    n:=NrComponentsOfCascadeProduct(s);
    func:=List(prefix, x-> List([1..Length(x)], x-> []));
    visited:=List(prefix, x-> BlistList([1..Length(x)], []));
    one:=List(prefix, x-> BlistList([1..Length(x)], [1..Length(x)]));
    
    for i in [1..DegreeOfTransformation(f)] do 
      x:=ShallowCopy(dom[i]);
      m:=n;
      Remove(x, m);
      pos:=Position(prefix[m], x);
      
      while not visited[m][pos] do 
        func[m][pos][dom[i][m]]:=dom[i][m]^f;
        if func[m][pos][dom[i][m]]<>dom[i][m] then 
          one[m][pos]:=false;
        fi;
        visited[m][pos]:=true;
        m:=m-1;
        if m=0 then 
          break;
        fi;
        Remove(x, m);
        pos:=Position(prefix[m], x);
      od;
    od;
    
    #post process

    for i in [1..Length(func)] do 
      for j in [1..Length(func[i])] do 
        if one[i][j] then 
          Unbind(func[i][j]);
        elif IsPermGroup(ComponentsOfCascadeProduct(s)[i]) then 
          func[i][j]:=PermList(func[i][j]);
        else
          func[i][j]:=TransformationNC(func[i][j]);
        fi;
      od;
    od;

    return CreateCascadedTransformation(f, func);
  end;

  return MagmaIsomorphismByFunctionsNC(s, t, AsTransformation, inv);
end);

# old
# YEP THIS IS THE MARKER BETWEEN NEW AND OLD

################################################################################
####REIMPLEMENTED OPERATIONS####################################################
# equality the worst case is when p and q are indeed equal, as every value is
# checked
InstallOtherMethod(\=, "for cascaded op and cascaded op", IsIdenticalObj,
[IsCascadedTransformation, IsCascadedTransformation],
function(p,q)
  return "TODO!";
end);

# comparison, less than, just a trick flattening and do the comparison there
InstallOtherMethod(\<, "for cascaded op and cascaded op",
[IsCascadedTransformation, IsCascadedTransformation],
function(p,q)
  return AsTransformation(p) < AsTransformation(q);
  #TODO!!! this can be faster by not doing it full!!!
end);

################################################################################
##########DEPENDENCIES##########################################################

# checks whether the target level depends on onlevel in ct.  simply follows
# the definition and varies one level
InstallGlobalFunction(DependsOn,
function(ct, targetlevel, onlevel)
  local csh, args, value, arg, coord;

  #getting the cascade shell of the operation
  csh := CascadeShellOf(ct);
  #all possible arguments up to targetlevel-1
  args:=EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(targetlevel-1)]});
  #so we test for all arguments
  #TODO some optimization may be possible here, not to check any twice
  for arg in args do
    #remember the value
    value := ct!.depfunc(arg);
    #now do the variations
    for coord in CoordValSets(csh)[onlevel] do
      arg[onlevel] := coord;
      #if there is a change then we are done!
      if value <>  ct!.depfunc(arg) then
        return true;
      fi;
    od;
  od;
  return false;
end);

# it creates the graph of actual dependencies for a cascaded operation
InstallGlobalFunction(DependencyGraph,
function(ct)
  local graph, i, j;

  graph := [];
  # checking all directed pairs systematically
  for i in [2..Length(CascadeShellOf(ct))] do
    for j in [1..i-1] do
      if DependsOn(ct,i,j) then
        Add(graph,[i,j]);
      fi;
    od;
  od;
  return AsSortedList(graph);
end);

# returns a list of levels where the given cascaded operation has non-trivial
# action(s).
InstallGlobalFunction(ProjectedScope,
function(ct)
local pscope,level,prefix,csh;

  #getting the info object
  csh := CascadeShellOf(ct);

  #we suppose there is no action
  pscope := FiniteSet([],Length(csh));

  for level in [1..Length(csh)] do
    for prefix in
     EnumeratorOfCartesianProduct(CoordValSets(csh){[1..(level-1)]} ) do
      #if it is not the identity of the component
      if One(csh[level]) <> (ct!.depfunc(prefix)) then
        #then we have at least one here
        Add(pscope,level);
        #so we can leave the loop
        break; #JDM is this right? This only breaks out of the inner loop not
        # the outer loop and so this doesn't result in a value being returned
      fi;
    od;
  od;
  return pscope;
end);

################################################################################
########### DRAWING ############################################################
InstallGlobalFunction(DotCascadedTransformation,
function(ct)
  local csh, str, out, vertices, vertexlabels, edges, deps, coordsname,
        level, newnn, edge, i, dep, coord;

  csh := CascadeShellOf(ct);
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
  deps := DependencyMapsFromCascadedTransformation(ct);
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
