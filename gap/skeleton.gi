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
  SetIsHasseDiagram(h, true);
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
  pos := Position(orderedsubsets, set) - 1;
  while pos > 0 do
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
    pos := pos - 1;
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
      if sk.height[p] < height+1 then
        sk.height[p] := height+1;
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
  sk.height := ListWithIdenticalEntries(Size(sk.reps), 0);
  #we start chains from the elements with no children
  leaves := Filtered([1..Length(sk.reps)],
                    x->IsEmpty(Images(sk.geninclusionHD,x)));
  for leaf in leaves do
    if IsSingleton(sk.orb[sk.reps[leaf]]) then
      correction:=0;#there is a singleton image, so no correction needed
      sk.height[leaf] := 0;
      RecHeight(sk,leaf,0);
    else
      sk.height[leaf] := 1;
      RecHeight(sk,leaf,1);
    fi;
  od;
  height := sk.height[1];
  #calculating depth based on upside down height
  sk.depths  := List(sk.height, x-> height-x + 1);
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
  tmpl := List(CoveringSetsOf(sk,sk.orb[indx]),x->Position(sk.orb,x));
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
BySizeSorterAscend := function(v,w)
if Size(v) <> Size(w) then
  return Size(v)<Size(w);
else
  return v<w;
fi;
end;
MakeReadOnlyGlobal("BySizeSorterAscend");

