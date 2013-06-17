InMaps := NewAttribute("InMaps",IsSkeleton,"mutable");
InWords := NewAttribute("InWords",IsSkeleton,"mutable");
OutMaps := NewAttribute("OutMaps",IsSkeleton,"mutable");
OutWords := NewAttribute("OutWords",IsSkeleton,"mutable");
#TODO make them readonly

DeclareAttribute("GroupComponents", IsSkeleton);

DeclareGlobalFunction("GetIN");
DeclareGlobalFunction("GetINw");
DeclareGlobalFunction("GetOUT");
DeclareGlobalFunction("GetOUTw");

#PERMUTATORS
DeclareGlobalFunction("RoundTripWords");
DeclareGlobalFunction("NontrivialRoundTripWords");
DeclareSynonym("HolonomyGroupGeneratorWords", NontrivialRoundTripWords);
DeclareGlobalFunction("PermutatorSemigroupElts");
DeclareGlobalFunction("PermutatorGroup");
DeclareGlobalFunction("PermutatorHolonomyHomomorphism");
DeclareGlobalFunction("HolonomyGroup@");
DeclareGlobalFunction("EvalWordInSkeleton");
