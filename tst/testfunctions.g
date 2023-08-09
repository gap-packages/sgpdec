SgpDecTestInstall := function()
local test;
  for test in [
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
    Test(Concatenation(
            PackageInfo("sgpdec")[1]!.InstallationPath,
            "/tst/",test,
            ".tst"));;
  od;
end;
MakeReadOnlyGlobal("SgpDecTestInstall");
