################################################################################
# CONSTRUCTOR ##################################################################
# setting the basic attributes of the skeleton
InstallGlobalFunction(SKELETON,
function(ts)
  local o;
  o := Objectify(SKELETONType, rec());
  SetTransSgp(o,ts);
  SetGenerators(o,GeneratorsOfSemigroup(ts));
  SetDegreeOfSKELETON(o,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(o, FiniteSet([1..DegreeOfSKELETON(o)]));
  return o;
end);

InstallMethod(Singletons, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  return List([1..DegreeOfSKELETON(sk)],
              i -> FiniteSet([i], DegreeOfSKELETON(sk)));
end);

InstallMethod(ForwardOrbit, "for a skeleton (SgpDec)", [IsSKELETON],
function(sk)
  local o;
  o := Orb(TransSgp(sk), BaseSet(sk), OnFiniteSets,
           rec(schreier:=true,orbitgraph:=true));
  Enumerate(o);
  return o;
end);
