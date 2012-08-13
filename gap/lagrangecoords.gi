#############################################################################
##
## lagrangecoords.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## 2008-2012
##
## Lagrange coordinatization of groups.
##

##################################################################
# Simplified call for generating cascaded components for a group,
# when a default Chief series is enough.
InstallOtherMethod(LagrangeDecomposition,[IsPermGroup],
function(G)
  return LagrangeDecomposition(G,ChiefSeries(G));
end);

##################################################################
# Creates the record containing the info for the lagrange decomposition of
# permutation groups: series, transversals, components, coset representatives,
# mapping from points to coset reprs and backwards.
InstallMethod(LagrangeDecomposition, "for a group and a subnormal series",
[IsPermGroup, IsList],
function(G, subgroupchain)
  local series, t, transversals, comps, compgens, csh,
   stabrt, stabrtreps, result, i, gen;

  #############sanity check##################################
  if G <> subgroupchain[1] then
    Error("Supplied chain and the original group is not compatible!");
  fi;

  ###############SERIES########################################
  series := ShallowCopy(subgroupchain); #to make it mutable

  Info(LagrangeDecompositionInfoClass, 2, "LAGRANGEDECOMPOSITION ");
  t := Runtime();
  if SgpDecOptionsRec.SMALLER_GENERATOR_SET then
    #reducing the numbers of generators if possible
    series := List(series, G->Group(SmallGeneratingSet(G)));
    Info(LagrangeDecompositionInfoClass, 2,
    "Reducing the number of generators in the series ",
    FormattedTimeString(Runtime()-t)); t := Runtime();
  fi;

  #############TRANSVERSALS & COMPONENTS##############################
  transversals := [];
  comps := [];
  for i in [1..Length(series)-1] do
    #first the transversals
    transversals[i] := RightTransversal(series[i],series[i+1]);

    # then the generators of the component by the canonical action on the
    # transversals
    compgens := [];
    for gen in GeneratorsOfGroup(series[i]) do
      Add(compgens, PermList(ActionOn(transversals[i],gen,\*)));
    od;
    Add(comps,Group(AsSet(compgens)));
  od;
  Info(LagrangeDecompositionInfoClass, 2,
   "Calculating transversals and components ",
   FormattedTimeString(Runtime()-t)); t := Runtime();

  if SgpDecOptionsRec.SMALLER_GENERATOR_SET then
    #reducing the numbers of generators if possible
    comps := List(comps, G->Group(SmallGeneratingSet(G)));
    Info(LagrangeDecompositionInfoClass, 2,
    "Reducing the number of generators in components ",
       FormattedTimeString(Runtime()-t)); t := Runtime();
  fi;

  Info(LagrangeDecompositionInfoClass, 2, "Calculating codec ",
   FormattedTimeString(Runtime()-t)); t := Runtime();

  csh := CascadeShell(comps);

  #############CONSTRUCTING THE CONTAINER RECORD#########################

  #when the group is small we can ask for these extra info
  if SgpDecOptionsRec.SMALL_GROUPS then
    Info(LagrangeDecompositionInfoClass, 2,
     "Small group identification started...\c");
    Perform(comps, StructureDescription);
    Perform(series, StructureDescription);
    Perform([G],StructureDescription);
    Info(LagrangeDecompositionInfoClass, 2, "DONE ",
    FormattedTimeString(Runtime()-t)); t := Runtime();
  fi;

  #calculating the cosetaction map (needed for raising a state)
  stabrt := RightTransversal(G,Stabilizer(G,1));
  stabrtreps := [];
  for i in [1..Length(stabrt)] do
    stabrtreps[1^stabrt[i]] := stabrt[i];
  od;
  Info(LagrangeDecompositionInfoClass, 2,
  "Coset reps for the original group action ",
   FormattedTimeString(Runtime()-t)); t := Runtime();

#the record containing the information about the components
  result := rec(
              original := G,
              series := series,
              components := comps,
              transversals := transversals,
              cascadeshell := csh,
              stabilizertransversalreps := stabrtreps,
              originalstateset := MovedPoints(G));
  return Objectify(LagrangeDecompositionType, result);
end);

