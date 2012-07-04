#############################################################################
##
## skeleton.gi           SgpDec package
##
## Copyright (C)  Attila Egri-Nagy, Chrystopher L. Nehaniv
##
## Skeleton
##

#calculating the strongly connected components of singletons
#this is needed for augmenting the image set
SGPDEC_SingletonEquivalenceClasses := function(ts)
  local singletons,n, eqclasses, o, class;
    
  n := Degree(ts);
  singletons := List([1..n], x-> FiniteSet([x], n));
  eqclasses := [];
  while (not IsEmpty(singletons)) do
    o := Orb(ts, singletons[1], OnFiniteSets);
    Enumerate(o);  
    class := List(OrbSCC(o)[1], y->o[y]); 
    Add(eqclasses, class);
    SubtractSet(singletons, class);
  od;
  return eqclasses;  
end;

#Depth values are calculated from height values
#(once I tried a direct depth calculation, but that produced wrong results)
_Skeleton_depthCalc := function(sk)
local height,eqclass;
  height := GetEqClass(sk,TopSet(sk)).height;
  for eqclass in SkeletonClasses(sk) do
    eqclass.depth := height - eqclass.height + 1;
  od;
end;

#recursive calculation of height for equivalence classes
_Skeleton_calculateHeightFromSingleton := function(sk,eqclass,height)
local p,parents;
  parents := HTValue(sk!.eqclasspreimages, eqclass.rep);
  if parents = fail then return; fi; #we stop at the top level, the full state set
  for p in parents do
    if Size(p) > 1 then #if it is not a singleton
      if GetEqClass(sk,p).height  < height+1 then
        GetEqClass(sk,p).height := height+1;
        #only call when the height is raised (this saves a lot of calls)
        _Skeleton_calculateHeightFromSingleton(sk,GetEqClass(sk,p),height+1);
      fi;
    fi;
  od;
end;

# direct preimages of equivelence classes, i.e. building the Hasse diagram
# of the equivalence classes
_Skeleton_EquivClassdirectPreImages := function(sk)
local t,images,set,i,neqclass,preimght,preimgs,skelclasses;
  preimght := HTCreate(TopSet(sk));
  #just to have an immediate reference to equivalence classes
  skelclasses := SkeletonClasses(sk);
  for t in GeneratorsForSkeleton(sk) do
    #excluding permutations as they surely produce no eqclass switch 
    if RankOfTransformation(t) <> DegreeOfTransformation(t) then
      for i in [1..Length(skelclasses)] do
        #for all elements of the class we check where they land
        for set in skelclasses[i].elems do
          neqclass := GetEqClass(sk,OnFiniteSets(set, t));
          if (neqclass <> skelclasses[i]) then
            preimgs := HTValue(preimght, neqclass.rep);
            if preimgs <> fail then
              AddSet(preimgs, skelclasses[i].rep);# Display(preimgs);
              HTUpdate(preimght, neqclass.rep, preimgs);
            else
              HTAdd(preimght, neqclass.rep,[skelclasses[i].rep]);
            fi;
          fi;
        od;
      od;
    fi;
  od;
  #for nonimage subsets
  for i in [1..Length(skelclasses)] do
    for set in CoveringSetsOf(sk,skelclasses[i].rep) do
      neqclass := GetEqClass(sk,set);
      preimgs := HTValue(preimght, neqclass.rep);
      if preimgs <> fail then
        AddSet(preimgs, skelclasses[i].rep);
        HTUpdate(preimght, neqclass.rep, preimgs);
      else
        HTAdd(preimght, neqclass.rep, [skelclasses[i].rep]);
      fi;
    od;
  od;
  return preimght;
end;


