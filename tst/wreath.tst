################################################################################
#testing the full cascade (semi)group
# testing the Frobenius-Lagrange decomposition
gap> START_TEST("Sgpdec package: wreath.tst");
gap> LoadPackage("sgpdec", false);;
gap> Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
> "/tst/variables.g"));;
gap> pairs := [[Z2,Z3], [Z3,S4], [S3,Z2]];;
gap> triples := [[Z3,Z2,Z2]];;

# testing size against the stock version of group wreath product
gap> ForAll(pairs,p->Size(WreathProduct(p[2],p[1]))=Size(FullCascadeGroup(p)));
true

# testing associativity
gap> ForAll(triples, function(t)
>  local A,B,C,AB,BC,ABC,AB_C,A_BC;
>  A := t[1];
>  B := t[2];
>  C := t[3];
>  AB := Image(IsomorphismPermGroup(GroupWreathProduct(A,B)));
>  BC := Image(IsomorphismPermGroup(GroupWreathProduct(B,C)));
>  ABC := Image(IsomorphismPermGroup(GroupWreathProduct([A,B,C])));
>  AB_C := Image(IsomorphismPermGroup(GroupWreathProduct([AB,C])));
>  A_BC := Image(IsomorphismPermGroup(GroupWreathProduct([A,BC])));
>  return IsomorphismGroups(ABC,A_BC)<>fail
>         and
>         IsomorphismGroups(ABC,AB_C)<>fail; end);
true

#
gap> STOP_TEST( "Sgpdec package: wreath.tst", 10000);