#former _FudgeFactors, s - state (list), g - group element to be lifted,
InstallMethod(ComponentActions,
        "componentactions of an original permutation in Lagrange decomposition",
        true,
        [IsLagrangeDecomposition,IsPerm, IsList], 0,
function(decomp,g,s)
local fudges,i;

  #on the top level we have simply g
  fudges := [];
  Add(fudges,g);
  #then going down to deeper levels
  for i in [2..Length(s)] do
    Add(fudges,
        s[i-1] * #this is already a representative!
        fudges[i-1] *
        Inverse(Perm2CosetRepr(s[i-1] * fudges[i-1],
                TransversalsOf(decomp)[i-1])));
  od;
  #converting to canonical
  for i in [1..Length(fudges)] do
    fudges[i] := PermList(ActionOn(TransversalsOf(decomp)[i],
                         fudges[i],\*));
  od;
  return fudges;
end);

# getting the representative of an element
InstallGlobalFunction(Perm2CosetRepr,
function(g,transversal)
  return transversal[PositionCanonical(transversal,g)];
end);

#coding to the cascaded format
InstallGlobalFunction(EncodeCosetReprs,
function(decomp,list) local i,l; l := [];
  for i in [1..Size(list)] do
    Add(l, PositionCanonical(TransversalsOf(decomp)[i],
        Perm2CosetRepr(list[i],TransversalsOf(decomp)[i])));
  od;
  return l;
end);

#coding from the cascaded format
InstallGlobalFunction(DecodeCosetReprs,
function(decomp,cascstate)
local i,l;
  l := [];
  for i in [1..Size(cascstate)] do
    Add(l, TransversalsOf(decomp)[i][cascstate[i]]);
  od;
  return l;
end);

# Each cascaded state corresponds to one element (in the regular representation)
#of the group. This function gives the path corresponding to a group element
#(through the Lagrange-Frobenius map).
InstallGlobalFunction(Perm2CascadedState,
function(decomp,g)
local coords,i;

  #on the top level we have simply g
  coords := [];
  Add(coords,g);
  #then going down to deeper levels
  for i in [2..Length(decomp)] do
    Add(coords,
        coords[i-1]
        * Inverse(Perm2CosetRepr(coords[i-1], TransversalsOf(decomp)[i-1])) );
  od;

  #taking the representative elements
  for i in [1..Length(coords)] do
    coords[i] := Perm2CosetRepr(coords[i], TransversalsOf(decomp)[i]);
  od;

  # then coding coset representatives as points
  for i in [1..Length(coords)] do
    coords[i] :=  PositionCanonical( TransversalsOf(decomp)[i],coords[i]);
  od;

  return coords; #CascadedState(CascadeShellOf(decomp),coords);
end);

InstallGlobalFunction(CascadedState2Perm,
function(decomp,cs)
    return Product(Reversed(DecodeCosetReprs(decomp,cs)),());
end);


#given a cascaded state it returns an array of flat cascops that -
#applied in order - kills of levels top-down.
InstallGlobalFunction(LevelKillers,
function(decomp,cs)
local decoded, cosetrepr, killers;
  decoded := DecodeCosetReprs(decomp,cs);
  killers := [];
  for cosetrepr in decoded do
    Add(killers,Inverse(cosetrepr));
  od;
  return killers;
end);

InstallGlobalFunction(LevelBuilders,
function(decomp,cs)
local decoded, cosetrepr, builders;
  decoded := DecodeCosetReprs(decomp,cs);
  builders := [];
  for cosetrepr in decoded do
    Add(builders,cosetrepr);
  od;
  return builders;
end);

################################################################################
###############YEAST STATES#####################################################
InstallMethod(Raise,
    "raise a state",
    true,
    [IsLagrangeDecomposition,IsInt], 0,
function(decomp,i)
    return Perm2CascadedState(decomp,decomp!.stabilizertransversalreps[i]);
end);

InstallMethod(Flatten,
    "flatten a cascaded state",
    true,
    [IsLagrangeDecomposition,IsList], 1,
function(decomp,cs)
  #the Frobenius-Lagrange map TODO transitivity
  return 1 ^ Product(Reversed(DecodeCosetReprs(decomp,cs)),());
end);

#InstallMethod(Flatten,
#    "flatten an abstract cascaded state",
#    true,
#    [IsLagrangeDecomposition,IsAbstractCascadedState], 0,
#function(decomp,cs) #TODO!! replace  this with the more efficient one
#local state, flattened,point;
#  flattened := [];
#  for state in States(CascadeShellOf(decomp)) do
#    if state < cs then
#      point := Flatten(decomp,state);
#      if not (point in flattened) then Add(flattened, point); fi;
#    fi;
#  od;
#  return flattened;
#end);

