unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d;


procedure NewGame;
procedure DrawAll;
//just for a test
procedure OnClick(ax, ay: single);

var
  Map: TMap;
  CurSys: TSystem;
implementation

uses Math, uMain, uNameGen;

procedure DoJump(sys: TSystem);
begin
  if Assigned(CurSys) then
    CurSys.State := Visited;
  CurSys := sys;
  CurSys.JumpTo;
  ScrollToCenter(CurSys.X, CurSys.Y);
end;

procedure NewGame;
begin
  InitNameGen;
  Map := TMap.Create;
  Map.Generate;
  DoJump(Map.Systems[0]);
end;

procedure DrawAll;
begin
  Map.Draw;
end;

procedure OnClick(ax, ay: single);
var
  sys: TSystem;
begin
  sys := Map.FindSys(ax, ay);
  if sys <> nil then
    DoJump(sys);
end;


end.
