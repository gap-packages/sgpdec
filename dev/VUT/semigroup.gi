#############################################################################
##
#W semigroup.gi           GrAsP library  
##
#Y  Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
#Y  2003 University of Hertfordshire, Hatfield, UK
##
##  This file contains additional code for (transformation) semigroups.
##

##  <#GAPDoc Label="ConstantTransformation">
##  <ManSection>
##  <Func Arg="degree, value" Name="ConstantTransformation" />
##  <Description>
##  Returns the constant transformation of value on the number of points given in degree.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction(ConstantTransformation,
    function(n,m)
    local t,i;
        if (not IsPosInt(n)) or (not IsPosInt(m)) then
            Error("in ConstantTransformation: function requires two positive integers");
        fi;
        if (m > n) then
            Error("in ConstantTransformation: arguments don't define a transformation");
        fi;
        t:= [];
        for i in [1..n] do
	    t[i] := m;
	od;
	return TransformationNC(t);	
    end);


##  <#GAPDoc Label="S1">
##  <ManSection>
##  <Func Arg="s" Name="S1" />
##  <Description>
##  Returns the semigroup as a monoid.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("S1", 
  function(semigroup)
  local gens, degree;

if (IsTransformationSemigroup(semigroup)) then
    #if it is already a monoid, then nothing to do
    if (IsMonoid(AsMonoid(semigroup))) then
	return semigroup;
    fi;
    #otherwise construct it
    gens := ShallowCopy(GeneratorsOfSemigroup(semigroup));
    degree := DegreeOfTransformation(gens[1]);
    Add(gens, IdentityTransformation(degree));
    return SemigroupByGenerators(gens);
else
    Print("Argument is not a transformation semigroup.");
fi;
end);

##  <#GAPDoc Label="S0">
##  <ManSection>
##  <Func Arg="s" Name="S0" />
##  <Description>
##  Returns the semigroup as a semigroup with zero if it doesn't have one.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("S0", 
  function(semigroup)
  local gens, ngens, degree, ndegree, i, templist;

if (IsTransformationSemigroup(semigroup)) then
    #if it is already a semigroup with zero, then nothing to do TODO!!!
    #if (IsMonoid(AsMonoid(semigroup))) then
    #	return semigroup;
    #fi;
    #otherwise construct it
    gens := GeneratorsOfSemigroup(semigroup);
    degree := DegreeOfTransformation(gens[1]);
    ndegree := degree + 1; 
    ngens := [];
    for i in Iterator(gens) do
	templist := ShallowCopy(ImageListOfTransformation(i));
	Add(templist, ndegree);
	Add(ngens, Transformation(templist));
    od;
    Add(ngens, ConstantTransformation(degree+1, degree+1));
    return SemigroupByGenerators(ngens);
else
    Print("Argument is not a transformation semigroup.");
fi;
end);

##  <#GAPDoc Label="SI">
##  <ManSection>
##  <Func Arg="s" Name="SI" />
##  <Description>
##  Returns the semigroup with a new identity.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("SI", 
  function(semigroup)
  local gens, ngens, degree, ndegree, i, templist;

if (IsTransformationSemigroup(semigroup)) then
    gens := GeneratorsOfSemigroup(semigroup);
    degree := DegreeOfTransformation(gens[1]);
    ndegree := degree + 2; 
    ngens := [];
    for i in Iterator(gens) do
	templist := ShallowCopy(ImageListOfTransformation(i));
	Add(templist, ndegree-1);
	Add(templist, ndegree-1);
	Add(ngens, Transformation(templist));
    od;
    Add(ngens, IdentityTransformation(ndegree));
    return SemigroupByGenerators(ngens);
else
    Print("Argument is not a transformation semigroup.");
fi;
end);



