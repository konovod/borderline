unit uglobal;

interface

uses   zgl_font, zgl_textures;

type
  zglColor = LongWord;

const

  White = $FFFFFF;
  Red = $FF0000;
  Green = $00FF00;
  Blue = $0000FF;
  Black = $000000;

{$IFDEF CPUARM}
  SCREENX = 1280 div 2;
  SCREENY = 720 div 2;
{$ELSE}
	SCREENX = 1024;
	SCREENY = 700;
//  SCREENY = 768;

{$ENDIF}

  MANY = 10000;
  MINDIST = 10;
  CLICKDIST = 50;

var
  fntMain:  zglPFont;
  fntSecond:  zglPFont;
  Quitting: Boolean;

function Distance(X1, Y1, X2, Y2: Single): Single;

function Rand(afrom, ato :integer) :integer; overload;
function Randf(afrom, ato :single) :single; overload;
procedure BoldLine(X1, Y1, X2, Y2 :single; C :cardinal);


implementation
uses Math, zgl_primitives_2d;

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



end.
