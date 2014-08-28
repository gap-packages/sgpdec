hcs := FLCascadeGroup(S3);
isom := IsomorphismPermGroup(hcs);
fhcs := Range(isom);

for c in hcs do
  s := "";
  t := Image(isom,c);
  cnt := ReplacedString(CompactNotation(t),"|","\\|"); 
  s := Concatenation(s, cnt, "\\n");
  filename := Concatenation(String(t),"permcasc");
  RemoveCharacters(filename,"[],");
  PrintTo(filename,DotCascade(c,s));
od;
