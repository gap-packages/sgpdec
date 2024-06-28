LoadPackage( "sgpdec", false);

TestDirectory(DirectoriesPackageLibrary("sgpdec","tst"),
              rec(exitGAP     := true,
                  testOptions := rec(compareFunction := "uptowhitespace",
                                     transformFunction := "removenl") ) );
