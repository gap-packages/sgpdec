gap> START_TEST("State set congruences");
gap> LoadPackage("sgpdec", false);;

gap> S:=Semigroup([Transformation([1,6,11,12,11,10,7,13,7,1,2,1,1]),
>              Transformation([2,10,3,3,8,7,2,4,5,6,5,3,4])]);;
gap> partition := StateSetCongruence(Generators(S), [[1,2],[3,4]]);
[[1,2,6,7,10],[3,4,5,8],[9],[ 11..13]]

gap> STOP_TEST( "State set congruences");
