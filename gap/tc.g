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

# this cuts off the baseset
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

ConstantMapToATile2 := function(subtile, depth, slot, sk)
  local pos; # the position of the tile that contains set
  pos := First([Shifts(sk)[depth][slot]+1..Shifts(sk)[depth][slot+1]],
                x-> CoordVals(sk)[depth][x] = subtile);
  #just a constant transformation pointing to this tile (encoded as an integer)
  if pos = fail then Error();fi;
  return Transformation(List([1..Size(CoordVals(sk)[depth])],x->pos));
end;


HolonomyCore := function(sk, s, coords)
  local CP, CQ, # tile chains 
        Q, P, # the current set in the chains
        CPs,Ps, # P hit by s
        depth, 
        cas, # encoded component actions
        positionedQ,positionedP; # positioned tiles
  cas := List([1..DepthOfSkeleton(sk)-1],
                  x -> One(HolonomyPermutationResetComponents(sk)[x]));
  CP := DecodeCoords(sk,coords);
  Add(CP,BaseSet(sk),1);
  CPs := OnSequenceOfSets(CP,s);
  CQ := DominatingTileChain(sk,CPs);
  positionedQ := PositionedTileChain(sk,CQ);
  positionedP := PositionedTileChain(sk,CP);
  Q := BaseSet(sk);
  P := BaseSet(sk);
  for depth in [1..DepthOfSkeleton(sk)-1] do
    if depth = DepthOfSet(sk,Q) then #TODO positionedQ[depth] <> 0 is faster
      Ps := OnFiniteSet(P,s); #TODO this is already in CPs
      if Ps  = Q then #PERMUTATION
        cas[depth] := PermutationOfTiles(
                              FromRep(sk,P) * s * ToRep(sk,Q),#roundtrip
                              depth,GetSlot(Q,sk),sk);
      else #CONSTANT
        if not IsSubsetBlist(Q,  Ps) then Error("newHEY");fi;
        cas[depth]:=ConstantMapToATile2(
                            RepTile(positionedQ[depth],Q,sk),
                            depth,GetSlot(Q,sk),sk);
      fi;
      Q := positionedQ[depth];
    fi;
    if depth = DepthOfSet(sk,P) then
      P := positionedP[depth];
    fi;
  od;
  return cas;
end;
