LinNotComps := function(str)
  local comps,openers,closers, pos,last,depth, i;
  openers := "[(";
  closers := ")]";
  last := 0;
  depth := 0;
  comps := [];
  for i in [1..Size(str)] do
    if str[i] in openers then
      depth := depth + 1;
    elif str[i] in closers then
      depth := depth - 1;
    fi;
    if depth = 0 then
      Add(comps, str{[last+1..i]});
      last := i;
    fi;
  od;
  if IsEmpty(comps) then return [str]; fi;
  return comps;
end;
