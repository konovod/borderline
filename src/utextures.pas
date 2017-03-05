unit uTextures;

interface

uses
  zgl_textures,
  zgl_file, zgl_log;

type

  { TAbstractTexture }

  TAbstractTexture = class
    filename: string;
    tex: zglPTexture;
    constructor Create(aname: string);
    procedure AfterLoad; virtual;
  end;

  { TSprite }

  TSprite = class(TAbstractTexture)
    procedure Draw(x,y: single);overload;
    procedure Draw(x, y, w, h: single);overload;
  end;

  { TAnimatedSprite }

  TAnimatedSprite = class(TAbstractTexture)
    Count: integer; frWidth, frHeight: Integer;
    constructor Create(aname: string; acount: integer);
    procedure AfterLoad; override;
    procedure Draw(fr: integer; x,y: single; eff: integer = 0);overload;
    procedure Draw(fr: integer; x, y, w, h: single; eff: integer = 0);overload;
  end;

  procedure ReloadAllTextures(DataDir: string);
  procedure ProcessLoadedTextures;
var
  TextureDataDir: string;
implementation
uses zgl_sprite_2d, uglobal, math;

var
  AllTextures: array of TAbstractTexture;

    { TAnimatedSprite }

constructor TAnimatedSprite.Create(aname: string; acount: integer);
begin
  inherited Create(aname);
  Count := acount;
end;

procedure TAnimatedSprite.AfterLoad;
begin
  frHeight := tex^.Height;
  frWidth := tex^.Width div count;
  tex_SetFrameSize(tex, frWidth, frHeight);
end;

procedure TAnimatedSprite.Draw(fr: integer; x, y: single; eff: integer = 0);
begin
  asprite2d_Draw( tex, x, y, frWidth, frHeight, 0, fr, 255, eff);
end;

procedure TAnimatedSprite.Draw(fr: integer; x, y, w, h: single; eff: integer = 0);
begin
  asprite2d_Draw( tex, x, y, w, h, 0, fr, 255, eff);
end;

  { TSprite }

procedure TSprite.Draw(x, y: single);
begin
  ssprite2d_Draw(tex, x, y, tex^.Width, tex^.Height, 0);
end;

procedure TSprite.Draw(x, y, w, h: single);
begin
  ssprite2d_Draw(tex, x, y, w, h, 0);
end;

  { TAbstractTexture }

constructor TAbstractTexture.Create(aname: string);
begin
  filename := aname+'.png';
  assert(file_Exists(TextureDataDir + filename));
  tex := tex_LoadFromFile( TextureDataDir + filename, TEX_NO_COLORKEY, TEX_CONVERT_TO_POT);
  SetLength(AllTextures, Length(AllTextures)+1);
  AllTextures[High(AllTextures)] := self;
end;

procedure TAbstractTexture.AfterLoad;
begin

end;

procedure ReloadAllTextures(DataDir: string);
var
  tex: TAbstractTexture;
begin
  {$ifdef cpuarm}
  for tex in AllTextures do
    tex_RestoreFromFile(tex.tex, datadir + tex.filename);
  {$endif}
end;


procedure ProcessLoadedTextures;
var
  alist: zglTFileList;
  i: integer;
  s: UTF8String;
  tex: TAbstractTexture;
  ok: boolean;
begin
  for tex in AllTextures do
    tex.AfterLoad;
  {$ifdef WINDOWS}
  file_Find(TextureDataDir, alist, False);
  for i := 0 to alist.Count-1 do
  begin
    s := alist.Items[i];
    ok := False;
    for tex in AllTextures do
      if tex.filename = s then
      begin
        ok := True;
        break;
      end;
    if not ok then
      log_Add('Unused texture: '+s)
  end;
  {$endif}
end;

end.

