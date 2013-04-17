gap> Read("variables.g");;

# cascade - previously cascade(d) transformation, cascade transform

# Two ways to construct:
# 1. high level, dependency domains + individual dependencise
#    or identity
#    or a random one.
# 2. Low-level CreateCascade for giving the data structure members.

# Cascade
# creating a cascade is done by giving the domains of the dependency
# domains and a list of individual dependencies
gap> c := Cascade([FF,T3],[ [[],Transformation([1,1])],
>                 [[1],Transformation([3,3,2])],[[2],Transformation([2,3,2])]]);
<cascade with 2 levels with (2, 3) pts, 3 dependencies>
gap> Display(c);
Dependency function of depth 1 with 1 dependencies.
[ ] -> Transformation( [ 1, 1 ] )
Dependency function of depth 2 with 2 dependencies.
[ 1 ] -> Transformation( [ 3, 3, 2 ] )
[ 2 ] -> Transformation( [ 2, 3, 2 ] )

# it is recognized if all components are groups
gap> c := Cascade([Z2,Z3], [ [[],(1,2)], [[1],(1,2,3)] ]);
<cascade with 2 levels with (2, 3) pts, 2 dependencies>
gap> Display(c);
Dependency function of depth 1 with 1 dependencies.
[ ] -> (1,2)
Dependency function of depth 2 with 1 dependencies.
[ 1 ] -> (1,2,3)
gap> IsPermCascade(c);
true

# it is also possible to give only component domains, in that case
gap> Cascade([[1..2],[1..3]],[]);
<cascade with 2 levels with (2, 3) pts, 0 dependencies>
