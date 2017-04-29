![SgpDec logo](doc/logo128x128.png)
# SgpDec: Hierarchical Composition and Decomposition of Permutation Groups and Transformation Semigroups

## What is it good for?
SgpDec is a computational implementation of Krohn-Rhodes theory. It is capable of decomposing transformation semigroups and permutation groups into simpler components, or composing simple components into complex structures. The building blocks are put together in a cascade product, which is an efficiently constructed subsemigroup of the wreath product of the components. The hierarchical nature of the cascade product allows us to build successive approximations of finite computational structures.

There is an excellent [video introduction to Krohn-Rhodes theoryt by Simon DeDeo](https://www.youtube.com/playlist?list=PLWpny35W2zZPr6COsyOD-PujR-_bWMjUk), a part of [an online course on renormalization](https://www.complexityexplorer.org/tutorials/67-introduction-to-renormalization). Throwing away information selectively in order to understand complex systems is a fundamental idea for SgpDec as well.



For a lightweight popular science style reading on computational semigroup theory check the computational semigroup theory blog (https://compsemi.wordpress.com/).

## How to use it?

You need the latest version of the GAP computer algebra system (https://github.com/gap-system/gap).

To get some idea what SgpDec is capable of, check this paper: SgpDec: Cascade (De)Compositions of Finite Transformation Semigroups and Permutation Groups (http://link.springer.com/chapter/10.1007/978-3-662-44199-2_13). For further details the documentation should be helpful.

The preprint Computational Holonomy Decomposition of Transformation Semigroups http://arxiv.org/abs/1508.06345 contains a constructive proof of the holonomy decomposition that is in close correspondence to the implementation.

## Where to complain when something goes wrong?

Please report any problem or request features by creating on issue on the project page here.

## Who are you?

Attila Egri-Nagy www.egri-nagy.hu @EgriNagy

James D. Mitchell http://www-groups.mcs.st-andrews.ac.uk/~jamesm/ @jdmjdmjdmjdm 

Chrystopher L. Nehaniv http://homepages.herts.ac.uk/~nehaniv/  @NehanivCL
