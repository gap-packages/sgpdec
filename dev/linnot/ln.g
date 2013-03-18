# assigns how many parentheses are open to each point, 0 means top level
DepthVector := function(str)
local openers,closers,depth,i,depthvect;
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

#splitting string at given positions
SplitStringAtPositions := function(str, poss)
  local pieces, last,i;
  last := 0;
  pieces := [];
  for i in [1..Size(poss)] do
    Add(pieces, str{[last+1..poss[i]]});
    last := poss[i];
  od;
  return pieces;
end;

# finding comma separated values (only at zero depth)
CommaComps := function(str)
  local cuts;
  if IsEmpty(str) then return [];fi;
  cuts := Intersection(Positions(DepthVector(str),0),
                  Positions(str,','));
  Add(cuts, Size(str)); #to have the last pieve as well
  #post process: removing dangling commas
  return List(SplitStringAtPositions(str, cuts),
              function(s) if s[Size(s)]=',' then return s{[1..Size(s)-1]};
                          else return s; fi;end);
end;

#just remove outer parentheses
CutParentheses := function(str) return str{[2..Size(str)-1]}; end;

#this gets the last image from w or [x,y,z;w]
GetImgVal := function(str)
local s, poss, lastpos;
  if not('[' in str)  then return str;
  else
    s := CutParentheses(str);
    poss := Positions(str, ';');
    lastpos := poss[Size(poss)];
    return s{[lastpos..Size(s)]};
  fi;
end;

#this gets the preimages [x,y,z] from [x,y,z;w]
GetPreImgs := function(str)
local s, poss, lastpos;
    s := CutParentheses(str);
    poss := Positions(str, ';');
    lastpos := poss[Size(poss)];
    return CommaComps(s{[1..lastpos-2]});
end;

#recursively fills the list maps [point, image] tuples
AllMapsFromLinNotComp := function(str,maps)
  local l,i,comps,img;
  comps := [];
  if str[1] = '(' then      # permutation
    comps := CommaComps(CutParentheses(str));
    l := List(comps, s->Int(GetImgVal(s)));
    if not IsEmpty(l) then Add(l, l[1]);fi; #closing the circle
    for i in [1..Size(l)-1] do
      Add(maps, [l[i],l[i+1]]);
    od;
  elif str[1] = '[' then     # transformation
    comps := (GetPreImgs(str));
    l := List(comps, s->Int(GetImgVal(s)));
    img := Int(GetImgVal(str));
    Perform([1..Size(l)], function(x)Add(maps,[l[x],img]);end);
  fi;
  #doing the recursion
  Perform(comps,function(x)AllMapsFromLinNotComp(x,maps);end);
  return maps;
end;

InstallOtherMethod(AsTransformation,"for cascade and int",[IsString,IsPosInt],
function(s,n)
local maps,scc,l,m;
  maps := [];
  l := [1..n];
  for scc in SplitStringAtPositions(s, Positions(DepthVector(s),0)) do
    AllMapsFromLinNotComp(scc,maps);
  od;
  # patching the identity map with the collected maps
  for m in maps do l[m[1]] := m[2];od;
  return Transformation(l);
end);