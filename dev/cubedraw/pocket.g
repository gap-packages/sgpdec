ShowPocketCubeElement := function(perm)
local p, filename, i, tempstring, tempstrwriter, metapostcode;
  p := ImageListOfPermutation(Inverse(perm),24); # inverting is due to the position-content duality lemma

  tempstring := ""; tempstrwriter := OutputTextString(tempstring, false);
  PrintTo(tempstrwriter,"numeric p[];\n");

  for i in [1..24] do
    AppendTo(tempstrwriter,Concatenation("p[",StringPrint(i), "] := " , StringPrint(p[i]) , ";\n"));
  od; 
  


  metapostcode := ReadAll(InputTextFile("pocket.mp"));
  filename := Concatenation(StringPrint(perm),".mp");
  filename := ReplacedString(filename, " ", "");
  filename := ReplacedString(filename, "(", "");
  filename := ReplacedString(filename, ")", "-");
  filename := ReplacedString(filename, ",", "_");
  #for the identity
  if (filename = "-.mp") then filename := "id.mp"; fi;
  PrintTo(filename, Concatenation(tempstring, metapostcode));
  Exec("mpost ", filename);
  filename := ReplacedString(filename, ".mp", ".1");
  Exec("evince ", filename, " & ");
end;

ShowPocketCubeState := function(lagdec, cascaded_state)
  ShowPocketCubeElement(Product(DecodeCosetReprs(lagdec, cascaded_state)));
end;

