################################################################################
### INs and OUTs with a primitive caching method to avoid double calculation ###

#just empty lists in the beginning, built on demand
InstallMethod(InMaps, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(InWords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(OutMaps, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);

InstallMethod(OutWords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk) return []; end);


#returns the word  that takes the representative
#to the set A - so a path that goes INto A
InstallGlobalFunction(GetINw,
function(sk, A)
local pos, scc,o;
  o := ForwardOrbit(sk);
  pos := Position(o, A);
  if not IsBound(InWords(sk)[pos]) then
    scc := OrbSCCLookup(o)[pos];
    InWords(sk)[pos] :=
      Concatenation(
              TraceSchreierTreeOfSCCBack(o,scc,SkeletonTransversal(sk)[scc]),
              TraceSchreierTreeOfSCCForward(o, scc, pos));
  fi;
  return InWords(sk)[pos];
end);

InstallGlobalFunction(GetIN,
function(sk, A)
local pos;
  pos := Position(ForwardOrbit(sk), A);
  if not IsBound(InMaps(sk)[pos]) then
    InMaps(sk)[pos] := EvalWordInSkeleton(sk, GetINw(sk,A));
  fi;
  return InMaps(sk)[pos];
end);

#returns the word  that takes A to its representative
# i.e. the route OUT from A
InstallGlobalFunction(GetOUTw,
function(sk, A)
local pos, scc, n, outw, fg, inw, out,l,o;
  o := ForwardOrbit(sk);
  pos := Position(o, A);
  if not IsBound(OutWords(sk)[pos]) then
    scc := OrbSCCLookup(o)[pos];
    outw :=
      Concatenation(
              TraceSchreierTreeOfSCCBack(o, scc, pos),
              TraceSchreierTreeOfSCCForward(o,scc,
                      SkeletonTransversal(sk)[scc]));
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
    OutWords(sk)[pos] := Flat(l);
  fi;
  return OutWords(sk)[pos];
end);

InstallGlobalFunction(GetOUT,
function(sk, A)
local pos;
  pos := Position(ForwardOrbit(sk), A);
  if not IsBound(OutMaps(sk)[pos]) then
    OutMaps(sk)[pos] := EvalWordInSkeleton(sk,GetOUTw(sk,A));
  fi;
  return OutMaps(sk)[pos];
end);

################################################################################
### PERMUTATOR #################################################################
################################################################################
#roundtrips from the representative conjugated to the given set
InstallGlobalFunction(RoundTripWords,
function(sk,set)
local roundtrips,i,j,nset,scc,word,o;
  o := ForwardOrbit(sk);
  roundtrips := [];

  #we grab the equivalence class of the set, its strongly connected component
  scc := List(OrbSCC(o)[OrbSCCLookup(o)[Position(o, set)]],x->o[x]);
  Sort(scc); #for quicker lookup
  #Print(set, " " , scc, "\n");
  #for all elements of the equivalence class of the set
  for i in [1..Length(scc)] do
    #for all generators #TODO do this with orbitgraph
    for j in [1..Length(Generators(sk))] do
      #we hit an element in the class by a generator
      nset := OnFiniteSets(scc[i],Generators(sk)[j]);
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
                       x -> Reduce2StraightWord(x,
                               Generators(sk),
                               (),
                               \*));
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
  for transformation in TransSgp(sk) do
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

################################################################################
# HOLONOMY GROUPS ##############################################################
################################################################################
InstallGlobalFunction(PermutatorHolonomyHomomorphism,
function(sk,set)
  local permgroup,imggens,homgens;
  permgroup := PermutatorGroup(sk,set);
  imggens := List(GeneratorsOfGroup(permgroup),
                  g->AsPermutation(
                          TransformationOp(g,
                                  TilesOf(sk,set),
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

InstallMethod(GroupComponents, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local d,groups;
  groups := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    Add(groups,
        List(RepresentativeSets(sk)[d],
             rep -> HolonomyGroup@(sk, rep)));
  od;
  return groups;
end);

InstallMethod(TileCoords, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local d,coords,l,rep;
  coords := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    l := [];
    for rep in RepresentativeSets(sk)[d] do
      Add(l,TilesOf(sk, rep));
    od;
    Add(coords,l);
  od;
  return coords;
end);

InstallMethod(CoordVals, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
  return List(TileCoords(sk), Concatenation);
end);

InstallMethod(Shifts, "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local tilecoords,d,l,s,shifts;
  shifts := [];
  for d in [1..DepthOfSkeleton(sk)-1] do
    l := List(TileCoords(sk)[d], Size);
    s := List([0..Size(l)], x->Sum(l{[1..x]}));
    Add(shifts, s);
  od;
  return shifts;
end);

InstallMethod(HolonomyPermutationResetComponents,
        "for a skeleton (SgpDec)", [IsSkeleton],
function(sk)
local grpcomps;
  grpcomps := GroupComponents(sk);
  return List([1..Length(grpcomps)],
              x -> PermutationResetSemigroup(grpcomps[x],
                      Shifts(sk)[x]));
end);

################################################################################
# util wrapping function for the often called BuildByWords
# to fend off likely future changes
InstallGlobalFunction(EvalWordInSkeleton,
function(sk, w)
  return BuildByWord(w, Generators(sk), (), OnRight);
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
  for class in Union(RepresentativeSets(sk)) do
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
