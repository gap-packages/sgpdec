################################################################################
##  SgpDec                 Emulation from surjective morphisms, Covering Lemma
##  Copyright (C) 2024                                  Attila Egri-Nagy et.al
################################################################################
### BUILDING THE EMULATION constructing psi and mu #############################

# LABELLING i.e. constructing (Z,U)

# STATES
# returns a function that maps the elements of a set of k integers down to the
# the set 1,...,n, 'squashing them to the bottom'
# A - a set of states (positive integers)
# it returns fail if the input is undefined (by the hashmap inside)
# intuition: this encodes the original states in X into Z
wyLabel := function(A)
  local m, sA;
  sA := AsSortedList(A); #to make sure they are in order
  m := HashMap();
  Perform(List([1..Size(sA)]), function(i) m[sA[i]]:=i;end);
  return x -> m[x];
end;
MakeReadOnlyGlobal("wyLabel");

# the inverse of wyLabel, decodes the states in U back to ones from X
wyLabelInv := function(A)
  local m, sA;
  sA := AsSortedList(A);
  m := HashMap();
  Perform(List([1..Size(sA)]), function(i) m[i]:=sA[i];end);
  return x -> m[x];
end;
MakeReadOnlyGlobal("wyLabelInv");

# the lifts in the decomposition for the states in the original ts
# idea: take a state x, and for all of its images y (the top level coordinate),
# find all the pre-images of y (the context)
PsiFunc := function(x, theta, thetainv)
  return List(theta[x],
             function(y)
               local w;
               w := wyLabel(thetainv[y]);
               return [y,w(x)];
             end);
end;
MakeReadOnlyGlobal("PsiFunc");

InstallGlobalFunction(Psi,
function(theta)
  local x,YtoX, psi;
  psi := HashMap();
  YtoX := InvertHashMapRelation(theta);
  for x in Keys(theta) do
      psi[x] := PsiFunc(x, theta, YtoX);
  od;
  return psi;
end);

# for the coordinates we return the original state
# Where does z go? It depends on the top level state.
PsiInvFunc := function(coords,thetainv)
  local y,z,winv;
  y := coords[1];
  z:= coords[2];
  winv := wyLabelInv(thetainv[y]); # thetainv: Y -> X
  return winv(z);
end;
MakeReadOnlyGlobal("PsiInvFunc");

# checking to coordinatized states by mapping them back to X
PsiCheck := function(theta)
  local x, thetainv;
  thetainv := InvertHashMapRelation(theta);
  for x in Keys(theta) do
    if not (ForAll(PsiFunc(x, theta, thetainv),
                   coordpair -> x = PsiInvFunc(coordpair, thetainv))) then
      Print("Problem with state ",x );
    fi;
  od;
  return true;
end;
MakeReadOnlyGlobal("PsiCheck");

# TRANSFORMATIONS
# given the context y, the top level state, we want to know
# how the original action of s can be expressed locally on Z
# the element of U constructed here also depends on t
LocalTransformation := function(y,s,t, YtoX)
  local wyinv, wyt, l, ypre, ytpre;
  ypre := YtoX[y]; #preimages
  ytpre := YtoX[OnPoints(y,t)];
  l := [1..Maximum(Size(ypre),Size(ytpre))];#k]; #we need to prefill the action with identities, |ypre| may not equal |ytpre|
  wyinv := wyLabelInv(ypre);
  wyt := wyLabel(ytpre);
  Perform([1..Size(ypre)],
         function(z)
           # map z back from the current context,
           # act by S in X, then map to new context of yt
           l[z]:= wyt(OnPoints(wyinv(z),s));
         end);
  return Transformation(l);
end;
MakeReadOnlyGlobal("LocalTransformation");

# creating a cascade for s when lifted to t
MuLift := function(s,t,theta,n)
  local y, cs, deps, nt, YtoX, preimgs,k;
  YtoX := InvertHashMapRelation(theta);
  deps := [];
  k :=  Maximum(List(ImageOfHashMapRelation(theta), y -> Size(YtoX[y])));
  for y in ImageOfHashMapRelation(theta) do
    nt := LocalTransformation(y,s,t, YtoX);
    if not IsOne(nt) then
      Add(deps, [[y], nt]);
    fi;
  od;#y
  if not IsOne(t) then Add(deps, [[],t]); fi; #top level is t
  return Cascade([n,k], deps, TransCascadeType);
