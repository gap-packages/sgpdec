#############################################################################
##
## TUTORIAL #02 Lagrange Coordinates          SgpDec package  
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## 2008 University of Hertfordshire, Hatfield, UK
##
## Tutorial for Lagrange coordinatization of permutation groups.
##
## This is a runnable script 
## 
## gap < 02_lagrange.g
## 
## from command line. Or in GAP
##
## Read("02_lagrange.g");
##
## However it is recommended to go through the commands and issue them separately to see how they work.
## When loaded into GAP the variables are available for experimenting with them. 


#switch to fancier display (this dies on bigger groups)
SMALL_GROUPS := true;

####COMPONENTS FOR S4#######

#calculating the decomposition
ld := LagrangeDecomposition(S4);

#Alternative method to get the components interactively, instead of the default series by GAP.
#ld := LagrangeDecomposition(a_permutation_group, iCreateSeriesForHierarchicalDecomposition);

#the number of building blocks
Length(ld);

#have a look at the components
AsList(ld);

#UNDER THE HOOD 
#access to the underlying series
SeriesOf(ld);
#access to the used transversals
TransversalsOf(ld);
#the decomposition object  retains the original group as well
OriginalStructureOf(ld);
#the decomposition contians a cascaded structure as its core
CascadedStructureOf(ld);
#In order to create the cascade product we need to use the canonical coding, the 'points', i.e. integers 1..n.
#Thus for each level we have maps from coset representatives to points and back.
#These are lists of Mapping-s in GAP and can be viewed (if small).
MappingTable(ConvertersFromCanonicalOf(ld)[1]);
MappingTable(ConvertersToCanonicalOf(ld)[2]);
 
#the states of the components (the coordinates) are (sub)cosets in the original group, these can be accessed by 'Interpret' - it gives meaning to states in the original context
# the first state of the second level
Interpret(ld,2,1);


#choosing a random permutation from the group
g := Random(OriginalStructureOf(ld));

#lifting a permutation of the original group into the cascaded product, ended up with a CascadedOperation
ghat := Raise(ld,g);

#when going back to the original structure we should get the same element (unlike Collapse we should give the decomposition object). We can check this by testing the equality:
g = Flatten(ld,ghat);

#the cascaded states are in one-to-one correspondence with the group elements (thus flattening ghat gives a right regular representation of g)
cs_of_g := Perm2CascadedState(ld,g);

#Frobenius-Lagrange MAP (basically the steps of Flattening)
#first we decode the cascaded state, the points to coset representatives
decoded := DecodeCosetReprs(ld,cs_of_g);


#killing off by levels
#for a cascaded state we can have a list of cascaded operations that applied in order transforms the corrseponding level to the base point 1 (identity on the cosetrepr side), 'kills of the level'
levelkillers := LevelKillers(ld,cs_of_g);
for i in [1..Length(ld)] do
  Display(cs_of_g);
  cs_of_g := cs_of_g * Raise(ld,levelkillers[i]);
od;
Display(cs_of_g);

