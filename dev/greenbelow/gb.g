# true if a if is X-below or X-equivalent, X is L,R or D
# this is the generic function, see concrete ones below
IsGreensBelowOrEquiv := function(S,a,b, GreensClassFunc)
  return IsGreensLessThanOrEqual(
                 GreensClassFunc(S,a),
                 GreensClassFunc(S,b)
                 );
end;

IsGreensDBelowOrEquiv := function(S,a,b)
  return IsGreensBelowOrEquiv(S,a,b,GreensDClassOfElement);
end;

IsGreensRBelowOrEquiv := function(S,a,b)
  return IsGreensBelowOrEquiv(S,a,b,GreensRClassOfElement);
end;

IsGreensLBelowOrEquiv := function(S,a,b)
  return IsGreensBelowOrEquiv(S,a,b,GreensLClassOfElement);
end;

#subduction transferred to semigroup elements
IsSubductionBelowOrEquiv := function(sk, a, b)
  local la, lb, d;
  d := DegreeOfSkeleton(sk);
  la := FiniteSet(ImageSetOfTransformation(a),d);
  lb := FiniteSet(ImageSetOfTransformation(b),d);
  return IsSubductionLessOrEquivalent(sk,la,lb);
end;

#checking whether X-relation implies subduction
#generic function
CheckGreenstoSubdImplication := function(S,GreensBelowOrEquivFunc)
  local sk,p;
  sk := Skeleton(S);
  #we check all tuples
  for p in Tuples(S,2) do
    if GreensBelowOrEquivFunc(S,p[1],p[2]) then
      if not IsSubductionBelowOrEquiv(sk,p[1],p[2]) then
        Print(p[1],p[2]);
        return fail;
      fi;
    fi;
  od;
  return true;
end;

CheckDtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensDBelowOrEquiv);
end;

CheckRtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensRBelowOrEquiv);
end;

CheckLtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensLBelowOrEquiv);
end;
