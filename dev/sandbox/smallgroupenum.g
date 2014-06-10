# applies the given functions to all (small) groups of given orders
ApplyToSmallPermGroups := function(orders, funct)
local order,grp, permgrp;
  for order in orders do
    for grp in AllSmallGroups(order) do
      permgrp := Image(IsomorphismPermGroup(grp));
      funct(permgrp);
    od;
  od;
end;

