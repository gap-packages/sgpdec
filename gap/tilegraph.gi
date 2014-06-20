# redoing the whole things for the whole tile graph instead of tile chains
TileGraph := function(sk)
  local tg,f;
  f := function(r)
    Perform(TilesOf(sk,r.s),function(x) Add(r.t,rec(s:=x,t:=[]));end);
    Perform(r.t,f);
  end;
  tg := rec(s:=BaseSet(sk),t := []);
  f(tg);
  return tg;
end;

OnTileGraph := function(tg, t)
  local f;
  f := function(r) r.s := OnFiniteSet(r.s,t);Perform(r.t,f); end;
  f(tg);
end;

CollapseTileGraph := function(tg)
  local f;
  f := function(r)
    local pos;
    if IsEmpty(r.t) then return r; fi;
    r.t := Set(r.t,f);
    pos := First([1..Size(r.t)], x->r.t[x].s=r.s);
    if pos <> fail then 
      return r.t[pos];
    fi;
    return r;
  end;

  return f(tg);
end;
