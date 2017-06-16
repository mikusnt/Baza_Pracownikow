unit TPulseLab;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Vcl.ExtCtrls;

type
  TPulseLabel = class(TLabel)
  private
    endcolor, startcolor, addcolor, tempcolor, Lcolor : TColor;
    TTimer0 : TTimer;
    interval : word;
    countup, tenabled, lenabled : boolean;
    ltext, nltext : string;
    MyEvent : TNotifyEvent;
  protected
    { Protected declarations }
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure MyOnTimer(Sender : TObject);
    procedure MyOnMouseEnter(Sender : TObject);
    procedure MyOnMouseLeave(Sender : TObject);
    procedure SetTimerEnabled(timercount : boolean);
    procedure SetNoLinkText(newtext : string);
  published
    property FontColorStart : TColor read startcolor write startcolor;
    property FontColorEnd : TColor read endcolor write endcolor;
    property TimerInterval : word read interval write interval;
    property FontColorChange : TColor read addcolor write addcolor;
    property TimerEnabled : Boolean read Tenabled write SetTimerEnabled;
    property LinkEnabled : Boolean read Lenabled write Lenabled;
    property LinkText : string read Ltext write Ltext;
    property NoLinkText : string read NLtext write SetNoLinkText;
    property LinkColor : TColor read Lcolor write Lcolor;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPulseLabel]);
end;

constructor TPulseLabel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Font.Color:=0;
  startcolor:=0;
  endcolor:=$F0;
  addcolor:=$28;
  interval:=200;
  Lcolor:=clBlue;
  Tenabled:=False;
  Lenabled:=True;
  Ltext:='PulseLabel';
  NLtext:='PulseLabel';

  TTimer0:=TTimer.Create(self);
  TTimer0.Name:='TTimer0';
  TTimer0.Interval:=interval;
  TTimer0.Enabled:=tenabled;
  TTimer0.OnTimer:=MyOnTimer;

  OnMouseEnter:=MyOnMouseEnter;
  OnMouseLeave:=MyOnMouseLeave;
end;

destructor TPulseLabel.Destroy;
begin
  TTimer0.Free;
  inherited Destroy;
end;

procedure TPulseLabel.MyOnTimer(Sender : TObject);
begin
  if countup then
  begin
    if Font.Color < endcolor then Font.Color:= Font.Color+addcolor
    else countup:=False;
  end;
  if not countup then
  begin
    if Font.Color > startcolor then Font.Color:= Font.Color-addcolor
    else countup:=True;
  end;
end;

procedure TPulseLabel.MyOnMouseEnter(Sender : TObject);
begin
  if Lenabled then
  begin
    tempcolor:=Font.Color;
    TTimer0.Enabled:=False;
    Font.Color:=Lcolor;
    Font.Style:=Font.Style+[fsUnderline];
    Caption:=Ltext;
  end;
end;

procedure TPulseLabel.MyOnMouseLeave(Sender : TObject);
begin
  if Lenabled then
  begin
    Font.Color:=tempcolor;
    Font.Style:=Font.Style-[fsUnderline];
    TTimer0.Enabled:=enabled;
  end;
  Caption:=NLtext;
end;

procedure TPulseLabel.SetTimerEnabled(timercount:boolean);
begin
  Tenabled:=timercount;
  if tenabled then
  begin
    if startcolor < endcolor then countup:=True
      else countup:=False;
    Caption:=NLtext;
  end
  else Font.Color:=startcolor;
  TTimer0.Interval:=interval;
  TTimer0.Enabled:=Tenabled;
end;

procedure TPulseLabel.SetNoLinkText(newtext : string);
begin
  NLtext:=newtext;
  Caption:=NLtext;
end;

end.