InstallMethod(Skeleton,[IsTransformationSemigroup],
function(ts)
local sk;
  sk := rec(ts:=ts,
            degree:=DegreeOfTransformationSemigroup(ts)
            );
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
  sk.sets := ShallowCopy(AsSet(List(sk.orb))); #to make it mutable
  #and a set, this is a bit crazy, so it should be checked
  #maybe ordering the other way around would be more efficient

  #augmenting with the state set and the singletons
  AddSet(sk.sets,sk.stateset);
  Perform(sk.singletons, function(y) AddSet(sk.sets,y);end);
  #now sorting properly TODO try to avoid double sorting
  Sort(sk.sets,BySizeSorterAscend);
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

InstallGlobalFunction(IsEquivalent,
function(sk, A, B)
  return OrbSCCLookup(sk.orb)[Position(sk.orb, A)]
         = OrbSCCLookup(sk.orb)[Position(sk.orb, B)];
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
    sk.IN[pos] := Construct(GetINw(sk,A), sk.gens, sk.id, \*);
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
    out := Construct(outw, sk.gens, sk.id, \*);
    inw := GetINw(sk,A);
    #now doing it properly (Lemma 5.9. in ENA PhD thesis)
    #TODO a hardcoded limit, figure out why PositiveIntegers does not work!
    n := First([1..2147483648],
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
    sk.OUT[pos] := Construct(GetOUTw(sk,A), sk.gens, sk.id, \*);
  fi;
  return sk.OUT[pos];
end);

################################################################################

InstallGlobalFunction(CoveringSetsOf,
function(sk,A)
  return Images(sk.inclusionHD,A);
end);

InstallGlobalFunction(RandomCoverChain,
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


InstallGlobalFunction(NumberOfCoverChainsToSet,
function(sk,set)
local sizes, preimgs;
  if set = sk.stateset then return 1; fi;
  preimgs := PreImages(sk.inclusionHD, set);
  sizes := List(preimgs, x -> NumberOfCoverChainsToSet(sk,x));
  return Length(sizes)*Product(sizes);
end);

RecAllCoverChainsToSet := function(sk,chain ,coll, relation)
local set,preimg, l;
  set := chain[Length(chain)];
  if set = sk.stateset then
    l :=  ShallowCopy(chain);
    Remove(l);# we don't need the top
    Add(coll, Reversed(l));
    return;
  fi;
  for preimg in  PreImages(relation, set) do
    if preimg <> chain[Length(chain)] then
      Add(chain, preimg);
      RecAllCoverChainsToSet(sk, chain, coll,relation);
      Remove(chain);
    fi;
  od;
  return;
end;
MakeReadOnlyGlobal("RecAllCoverChainsToSet");

InstallGlobalFunction(AllCoverChainsToSet,
function(sk, set)
local coll;
  coll := [];
  RecAllCoverChainsToSet(sk, [set], coll, sk.inclusionHD);
  return coll;
end);

InstallGlobalFunction(AllCoverChains,
function(sk)
local coll,i;
  coll := [];
  for i in [1..sk.degree] do
    Append(coll, AllCoverChainsToSet(sk, FiniteSet([i],sk.degree)));
  od;
  return coll;
end);

InstallGlobalFunction(Permutators,
function(sk,set)
local permutators,i,j,nset,scc,word;
  permutators := [];
  Sort(permutators);

  scc := List(OrbSCC(sk.orb)[OrbSCCLookup(sk.orb)[Position(sk.orb, set)]],
              x->sk.orb[x]);
  #for all elements of the equivalence class of the set
  for i in [1..Length(scc)] do
    #for all generators
    for j in [1..Length(sk.gens)] do
      #we hit an element in the class by a generator
      nset := OnFiniteSets(scc[i],sk.gens[j]);
      #if it stays in the class then it will give rise to a permutator
      if nset in scc then #this could be optimized TODO
        word :=  Concatenation(GetINw(sk,scc[i]),[j],GetOUTw(sk,nset));
        if not (word in permutators) then
          Add(permutators, word, PositionSorted(permutators, word));
        fi;
      fi;
    od;
  od;
  #conjugation here
  permutators := List(permutators,
                      x -> Concatenation(GetOUTw(sk,set), x, GetINw(sk,set)));
  if SgpDecOptionsRec.STRAIGHTWORD_REDUCTION then
    #reducing on sets yield alien actions
    permutators := List(permutators,
                        x -> Reduce2StraightWord(x, sk.gens, sk.id));
    # straightening may introduce duplicates
    permutators := DuplicateFreeList(permutators);
  fi;
  return permutators;
end);

InstallGlobalFunction(PermutatorGenerators,
function(sk,set)
  return Filtered(Permutators(sk,set),
                 x -> not (IsIdentityOnFiniteSet(
                         Construct(x, sk.gens, sk.id,\*) ,set)));
end);

InstallGlobalFunction(CoverGroup,
function(sk,set)
local gens;
  gens := AsSet(List(List(PermutatorGenerators(sk,set),
                  x->Construct(x, sk.gens, sk.id,\*)),
                  x->PermList(ActionOn(CoveringSetsOf(sk,set),x,OnFiniteSets)))
                );
  if IsEmpty(gens) then gens := [()]; fi;
  return Group(gens);
end);

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
  return sk.height[OrbSCCLookup(sk.orb)[Position(sk.orb,A)]];
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

################################################################################
# VIZ ##########################################################################

# creating graphviz file for drawing the
InstallGlobalFunction(DotSkeleton,
function(sk,params)
local  str, i,label,node,out,class,classes,set,states,G;

  str := "";
  out := OutputTextString(str,true);
  PrintTo(out,"digraph skeleton{\n");

  if "states" in RecNames(params) then
    states := params.states;
  else
    states := [1..999];
  fi;

  #defining the hierarchical levels - the nodes are named only by integers
  AppendTo(out, "{node [shape=plaintext]\n edge [style=invis]\n");
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out,Concatenation(StringPrint(i),"\n"));
    if i <= DepthOfSkeleton(sk) then
      AppendTo(out,Concatenation(StringPrint(i),"->",StringPrint(i+1),"\n"));
    fi;
  od;
  AppendTo(out,"}\n");
  #drawing equivalence classes
  classes :=  SkeletonClasses(sk);
  for i in [1..Length(classes)] do
    AppendTo(out,"subgraph cluster",StringPrint(i),"{\n");
    for node in classes[i] do
      AppendTo(out,"\"",FiniteSetPrinter(node,states),"\";");
    od;
    AppendTo(out,"color=\"black\";");
    if DepthOfSet(sk, node) < DepthOfSkeleton(sk) then
      G := CoverGroup(sk, node);
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
  for i in [1..DepthOfSkeleton(sk)] do
    AppendTo(out, "{rank=same;",StringPrint(i),";");
    for class in SkeletonClassesOnDepth(sk,i) do
      for node in class do
            AppendTo(out,"\"",FiniteSetPrinter(node,states),"\";");
     od;
    od;
    AppendTo(out,"}\n");
  od;
  #drawing the representatives as rectangles and their covers
  for class in AllRepresentativeSets(sk) do
    AppendTo(out,"\"",FiniteSetPrinter(class,states),
            "\" [shape=box,color=black];\n");
    for set in CoveringSetsOf(sk, class) do
      AppendTo(out,"\"",FiniteSetPrinter(class,states),
              "\" -> \"",FiniteSetPrinter(set,states),"\"\n");
      od;
    od;
    AppendTo(out,"}\n");
    CloseStream(out);
    return str;
end);