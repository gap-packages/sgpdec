################################################################################
##  SgpDec                                   Relations represented as HashMaps
##  Copyright (C) 2024                                  Attila Egri-Nagy et.al
################################################################################
# Relations represented as set-valued hash-maps, using the HashMap
# from the datastructures package.
# The only extra assumption is that the values are collections (sets).
# There is no data type defined, just the name.
# Naming: HashMapRelation is a relation represented by a set-valued HashMap.
# generic variable name: hmr

# given a relation hmr this returns all the distinct elements from
# all image sets
InstallGlobalFunction(ImageOfHashMapRelation,
function(hmr)
  return AsSet(Concatenation(AsSet(Values(hmr))));
end);

# turning around a relation: if (s,t) is in hmr,
# then (t,s) will be in the inverse
InstallGlobalFunction(InvertHashMapRelation,
function(hmr)
  local m;
  #putting in all values as keys with empty value set for now
  m := HashMap(List(ImageOfHashMapRelation(hmr),
                    x -> [x,[]]));
  Perform(Keys(hmr),
         function(k)
           Perform(hmr[k], #we put all related elements into the mutable lists
                  function(v)
                    AddSet(m[v], k);
                  end);
         end);
  return m;
end);

# A relation is injective if there is no overlap between the image sets.
# We incrementally build the union of image sets, and check for empty
# intersection of the result so far and next image set.
InstallGlobalFunction(IsInjectiveHashMapRelation,
function(hmr)
  local coll,imgs;
  coll := [];
  for imgs in Values(hmr) do
    if not IsEmpty(Intersection(coll,imgs)) then
      return false; #not injective
    fi;
    coll := Union(coll, imgs); #collect all the elements so far
  od;
  return true; #there was no overlap, so it is injective
end);

# it is injective if the inverse has singletons, i.e. the preimages are singletons
# for testing purposes
InstallGlobalFunction(IsInjectiveHashMapRelation2,
function(rel)
  return ForAll(Values(InvertHashMapRelation(rel)), coll -> Size(coll) = 1);
end);
