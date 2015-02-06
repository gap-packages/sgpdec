# transformation notation tests
gap> START_TEST("Sgpdec package: straightword.tst");
gap> LoadPackage("sgpdec");;
gap> gens := GeneratorsOfSemigroup(FullTransformationSemigroup(9));;
gap> w := RandomWord(33333,Size(gens));;
gap> rw := Reduce2StraightWord(w,gens,One(gens[1]),\*);;
gap> Length(rw) <= Length(w);
true
gap> IsStraightWord(rw,gens,One(gens[1]),\*);
true
gap> BuildByWord(w,gens,One(gens[1]),\*)
>       = BuildByWord(rw,gens,One(gens[1]),\*);
true

#
gap> STOP_TEST( "Sgpdec package: straightword.tst", 10000);