# quick but comprehensive test for establishing correctness of the algorithms

LoadPackage("sgpdec");
#just aliases
Read("namedgroups.g");
Read("namedsemigroups.g");

SEED := IO_gettimeofday().tv_sec;
Reset(GlobalMersenneTwister, SEED);
Print("#Random seed:", SEED, "\n");

SMALL_GROUPS := true;;
test_groups := [D8,C4,C5,S4];;
test_semigroups := [MICROBUG,HEYBUG,SMLBUG,BECKS, BEX,T4, ALIFEX, NONISOMPERM];
ITER := 33;;

#reading the test functions
Read("cartesianenum.g");;
Read("wreath.g");;
Read("idmul.g");;
Read("mul.g");;
Read("depextract.g");;
Read("linnot.g");;

########################################################
############MAIN########################################
########################################################
Print("\nTesting enumerator of cartesian product.\n");
TestCartesianEnumerator();

TestLinearNotation(5);
TestLinearNotation(51);

TestDependencyExtraction([MICROBUG,HEYBUG,ALIFEX]);
TestDependencyExtraction([BECKS,HEYBUG,S3]);

TestMultiplicationByIdentity([BECKS,HEYBUG,S3]);
TestMultiplicationByIdentity([MICROBUG,HEYBUG,ALIFEX]);

TestMultiplication([BECKS,HEYBUG,S3]);
TestMultiplication([MICROBUG,HEYBUG,ALIFEX]);

#Dump the random seed in case there was something interesting.
Print("#Random seed:", SEED, "\n");
