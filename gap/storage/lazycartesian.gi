#############################################################################
##
## lazycartesian.gi           SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## The cartesian product of sets in a list but with lazy evaluation.
##

###############################################################
########### NEW FUNCTIONS #####################################
###############################################################

InstallGlobalFunction("LazyCartesian",
function(sets)
local size, bases, i;
  #doing the empty list
  if IsEmpty(sets) then return [sets]; fi;
  #calculating the size of the cartesian product                    
  size := Product(List(sets, x -> Length(x)));
  #obtaining the bases for the digit positions
  #the ones are at the last digit
  bases := [1];      
  for i in [1..Length(sets)-1] do
    Add(bases, Length(sets[i]) * LastElementOfList(bases));
  od;                    
  return Objectify(LazyCartesianType, rec(sets := sets,bases:=bases, size := size));
end
);

#Just augments the prefix with the first element of the remaining state sets.
#InstallGlobalFunction("LazyCartesianFirstWithPrefix",
#function(lazycart,prefix)
#local i,result;
#  result := ShallowCopy(prefix);
#  for i in [Length(prefix)+1..Length(lazycart!.sets)] do
#    Add(result,lazycart!.sets[i][1]);
#  od;
#  return result;
#end
#);

#Just augments the prefix with the last element of the remaining state sets.
#InstallGlobalFunction("LazyCartesianLastWithPrefix",
#function(lazycart,prefix)
#local i,result;
#  result := ShallowCopy(prefix);
#  for i in [Length(prefix)+1..Length(lazycart!.sets)] do
#    Add(result,LastElementOfList(lazycart!.sets[i]));
#  od;
#  return result;
#end
#);


###############################################################
############ OLD METHODS ######################################
###############################################################

# for accessing the list elements
InstallOtherMethod( \[\],
    "for lazy cartesian products",
    [ IsLazyCartesian, IsPosInt ],
function( lazycart, pos )
local coords,i,remainder,tmp,bases, sets,n;
  #for quicker access we put these into local variables
  bases := lazycart!.bases;
  sets := lazycart!.sets;
  n := Length(bases);
  
  #adjusting to zero start
  pos := pos - 1;

  coords := [];
  for i in Reversed([2..n]) do
    remainder := pos mod bases[i];
    pos := pos - remainder;
    Add(coords, pos / bases[i]);
    pos := remainder;
  od;
  #adding the 1s                   
  Add(coords,pos);                   
  
  #translating coords the real values from sets (reusing the list)
  coords := Reversed(coords);                   
  for i in [1..Length(coords)] do
    coords[i] := sets[i][coords[i]+1]; #+1 is the correction
  od;                   
  return coords;
end 
);

InstallMethod( PositionCanonical,
    "for lazy cartesians",
    [ IsLazyCartesian, IsList],
    function (lazycart, coords )
local i,sum,bases,sets,n;
  #for quicker access we put these into local variables
  bases := lazycart!.bases;
  sets := lazycart!.sets;
  n := Length(coords);

  sum := 0;             
  for i in [1..Length(coords)] do
    sum := sum + ((Position(sets[i],coords[i])-1) * bases[i]);
  od;
  #adjusting to one start
  return sum+1;
end );



# The size of the cartesian product.
InstallMethod(Length,"for lazy cartesian products",true,[IsLazyCartesian],
function(lazycart)
  return lazycart!.size;
end
);

