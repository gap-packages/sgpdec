gap> cs := ChiefSeries(AlternatingGroup(4));                 
[ Alt( [ 1 .. 4 ] ), Group([ (1,3)(2,4), (1,2)(3,4) ]), Group(()) ]
gap> FLTransversals(cs);
[ RightTransversal(Alt( [ 1 .. 4 ] ),Group([ (1,3)(2,4), (1,2)(3,4) ])), 
  <enumerator of perm group> ]
gap> FLComponents(cs);
rec( components := [ Group([ (1,2,3), (1,3,2) ]), Group([ (1,2)(3,4), (1,3)
      (2,4) ]) ], 
  transversals := [ RightTransversal(Alt( [ 1 .. 4 ] ),Group([ (1,3)
      (2,4), (1,2)(3,4) ])), <enumerator of perm group> ] )
gap> DisplayFLComponents(cs);
1: (3,C3)
2: (4,C2 x C2)
