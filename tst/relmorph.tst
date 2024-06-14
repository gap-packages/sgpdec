gap> START_TEST("Relational morphsims");
gap> LoadPackage("sgpdec", false);;

# joining two states with a transposition defined on them
gap> ex1S := Semigroup(Transformation([1,3,2]), #transposition of 2 and 3
>                  Transformation([1,1,1]),
>                  Transformation([2,2,2]));;

#collapsing 2 and 3
gap> ex1theta := HashMap([[1,[1]],
>                     [2,[2]],
>                     [3,[2]]]);;
gap> ex1phi := HashMap([[Transformation([1,2,3]), [Transformation([1,2])]],
>                   [Transformation([1,1,1]), [Transformation([1,1])]],
>                   [Transformation([2,2,2]), [Transformation([2,2])]],
>                   [Transformation([3,3,3]), [Transformation([2,2])]],
>                   [Transformation([1,3,2]), [Transformation([1,2])]]]);;
gap> STOP_TEST( "Relational morphisms");
