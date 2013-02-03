##  <#GAPDoc Label="Idempotize">
##  <ManSection >
##  <Func Arg="transformation, idempotent" Name="Idempotize" />
##  <Description>
##  Returns the resulting transformation of multiplying on both sides of a transformation by an idempotent transformation. i*t*i
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallGlobalFunction(Idempotentize,
function(transformation, idempotent) 
    return idempotent * transformation * idempotent;
end);

##  <#GAPDoc Label="ReduceByIdempotent">
##  <ManSection >
##  <Func Arg="generators, index" Name="ReduceByIdempotent" />
##  <Description>
##  Factors out one idempotent generator from the generators, i.e. the remaining generators are all idempotized <Ref Label="Idempotize"/>. If the generator of the given index is not an idempotent, then an empty list is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(ReduceByIdempotent,
function(generators, index)
    local i,result;

    result := [];
    if IsIdempotent(generators[index]) then
	for i in [1..Size(generators)] do
            #the idempotent itself is not included
            if not (i = index) then
                Add(result, Idempotentize(generators[i], generators[index]));
            fi;
	od;

    fi;
    return result;
end);


#undocummented
InstallGlobalFunction(BatchReductionByIdempotents,
function(generators, name)
    local i, filename;

for i in [1..Size(generators)] do 
    filename := Concatenation(name,"_R",StringPrint(i),"_S",StringPrint(RankOfTransformation(generators[i])),".gens" );
    WriteStringToFile(filename,AsJGRASPGenerators(ReduceByIdempotent(generators,i)));
od;

 
end);

InstallGlobalFunction(RecursiveReductionByIdempotents,
function(generators, name, statesize)
    local rank,i, nname, filename,gens;

for i in [1..Size(generators)] do 
    rank := RankOfTransformation(generators[i]);
    nname := Concatenation(name,"_R",StringPrint(i),"_S",StringPrint(rank));
    gens := ReduceByIdempotent(generators,i);
    if not IsEmpty(gens) then 
	if rank = statesize then
	    filename := Concatenation(nname,".gens");
	    WriteStringToFile(filename,AsJGRASPGenerators(gens));
	fi;
	if rank > 1 then
	    RecursiveReductionByIdempotents(gens,nname,statesize);
	    #Print(nname);Print("\n");
	fi;
    fi;
od;

 
end);


