#############################################################################
##
## skeleton.gi           SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Skeleton of the semigroup action on a set. Subduction relation,
## equivalence classes, tilechains.
##
## Some of the functions below use undocumented features of the Orb package,
## namely OrbSCC, OrbSCCLookup and !.schreierpos,
## therefore they could break due to changes upstream.

################################################################################
# CONSTRUCTOR ##################################################################
# setting the basic attributes of the skeleton, but not computing anything yet
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
  return List(OrbSCC(ForwardOrbit(sk)), First); #TODO choice for representatives made here 
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
# we only need to add non-image singletons, as the base set is in the orbit
InstallMethod(ExtendedImageSet, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local imageset;
  #we have to copy it
  imageset := ShallowCopy(UnderlyingPlist(ForwardOrbit(sk)));
  #add the missing singletons
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

InstallMethod(InclusionCoverRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return HasseDiagramBinaryRelation(
          PartialOrderByOrderingFunction(Domain(ExtendedImageSet(sk)),
                                         IsSubsetBlist));
end);

################################################################################
# SUBDUCTION ###################################################################
################################################################################

#the subduction Hasse diagram of representatives


InstallMethod(SubductionEquivClassRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local o, SCCLookup, SCCOf, DirectImages, NonFailing, Set2Index, SubSets, reps, imgs, subs, l;
  o := ForwardOrbit(sk);
  # functions are defined for better readability and separating technical (Orb) code
  SCCLookup := x -> OrbSCCLookup(o)[x]; #finds SCC of an orbit element (the index of it)
  SCCOf := x -> OrbSCC(o)[OrbSCCLookup(o)[x]]; #finds the SCC and return the whole class
  DirectImages := x -> Union(List(SCCOf(x),  y -> OrbitGraph(o)[y])); #direct descendants in the orbit graph
  NonFailing := x -> x <> fail; #predicate function for not being fail
  Set2Index := x -> Position(o,x);
  reps := SkeletonTransversal(sk);
  SubSets := x -> Union(List(SCCOf(x), y -> Images(InclusionCoverRelation(sk),o[y])));
  #subduction is image of and subset of relation combined
  imgs := List(reps, DirectImages); #direct images of representatives
  subs := List(reps, rep -> Filtered( List(SubSets(rep),Set2Index), NonFailing));
  l := List([1..Size(reps)], i -> Union(imgs[i], subs[i]));
  return TransitiveClosureBinaryRelation(
           ReflexiveClosureBinaryRelation(
             BinaryRelationOnPoints(List(l, z -> Unique(List(z, SCCLookup))))));
end);

InstallMethod(SubductionEquivClassCoverRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return HasseDiagramBinaryRelation(SubductionEquivClassRelation(sk));
end);

InstallGlobalFunction(IsSubductionEquivalent,
function(sk, A, B)
  local o;
  o := ForwardOrbit(sk);
  return OrbSCCLookup(o)[Position(o, A)]
         = OrbSCCLookup(o)[Position(o, B)];
end);

# true if P \subseteq Qs for some S
# here we use a general property of partial orders that if P is related to Q
# then any P-equivalent element is related to any Q-equivalent element
InstallGlobalFunction(IsSubductionLessOrEquivalent,
function(sk, P, Q)
  local o, Pbar, Qbar;
  o := ForwardOrbit(sk);
  Pbar := OrbSCCLookup(o)[Position(o,P)];
  Qbar := OrbSCCLookup(o)[Position(o,Q)];
  return Pbar in Images(SubductionEquivClassRelation(sk), Qbar);
end);

#TODO the witness functions calculate partial orbits, this should be replaced by a search
#in the already calculated orbit

#returns an s such that P\subseteq S
InstallGlobalFunction(SubductionWitness,
function(sk, P, Q)
  local Qorb,Qs;
  if not IsSubductionLessOrEquivalent(sk,P,Q) then return fail; fi;
  Qorb := Enumerate(Orb(TransSgp(sk), Q, OnFiniteSet, rec(schreier:=true)));
  Qs := First(Qorb, Qs -> IsSubsetBlist(Qs,P));
  return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
end);

#return s such that P=Qs
InstallGlobalFunction(ImageWitness,
function(sk, P, Q)
  local Qorb,Qs;
  Qorb := Enumerate(Orb(TransSgp(sk), Q, OnFiniteSet, rec(schreier:=true)));
  Qs := First(Qorb, Qs->Qs=P);
  if Qs = fail then
    return fail;
  else
    return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
  fi;
end);

# calculating subduction equivalence classes for nonimage singletons
InstallMethod(NonImageSingletonClasses,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local l, cls, tmp,s,q, ImageOfBruteForce;
  ImageOfBruteForce := function(sk, P, Q)
    return P in Enumerate(Orb(TransSgp(sk), Q, OnFiniteSet));
  end;
  l := ShallowCopy(NonImageSingletons(sk));
  cls := [];
  while not IsEmpty(l) do
    q := Remove(l);
    tmp := [q]; #starting new class with the last one
    for s in ShallowCopy(l) do #to be on the safe side
      if ImageOfBruteForce(sk,s,q) and
         ImageOfBruteForce(sk,q,s) then
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
    parents := PreImages(SubductionEquivClassCoverRelation(sk), eqclassindx);
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
                    x->IsEmpty(Images(SubductionEquivClassCoverRelation(sk),x)));
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
# TILES, TILE CHAINS ###########################################################
################################################################################

InstallGlobalFunction(TilesOf,
function(sk,set)
  if ContainsSet(sk,set) then
    return Images(InclusionCoverRelation(sk),set);
  else
    return fail;
  fi;
end);

#all tiles of A containing B
InstallGlobalFunction(TilesContaining,
function(sk, A,B)
    return Filtered(Images(InclusionCoverRelation(sk),A),
                   x->IsSubsetBlist(x,B));
end);

# used by holonomy
InstallGlobalFunction(RandomChain,
function(sk,k)
local chain,singleton, set;
  chain := [];
  singleton := FiniteSet([k], DegreeOfSkeleton(sk));
  Add(chain,BaseSet(sk));
  set := chain[Length(chain)];
  while set <> singleton do
    Add(chain, Random(TilesContaining(sk, set, singleton)));
    set := chain[Length(chain)];
  od;
  return chain;
end);

#just counting, not constructing them
InstallGlobalFunction(NrChainsBetween,
function(sk,A,B)
local sizes, tiles;
  if A = B then return 1; fi;
  tiles := TilesContaining(sk,A,B);
  sizes := List(tiles, x -> NrChainsBetween(sk,x,B));
  return Sum(sizes);
end);


# recursively extending chain top-down from its last element to target
RecChainsBetween := function(sk,chain,target,coll)
local set,cover;
  set := chain[Length(chain)];
  if set = target then #we have a complete chain now, copy and return
    Add(coll, ShallowCopy(chain));
    return; #this copying a bit clumsy, but what can we do?
  fi;
  # recur on all covers that contain the target
  Perform(TilesContaining(sk, set, target),
          function(s)
            Add(chain, s);
            RecChainsBetween(sk, chain, target, coll);
            Remove(chain);
          end);
end;
MakeReadOnlyGlobal("RecChainsBetween");

InstallGlobalFunction(ChainsBetween,
function(sk, A,B) # A \subset B
local coll;
  coll := []; # collecting the tilechains in here
  RecChainsBetween(sk, [A], B, coll);
  return coll;
end);

InstallGlobalFunction(Chains,
function(sk)
local coll,s;
  coll := [];
  for s in Singletons(sk) do
    Append(coll, ChainsBetween(sk,BaseSet(sk),s));
  od;
  return coll;
end);

# extracts the point in the singleton element
# when called with a tile chain fragment the result is meaningless
InstallGlobalFunction(ChainRoot,
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

# just giving a dominating tile chain #TODO abstract and combine this and the next function
InstallGlobalFunction(DominatingChain,
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

InstallGlobalFunction(DominatingChains,
function(sk,chain)
  local chains, fragments;
  if IsEmpty(chain) then return fail;fi; #TODO why do we give up here?
  if chain[1] <> BaseSet(sk) then Add(chain, BaseSet(sk),1);fi;
  fragments := List([1..Size(chain)-1],
                    x->ChainsBetween(sk,chain[x],chain[x+1]));
  #removing duplicates, the in-between ones
  Perform([1..Size(fragments)-1],
          function(x)
            Perform(fragments[x],
                    function(y)Remove(y,Length(y));end);
          end);
  #now combining all together (there seems to be no sublist sharing)
  return List(EnumeratorOfCartesianProduct(fragments), Concatenation);
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
  reps := List([1..DepthOfSkeleton(sk)], i -> []); # different empty lists
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
