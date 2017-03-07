unit umapgen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uMap, uglobal;

procedure Generate(Map: TMap);

const
  GALAXY_SIZE = 2000;
  ADD_LINKS = 0.2;
  N_SYSTEMS = 500;
  CLOSE_DIST = 100;

  N_ALIENS = 10;
  INDEPENDENT = 0.1;

implementation

uses uDelaunay, uNameGen, zgl_log;

procedure AddLink(first, second: TSystem);
begin
  SetLength(first.Links, Length(first.Links)+1);
  first.Links[Length(first.Links)-1] := second;
  SetLength(second.Links, Length(second.Links)+1);
  second.Links[Length(second.Links)-1] := first;
end;

procedure DelLink(sys: TSystem; index: integer);
begin
  if index <> High(sys.Links) then
    sys.Links[index] := sys.Links[High(sys.Links)];
  SetLength(sys.Links, High(sys.Links));
end;



procedure MinimalTree(Map: TMap);
//using https://ru.wikipedia.org/wiki/Алгоритм_Крускала
//and https://ru.wikipedia.org/wiki/Система_непересекающихся_множеств

type
  TLine = record
    Length, A,B: Integer;
    Active: Boolean;
  end;

var
  NRoots, NLines: Integer;
  Roots: array of Integer;
  Lines: array of TLine;

{procedure makeset(x:integer);
begin
  Roots[x] := x;
  inc(NRoots);
end;}

function find(x:integer):integer;
begin
  if Roots[x] <> x then
    Roots[x] := find(Roots[x]);
  Result := Roots[x];
end;

function union(x,y:integer): Boolean;
begin
  x := find(x);
  y := find(y);
  Result := x <> y;
  if Result then
  begin
    Dec(NRoots);
    if random <= 0.5 then
      Roots[x] := y
    else
      Roots[y] := x;
  end;
