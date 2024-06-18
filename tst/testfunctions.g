SgpDecTestInstall := function()
local test;
  for test in
      ["emulation",
       "surmorphism",
       "statecong",
       "relmorph",
       "hashmaprel",
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
       "transnot",
       "viz",
       "straightword",
       "manual"
      ] do
    Test(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
                       "/tst/",test,
                       ".tst"),
        rec(compareFunction := "uptowhitespace"));;
  od;
end;
MakeReadOnlyGlobal("SgpDecTestInstall");
