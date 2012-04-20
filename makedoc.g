SgpDecMakeDoc := function()
    MakeGAPDocDoc(Concatenation( PackageInfo( "sgpdec" )[1]!.InstallationPath, "/doc" ),
            "SgpDec",[
                    "../gap/storage/storage.gd",
                    "../gap/storage/stack.gd",
                    "../gap/storage/queue.gd",
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
                    "../gap/holonomy.gd",
                    "../config"
                    ],"SgpDec");
end;