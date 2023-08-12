#############################################################################
##
## skeletonchains.gi       SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Tilechains in a skeleton of a transformation semigroup.
##

################################################################################
# TILES ########################################################################
################################################################################

InstallGlobalFunction(TilesOf,
function(sk,set)
  if set in ExtendedImageSet(sk) then
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


################################################################################
InstallGlobalFunction(DepthOfSet,
function(sk,A)
  if IsSingleton(A) then return DepthOfSkeleton(sk); fi;
  return Depths(sk)[
                 OrbSCCLookup(ForwardOrbit(sk))[Position(ForwardOrbit(sk),A)]
                 ];
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
  singleton := Last(tc);
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
