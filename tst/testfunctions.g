#this gives some readable titles
SgpDecTestInstall := function()
local test;
  for test in
      ["emulation",
       "surmorphism",
       "statecong",
       "relmorph",
       "hashmaprel",
       "acn",
       "lowerbound",
       "disjointuniongroup",
       "WeakControlWords",
       "wreath",
       "cascade",
       "depfunc",
       "fl",
       "skeleton",
       "holonomy",
       "cartesianenum",
       "viz",
       "straightword",
       "manual"
      ] do
    Test(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                       "/tst/",test,
                       ".tst"),
         rec(compareFunction := "uptowhitespace",
             showProgess:=true));;
  od;
end;
MakeReadOnlyGlobal("SgpDecTestInstall");

#this version provides memory consumption information
SgpDecTestInstall2 := function()
  Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                     "/tst/testall.g"));
end;

