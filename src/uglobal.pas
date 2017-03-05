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

  GALAXY_SIZE = 500;

var
  fntMain:  zglPFont;
  fntSecond:  zglPFont;
  Quitting: Boolean;

function Distance(X1, Y1, X2, Y2: integer): integer;
function RealDistance(X1, Y1, X2, Y2: Single): Single;
implementation
uses Math;

function Distance(X1, Y1, X2, Y2: integer): integer;
begin
    //Result := Abs(X1 - X2) + Abs(Y1 - Y2);
  Result := Max(Abs(X1 - X2), Abs(Y1 - Y2));
//  Result := Max(Abs(X1 - X2), Abs(Y1 - Y2)) + Min(Abs(X1 - X2), Abs(Y1 - Y2)) div 2;
end;

function RealDistance(X1, Y1, X2, Y2: Single): Single;
begin
  Result := sqrt(sqr(x1-x2)+sqr(y1-y2));
end;

end.
