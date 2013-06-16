DeclareCategory("IsSKELETON", IsObject and IsAttributeStoringRep);
BindGlobal("SKELETONFamily",NewFamily("SKELETONFamily", IsSKELETON));
BindGlobal("SKELETONType", NewType(SKELETONFamily,IsSKELETON));

#constructor
DeclareGlobalFunction("SKELETON");

#stored attributes
DeclareAttribute("TransSgp",IsSKELETON);
DeclareAttribute("BaseSet",IsSKELETON);
DeclareAttribute("Generators",IsSKELETON);
DeclareAttribute("DegreeOfSKELETON",IsSKELETON);
DeclareAttribute("Singletons",IsSKELETON);
DeclareAttribute("ForwardOrbit",IsSKELETON);
DeclareAttribute("SKELETONTransversal",IsSKELETON);
DeclareAttribute("ExtendedImageSet",IsSKELETON);
DeclareAttribute("InclusionCoverBinaryRelation",IsSKELETON);
DeclareAttribute("RepSubductionCoverBinaryRelation",IsSKELETON);
DeclareAttribute("Depths",IsSKELETON);
DeclareAttribute("Heights",IsSKELETON);

#functions
DeclareGlobalFunction("SKTilesOf");
DeclareGlobalFunction("SKRepresentativeSet");
DeclareGlobalFunction("RepresentativeSetsOnDepth");
DeclareGlobalFunction("SKAllRepresentativeSets");
