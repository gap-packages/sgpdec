SgpDecDocSourceFiles :=
  [
   "linearnotation.xml",
   "words.xml",
   "../gap/decomposition.xml",
   "../gap/cascadedstructure.xml",
   "../gap/lagrangecoords.xml",
   "../gap/cascadedstate.xml",
   "../gap/cascadedoperation.xml",
   "finiteset.xml",
   "../gap/subgroupchains.xml",
   "skeleton.xml",
   "../gap/holonomy.xml"
   ];
MakeReadOnlyGVar("SgpDecDocSourceFiles");

SgpDecMakeDoc := function()
  MakeGAPDocDoc(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
          "/doc"),
          "SgpDec",SgpDecDocSourceFiles,"SgpDec","MathJax");
end;

SgpDecRunManualExamples := function()
  SizeScreen([80]);
  RunExamples(
          ExtractExamples(
                  Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                          "/doc"),
                  "SgpDec.xml",
                  SgpDecDocSourceFiles,
                  "Section"), rec(width:=80));
end;