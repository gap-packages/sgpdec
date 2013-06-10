################################################################################
# util wrapping function for the often called BuildByWords
# to fend off likely future changes
EvalWordInSkeleton := function(sk, w)
  return BuildByWord(w, sk.gens, sk.id, OnRight);
end;
MakeReadOnlyGlobal("EvalWordInSkeleton");

################################################################################
##Functions for calculating the Hasse diagram of relations on the set of subsets

# adapted from GAPlib, it creates a Hasse diagram given a function
# which calculates the covering elements for each elements in the set
# TODO it is used only for Images and PreImages calc in the constructor
# slated fro removal
HasseDiagramByCoverFuncNC := function(set, coverfunc)
local i,j,dom,tups,h;
  dom := Domain(set);
  tups := [];
  for i in dom do
    for j in coverfunc(i) do
      Add(tups, Tuple([i, j]));
    od;
  od;
  h := GeneralMappingByElements(dom,dom, tups);
  #SetIsHasseDiagram(h, true);
  return h;
end;
MakeReadOnlyGlobal("HasseDiagramByCoverFuncNC");

# returns the covering subsets of the given set
# the whole set of sets needs to be ordered, as the code is somewhat optimized
#TODO can this be further improved by recursion
CoveringSubsets := function(set, orderedsubsets)
local covers, pos, flag,s;
  #singletons have no covers
  if Size(set) = 1 then return []; fi;
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
MakeReadOnlyGlobal("CoveringSubsets");

HasseDiagramOfSubsets := function(orderedsubsets)
  return HasseDiagramByCoverFuncNC(orderedsubsets,
                 set->CoveringSubsets(set, orderedsubsets));
end;
MakeReadOnlyGlobal("HasseDiagramOfSubsets");

################################################################################
#### HEIGHT AND DEPTH CALCULATION###############################################

#height calculation is needed before depth
RecHeight := function(sk, eqclassindx ,height)
local p,parents;
  parents := PreImages(sk.geninclusionHD, eqclassindx);
  for p in parents do
    if not IsSingleton(sk.orb[sk.reps[p]]) then #if it is not a singleton
      if sk.heights[p] < height+1 then
        sk.heights[p] := height+1;
        #only call when the height is raised (this saves a lot of calls)
        RecHeight(sk,p,height+1);
      fi;
    fi;
  od;
end;
MakeReadOnlyGlobal("RecHeight");

DepthCalc := function(sk)
  local leaves, leaf, height, correction;
  #If there is no singleton image, then we need to add one to the depth
  correction := 1;
  sk.heights := ListWithIdenticalEntries(Size(sk.reps), 0);
  #we start chains from the elements with no children
  leaves := Filtered([1..Length(sk.reps)],
                    x->IsEmpty(Images(sk.geninclusionHD,x)));
  for leaf in leaves do
    if IsSingleton(sk.orb[sk.reps[leaf]]) then
      correction:=0;#there is a singleton image, so no correction needed
      sk.heights[leaf] := 0;
      RecHeight(sk,leaf,0);
    else
      sk.heights[leaf] := 1;
      RecHeight(sk,leaf,1);
    fi;
  od;
  height := sk.heights[1];
  #calculating depth based on upside down height
  sk.depths  := List(sk.heights, x-> height-x + 1);
  sk.depth := Maximum(sk.depths) + correction;
end;
MakeReadOnlyGlobal("DepthCalc");

################################################################################

# indx - the index of an orbit element
DirectImagesReps := function(sk,indx)
local l, rep;
  l := [];
  Perform(sk.orb!.orbitgraph[indx],
          function(x) AddSet(l, OrbSCCLookup(sk.orb)[x]);end);
  rep := OrbSCCLookup(sk.orb)[indx];
  if rep in l then Remove(l, Position(l,rep));fi;
  return l;
end;
MakeReadOnlyGlobal("DirectImagesReps");

# indx - the index of an orbit element
InclusionCoverReps := function(sk,indx)
local l, rep, tmpl,i;
  #convert the image sets into their indices
  tmpl := List(TilesOf(sk.orb[indx],sk),x->Position(sk.orb,x));
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
MakeReadOnlyGlobal("InclusionCoverReps");

#collecting the direct images and inclusion covers of an SCC
#thus building the generalized inclusion covers
CoversOfSCC := function(sk, sccindx)
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
MakeReadOnlyGlobal("CoversOfSCC");

################################################################################
###CONSTRUCTOR##################################################################

#for sorting finitesets, first by size, then by content
DescendingSizeSorter := function(v,w)
  if Size(v) <> Size(w) then
    return Size(v)>Size(w);
  else
    return v<w;
  fi;
end;
MakeReadOnlyGlobal("DescendingSizeSorter");

