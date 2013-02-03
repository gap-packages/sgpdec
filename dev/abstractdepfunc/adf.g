##########abstracting stuff

# classifying the elements in the list according to the 
# value returned by a function
#WARNING though this does sorting it is definitely not an optimized implementation! 
SGPDEC_Classify := function(l, funct)
local imgs, preimgs;
  #first we collect the unique images of funct on the elements on lists
  imgs := DuplicateFreeList(List(l, x -> funct(x)));
  #sort the imgs for some efficiency
  Sort(imgs);
  #then we collect the preimages
  preimgs := List([1..Length(imgs)], x->[]);
  Perform(l , function(x) Add(preimgs[Position(imgs,funct(x))],x);end);
  return rec(values := imgs ,classes := preimgs);
end;

#displaying the results returned by SGPDEC_Classify
SGPDEC_ShowClasses := function(classrec)
local i;
  for i in [1..Length(classrec.values)] do
    Print(classrec.values[i],"---",classrec.classes[i],"\n");
  od;
end;

#given two coordinate tuples this returns the positions
#of differing values
_depfunctable_VariedPositionsNC := function(l1, l2)
  return Filtered([1..Length(l1)], x -> l1[x] <> l2[x]);
end;

#sorting for sets of varied positions, first bigger sets then default <
BySizeSorter := function(v,w)
if Size(v) <> Size(w) then
  return Size(v)>Size(w);
else
  return v>w;
fi;
end;
MakeReadOnlyGlobal("BySizeSorter");

#input coords with the same size and the sizes of the statesets
#it returns an abstract state
_depfunctable_AMaximalAbstractState := function(coords, sizevector)
local acoordtup,abstate,vpositionset,prodsize, concstates, variablepositionsets;
  #in case there is nothing to do
  if IsEmpty(coords) then return fail;fi;
  #just pick 1 coordtuple, the first is a sure bet
  acoordtup :=  coords[1];   
  #get the variable position sets
  variablepositionsets := DuplicateFreeList(
      List(coords,  x -> _depfunctable_VariedPositionsNC(acoordtup,x)));
  #sort by size getting smaller
  Sort(variablepositionsets, BySizeSorter);
  #start the loop going down in size of variable position set
  for vpositionset in variablepositionsets do
    abstate := ShallowCopy(acoordtup);          
    Perform(vpositionset, function(y) abstate[y]:=0;end);
    prodsize :=  Product(sizevector{vpositionset});
    concstates := Filtered(coords, x -> abstate = x or IsStrictlyMoreAbstract(abstate,x));
    if prodsize = Size(concstates) then
      #return the abstract state we found (since we sorted it that way, it should be maximal)
      return rec(abstractstate := abstate,concretestates := concstates);
    fi;      
  od; 
  return fail;
end;

#input coords with the same size and the sizes of the statesets
#it returns a set of abstract states covering coords
_depfunctable_AbstractingCoordCollection := function(coords, sizevector)
local newcoords, absrec, mcoords;
  newcoords := [];
  #the idea is the get an abstract state in each step and remove the covered concretes 
  mcoords := ShallowCopy(coords);
  absrec := _depfunctable_AMaximalAbstractState(mcoords, sizevector);
  while (absrec <> fail) do
    Perform(absrec.concretestates, function(l) Remove(mcoords,Position(mcoords,l));end);
    Add(newcoords, absrec.abstractstate);
    absrec := _depfunctable_AMaximalAbstractState(mcoords, sizevector);
  od;
  Append(newcoords,mcoords);
  return newcoords;
end;

DepFuncTableFromCascOp :=
function(cascop)
local depmaps,levelled,i,j,images,depfunctable,acoord, acoords, sizevector;
  sizevector := List(StateSets(CascadeShellOf(cascop)), x->Size(x));
  depfunctable := [];
  #extract dependencymaps
  depmaps  := DependencyMapsFromCascadedOperation(cascop);
  #classifying them by levels
  levelled := SGPDEC_Classify(depmaps, x -> Length(x[1]));
  for i in [1..Size(levelled.classes)] do
    #classify by images
    images := SGPDEC_Classify(levelled.classes[i], x -> x[2]);
    #loosing the images in the classes
    images.classes := List(images.classes, x -> List(x, y -> y[1]));
    for  j in [1..Size(images.classes)] do
      acoords := _depfunctable_AbstractingCoordCollection(images.classes[j], sizevector);
      for acoord in acoords do 
        RegisterNewDependency(depfunctable, acoord, images.values[j]);
      od;
    od;   
  od;
  return depfunctable;
end);
