SgpDecMakeDoc := function()
    MakeGAPDocDoc(Concatenation( PackageInfo( "sgpdec" )[1]!.InstallationPath, "/doc" ),
            "SgpDec",[
                    "../gap/linearnotation.gd",
                    "../gap/words.xml",
                    "../gap/decomposition.gd",
                    "../gap/cascadedstructure.gd",
                    "../gap/lagrangecoords.gd",
                    "../gap/cascadedstate.gd",
                    "../gap/cascadedoperation.gd",
                    "../gap/finiteset.xml",
                    "../gap/subgroupchains.gd",
                    "../gap/skeleton.xml",
                    "../gap/holonomy.xml",
                    "../config"
                    ],"SgpDec");
end;