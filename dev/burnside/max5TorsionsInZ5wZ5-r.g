
max5Torsion5GensInZ5wrZ5 :=
[ (1,6,11,16,21)(2,7,12,17,22)(3,8,13,18,23)(4,9,14,19,24)(5,10,15,20,25),
  (1,5,4,3,2)(6,7,8,9,10),
  (1,2,3,4,5)(6,9,7,10,8)(11,12,13,14,15), 
  (1,5,4,3,2)(6,9,7,10,8)(11,13,15,12,14)(16,17,18,19,20),
  (1,2,3,4,5)(6,7,8,9,10)(11,12,13,14,15)(16,17,18,19,20)(21,22,23,24,25) ];


#max5Torsion2GensInZ5wrZ5 := [ ( 1, 6,11,16,21)( 2, 7,12,17,22)( 3, 8,13,18,23)( 4, 9,14,19,24)( 5,10,15,20,25),
                              ( 1, 5, 4, 3, 2)( 6, 7, 8, 9,10) ];


y := ( 1, 6,11,16,21)( 2, 7,12,17,22)( 3, 8,13,18,23)( 4, 9,14,19,24)( 5,10,15,20,25);

comps := [Z5,Z5];
yr := CPdef(comps, [
             [[],(1,2,3,4,5)]
                   ]);
xr := CPdef(comps, [
             [[()],(1,2,3,4,5)],
             [[(1,2,3,4,5)],(1,5,4,3,2)]
                ]);
x := CPflat(xr,comps); 
y := CPflat(yr,comps); 

symbols := [Z5symbols,Z5symbols];

CPdraw(xr,comps,symbols,"xr");
CPdraw(yr,comps,symbols,"yr");

