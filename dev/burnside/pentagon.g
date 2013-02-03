 comps:= [Z2,Z5];

#rotation
ca := CPdef(comps,  [ [[()],(1,2,3,4,5)],[[(1,2)] ,Inverse((1,2,3,4,5)) ] ] );
#flip
 cb := CPdef(comps,  [ [[],(1,2)] ] );           


symbols := [Z2symbols,Z5symbols];
CPdraw(ca,comps,symbols,"ca_pentagon");
CPdraw(cb,comps,symbols,"cb_pentagon");

CPinvert := function(a,comps);
 return CPraise(CPflat(a,comps)^-1,comps);
end;
