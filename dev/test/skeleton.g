TestSkeletonCoveringSets := function(sk)
local point, tiles;
  for point in ImageSets(sk) do
    tiles := CoveringSetsOf(sk,point);
    if IsSingleton(point) then
      if not IsEmpty(tiles) then
        Print("FAIL\n");Error("Skeleton: singleton set covered!\n");
      fi;
    else
      if UnionFiniteSet(tiles) <> point then
        Print("FAIL\n");Error("Skeleton: covers do not cover!\n");
      fi;
    fi;
  od;
end;

TestSkeletonINOUTs := function(sk)
local img;
  Print("INOUT");
  for img in ImageSets(sk) do
    if IsIdentityOnFiniteSet(GetIN(sk,img)*GetOUT(sk,img),
               RepresentativeSet(sk,img)) then
      Print("#\c");
    else
      Print("FAIL\n");Error("Skeleton: INOUTs don't give the identity!\n");
    fi;
  od;
  Print("\nIN");
  for img in ImageSets(sk) do
    if OnFiniteSets(RepresentativeSet(sk,img), GetIN(sk,img)) = img then
      Print("#\c");
    else
      Print("FAIL\n");Error("Skeleton: IN does not go into the set!\n");
    fi;
  od;
  Print("\nOUT");
  for img in ImageSets(sk) do
    if OnFiniteSets(img, GetOUT(sk,img)) = RepresentativeSet(sk,img) then
      Print("#\c");
    else
      Print("FAIL\n");
      Error("Skeleton: OUT does not go into the representative!\n");
    fi;
  od;
end;

TestSkeleton := function(ts)
local t,sk;
  t := Runtime();

  sk := Skeleton(ts);
  TestSkeletonCoveringSets(sk);
  TestSkeletonINOUTs(sk);

  Print("PASSED in ",Runtime() - t,"ms\n");
end;