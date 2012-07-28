#############################################################################
##
## finiteset.gi           SgpDec package
##
## Copyright (C) 2008-2012
##
## Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
## Finite sets of integers. Wrapping boolean lists for speed and readability
## purposes
##

########CONSTRUCTORS####################

#FiniteSet directly from blist
InstallGlobalFunction(FiniteSetByBlist,
function(blist)
  return  Objectify(_FiniteSetType, rec(blist := blist));
end);

InstallGlobalFunction(FiniteSet,
function(arg)
  if Length(arg)=1 then
    #the size of universe is calculated
    return FiniteSetByBlist(BlistList([1..Maximum(arg[1])],arg[1]));
  else
    return FiniteSetByBlist(BlistList([1..arg[2]],arg[1]));
  fi;
end);

#copy constructor
InstallGlobalFunction(FiniteSetCopy,
function(A)
  return FiniteSetByBlist(ShallowCopy(A!.blist));
end);

#########SIZE################################
InstallGlobalFunction(SizeOfUniverse,
function(finiteset)
  return Size(finiteset!.blist);
end);

InstallGlobalFunction(IsSingleton,
function(finset)
  return SizeBlist(finset!.blist) = 1;
end);

InstallMethod(Size, "for a finite set",
        [IsFiniteSet  and IsFiniteSetBlistRep],
        x-> SizeBlist(x!.blist));

InstallMethod(IsEmpty, "for a finite set",
        [IsFiniteSet  and IsFiniteSetBlistRep],
        x-> (SizeBlist(x!.blist)=0) );


InstallOtherMethod(Length, "for a finite set",
        [IsFiniteSet and IsFiniteSetBlistRep],
        Size);

##########SET OPERATIONS#####################
#if the name is a noun then it returns a new inctance,
#if it is a verb then it changes the (first) parameter
InstallGlobalFunction(UnionFiniteSet,
function(listofFS)
local union,fset;
  union := BlistList([1 .. SizeOfUniverse(listofFS[1])],[  ]);
  for fset  in listofFS  do
    UniteBlist(union,fset!.blist); #TODO this can probably be improved
  od;
  return FiniteSetByBlist(union);
end);

InstallGlobalFunction(UniteFiniteSet,
function(A,B)
local union,fset;
    UniteBlist(A!.blist,B!.blist);
end);


InstallGlobalFunction( IntersectionFiniteSet,
function( listofFS )
local intersect,fset;
  intersect := BlistList( [1..SizeOfUniverse(listofFS[1])],
                       [1..SizeOfUniverse(listofFS[1])]  );
  for fset  in listofFS  do
    IntersectBlist( intersect, fset!.blist );
  od;
  return FiniteSetByBlist(intersect);
end);

InstallGlobalFunction(IntersectFiniteSet,
function(A,B)
local union,fset;
    IntersectBlist(A!.blist,B!.blist);
end);

InstallGlobalFunction(DifferenceFiniteSet,
function(A, B)
  return  FiniteSetByBlist(DifferenceBlist(A!.blist, B!.blist));
end);

InstallGlobalFunction(SubtractFiniteSet,
function(A, B)
  return  SubtractBlist(A!.blist, B!.blist);
end);

InstallGlobalFunction(ComplementOfFiniteSet,
function(A)
local copy;
  copy := FiniteSetCopy(A);
  ComplementFiniteSet(copy);
  return copy;
end);

InstallGlobalFunction(ComplementFiniteSet,
function(A)
  Apply(A!.blist, x->not x);
end);

InstallOtherMethod(IsSubset, "for two finite sets", true,
        [IsFiniteSet,
         IsFiniteSet],
function(A, B)
  return  IsSubsetBlist(A!.blist,B!.blist);
end);

InstallGlobalFunction(IsProperFiniteSubset,
function (A,B )
    return (Size(A) > Size(B)) and IsSubset(A,B);
end);

########MODIFY AND ACCESS THE ELEMENTS########################
InstallOtherMethod(Add,"for finite sets",[IsFiniteSet,IsInt],
function (finiteset , elem)
  finiteset!.blist[elem] := true;
end);

InstallOtherMethod(Remove,"for finite sets",[IsFiniteSet,IsInt],
function ( finiteset , elem)
  finiteset!.blist[elem] := false;
end);

InstallMethod(\in,
  "for an integer and a finite set",
  [IsInt, IsFiniteSet],
function(i, s)
  if i < 1 or i > Size(s!.blist) then return false;fi;
  return s!.blist[i];
end);

InstallGlobalFunction(MinFiniteSet,
function(A)
  if Size(A!.blist) = 0 then return fail; fi;
  return Position(A!.blist,true);
end);
#TODO Add MaxFiniteSet

InstallMethod(AsList,"for finite sets",[IsFiniteSet],
function ( finiteset )
  local n, result, j, blist, i;
  #an empty finite set
  n:=Size(finiteset!.blist);
  result := EmptyPlist(n);
  j:=0; blist:=finiteset!.blist;
  for i in [1..n] do
    if blist[i] then
      j:=j+1; result[j]:=i;
    fi;
  od;
  return result;
end);

###########ITERATOR#################################################

