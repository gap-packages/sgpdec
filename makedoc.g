SgpDecDocSourceFiles := ["../PackageInfo.g",
                         "mansections.xml"];
MakeReadOnlyGVar("SgpDecDocSourceFiles");

SgpDecMakeDoc := function()
  MakeGAPDocDoc(
    Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,"/doc"),
    "main.xml",
    SgpDecDocSourceFiles,
    "SgpDec",
    "MathJax",
    "../../..");
end;

SgpDecRunManualExamples := function()
  #to have the same output
  SizeScreen([80]);
  #to have no profile info
  #SetInfoLevel(LagrangeDecompositionInfoClass,0);
  #SetInfoLevel(HolonomyInfoClass,0);
  #SetInfoLevel(SkeletonInfoClass,0);
  RunExamples(
    ExtractExamples(
      Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                    "/doc"),
      "main.xml",
      SgpDecDocSourceFiles,
      "Section"),
    rec(width:=80,compareFunction:="uptowhitespace"));
end;

#the actual call
SgpDecMakeDoc();