

for i in [3..15] do
  for j in [i..15] do
    for m in [1..Minimum([(i-1),(j-1)])] do

    NumNodes := i + j - (m+1);

Print("Theta graph: ");
    Display([i,j,m]);
#Print("***\n");;
 
#    S := Semigroup(
#                List(ThetaGraph(i,j,m),
#                     x -> TransformationFromElementaryCollapsing(x, NumNodes)
#                     )
#                  );
#    hd := HolonomyDecomposition(S);
#f := DotSemigroupAction(S,[1..NumNodes],OnPoints);
#FileString(Concatenation("~/Theta-",String(i),"-",String(j),"-",String(m),".dot"),f);

  Print("Rank of Defect One: ", NumNodes-1,"\n");

# cycle the first i-1 nodes, leaving others fixed:
tau := PermList(Concatenation([2..i-1],[1],[i],[i+1..NumNodes]));

# cycle around both loops omitting internal overlap nodes :
sigma := PermList(Concatenation([2..i-m],[i+1],[i-m+1..i-1],[i],[i+2..NumNodes],[1]));

flag :=0;

Display(tau); Display(sigma);


tausigma := sigma^-1 * tau * sigma; 
Print("tau^sigma tau-inverse:", tausigma * tau^-1,"\n");
p := tausigma * (tau^sigma * tau^-1) * tausigma^-1;
Print("(tau^sigma tau-inverse)^(tau^sigma-inv):", p, "\n" );

tau *p *;

#p := sigma^-w * tau^w2 * sigma^w * tau^-w2 * sigma^e *tau^f *sigma^g * tau^h;
#p := sigma^w * tau^w2 * sigma^e * tau^f *sigma^(m-1);
if flag=0 and ( (p^3=() and Length(MovedPoints(p))=3) or (p^2=() and Length(MovedPoints(p))=2))  then  flag:=1; fi;
if flag = 1 then Print("3-cycle or 2-cycle found\n"); else Print("***\n"); fi;
Print(" \n");
od; od; od; 