end;
MakeReadOnlyGlobal("MuLift");

# needed for MuCheck
MuFunc := function(s, ts, theta, n)
  return List(ts, t-> MuLift(s,t,theta, n));
end;
MakeReadOnlyGlobal("MuFunc");

# the complete map from S to the cascade product
# just lift every s with respect to all of its lifts
InstallGlobalFunction(Mu,
function(theta, phi)
  local mu, t, y, s, cs, deps, nt, n;
  n := Size(ImageOfHashMapRelation(theta)); # #states of top level
  mu := HashMap();
  for s in Keys(phi) do
    mu[s] := MuFunc(s, phi[s], theta,n);
  od;#s
  return mu;
end);

#returns a transformation in S
MuInvFunc := function(cs, theta)
  local y, wy,t,u,wytinv, thetainv,x, m,xs,n;
  thetainv := InvertHashMapRelation(theta);
  m := HashMap();
  n := Size(Keys(theta)); # |X|
  for y in ImageOfHashMapRelation(theta) do
    wy := wyLabel(thetainv[y]);
    t := OnDepArg([], DependencyFunctionsOf(cs)[1]);
    wytinv := wyLabelInv(thetainv[OnPoints(y,t)]);
    u := OnDepArg([y], DependencyFunctionsOf(cs)[2]);
    #Print(wy*u*wytinv);
    for x in thetainv[y] do
      xs :=  wytinv(OnPoints(wy(x),u));
      #Print(x , " -> ",xs, "\n");
      if IsBound(m[x]) then
        if m[x] <> xs then Error(); fi; #this can be removed later
      else
        m[x] := xs;
      fi;
    od;
  od;
  return Transformation(List([1..n], i -> m[i]));
end;
MakeReadOnlyGlobal("MuInvFunc");

# checks whether the emulation composed with interpretation IE
# is the identity on S
MuCheck := function(theta, phi)
  local s, lifts,n,css, cs,ss;
  n := Size(ImageOfHashMapRelation(theta)); # |Y|
  for s in Keys(phi) do
    css := MuFunc(s, phi[s], theta, n);
    for cs in css do
      ss := MuInvFunc(cs,theta);
      if s <> ss then Print("s", s, " <> ss", ss, "\n"); return false; fi;
    od;
  od;
  return true;
end;
MakeReadOnlyGlobal("MuCheck");

# Detailed testing script for emulating by a cascade product
# creates a 2-level decomposition for the given semigroup and input
# surjective morphism and tests the emulation and interpretations
InstallGlobalFunction(TestEmulationWithMorphism,
function(S,theta, phi)
  local psi, mu, lifts;
  #1st to double check that we have a relational morphism
  if not IsTSRelMorph(theta, phi, OnPoints, OnPoints) then
    Info(EmulationInfoClass, 1, "Surjective Morphism failed!");
    return false;
  fi;
  #now creating the coordinatized version
  psi := Psi(theta);
  mu := Mu(theta, phi);
  # Can the cascade emulation the original

  if not IsTSRelMorph(psi, mu, OnPoints, OnCoordinates) then
    Info(EmulationInfoClass, 1, "Emulation failed!");
    return false;
  fi;
  if not IsTSRelMorph(InvertHashMapRelation(psi),
                      InvertHashMapRelation(mu),
                      OnCoordinates,
                      OnPoints) then
    Info(EmulationInfoClass, 1, "Interpretation failed!");
    return false;
  fi;
  lifts := ImageOfHashMapRelation(mu);
  #the size calculation might be heavy for bigger cascade products
  Info(EmulationInfoClass, 1,
       JoinStringsWithSeparator(
           ["|S|=", Size(S), " -> (",
            Size(lifts) , ",",
            Size(Semigroup(lifts)), ",",
            Size(Semigroup(Concatenation(List(Generators(S), s-> mu[s])))),
            ") (#lifts, #Sgp(lifts), #Sgp(mu(Sgens)))"],""));
  return true;
end);

# creates the default n(n-1) covering
InstallGlobalFunction(TestEmulation,
function(S)
local n, theta, phi;
  n := DegreeOfTransformationSemigroup(S);
  #the standard covering map described in the Covering Lemma paper
  theta := ThetaForPermutationResets(n);
  phi := PhiForPermutationResets(S);
  return TestEmulationWithMorphism(S, theta, phi);
end);
