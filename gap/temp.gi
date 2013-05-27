################################################################################
# some technical code - likely to be replaced by GAP library calls (once found)
################################################################################


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
