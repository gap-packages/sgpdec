gap> START_TEST("Sgpdec package: depfunc.tst");
gap> LoadPackage("sgpdec", false);;
gap> Read(Concatenation(PackageInfo("sgpdec")[1]!.InstallationPath,
> "/tst/variables.g"));;
gap> SemigroupsStartTest();

# creating domains for dependency functions can be done in 3 ways
# 1. by a list of perm groups/transformation semigroups
# 2. by a list of domains of transformations in components
# 3. by a list of containing domain sizes
# We create all domains in one shot, since we need them all for cascades.
gap> depdoms := DependencyDomains([Z5,T3,FF,S4]);;
gap> depdoms2 := DependencyDomains([[1..5],[1..3],[1,2],[1..4]]);;
gap> depdoms3 := DependencyDomains([5,3,2,4]);;
gap> depdoms = depdoms2;
true
gap> depdoms2 = depdoms3;
true

# creating a dependency function can be done in 2 ways
# 1. by domain a list of mappings
# 2. by domain and a lookup table (internal representation)
# 1.
# We simply define it by giving its domain and mappings in the format
# [argument, value]
# where argument is tuple of integers and value is a transformation/permutation
# The range of the dependency function is defined implicitly.
gap> df := DependencyFunction(depdoms[4],
>       [
>         [ [1,2,2] , (2,4,3) ],
>         [ [5,3,1] , (1,2)(4,3) ],
>         ]);;

#on the top level there is only one mapping
gap> df2 := DependencyFunction(depdoms[1],
>        [
>         [ [] , (1,2,3,4,5) ]
>         ]);;

# 2.
# The same information but in different data structure.
# [arg, value] --> vals[Position(dom, arg)] = value
gap> dom := depdoms[4];; # just a shorthand
gap> vals := EmptyPlist(Size(dom));;
gap> vals[Position(dom,[1,2,2])] := (2,4,3);;
gap> vals[Position(dom,[5,3,1])] := (1,2)(3,4);;
gap> df_ := DependencyFunction(dom,vals);;

#
gap> dom := depdoms[1];; # just a shorthand
gap> vals := EmptyPlist(Size(dom));;
gap> vals[1] := (1,2,3,4,5);; # in this case we happen to know the index
gap> df2_ := DependencyFunction(dom,vals);;

# they are of course the same object
gap> df=df_;
true
gap> df2=df2_;
true

# extracting the mappings (individual dependencies) from the function
gap> Dependencies(df);
[ [ [ 1, 2, 2 ], (2,4,3) ], [ [ 5, 3, 1 ], (1,2)(3,4) ] ]
gap> df = DependencyFunction(DomainOf(df),Dependencies(df));
true

# for convenience a function is provided to sort dependencies into their
# proper rank dependency function
gap> deps :=
>       [
>         [ [1,2] , (2,4) ],
>         [ [5,3,1] , (1,2)(4,3) ],
>         [ [2,3] , (1,2) ],
>         [ [] , (1,2,4,3) ]
>         ];;
gap> depfuncs := DependencyFunctions(depdoms, deps);
[ <depfunc of depth 1 with 1 deps>, <depfunc of depth 2 with 0 deps>, 
  <depfunc of depth 3 with 2 deps>, <depfunc of depth 4 with 1 deps> ]

# nice formatted display
gap> Display(depfuncs[3]);
Dependency function of depth 3 with 2 dependencies.
[ 1, 2 ] -> (2,4)
[ 2, 3 ] -> (1,2)

#
gap> SemigroupsStopTest();
gap> STOP_TEST( "Sgpdec package: depfunc.tst", 10000);
