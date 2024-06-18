gap> START_TEST("Surjective relational morphisms");
gap> LoadPackage("sgpdec", false);;

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

gap> STOP_TEST( "Surjective relational morphisms");
