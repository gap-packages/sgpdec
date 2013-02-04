#testing whether the set of chains are closed under the action of the semigroup 
testChainAction := function(ts)
local chain,chains,modchain, t;
  chains := AllChains(Skeleton(ts));
  for t in ts do
    for chain in chains do
      modchain := Unique(List(chain, x -> x*t));
      if not (modchain in chains) then
        Print(chain, " -> ", modchain, "by", t,"\n" );
      fi;
    od;
  od;  
end;
