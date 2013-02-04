Read("RubikCube.g");
series := CompositionSeries(rubik_cube);
myseries := [series[1], series[2],series[3],series[10],series[11],series[22]];

FactorGroup(series[2],series[3]);


gens := GeneratorsOfGroup(myseries[1]);
#reps := [(), gens[1]];

t := [];
for i in [1,2,3,4,5] do
a :=  RightTransversal(myseries[i],myseries[i+1]);
Add(t,a); Print(Size(a)); Print("\n");
od;


#l := []; 
#for xi in reps do
#  for g in gens do
#   Print("xi=",xi,"\n g=",g, "\n xi*g=",xi*g,"\n");
#   Print("xi * g * (reps[(xi * g)])^-1) = ", xi * g * (reps[ (xi * #g)])^-1, "\n\n");  
#   Add(l,xi * g * (reps[ 1 ^ (xi * g)])^-1) ; 
#  od;
#od;





