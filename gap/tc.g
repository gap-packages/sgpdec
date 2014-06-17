DominatingTileChain := function(sk,chain)
  local pos, dtc;
  pos := 1;
  dtc := ShallowCopy(chain);
  while not IsSingleton(dtc[pos]) do
    if not dtc[pos+1] in TilesOf(sk, dtc[pos]) then
      Add(dtc,
          First(TilesOf(sk,dtc[pos]), x->IsSubsetBlist(x,dtc[pos+1])),
          pos+1);
    fi;
    pos := pos + 1;
  od;
  return dtc;
end;


PositionedTileChain := function(sk, chain)
  local positioned,i;
  positioned := [];
  i := 1;
  while i < Length(chain) do
    positioned[DepthOfSet(sk,chain[i])] := chain[i+1];
    i := i +1;
  od;
  return positioned;
end;

PaddedTileChain := function(sk, tilechain)
local padded,i,positionedchain;
  positionedchain := PositionedTileChain(sk,tilechain);
  padded := EmptyPlist(DepthOfSkeleton(sk)-1);
  for i in [1..DepthOfSkeleton(sk)-1] do
    if IsBound(positionedchain[i]) then
      padded[i] := positionedchain[i];
    else
      padded[i] := padded[i-1];
    fi;
  od;
  return padded;
end;

# P is a tile chain
HolonomyCore := function(sk, P, s)
  local pP, pPs, Q, pQ, depth, Qparent;
#  Pparent := BaseSet(sk);
  Qparent := BaseSet(sk);
  Q := DominatingTileChain(sk,Ps);
  pQ := PositionedTileChain(sk,Q);
  pP := PositionedTileChain(sk,P);
  pPs := OnTileChain(pP,s);
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if IsBound(pQ[depth]) then
      if P = Qparent then #PERMUTATION
        # action := FromRep(sk,P) * s * ToRep(sk,Q); #roundtrip
        # cas[depth] := PermutationOfTiles(action,depth,GetSlot(Q,sk),sk);
        # ncoordval := OnFiniteSet(coords[depth], action);
      fi;
    fi;
  od;
end;