# stack based BFS for finding OUT for a set in an equivalence class
_Skeleton_findRouteToRep := function(sk, A, eqclass)
local word,stack,i,visited,gens,path,set,nset,setinfo;
  gens := GeneratorsForSkeleton(sk);
  visited := HTCreate(A); #remembering the visited points
  stack := Stack(); #the stack of containing the points to be processed
  Store(stack, [[], A]); #initial content: empty word and the original set
  while not IsEmpty(stack) do
    path := Retrieve(stack); # info is : [word, resulting finite set]
    set := path[2];
    for i in [1..Size(gens)] do
      nset := OnFiniteSets(set, gens[i]);
      if set <> nset then  #there is a nontrivial action
        if HTValue(visited,nset) = fail then #when we find something new
          word := ShallowCopy(path[1]);
          Add(word,i);
          setinfo := InfoOnSet(sk, nset);
          if (nset in eqclass) and (IsBound(setinfo.OUTw)) then
            #found something that knows the way back, so we can simply take that route 
            return Concatenation(word, setinfo.OUTw);
          elif nset in eqclass then  #is it still in the same equiv class, if yes we continue with that
            HTAdd(visited, nset,true);
            Store(stack,[word,nset]);
          fi;
        fi;
      fi;
    od;
  od;
  # Normally this statement is not supposed to be reached.
  Error("### In _Skeleton_findRouteToRep we are in an equivalence class but cannot find a way from ", A, " to representative ", RepresentativeSet(sk,A),"! ###");
end;

#calculating the maps into an equivalence class element from the representative
_Skeleton_calcINs := function(sk, eqclass)
local gens, id, stack, setinfo, visited, data, word, set, nsetinfo,i,nset,t;
  #doing a graph search in the equivalence for calculating IN and INw
  gens := GeneratorsForSkeleton(sk);
  id := sk!.id;
  stack := Stack(); #the stack of containing the points to be processed
  setinfo := InfoOnSet(sk, eqclass.rep);
  setinfo.IN := id; setinfo.INw := []; #the representative is trivial
  setinfo.OUT := id; setinfo.OUTw := [];
  Store(stack, [[],id, eqclass.rep]); #initial content: [1]  the word, [2]  transformation, [3] the set
  visited := HTCreate(eqclass.rep); #remembering the visited points
  while not IsEmpty(stack) do
    data := Retrieve(stack);
    set := data[3];
    for i in [1..Size(gens)] do
      nset := OnFiniteSets(set, gens[i]);
      if (set <> nset) and ( HTValue(visited,nset) = fail) and (nset in eqclass.elems) then 
        #we've just found a nonvisited set in the eqclass
        HTAdd(visited, nset,true);
        word := ShallowCopy(data[1]);
        Add(word,i);
        t := data[2] * gens[i];
        nsetinfo := InfoOnSet(sk, nset);         
        nsetinfo.INw := word;
        nsetinfo.IN := t;
        Store(stack,[word,nsetinfo.IN, nset]);
      fi;
    od;
  od;  
  return true;
end;

#returns the n
_skeleton_Lemma_5_9 := function(A,f)
local power,n;
  power := One(f);
  n := 0;
  repeat 
    power := power * f;
    n := n+1;
  until IsIdentityOnFiniteSet(power, A);
  return n;
end;


_Skeleton_calcOUTs := function(sk, eqclass)
local n, traj,nnset, nnsetinfo,t, nsetinfo,setinfo,elem,set,nowayout_yet,l,fg,id,gens;
  gens := GeneratorsForSkeleton(sk);
  id := sk!.id;
  for set in eqclass.elems do
    setinfo := InfoOnSet(sk, set); 
    t := setinfo.IN;
    n := 1;
    traj := HTCreate(set);
    nnset := OnFiniteSets(set, t);
    nnsetinfo := InfoOnSet(sk, nnset);       
    while not IsBound(nnsetinfo.OUT) and (nnset in eqclass.elems) and (HTValue(traj,nnset) = fail) do
      t := t * setinfo.IN;
      n := n + 1;
      nnset := OnFiniteSets(set, t);
      HTAdd(traj, nnset,true);
      nnsetinfo := InfoOnSet(sk, nnset);       
    od;
    if IsBound(nnsetinfo.OUT)  and (nnset) in eqclass.elems then
      setinfo.OUT := t * nnsetinfo.OUT;
      setinfo.OUTw := Concatenation(List([1..n], x -> setinfo.INw));
      if STRAIGHTWORD_REDUCTION then
        setinfo.OUTw := Reduce2StraightWord(setinfo.OUTw, gens,id);
      fi;
      Append(setinfo.OUTw, nnsetinfo.OUTw);
    fi;
  od;
  
  for set in eqclass.elems do
    setinfo := InfoOnSet(sk, set);
    #if OUT not yet calculated then do it now
    if not (IsBound(setinfo.OUT)) then 
      setinfo.OUTw := _Skeleton_findRouteToRep(sk,set, eqclass.elems);
      setinfo.OUT := Construct(setinfo.OUTw, gens, id,\*);
    fi;
    # doing the proper out
    n := _skeleton_Lemma_5_9(eqclass.rep, setinfo.IN * setinfo.OUT);
    l := [];
    Add(l, setinfo.OUTw);
    fg := Flat([setinfo.INw,setinfo.OUTw]);
    Add(l, ListWithIdenticalEntries(n-1,fg));
    setinfo.OUTw := Flat(l);
    setinfo.OUT := setinfo.OUT * ((setinfo.IN * setinfo.OUT)^(n-1));
    if STRAIGHTWORD_REDUCTION then
      setinfo.OUTw := Reduce2StraightWord(setinfo.OUTw, gens,id);
    fi;
  od;
  return true;
