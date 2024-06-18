gap> START_TEST("Emulation (Covering Lemma)");
gap> LoadPackage("sgpdec", false);;
gap> Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
> "/tst/bestiary.g"));;
gap> TestEmulation(BEX);
true
gap> TestEmulation(BECKS);
true
gap> TestEmulation(HEYBUG);
true
gap> TestEmulation(OVLCOVERS);
true
gap> TestEmulation(LASTMINUTE);
true
gap> TestEmulationWithMorphism(BECKS, ThetaForConstant([1..6]), PhiForConstant(BECKS));
true
gap> S:=Semigroup([Transformation([1,6,11,12,11,10,7,13,7,1,2,1,1]),
>              Transformation([2,10,3,3,8,7,2,4,5,6,5,3,4])]);;
gap> partition := StateSetCongruence(Generators(S), [[1,2],[3,4]]);;
gap> theta := ThetaForCongruence(partition);;
gap> phi := PhiForCongruence(partition, S);;
gap> MuCheck(theta, phi);
true
gap> PsiCheck(theta);
true

gap> STOP_TEST( "Emulation Covering Lemma");
