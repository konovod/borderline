unit ugame;

{$mode delphi}

interface

uses
  Classes, SysUtils, uglobal, uTextures, uMap, zgl_tiles_2d, zgl_primitives_2d,
  zgl_sprite_2d, zgl_textures, zgl_fx, zgl_particles_2d;


procedure NewGame;
procedure DrawAll;

var
  Map: TMap;
implementation

uses Math, uMain, uNameGen;

procedure NewGame;
begin
  InitNameGen;
  Map := TMap.Create;
  Map.Generate;
end;

procedure DrawAll;
begin
  Map.Draw;
end;


end.
