#lines up
IdempotentMap := function(P,Q,n)
  local l,i;
  l := [];
  for i in [1..Size(P)] do
    l[P[i]] := Q[i];
  od;
  l := List([1..n],
            function(x) if IsBound(l[x]) then return l[x];
    else
      return Q[Size(Q)];
      #      if x in Q then return x; else return Q[Size(Q)];fi;
    fi;end);
  Display(l);
  return Transformation(l);
end;
