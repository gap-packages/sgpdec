################################################################################
# CONSTRUCTOR ##################################################################
# setting the basic attributes of the skeleton
InstallGlobalFunction(SKELETON,
function(ts)
  local o;
  o := Objectify(SKELETONType, rec());
  SetTransSgp(o,ts);
  SetGenerators(o,GeneratorsOfSemigroup(ts));
  SetDegreeOfSKELETON(o,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(o, FiniteSet([1..DegreeOfSKELETON(o)]));
  return o;
end);

################################################################################
# ORBIT OF THE STATE SET #######################################################
# the main orbit calculation is done by Orb from the orb package
InstallMethod(ForwardOrbit, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  local o;
  o := Orb(TransSgp(sk), BaseSet(sk), OnFiniteSets,
           rec(schreier:=true,orbitgraph:=true));
  Enumerate(o);
  return o;
end);

# the list of representatives as indices
InstallMethod(SKELETONTransversal, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return List(OrbSCC(ForwardOrbit(sk)), x->x[1]);
end);

################################################################################
# EXTENDED IMAGE SET ###########################################################

# 1-element subsets of the state set (may not be images)
InstallMethod(Singletons, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return List([1..DegreeOfSKELETON(sk)],
              i -> FiniteSet([i], DegreeOfSKELETON(sk)));
end);

#for sorting finitesets, first by size, then by content
DescendingSizeSorter := function(v,w)
  if SizeBlist(v) <> SizeBlist(w) then
    return SizeBlist(v)>SizeBlist(w);
  else
    return v<w;
  fi;
end;
MakeReadOnlyGlobal("DescendingSizeSorter");

# the image set extended with singletons and ordered
InstallMethod(ExtendedImageSet, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  local imageset;
  #we have to copy it
  imageset := ShallowCopy(UnderlyingPlist(ForwardOrbit(sk)));
  #extending with the state set...
  if not (BaseSet(sk) in ForwardOrbit(sk)) then
    Add(imageset,BaseSet(sk),1); #adding it as first
  fi;
    #...and the singletons
  Perform(Singletons(sk),
          function(x)
    if not(x in ForwardOrbit(sk)) then
      Add(imageset,x);
    fi;
  end);
  #now sorting descending by size
  Sort(imageset,DescendingSizeSorter);
  return imageset;
end);

################################################################################
# INCLUSION RELATION ###########################################################
################################################################################

# returns the maximal subsets of the given set found in the given ordered set
# of sets, for the skeleton the extended set of images
#TODO can this be further improved by recursion
#TODO this is TilesOf, but not stored
MaximalSubsets := function(set, orderedsubsets)
local covers, pos, flag,s;
  #singletons have no covers
  if SizeBlist(set) = 1 then return []; fi;
  covers := [];
  #we search only from this position
  pos := Position(orderedsubsets, set) + 1;
  while pos <= Size(orderedsubsets) do
    if IsProperFiniteSubset(set, orderedsubsets[pos]) then
      flag := true;
      # we check whether the newly found subset is a subset of a cover
      for s in covers do
        if IsProperFiniteSubset(s,orderedsubsets[pos]) then
          flag := false;
          break;
        fi;
      od;
      if flag then Add(covers,orderedsubsets[pos]);fi;
    fi;
    pos := pos + 1;
  od;
  return covers;
end;
MakeReadOnlyGlobal("MaximalSubsets");

# binary relation defined by covering elements (sort of HasseDiagram)
BinaryRelationByCoverFuncNC := function(set, coverfunc)
local i,j,dom,tups,h;
  dom := Domain(set);
  tups := [];
  for i in dom do
    for j in coverfunc(i) do
      Add(tups, Tuple([i, j]));
    od;
  od;
  h := BinaryRelationByElements(dom, tups);
  return h;
end;
MakeReadOnlyGlobal("BinaryRelationByCoverFuncNC");

InstallMethod(InclusionCoverBinaryRelation,
        "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return BinaryRelationByCoverFuncNC(ExtendedImageSet(sk),
                 set->MaximalSubsets(set, ExtendedImageSet(sk)));
end);

