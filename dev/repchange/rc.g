nsk := function(sk, tr)
  local o, ts;
  ts:=TransSgp(sk);
  o := Objectify(SkeletonType, rec());
  SetTransSgp(o,ts);
  SetGenerators(o,Generators(ts));
  SetDegreeOfSkeleton(o,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(o, FiniteSet([1..DegreeOfSkeleton(o)]));
  SetForwardOrbit(o,ForwardOrbit(sk));
  SetExtendedImageSet(o, ExtendedImageSet(sk));
  SetSubductionEquivClassCoverRelation(o,SubductionEquivClassCoverRelation(sk));
  SetSubductionEquivClassRelation(o,SubductionEquivClassRelation(sk));
  SetInclusionCoverRelation(o, InclusionCoverRelation(sk));
  SetSkeletonTransversal(o,tr);
  return o;
end;