DepthVector := function(str)
  local openers,closers,last,depth, i, depthvect;
  openers := "[(";
  closers := ")]";
  depth := 0;
  depthvect := EmptyPlist(Size(str));
  for i in [1..Size(str)] do
    if str[i] in openers then
      depth := depth + 1;
    elif str[i] in closers then
      depth := depth - 1;
    fi;
    depthvect[i]:= depth;
  od;
  return depthvect;
end;

# finding the components in the string
LinNotComps := function(str)
  local comps,cuts, last,i;
  cuts := Positions(DepthVector(str),0);
  last := 0;
  comps := [];
  for i in [1..Size(cuts)] do
    Add(comps, str{[last+1..cuts[i]]});
    last := cuts[i];
  od;
  return comps;
end;

#recursively fill the list maps [point, image] tuples
AllMapsFromLinNot := function(str)
  local maps;
  maps := [];
  if str[1] = '(' then
    # permutation
  else
  fi;
  return maps;
end;
