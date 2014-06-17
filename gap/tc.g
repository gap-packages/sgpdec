OnSequenceOfSets := function(tc, s)
  return Set(tc,tile -> OnFiniteSet(tile,s)); #hoping for the order
end;

# no choice here yet
DominatingTileChain := function(sk,chain)
  local pos, dtc;
  if IsEmpty(chain) then Error();fi;
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
end;


PositionedTileChain := function(sk, chain)
  local positioned,i;
  positioned := List([1..DepthOfSkeleton(sk)-1],x->0);
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
    if positionedchain[i] <> 0 then
      padded[i] := positionedchain[i];
    else
      if i = 1 then
        padded[i] := BaseSet(sk);
      else
        padded[i] := padded[i-1];
      fi;
    fi;
  od;
  return padded;
end;

# P is a tile chain
HolonomyCore := function(sk, s, coords)
  local pP, pPs, Q, pQ, depth, Qparent,action, cas,P, positionedQ,paddedP;
  cas := List([1..DepthOfSkeleton(sk)-1],
                  x -> One( HolonomyPermutationResetComponents(sk)[x]));
  P := DecodeCoords(sk,coords);
  Qparent := BaseSet(sk);
  Q := DominatingTileChain(sk,OnSequenceOfSets(P,s));
  positionedQ := PositionedTileChain(sk,Q);
  paddedP := PaddedTileChain(sk,P);
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if positionedQ[depth] <> 0 then
      if OnFiniteSet(paddedP[depth],s) = Qparent then #PERMUTATION
        action := FromRep(sk,paddedP[depth]) * s * ToRep(sk,Qparent); #roundtrip
        cas[depth] := PermutationOfTiles(action,depth,GetSlot(Qparent,sk),sk);
      else
        #constant
        if not IsSubsetBlist(positionedQ[depth],  OnFiniteSet(paddedP[depth],s)) then Error();fi;;
        cas[depth]:=ConstantMapToATile(positionedQ[depth],
                            depth,
                            GetSlot(Qparent,sk),
                            sk);
      fi;
      Qparent := positionedQ[depth];
    fi;
  od;
  return cas;
end;
