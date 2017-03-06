unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d;


procedure NewGame;
procedure DrawAll;
procedure DrawGameUI;
//just for a test
procedure OnClick(ax, ay: single);

var
  Map: TMap;
  CurSys: TSystem;
  Turn: integer;
  StarDate: TDate;

procedure NextTurn;
implementation

uses Math, uMain, uNameGen, zgl_text;

procedure DoJump(sys: TSystem);
begin
  NextTurn;
  if Assigned(CurSys) then
    CurSys.State := Visited;
  CurSys := sys;
  CurSys.JumpTo;
  ScrollToCenter(CurSys.X, CurSys.Y);
end;

procedure NewGame;
begin
  InitNameGen;
  StarDate := EncodeDate(2212, 3, 12);
  Map := TMap.Create;
  Map.Generate;
  DoJump(Map.Systems[0]);
end;

procedure DrawAll;
begin
  Map.Draw;
end;

procedure DrawGameUI;
begin
//  text_Draw(fntMain, SCREENX/2,50, DateToStr(StarDate), TEXT_VALIGN_CENTER + TEXT_HALIGN_CENTER);
end;

procedure OnClick(ax, ay: single);
var
  sys: TSystem;
begin
  sys := Map.FindSys(ax, ay);
  if sys <> nil then
    DoJump(sys);
end;

procedure NextTurn;
begin
  inc(Turn);
  //TODO - all processing
  StarDate := IncMonth(StarDate, 4+random(3));
end;


end.
