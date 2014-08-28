# The idea here is to define generic functions, i.e.
# functions creating functions 

# GREEN'S PREORDERS
#true if a if is X-below or X-equivalent, X is L,R or D
IsGreensBelowOrEquiv := function(S,a,b, GreensClassFunc)
  return IsGreensLessThanOrEqual(
                 GreensClassFunc(S,a),
                 GreensClassFunc(S,b));
end;

# concrete preorder functions
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

#concrete
CheckDtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensDBelowOrEquiv);
end;

CheckRtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensRBelowOrEquiv);
end;

CheckLtoSubdImplication := function(S)
  return CheckGreenstoSubdImplication(S,IsGreensLBelowOrEquiv);
end;

#examples
NonLinearNonIsomorphicSkeleton :=
  Monoid([ Transformation( [ 1, 3, 1 ] ),
          Transformation( [ 2, 1, 2, 3 ] ),
          Transformation( [ 3, 2, 1, 1 ] ) ]);
NonLinearNonIsomorphicSkeleton_24 :=
  Monoid([ Transformation( [ 1, 3, 4, 4 ] ),Transformation( [ 3, 4, 3, 2 ] ) ]);
NonLinearNonIsomorphicSkeleton_10 :=
  Monoid([Transformation([1,5,1,2,1]),Transformation([3,1,1,2,3])]);
