unit uGameUI;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uUI;

type

  { TDateButton }

  TDateButton = class(TButton)
    procedure Draw; override;
    procedure Click(event: TMouseEvent); override;
  end;




procedure InitUI;
implementation

uses ugame;

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
  i: integer;
begin
  add(TDateButton.Create(0.40,0.01,0.2,0.06));
end;



end.

