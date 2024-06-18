gap> START_TEST("Surjective relational morphisms");
gap> LoadPackage("sgpdec", false);;
gap> Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
> "/tst/bestiary.g"));;

## Testing a non-morphism: permutations map to identity, everything else to itself
gap> ThetaId := function(states) return HashMap(List(states, x-> [x,[x]]));end;;

gap> PhiNoPerm := function(S)
>  return HashMap(List(S, function(s)
>                       if IsPermutation(s) then
>                         return [s,[IdentityTransformation]];
>                       else
>                         return [s,[s]];
>                       fi;end));
> end;;
gap> T4 := FullTransformationSemigroup(4);;
gap> IsTSRelMorph(ThetaId([1..4]), PhiNoPerm(T4), OnPoints, OnPoints);
Checking 1*Transformation( [ 2, 1, 4, 3 ] )
[ 1 ] is not a subset of [ 2 ]
false
gap> skBECKS := Skeleton(BECKS);;
gap> IsTSRelMorph(ThetaForHolonomy(skBECKS),PhiForHolonomy(skBECKS),OnPoints,OnPoints);
true

gap> STOP_TEST( "Surjective relational morphisms");
