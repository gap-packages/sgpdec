%this is used by the GAP script and the array p is put here
prologues:=3;

%for the labels
input TEX;

beginfig(1);
u:=0.75cm;  

pickup pencircle scaled 2pt;
path f[];
color cols[];

cols[1] := blue;
cols[2] := red;
cols[3] := green + red;%yellow
cols[4] := red + blue; %purple
cols[5] := white;
cols[6] := green;

%the facelets of cube
f[1] := (2u,6u)--(5u,6u)--(5u,5u)--(3u,5u)--cycle;
f[2] := (5u,6u)--(5u,5u)--(7u,5u)--(8u,6u)--cycle;
f[3] := (5u,5u)--(7u,5u)--(6u,4u)--(5u,4u)--cycle;
f[4] := (3u,5u)--(5u,5u)--(5u,4u)--(4u,4u)--cycle;
f[5] := (2u,6u)--(3u,5u)--(3u,3u)--(2u,3u)--cycle;
f[6] := (3u,5u)--(4u,4u)--(4u,3u)--(3u,3u)--cycle;
f[7] := (3u,3u)--(4u,3u)--(4u,2u)--(3u,1u)--cycle;
f[8] := (2u,3u)--(3u,3u)--(3u,1u)--(2u,0)--cycle;
f[9] := (4u,4u)--(5u,4u)--(5u,3u)--(4u,3u)--cycle;
f[10] := (5u,4u)--(6u,4u)--(6u,3u)--(5u,3u)--cycle;
f[11] := (5u,3u)--(6u,3u)--(6u,2u)--(5u,2u)--cycle;
f[12] := (4u,3u)--(5u,3u)--(5u,2u)--(4u,2u)--cycle;
f[13] := (6u,4u)--(7u,5u)--(7u,3u)--(6u,3u)--cycle;
f[14] := (7u,5u)--(8u,6u)--(8u,3u)--(7u,3u)--cycle;
f[15] := (7u,3u)--(8u,3u)--(8u,0)--(7u,1u)--cycle;
f[16] := (6u,3u)--(7u,3u)--(7u,1u)--(6u,2u)--cycle;
f[17] := (8u,6u)--(10u,6u)--(10u,3u)--(8u,3u)--cycle;
f[18] := (0u,6u)--(2u,6u)--(2u,3u)--(0u,3u)--cycle;
f[19] := (0u,3u)--(2u,3u)--(2u,0u)--(0u,0u)--cycle;
f[20] := (8u,3u)--(10u,3u)--(10u,0u)--(8u,0u)--cycle;
f[21] := (4u,2u)--(5u,2u)--(5u,1u)--(3u,1u)--cycle;
f[22] := (5u,2u)--(6u,2u)--(7u,1u)--(5u,1u)--cycle;
f[23] := (5u,1u)--(7u,1u)--(8u,0u)--(5u,0u)--cycle;
f[24] := (3u,1u)--(5u,1u)--(5u,0u)--(2u,0u)--cycle;

string s;
%drawing and filling with the right colour
for i=1 upto 24:
  j := p[i];
  draw f[i];
  fill f[i] withcolor cols[ceiling(j/4)];
  label (TEX(if i=j : ("$" & decimal j & "$") else: ("$" & decimal j & "_{_{" & decimal i & "}}$") fi) , 1/2[point 2 of f[i],point 4 of f[i]]);
endfor;


%emphasizing the edges
pickup pencircle scaled 3pt;
% F frame
draw (4u,2u)--(4u,4u)--(6u,4u)--(6u,2u)--cycle;
% B frame
draw (0,0)--(2u,0)--(2u,6u)--(0,6u);
draw (10u,0)--(8u,0)--(8u,6u)--(10u,6u);
% D frame
draw (2u,0)--(4u,2u)--(6u,2u)--(8u,0)--cycle;
% U frame
draw (2u,6u)--(4u,4u)--(6u,4u)--(8u,6u)--cycle;
% the other frames are implicitly drawn


endfig;

end
