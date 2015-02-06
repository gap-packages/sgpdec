# testing shifting group action and disjoint union of groups
gap> START_TEST("Sgpdec package: disjointuniongroup.tst");
gap> LoadPackage("sgpdec");;

# shifting the action of S5 and checking isomorphism
gap> G := SymmetricGroup(IsPermGroup,5);;
gap> sG := ShiftGroupAction(G,23);
Group([ (24,25,26,27,28), (24,25) ])
gap> IsomorphismGroups(G,sG) <> fail;
true

# creating 15 copies of S5 and for the disjoint union with some funky shifts
gap> l := List([1..15],x->G);;
gap> shifts := List([1..16], x->5*Primes[x]);
[ 10, 15, 25, 35, 55, 65, 85, 95, 115, 145, 155, 185, 205, 215, 235, 265 ]
gap> dug := DisjointUnionGroup(l,shifts);
<permutation group with 30 generators>
gap> Size(dug)=Factorial(5)^15;
true

# testing isomorphism with nonspecified shifts
gap> dug2 := DisjointUnionGroup(l);
<permutation group with 30 generators>
gap> Size(dug) = Size(dug2);
true

#
gap> STOP_TEST( "Sgpdec package: disjointuniongroup.tst", 10000);