BindGlobal( "IsDoneIterator_FiniteSet",
  iter -> (iter!.pos = iter!.len));

BindGlobal( "NextIterator_FiniteSet",
function(iter)
  if iter!.pos = iter!.len then
    Error("<iter> is exhausted");
  fi;
  iter!.pos := iter!.pos + 1;
  while not iter!.blist[iter!.pos] do
    iter!.pos := iter!.pos + 1;
  od;
  return iter!.pos;
end);

BindGlobal("ShallowCopy_FiniteSet",
  iter -> rec(blist := iter!.list,
                       pos := iter!.pos,
                       len := iter!.len));

BindGlobal("IteratorFiniteSet",
function(A)
  local  iter;
  if Size(A) = 0 then # that does not work, maybe filter. IsEmpty(A) then
    iter := rec(
                ShallowCopy := ShallowCopy_FiniteSet,
                IsDoneIterator := x->true,
                NextIterator := fail);
  else
    iter := rec(
                blist := A!.blist,
                pos  := 0,
                len := Length(A!.blist),
                ShallowCopy := ShallowCopy_FiniteSet,
                IsDoneIterator := IsDoneIterator_FiniteSet,
                NextIterator := NextIterator_FiniteSet);
    #length
    while (not iter!.blist[iter.len]) and (iter.len > 0) do
      iter.len := iter.len-1;
    od;
  fi;
  return IteratorByFunctions(iter);
end);

InstallMethod(Iterator,
  "for a finite set",
  [IsFiniteSet],
function(A)
  return IteratorFiniteSet(A);
end);

InstallGlobalFunction(AllSubsets,
function(A)
local l, lc, result, bl,tmp;
  l := AsList(A);
  result := [];
  lc := EnumeratorOfCartesianProduct(ListWithIdenticalEntries(Size(l),
                [true, false]));
  for bl in lc do
    tmp := [];
    Perform([1..Size(bl)], function(x) if bl[x] then Add(tmp,l[x]);fi;end );
    Add(result,tmp);
  od;
  return List(result, x->FiniteSet(x,SizeOfUniverse(A)));
end);

###DISPLAY##############
InstallMethod( PrintObj,"for a finite set",
    [ IsFiniteSet ],
function( A )
local i,n,size;
  n := 0;
  size := Size(A);
  Print("{");
  for i in [1..SizeOfUniverse(A)] do
    if A!.blist[i] then
      Print(i);
      n := n + 1;
      if n < size then
        Print(",");
      fi;
    fi;
  od;
  Print( "}" );
end);

#to give arbitrary names to set elements
InstallGlobalFunction(FiniteSetPrinter,
function(finiteset, states)
  local str,i,l;
  str := "{";
  l := AsList(finiteset);
  for i in [1..Length(l)] do
    str := Concatenation(str, String(states[l[i]]));
    if i < Length(l) then
      str := Concatenation(str,",");
    fi;
  od;
  str := Concatenation(str,"}");
  return str;
end);

#Two finite sets are equal if they have the same underlying bitlists.
InstallOtherMethod(\=, "for two finite sets", IsIdenticalObj,
        [IsFiniteSet,
         IsFiniteSet],
function(A, B)
  return  A!.blist = B!.blist;
end);

InstallOtherMethod(\<, "for two finite sets", IsIdenticalObj,
        [IsFiniteSet,
         IsFiniteSet], 0,
function(A, B)
  return  A!.blist < B!.blist;
end);

#######ACTION RELATED############################
InstallGlobalFunction(OnFiniteSets,
function(A, t)
  local n, result, blist, i;
  #an empty finite set
  n:=SizeOfUniverse(A);
  result := BlistList([1..n],[]);
  blist:=A!.blist;
  for i in [1..n] do
    if blist[i] then
      result[i^t] := true;
    fi;
  od;
  return FiniteSetByBlist(result);
end);

#this function tells quickly if it is not the identity
InstallGlobalFunction(IsIdentityOnFiniteSet,
function(t, s)
local blist, i;
  blist:=s!.blist;
  for i in [1..SizeOfUniverse(s)] do
    if blist[i] and not i^t=i then
      return false;
    fi;
  od;
  return true;
end);

###########FOR ORB'S HASHTABLE FUNCTIONS#################################
HashFunctionForFiniteSet:=function (v, data)
local  i, res, n, blist;
  res := 0; n:=SizeOfUniverse(v); blist:=v!.blist;
  for i in [1..n] do
    if blist[i] then
      res := (res * data[1] + i) mod data[2];
    fi;
  od;
  return res + 1;
end;

InstallMethod( ChooseHashFunction, "for finite sets",
[IsFiniteSet, IsInt],
  function(p,hashlen)
    return rec(func := HashFunctionForFiniteSet, data := [101,hashlen]);
end);

#returns the integer value of the set as a binary number
#this is unique, unlike the hash value
InstallGlobalFunction(FiniteSetID,
function(A)
local i, sum;
  sum := 0;
  for i in [1..Size(A!.blist)] do
    if A!.blist[i] then
      sum := sum + 2^(i-1);
    fi;
  od;
  return sum;
  #here is the nice code, but the above is 18% faster
  #return Sum(List(AsList(A), x->2^(x-1)));
end);