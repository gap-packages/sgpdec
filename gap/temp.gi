################################################################################
# some technical code - likely to be replaced by GAP library calls (once found)
################################################################################

#This is in 4.6
BindGlobal( "NumberElement_Cartesian", 
function(enum, x)    
  local n, mults, colls, sum, pos, i;

  n:=enum!.n;
  mults:=enum!.mults;
  colls:=enum!.colls;

  if Length(x)<>n then 
    return fail;
  fi;

  sum:=0;
  for i in [1..n-1] do 
    pos:=Position(colls[i], x[i])-1;
    if pos=fail then 
      return fail;
    fi;
    sum:=sum+pos*mults[i];
  od;
  
  pos:=Position(colls[n], x[n]);
  
  if pos=fail then 
    return fail;
  fi;

  return sum+pos;
end);

BindGlobal( "ElementNumber_Cartesian", 
function(enum, x)
  local n, mults, out, i, colls;

  if x>Length(enum) then 
    return fail;
  fi;

  x:=x-1;

  n:=enum!.n;
  mults:=enum!.mults;
  colls:=enum!.colls;
  out:=EmptyPlist(n);

  for i in [1..n-1] do
    out[i]:=QuoInt(x, mults[i]);
    x:=x-out[i]*mults[i];
    out[i]:=colls[i][out[i]+1];
  od;
  out[n]:=colls[n][x+1];

  return out;
end);

BindGlobal( "EnumeratorOfCartesianProduct2",
  function(colls)
    local new_colls, mults, k, i, j;
    
    if not ForAll(colls, IsCollection) and ForAll(colls, IsFinite) then
      Error( "usage: each argument must be a finite collection," );
      return;
    fi;
    new_colls:=[]; 
    for i in [1..Length(colls)] do 
      if IsDomain(colls[i]) then 
        new_colls[i]:=Enumerator(colls[i]);
      else
        new_colls[i]:=colls[i];
      fi;
    od;

    mults:=List(new_colls, Length);
    for i in [1..Length(new_colls)-1] do 
      k:=1;
      for j in [i+1..Length(new_colls)] do 
        k:=k*Length(new_colls[j]);
      od;
      mults[i]:=k;
    od;
    mults[Length(new_colls)]:=0;

    return EnumeratorByFunctions(ListsFamily, 
      rec( NumberElement := NumberElement_Cartesian,
           ElementNumber := ElementNumber_Cartesian,
           mults:=mults,
           n:=Length(colls),
           colls:=new_colls,
           Length:=enum-> Maximum([mults[1],1])*Length(new_colls[1])));
  end);
    
InstallGlobalFunction( "EnumeratorOfCartesianProduct",
    function( arg )
    # this mimics usage of functions Cartesian and Cartesian2
    if IsEmpty(arg) or ForAny(arg, IsEmpty) then 
      return EmptyPlist(0);
    elif Length( arg ) = 1  then
        return EnumeratorOfCartesianProduct2( arg[1] );
    else
        return EnumeratorOfCartesianProduct2( arg );
    fi;
    return;
end);