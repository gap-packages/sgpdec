InstallOtherMethod(OneOp, "for a permutation cascade",
[IsPermCascade],
function(ct)
  return IdentityCascade(ComponentDomains(ct));
end);
