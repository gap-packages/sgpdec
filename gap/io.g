#############################################################################
##
##  io.g  SgpDec package
##
##  (C)  2011-2012 Attila Egri-Nagy, Chrystopher L. Nehaniv, James D. Mitchell
##
##  Some utility methods.
##


SGPDEC_Percentage := function(n,N)
 return Int(Int((Float(n)/Float(N)) * 10000)/Float(100));
end;

SGPDEC_util_timeunits := ["d","h","m","s","ms"];
SGPDEC_util_durations := [24*60*60*1000, 60*60*1000, 60*1000, 1000, 1];

SGPDEC_TimeString :=
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
    s := Concatenation(s, StringPrint(vals[k]),SGPDEC_util_timeunits[k]);
    k := k+1;
  od;

  return s;
end;

#returns the readable string representation of the number of bytes
FormattedMemoryInfo := function(mem)
  if mem < 1024 then
    return Concatenation(StringPrint(mem),"b");
  elif mem >= 1024 and mem < 1024^2 then
    return Concatenation(StringPrint(Round(Float(mem/1024))),"KB");
  elif mem >= 1024^2 and mem < 1024^3 then
    return Concatenation(StringPrint(
                   Float(Round(Float(mem/(1024^2))*10)/10)),"MB");
  elif mem >= 1024^3 and mem < 1024^4 then
    return Concatenation(StringPrint(
                   Float(Round(Float(mem/(1024^3))*100)/100)),"GB");
  fi;
end;