################################################################################
# SUBDUCTION ###################################################################

#the subduction Hasse diagram of representatives

# returns the indices of the direct images of the scc indexed by indx
# indx - the index of an orbit element
DirectSCCImages := function(sk,sccindx)
local rep,o,indx,og,covers,ol;
  o := ForwardOrbit(sk);
  og := OrbitGraph(o);
  ol := OrbSCCLookup(o);
  covers := [];
  #for all elements in the SCC
  for indx in OrbSCC(o)[sccindx] do
    Perform(og[indx], function(x) AddSet(covers, ol[x]);end);
  od;
  #removing self-image
  if sccindx in covers then Remove(covers, Position(covers,sccindx));fi;
  return covers;
end;
MakeReadOnlyGlobal("DirectSCCImages");

# indx - the index of an orbit element
InclusionSCCCovers := function(sk,sccindx)
local covers, rep, l,i,o,ol,indx;
  o := ForwardOrbit(sk);
  ol := OrbSCCLookup(o);
  covers := [];
  for indx in OrbSCC(o)[sccindx] do
    #convert the tiles into their indices
    l := List(SKTilesOf(sk,o[indx]),x->Position(o,x));
    for i in l do
      if i <> fail then # some singletons may not be in the orbit
        AddSet(covers, ol[i]);
      fi;
    od;
  od;
  return covers;
end;
MakeReadOnlyGlobal("InclusionSCCCovers");

#collecting the direct images and inclusion covers of an SCC
#thus building the generalized inclusion covers
InstallMethod(RepSubductionCoverBinaryRelation,
        "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return BinaryRelationByCoverFuncNC([1..Size(SKELETONTransversal(sk))],
                 x->Union(InclusionSCCCovers(sk,x),DirectSCCImages(sk,x)));
end);

################################################################################
# HEIGHT, DEPTH ################################################################

InstallMethod(Heights,
        "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  local leaves, leaf, correction,o,reps,heights,depths,RecHeight;
  o := ForwardOrbit(sk);
  reps := SKELETONTransversal(sk);
  heights := ListWithIdenticalEntries(Size(reps),0);
  #-----------------------------------------------------------------------------
  RecHeight := function(sk, eqclassindx ,height)
    local p,parents;
    parents := PreImages(RepSubductionCoverBinaryRelation(sk), eqclassindx);
    for p in parents do
      if not IsSingleton(o[reps[p]]) then #if it is not a singleton
        if heights[p] < height+1 then
          heights[p] := height+1;
          #only call when the height is raised (this saves a lot of calls)
          RecHeight(sk,p,height+1);
        fi;
      fi;
    od;
  end;
  #-----------------------------------------------------------------------------

  #If there is no singleton image, then we need to add one to the depth
  correction := 1;
  #we start chains from the elements with no children
  leaves := Filtered([1..Length(reps)],
                    x->IsEmpty(Images(RepSubductionCoverBinaryRelation(sk),x)));
  for leaf in leaves do
    if IsSingleton(o[reps[leaf]]) then
      correction:=0;#there is a singleton image, so no correction needed
      heights[leaf] := 0;
      RecHeight(sk,leaf,0);
    else
      heights[leaf] := 1;
      RecHeight(sk,leaf,1);
    fi;
  od;
  #calculating depth based on upside down height
  return heights;
end);

InstallMethod(Depths,
        "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return List(Heights(sk), x-> Heights(sk)[1]-x + 1);
end);

################################################################################
InstallGlobalFunction(SKTilesOf,
function(sk,set)
  return Images(InclusionCoverBinaryRelation(sk),set);
end);

#returns the representative element of the scc of a finiteset
InstallGlobalFunction(SKRepresentativeSet,
function(sk, finiteset)
local o;
  o := ForwardOrbit(sk);
  return o[SKELETONTransversal(sk)[OrbSCCLookup(o)[Position(o, finiteset)]]];
end);
