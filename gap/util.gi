#############################################################################
##
##  util.gi  SgpDec package
##
##  (C)  2011-2012 Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
##  Some utility methods.
##

################################################################################
### FormattedFloat ###########################################################
#when printing Floats the precision causes lots of trouble
InstallGlobalFunction(FormattedFloat,
function(f)
local i,d,s;
  i := Int(f * 100);
  d := i mod 100;
  s := "";
  if d < 10 then s := "0";fi;
  return Concatenation(String(Int(i/100)),".",s,String(d));
end);

################################################################################
### PERCENTAGESTRING ###########################################################

InstallGlobalFunction(FormattedPercentageString,
function(n,N)
  return Concatenation(FormattedFloat((Float(n)/Float(N)) * 100),"%");
end);

################################################################################
#### TIMESTRING ################################################################

SGPDEC_util_timeunits := ["d","h","m","s","ms"];
MakeReadOnlyGlobal("SGPDEC_util_timeunits");
SGPDEC_util_durations := [24*60*60*1000, 60*60*1000, 60*1000, 1000, 1];
MakeReadOnlyGlobal("SGPDEC_util_durations");

InstallGlobalFunction(FormattedTimeString,
function(t)
local vals,k,s;
  if t = 0 then return "-";fi; #not measurable
  vals := [];
  for k in SGPDEC_util_durations do
    Add(vals, Int(t/k));
    t := t - vals[Length(vals)] * k;
  od;
  s := "";
  k := 1;
  while vals[k] = 0 do k := k+1; od;
  while k <= Length(SGPDEC_util_durations) do
    s := Concatenation(s, String(vals[k]),SGPDEC_util_timeunits[k]);
    k := k+1;
  od;
  return s;
end);

################################################################################
### MEMORYSTRING ###############################################################

#returns the readable string representation of the number of bytes
InstallGlobalFunction(FormattedMemoryString,
function(numofbytes)
  if numofbytes < 1024 then
    return Concatenation(String(numofbytes),"B");
  elif numofbytes >= 1024 and numofbytes < 1024^2 then
    return Concatenation(FormattedFloat(Float(numofbytes/1024)),"KB");
  elif numofbytes >= 1024^2 and numofbytes < 1024^3 then
    return Concatenation(FormattedFloat(Float(numofbytes/(1024^2))),"MB");
  elif numofbytes >= 1024^3 and numofbytes < 1024^4 then
    return Concatenation(FormattedFloat(Float(numofbytes/(1024^3))),"GB");
  fi;
end);