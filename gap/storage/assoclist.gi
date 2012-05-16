#############################################################################
##
## Associative List (implementation)
##
## Copyright (C)  Attila Egri-Nagy
##

#construct an associative list loaded based on keys and values
InstallMethod(AssociativeList,"for two lists", true, [IsList, IsList],0,
function(keys, values)
  local assoclist,i,pos;
  #sanity check
  if Size(keys) <> Size(values) then return fail; fi;

  assoclist := rec(keys:=[], values:=[]);
  for i in [1..Length(keys)] do
    pos := PositionSorted(assoclist.keys, keys[i]);
    Add(assoclist.keys,keys[i],pos);
    Add(assoclist.values, values[i], pos);
  od;
  return Objectify(AssociativeListType, assoclist);
end);

#mapping keys to their positions
InstallOtherMethod(AssociativeList,
        "for a list mapping elemetns to their positions", true, [IsList],0,
function(keys)
  return AssociativeList(keys,[1..Length(keys)]);
end);

#an empty associative list
InstallOtherMethod(AssociativeList,
        "empty assoclist", true, [],0,
function()
  return Objectify(AssociativeListType,
                 rec(keys:=[], values:=[]));
end);

# unfortunately list assignment works only with integrals
# so we need a dedicated assign function
InstallGlobalFunction(Assign,
function(assoclist, key, value)
  local pos;
  pos := Position(assoclist!.keys, key);
    if pos = fail then
      pos := PositionSorted(assoclist!.keys, key);
      Add(assoclist!.keys,key,pos);
      Add(assoclist!.values, value, pos);
    else
        assoclist!.values[pos] := value;
    fi;
end);

#it gives back the keys
InstallGlobalFunction(Keys,
function(assoclist)
    return assoclist!.keys;
end);

#accessing elements by arbitrary indices
InstallOtherMethod( \[\],
    "for associative lists",
    [ IsAssociativeList, IsObject],
function( assoclist, key )
  local pos;
  pos := Position(assoclist!.keys, key);
  if pos <> fail then
    return assoclist!.values[pos];
  else
    return fail;
  fi;
end
);

#if the keyset is the same then we can combine the values
InstallGlobalFunction(CombinedAssociativeList,
function(l1,l2)
local k, l;
  if Keys(l1) <> Keys(l2) then 
      Print("#W Different keysets cannot be combined!\n");      
      return fail;      
  fi;
  l :=  AssociativeList();
  for k in Keys(l1) do
    Assign(l, k, [l1[k],l2[k]]);
  od;
  return l;
end);

#values -> keys, but obviously list valued
InstallGlobalFunction(ReversedAssociativeList,
function(al)
local nl,k,val,l;
  nl := AssociativeList();
  for k in Keys(al) do
      val := al[k];      
      if val in Keys(nl) then
          l := nl[val];
          AddSet(l,k);
      else
          Assign(nl,val,[k]);
      fi;
  od;  
  return nl;  
end);

InstallOtherMethod(\=, "for two associative lists", IsIdenticalObj,
        [IsAssociativeList, 
         IsAssociativeList], 0, 
    function(A, B) 
        return  A!.keys = B!.keys and A!.values = B!.values;
    end);


InstallMethod( PrintObj,"for an associative list",
        [ IsAssociativeList ],
function( al )
local key;
  if IsEmpty(Keys(al)) then
    Print("empty associative list");
  else
    for key in Keys(al) do
      Print(key," -> ", al[key],"\n");
    od;
  fi;
end);