#############################################################################
##
## skeleton.gi           SgpDec package
##
## Copyright (C) 2010-2015
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Skeleton of the semigroup action on a set. Subduction relation,
## equivalence classes, tilechains.
##

################################################################################
# CONSTRUCTOR ##################################################################
# setting the basic attributes of the skeleton
InstallGlobalFunction(Skeleton,
function(ts)
  local o;
  o := Objectify(SkeletonType, rec());
  SetTransSgp(o,ts);
  SetGenerators(o,Generators(ts));
  SetDegreeOfSkeleton(o,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(o, FiniteSet([1..DegreeOfSkeleton(o)]));
  return o;
end);

################################################################################
# ORBIT OF THE STATE SET #######################################################
# the main orbit calculation is done by Orb from the orb package
InstallMethod(ForwardOrbit, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local o;
  o := Orb(TransSgp(sk), BaseSet(sk), OnFiniteSet,
           rec(schreier:=true,orbitgraph:=true));
  Enumerate(o);
  return o;
end);

# the list of representatives as indices
InstallMethod(SkeletonTransversal, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List(OrbSCC(ForwardOrbit(sk)), x->x[1]);
end);

################################################################################
# EXTENDED IMAGE SET ###########################################################

# 1-element subsets of the state set (may not be images)
InstallMethod(Singletons, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List([1..DegreeOfSkeleton(sk)],
              i -> FiniteSet([i], DegreeOfSkeleton(sk)));
end);

# those singletons that are not images
InstallMethod(NonImageSingletons, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return Filtered(Singletons(sk), x-> not x in ForwardOrbit(sk));
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

# the image set extended with singletons and ordered by descending size
InstallMethod(ExtendedImageSet, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local imageset;
  #we have to copy it
  imageset := ShallowCopy(UnderlyingPlist(ForwardOrbit(sk)));
  #extending with the state set...
  if not (BaseSet(sk) in ForwardOrbit(sk)) then
    Add(imageset,BaseSet(sk),1); #adding it as first
  fi;
  #...and the singletons
  Perform(NonImageSingletons(sk),
          function(x) Add(imageset,x);end);
  #now sorting descending by size
  Sort(imageset,DescendingSizeSorter);
  return imageset;
end);

InstallGlobalFunction(ContainsSet,
function(sk, set)
  #checking whether we have the set somewhere
  return set in ForwardOrbit(sk)
         or set = BaseSet(sk)
         or set in NonImageSingletons(sk);
end);

################################################################################
# INCLUSION RELATION ###########################################################
################################################################################

# returns the maximal subsets of the given set found in the given ordered set
# of sets, for the skeleton the extended set of images
#TODO can this be further improved by recursion
MaximalSubsets := function(sk, set)
local covers, pos, orderedsubsets;
  #singletons have no covers
  if SizeBlist(set) = 1 then return []; fi;
  covers := [];
  #we search only from this position in the descending order
  orderedsubsets := ExtendedImageSet(sk);
  pos := Position(orderedsubsets, set) + 1;
  while pos <= Size(orderedsubsets) do
    if IsProperFiniteSubset(set, orderedsubsets[pos])
       and
       not ForAny(covers,x->IsProperFiniteSubset(x,orderedsubsets[pos])) then
      Add(covers,orderedsubsets[pos]);
    fi;
    pos := pos + 1;
  od;
  return covers;
end;
MakeReadOnlyGlobal("MaximalSubsets");

# binary relation defined by covering elements (sort of HasseDiagram)
BinaryRelationByCoverFuncNC := function(set, coverfunc)
local x,y,dom,tups;
  dom := Domain(set);
  tups := [];
  for x in dom do
    for y in coverfunc(x) do
      Add(tups, Tuple([x, y]));
    od;
  od;
  return BinaryRelationByElements(dom, tups);
end;
MakeReadOnlyGlobal("BinaryRelationByCoverFuncNC");

InstallMethod(InclusionCoverBinaryRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return BinaryRelationByCoverFuncNC(ExtendedImageSet(sk),
                 set->MaximalSubsets(sk,set));
end);

################################################################################
# SUBDUCTION ###################################################################
################################################################################

#the subduction Hasse diagram of representatives

# returns the indices of the direct images of the scc indexed by indx
# and the maximal subsets
# sccindx - the index of an orbit SCC
SubductionCovers := function(sk,sccindx)
local rep,o,indx,og,covers,ol,l;
  o := ForwardOrbit(sk);
  og := OrbitGraph(o);
  ol := OrbSCCLookup(o);
  covers := [];
  #for all elements in the SCC
  for indx in OrbSCC(o)[sccindx] do
    #direct images
    Perform(og[indx], function(x) AddSet(covers, ol[x]);end);
    #tiles, checking for fail for nonimage singletons
    Perform(Filtered(List(TilesOf(sk,o[indx]),x->Position(o,x)),y -> y<>fail),
            function(z) AddSet(covers, ol[z]);end);
  od;
  #removing self-image
  if sccindx in covers then Remove(covers, Position(covers,sccindx));fi;
  return covers;
end;
MakeReadOnlyGlobal("SubductionCovers");

#collecting the direct images and inclusion covers of an SCC
#thus building the generalized inclusion covers
InstallMethod(RepSubductionCoverBinaryRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return BinaryRelationByCoverFuncNC([1..Size(SkeletonTransversal(sk))],
                 x->SubductionCovers(sk,x));
end);

################################################################################
# subduction based on orbits from sets (not so nicely called partial orbits)

#just empty lists in the beginning, built on demand
#contains the forward orbits of elements from the image set
#indices coming from ExtendedImageSet
InstallMethod(PartialOrbits, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallGlobalFunction(IsSubductionEquivalent,
function(sk, A, B)
  local o;
  o := ForwardOrbit(sk);
  return OrbSCCLookup(o)[Position(o, A)]
         = OrbSCCLookup(o)[Position(o, B)];
end);

#just a util functions to check whether the required partial orbit is available
#if not, then calculate it
CalcPartialOrbitOnDemand := function(sk,Q,Qindx)
  if not IsBound(PartialOrbits(sk)[Qindx]) then
    PartialOrbits(sk)[Qindx] := Orb(TransSgp(sk), Q, OnFiniteSet,
                                 rec(schreier:=true,orbitgraph:=true));
    Enumerate(PartialOrbits(sk)[Qindx]);
  fi;
end;
MakeReadOnlyGlobal("CalcPartialOrbitOnDemand");

# true is P \subseteq Qs
InstallGlobalFunction(IsSubductionLessOrEquivalent,
function(sk, P, Q)
  local Qindx;
  Qindx := Position(ExtendedImageSet(sk),Q);
  CalcPartialOrbitOnDemand(sk,Q, Qindx);
  return ForAny(PartialOrbits(sk)[Qindx],
                Qs -> IsSubsetBlist(Qs,P));
end);

#TODO it is not optimal to search twice for a superset
InstallGlobalFunction(SubductionWitness,
function(sk, P, Q)
  local Qorb,Qs;
  if not IsSubductionLessOrEquivalent(sk,P,Q) then return fail; fi;
  #we know that the partial orbit is already calculated by IsSubductionLessOr...
  Qorb := PartialOrbits(sk)[Position(ExtendedImageSet(sk),Q)];
  Qs := First(Qorb, Qs -> IsSubsetBlist(Qs,P));
  return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
end);

#return s such that P=Qs
InstallGlobalFunction(ImageWitness,
function(sk, P, Q)
  local Qorb,Qs,Qindx;
  Qindx := Position(ExtendedImageSet(sk),Q);
  CalcPartialOrbitOnDemand(sk,Q, Qindx);
  Qorb := PartialOrbits(sk)[Qindx];
  Qs := First(Qorb, Qs->Qs=P);
  if Qs = fail then
    return fail;
  else
    return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
  fi;
end);

#lots of muscle work for the nonimage singletons
#calculating subduction equivalence
InstallMethod(NonImageSingletonClasses,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local l, cls, tmp,s,q;
  l := ShallowCopy(NonImageSingletons(sk));
  cls := [];
  while not IsEmpty(l) do
    q := Remove(l);
    tmp := [q]; #starting new class with the last one
    for s in ShallowCopy(l) do #to be on the safe side
      if IsSubductionLessOrEquivalent(sk,s,q) and
         IsSubductionLessOrEquivalent(sk,q,s) then
        Add(tmp,s);
        Remove(l,Position(l,s));
      fi;
    od;
    Add(cls,tmp);
  od;
  return cls;
end);

InstallGlobalFunction(SubductionClassOfSet,
function(sk, set)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o)[OrbSCCLookup(o)[Position(o, set)]],x-> o[x]);
end);

#TODO document this!
InstallGlobalFunction(WeakControlWords,
function(sk, X, Y)
  local Xp,Xclass;
  if IsSubsetBlist(X,Y) then
    Xp := X;
  else
    Xclass := SubductionClassOfSet(sk,X);
    Xp := First(Xclass, XC->IsSubsetBlist(XC,Y));
  fi;
  if Xp = fail then return fail; fi;
  return [ImageWitness(sk,Xp,X), ImageWitness(sk,Y,Xp)];
end);


################################################################################
# HEIGHT, DEPTH ################################################################

#height functions
MinimalHeightValues := function(sk)
  local leaves, leaf, o,reps,heights,RecHeight;
  o := ForwardOrbit(sk);
  reps := SkeletonTransversal(sk);
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
  #we start chains from the elements with no children
  leaves := Filtered([1..Length(reps)],
                    x->IsEmpty(Images(RepSubductionCoverBinaryRelation(sk),x)));
  for leaf in leaves do
    if IsSingleton(o[reps[leaf]]) then
      heights[leaf] := 0;
      RecHeight(sk,leaf,0);
    else
      heights[leaf] := 1;
      RecHeight(sk,leaf,1);
    fi;
  od;
  return heights;
end;
MakeReadOnlyGlobal("MinimalHeightValues");

#one equivalence class per level #TODO singletons may not be done properly
MaximalHeightValues := function(sk)
local heights, i, l;
  #now do topological sorting
  heights := MinimalHeightValues(sk);
  #we collect the positions of same height values, flattened & ordered
  l := Flat(List([Minimum(heights)..Maximum(heights)],
                x -> Positions(heights,x))); #positions can be permuted
  heights := [];
  #then just assign its index to it
  Perform([1..Size(l)], function(x) heights[l[x]] := x-1;end);
  return heights;
end;
MakeReadOnlyGlobal("MaximalHeightValues");

CardinalityHeightValues := function(sk)
local heights,o,posl;
  o := ForwardOrbit(sk);
  heights := List(SkeletonTransversal(sk), x->SizeBlist(o[x])-1);
  posl := List([Minimum(heights)..Maximum(heights)], x-> Positions(heights,x));
  while Position(posl, []) <> fail do Remove(posl, Position(posl,[]));od;
  Perform([1..Size(posl)], function(x) Perform(posl[x], function(y)heights[y]:= x;end) ;end);
  return heights;
end;

InstallMethod(Heights, "for a skeleton (SgpDec)", [IsSkeleton],
        MinimalHeightValues);

#calculating depth based on upside down height
InstallMethod(Depths,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List(Heights(sk), x-> Heights(sk)[1]-x + 1);
end);

InstallMethod(DepthOfSkeleton,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  if Size(Singletons(sk)) = Size(NonImageSingletons(sk)) then
    return Maximum(Depths(sk))+1;
  else
    return Maximum(Depths(sk));
  fi;
end);

################################################################################
# TILES, TILEC HAINS ###########################################################
################################################################################

InstallGlobalFunction(TilesOf,
function(sk,set)
  if ContainsSet(sk,set) then
    return Images(InclusionCoverBinaryRelation(sk),set);
  else
    return fail;
  fi;
end);

# used by holonomy
InstallGlobalFunction(RandomTileChain,
function(sk,k)
local chain,singleton, set;
  chain := [];
  singleton := FiniteSet([k], DegreeOfSkeleton(sk));
  Add(chain,BaseSet(sk));
  set := chain[Length(chain)];
  while set <> singleton do
    Add(chain,Random(
            Filtered(Images(InclusionCoverBinaryRelation(sk),set),
                    x->IsSubsetBlist(x,singleton))));
    set := chain[Length(chain)];
  od;
  return chain;
end);

InstallGlobalFunction(NrTileChainsBetween,
function(sk,A,B)
local sizes, tiles;
  if A = B then return 1; fi;
  tiles := Filtered(Images(InclusionCoverBinaryRelation(sk),A),
                   x->IsSubsetBlist(x,B));
  sizes := List(tiles, x -> NrTileChainsBetween(sk,x,B));
  return Sum(sizes);
end);


# recursively extending chain top-down from its last element to target
RecTileChainsBetween := function(sk,chain,target,coll)
local set,cover;
  set := chain[Length(chain)];
  if set = target then #we have a complete chain now, copy and return
    Add(coll, ShallowCopy(chain));
    return; #this copying a bit clumsy, but what can we do?
  fi;
  # recur on all covers that contain the target
  Perform(Filtered(Images(InclusionCoverBinaryRelation(sk),set),
                  cover -> IsSubsetBlist(cover,target)),
          function(s)
            Add(chain, s);
            RecTileChainsBetween(sk, chain, target, coll);
            Remove(chain);
          end);
end;
MakeReadOnlyGlobal("RecTileChainsBetween");

InstallGlobalFunction(TileChainsBetween,
function(sk, A,B) # A \subset B
local coll;
  coll := []; # collecting the tilechains in here
  RecTileChainsBetween(sk, [A], B, coll);
  return coll;
end);

InstallGlobalFunction(TileChains,
function(sk)
local coll,s;
  coll := [];
  for s in Singletons(sk) do
    Append(coll, TileChainsBetween(sk,BaseSet(sk),s));
  od;
  return coll;
end);

# extracts the point in the singleton element
# when called with a tile chain fragment the result is meaningless
InstallGlobalFunction(TileChainRoot,
function(tc)
  local singleton;
  singleton := tc[Size(tc)]; #the last element     
  return First([1..Size(singleton)], x->singleton[x]);    
end);


#for acting on tile chains
InstallGlobalFunction(OnSequenceOfSets,
function(tc, s)
  return Set(tc,tile -> OnFiniteSet(tile,s)); #hoping for the order
end);

# just giving a dominating tile chain
InstallGlobalFunction(DominatingTileChain,
function(sk,chain)
  local pos, dtc;
  if IsEmpty(chain) then return fail;fi;
  pos := 1;
  dtc := ShallowCopy(chain);
  if dtc[1] <> BaseSet(sk) then Add(dtc, BaseSet(sk),1);fi;
  while not IsSingleton(dtc[pos]) do
    if not dtc[pos+1] in TilesOf(sk, dtc[pos]) then
      Add(dtc,
          First(TilesOf(sk,dtc[pos]), x->IsSubsetBlist(x,dtc[pos+1])),
          pos+1);
    fi;
    pos := pos + 1;
  od;
  return dtc;
end);

InstallGlobalFunction(DominatingTileChains,
function(sk,chain)
  local chains, fragments;
  if IsEmpty(chain) then return fail;fi; #TODO why do we give up here?
  if chain[1] <> BaseSet(sk) then Add(chain, BaseSet(sk),1);fi;
  fragments := List([1..Size(chain)-1],
                    x->TileChainsBetween(sk,chain[x],chain[x+1]));
  #removing duplicates, the in-between ones
  Perform([1..Size(fragments)-1],
          function(x)
            Perform(fragments[x],
                    function(y)Remove(y,Length(y));end);
          end);
  #now combining all together (there seems to be no sublist sharing)
  return List(EnumeratorOfCartesianProduct(fragments), Concatenation);
end);

# this cuts off the base set
InstallGlobalFunction(PositionedTileChain,
function(sk, chain)
  local positioned,i;
  positioned := List([1..DepthOfSkeleton(sk)-1],x->0);
  i := 1;
  while i < Length(chain) do
    positioned[DepthOfSet(sk,chain[i])] := chain[i+1];
    i := i +1;
  od;
  return positioned;
end);

################################################################################
InstallGlobalFunction(DepthOfSet,
function(sk,A)
  if IsSingleton(A) then return DepthOfSkeleton(sk); fi;
  return Depths(sk)[
                 OrbSCCLookup(ForwardOrbit(sk))[Position(ForwardOrbit(sk),A)]
                 ];
end);

#returns the representative element of the scc of a finiteset
InstallGlobalFunction(RepresentativeSet,
function(sk, finiteset)
local o;
  o := ForwardOrbit(sk);
  return o[SkeletonTransversal(sk)[OrbSCCLookup(o)[Position(o, finiteset)]]];
end);

InstallMethod(RepresentativeSets, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local reps;
  reps := List([1..DepthOfSkeleton(sk)], i -> []);
  Perform(List(SkeletonTransversal(sk),x->ForwardOrbit(sk)[x]),
          function(x)Add(reps[DepthOfSet(sk,x)],x);end);
  return reps;
end);

InstallGlobalFunction(RepresentativeSetsOnDepth,
function(sk, depth)
  return RepresentativeSets(sk)[depth];
end);

InstallGlobalFunction(RealImageSubductionClasses,
function(sk)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o),x->List(x, y->o[y]));
end);

InstallGlobalFunction(SubductionClasses,
function(sk)
  return Concatenation(RealImageSubductionClasses(sk),
               NonImageSingletonClasses(sk));
end);

InstallGlobalFunction(SubductionClassesOnDepth,
function(sk, depth)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o){Positions(Depths(sk), depth)},
              x->List(x, y->o[y]));
end);

InstallMethod( ViewObj,"for a skeleton",[IsSkeleton],
function(sk)
  Print("<skeleton of ", String(TransSgp(sk)), ">");
end);

InstallMethod(Display,"for a skeleton",[IsSkeleton],
function(sk) ViewObj(sk); Print("\n"); end);
