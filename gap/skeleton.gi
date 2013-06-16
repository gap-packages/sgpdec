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
  o := Orb(TransSgp(sk), BaseSet(sk), OnFiniteSets,
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
        "for a skeleton (SgpDec)", [IsSkeleton],
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
    l := List(TilesOf(sk,o[indx]),x->Position(o,x));
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
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return BinaryRelationByCoverFuncNC([1..Size(SkeletonTransversal(sk))],
                 x->Union(InclusionSCCCovers(sk,x),DirectSCCImages(sk,x)));
end);

#just empty lists in the beginning, built on demand
InstallMethod(PartialOrbits, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);


CalcPartialOrbitOnDemand := function(sk,Q,Qindx)
  if not IsBound(PartialOrbits(sk)[Qindx]) then
    PartialOrbits(sk)[Qindx] := Orb(TransSgp(sk), Q, OnFiniteSets,
                                 rec(schreier:=true,orbitgraph:=true));
    Enumerate(PartialOrbits(sk)[Qindx]);
  fi;
end;

InstallGlobalFunction(IsSubductionEquivalent,
function(sk, A, B)
  local o;
  o := ForwardOrbit(sk);
  return OrbSCCLookup(o)[Position(o, A)]
         = OrbSCCLookup(o)[Position(o, B)];
end);

# true is P \subseteq Qs
InstallGlobalFunction(IsSubductionLessOrEquivalent,
function(sk, P, Q)
  local Qindx;
  Qindx := Position(ForwardOrbit(sk),Q);
  CalcPartialOrbitOnDemand(sk,Q, Qindx);
  return ForAny(PartialOrbits(sk)[Qindx],
                Qs -> IsSubsetBlist(Qs,P));
end);

#TODO it is not optimal to search twice for a superset
InstallGlobalFunction(SubductionWitness,
function(sk, P, Q)
  local Qorb,Qs;
  if not IsSubductionLessOrEquivalent(sk,P,Q) then return fail; fi;
  Qorb := PartialOrbits(sk)[Position(ForwardOrbit(sk),Q)];
  Qs := First(Qorb, Qs -> IsSubsetBlist(Qs,P));
  return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
end);

#return s such that P=Qs
InstallGlobalFunction(ImageWitness,
function(sk, P, Q)
  local Qorb,Qs,Qindx;
  Qindx := Position(ForwardOrbit(sk),Q);
  CalcPartialOrbitOnDemand(sk,Q, Qindx);
  Qorb := PartialOrbits(sk)[Qindx];
  Qs := First(Qorb, Qs->Qs=P);
  if Qs = fail then
    return fail;
  else
    return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
  fi;
end);

InstallGlobalFunction(SkeletonClassOfSet,
function(sk, set)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o)[OrbSCCLookup(o)[Position(o, set)]],x-> o[x]);
end);

InstallGlobalFunction(WeakControlWords,
function(sk, X, Y)
  local Xp,Xclass;
  if IsSubsetBlist(X,Y) then
    Xp := X;
  else
    Xclass := SkeletonClassOfSet(sk,X);
    Xp := First(Xclass, XC->IsSubsetBlist(XC,Y));
  fi;
  if Xp = fail then return fail; fi;
  return [ImageWitness(sk,Xp,X), ImageWitness(sk,Y,Xp)];
end);


################################################################################
# HEIGHT, DEPTH ################################################################

InstallMethod(Heights,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local leaves, leaf, correction,o,reps,heights,depths,RecHeight;
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
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List(Heights(sk), x-> Heights(sk)[1]-x + 1);
end);

InstallMethod(DepthOfSkeleton,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return Maximum(Depths(sk));
end);


################################################################################
InstallGlobalFunction(TilesOf,
function(sk,set)
  return Images(InclusionCoverBinaryRelation(sk),set);
end);

InstallGlobalFunction(RandomTileChain,
function(sk,k)
local chain, set;
  chain := [];
  set := FiniteSet([k], DegreeOfSkeleton(sk));
  Add(chain,set);
  while set <> BaseSet(sk) do
    set := Random(PreImages(InclusionCoverBinaryRelation(sk), set));
    Add(chain,set);
  od;
  return Reversed(chain);
end);


InstallGlobalFunction(NumberOfTileChainsToSet,
function(sk,set)
local sizes, preimgs;
  if set = BaseSet(sk) then return 1; fi;
  preimgs := PreImages(InclusionCoverBinaryRelation(sk), set);
  sizes := List(preimgs, x -> NumberOfTileChainsToSet(sk,x));
  return Length(sizes)*Product(sizes); #TODO is this correct?
end);

