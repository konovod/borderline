unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d;



function Rand(afrom, ato :integer) :integer; overload;
function Randf(afrom, ato :single) :single; overload;
procedure BoldLine(X1, Y1, X2, Y2 :single; C :cardinal);


procedure NewGame;
procedure DrawAll;

var
  Map: TMap;
implementation

uses Math, uMain;

function Rand(afrom, ato :integer) :integer; overload;
begin
  assert(ato >= afrom);
  if ato = afrom then
    Result := afrom
  else
    Result := Random(ato - afrom + 1) + afrom;
end;

function Randf(afrom, ato :single) :single; overload;
begin
  Result := Random * (ato - afrom) + afrom;
end;

procedure BoldLine(X1, Y1, X2, Y2 :single; C :cardinal);
const
  delta = 0.5;
begin
  pr2d_Line(X1, Y1, X2, Y2, c, 255, 0);
  if abs(X1 - X2) > abs(Y1 - Y2) then
  begin
    pr2d_Line(X1, Y1 - delta, X2, Y2 - delta, c, 255, PR2D_SMOOTH);
    pr2d_Line(X1, Y1 + delta, X2, Y2 + delta, c, 255, PR2D_SMOOTH);
  end
  else
  begin
    pr2d_Line(X1 - delta, Y1, X2 - delta, Y2, c, 255, PR2D_SMOOTH);
    pr2d_Line(X1 + delta, Y1, X2 + delta, Y2, c, 255, PR2D_SMOOTH);
  end;
end;

procedure NewGame;
begin
  Map := TMap.Create;
  Map.Generate;
end;

procedure DrawAll;
begin
  Map.Draw;
end;


end.
