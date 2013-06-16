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
SKInclusionCoverReps := function(sk,indx)
local l, rep, tmpl,i;
  #convert the image sets into their indices
  tmpl := List(TilesOf(sk,sk.orb[indx]),x->Position(sk.orb,x));
  l := [];
  for i in tmpl do
    if i <> fail then # some singletons may not be in the orbit
      AddSet(l, OrbSCCLookup(sk.orb)[i]);
    fi;
  od;
  rep := OrbSCCLookup(sk.orb)[indx];
  if rep in l then Remove(l, Position(l,rep));fi;
  return l;
end;
MakeReadOnlyGlobal("SKInclusionCoverReps");

#collecting the direct images and inclusion covers of an SCC
#thus building the generalized inclusion covers
SKCoversOfSCC := function(sk, sccindx)
local l,covers;
  covers := [];
  #the covers in the inclusion relation
  for l in List(OrbSCC(sk.orb)[sccindx],
          x -> InclusionCoverReps(sk,x)) do
    Perform(l, function(x) AddSet(covers, x);end);
  od;
  #the direct image covers
  for l in List(OrbSCC(sk.orb)[sccindx],
          x -> DirectImagesReps(sk,x)) do
    Perform(l, function(x) AddSet(covers, x);end);
  od;
  return covers;
end;
MakeReadOnlyGlobal("SKCoversOfSCC");




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
