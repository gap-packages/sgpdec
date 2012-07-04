#############################################################################
##  <#GAPDoc Label="AnalyzePermWordColl">
##  <ManSection><Heading>Analyzing a collection of permwords</Heading>
##  <Func Name="AnalyzePermWordColl" Arg="permwords"/>
##  <Description>
##  Analyzes and displays some basic attributes of permutation words in a collection. Minimal and maximal lengths, number of identities, length distributions.  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#DeclareGlobalFunction("AnalyzePermWordColl");

# prints the length distribution of permutation words in a list
AnalyzePermWordColl := function(permwords)
local n,pw,len, lengths,max,min,i;
  Print(Size(permwords), " permwords.\n");
  n := 0;
  for pw in permwords do
    if pw!.perm = () then n := n+1; fi; 
  od;
  Print(n, " identities.\n");
  #just initializing max min values
  min := Length(Random(permwords));
  max := min;
  for pw in permwords do
    len := Length(pw);
    if len < min then min := len;fi;
    if len > max then max := len;fi;
  od;
  Print("Minimal length ", min, "\n");
  Print("Maximal length ", max, "\n");

  lengths := List([1..max+1], x->0);
  for pw in permwords do
    len := Length(pw)+1;#correction because of zero
    lengths[len] := lengths[len] + 1;
  od;
  for i in [0..max] do
    if lengths[i+1] <> 0 then Print(i, ": ", lengths[i+1],"\n");fi;
  od;
end;

