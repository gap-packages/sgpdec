SgpDecMakeDoc := function()
    MakeGAPDocDoc(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                                            "/doc"),
            "SgpDec",[
                    "../gap/linearnotation.xml",
                    "words.xml",
                    "../gap/decomposition.xml",
                    "../gap/cascadedstructure.xml",
                    "../gap/lagrangecoords.xml",
                    "../gap/cascadedstate.xml",
                    "../gap/cascadedoperation.xml",
                    "../gap/finiteset.xml",
                    "../gap/subgroupchains.xml",
                    "../gap/skeleton.xml",
                    "../gap/holonomy.xml"
                    ],"SgpDec");
end;

SgpDecRunManualExamples := function()
  RunExamples(
          ExtractExamples(
                  Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                          "/doc"),
                  "SgpDec.xml",
                  ["../gap/words.xml"],
                  "Section"));
end;