InstallGlobalFunction(Skeleton,
function(ts)
local sk;
  sk := rec(ts:=ts,
            degree:=DegreeOfTransformationSemigroup(ts));
  sk.gens := Generators(ts);
  sk.id := IdentityTransformation(sk.degree);
  sk.stateset := FiniteSet([1..sk.degree]);
  sk.singletons := List([1..sk.degree], x->FiniteSet([x],sk.degree));
  sk.orb := Orb(ts, sk.stateset, OnFiniteSets,
                rec(schreier:=true,orbitgraph:=true));
  Enumerate(sk.orb);
  OrbSCC(sk.orb);
  #default choice for representatives - the first element
  sk.reps := List(OrbSCC(sk.orb), x->x[1]);
  #the imagesets explicitly in a list
  sk.sets := List(sk.orb);
  #augmenting with the state set and the singletons
  if not (sk.stateset in sk.orb) then
    Add(sk.sets,sk.stateset,1);
  fi;
  Perform(sk.singletons,
          function(y)
            if not(y in sk.orb) then
              Add(sk.sets,y);
            fi;
          end);
  #now sorting descending by size (natural for the orbit)
  Sort(sk.sets,DescendingSizeSorter);
  sk.inclusionHD := HasseDiagramOfSubsets(sk.sets);
  sk.geninclusionHD := HasseDiagramByCoverFuncNC([1..Length(sk.reps)],
                               x->CoversOfSCC(sk,x));
  #calculating depth
  DepthCalc(sk);
  #setting empty cache for INs and OUTs
  sk.IN := [];
  sk.INw := [];
  sk.OUT := [];
  sk.OUTw := [];
  #TODO bit a of a hack to calculate subduction
  #we keep here the orbits from points
  #the first is the state set itself for sure, the rest will be calced on demand
  sk.partialorbs := [sk.orb];
  return sk;
end);

################################################################################

#returns the representative element of the scc of a finiteset
InstallGlobalFunction(RepresentativeSet,
function(sk, finiteset)
  return sk.orb[sk.reps[OrbSCCLookup(sk.orb)[Position(sk.orb, finiteset)]]];
end);

InstallGlobalFunction(RepresentativesOnDepth,
function(sk, d)
  return List(Positions(sk.depths, d), x->sk.orb[sk.reps[x]]);
end);

InstallGlobalFunction(AllRepresentativeSets,
function(sk)
  return List(sk.reps, x->sk.orb[x]);
end);

#changes the representative element to the given finite set
#in the corresponding scc
InstallGlobalFunction(ChangeRepresentativeSet,
function(sk, finiteset)
local pos;
  pos := Position(sk.orb, finiteset);
  sk.reps[OrbSCCLookup(sk.orb)[pos]] := pos;
  #we need to empty the cache for INs and OUTs
  #TODO make this more specific, just empty
  sk.IN := [];
  sk.INw := [];
  sk.OUT := [];
  sk.OUTw := [];
end);

InstallGlobalFunction(IsSubductionEquivalent,
function(sk, A, B)
  return OrbSCCLookup(sk.orb)[Position(sk.orb, A)]
         = OrbSCCLookup(sk.orb)[Position(sk.orb, B)];
end);

# true is P \subseteq Qs
InstallGlobalFunction(IsSubductionRelated,
function(sk, P, Q)
  local Qindx;
  Qindx := Position(sk.orb,Q);
  if not IsBound(sk.partialorbs[Qindx]) then
    sk.partialorbs[Qindx] := Orb(sk.ts, Q, OnFiniteSets,
                                 rec(schreier:=true,orbitgraph:=true));
    Enumerate(sk.partialorbs[Qindx]);
  fi;
  return ForAny(sk.partialorbs[Qindx],
                Qs -> IsSubsetBlist(Qs,P));
end);

#TODO it is not optimal to search twice for a superset
InstallGlobalFunction(SubductionWitness,
function(sk, P, Q)
  local Qorb,Qs;
  if not IsSubductionRelated(sk,P,Q) then return fail; fi;
  Qorb := sk.partialorbs[Position(sk.orb,Q)];
  Qs := First(Qorb, Qs -> IsSubsetBlist(Qs,P));
  return TraceSchreierTreeForward(Qorb, Position(Qorb,Qs));
end);


################################################################################
### INs and OUTs with a primitive caching method to avoid double calculation ###

#returns the word  that takes the representative
#to the set A - so a path that goes INto A
InstallGlobalFunction(GetINw,
function(sk, A)
local pos, scc;
  pos := Position(sk.orb, A);
  if not IsBound(sk.INw[pos]) then
    scc := OrbSCCLookup(sk.orb)[pos];
    sk.INw[pos] := Concatenation(
                           TraceSchreierTreeOfSCCBack(sk.orb,scc,sk.reps[scc]),
                           TraceSchreierTreeOfSCCForward(sk.orb, scc, pos));
  fi;
  return sk.INw[pos];
end);

