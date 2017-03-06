unit uGameUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uUI, ugameactions, uglobal;

type

  { TDateButton }

  TDateButton = class(TButton)
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
  end;

  { TActionButton }

  TActionButton = class(TButton)
    index: integer;
    function Visible: Boolean;override;
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
    constructor Create(aX, aY, aW, aH: Single; aindex: integer);
    function MyAction: TAction;
  end;




procedure InitUI;
implementation

uses ugame;

{ TActionButton }

function TActionButton.Visible: Boolean;
begin
  Result := index < Length(ActiveActions);
end;

procedure TActionButton.Draw;
begin
  if MyAction.Allowed then
    StdButton(MyAction.Text, X, Y, W, H, Normal)
  else
    StdButton(MyAction.Text, X, Y, W, H, Inactive);
end;

procedure TActionButton.Click(event: TMouseEvent);
begin
  if MyAction.Allowed then MyAction.Execute;
end;

constructor TActionButton.Create(aX, aY, aW, aH: Single; aindex: integer);
begin
  inherited Create(ax,ay,aw,ah);
  index := aindex;
end;

function TActionButton.MyAction: TAction;
begin
  Result := ActiveActions[index];
end;

{ TDateButton }

procedure TDateButton.Draw;
begin
  StdButton(DateToStr(StarDate), X,Y,W,H,Inactive);
end;

procedure TDateButton.Click(event: TMouseEvent);
begin

end;

procedure InitUI;

procedure add(bt: TButton);
begin
  SetLength(IngameButtons, Length(IngameButtons)+1);
  IngameButtons[High(IngameButtons)] := bt;
end;

var
  i, j: integer;
  cx, cy: single;
begin
  add(TDateButton.Create(0.40,0.01,0.2,0.06));
  cy := 0.1;
  cx := 0;
  for i := 1 to 15 do
  begin
    add(TActionButton.Create(TOPPANEL_LEFT+cx, cy, ACTIONBTN_WIDTH-0.02, 0.05, i-1));
    cx := cx+ACTIONBTN_WIDTH;
    if cx > TOPPANEL_WIDTH - ACTIONBTN_WIDTH then
    begin
      cx := 0;
      cy := cy+0.07;
    end;
  end;
end;



end.

