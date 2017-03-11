unit uglobal;

interface

uses   zgl_font, zgl_textures, zgl_math_2d, SysUtils, uGameTypes;

type
  zglColor = LongWord;

const

  White = $FFFFFF;
  Red = $FF0000;
  Green = $00FF00;
  Blue = $0000FF;
  Black = $000000;
  Dark = $101010;
  IntfText = $80FF00;
  IntfDark = $408000;
  IntfBack = Black;

{$IFDEF CPUARM}
  //SCREENX = 1280 div 2;
  //SCREENY = 720 div 2;
	SCREENX = 1280;
	SCREENY = 720;
{$ELSE}
	SCREENX = 1024;
	SCREENY = 700;
//  SCREENY = 768;

{$ENDIF}

  TOPPANEL_LEFT = 0.12;
  TOPPANEL_WIDTH = 1-TOPPANEL_LEFT*2;
  ACTIONBTN_WIDTH = 0.2;

  SYSTEMINFO_WIDTH = 0.3;
  SYSTEMINFO_HEIGHT = 0.3;

  PLAYERINFO_WIDTH = 0.2;
  PLAYERINFO_HEIGHT = 0.5;
  PLAYERINFO_TOP = 0.33;

  MANY = 10000;
  MINDIST = 10;
  CLICKDIST = 50;

  MODAL_WIDTH = 0.9;
  MODAL_HEIGHT = 0.8;
  CLOSE_WIDTH = 0.05;

  N_LOG_LINES = 19;

  BTL_LOG_WIDTH = 0.38;
  BTL_LOG_TOP = 0.2;
  BTL_LOG_HEIGHT = 0.7;
  N_BTL_LOG_LINES = 32;



var
  fntMain:  zglPFont;
  fntSecond:  zglPFont;
  Quitting: Boolean;

function Distance(X1, Y1, X2, Y2: Single): Single;

function Rand(afrom, ato :integer) :integer; overload;
function Randf(afrom, ato :single) :single; overload;
procedure BoldLine(X1, Y1, X2, Y2 :single; C :cardinal);
procedure DrawPanelUI(X,Y,W,H: Single; alpha: single = 1);
procedure DrawPanel(X,Y,W,H: Single; alpha: single = 1);
procedure DrawFormattedText(X,Y,W,H: Single; caption, text: string);
procedure DrawSomeText(X,Y,W,H: Single; caption, text: string);

function MyDateToStr(adate: TStarDate): string;

function InRect(x,y: single; x0,y0,w,h: single): boolean;

implementation
uses Math, zgl_primitives_2d, zgl_text;

function Distance(X1, Y1, X2, Y2: Single): Single;
begin
  Result := sqrt(sqr(x1-x2)+sqr(y1-y2));
end;

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

procedure DrawPanel(X,Y,W,H: Single; alpha: single = 1);
var
  a: byte;
begin
  a := EnsureRange(Trunc(alpha*256), 0, 255);
  pr2d_Rect(X, Y, W, H, Black, a, PR2D_FILL);
  pr2d_Rect(X, Y, W, H, IntfText);
end;

procedure DrawFormattedText(X, Y, W, H: Single; caption, text: string);
var
  R: zglTRect;
begin
  R.X := X;
  R.Y := Y + 25;
  R.W := W;
  R.H := H;
  text_DrawEx(fntMain, X, Y, 0.6, 0, caption,  255, White, TEXT_HALIGN_LEFT+TEXT_VALIGN_TOP);
  text_DrawInRectEx(fntMain, R, 0.5, 0, Text,  255, IntfText, {TEXT_CLIP_RECT+}TEXT_HALIGN_JUSTIFY+TEXT_VALIGN_TOP);
  //ExtractSubstr();
end;

procedure DrawSomeText(X, Y, W, H: Single; caption, text: string);
var
  R: zglTRect;
begin
  R.X := X;
  R.Y := Y+10;
  R.W := W;
  R.H := 25;
  text_DrawInRectEx(fntMain, R, 1, 0, caption,  255, White, TEXT_HALIGN_CENTER+TEXT_VALIGN_CENTER);
  R.X := X;
  R.Y := Y + 35;
  R.W := W;
  R.H := H;
  text_DrawInRectEx(fntMain, R, 1, 0, Text,  255, IntfText, TEXT_CLIP_RECT+TEXT_HALIGN_JUSTIFY+TEXT_VALIGN_TOP);
end;

procedure DrawPanelUI(X,Y,W,H: Single; alpha: single = 1);
begin
  DrawPanel(SCREENX*X, SCREENY*Y, SCREENX*W, SCREENY*H, alpha);
end;

function MyDateToStr(adate: TStarDate): string;
begin
  Result := IntToStr(2113+adate);
  //DateTimeToString(Result, 'yyyy-mm-dd', adate)
end;

function InRect(x, y: single; x0, y0, w, h: single): boolean;
begin
  Result := InRange(x, x0, x0+w) and InRange(y, y0, y0+h);
end;

end.
