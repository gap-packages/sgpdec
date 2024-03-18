LoadPackage( "sgpdec" );

# `TestDirectory` provides a convenient way to run collections of tests.
# It also simplifies adding new tests, because it automatically picks
# up all files having extension `.tst`
#
# It also ensures that it will display an information message that is
# needed to detect whether a test passed or failed in a number of automated
# settings.
#
# If you need to run some other tests in addition to `TestDirectory`,
# you code should analyse the outcome of the test, and then
# print an information using the string that looks exactly as shown below:
#
# if testresult 
#   Print("#I  No errors detected while testing"\n");
# else
#   Print("#I  Errors detected while testing\n");
# fi;
#
#
TestDirectory(DirectoriesPackageLibrary( "sgpdec", "tst" ),
  rec(exitGAP     := true,
      testOptions := rec(compareFunction := "uptowhitespace", transformFunction := "removenl") ) );

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
