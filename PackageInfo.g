SetPackageInfo( rec(

PackageName := "SgpDec",

Subtitle := "Hierarchical Coordinatizations of Finite Groups and Semigroups",

Version := "0.6.31",

Date := "18/03/2012",

ArchiveURL := "http://sgpdec.sf.net",

ArchiveFormats := ".tar.gz",

Persons := [
  rec(
    LastName      := "Egri-Nagy",
    FirstNames    := "Attila",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "attila@egri-nagy.hu",
    WWWHome       := "http://www.egri-nagy.hu",
    PostalAddress := Concatenation( [
                       "University of Hertfordshire\n",
                       "STRI\n",
                       "College Lane\n",
                       "AL10 9AB\n",
                       "United Kingdom" ] ),
    Place         := "Hatfield, Herts",
    Institution   := "UH"
  ),
  rec(
    LastName      := "L. Nehaniv",
    FirstNames    := "Chrystopher",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "C.L.Nehaniv@herts.ac.uk",
    WWWHome       := "http://homepages.feis.herts.ac.uk/~comqcln/",
    PostalAddress := Concatenation( [
                       "University of Hertfordshire\n",
                       "STRI\n",
                       "College Lane\n",
                       "AL10 9AB\n",
                       "United Kingdom" ] ),
    Place         := "Hatfield, Herts",
    Institution   := "UH"
  ),
  rec(
    LastName      := "Mitchell",
    FirstNames    := "J. D.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-and.ac.uk",
    WWWHome       := "http://tinyurl.com/jdmitchell",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  )
],

Status := "dev",

README_URL := "http://sgpdec.sf.net",

PackageInfoURL := "http://sgpdec.sf.net",


AbstractHTML :=
  "<span class=\"pkgname\">SgpDec</span> is  a <span class=\"pkgname\">GAP</span> package \
   for hierarchical decompositions of finite permutation groups and transformation semigroups.",

PackageWWWHome := "http://sgpdec.sf.net",

PackageDoc := rec(
  BookName  := "SgpDec",
  Archive :=  "http://sgpdec.sf.net",

  ArchiveURLSubset := ["htm"],
  HTMLStart := "doc/manual.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Hierarchical Decompositions of Finite Permutation Groups and Transformation Semigroups",
  Autoload  := true
),


Dependencies := rec(
 GAP := ">=4.5",
 NeededOtherPackages := [["GAPDoc", ">= 1.2"],  #StringPrint
                         ["citrus", ">= 0.1"], #orbit algorithms
                   ["orb", ">= 3.7"], #hashtable functionalities
                                           ["viz", ">= 0.1"] #Draw, Splash
                         ],
 SuggestedOtherPackages := [ ],
 ExternalConditions := [["Graphviz","http://www.graphviz.org/"]] #for creating PDF figures                      
),

AvailabilityTest := ReturnTrue,

Autoload := false,

TestFile := "test/test.g",

Keywords := ["Krohn-Rhodes Theory","transformation semigroup","permutation group","hierarchical decomposition"]

));