################################################################################
#####################YEAST PERMUTATIONS#########################################

#decomp - cascade components of group, g element of the group
InstallMethod(Raise,
    "raise a permutation",
    true,
    [IsLagrangeDecomposition,IsPerm], 0,
function(decomp,g)
local j,state,states,fudges,depfunctable,arg;

  if g=() then return IdentityCascadedTransformation(CascadeShellOf(decomp));fi;

  #the states already coded as coset representatives
  states := LazyCartesian(TransversalsOf(decomp));

  #the lookup for the new dependencies
  depfunctable := [];

  #we go through all states
  for state in states do
    #get the component actions on a state
    fudges := ComponentActions(decomp,g,state);

    #examine whether there is a nontrivial action, then add
    for j in [1..Length(fudges)] do
      if fudges[j] <> () then
        arg := EncodeCosetReprs(decomp,state{[1..(j-1)]});
        RegisterNewDependency(depfunctable, arg, fudges[j]);
      fi;
    od;
  od;

  return CascadedTransformation(CascadeShellOf(decomp),depfunctable);
end);

InstallMethod(Flatten,
    "flatten a cascaded permutation",
    true,
    [IsLagrangeDecomposition,IsCascadedTransformation], 0,
function(decomp,co)
    return PermList(List(OriginalStateSet(decomp),
                   x-> Flatten(decomp, Raise(decomp,x) ^ co)));
end);

InstallMethod(Interpret,
    "interprets a component's state",
    true,
    [IsLagrangeDecomposition,IsInt,IsInt], 0,
function(decomp,level,state)
  return TransversalsOf(decomp)[level][state];
end);

################################################################################
########X2Y#####################################################################
InstallOtherMethod(x2y,
    "finds a cascaded operation taking cascaded state x to y",
    true,
    [IsLagrangeDecomposition,IsList,IsList], 0,
function(decomp,x,y)
local tobase, frombase, id;
    # going to the leftmost branch
    tobase :=  Product(LevelKillers(decomp,x),());
    #then to y
    frombase := Product(Reversed(LevelBuilders(decomp,y)),());
    #combining the two legs of the journey
    return tobase * frombase;
end);

InstallOtherMethod(x2y,
        "finds an original operation taking original state x to y",
        true,
        [IsLagrangeDecomposition,IsInt,IsInt], 0,
function(decomp,x,y)
   return x2y(decomp,Raise(decomp,x), Raise(decomp,y));
end);

#this is purely for checking as it is easy to do this in the flat group
InstallOtherMethod(x2y,
    "finds a cascaded operation taking cascaded operation x to y",
    true,
    [IsLagrangeDecomposition,IsCascadedTransformation,IsCascadedTransformation],
    0,
function(decomp,x,y)
  return x2y(decomp,Perm2CascadedState(decomp,Flatten(decomp,x)),
             Perm2CascadedState(decomp,Flatten(decomp,y)));
  #this flattening is stupid but Perm2CascadedState expects flat permutation.
end);

################################################################################
#ACCESS FUNCTIONS###############################################################
InstallGlobalFunction(TransversalsOf,
function(decomp)
  return decomp!.transversals;
end);

InstallGlobalFunction(SeriesOf,
function(decomp)
  return decomp!.series;
end);

InstallGlobalFunction(OriginalStateSet,
        function(decomp) return decomp!.originalstateset;end);

####################OLD FUNCTIONS#################################
# The size of the cascade shell is the number components.
InstallMethod(Length,"for Lagrange decompositions",true,
        [IsLagrangeDecomposition],
function(ld)
  # just delegating the task to the cascade shell
  return Length(ld!.cascadeshell);
end);

# for accessing the list elements
InstallOtherMethod( \[\],
    "for Lagrange decompositions",
    [ IsLagrangeDecomposition, IsPosInt ],
function( ld, pos )
  # just delegating the task to the cascade shell
  return ld!.cascadeshell[pos];
end);

#############################################################################
# Implementing Display, printing nice, human readable format.
InstallMethod( ViewObj,
    "displays a Lagrange decomposition",
    true,
    [IsLagrangeDecomposition], 0,
function( ld )
  Print("Lagrange decomposition of:");
  ViewObj(OriginalStructureOf(ld));Print("\n");
  ViewObj(ld!.cascadeshell);
end);