end;

  procedure DoQuickSort(iLo, iHi: Integer);
  var
    Lo, Hi: Integer;
    Mid: Double;
    T: TLine;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := Lines[(Lo + Hi) div 2].Length;
    repeat
      while Lines[Lo].Length < Mid do Inc(Lo);
      while Lines[Hi].Length > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        T := Lines[Lo];
        Lines[Lo] := Lines[Hi];
        Lines[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then DoQuickSort(iLo, Hi);
    if Lo < iHi then DoQuickSort(Lo, iHi);
  end;


var
  I, J, K, A, B: Integer;
  Ra, Rb: TSystem;
  MaxLine: Integer;
begin
  NRoots := length(Map.Systems);
  SetLength(Roots, NRoots);
  for I := 0 to NRoots - 1 do
    Roots[I] := I;
  NLines := 0;
  for I := 0 to NRoots - 1 do
    inc(NLines, Length(Map.Systems[I].Links));
  SetLength(Lines, NLines);
  NLines := 0;
  for I := 0 to NRoots - 1 do
    for J := 0 to Length(Map.Systems[I].Links) - 1 do
    begin
      A := I;
      B := Map.Systems[I].Links[J].id;
      if A < B then
      begin
        Lines[NLines].A := A;
        Lines[NLines].B := B;
      end;
      Ra := Map.Systems[A];
      Rb := Map.Systems[B];
      Lines[NLines].Length := Sqr(Ra.X-Rb.X)+Sqr(Ra.Y-Rb.Y);
      inc(NLines);
    end;
  if NLines = 0 then exit;
  //TODO: sort
  DoQuickSort(0, NLines-1);
  //Actually, process lines
  MaxLine := 0;
  while NRoots > 1 do
  begin
    Lines[MaxLine].Active := union(Lines[MaxLine].A, Lines[MaxLine].B);
    inc(MaxLine);
  end;
  //Now, extract data back to our structure
  for I := 0 to NLines-1 do
  begin
    if (I < MaxLine) and Lines[I].Active then continue;
    //also, add some more links
    if random < ADD_LINKS then continue;

    A := Lines[I].A;
    B := Lines[I].B;
    Ra := Map.Systems[A];
    Rb := Map.Systems[B];
    for K := Length(Ra.Links) - 1 downto 0 do
      if Ra.Links[K] = Rb then
      begin
        DelLink(Ra, K);
        break;
      end;
    for K := 0 to Length(Rb.Links) - 1 do
      if Rb.Links[K] = Ra then
      begin
        DelLink(Rb, K);
        break;
      end;
  end;
end;


procedure Populate(Map: TMap);
var
  i: integer;
  remains: integer;
  sys: TSystem;
  ants: array[1..N_ALIENS] of TSystem;
  nsteps, ntries: integer;

function RandomSys: TSystem;
begin
  Result := Map.Systems[Random(Length(Map.Systems))];
end;

function RandomNeighbour(asys: TSystem): TSystem;
begin
  Result := asys.Links[Random(Length(asys.Links))];
end;

function step(asys: TSystem; index: integer): Boolean;
begin
  Result := asys.AlienId in [0, index];
  if asys.PopStatus = WipedOut then
  begin
    asys.PopStatus := Alien;
    asys.AlienId := index;
    //asys.Name := IntToStr(index);//for debug
    dec(remains);
  end;
  if result then
    ants[index] := asys;
end;

begin
  //"empty" systems
  remains := 0;
  for sys in Map.Systems do
    if random < INDEPENDENT then
      sys.PopStatus := Colonizable
    else
    begin
      sys.PopStatus := WipedOut;
      inc(remains);
    end;
  //spawn civilizations
  for i := 1 to N_ALIENS do
  begin
    repeat
      ants[i] := RandomSys;
    until ants[i].PopStatus = WipedOut;
    step(ants[i], i);
  end;
  nsteps := GALAXY_SIZE;
  //expand them
  while (remains > 0) and (nsteps > 0) do
  begin
    dec(nsteps);
    for i := 1 to N_ALIENS do
    begin
      ntries := 1000;
      while (ntries > 0) and not step(RandomNeighbour(ants[i]), i) do dec(ntries);
    end;
  end;
  nsteps := 0;
  for sys in Map.Systems do
    if sys.PopStatus = WipedOut then
      inc(nsteps);
  if nsteps > 0 then
    log_Add('***********Failed planets: '+IntToStr(nsteps));
  //earth
  map.Systems[0].AlienId := 0;
  map.Systems[0].PopStatus := Own;
  for sys in Map.Systems do
    sys.InitGameStats;
end;



procedure Generate(Map: TMap);
var
  i, j,t, n: integer;
  n1, n2, n3: Integer;
  TRI: TDelaunay;

procedure AddLink1(first, second: Integer);
begin
  if first >= length(Map.Systems) then exit;
  if second >= length(Map.Systems) then exit;
  AddLink(Map.Systems[first], Map.Systems[second]);
end;

begin
  //use poisson-smth?
  n := N_SYSTEMS;
  SetLength(Map.Systems, n);
  //TODO: names generator
  for i := 0 to n-1 do
    Map.Systems[I] := TSystem.Create(i, Rand(1, GALAXY_SIZE), Rand(1, GALAXY_SIZE), '');
  //remove too close
  for i := n-2 downto 0 do
    for j := n-1 downto i+1 do
      if Distance(Map.Systems[i].X, Map.Systems[i].Y, Map.Systems[j].X, Map.Systems[j].Y) < CLOSE_DIST then
      begin
        Map.Systems[j].Free;
        if j <> n-1 then
        begin
          Map.Systems[j] := Map.Systems[n-1];
          Map.Systems[j].id := j;
        end;
        SetLength(Map.Systems, n-1);
        dec(n);
      end;
  Map.Systems[0].Name := 'Sun';
  for i := 1 to n-1 do
    Map.Systems[i].Name := GenerateName;
//  n := length(Map.Systems);
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
      AddLink1(n1, n2);
      AddLink1(n2, n3);
      AddLink1(n3, n1);
    end;
  TRI.Free;
  MinimalTree(Map);
  Populate(Map);
end;


end.

