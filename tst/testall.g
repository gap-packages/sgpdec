LoadPackage( "sgpdec", false);

TestDirectory(DirectoriesPackageLibrary("sgpdec","tst"),
              rec(exitGAP     := true,
                  testOptions := rec(compareFunction := "uptowhitespace",
                                     transformFunction := "removenl") ) );

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
