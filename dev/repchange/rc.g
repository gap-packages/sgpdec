# return a new Skeleton where A becomes a representative of its own class
MakeRepresentative := function(sk, A)
  local newsk, ts, tr, Aindex, SCCindex,o;
  #creating a new transversal
  o := ForwardOrbit(sk);
  Aindex := Position(o,A);
  if (Aindex = fail) then return fail; fi;
  SCCindex := OrbSCCLookup(o)[Aindex];
  tr := ShallowCopy(SkeletonTransversal(sk));
  tr[SCCindex]:=Aindex;
  MakeImmutable(tr);
  #creating a new skeleton object, setting the attributes not dependent on the reps
  ts:=TransSgp(sk);
  newsk := Objectify(SkeletonType, rec());
  SetTransSgp(newsk,ts);
  SetGenerators(newsk,Generators(ts));
  SetDegreeOfSkeleton(newsk,DegreeOfTransformationSemigroup(ts));
  SetBaseSet(newsk, BaseSet(sk));
  SetForwardOrbit(newsk,o);
  SetExtendedImageSet(newsk, ExtendedImageSet(sk));
  SetSubductionEquivClassCoverRelation(newsk,
                                       SubductionEquivClassCoverRelation(sk));
  SetSubductionEquivClassRelation(newsk,
                                  SubductionEquivClassRelation(sk));
  SetInclusionCoverRelation(newsk, InclusionCoverRelation(sk));
  #setting the new transversal
  SetSkeletonTransversal(newsk,tr);
  return newsk;
end;