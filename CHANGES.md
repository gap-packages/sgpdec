## 1.2.0 (2025-06-20)

- Fixing an issue in the holonomy skeleton: when the orbit of the state set did not contain any singleton set, DepthOfSkeleton missed the last level. Consequently, DisplayHolonomyComponents missed the last level too, and the emulation did not work. BREAKING: some previous examples may report an extra level.

## 1.1.0 (2024-06-28)

- New parsing algorithm for the attractor-cycle notation. The previous convoluted solution did not always work for more than 9 states. Breaking change: the implementation now strictly follows the context-free grammar specification, thus the expression "[1|2,3,4]" is now treated as malformed. Adding more tests for the notation. Technical function SgpDecTestInstall2 added to get some information on memory usage of tests.

## 1.0.0 (2024-06-20)

- Covering Lemma implementation. Code for essential dependencies revised and corrected. Switching to Break Versioning.

## 0.9.8 (2024-06-13)

- Better constructors for Cascades needed by the upcoming Covering Lemma implementation.
- Cascades now have a partially implemented List interface. This was needed to be able use them in HashMaps. BREAKING CHANGE: as a consequence, the ^ operation is not registered any more for OnCoordinates.
- Skeleton visualisation: non-image singletons visually separated to an additional level, but not contributing to depth.
- Direct depth calculation - height computation removed. Some decomposition may change as the loose components are pushed upwards.
- MaxChainOfEssentialDependency added.

## 0.9.7 (2023-09-01)

- BREAKING CHANGES: ContainsSet(sk, P) replaced with P in ExtendedImageSet(sk), since ExtendedImageSet is now a HashSet for faster lookup. SortedExtendedImageSet added for retaining the functionality of having a sorted list of the extended images.
- CompactNotation has different semantics now and it is renamed to AttractorCycleNotation. LinearNotation has been removed.
- Other changes:
- DotTransformation added.
- ComputeSkeletonNavigationTables added. This replaces the previous caching mechanisms. With this all skeleton navigation functions can be precomputed.

## 0.9.6 (2023-08-11)

- MakeRepresentative added. To simplify the process of changing a representative, the primitve caching mechanism for the words navigating in the equivalence classes were removed. This makes computing the morphism for holonomy less performant. Proper memoization is to be added later.

## 0.9.5 (2023-08-10)

- Adding preliminary support for calculating essential dependencies. Simplifying functions in skeleton.gi. Subduction relation checking is more efficient now, using the partial order of equivalence class representatives. Partial orbit calculation caching removed.

## 0.9.4 (2022-09-03)

- Release for GAP 4.12.0. Semigroups introduced RandomWord, so it is removed from SgpDec.

## 0.9.3 (2021-06-29)

- The star state was added previously to explicitly represent the situation where the cascade action 'jumps over' some levels. However, the extra states unnecessarily increase the size of the component state sets, leading to bigger decompositions. This release removes the star state and uses the constant 1 map as the default component action. Thus, the decompositions will be smaller.

## 0.9.2 (2019-03-25)

- Making FL conversion functions polymorphic, so they can either take an FLCascadeGroup for convenience, or a list of transversals if obtaining a decompositions (lifting the generators) is not feasible.

## 0.9.1 (2019-03-20)

- Separating computation of  transversals and component groups into different functions: FLTransversals, FLComponents. This is useful for computing decompositions partially, in case the whole FLCascadeGroup is not feasible. ValidPoints is now defined as an attribute of FLCascadeGroup to avoid recalculation. Standard way of testing with TestPackage("sgpdec") is available now.

## 0.9 (2019-03-18)

- Reps2Perm added. PermutatorSemigroupElts fixed. Documentation entries added. Unified format for DisplayHolonomyComponents and DisplayFLComponents when the Small Groups library is not used.

## 0.8.3 (2019-03-15)

- Adding new visualization functions: DotRepPermutatorGroups, DotRepHolonomyGroups. Small fixes and cleanups related to increased code coverage.

## 0.8.2 (2019-03-15)

- Successful CI integration. Group decomposition functions finalized. Increased code coverage. Fix: FullCascadeSemigroup created properly to avoid long elements enumeration.

## 0.8.1 (2019-03-13)

- Update release compatible with GAP 4.10.1. Reworked group decomposition. Added documentation.

## 0.8 (2019-03-09)

- Update release compatible with GAP 4.10.0. Some documentation added. Finiteness property set for cascade groups.

## 0.7.33 (2016-02-27)

- Update release compatible with GAP 4.8.2. Hash function patch removed.

## 0.7.32 (2016-01-16)

- Patching for missing hash function for boolean lists until Orb has one.

## 0.7.31 (2015-12-14)

- Tests are compatible with GAP4.8/Semigroups 2.7. Small fixes for visualization.

## 0.7.30 (2015-07-20)

- Bringing the code in sync with the paper: now we have an extra state on each level to act on representing jumped over levels. Numerous little fixes code improvements in the last year.

## 0.7.29 (2014-06-18)

