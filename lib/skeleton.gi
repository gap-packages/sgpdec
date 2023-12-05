#############################################################################
##
## skeleton.gi           SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Skeleton of the semigroup action on a set. Subduction relation,
## equivalence classes.
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

# the image set extended with singletons and ordered by descending size
# we only need to add non-image singletons, as the base set is in the orbit
InstallMethod(ExtendedImageSet, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  local extimgs;
  extimgs := HashSet();
  Perform(ForwardOrbit(sk), function(A) AddSet(extimgs,A);end);
  #add the missing singletons
  Perform(NonImageSingletons(sk), function(A) AddSet(extimgs,A);end);
  return extimgs;
end);

#just to give a nice descending view of the sets
InstallGlobalFunction(SortedExtendedImageSet,
function(sk)
local sets;
  sets := ShallowCopy(AsSet(ExtendedImageSet(sk)));
  Sort(sets,FiniteSetComparator);
  return sets;
end);

################################################################################
# INCLUSION RELATION ###########################################################
################################################################################

# returns the maximal subsets of the given set found in the given ordered set
# of sets, for the skeleton the extended set of images
#TODO this was removed and added back as general HasseDiagramBinary Relation is slow
MaximalSubsets := function(sk, set)
local covers, pos, orderedsubsets;
  #singletons have no covers
  if SizeBlist(set) = 1 then return []; fi;
  covers := [];
  #we search only from this position in the descending order
  orderedsubsets := SortedExtendedImageSet(sk);
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

InstallMethod(InclusionCoverRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  # return HasseDiagramBinaryRelation( #this is super slow!
  #         PartialOrderByOrderingFunction(Domain(AsSet(ExtendedImageSet(sk))),
  #                                        IsSubsetBlist));
  return BinaryRelationByCoverFuncNC(SortedExtendedImageSet(sk),
                                     set->MaximalSubsets(sk,set));
end);

################################################################################
# SUBDUCTION ###################################################################
################################################################################

ComputeSubductionEquivClassRelation :=
function(sk)
  local o, SCCLookup, SCCOf, DirectImages, NonFailing, Set2Index, SubSets, reps, imgs, subs, l;
  o := ForwardOrbit(sk);
  # functions are defined for better readability and separating technical (Orb) code
  SCCLookup := x -> OrbSCCLookup(o)[x]; #finds SCC of an orbit element (the index of it)
  SCCOf := x -> OrbSCC(o)[SCCLookup(x)]; #finds the SCC and return the whole class
  DirectImages := x -> Union(List(SCCOf(x),  y -> OrbitGraph(o)[y])); #direct descendants in the orbit graph
  NonFailing := x -> x <> fail; #predicate function for not being fail
  Set2Index := x -> Position(o,x);
  SubSets := x -> Union(List(SCCOf(x), y -> Images(InclusionCoverRelation(sk),o[y])));
  #subduction is image of and subset of relation combined, computed for the representatives
  reps := SkeletonTransversal(sk);
  imgs := List(reps, DirectImages); #direct images of representatives
  subs := List(reps, rep -> Filtered( List(SubSets(rep),Set2Index), NonFailing));
  l := List([1..Size(reps)], i -> Union(imgs[i], subs[i])); #TODO not a union! 
  return BinaryRelationOnPoints(List(l, z -> Unique(List(z, SCCLookup)))); #TODO what is missing from this to be the cover relation?
end;

#the subduction Hasse diagram of representatives
InstallMethod(SubductionEquivClassRelation,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
return TransitiveClosureBinaryRelation(
           ReflexiveClosureBinaryRelation(
             ComputeSubductionEquivClassRelation(sk)));
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
################################################################################
InstallMethod(Heights, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
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
  #singleton leaves have height 0, others 1
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
end);

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

#returns a new skeleton where set A becomes a representative of its own class
InstallGlobalFunction(MakeRepresentative,
function(sk, A)
  local newsk, ts, tr, Aindex, SCCindex,o;
  #creating a new transversal
  o := ForwardOrbit(sk);
  Aindex := Position(o,A);
  if (Aindex = fail) then return fail; fi;
  SCCindex := OrbSCCLookup(o)[Aindex];
  tr := ShallowCopy(SkeletonTransversal(sk));
  tr[SCCindex]:=Aindex;
  MakeImmutable(tr);
  #creating a new skeleton object, setting the attributes not dependent on the reps
  ts:=TransSgp(sk);
  newsk := Objectify(SkeletonType, rec());
  SetTransSgp(newsk,ts);
  SetGenerators(newsk,Generators(ts));
  SetDegreeOfSkeleton(newsk,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(newsk, BaseSet(sk));
  SetForwardOrbit(newsk,o);
  SetExtendedImageSet(newsk, ExtendedImageSet(sk));
  SetSubductionEquivClassCoverRelation(newsk,
                                       SubductionEquivClassCoverRelation(sk));
  SetSubductionEquivClassRelation(newsk,
                                  SubductionEquivClassRelation(sk));
  SetInclusionCoverRelation(newsk, InclusionCoverRelation(sk));
  #setting the new transversal
  SetSkeletonTransversal(newsk,tr);
  return newsk;
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
