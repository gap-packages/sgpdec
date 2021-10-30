################################################################################
# testing the full cascade (semi)group, it should be the wreath product 
gap> START_TEST("Sgpdec package: wreath.tst");
gap> LoadPackage("sgpdec", false);;
gap> Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
> "/tst/variables.g"));;
gap> pairs := [[Z2,Z3], [S3,Z2]];;
gap> triples := [[Z2,Z2,Z3]];;

# checking isomorphism with the stock version of group wreath product
gap> ForAll(pairs, function(p)
>  local W, FC;
>  W := Image(IsomorphismPermGroup(WreathProduct(p[2],p[1])));
>  FC := Image(IsomorphismPermGroup(FullCascadeGroup(p)));
>  return IsomorphismGroups(W,FC) <> fail; end); # TODO this should work even without converting to permutation groups
true
gap> W := FullCascadeGroup(pairs[1]);
<wreath product of perm groups>
gap> r := RandomCascade(ComponentsOfCascadeProduct(W), 2);;
gap> r = AsCascade(AsPermutation(r), ComponentsOfCascadeProduct(W));
true
gap> ComponentsOfCascadeProduct(W);
[ Group([ (1,2) ]), Group([ (1,2,3) ]) ]

# testing associativity
gap> ForAll(triples, function(t)
>  local A,B,C,AB,BC,ABC,AB_C,A_BC;
>  A := t[1];
>  B := t[2];
>  C := t[3];
>  AB := Image(SmallerDegreePermutationRepresentation(Image(IsomorphismPermGroup(GroupWreathProduct([A,B])))));
>  BC := Image(SmallerDegreePermutationRepresentation(Image(IsomorphismPermGroup(GroupWreathProduct([B,C])))));
>  ABC := Image(IsomorphismPermGroup(GroupWreathProduct([A,B,C])));
>  AB_C := Image(IsomorphismPermGroup(GroupWreathProduct([AB,C])));
>  A_BC := Image(IsomorphismPermGroup(GroupWreathProduct([A,BC])));
>  return IsomorphismGroups(ABC,A_BC)<>fail
>         and
>         IsomorphismGroups(ABC,AB_C)<>fail; end);
true
gap> W := FullCascadeSemigroup([FF,Z2]);;
gap> Size(W);
12
gap> Size(AsList(W));
12
gap> ComponentsOfCascadeProduct(W);
[ <transformation monoid of size 3, degree 2 with 2 generators>, 
  <transformation group of size 2, degree 2 with 1 generator> ]
gap> S := Range(IsomorphismTransformationSemigroup(W));
<transformation monoid of degree 4 with 4 generators>
gap> Size(S);
12

#
gap> STOP_TEST( "Sgpdec package: wreath.tst", 10000);
