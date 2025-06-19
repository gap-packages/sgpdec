################################################################################
# BESTIARY #####################################################################
# A Bestiary of Transformation Semigroups for the Holonomy Decomposition
# https://doi.org/10.1007/978-3-030-63591-6_4

################################################################################
# BECKS the automaton with nonimage tiles
# It is slightly counterintuitive that tiles of a set can fail to be images of
# the set itself, they come from somewhere else. It is an obstacle to
# incremental computation of holonomy.
# the name comes from a beer brand, and a restaurant in Eger
# on the main street, working on this during Chrystopher's visit
# (update: restaurant changed to a differnt beer brand)
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

################################################################################
# BEX reduced version of BECKS
bex := [
Transformation([1,2,1,1]), #creates the image {1,2}
Transformation([4,4,4,3]), #transposition in {3,4}
Transformation([3,3,4,4]), #this and the nontrivial holonomy group of {4,5,6}
                           #generate the images with cardinality 2
Transformation([4,4,1,2]), #this maps {3,4} to {1,2}
Transformation([2,1,4,4])];#makes H({1,2}) nontrivial
BEX := Semigroup(bex);
SetName(BEX,"BEX");

#small example from Alife X paper
alifex := [Transformation([2,2,3,3,3]),Transformation([3,3,3,5,4])];
ALIFEX := Semigroup(alifex);
SetName(ALIFEX,"ALIFEX");

################################################################################
# HEYBUG
# automata derived from the p-53 model giving strange errors
# heybug ran into an else statement which just should not happen
# this was a big drama in 2010 when flying from Winnipeg to Chicago
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

#smaller version of the above
smallp2hnt := [Transformation([2,1,3]),
               Transformation([1,2,2])];
SMALLP2HNT := Semigroup(smallp2hnt);

# finding all nontrivial differences between permutator and holonomy groups
# this can easily find C2n -> Cn in random transformation semigroups
findPermHolDiff := function(S)
  local sk, diffs;
  sk := Skeleton(S);
  diffs := Filtered(Concatenation(RepresentativeSets(sk)),
                   x ->
                   StructureDescription(PermutatorGroup(sk,x))
                   <>
                   StructureDescription(HolonomyGroup@SgpDec(sk,x)));
  Perform(diffs,
          function(x)
    Print(TrueValuePositionsBlistString(x),
          StructureDescription(PermutatorGroup(sk,x)),
                  "->",
                        StructureDescription(HolonomyGroup@SgpDec(sk,x)));
                    end);
end;

#Overlapping covers for parallel components
ovlcovers := [Transformation([4,3,4,2]),
              Transformation([1,2,2,1]),
              Transformation([3,2,1,1])
              ];
OVLCOVERS := Semigroup(ovlcovers);
SetName(OVLCOVERS,"OVLCOVERS");

# No singleton image
nosingleton := [Transformation([5,1,3,5,1]), Transformation([5,4,5,2,4])];
NOSINGLETON := Monoid(nosingleton);
# bigger example reported by Hanna Derets in 2025
nosingleton2 := [Transformation([5,6,7,8,3,4,6,7]),
                 Transformation([3,4,6,7,7,8,4,6]),
                 Transformation([2,3,4,6,6,7,8,4])];
NOSINGLETON2 := Semigroup(nosingleton2);

#X's wide examples never coded before
# l is a triple (list)
collapser := function(l) local t;
               t := ListWithIdenticalEntries(6,l[1]);
               t[l[1]] := l[1];
               t[l[2]] := l[2];
               t[l[3]] := l[3];
               return Transformation(t);
             end;

cycle := function(l) local t;
           t := ListWithIdenticalEntries(6,l[1]);
           t[l[1]] := l[2];
           t[l[2]] := l[3];
           t[l[3]] := l[1];
           return Transformation(t);
         end;

transposition := function(l) local t;
           t := ListWithIdenticalEntries(6,l[1]);
           t[l[1]] := l[2];
           t[l[2]] := l[1];
           t[l[3]] := l[3];
           return Transformation(t);
         end;

transpositions := List(Combinations([1..6],3), transposition);
cycles := List(Combinations([1..6],3), cycle);
collapsers := List(Combinations([1..6],3), collapser);

lastminute := collapsers; #Concatenation(collapsers, cycles, transpositions);

LASTMINUTE := Semigroup(lastminute);
