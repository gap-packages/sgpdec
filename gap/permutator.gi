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

################################################################################
# util wrapping function for the often called BuildByWords
# to fend off likely future changes
InstallGlobalFunction(EvalWordInSkeleton,
function(sk, w)
  return BuildByWord(w, sk.gens, sk.id, OnRight);
end);