RecAllTileChainsToSet := function(sk,chain ,coll)
local set,preimg, l;
  set := chain[Length(chain)];
  if set = BaseSet(sk) then
    l :=  ShallowCopy(chain);
    Add(coll, Reversed(l));
    return;
  fi;
  for preimg in  PreImages(InclusionCoverBinaryRelation(sk), set) do
    if preimg <> chain[Length(chain)] then
      Add(chain, preimg);
      RecAllTileChainsToSet(sk, chain, coll);
      Remove(chain);
    fi;
  od;
  return;
end;
MakeReadOnlyGlobal("RecAllTileChainsToSet");

InstallGlobalFunction(AllTileChainsToSet,
function(sk, set)
local coll;
  coll := [];
  RecAllTileChainsToSet(sk, [set], coll);
  return coll;
end);

InstallGlobalFunction(AllTileChains,
function(sk)
local coll,s;
  coll := [];
  for s in Singletons(sk) do
    Append(coll, AllTileChainsToSet(sk,s));
  od;
  return coll;
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

InstallGlobalFunction(RepresentativeSetsOnDepth,
function(sk, d)
  return List(Positions(Depths(sk), d),
              x->ForwardOrbit(sk)[SkeletonTransversal(sk)[x]]);
end);

InstallGlobalFunction(AllRepresentativeSets,
function(sk)
  return List(SkeletonTransversal(sk), x->ForwardOrbit(sk)[x]);
end);

InstallGlobalFunction(SkeletonClasses,
function(sk)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o),x->List(x, y->o[y]));
end);

InstallGlobalFunction(SkeletonClassesOnDepth,
function(sk, depth)
  local o;
  o := ForwardOrbit(sk);
  return List(OrbSCC(o){Positions(Depths(sk), depth)},
              x->List(x, y->o[y]));
end);


################################################################################
# VIZ ##########################################################################

# creating graphviz file for drawing the
InstallGlobalFunction(DotSkeleton,
function(arg)
local  str, i,label,node,out,class,classes,set,states,G,sk,params;
  #getting local variables for the arguments
  sk := arg[1];
  if IsBound(arg[2]) then
    params := arg[2];
  else
    params := rec();
  fi;
  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph skeleton{\n");
  #setting the state names
  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..999];
  fi;
  #defining the hierarchical levels - the nodes are named only by integers
  #these numbers appear on the side
  AppendTo(out, "{node [shape=plaintext]\n edge [style=invis]\n");
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out,Concatenation(String(i),"\n"));
    if i <= DepthOfSkeleton(sk) then
      AppendTo(out,Concatenation(String(i),"->",String(i+1),"\n"));
    fi;
  od;
  AppendTo(out,"}\n");
  #drawing equivalence classes
  classes :=  SkeletonClasses(sk);
  for i in [1..Length(classes)] do
    AppendTo(out,"subgraph cluster",String(i),"{\n");
    for node in classes[i] do
      AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
    od;
    AppendTo(out,"color=\"black\";");
    if DepthOfSet(sk, node) < DepthOfSkeleton(sk) then
      G := HolonomyGroup@(sk, node);
      if not IsTrivial(G) then
        AppendTo(out,"style=\"filled\";fillcolor=\"lightgrey\";");
        if SgpDecOptionsRec.SMALL_GROUPS then
          label := StructureDescription(G);
        else
          label:= "";
        fi;
        AppendTo(out,"label=\"",label,"\"  }\n");
      else
        AppendTo(out,"  }\n");
      fi;
    else
      AppendTo(out,"  }\n");
    fi;
  od;
  #drawing the the same level elements
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out, "{rank=same;",String(i),";");
    for class in SkeletonClassesOnDepth(sk,i) do
      for node in class do
        AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
      od;
    od;
    AppendTo(out,"}\n");
  od;
  #singletons
  AppendTo(out, "{rank=same;",String(DepthOfSkeleton(sk)),";");
  for node in Singletons(sk) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
  od;
  AppendTo(out,"}\n");
  #drawing the representatives as rectangles and their covers
  for class in AllRepresentativeSets(sk) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class),
            "\" [shape=box,color=black];\n");
    for set in TilesOf(sk,class) do
      AppendTo(out,"\"",TrueValuePositionsBlistString(class),
              "\" -> \"",TrueValuePositionsBlistString(set),"\"\n");
    od;
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
