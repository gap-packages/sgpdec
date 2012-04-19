#handmade generators (obsolete)
p1 := PermList([14,13,16,15, 10,9,12,11, 6,5,8,7, 2,1,4,3]);
p2 := PermList([15,16,13,14, 11,12,9,10, 7,8,5,6, 3,4,1,2]);
p3 := PermList([8,7,6,5, 4,3,2,1, 16,15,14,13, 12,11,10,9]);
p4 := PermList([12,11,10,9, 16,15,14,13, 4,3,2,1, 8,7,6,5]);


2x2merlingraph := [[1,2],[2,1],
        [1,3],[3,1],
        [2,4],[4,2],
        [3,4],[4,3]];

2x2merlingroup := Group(hgn_Generators(Z2,2x2merlingraph));
