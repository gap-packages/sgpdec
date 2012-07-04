#the uniquely labelled directed graph stuff
Read("../uldg/uldg.g");

#getting the seed from the number of seconds from the Epoch
SecondsFromTheUNIXEpoch := function()
local path, date,str,a;
  path := DirectoriesSystemPrograms();;
  date := Filename( path, "date" );
  str := ""; 
  a := OutputTextString(str,true);
  Process( DirectoryCurrent(), date, InputTextNone(), a, ["+%s"] );
  CloseStream(a);
  NormalizeWhitespace(str);
  return Int(str);
end;

rnd := RandomSource(IsGAPRandomSource,SecondsFromTheUNIXEpoch());

#it picks a random molecule based on the concentration levels (distribution)
PickRandomTypeProportionally := function(rnd, distribution) #pick molecule uniformly
local r, cumsum, p;
  r := Random([1..Sum(distribution)]);
  cumsum := distribution[1]; 
  p := 1;
  while  r > cumsum do p := p +1; cumsum := cumsum + distribution[p] ;od;
  return p;
end;


#the collisions are proportional to the concentrations (i.e. two random molecules are chosen for collision)
# transfs - transformations
# distr - original distribution
# numofcycles - number of total cycles
# snapshots - at what periods to display 
moldyn := function(transfs, distr, numofcycles, snapshots)
local i,c, t, p,pt, r, cumsum, j;
   c := 1;
   for i in [1..numofcycles] do
     #which type of molecule to pick?
     p := PickRandomTypeProportionally(rnd, distr);
     #finding the transformation
     t := Random(rnd, transfs);
     #p goes to p*t
     pt := p ^ t;
     distr[p] := distr[p]-1;
     distr[pt] := distr[pt] +1;

     #doing snapshot
     if (c mod snapshots) = 0 then
       Print(c," ");
       Print(Sum(distr)," ");
       for j in [1..Length(distr)] do
         Print(distr[j]," ");
       od;
       Print("\n");
     fi;
     c := c +1;
   od;
end;


#the collisions are proportional to the concentrations (i.e. two random molecules are chosen for collision)
# transfs - transformations
# distr - original distribution
# numofcycles - number of total cycles
# snapshots - at what periods to display 
driftingmoldyn := function(transfs, distr, numofcycles, snapshots)
local i,c, t, p,pt, r, j,event,events;
   c := 1;
   events := [1..3]; #1 - reaction,2 - molecule leaving, 3 - molecule entering
   for i in [1..numofcycles] do
     event := Random(events);
     if event = 1 then 
       #which type of molecule to pick?
       p := PickRandomTypeProportionally(rnd, distr);
       #finding the transformation
       t := Random(rnd, transfs);
       #p goes to p*t
       pt := p ^ t;
       distr[p] := distr[p]-1;
       distr[pt] := distr[pt] +1;
       #Print("R");
     elif event = 2 then
       #removing a random one proportionally
       p := PickRandomTypeProportionally(rnd, distr);
       #if distr[p] > 0 then 
       distr[p] := distr[p] -1;# fi;
       #Print("O");
     else
       #just adding the first molecule
       distr[1] := distr[1] + 1;
       #Print("I");
     fi;

     #doing snapshot
     if (c mod snapshots) = 0 then
       Print(c," ");
       Print(Sum(distr)," ");
       for j in [1..Length(distr)] do
         Print(distr[j]," ");
       od;
       Print("\n");
     fi;
     c := c +1;
   od;
end;



driven_ensembledyn := function(transfs, distr, numofcycles, snapshots)
local newdistrib,olddistrib, t,i,c, p, pt,events,event;
   c := 1;
   #start with the distribution given as an argument
   olddistrib := ShallowCopy(distr);
   events := [1..3]; #1 - reaction,2 - molecule leaving, 3 - molecule entering
   for i in [1..numofcycles] do
     event := Random(events);
     if event = 1 then 
       #finding a random transformation
       t := Random(rnd, transfs);
       newdistrib := List([1..Length(distr)], x -> 0);
       for p in [1..Length(distr)] do
         pt := p ^ t;
         newdistrib[pt] := newdistrib[pt] + olddistrib[p];
       od;
       olddistrib := newdistrib;

     elif event = 2 then
       #removing a random one proportionally
       p := PickRandomTypeProportionally(rnd, olddistrib);
       #if olddistrib[p] > 0 then 
       olddistrib[p] := olddistrib[p] -1;# fi;
       #Print("O");
     else
       #just adding the first molecule
       olddistrib[1] := olddistrib[1] + 1;
       #Print("I");
     fi;


     #doing snapshot
     if (c mod snapshots) = 0 then
       Display(olddistrib);
     fi;
     c := c + 1;
   od;
end;


ensembledyn := function(transfs, distr, numofcycles, snapshots)
local newdistrib,olddistrib, t,i,c, p, pt;
   c := 1;
   #start with the distribution given as an argument
   olddistrib := ShallowCopy(distr);
   for i in [1..numofcycles] do

     #finding a random transformation
     t := Random(rnd, transfs);
     newdistrib := List([1..Length(distr)], x -> 0);
     for p in [1..Length(distr)] do
       pt := p ^ t;
       newdistrib[pt] := newdistrib[pt] + olddistrib[p];
     od;
     olddistrib := newdistrib;
     #doing snapshot
     if (c mod snapshots) = 0 then
       Display(olddistrib);
     fi;
     c := c + 1;
   od;
end;

