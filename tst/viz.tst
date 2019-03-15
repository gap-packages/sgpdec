# testing Doting and Tikzing from skeletonviz 
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
gap> DotSubductionEquivalencePoset(sk);
"//dot\ndigraph skeleton{\nnode [shape=box ];\nedge [arrowhead=none ];\n1 [lab\
el=\"{1,2,3} \"];\n2 [label=\"{1,2} {2,3} \"];\n3 [label=\"{1} {3} {2} \"];\n1\
->2;\n2->3;\n}\n"
gap> DotChainActions(sk,Transformation([3,2,1]));
"//dot\ngraph chains{\nn1[shape=record,label=\"{1,2,3}\",color=\"black\"];\nn1\
_1[shape=record,label=\"{2,3}\",color=\"black\"];\nn1--n1_1\nn1_1_1[shape=reco\
rd,label=\"{3}\",color=\"black\"];\nn1_1--n1_1_1\nn1_1_2[shape=record,label=\"\
{2}\",color=\"black\"];\nn1_1--n1_1_2\nn1_2[shape=record,label=\"{1,2}\",color\
=\"black\"];\nn1--n1_2\nn1_2_1[shape=record,label=\"{2}\",color=\"black\"];\nn\
1_2--n1_2_1\nn1_2_2[shape=record,label=\"{1}\",color=\"black\"];\nn1_2--n1_2_2\
\n}\n"
gap> TikzChainActions(sk,Transformation([3,2,1]));
"%latex\n\\documentclass{minimal}\\usepackage{tikz}\\usetikzlibrary{trees}\\be\
gin{document}\n\n\\begin{tikzpicture}\n[level distance=1cm,level 1/.style={sib\
ling distance=1.3cm},level 2/.style={sibling distance=.6cm}]\n\n\\node {$\\{1,\
2,3\\}$} child { node{$\\{2,3\\}$} child { node{$\\{3\\}$}} child { node{$\\{2\
\\}$}}} child { node{$\\{1,2\\}$} child { node{$\\{2\\}$}} child { node{$\\{1\
\\}$}}};\\end{tikzpicture}\n\n\\end{document}\n"
gap> DotSemigroupAction(S, [1..3], OnPoints);
"//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"2\" -> \"1\"[label=\"\
1\"]\n\"3\" -> \"2\"[label=\"1\"]\n\"1\" -> \"3\"[label=\"2\"]\n\"3\" -> \"1\"\
[label=\"2\"]\n}\n"
gap> DotSemigroupActionWithNames(S, [1..3], OnPoints,["x1","x2","x3"],["g1","g2"] );
"//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"x2\" -> \"x1\"[label=\
\"g1\"]\n\"x3\" -> \"x2\"[label=\"g1\"]\n\"x1\" -> \"x3\"[label=\"g2\"]\n\"x3\
\" -> \"x1\"[label=\"g2\"]\n}\n"
gap> sk := Skeleton(FullTransformationSemigroup(3));;
gap> DotRepPermutatorGroups(sk);
[ "//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"1\" -> \"2\"[label=\
\"1,2\"]\n\"2\" -> \"1\"[label=\"1\"]\n\"2\" -> \"3\"[label=\"2\"]\n\"3\" -> \
\"1\"[label=\"2\"]\n}\n", 
  "//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"1\" -> \"2\"[label=\
\"112313\"]\n\"2\" -> \"1\"[label=\"112313\"]\n}\n" ]
gap> DotRepPermutatorGroups(sk, rec(states:=["x1","x2", "x3"], symbols:=["g1","g2", "g3"]) );
[ "//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"x1\" -> \"x2\"[labe\
l=\"g1,g2\"]\n\"x2\" -> \"x1\"[label=\"g1\"]\n\"x2\" -> \"x3\"[label=\"g2\"]\n\
\"x3\" -> \"x1\"[label=\"g2\"]\n}\n", 
  "//dot\ndigraph aut{\nnode [shape=circle]edge [len=1.2]\"x1\" -> \"x2\"[labe\
l=\"g1g1g2g3g1g3\"]\n\"x2\" -> \"x1\"[label=\"g1g1g2g3g1g3\"]\n}\n" ]
gap> SgpDecFiniteSetDisplayOff();;

#
gap> STOP_TEST( "Sgpdec package: viz.tst", 10000);
