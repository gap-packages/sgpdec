# testing Doting and Tikzing 
gap> START_TEST("Sgpdec package: viz.tst");
gap> LoadPackage("sgpdec", false);;
gap> SgpDecFiniteSetDisplayOn();;
gap> S := Semigroup([Transformation([1,1,2]), Transformation([3,2,1])]);;
gap> sk := Skeleton(S);;
gap> DotSkeleton(sk);
"//dot\ndigraph skeleton{ newrank=true;\n{node [shape=plaintext]\n edge [style\
=invis]\n1\n1->2\n2\n2->3\n}\nsubgraph cluster1{\n\"{1,2,3}\";color=\"black\";\
style=\"filled\";fillcolor=\"lightgrey\";label=\"C2\"  }\nsubgraph cluster2{\n\
\"{1,2}\";\"{2,3}\";color=\"black\";style=\"filled\";fillcolor=\"lightgrey\";l\
abel=\"C2\"  }\nsubgraph cluster3{\n\"{1}\";\"{3}\";\"{2}\";color=\"black\";  \
}\n{rank=same;1;\"{1,2,3}\";}\n{rank=same;2;\"{1,2}\";\"{2,3}\";}\n{rank=same;\
3;\"{1}\";\"{2}\";\"{3}\";}\n\"{1,2,3}\" [shape=box,color=black];\n\"{1,2,3}\"\
 -> \"{1,2}\"\n[label=\"[ 1 ]\"]\n\"{1,2,3}\" -> \"{2,3}\"\n[label=\"[ 1, 2 ]\
\"]\n\"{1,2}\" [shape=box,color=black];\n\"{1,2}\" -> \"{1}\"\n[label=\"[ 1 ]\
\"]\n\"{1,2}\" -> \"{2}\"\n[label=\"[ 1, 2, 1 ]\"]\n\"{1}\" [shape=box,color=b\
lack];\n}\n"
gap> DotSkeletonForwardOrbit(sk);
"//dot\ndigraph skeleton_forward_orbit{\nsubgraph cluster1{style=filled;color=\
lightgrey;\n\"{1,2,3}\";}\nsubgraph cluster2{style=filled;color=lightgrey;\n\"\
{1,2}\";\"{2,3}\";}\nsubgraph cluster3{style=filled;color=lightgrey;\n\"{1}\";\
\"{3}\";\"{2}\";}\n\"{1,2,3}\" -> \"{1,2}\" [label=\"1\"];\n\"{1,2,3}\" -> \"{\
1,2,3}\" [label=\"2\"];\n\"{1,2}\" -> \"{1}\" [label=\"1\"];\n\"{1,2}\" -> \"{\
2,3}\" [label=\"2\"];\n\"{1}\" -> \"{1}\" [label=\"1\"];\n\"{1}\" -> \"{3}\" [\
label=\"2\"];\n\"{2,3}\" -> \"{1,2}\" [label=\"1,2\"];\n\"{3}\" -> \"{2}\" [la\
bel=\"1\"];\n\"{3}\" -> \"{1}\" [label=\"2\"];\n\"{2}\" -> \"{1}\" [label=\"1\
\"];\n\"{2}\" -> \"{2}\" [label=\"2\"];\n\"{1,2,3}\" [shape=box,color=black];\
\n\"{1,2}\" [shape=box,color=black];\n\"{1}\" [shape=box,color=black];\n}\n"
gap> SgpDecFiniteSetDisplayOff();;

#
gap> STOP_TEST( "Sgpdec package: viz.tst", 10000);
