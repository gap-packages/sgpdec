# predefined semigroups frequently used or needed for tests

# creates a wrapping function from the list of pairs (semi)group element-symbol
SymbolFunction4Operations := function(assoclist)
  local  f, al;
  al := Immutable(assoclist);
  f := function(operation)
    local i;
    for i in al do
      if i[1] = operation then return i[2];fi;
    od;
    return fail;
  end;
  return f;
end;

# creates a wrapping function from the list of symbols for (semi)group states
# (points to act on)
SymbolFunction4States := function(list)
  local  f, al;
  al := Immutable(list);
  f := function(state)
    return al[state];
  end;
  return f;
end;

################################################################################
# FLIP_FLOP ####################################################################

FlipFlop := SemigroupByGenerators(
                    [Transformation([1,1]),
                     Transformation([2,2]),
                     Transformation([1,2])]);
SetName(FlipFlop,"FF");
FlipFlopStates := SymbolFunction4States(["0","1"]);
FlipFlopOps := SymbolFunction4Operations([
[Transformation([1,1]),"set0"],
[Transformation([2,2]),"set1"],
[Transformation([1,2]),"read"]
]);

################################################################################
# FULL TRANSFORMATION SEMIGROUPS ###############################################

T2 := FullTransformationSemigroup(2);
SetName(T2,"T2");

T3 := FullTransformationSemigroup(3);
SetName(T3,"T3");

T4 := FullTransformationSemigroup(4);
SetName(T4,"T4");
T4gens := GeneratorsOfSemigroup(T4);

T5 := FullTransformationSemigroup(5);
SetName(T5,"T5");

T6 := FullTransformationSemigroup(6);
SetName(T6,"T6");

T7 := FullTransformationSemigroup(7);
SetName(T7,"T7");

T8 := FullTransformationSemigroup(8);
SetName(T8,"T8");

T9 := FullTransformationSemigroup(9);
SetName(T9,"T9");

T10 := FullTransformationSemigroup(10);
SetName(T10,"T10");

T11 := FullTransformationSemigroup(11);
SetName(T11,"T11");

################################################################################
# BESTIARY #####################################################################

# the automaton with nonimage tiles
# the name comes from a beer brand, and a restaurant in Eger
# on the main street, working on this during Chrystoher's visit
becks := [
Transformation([1,2,3,1,1,1]), #creates the image {1,2,3}
Transformation([4,4,4,5,4,6]), #transposition in {4,5,6}
Transformation([4,4,4,5,6,4]), #cycle of {4,5,6}
Transformation([4,4,4,4,5,5]), #this and the nontrivial holonomy group of
                               #{4,5,6} generate the images with cardinality 2
Transformation([4,4,4,1,2,3]), #this maps {4,5,6} to {1,2,3}
Transformation([2,3,1,4,4,4])];#makes H({1,2,3}) nontrivial
BECKS := Semigroup(becks);
SetName(BECKS,"BECKS");

# reduced version of BECKS
bex := [
Transformation([1,2,1,1]), #creates the image {1,2}
Transformation([4,4,4,3]), #transposition in {3,4}
Transformation([3,3,4,4]), #this and the nontrivial holonomy group of {4,5,6}
                           #generate the images with cardinality 2
Transformation([4,4,1,2]), #this maps {3,4} to {1,2}
Transformation([2,1,4,4])];#makes H({1,2}) nontrivial
BEX := Semigroup(bex);
SetName(BEX,"BEX");

#simple automaton demonstrating nonisomorphic permutator semigroups on
#equivalent subsets
nonisomperm := [Transformation([2,1,3]),
                Transformation([3,2,3]),
                Transformation([1,1,2])];
NONISOMPERM := Semigroup(nonisomperm);
SetName(NONISOMPERM,"NONISOMPERM");

#small example from Alife X paper
alifex := [Transformation([2,2,3,3,3]),Transformation([3,3,3,5,4])];
ALIFEX := Semigroup(alifex);
SetName(ALIFEX,"ALIFEX");

#automata derived from the p-53 model giving strange errors
#heybug ran into an else statement which just should not happen
#this was a big drama in 2010 when flying from Winnipeg to Chicago
heybug := [
    Transformation( [ 2,2,4,4,6,6,8,8 ] ),
    Transformation( [ 1,2,3,5,5,6,7,5 ] ),
    Transformation( [ 1,2,3,4,3,4,3,4 ] )
];
HEYBUG := Semigroup(heybug);

#a small version of heybug
smlbug := [ Transformation([2,2,4,4,6,6]),
            Transformation([1,3,3,4,5,3]),
            Transformation([1,2,1,2,1,2])  ];
SMLBUG := Semigroup(smlbug);
SetName(SMLBUG,"SMLBUG");

#further size reduction
microbug := [ Transformation( [ 1,2,1 ] ),Transformation( [ 3,3,1 ] ) ];
MICROBUG := Semigroup(microbug);
SetName(MICROBUG,"MICROBUG");

#Chrystopher's example where the permutator and the holonomy group is different
perm2holnontrivial := [Transformation([2,1,4,5,3]),
                       Transformation([1,2,2,2,2]),
                       Transformation([3,3,3,4,5])];
PERM2HOLNONTRIVIAL := Semigroup(perm2holnontrivial);
SetName(PERM2HOLNONTRIVIAL,"P2HNT");

#Overlapping covers for parallel components
ovlcovers := [Transformation([4,3,4,2]),
              Transformation([1,2,2,1]),
              Transformation([3,2,1,1])
              ];
OVLCOVERS := Semigroup(ovlcovers);
SetName(OVLCOVERS,"OVLCOVERS");
