################################################################################
# some technical code - likely to be replaced by GAP library calls (once found)
################################################################################

InstallMethod(TransformationOp, "for object, list, function",
[IsObject, IsList, IsFunction],
function(f, D, act)
  local perm, out, new, i, pnt;

  perm:=();

  if IsPlistRep(D) and Length(D)>2 and CanEasilySortElements(D[1]) then
    if not IsSSortedList(D) then
      D:=ShallowCopy(D);
      perm:=Sortex(D);
      D:=Immutable(D);
      SetIsSSortedList(D, true);
    fi;
  fi;

  out:=EmptyPlist(Length(D));
  i:=0;

  for pnt in D do
    new:=PositionCanonical(D, act(pnt, f));
    if new=fail then
      return fail;
    fi;
    i:=i+1;
    out[i]:=new;
  od;

  out:=Transformation(out);

  if not IsOne(perm) then
    out:=out^(perm^-1);
  fi;

  return out;
end);

#This is in 4.6
if not IsBound(NumberElement_Cartesian) then
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
fi;

if not IsBound(ElementNumber_Cartesian) then
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
fi;

if not IsBound(EnumeratorOfCartesianProduct2) then
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
fi;

if not ISBOUNDENUMERATORCARTESIANPRODUCT then
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
fi;

if not ISBOUNDACTIONREPRESENTATIVES then
  #backporting from 1.0 branch of Semigroups
  # JDM generalise this
# returns a list of points in the domain of the action of the semigroup 
# from which every other point in the domain can be reached by applying
# elements of the semigroup.
InstallMethod(ActionRepresentatives, "for a transformation semigroup",
[IsTransformationSemigroup],
function(s)
  local n, base, gens, nrgens, j, seen, record, out, o, i;
  
  n:=DegreeOfTransformationSemigroup(s);
  base:=[1..n];
  gens:=GeneratorsOfSemigroup(s);
  nrgens:=Length(gens);
  j:=0;
  repeat   
    j:=j+1;
    base:=Difference(base, ImageSetOfTransformation(gens[j]));
  until base=[] or j=nrgens;

  seen:=[];
  record:=rec();
  record.gradingfunc:=function(o,x)
    if x in seen then
      return true;
    else
      Add(seen, x);
      return false;
    fi;
  end;
  record.onlygrades:=function(x,unused) return x=false; end;
  record.onlygradesdata:=fail;
  record.treehashsize:=NextPrimeInt(n);
  
  out:=[]; 
  for i in base do  
    o:=Orb(gens, i, OnPoints, record);
    Enumerate(o);
    Add(out, o[1]);
  od;
  
  base:=Difference([1..n], seen);
  seen:=[];
  while base<>[] do
    i:=base[1];
    o:=Orb(gens, i, OnPoints, record);
    Enumerate(o);
    Add(out, o[1]);
    base:=Difference(base, seen);
  od;
  return out;
end);
  
fi;
