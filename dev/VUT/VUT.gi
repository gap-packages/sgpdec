#############################################################################
##
#W  grasp.gi           GrAsP library  
##
#Y  Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
#Y  2003 University of Hertfordshire, Hatfield, UK
##
##  This file contains code for automata and semigroups.
##

##  <#GAPDoc Label="VUT">
##  <ManSection>
##  <Func Arg="l" Name="VUT" />
##  <Description>
##  The V union T technique.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("VUT", 
        function(semigroup, components)
    
    local J,FJ,lclasses,V,T,L,Q;
    J := GetMaximalDClass(semigroup);
    FJ := Difference(semigroup,J);
    
    if (IsRegularDClass(J)) then
        lclasses := LClassesOfDClass(semigroup,J);
        if Size(lclasses) = 1 then
            if IsEmpty(FJ) then
                #left simple 
                Add(components, semigroup);
            else
                
                V := SemigroupByGenerators(FJ);
                T := SemigroupByGenerators(J);
                VUT(V, components);
                VUT(T, components);
            fi;
        else
            #more L classes, just pck up one, the 1st
            L := lclasses[1];
            if IsEmpty(FJ) then
                V := SemigroupByGenerators(L);
                T := SemigroupByGenerators(Difference(semigroup, L));
                VUT(V, components);
                VUT(T, components);
            else
                V := SemigroupByGenerators(Union(L,FJ));
                T := SemigroupByGenerators(Union(Difference(J, L), FJ));
                VUT(V, components);
                VUT(T, components);                
            fi;    
        fi;
    else
        Q := SemigroupByGenerators(J);
        if Q = semigroup then
            #cyclic
            Add(components, semigroup);
        else
            V := SemigroupByGenerators(FJ);
            T := Q;
            VUT(V, components);
            VUT(T, components);                
        fi;
        
    fi;
    
    return components;
end);



##  <#GAPDoc Label="Automaton2Semigroup">
##  <ManSection>
##  <Func Arg="automaton" Name="Automaton2Semigroup" />
##  <Description>
##  Creates the characteristic semigroup of an automaton. 
##  Takes the input alphabet as generators.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction("Automaton2Semigroup", 
        function(automaton)
    local i,j, gen, gens;
    
    gens := [];
    for i in automaton.syms do
        gen := [];	
        for j in automaton.sts do
            Add(gen, automaton.tt[Position(automaton.sts,j)][Position(automaton.syms,i)]);
	od; 
        Add(gens, Transformation(gen));
    od; 	

    return gens;
end);
