DeclareCategory("IsPermCascade",
        IsCascade and IsMultiplicativeElementWithInverse);

BindGlobal("PermCascadeFamily",
        NewFamily("PermCascadeFamily",
                IsPermCascade, CanEasilySortElements, CanEasilySortElements));

BindGlobal("PermCascadeType", NewType(PermCascadeFamily,
        IsPermCascade and IsAssociativeElement));

DeclareGlobalFunction("PermCascadeNC");
DeclareGlobalFunction("PermCascade");
