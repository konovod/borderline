unit uMap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uglobal;

type

  { TSystem }

  TSystem = class
    id: integer;
    X,Y: Integer;
    Name: string;
    Links: array of TSystem;
    function Color: zglColor;
    procedure Draw;
    constructor Create(aid, ax, ay: integer; aname: string);
    procedure AddLink(sys: TSystem);
  end;

  { TMap }

  TMap = class
    Systems: array of TSystem;
    constructor Create;
    procedure Generate;
    procedure Draw;
  end;

implementation

uses zgl_primitives_2d, zgl_text, ugame;

{ TMap }

constructor TMap.Create;
begin

end;

procedure TMap.Generate;
var
  i, j,t, n: integer;
begin
  //test version
  n := 10;
  SetLength(Systems, n);
  for i := 0 to n-1 do
    Systems[I] := TSystem.Create(i, Rand(1, GALAXY_SIZE), Rand(1, GALAXY_SIZE), 'Star #'+IntToStr(I+1));
  for i := 0 to n-1 do
    for j := 0 to 1 do
    begin
      repeat
        t := Random(n);
      until t <> i;
      Systems[i].AddLink(Systems[t]);
      Systems[t].AddLink(Systems[i]);
    end;
end;

procedure TMap.Draw;
var
  sys: TSystem;
begin
  for sys in Systems do
    sys.Draw;
end;

{ TSystem }

function TSystem.Color: zglColor;
begin
  Result := Red;
end;

procedure TSystem.Draw;
var
  other: TSystem;
begin
  pr2d_Circle(X, Y, 10, Color, 255, 32, PR2D_FILL);
  text_Draw(fntMain, X, Y, Name);
  for other in links do
    if other.id > id then
      BoldLine(X,Y,other.X, other.Y, White);
end;

constructor TSystem.Create(aid, ax, ay: integer; aname: string);
begin
  id := aid;
  x := ax;
  y := ay;
  name := aname;
end;

procedure TSystem.AddLink(sys: TSystem);
begin
  SetLength(Links, Length(Links)+1);
  Links[Length(Links)-1] := sys;
end;

end.

