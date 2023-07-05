#ChangeDirectoryCurrent("C://Users//thoma//Desktop//ECE 5C//Research//decomp.g");

#LoadPackage("SgpDec");

#Read("C://Users//thoma//Desktop//ECE 5C//Research//nim.g");
#

splashing := true;;
GameStates := ["0:1:1", "0:2:2", "1:2:3", "INVALID"];;
GameSymbols := ["0←1", "1←1", "1←2", "2←1", "2←2", "2←3"];;

S0 := Transformation([4, 4, 2, 4]);;
S1 := Transformation([3, 1, 1, 4]);;
S2 := Transformation([4, 3, 1, 4]);;
S3 := Transformation([3, 1, 2, 4]);;
S4 := Transformation([4, 3, 1, 4]);;
S5 := Transformation([4, 4, 1, 4]);;

Game := Semigroup(S0, S1, S2, S3, S4, S5);
skel := Skeleton(Game);

if splashing then
  dot := DotSkeleton(skel,rec(states  := GameStates, symbols :=GameSymbols));
  PrintTo("NimSkeleton.dot", dot);

  d := DotSemigroupActionWithNames(Game, [1..4], OnPoints, GameStates, GameSymbols);
  PrintTo("NimMachine.dot", d);
fi;

DisplayHolonomyComponents(skel);
Display("Displaying skel done!");

Game_Coordinatized := HolonomyCascadeSemigroup(Game);
gen := GeneratorsOfSemigroup(Game_Coordinatized);

for i in [1..Length(gen)] do
 Display(gen[i]);
 PrintTo(Concatenation("gap_gen", String(i),".dot"), DotCascade(gen[i]));
od;

hol := DotRepHolonomyGroups(skel, rec(states  := GameStates, symbols :=GameSymbols));
for i in [1..Length(hol)] do
  PrintTo(Concatenation("nim_rep_holonomy_grp", String(i),".dot"), hol[i]);
od;

nat := DotNaturalSubsystems(skel, rec(states  := GameStates, symbols :=GameSymbols));
for i in [1..Length(nat)] do
  PrintTo(Concatenation("nim_nat_subsys", String(i),".dot"), nat[i]);
od;
    
