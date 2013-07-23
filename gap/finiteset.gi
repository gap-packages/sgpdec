#############################################################################
##
## finiteset.gi           SgpDec package
##
## Copyright (C) 2010-2013
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Just a wrap around blists to behave as finite sets.
##

# functions for imitating finiteset functions using blists
InstallGlobalFunction(FiniteSet,
function(arg)
  if Length(arg)=1 then
    #the size of universe is calculated
    return BlistList([1..Maximum(arg[1])],arg[1]);
  else
    return BlistList([1..arg[2]],arg[1]);
  fi;
end);

InstallGlobalFunction(IsSingleton,
function(finset)
  return SizeBlist(finset) = 1;
end);

InstallGlobalFunction(IsProperFiniteSubset,
function (A,B)
    return SizeBlist(A) > SizeBlist(B) and IsSubsetBlist(A,B);
end);

# TODO: this should be called OnBlistList
InstallGlobalFunction(OnFiniteSet,
function(A, t)
  local n, result, blist, i;
  #an empty finite set
  n:=Size(A);
  result := BlistList([1..n],[]);
  for i in [1..n] do
    if A[i] then
      result[OnPoints(i,t)] := true;
    fi;
  od;
  return result;
end);

#TODO why this does not work?
# just registering the above action as a method for ^
InstallOtherMethod(\^, "for finite set (blist) and transformation (SgpDec)",
[IsBlist, IsTransformation], OnFiniteSet);


#this function tells quickly if it is not the identity
InstallGlobalFunction(IsIdentityOnFiniteSet,
function(t, blist)
local i;
  for i in [1..Size(blist)] do
    if blist[i] and not OnPoints(i,t)=i then
      return false;
    fi;
  od;
  return true;
end);

################################################################################
### ToggleFiniSetDisplay #######################################################
InstallGlobalFunction(SgpDecFiniteSetDisplayOn,
function()
  SetUserPreference("DisplayTrueValuePositionsBlist",true);
end);

InstallGlobalFunction(SgpDecFiniteSetDisplayOff,
function()
  SetUserPreference("DisplayTrueValuePositionsBlist",false);
end);

InstallGlobalFunction(TrueValuePositionsBlistString,
function(arg)
local bl,i,n,size,str,states;
 bl := arg[1];
 if IsBound(arg[2]) then
 # 2nd argument if present contains the list of state names
  states := arg[2];
 else
 # use state number for the name of the state
  states := [1..Size(bl)];
 fi;
  n := 0;
  size := SizeBlist(bl);
  str:="{";
  for i in [1..Size(bl)] do
    if bl[i] then
      str := Concatenation(str,String(states[i]));
      n := n + 1;
      if n < size then
        str := Concatenation(str,",");
      else
        break;
      fi;
    fi;
  od;
  str := Concatenation(str,"}");
  return str;
end);

# TODO there is a bit of a confusion which method to redefine
InstallMethod(ViewObj,"for a blist (SgpDec)",
    [ IsBlistRep ],5,
function(bl)
  if UserPreference ("DisplayTrueValuePositionsBlist") then
    Print(DisplayString(bl));
  else
    TryNextMethod();
  fi;
end);

InstallMethod(DisplayString,"for a blist (SgpDec)",
    [ IsBlistRep ],5,
function(bl)
  if UserPreference ("DisplayTrueValuePositionsBlist") then
    return TrueValuePositionsBlistString(bl);
  else
    TryNextMethod();
  fi;
end);

################################################################################
# Hash function for blists - salvaged from Citrus
InstallGlobalFunction(HashFunctionForBlist,
function(v, data)
  return ORB_HashFunctionForIntList(ListBlist([1..Length(v)], v), data);
end);

InstallMethod(ChooseHashFunction, "for blist and pos. int.",
[IsBlistRep, IsPosInt],
function(p, hashlen)
  return rec(func := HashFunctionForBlist, data := [101, hashlen]);
end);
