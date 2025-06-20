##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "1.1.0">
##  <!ENTITY COPYRIGHTYEARS "2008-2025">
##  <#/GAPDoc>

SetPackageInfo(rec(

PackageName := "SgpDec",

Subtitle := "Hierarchical Decompositions of Finite Groups and Semigroups",

Version := "1.2.0",

Date := "20/06/2025", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    LastName      := "Egri-Nagy",
    FirstNames    := "Attila",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "attila@egri-nagy.hu",
    WWWHome       := "http://www.egri-nagy.hu",
    PostalAddress := Concatenation( [
                       "Akita Internationl University\n",
                       "Yuwa, Akita-City\n",
                       "010-1292\n",
                       "JAPAN" ] ),
    Place         := "Akita",
    Institution   := "AIU"
  ),
  rec(
    LastName      := "Nehaniv",
    FirstNames    := "Chrystopher L.",
    IsAuthor      := true,
    IsMaintainer  := false,
    Email         := "C.L.Nehaniv@herts.ac.uk",
    WWWHome       := "https://uwaterloo.ca/systems-design-engineering/profile/cnehaniv",
    PostalAddress := Concatenation( [
                       "University of Waterloo\n",
                       "Waterloo Institute for Complexity and Innovation (WICI)" ] ),
    Place         := "Waterloo, Canada",
    Institution   := "UW"
  ),
  rec(
    LastName      := "Mitchell",
    FirstNames    := "J. D.",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "jdm3@st-and.ac.uk",
    WWWHome       := "https://jdbm.me/",
    PostalAddress := Concatenation( [
                       "Mathematical Institute,",
                       " North Haugh,", " St Andrews,", " Fife,", " KY16 9SS,",
                       " Scotland"] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
  )
],

Status := "dev",

PackageWWWHome := "https://gap-packages.github.io/sgpdec/",
README_URL     := Concatenation(~.PackageWWWHome, "README"),
PackageInfoURL := Concatenation(~.PackageWWWHome, "PackageInfo.g"),
ArchiveURL     := Concatenation("https://github.com/gap-packages/sgpdec/",
                           "releases/download/v", ~.Version,
                           "/sgpdec-", ~.Version),
                   ArchiveFormats := ".tar.gz .tar.bz2",
SourceRepository := rec(
  Type := "git",
  URL := "https://github.com/gap-packages/sgpdec"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
AbstractHTML := "<span class=\"pkgname\">SgpDec</span> is  a <span class=\
                   \"pkgname\">GAP</span> \
                   package for hierarchical decompositions of finite \
                   permutation groups and transformation semigroups.",

PackageDoc := rec(
  BookName  := "SgpDec",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Hierarchical Decompositions of Finite Groups and Semigroups",
),


Dependencies := rec(
 GAP := ">= 4.12.2",
 NeededOtherPackages := [["GAPDoc", ">=1.6.6"],  #StringPrint
                   ["orb", ">=4.9.0"],
                   ["semigroups", ">=5.2.0"],
                   ["datastructures", ">=0.3.0"]
                   ],
 SuggestedOtherPackages := [],
 ExternalConditions := [ ]
),

AvailabilityTest := ReturnTrue,


TestFile := "tst/testall.g",

Keywords := ["Krohn-Rhodes Theory",
             "transformation semigroup",
             "permutation group",
             "hierarchical decomposition"]
));