InstallGlobalFunction(GetIN,
function(sk, A)
local pos;
  pos := Position(sk.orb, A);
  if not IsBound(sk.IN[pos]) then
    sk.IN[pos] := EvalWordInSkeleton(sk, GetINw(sk,A));
  fi;
  return sk.IN[pos];
end);

#returns the word  that takes A to its representative
# i.e. the route OUT from A
InstallGlobalFunction(GetOUTw,
function(sk, A)
local pos, scc, n, outw, fg, inw, out,l;
  pos := Position(sk.orb, A);
  if not IsBound(sk.OUTw[pos]) then
    scc := OrbSCCLookup(sk.orb)[pos];
    outw :=  Concatenation(TraceSchreierTreeOfSCCBack(sk.orb, scc, pos),
                     TraceSchreierTreeOfSCCForward(sk.orb, scc, sk.reps[scc]));
    out := EvalWordInSkeleton(sk, outw);
    inw := GetINw(sk,A);
    #now doing it properly (Lemma 5.9. in ENA PhD thesis)
    n := First(PositiveIntegers,
               x-> IsIdentityOnFiniteSet( (GetIN(sk,A) * out)^(x+1),
                       RepresentativeSet(sk,A)));
    l := [];
    Add(l, outw);
    fg := Flat([inw,outw]);
    Add(l, ListWithIdenticalEntries(n,fg));
    sk.OUTw[pos] := Flat(l);
  fi;
  return sk.OUTw[pos];
end);

InstallGlobalFunction(GetOUT,
function(sk, A)
local pos;
  pos := Position(sk.orb, A);
  if not IsBound(sk.OUT[pos]) then
    sk.OUT[pos] := EvalWordInSkeleton(sk,GetOUTw(sk,A));
  fi;
  return sk.OUT[pos];
end);

################################################################################

InstallGlobalFunction(TilesOf,
function(A,sk)
  return Images(sk.inclusionHD,A);
end);

InstallGlobalFunction(RandomTileChain,
function(sk,k)
local chain, set, topset;
  chain := [];
  set := FiniteSet([k], sk.degree);
  Add(chain,set);
  while set <> sk.stateset do
    set := Random(PreImages(sk.inclusionHD, set));
    Add(chain,set);
  od;
  Remove(chain);#TODO quick hack - we don't need the full set in the chain
  return Reversed(chain);
end);


InstallGlobalFunction(NumberOfTileChainsToSet,
function(sk,set)
local sizes, preimgs;
  if set = sk.stateset then return 1; fi;
  preimgs := PreImages(sk.inclusionHD, set);
  sizes := List(preimgs, x -> NumberOfTileChainsToSet(sk,x));
  return Length(sizes)*Product(sizes);
end);

RecAllTileChainsToSet := function(sk,chain ,coll, relation)
local set,preimg, l;
  set := chain[Length(chain)];
  if set = sk.stateset then
    l :=  ShallowCopy(chain);
    #Remove(l);# we don't need the top
    Add(coll, Reversed(l));
    return;
  fi;
  for preimg in  PreImages(relation, set) do
    if preimg <> chain[Length(chain)] then
      Add(chain, preimg);
      RecAllTileChainsToSet(sk, chain, coll,relation);
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
  RecAllTileChainsToSet(sk, [set], coll, sk.inclusionHD);
  return coll;
end);

InstallGlobalFunction(AllTileChains,
function(sk)
local coll,i;
  coll := [];
  for i in [1..sk.degree] do
    Append(coll, AllTileChainsToSet(sk, FiniteSet([i],sk.degree)));
  od;
  return coll;
end);

################################################################################
### PERMUTATOR #################################################################
################################################################################
#roundtrips from the representative conjugated to the given set
InstallGlobalFunction(RoundTripWords,
function(sk,set)
local roundtrips,i,j,nset,scc,word;
  roundtrips := [];

  #we grab the equivalence class of the set, its strongly connected component
  scc := List(OrbSCC(sk.orb)[OrbSCCLookup(sk.orb)[Position(sk.orb, set)]],
              x->sk.orb[x]);
  Sort(scc); #for quicker lookup
  #for all elements of the equivalence class of the set
  for i in [1..Length(scc)] do
    #for all generators
    for j in [1..Length(sk.gens)] do
      #we hit an element in the class by a generator
      nset := OnFiniteSets(scc[i],sk.gens[j]);
      #if it stays in the class then it will give rise to a permutator
      if nset in scc then
        word :=  Concatenation(GetINw(sk,scc[i]),[j],GetOUTw(sk,nset));
        AddSet(roundtrips, word);
      fi;
    od;
  od;
  #conjugation here - we have to relocate the roundtrips to the set
  roundtrips := List(roundtrips,
                      x -> Concatenation(GetOUTw(sk,set), x, GetINw(sk,set)));
  if SgpDecOptionsRec.STRAIGHTWORD_REDUCTION then
    #reducing on sets yield alien actions
    roundtrips := List(roundtrips,
                        x -> Reduce2StraightWord(x, sk.gens, sk.id, \*));
    # straightening may introduce duplicates #TODO Does it really?
    roundtrips := DuplicateFreeList(roundtrips);
  fi;
  return roundtrips;
end);