##  <#GAPDoc Label="IteratedSemigroupDisplay">
##  <ManSection>
##  <Func Arg="l" Name="IteratedSemigroupDisplay" />
##  <Description>
##  Display a list of semigroups with their sizes and generators.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("IteratedSemigroupDisplay", 
  function(list_of_semigroups)
  local i,n;
  n := Size(list_of_semigroups);
  for i in Iterator(list_of_semigroups) do 
      Print("S"); Print(n); n := n - 1;
      Print(" Size:");Print(Size(i));
      Print(" Generators:");Print(GeneratorsOfSemigroup(i));
      Print("\n");
  od;
end);



##  <#GAPDoc Label="LClassesOfDClass">
##  <ManSection>
##  <Func Arg="semigroup, dclass" Name="LClassesOfDClass" />
##  <Description>
##  Returns the L classes of a D class of a semigroup.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("LClassesOfDClass", 
    function(sg,jcl)
    local i, lclasses, result,d;
    
    result := [];
    lclasses := GreensLClasses(sg);
    d := AsSet(jcl);
    for i in lclasses do 
        if IsSubset(d, AsSet(i)) then
            Add(result, i);
        fi;
        
    od;
    return result;
end);

##  <#GAPDoc Label="PrincipialFactor">
##  <ManSection>
##  <Func Arg="semigroup, dclass" Name="PrincipialFactor" />
##  <Description>
##  Returns the principial factor belonging to a dclass.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("PrincipialFactor", 
    function(sg,jcl)
    local princideal, divisorideal;

    princideal := SemigroupIdealByGenerators(sg, [Representative(jcl)]);
    divisorideal := SemigroupIdealByGenerators(sg, UnionOfStrictlyLessJClasses(sg, jcl));
    return princideal/(ReesCongruenceOfSemigroupIdeal(divisorideal)); 
end);



##  <#GAPDoc Label="GetMaximalDClass">
##  <ManSection>
##  <Func Arg="semigroup" Name="GetMaximalDClass" />
##  <Description>
##  Returns the maximal D class of a semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction("GetMaximalDClass", 
    function(sg)
    local i,dclasses,ndcls,max;

    dclasses := GreensDClasses(sg);
    ndcls := Size(dclasses);
    if ndcls = 1 then return dclasses[1]; fi;
    max := dclasses[1];	
    for i in [2..ndcls] do
      if IsSubset(AsSet(SemigroupIdealByGenerators(sg,dclasses[i])) , AsSet(SemigroupIdealByGenerators(sg,max))) then
        max := dclasses[i];
      fi;
    od;    
    return max;
end);

##  <#GAPDoc Label="UnionOfStrictlyLessJClasses">
##  <ManSection>
##  <Func Arg="semigroup, jclass" Name="UnionOfStrictlyLessJClasses" />
##  <Description>
##  Returns the union of strictly less <M>J</M> classes. 
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("UnionOfStrictlyLessJClasses", 
    function(sg, jcl)
    local i,jclasses,njcls,union, pi,pi2;

    pi := AsSet(SemigroupIdealByGenerators(sg,jcl));
    jclasses := GreensJClasses(sg);
    union := [];  
    njcls := Size(jclasses);
    for i in [1..njcls] do
      pi2 := AsSet(SemigroupIdealByGenerators(sg,jclasses[i]));
      if IsSubset(pi, pi2) and pi <> pi2 then
        union := Union(jclasses[i], union);
      fi;
    od;    
    return union;
end);


##  <#GAPDoc Label="IsLeftSimpleSemigroup">
##  <ManSection>
##  <Meth Arg="semigroup" Name="IsLeftSimpleSemigroup" />
##  <Description>
##	This is the general case for a semigroup. It just checks how many
##	L classes does it have. If one, then left simple.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallMethod(IsLeftSimpleSemigroup,
  "for a semigroup",
  true,
  [ IsSemigroup ], 0,
function(s)
  if Size(GreensLClasses(s)) = 1 then
	return true;
  else
	return false;
  fi;

end);
