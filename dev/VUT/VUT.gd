#############################################################################
##
#W  grasp.gd           GAP library         Attila Egri-Nagy
##
#H  @(#)$Id: grasp.gd,v 1.6 2003/06/10 11:23:08 sirna Exp $
##
#Y  Copyright (C) Attila Egri-Nagy, Chrystopher L. Nehaniv  
##
#Y  2003, University of Hertfordshire, Hatfield, UK
##
##  
##


#############################################################################
##
#F  VUT( <S> )  
##
##  returns the list of the components of the V union T decomposition.
##
DeclareGlobalFunction("VUT");

#############################################################################
##
#F  Automaton2Semigroup( <A> )  
##
##  returns the generators of the corresponding transformation
##  semigroup <S> for automaton <A>.
##
DeclareGlobalFunction("Automaton2Semigroup");