- The release of finally understanding holonomy decomposition! :) Holonomy core rewritten with dominating tile chains. Alternative height functions. RestrictedDomain added for future optimization. Code cleaning, commenting. Regression fixes fo Splash.

## 0.7.28 (2014-03-26)

- Updating the skeleton diagram to work with GraphViz 2.36. Added ContainsSet function for the skeleton and use it for checks to avoid error messages. Added RandomTileChainToSet.

## 0.7.27 (2013-10-30)

- Fixing DisplayHolonomyComponents: no need to display singletons and size of the set was wrongly displayed instead of number of tiles.

## 0.7.26 (2013-10-28)

- DisplayHolonomyComponents and OnTileChain added.

## 0.7.25 (2013-10-06)

- Subgroup chains methods readded, defending against upstream change (dynamic degree for transformations), nonimage tiles by dotted arrows in DotSkeleton.

## 0.7.24 (2013-09-12)

- DotCascadeAction added.

## 0.7.23 (2013-09-12)

- DotCascade revised, highlighting moved branches properly. Added FormattedBigNumberString, SimplerCompactNotation. Working on the documentation.

## 0.7.22 (2013-08-02)

- Improved DotSkeleton. Cascade constructor now accepts list of domain sizes. Dep2DepFuncs renamed to DependencyFunctions. Coordinate action and cascade multiplication now have global functions and installed methods.

## 0.7.21 (2013-07-10)

- RealImageSkeletonClasses added. DependencyValues added. Documenting some functionality.

## 0.7.20 (2013-07-10)

- More doc on demand. Streamlining functions for the finite set 'illusion' layer.

## 0.7.19 (2013-07-02)

- BugFix: The lack of non image singletons led to loosing the last level of the decomposition. The fix also makes DotSkeleton consistent again.

## 0.7.18 (2013-07-01)

- BugFix: AsCascade wrongly lifted some elements of T_8 into a [2,2,2] tree. The previous algorithm did not detect overwriting existing actions in some cases. Added test case for DisjointUnionGroup and documentation compilation framework is back again.

## 0.7.17 (2013-06-26)

- Separating calculation for permutation reset semigroups. DisjointUnionGroup introduced.

## 0.7.16 (2013-06-24)

- DotSkeletonForwardOrbit added. Skeleton code now separated into 3 different files: orbit and relations, permutator and holonomy, and visualisation files.

## 0.7.15 (2013-06-19)

- Major rewrite of the holonomy data structure. HolonomyDecomposition disappeared, merged into the Skeleton.

## 0.7.14 (2013-06-16)

- 2nd gen Skeleton replaced by 3rd gen Skeleton. Skeleton is not a big record, but an object with attributes. Permutator part of the code is separated to avoid huge source files. Proper binary relations for inclusion and subduction added. Subduction relation functions added.

## 0.7.13 (2013-05-30)

- SgpDecTestInstall added. Fixing broken WreathProductGroup.

## 0.7.12 (2013-05-29)

- Test cases added. Print methods for cascades. Bugfix: holonomy components are now set.

## 0.7.11

- Updated to the upcoming GAP 4.7. TransCascades and PermCascades properly separated. Bugfix in =,< for cascades. Holonomy lifting added. Finite set display for blists properly done.

## 0.7.10 (2013-05-25)

- Clean up in FL decomposition and further simplification in the holonomy decomposition code. Tile-terminology is back.

## 0.7.9 (2013-05-24)

- Holonomy decomposition is back but only in pieces.

## 0.7.8 (2013-05-22)

- Lagrange decomposition and  Skeleton is back. Thin layer for boolean lists to behave as finite set added.

## 0.7.7 (2013-04-07)

- CascadeGroup added and code shared with CascadeSemigroup now lifted to CascadeProduct. New codebase is ready to reintegrate Lagrange Decomposition.

## 0.7.6 (2013-03-18)

- AsTransformation method for string (containing linear notation) and int (size of domain) added.

## 0.7.5 (2013-03-13)

-     Mixed components are allowed again, with minimal code changes. Further cleanups following the DependencyFunction separation. New test case for checking lifting as well.
- 0.7.4.
-     Dependency functions are now separated for each level, thus cascades become tuples of dependency functions. Exactly as described mathematically.

## 0.7.3 (2013-03-05)

- Numerous renamings, unified DomainOf and DependencyDomainsOf for cascades and cascade semigroups. IdentityCascade added. Test scripts updated.

## 0.7.2 (2013-03-04)

- DotCascade reimplemented with better drawing style. The whole domain tree is drawn and nontrivial dependenices are highlighted.

## 0.7.1 (2013-02-27)

- Unified ComponentDomains instead of the confusing and long ComponentDomainsOfCascade and ComponentDomainsOfCascadeSemigroup.

## 0.7 (2013-01-23)

- Restarting the development with a new and clean implementation of cascade products. Better integration with existing semigroup functions, for instance added IsomorphismTransformationSemigroup. SemigroupWreathProduct working.
