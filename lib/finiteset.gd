#############################################################################
##
## finiteset.gd           SgpDec package
##
## Copyright (C) 2010-2023
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Just a wrap around blists to behave as finite sets.
##

DeclareGlobalFunction("TrueValuePositionsBlistString");

DeclareUserPreference(rec(
  name:="DisplayTrueValuePositionsBlist",
  description:=["if true it enables alternate display for blists"],
  default:=false,
  check:=IsBool));
# TODO this is bad, but the default value does not set the value
SetUserPreference("DisplayTrueValuePositionsBlist",false);
DeclareGlobalFunction("SgpDecFiniteSetDisplayOn");
DeclareGlobalFunction("SgpDecFiniteSetDisplayOff");

DeclareGlobalFunction("FiniteSet");
DeclareSynonym("Cardinality",SizeBlist);
DeclareSynonym("FiniteSetSize",SizeBlist);
DeclareGlobalFunction("FiniteSetComparator");
DeclareGlobalFunction("OnFiniteSet");
DeclareGlobalFunction("IsIdentityOnFiniteSet");
DeclareGlobalFunction("IsSingleton");
DeclareGlobalFunction("IsProperFiniteSubset");
DeclareGlobalFunction("HashFunctionForBlist");
