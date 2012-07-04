
#gives back a permutation
findRouteInGroup := function(pnt1, pnt2,G)
local g,k,gens,new, alreadychecked, tobeextended, tmpl, numofmuls;

  if pnt1 = pnt2 then return [(),0,0]; fi;
  alreadychecked := [()]; 
  tobeextended := [()];
  numofmuls := 1;
  gens := GeneratorsOfGroup(G);
  while not IsEmpty(tobeextended) do
    tmpl := [];
    for g in gens do
      for k in tobeextended do
        new := k * g;
	numofmuls := numofmuls + 1;
        #investigate the new element
        if pnt1 ^ new = pnt2 then
	  #we are done
	  return [new,numofmuls,Size(alreadychecked)];
        fi;
        if not (new in alreadychecked ) then
	  Add(alreadychecked,new);
	  Add(tmpl, new);
        fi;      
      od;
    od;
    tobeextended := tmpl;
  od;
  return  [new,numofmuls,Size(alreadychecked)];
end;

#gives back a permutation
#they should be in the same family, but this comes later
findRouteInCascadedGroup := function(cs1, cs2)
local i,deps,cpi,record,perm,time,space;

  deps := [];
  time := 0;
  space := 0;
  #getting the info object
  cpi := FamilyObj(cs1)!.cpi;
  for i in [1..Size(cs1)] do
    record := findRouteInGroup(cs1!.coords[i],cs2!.coords[i],cpi.original_components[i]);
    perm := record[1];
    time := time + record[2];
    space := space + record[3];
    Add(deps,[cs1!.coords{[1..(i-1)]},perm]); 
  od;
  return [DefineCascadedOperation(cpi,deps),time,space];
end;

testEfficiency := function(G,n)
local c,cpi,origens,derivedgens,nG,set,i,p1,p2,fres,cres;

  c := CascadeComponentsOfGroup(G);
  cpi := CascadeProductInfoStructure(c.components);
  origens := GeneratorsOfGroup(c.rightregular_group);
  derivedgens := [];
  for i in origens do
    Add(derivedgens, Flatten(DefineCascadedOperation(cpi, BuildDependencyFunction(c,i))));
  od;
  nG := Group(derivedgens);

  set := SetOfPermutationGroupToActOn(nG);

  for i in [1..n] do
    p1 := Random(set);
    p2 := Random(set);
    fres := findRouteInGroup(p1,p2,nG);

    cres := findRouteInCascadedGroup(Raise(cpi,p1),Raise(cpi,p2));
    Print("Time F ",fres[2]," C ",cres[2],"\n");
    Print("Space F ",fres[3]," C ",cres[3], "\n\n");
  od;

end;




RigthRegularGroup := function(G)
  return Range(RegularActionHomomorphism(G));
end;


