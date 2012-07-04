
# SgpDec script by C. L. Nehaniv to return Holonomy Group details.   7 June 2011
#HGSurfer(S,HolDec,FinSet)

gens := GeneratorsOfSemigroup(S);

#ActionInfoOnLevel(HolDec,DepthOfSet(HolDec,FinSet));

sk := SkeletonOf(hd); 

ec := SkeletonClasses(sk);

RepSetList :=[];
for class in [1..Size(ec)]
 do  
     Add(RepSetList,ec[class].rep);
 od;

for FinSet in RepSetList 
do

Print("Set: ",FinSet," = union of ");
Print(CoveringSetsOf(sk,FinSet),"\n"); 
Print("Holonomy ",CoverGroup(sk,FinSet),"\n");

# e.g. for lac operon (lac.g):  x1 :=FiniteSet([9,10,11,12,13,14,15,16])

permwords := Permutators(sk,FinSet);

for w in permwords
  do 
      perm := Construct(w,gens,One(gens[1]),\*);
      Print("Permuator word ", w, ": ",  perm, " gives ", LinearNotation(perm),"\n");
  od;
Print("\n");
od;