InstallGlobalFunction(NontrivialRoundTripWords,
function(sk,set)
local roundtrips,rtws,nontrivs;
  rtws := RoundTripWords(sk,set);
  roundtrips := List(rtws, w->EvalWordInSkeleton(sk,w));
  nontrivs := Filtered([1..Size(roundtrips)],
                      x->not IsIdentityOnFiniteSet(roundtrips[x],set));
  Info(SkeletonInfoClass, 2, "Nonidentity roundtrips/all roundtrips: ",
       Size(rtws), "/", Size(nontrivs));
  return rtws{nontrivs};
end);

#TODO this is brute force! any other idea?
InstallGlobalFunction(PermutatorSemigroupElts,
function(sk,set)
local permutators, transformation;
  permutators := [];
  for transformation in sk.ts do
    if OnFiniteSets(set,transformation) = set then
      Add(permutators, transformation);
    fi;
  od;
  return permutators;
end);

InstallGlobalFunction(PermutatorGroup,
function(sk,set)
local permgens,gens,n, permgenwords;
  permgens := List(NontrivialRoundTripWords(sk,set),
                   w -> EvalWordInSkeleton(sk,w));
  gens := AsSet(List(permgens,
                  t -> AsPermutation(
                          RestrictedTransformation(t,
                                  ListBlist([1..Size(set)],set)))));
  Info(SkeletonInfoClass, 2,
       "Permutator group generators/nonidentity roundtrips: ",
       Size(gens), "/", Size(permgens));
  if IsEmpty(gens) then
    return Group(());
  else
    return Group(gens);
  fi;
end);

InstallGlobalFunction(PermutatorHolonomyHomomorphism,
function(sk,set)
  local permgroup,imggens,homgens;
  permgroup := PermutatorGroup(sk,set);
  imggens := List(GeneratorsOfGroup(permgroup),
                  g->AsPermutation(
                          TransformationOp(g,
                                  TilesOf(set,sk),
                                  OnFiniteSets)));
  homgens := DuplicateFreeList(imggens);
  return GroupHomomorphismByImages(permgroup,
                 Group(homgens),
                 GeneratorsOfGroup(permgroup),
                 imggens);
end);

InstallGlobalFunction(HolonomyGroup@,
function(sk,set)
  return Image(PermutatorHolonomyHomomorphism(sk,set));
end);

################################################################################
InstallGlobalFunction(DepthOfSkeleton,
function(sk)
  return sk.depth;
end);

InstallGlobalFunction(DepthOfSet,
function(sk,A)
  if IsSingleton(A) then return sk.depth; fi;
  return sk.depths[OrbSCCLookup(sk.orb)[Position(sk.orb,A)]];
end);

InstallGlobalFunction(HeightOfSet,
function(sk,A)
  if IsSingleton(A) then return 0; fi;
  return sk.heights[OrbSCCLookup(sk.orb)[Position(sk.orb,A)]];
end);

InstallGlobalFunction(TopSet,
function(sk)
  return sk.stateset;
end);

InstallGlobalFunction(ImageSets,
function(sk)
  return AsList(sk.orb);
end);

InstallGlobalFunction(SkeletonClasses,
function(sk)
  return List(OrbSCC(sk.orb),
              x->List(x, y->sk.orb[y]));
end);

InstallGlobalFunction(SkeletonClassesOnDepth,
function(sk, depth)
  return List(OrbSCC(sk.orb){Positions(sk.depths, depth)},
              x->List(x, y->sk.orb[y]));
end);

InstallGlobalFunction(SkeletonClassOfSet,
function(sk, set)
  return List(OrbSCC(sk.orb)[OrbSCCLookup(sk.orb)[Position(sk.orb, set)]],
              x-> sk.orb[x]);
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
  for node in sk.singletons do
    AppendTo(out,"\"",TrueValuePositionsBlistString(node),"\";");
  od;
  AppendTo(out,"}\n");
  #drawing the representatives as rectangles and their covers
  for class in AllRepresentativeSets(sk) do
    AppendTo(out,"\"",TrueValuePositionsBlistString(class),
            "\" [shape=box,color=black];\n");
    for set in TilesOf(class,sk) do
      AppendTo(out,"\"",TrueValuePositionsBlistString(class),
              "\" -> \"",TrueValuePositionsBlistString(set),"\"\n");
    od;
  od;
  AppendTo(out,"}\n");
  CloseStream(out);
  return str;
end);
