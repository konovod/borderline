unit umapgen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uMap, uglobal;

procedure Generate(Map: TMap);

implementation

uses uDelaunay, zgl_log;

procedure Generate(Map: TMap);
var
  i, j,t, n: integer;
  n1, n2, n3: Integer;
  TRI: TDelaunay;

procedure AddLink(first, second: Integer);
begin
  if first >= length(Map.Systems) then exit;
  if second >= length(Map.Systems) then exit;
  Map.Systems[first].AddLink(Map.Systems[second]);
  Map.Systems[second].AddLink(Map.Systems[first]);
end;

begin
  //test version
  n := 10;
  SetLength(Map.Systems, n);
  //TODO: names generator
  for i := 0 to n-1 do
    Map.Systems[I] := TSystem.Create(i, Rand(1, GALAXY_SIZE), Rand(1, GALAXY_SIZE), 'Star #'+IntToStr(I+1));
  //TODO: remove too close

  n := length(Map.Systems);
  //delaunay triangulation
  TRI := TDelaunay.Create;
  for I := 0 to n - 1 do
    TRI.AddPoint(Map.Systems[I].X+random, Map.Systems[I].Y+random);
  TRI.Mesh;
  for I := 1 to TRI.HowMany do
    with TRI.Triangle.Items[I] do
    begin
      n1 := TRI.Vertex.Items[vv0].Original-1;
      n2 := TRI.Vertex.Items[vv1].Original-1;
      n3 := TRI.Vertex.Items[vv2].Original-1;
      AddLink(n1, n2);
      AddLink(n2, n3);
      AddLink(n3, n1);
    end;
  TRI.Free;

end;

end.

