##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2010 University of Hertfordshire, Hatfield, UK
##


## Parrondo-van Leeuven-Nehaniv 7 state automaton for p53-mdm2 system

a := TransformationFromElementaryCollapsing([3,7],7);
b := TransformationFromElementaryCollapsing([1,2],7);
c := TransformationFromElementaryCollapsing([2,1],7);
d := TransformationFromElementaryCollapsing([3,2],7);
e := TransformationFromElementaryCollapsing([2,3],7);
p := TransformationFromElementaryCollapsing([5,3],7);
q := TransformationFromElementaryCollapsing([3,5],7);
r := TransformationFromElementaryCollapsing([4,5],7);
s := TransformationFromElementaryCollapsing([3,4],7);
t := TransformationFromElementaryCollapsing([7,3],7);
u := TransformationFromElementaryCollapsing([1,6],7);
v := TransformationFromElementaryCollapsing([7,1],7);
w := TransformationFromElementaryCollapsing([1,7],7);
x := TransformationFromElementaryCollapsing([5,6],7);
y := TransformationFromElementaryCollapsing([7,6],7);
z := TransformationFromElementaryCollapsing([6,7],7);

parrondocln_gens:=[a,b,c,d,e,p,q,r,s,t,u,v,w,x,y,z];

hdp := HolonomyDecomposition(Semigroup(parrondocln_gens));
