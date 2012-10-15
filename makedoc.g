SgpDecDocSourceFiles :=
  [
   "linearnotation.xml",
   "words.xml",
   "decomposition.xml",
   "cascadeshell.xml",
   "lagrangecoords.xml",
   "../gap/cascadedoperation.xml",
   "finiteset.xml",
   "../gap/subgroupchains.xml",
   "skeleton.xml",
   "holonomy.xml"
   ];
MakeReadOnlyGVar("SgpDecDocSourceFiles");

SgpDecMakeDoc := function()
  MakeGAPDocDoc(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
          "/doc"),
          "SgpDec",SgpDecDocSourceFiles,"SgpDec","MathJax");
end;

SgpDecRunManualExamples := function()
  #to have the same output
  SizeScreen([80]);
  #to have no profile info
  SetInfoLevel(LagrangeDecompositionInfoClass,0);
  SetInfoLevel(HolonomyInfoClass,0);
  RunExamples(
          ExtractExamples(
                  Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                          "/doc"),
                  "SgpDec.xml",
                  SgpDecDocSourceFiles,
                  "Section"), rec(width:=80));
end;