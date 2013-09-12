hcs := HolonomyCascadeSemigroup(SingularSemigroup(3));
isom := IsomorphismTransformationSemigroup(hcs);
fhcs := Range(isom);
surhom := HomomorphismTransformationSemigroup(hcs);


for c in hcs do
  s := "";
  t := Image(surhom,c);
  cnt := ReplacedString(SimplerCompactNotation(t),"|","\\|"); 
  ilt := String(ImageListOfTransformation(t));
  RemoveCharacters(ilt," ");
  s := Concatenation(s, cnt, ":" , ilt,"\\n");
  f := Image(isom,c);
  cnf := ReplacedString(SimplerCompactNotation(f),"|","\\|"); 
  ilf := String(ImageListOfTransformation(f));
  RemoveCharacters(ilf," ");
  s := Concatenation(s,cnf, ":" , ilf);
  #Splash(DotCascade(c,s));
  filename := Concatenation(ilf,"casc");
  RemoveCharacters(filename,"[],");
  PrintTo(filename,DotCascade2(c,s));
od;
