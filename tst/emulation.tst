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

gap> STOP_TEST( "Emulation Covering Lemma");
