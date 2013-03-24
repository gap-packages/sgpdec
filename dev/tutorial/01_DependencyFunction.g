Read("variables.g");

# creating domains for dependency functions can be done in 3 ways
# 1. by a list of perm groups/transformation semigroups
# 2. by a list of domains of transformations in components
# 3. by a list of containing domain sizes
# We create all domains in one shot, since we need them all for cascades.
depdoms := DependencyDomains([Z5,T3,FF,S4]);
depdoms2 := DependencyDomains([[1..5],[1..3],[1,2],[1..4]]);
depdoms3 := DependencyDomains([5,3,2,4]);
depdoms = depdoms2;
depdoms2 = depdoms3;

# creating a dependency function can be done in 2 ways
# 1. by domain a list of mappings
# 2. by domain and a lookup table (internal representation)

# 1.
# We simply define it by giving its domain and mappings in the format
# [argument, value]
# where argument is tuple of integers and value is a transformation/permutation
# The range of the dependency function is defined implicitly.
df := DependencyFunction(depdoms[4],
        [
         [ [1,2,2] , (2,4,3) ],
         [ [5,3,1] , (1,2)(4,3) ],
         ]);
#on the top level there is only one mapping
df2 := DependencyFunction(depdoms[1],
        [
         [ [] , (1,2,3,4,5) ]
         ]);

# 2.
# The same information but in different data structure.
# [arg, value] --> vals[Position(dom, arg)] = value
dom := depdoms[4]; # just a shorthand
vals := EmptyPlist(Size(dom));
vals[Position(dom,[1,2,2])] := (2,4,3);
vals[Position(dom,[5,3,1])] := (1,2)(4,3);
df_ := DependencyFunction(dom,vals);

dom := depdoms[1]; # just a shorthand
vals := EmptyPlist(Size(dom));
vals[1] := (1,2,3,4,5); # in this case we happen to know the index
df2_ := DependencyFunction(dom,vals);
# they are of course the same object
df=df_;
df2=df2_;