end;

####CONSTRUCTOR
InstallMethod(Skeleton,[IsTransformationSemigroup],
function(T)
local i, skeleton, eqclass,imageset,tmp,t,o, scc;
  skeleton := rec();
  #for convenience we keep some objects
  skeleton.ts := T;
  skeleton.gens := GeneratorsOfSemigroup(T);
  skeleton.id := One(skeleton.gens[1]);
  skeleton.topset := FiniteSet([1..DegreeOfTransformation(Representative(T))]);
  
  # 1. Obtaining equivalence classes of images (strong orbits) 
  Info(SkeletonInfoClass, 2, "SKELETON"); t := Runtime();
  # calling a function of CITRUS
  o := Orb(T, skeleton.topset, OnFiniteSets, rec(schreier:=true, orbitgraph:=true));
  Enumerate(o);
  OrbSCC(o);
  
  skeleton.equivclasses :=  List(OrbSCC(o), x-> List(x, y->o[y])); 
  Info(SkeletonInfoClass, 2, "Equivalence classes (strong orbits) ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();
  
  # 2. sorting is for recognizing whether the singleton is already there or not
  Perform(skeleton.equivclasses, Sort);
  Info(SkeletonInfoClass, 2, "Sorting equivalence classes ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();
  
  # 3. we have to include the nonimage singleton in case they are missing
  for scc in SGPDEC_SingletonEquivalenceClasses(T) do
      Sort(scc);
      #TODO ADDSet comparison for collections needed
      Add(skeleton.equivclasses, scc, PositionSorted(skeleton.equivclasses, scc));
  od;
  Info(SkeletonInfoClass, 2, "Adding singleton sets ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 4. creating the big set of images before equiv classes are decorated  
  skeleton.imagesets := Concatenation(skeleton.equivclasses);
  Sort(skeleton.imagesets, BySizeSorterAscend); #we need this here but why? 
  Info(SkeletonInfoClass, 2, "Concatenating and sorting imagesets ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 5. putting the extra info for the equivalence class
  skeleton.equivclasses := List(skeleton.equivclasses, x -> rec(elems:=x, height:=0, depth :=0,rep := x[1]));
  #Sort(skeleton.equivclasses);#sorting again - probably not so important 
  Info(SkeletonInfoClass, 2, "Equivalence classes data structure ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 6. building a lookup table for imageset -> in,out, equivclass
  skeleton.setinfolookup := HTCreate(skeleton.imagesets[1]);
  for eqclass in skeleton.equivclasses do 
    for imageset in eqclass.elems do
      #for now just putting the equivalenceclass there
      HTAdd(skeleton.setinfolookup,imageset, rec(eqclass:=eqclass));
    od; 
  od;
  Info(SkeletonInfoClass, 2, "Imageset info lookup table ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 7. partial order of the inclusion relation on the image set
  skeleton.inclusion_relation := PartialOrderByOrderingFunctionNC(
            Domain(skeleton.imagesets),
            function(A,B) return IsSubset(A,B);end);
  Info(SkeletonInfoClass, 2, "Inclusion partial order ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();
  # 8. the hassediagram of the inclusion relation on the image set
  skeleton.inclusion_hassediag := HasseDiagramOfSubsets(skeleton.imagesets);
  Info(SkeletonInfoClass, 2, "Inclusion hasse diagram ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 9. it is time to put together the object
  skeleton := Objectify(SkeletonType,skeleton);

  
  # 10. direct images for equivalence classes
  skeleton!.eqclasspreimages := _Skeleton_EquivClassdirectPreImages(skeleton);
  Info(SkeletonInfoClass, 2, "Direct images of equivalence classes ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();

  # 11. calculating buses
  Perform(skeleton!.equivclasses, x->_Skeleton_calcINs(skeleton,x));
  Info(SkeletonInfoClass, 2, "Buses IN ", SGPDEC_TimeString(Runtime()-t)); t := Runtime(); 
  Perform(skeleton!.equivclasses, x->_Skeleton_calcOUTs(skeleton,x));
  Info(SkeletonInfoClass, 2, "Buses OUT ", SGPDEC_TimeString(Runtime()-t)); t := Runtime(); 
  # 12. calculation heights - starting from each singleton equivalence classes
  Perform(skeleton!.equivclasses, function(x) if Size(x.rep) = 1 then _Skeleton_calculateHeightFromSingleton(skeleton,x,0); fi;end);
  Info(SkeletonInfoClass, 2, "Height values ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();
  # 13. calculating depth
  _Skeleton_depthCalc(skeleton);  
  Info(SkeletonInfoClass, 2, "Depth values ", SGPDEC_TimeString(Runtime()-t)); t := Runtime();  
  Info(SkeletonInfoClass, 2, "DEPTH: ", DepthOfSkeleton(skeleton)-1);  
  return skeleton;
end);

###########ACCESSING IMAGE SETS#####################################

InstallGlobalFunction(SkeletonClasses,
function(sk)
  return sk!.equivclasses;
end
);

InstallGlobalFunction(SkeletonClassesOnDepth,
function(tp, depth)
  return Filtered(tp!.equivclasses, x -> x.depth = depth  );
end
);

InstallGlobalFunction(DisplaySkeletonRepresentatives,
 function(sk)
local i, class;
  for i in [1..DepthOfSkeleton(sk)] do
    for class in SkeletonClassesOnDepth(sk,i) do
      Print(class.rep," ");
    od; 
    Print("\n");
  od; 
end
);

InstallGlobalFunction(ActionMatrix,
function(sk, eqclass)
local i,g, gens, A, n, nodes, j;
  gens := GeneratorsForSkeleton(sk);
  nodes := eqclass.elems;
  n := Size(nodes);
  A := NullMat(n,n);
  for i in [1..n] do
    for g in gens do
      j := Position(nodes, nodes[i] * g);
      if j <> fail then # if it remains within the equivalence class
        A[i][j] := A[i][j] + 1;
      fi;
    od;
  od;
  return A;
end
);


InstallGlobalFunction(ImageSets,
function(sk)
  return sk!.imagesets;
end
);


InstallGlobalFunction(TopSet,
function(tp)
  return tp!.topset;
end
);

InstallGlobalFunction(InfoOnSet,
function(sk, set)
  return HTValue(sk!.setinfolookup, set);
end
);


InstallGlobalFunction(GetEqClass,
function(tp, set)
  return HTValue(tp!.setinfolookup, set).eqclass;
end
);


InstallGlobalFunction(RepresentativeSet,
function(tp, set)
  return HTValue(tp!.setinfolookup, set).eqclass.rep;
end
);

InstallGlobalFunction(ChangeRepresentativeSet,
function(sk, set)
local eqclass, elem;
  eqclass := GetEqClass(sk,set);
  eqclass.rep := set;
  #clearing the previous entries
  for elem in eqclass.elems do
      #for now just putting the equivalenceclass there
      HTUpdate(sk!.setinfolookup,elem, rec(eqclass:=eqclass));
  od;
  #recalculate trains TODO this could be optimized to calculate only a the changed one
  _Skeleton_EquivClassdirectPreImages(sk);  
  #recalculate buses - this should be done in full 
  _Skeleton_calcINs(sk, eqclass);
  _Skeleton_calcOUTs(sk, eqclass);
end
);


InstallGlobalFunction(GetIN,
function(tp, set)
  return HTValue(tp!.setinfolookup, set).IN;
end
);

InstallGlobalFunction(GetOUT,
function(tp, set)
  return HTValue(tp!.setinfolookup, set).OUT;
end
);


InstallGlobalFunction(DepthOfSet,
function(tp, set)
  return HTValue(tp!.setinfolookup, set).eqclass.depth;
end
);

InstallGlobalFunction(DepthOfSkeleton,
function(sk)
  #just the depth of a singleton
  return DepthOfSet(sk, FiniteSet([1], DegreeOfTransformation(sk!.id)));
end
);


InstallGlobalFunction(IsEquivalent,
function(sk,A,B)
  return HTValue(sk!.setinfolookup, A).eqclass = HTValue(sk!.setinfolookup, B).eqclass; 
end
);


InstallGlobalFunction(CoveringSetsOf,
function(sk,A)
  return Images(sk!.inclusion_hassediag,A);
end
);

InstallGlobalFunction(Permutators,
function(sk,set)
local permutators,i,j,setinfo,nsetinfo,eqclass,rrec,gens,word;
  permutators := [];
  Sort(permutators);
  gens := GeneratorsForSkeleton(sk);
  setinfo := InfoOnSet(sk, set);
  eqclass := setinfo.eqclass;
  #for all elements of the equivalence class of the set
  for i in [1..Length(eqclass.elems)] do
    #for all generators
    for j in [1..Length(gens)] do
      #we hit an element in the class by a generator
      nsetinfo := InfoOnSet(sk, OnFiniteSets(eqclass.elems[i] ,gens[j]));
      #if it stays in the class then it will give rise to a permutator
      if nsetinfo.eqclass = eqclass then
        rrec :=  InfoOnSet(sk, eqclass.elems[i]);
        word :=  Concatenation(rrec.INw,[j],nsetinfo.OUTw);
        if not (word in permutators) then Add(permutators, word, PositionSorted(permutators, word)); fi;
      fi;
    od;
  od;
  #conjugation here
  permutators := List(permutators, x -> Concatenation(setinfo.OUTw, x, setinfo.INw));
  if STRAIGHTWORD_REDUCTION then 
    permutators := List(permutators, x -> Reduce2StraightWord(x, gens, sk!.id)); #reducing on sets yield alien actions
    permutators := DuplicateFreeList(permutators); # straightening may introduce duplicates
  fi;
  return permutators;
end
);

InstallGlobalFunction(PermutatorGenerators,
function(sk,set)
  return Filtered(Permutators(sk,set), 
                  x -> not (IsIdentityOnFiniteSet(Construct(x, GeneratorsForSkeleton(sk), sk!.id,\*) ,set)));  
end
);

InstallGlobalFunction(PermutatorSemigroup,
function(sk,set)
local gens;
  gens := List(PermutatorGenerators(sk,set), x->Construct(x, sk!.gens, sk!.id,\*));
  if IsEmpty(gens) then gens := [sk!.id]; fi;
  return SemigroupByGenerators(gens);
end
);

InstallGlobalFunction(AllPermutators,
function(tp,set)
  return AsList(PermutatorSemigroup(tp,set));
end
);

InstallGlobalFunction(PermutatorGroup,
function(tp,set)
local gens;
  gens :=AsSet(List(List(PermutatorGenerators(tp,set),
                                    x->Construct(x, tp!.gens, tp!.id,\*)),x->Transf2PermOnSet(x,set)));
  if IsEmpty(gens) then gens := [()]; fi;
  return Group(gens);
end
);

InstallGlobalFunction(CoverGroup,
function(sk,set)
local gens;
  gens := AsSet(List(List(PermutatorGenerators(sk,set),
                                    x->Construct(x, sk!.gens, sk!.id,\*)),x->SGPDEC_CanonicalPermutationAction(CoveringSetsOf(sk,set),x,OnFiniteSets)));
  if IsEmpty(gens) then gens := [()]; fi;
  return Group(gens);
end
);

#returns a random (mainly for checking purposes) subset chain from the given singleton 
InstallGlobalFunction(RandomCoverChain,
function(tp,k)
local chain, set, topset;
  chain := [];
  topset := TopSet(tp);
  set := FiniteSet([k], Size(topset));
  Add(chain,set);
  while set <> topset do
    set := Random(PreImages(tp!.inclusion_hassediag, set));
    Add(chain,set);
  od;  
  Remove(chain);#quick hack - we don't need the full set in the chain
  return Reversed(chain);
end
);

InstallGlobalFunction(NumberOfCoverChainsToSet,
function(tp,set)
local sizes, preimgs;
  if set = TopSet(tp) then return 1; fi;
  preimgs := PreImages(tp!.inclusion_hassediag, set);
  #Display(preimgs);
  sizes := List(preimgs, x -> NumberOfCoverChainsToSet(tp,x));
  #Display(sizes);
  return Length(sizes)*Product(sizes);
end);

_skeleton_rec_AllCoverChainsToSet := function(tp,chain ,coll, relation)
local set,preimg, l;
  set := LastElementOfList(chain);
  if set = TopSet(tp) then
    l :=  ShallowCopy(chain);
    Remove(l);# we don't need the top
    Add(coll, Reversed(l));
    return;
  fi;
  for preimg in  PreImages(relation, set) do
    if preimg <> LastElementOfList(chain) then  
      Add(chain, preimg);
      _skeleton_rec_AllCoverChainsToSet(tp, chain, coll,relation);
      Remove(chain);
    fi;
  od;
  return;  
end;

InstallGlobalFunction(AllCoverChainsToSet,
function(tp, set)
local coll;
  coll := [];
  _skeleton_rec_AllCoverChainsToSet(tp, [set], coll, tp!.inclusion_hassediag);
  return coll;
end
);

InstallGlobalFunction(AllCoverChains,
function(tp)
local coll,n,i;
  coll := [];
  n := Size(TopSet(tp));
  for i in [1..n] do
    Append(coll, AllCoverChainsToSet(tp, FiniteSet([i],n)));
  od;
  return coll;
end
);


InstallGlobalFunction(AllChainsToSet,
function(tp, set)
local coll;
  coll := [];
  _skeleton_rec_AllCoverChainsToSet(tp, [set], coll, tp!.inclusion_relation);
  return coll;
end
);

InstallGlobalFunction(RandomChain,
function(sk, k)
  return Random(AllChainsToSet(sk, FiniteSet([k],Size(TopSet(sk)))));
end
);


InstallGlobalFunction(AllChains,
function(tp)
local coll,n,i;
  coll := [];
  n := Size(TopSet(tp));
  for i in [1..n] do
    Append(coll, AllChainsToSet(tp, FiniteSet([i],n)));
  od;
  return coll;
end
);



#########OLD METHODS#####################################

InstallOtherMethod(Size,"for skeletons",true,[IsSkeleton],
function(sk)
  return DepthOfSkeleton(sk);
end
);

#
InstallMethod( PrintObj,"for a skeleton",
    [ IsSkeleton ],
function( sk )
  Print("Skeleton of  ", sk!.ts, ", image sets: ", Size(sk!.imagesets) ,", equivalence classes: ",
        Size(sk!.equivclasses), ", levels: ", DepthOfSkeleton(sk));
end );

######ACCESS###########################################
InstallGlobalFunction(GeneratorsForSkeleton,
function(sk)
  return GeneratorsOfSemigroup(sk!.ts);
end
);

InstallGlobalFunction(GetTS,
function(sk)
  return sk!.ts;
end
);

#####DRAWING
# creating graphviz file for drawing the 
InstallGlobalFunction(DotSkeleton,
function(sk,params)
local  str, i,label,node,out,class,classes,set,states;

  str := "";
  out := OutputTextString(str,true);  
  PrintTo(out,"digraph skeleton{\n");

  if ExistsFieldInRecord(params, "states") then
    states := params.states;
  else
    states := [1..999];
  fi;

  
  #defining the hierarchical levels - the nodes are named only by integers
  AppendTo(out, "{node [shape=plaintext]\n edge [style=invis]\n");
  for i in [1..DepthOfSkeleton(sk)-1] do
    AppendTo(out,Concatenation(StringPrint(i),"\n"));
    if i <= DepthOfSkeleton(sk) then
      AppendTo(out,Concatenation(StringPrint(i),"->",StringPrint(i+1),"\n"));
    fi;    
  od;
  AppendTo(out,"}\n");
  
  #drawing equivalence classes
  classes :=  SkeletonClasses(sk);
    for i in [1..Length(classes)] do
     AppendTo(out,"subgraph cluster",StringPrint(i),"{\n");
      for node in classes[i].elems do
        AppendTo(out,"\"",FiniteSetPrinter(node,states),"\";");
     od;
     AppendTo(out,"color=\"black\"}\n");
    od;



  #drawing the the same level elements
  for i in [1..DepthOfSkeleton(sk)] do
    AppendTo(out, "{rank=same;",StringPrint(i),";");
    for class in SkeletonClassesOnDepth(sk,i) do
      for node in class.elems do
            AppendTo(out,"\"",FiniteSetPrinter(node,states),"\";");
     od;
    od;
    AppendTo(out,"}\n");
  od;

  #drawing the representatives as rectangles and their covers
    for class in SkeletonClasses(sk) do     
      AppendTo(out,"\"",FiniteSetPrinter(class.rep,states),"\" [shape=box,color=black];\n");
      for set in CoveringSetsOf(sk, class.rep) do
          AppendTo(out,"\"",FiniteSetPrinter(class.rep,states),"\" -> \"",FiniteSetPrinter(set,states),"\"\n");     
      od;     
    od;
    AppendTo(out,"}\n");
    CloseStream(out);
    return str;
end
);

InstallGlobalFunction(SplashSkeleton,
function(sk)
    Splash(DotSkeleton(sk, rec()));    
end
);

#TODO!! this may be simply the SemigroupAction in Viz
#graphvizing the equivalence class action
_skeletonDrawClassAction := function(sk, eqclass, params)
local i,g, gens, A, n, nodes, j, newnode, file, ht, entries, edge, currentlabel,label,states,inputsymbols;



  if ExistsFieldInRecord(params, "symbols") then
    inputsymbols := params.symbols;
  else
    inputsymbols := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
             "A","B","C","D","E","F","G","H","I","J","K","L","M","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
  fi;

  if ExistsFieldInRecord(params, "states") then
    states := params.states;
  else
    states := [1..999];
  fi;


  file := Concatenation(params.filename,".dot");  
  PrintTo(file,"digraph eqclass{\n");



  gens := GeneratorsForSkeleton(sk);
  nodes := eqclass.elems;
  n := Size(nodes);

  ht := HTCreate("{1,2,3} -> {2,4,5}");
  entries := [];
  for i in [1..n] do
    for j in [1..Size(gens)] do
      label := Concatenation("", inputsymbols[j]);

      newnode := nodes[i] * gens[j];
      if newnode in nodes then # if it remains within the equivalence class
        edge := Concatenation("\"",FiniteSetPrinter(nodes[i],states),"\"", " -> " , "\"",FiniteSetPrinter(newnode,states),"\"");      
      else
        edge := Concatenation("\"",FiniteSetPrinter(nodes[i],states),"\"", " -> " , "OUT");      
      fi;

      #checking whether the label is new or not
      currentlabel :=  HTValue(ht, edge);     
      if currentlabel = fail then
        HTAdd(ht,edge,label);
        Add(entries, edge);   
      else
        HTUpdate(ht,edge,Concatenation(currentlabel,",",label)); 
      fi;           
    od;
  od;         
   
  #now drawing 
  for edge in entries do
    AppendTo(file,Concatenation(edge , " [label=\"", HTValue(ht,edge) , "\"]\n"));
  od; 
  AppendTo(file,"}\n");
end;
