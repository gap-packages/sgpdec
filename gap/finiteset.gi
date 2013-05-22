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

InstallGlobalFunction(OnFiniteSets,
function(A, t)
  local n, result, blist, i;
  #an empty finite set
  n:=Size(A);
  result := BlistList([1..n],[]);
  for i in [1..n] do
    if A[i] then
      result[i^t] := true;
    fi;
  od;
  return result;
end);

#this function tells quickly if it is not the identity
InstallGlobalFunction(IsIdentityOnFiniteSet,
function(t, blist)
local i;
  for i in [1..Size(blist)] do
    if blist[i] and not i^t=i then
      return false;
    fi;
  od;
  return true;
end);

FiniteSetPrinter := function(bl)
local i,n,size;
  n := 0;
  size := SizeBlist(bl);
  Print("{");
  for i in [1..Size(bl)] do
    if bl[i] then
      Print(i);
      n := n + 1;
      if n < size then
        Print(",");
      else
        break;
      fi;
    fi;
  od;
  Print( "}" );
end;


#redefining, this is ugly with the ranks at the moment TODO
InstallMethod(ViewObj,"for a blist (redefined)",
    [ IsBlistRep ],333, FiniteSetPrinter);

InstallMethod(PrintObj,"for a blist (redefined)",
    [ IsBlistRep ],333, FiniteSetPrinter);

InstallMethod(Display,"for a blist (redefined)",
    [ IsBlistRep ],333, FiniteSetPrinter);
