
# Mutual Gaze Behaviour Automata
# Nondeterministic Markov Transition Models Converted To Finite State Automata
# using a power set construction
#
# Authors: Frank Broz and Chrystopher Nehaniv, Adaptive Systems Research Group
# University of Hertfordshire, UK.  Funded by EU FP7 ITALK Project
#

# Binary State Encoding for Subsets:
#1 = mutual gaze state M 
#2 = high gaze participant looking at low gaze participant  L
#4 = low gaze participant looking at high gaze participant  H
#8 = both participants look away from one another   A
#16 = some type of tracking error  E
#32 = sink state   "0" 


LowAtHigh := Transformation([5,5,5,29,29,29,29,13,13,13,13,29,29,29,29,17,21,21,21,29,29,29,29,29,29,29,29,29,29,29,29,32]);
HighAtLow := Transformation([11,27,27,1,11,27,27,11,11,27,27,11,11,27,27,19,27,27,27,19,27,27,27,27,27,27,27,27,27,27,27,32]);
LowAway := Transformation([2,26,26,8,10,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,26,32]);
HighAway := Transformation([4,12,12,12,12,12,12,12,12,12,12,12,12,12,12,8,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,32]);
LowErr := Transformation([1,16,16,4,5,16,16,8,9,16,16,12,13,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,32]);
HighErr := Transformation([1,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,32]);


t := [LowAtHigh,HighAtLow,LowAway,HighAway,LowErr,HighErr];


S := SemigroupByGenerators(t);

all_subsets := 
 [ 
   "M",  #1  = 00001
   "L",  #2  = 00010
   "LM", #3  = 00011
   "H",  #4  = 00100
   "HM", #5  = 00101 
   "HL", #6  = 00110
  "MLH", #7  = 00111
   "A",  #8  = 01000
   "AM", #9  = 01001
   "AL", #10 = 01010
  "ALM", #11 = 01011
   "AH", #12 = 01100
  "AHM", #13 = 01101
  "AHL", #14 = 01110
 "AHLM", #15 = 01111
   "E",  #16 = 10000
   "EM",  #17  = 10001
   "EL",  #18  = 10010
   "ELM", #19  = 10011
   "EH",  #20  = 10100
   "EHM", #21  = 10101 
   "EHL", #22  = 10110
  "EMLH", #23  = 10111
   "EA",  #24  = 11000
   "EAM", #25 = 11001
   "EAL", #26 = 11010
  "EALM", #27 = 11011
   "EAH", #28 = 11100
  "EAHM", #29 = 11101
  "EAHL", #30 = 11110
 "EAHLM", #31 = 11111
    "0"   #32 = 00000
    ];

# Pair 4 Cyclic Order 2 groups act on the following tile sets:
#8, 12   ->  {A}, {H,A}
#13,29  ->  {M,H,A}, {M,H,A,E}
#13,21  ->  {M,H,A}, {M,A,E}
#13,16  ->  {M,H,A}, {E}
#11,27  ->  {M,L,A}, {M,L,A,E}
#11,19  ->  {M,L,A}, {M,L,E}

hd := HolonomyDecomposition(S);

Splash(hd, rec(statesymbols := all_subsets));

b := FiniteSet([8,12,32],32);
PermutatorGenerators(SkeletonOf(hd),b);
	PermutatorGroup(b,hd);

LinearNotation(t[1]*t[5]*t[4]);   
