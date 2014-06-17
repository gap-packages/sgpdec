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
  local CP, CQ, # tile chains 
        pP, pPs, Q, pQ, depth,action, cas,P, positionedQ,paddedP,Ps,positionedP;
  cas := List([1..DepthOfSkeleton(sk)-1],
                  x -> One( HolonomyPermutationResetComponents(sk)[x]));
  CP := DecodeCoords(sk,coords);
  Q := BaseSet(sk);
  P := BaseSet(sk);
  Add(CP,BaseSet(sk),1);
  CQ := DominatingTileChain(sk,OnSequenceOfSets(CP,s));
  positionedQ := PositionedTileChain(sk,CQ);
  positionedP := PositionedTileChain(sk,CP);

  for depth in [1..DepthOfSkeleton(sk)-1] do
    if positionedQ[depth] <> 0 then
      Ps := OnFiniteSet(P,s); 
      if Ps  = Q then #PERMUTATION
        action := FromRep(sk,P) * s * ToRep(sk,Q); #roundtrip
        cas[depth] := PermutationOfTiles(action,depth,GetSlot(Q,sk),sk);
      else
        #constant
        if not IsSubsetBlist(Q,  Ps) then Error("newHEY");fi;;
        cas[depth]:=ConstantMapToATile(
                            RepTile(positionedQ[depth],Q,sk),
                            depth,
                            GetSlot(Q,sk),
                            sk);
      fi;
      Q := positionedQ[depth];
    fi;
    if positionedP[depth] <> 0 then
      P := positionedP[depth];
    fi;
  od;
  return cas;
end;
