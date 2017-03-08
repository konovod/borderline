unit uUI;

interface

uses SysUtils, Math, zgl_primitives_2d, zgl_text, zgl_math_2d, zgl_sprite_2d;


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


  TInvertState = (Normal, Inactive, Active);
  TButtonsArray = array of TButton;

  { TModalWindow }

  TModalWindow = class
    buttons: TButtonsArray;
    procedure Draw; virtual; abstract;
    function ProcessClick(x, y: Integer; event: TMouseEvent): Boolean;virtual;
  end;

var
  IngameButtons: TButtonsArray;
  __ax, __ay: integer;
  ModalWindow: TModalWindow;

procedure StdButton(Text: string; X,Y,W,H: Single; State: TInvertState = Normal);
implementation

uses umain, uglobal, ugame, uGameUI;


function Buttons: TButtonsArray;
begin
  if ModalWindow <> nil then
    Result := ModalWindow.buttons
  else
    Result := IngameButtons
end;


procedure StdButton(Text: string; X,Y,W,H: Single; State: TInvertState = Normal);
var
  R: zglTRect;
  Col: Cardinal;
begin
  case State of
    Normal: Col := IntfBack;
    Inactive: Col := IntfBack;
    Active: Col := IntfText;
  end;

//  pr2d_Ellipse( X+W/2, Y+H/2, W/2, H/2, Col, 255, 32, PR2D_FILL or PR2D_SMOOTH );
  pr2d_Rect( X, Y, W, H, Col, 255, PR2D_FILL or PR2D_SMOOTH );
  R.X := X;
  R.Y := Y;
  R.W := W;
  R.H := H;

  case State of
    Normal: Col := IntfText;
    Inactive: Col := IntfDark;
    Active: Col := IntfBack;
  end;

  pr2d_Rect( X, Y, W, H, Col, 255, PR2D_SMOOTH );
  text_DrawInRectEx(fntMain, R, 1, 0, Text, 255, Col, TEXT_VALIGN_BOTTOM + TEXT_HALIGN_CENTER);
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
  if ModalWindow <> nil then
  begin
    for B in IngameButtons do
      if B.Visible then
        B.Draw;
    ModalWindow.Draw;
  end;
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
    if B.Visible and InRect(x, y, B.X, B.Y, B.W, B.H) and (event in B.CatchEvents) then
    begin
      B.Click(event);
      Result := true;
      exit;
    end;
  if ModalWindow <> nil then
    Result := ModalWindow.ProcessClick(x,y,event)
  else
    Result := false;
end;

{ TModalWindow }

function TModalWindow.ProcessClick(x, y: Integer; event: TMouseEvent): Boolean;
begin
  Result := False;
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
