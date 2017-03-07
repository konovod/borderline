unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d, uGameTypes;


procedure NewGame;
procedure DrawAll;
procedure DrawGameUI;
//just for a test
procedure OnClick(ax, ay: single);

var
  Map: TMap;
  PlayerSys, Cursor: TSystem;
  CursorSize: Integer;
  Turn: integer;
  StarDate: TDate;

procedure NextTurn;
implementation

uses Math, uMain, uNameGen, zgl_text;

procedure NewGame;
begin
  InitNameGen;
  StarDate := EncodeDate(2212, 3, 12);
  Map := TMap.Create;
  Map.Generate;
  PlayerSys := Map.Systems[0];
  Cursor := nil;
  PlayerSys.Enter;
  ScrollToCenter(PlayerSys.x, PlayerSys.y);
end;

procedure DrawAll;
begin
  Map.Draw;
  if Cursor <> nil then
    Cursor.ShowInfo(Cursor.X, Cursor.Y);
end;

procedure DrawGameUI;
begin
  DrawPanelUI(TOPPANEL_LEFT-0.005, 0, TOPPANEL_WIDTH+0.01, 0.26);
  //if Cursor <> nil then
  //begin
  //  DrawPanelUI(0, 1-SYSTEMINFO_HEIGHT, SYSTEMINFO_WIDTH, SYSTEMINFO_HEIGHT);
  //  Cursor.ShowInfo(0, SCREENY*(1-SYSTEMINFO_HEIGHT));
  //end;
  DrawPanelUI(1-PLAYERINFO_WIDTH, PLAYERINFO_TOP, PLAYERINFO_WIDTH, PLAYERINFO_HEIGHT);
end;

procedure OnClick(ax, ay: single);
var
  sys: TSystem;
begin
  sys := Map.FindSys(ax, ay);
  if sys <> cursor then
    CursorSize := 0;

  if sys <> nil then
    Cursor := sys
  else
    Cursor := nil;
end;

procedure NextTurn;
begin
  inc(Turn);
  //TODO - all processing
  StarDate := IncMonth(StarDate, 4+random(3));
end;


end.
