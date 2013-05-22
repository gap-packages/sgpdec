# functions for imitating finiteset functions using blists

InstallGlobalFunction(IsSingleton,
function(finset)
  return SizeBlist(finset) = 1;
end);

InstallGlobalFunction(IsProperFiniteSubset,
function (A,B)
    return SizeBlist(A) > SizeBlist(B) and IsSubsetBlist(A,B);
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
