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
# COORDINATIZING POINTS ########################################################

InstallOtherMethod(AsCoords,
    "for a point",
    true,
    [IsInt,IsLagrangeDecomposition],
function(i,decomp)
    return Perm2Coords(decomp,decomp!.stabilizertransversalreps[i]);
end);

InstallOtherMethod(AsPoint,
    "for coordinates in Lagrange decomposition",
    true,
    [IsDenseList, IsLagrangeDecomposition],
function(cs,decomp)
local l;
  if (Length(cs) = Size(decomp)) and (Minimum(cs) > 0) then
    #the Frobenius-Lagrange map TODO transitivity
    return 1 ^ Product(Reversed(DecodeCosetReprs(decomp,cs)),());
  else
    l := [];
    Perform(AllConcreteCoords(CascadeShellOf(decomp),cs),
            function(x) AddSet(l,
                    1 ^ Product(Reversed(DecodeCosetReprs(decomp,x)),())
                    );end);
    return  l;
  fi;
end);

################################################################################
# LIFTING PERMUTATION ##########################################################

#decomp - cascade components of group, g element of the group
InstallOtherMethod(AsCascadedTrans,
    "raise a permutation",
    true,
    [IsPerm,IsLagrangeDecomposition],
function(g,decomp)
local j,state,states,fudges,depfunctable,arg;

  if g=() then return IdentityCascadedTransformation(CascadeShellOf(decomp));fi;

  #the states already coded as coset representatives
  states := EnumeratorOfCartesianProduct(TransversalsOf(decomp));

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

InstallOtherMethod(AsPermutation,
    "for a cascaded permutation",
    true,
    [IsCascadedTransformation,IsLagrangeDecomposition],
function(co,decomp)
    return PermList(List(OriginalStateSet(decomp),
                   x-> AsPoint(AsCoords(x,decomp) ^ co,decomp)));
end);

InstallMethod(Interpret,
    "interprets a component's state",
    true,
    [IsLagrangeDecomposition,IsInt,IsInt],
function(decomp,level,state)
  return TransversalsOf(decomp)[level][state];
end);

################################################################################
########X2Y#####################################################################
#TODO X2Y is just not in the right format at the moment
InstallOtherMethod(x2y,
    "finds a cascaded operation taking cascaded state x to y",
    true,
    [IsLagrangeDecomposition,IsList,IsList],
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
        [IsLagrangeDecomposition,IsInt,IsInt],
function(decomp,x,y)
   return x2y(decomp,AsCoords(x,decomp), AsCoords(y,decomp));
end);

#this is purely for checking as it is easy to do this in the flat group
InstallOtherMethod(x2y,
    "finds a cascaded operation taking cascaded operation x to y",
    true,
    [IsLagrangeDecomposition,IsCascadedTransformation,IsCascadedTransformation],
    0,
function(decomp,x,y)
  return x2y(decomp,Perm2Coords(decomp,AsPermutation(x,decomp)),
             Perm2Coords(decomp,AsPermutation(y,decomp)));
  #this flattening is stupid but Perm2Coords expects flat permutation.
end);
