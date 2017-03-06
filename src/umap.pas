unit uMap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uglobal;

type

  TSystemState = (Hidden, Found, Visited, Current);

  { TSystem }

  TSystem = class
    id: integer;
    X,Y: Integer;
    Name: string;
    Links: array of TSystem;
    State: TSystemState;
    function Color: zglColor;
    procedure Draw;
    procedure DrawLinks;
    constructor Create(aid, ax, ay: integer; aname: string);
    procedure Enter;
    function Linked(asys: TSystem): boolean;
  end;

  { TMap }

  TMap = class
    Systems: array of TSystem;
    constructor Create;
    procedure Generate;
    procedure Draw;
    function FindSys(x, y: single): TSystem;
  end;

implementation

uses zgl_primitives_2d, zgl_text, zgl_fx, ugame, umapgen;

{ TMap }

constructor TMap.Create;
begin

end;

procedure TMap.Generate;
begin
  uMapGen.Generate(Self);
end;

procedure TMap.Draw;
var
  sys: TSystem;
begin
  for sys in Systems do
    sys.DrawLinks;
  for sys in Systems do
    sys.Draw;
end;

function TMap.FindSys(x, y: single): TSystem;
var
  sys: TSystem;
begin
  for sys in Systems do
    if Distance(x, y, sys.x, sys.y) < CLICKDIST then
    begin
      Result := sys;
      exit;
    end;
  Result := nil;
end;

{ TSystem }

function TSystem.Color: zglColor;
begin
  case State of
    Hidden: Result := Blue;
    Found: Result := Red;
    Visited: Result := Green;
    Current: Result := White;
  end;
end;

procedure TSystem.Draw;
begin
  if State = Hidden then exit;
  pr2d_Circle(X, Y, 10, Color, 255, 32, PR2D_FILL);
  text_Draw(fntMain, X, Y, Name);
  if Self = Cursor then
  begin
    CursorSize := (CursorSize + 1) mod (15*4);
    pr2d_Circle(X, Y, 15+15-CursorSize div 4, IntfDark);
  end;
end;

procedure TSystem.DrawLinks;
var
  other: TSystem;
begin
  if State <= Found then exit;
  for other in links do
//    if other.id > id then
      BoldLine(X,Y,other.X, other.Y, White);
end;

constructor TSystem.Create(aid, ax, ay: integer; aname: string);
begin
  id := aid;
  x := ax;
  y := ay;
  name := aname;
  State := Hidden;
end;

procedure TSystem.Enter;
var
  sys: TSystem;
begin
  State := Current;
  for sys in Links do
    if sys.State < Found then
      sys.State := Found;
end;

function TSystem.Linked(asys: TSystem): boolean;
var
  sys: TSystem;
begin
  Result := True;
  for sys in Links do
    if sys = asys then exit;
  Result := False;
end;


end.

