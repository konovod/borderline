unit uUI;

interface

uses SysUtils, Math, zgl_primitives_2d, zgl_text, zgl_math_2d, zgl_sprite_2d;


procedure InitUI;
procedure DrawUI;

type
  TMouseEvent = (LeftDown, LeftUp, RightDown, RightUp);
  TMouseEvents = set of TMouseEvent;

function ClickUI(x, y: Integer; event: TMouseEvent): Boolean;

type

  { TButton }

  TButton = class
    X,Y,W,H: Single;
    function Visible: Boolean;virtual;
    procedure Draw; virtual; abstract;
    procedure Click(event: TMouseEvent); virtual; abstract;
    function CatchEvents: TMouseEvents; virtual;
    constructor Create(aX,aY,aW,aH: Single);
  end;

  { TRestartButton }

  TRestartButton = class(TButton)
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
  end;

  TInvertState = (Normal, Inactive, Active);
  TButtonsArray = array of TButton;

var
  IngameButtons: TButtonsArray;
  __ax, __ay: integer;

procedure StdButton(Text: string; X,Y,W,H: Single; State: TInvertState = Normal);
implementation

uses umain, uglobal, ugame;


function Buttons: TButtonsArray;
begin
  Result := IngameButtons
end;


procedure StdButton(Text: string; X,Y,W,H: Single; State: TInvertState = Normal);
var
  R: zglTRect;
  Col: Cardinal;
begin
  case State of
    Normal: Col := $FF109F10;// $FF5F5F5F;
    Inactive: Col := $FF5F5F5F;
    Active: Col := $FFFFFFFF;
  end;

//  pr2d_Ellipse( X+W/2, Y+H/2, W/2, H/2, Col, 255, 32, PR2D_FILL or PR2D_SMOOTH );
  pr2d_Rect( X, Y, W, H, Col, 255, PR2D_FILL or PR2D_SMOOTH );
  R.X := X;
  R.Y := Y;
  R.W := W;
  R.H := H;

  case State of
    Normal: Col := 0;
    Inactive: Col := $FA1A1A1;
    Active: Col := 0;
  end;

  pr2d_Rect( X, Y, W, H, Col, 255, PR2D_SMOOTH );
  text_DrawInRectEx(fntSecond, R, 1, 0, Text, 255, Col, TEXT_VALIGN_CENTER + TEXT_HALIGN_CENTER);
end;

procedure StdCross(X,Y,W,H: Single);
begin
    pr2d_Line(X,Y,X+W,Y+H,$FF0000);
    pr2d_Line(X,Y+1,X+W,Y+H+1,$FF0000);
    pr2d_Line(X,Y+2,X+W,Y+H+2,$FF0000);
    pr2d_Line(X,Y+H,X+W,Y,$FF0000);
    pr2d_Line(X,Y+H+1,X+W,Y+1,$FF0000);
    pr2d_Line(X,Y+H+2,X+W,Y+2,$FF0000);
end;

procedure DrawUI;
var
  B: TButton;
begin
  for B in Buttons do
    if B.Visible then
      B.Draw;
end;

function ClickUI(x, y: Integer; event: TMouseEvent): Boolean;
var
  B: TButton;
begin
  __ax := x;
  __ay := y;
  for B in Buttons do
    if B.Visible and InRange(x, B.X, B.X+B.W) and InRange(y, B.Y, B.Y+B.H) and (event in B.CatchEvents) then
    begin
      B.Click(event);
      Result := true;
      exit;
    end;
  Result := false;
end;

procedure InitUI;

procedure add(bt: TButton);
begin
  SetLength(IngameButtons, Length(IngameButtons)+1);
  IngameButtons[High(IngameButtons)] := bt;
end;

var
  i: integer;
begin
  add(TRestartButton.Create(0.6,0,0.08,0.08));
end;

{ TRestartButton }

procedure TRestartButton.Draw;
begin
  //StdButton('Restart', X,Y,W,H);

end;

procedure TRestartButton.Click(event: TMouseEvent);
begin

end;

{ TButton }

constructor TButton.Create(aX, aY, aW, aH: Single);
begin
  inherited Create;
  X := aX*SCREENX;
  Y := aY*SCREENY;
  W := aW*SCREENX;
  H := aH*SCREENY;
end;

function TButton.Visible: Boolean;
begin
  Result := True;
end;

function TButton.CatchEvents: TMouseEvents;
begin
  Result := [LeftUp];
end;


end.
