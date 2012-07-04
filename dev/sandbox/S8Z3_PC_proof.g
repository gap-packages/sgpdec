LoadAllGroupInfo();

conv := PermList([14,17,4,1,15,3,7,20,2,5,11,8,6,18,22,10,16,13,19,23,9,12,24,21]);

PC := ConjugateGroup(pocket_cube,conv);      

cstr := CascadedStructure([SymmetricGroup(8), Z3]);           

gens := []; for i in GeneratorsOfGroup(PC) do Add(gens, BuildNC(cstr,i));od;

fgens := List(gens, x -> Collapse(x));

newPC := Group(fgens);

Order(newPC) = Order(pocket_cube);

isom :=  IsomorphismGroups(pocket_cube, newPC);      
