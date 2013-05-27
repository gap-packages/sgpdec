#this direct calculation of does not work
#this gives different depth numbers and holonomyaction does not work on it 28.07.2010

_rec_depth := function(skeleton, eqclass, depth)
  local p,kids,pos;
  kids := PreImages(skeleton!.reversed_genincl_hassediag, eqclass.elems);
  for p in kids do
    #just to have access to the mutable record, Images seems to return immutable copies
    p :=  HTValue(skeleton!.imagesetlookup,p[1]).eqclass;
    if Size(p.rep) >= 1 then
      if p.depth  < depth+1 then 
         p.depth := depth+1;
      fi;
      _rec_depth(skeleton,p,depth+1);
    fi; 
  od;  
end;

depth := function(skeleton)
local maxdepth;
  HTValue(skeleton!.imagesetlookup,TopSet(skeleton)).eqclass.depth := 1;
  _rec_depth(skeleton, GetEqClass(skeleton, TopSet(skeleton)),1);
  
  #the singleton classes should be put together on one level
  maxdepth := 0;
  Perform(skeleton!.equivclasses,  function(x) if Size(x.rep) > 1 then maxdepth := Maximum(maxdepth, x.depth);fi;  ;end);
  Perform(skeleton!.equivclasses,  function(x) if Size(x.rep) = 1 then x.depth := maxdepth+1 ;fi;  ;end);
end;
