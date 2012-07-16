
for n in [5..100] do
  for m in [4..n] do
Display([n,m]);
sigma :=PermList(Concatenation([2..n-1],[1]));
tau:= PermList(Concatenation([1..n-3], [n-1, n+1, n], [n+2..n+m-3], [n-2]));

#Display(sigma); Display(tau);

G := GroupByGenerators([sigma,tau]);
Display(StructureDescription(G)); Print("Expected Degree: ", n+m-4, "\n");
 Print("\n");

od;

od;

