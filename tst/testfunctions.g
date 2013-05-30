SgpDecTestInstall := function()
local test;
  for test in [
          "wreath",
          "cascade",
          "depfunc",
          "fl",
          "holonomy",
          "cartesianenum",
          "transnot",
          "straightword"
          ] do
    Test(Concatenation(
            PackageInfo("sgpdec")[1]!.InstallationPath,
            "/tst/",test,
            ".tst"));;
  od;
end;
MakeReadOnlyGlobal("SgpDecTestInstall");
