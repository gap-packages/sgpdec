#returns an nxn matrix with 1 at i,j position, otherwise 0
Eij := function(n,i,j)
  local M;
  M := NullMat(n,n);
  M[i][j] := 1;
  return M;
end;

#the bar Eij
bEij := function(n,i,j)
  return Eij(n,i,j) + Eij(n,j,i);
end;

#creates the adjececny matrix from a list of edges
AdjMat := function(n,edges)
local e, M;
  M := NullMat(n,n);
  for e in edges do
    M := M + bEij(n,e[1],e[2]);
  od;
  return M;
end;

#EXAMPLE
A := AdjMat(5, [ [1,2], [2,3], [4,5]] );
B := AdjMat(5, [ [2,4], [3,5], [1,5]] );
Display(A); #to have proper matrix layout
LieBracket(A,B);
