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
    r.t := Set(r.t);
    while Size(r.t)=1 and r.s = r.t[1].s do
      r.s := r.t[1].s;
      r.t := r.t[1].t;
      r.t := Set(r.t);  
    od;
    Perform(r.t,f);
  end;

  f(tg);
end;
