unit StatForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MainForm, Vcl.StdCtrls;

type
  charnumbers = array[0..34] of byte;
  TForm3 = class(TForm)
    GroupSurname: TGroupBox;
    LFSSurname: TLabel;
    ESurname: TEdit;
    LMostSurname: TLabel;
    GroupForename: TGroupBox;
    LMostForename: TLabel;
    LFSForename: TLabel;
    EForename: TEdit;
    GroupPay: TGroupBox;
    LMinPay: TLabel;
    LMaxPay: TLabel;
    LAveragePay: TLabel;
    GroupDate: TGroupBox;
    LFirstDate: TLabel;
    LLastDate: TLabel;
    BClose: TButton;
    LsurnameV: TLabel;
    LforenameV: TLabel;
    LMostSurnameV: TLabel;
    LMostForenameV: TLabel;
    LFirstDateV: TLabel;
    LLastDateV: TLabel;
    LMinPayV: TLabel;
    LMaxPayV: TLabel;
    LAveragePayV: TLabel;

    {  Zdarzenia ogólne formy  }

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BCloseClick(Sender: TObject);

    {  Zdarzenia korekcji tekstu  }

    procedure ESurnameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EForenameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    {  Zdarzenia aktywacji filtrowania  }

    procedure LsurnameVClick(Sender: TObject);
    procedure LforenameVClick(Sender: TObject);
    procedure LMinPayVClick(Sender: TObject);
    procedure LMaxPayVClick(Sender: TObject);
    procedure LFirstDateVClick(Sender: TObject);
    procedure LLastDateVClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  surnamen, forenamen : charnumbers;
  maxsurnamen, minsurnamen, maxforenamen, minforenamen : byte;

  {  Funkcje biblioteki dll }

  function FirstCharToInt(sign : WideChar) : byte; stdcall external maindllname;
  function FirstCharTab(first : plist; issurname : boolean) : charnumbers; stdcall external maindllname;
  function MostlyLetter(table : charnumbers) : string; stdcall external maindllname;
  procedure PayDateCalc(first : plist; out minpay : integer; out maxpay : integer; out averagepay : integer; out mindate : TDateTime; out maxdate : TDateTime); stdcall external maindllname;

  {  Funkcje/procedury ogólne  }

  procedure ChangeColorStyle(LName : TLabel; islink : boolean);
  procedure Form1FilterActive(Sender : TObject; isdate : boolean);

  {  Funkcje/procedury obs³uguj¹ce jêzyki  }

  procedure ChangeForm3Lang(lang : byte);

  {***  Definicje zdarzeñ formy  ***}

implementation

{$R *.dfm}

{

    Funkcje/procedury ogólne

}
procedure ChangeColorStyle(LName : TLabel; islink : boolean);
{Zmienia kolor i styl okreœlonej etykiety}
begin
  with LName do
  begin
    if islink then
    begin
      Font.Color:=clBlue;
      Font.Style:=[fsUnderline];
    end
    else begin
      Font.Color:=clWindowText;
      LName.Font.Style:=LName.Font.Style-[fsUnderline];
      Caption:='-';
    end;

  end;
end;

procedure Form1FilterActive(Sender : TObject; isdate : boolean);
{Aktywacja filtra formy g³ównej, jej inicjalizacja i za³adowanie okreœlonych kryteriów do pól}
begin
  Form1.Show;
  Form3.Left:=0;
  Form3.Top:=0;
  if not filteractive then Form1.BFilterClick(Sender);
  EFSurname0.Text:='';
  filterid[0]:=0;
  LFSurname.Caption:=PMFMenu0.Items[0].Caption;
  EFForename0.Text:='';
  filterid[1]:=0;
  LFForename.Caption:=PMFMenu0.Items[0].Caption;
  EFPay0.Text:='';
  EFPay1.Text:='';
  EFPay1.Enabled:=False;
  filterid[2]:=1;
  LFPay.Caption:=PMFMenu1.Items[1].Caption;
  DFDate0.Date:=StrToDate('1899-01-01');
  DFDate1.Date:=Now;
  if isdate then
  begin
    filterid[3]:=0;
    LFDate.Caption:=PMFMenu2.Items[0].Caption;
    DFDate1.Enabled:=False;
  end
  else begin
    LFDate.Caption:=PMFMenu2.Items[5].Caption;
    filterid[3]:=5;
    DFDate1.Enabled:=True;
  end;
end;

{

    Funkcje/procedury obs³uguj¹ce jêzyki

}

procedure ChangeForm3Lang(lang : byte);
{Wczytanie jêzyka formy z biblioteki}
var
  DLL : HModule;
  tempf : function (index : byte) : mbline; stdcall;
  dllname : string;
  i : byte;
begin
  with Form3 do
  begin
    dllname:=LangIdToName(lang);
    DLL:=LoadLibrary(PChar(dllname));
    if DLL <> 0 then
    try
      @tempf := GetProcAddress(DLL, 'Form3Lang');
      LFSSurname.Caption:=tempf(0);
      LFSForename.Caption:=tempf(0);
      LMostSurname.Caption:=tempf(1);
      LMostForename.Caption:=tempf(1);
      LMinPay.Caption:=tempf(2);
      LMaxPay.Caption:=tempf(3);
      LAveragePay.Caption:=tempf(4);
      LFirstDate.Caption:=tempf(5);
      LLastDate.Caption:=tempf(6);
      Caption:=tempf(7);
      GroupSurname.Caption:=tempf(8);
      GroupForename.Caption:=tempf(9);
      GroupPay.Caption:=tempf(10);
      GroupDate.Caption:=tempf(11);
    finally
      FreeLibrary(DLL);
    end
    else NoLibrary(dllname);
  end;
end;

{

    Zdarzenia ogólne formy

}

procedure TForm3.FormCreate(Sender: TObject);
var
  minpay, maxpay, averagepay : integer;
  mindate, maxdate : TDateTime;
begin
  ChangeForm3Lang(langid);
  if first <> nil then
  begin
    surnamen:=FirstCharTab(first, True);
    forenamen:=FirstCharTab(first, False);
    LSurnameV.Caption:=IntToStr(surnamen[0]);
    ChangeColorStyle(LSurnameV, True);
    LForenameV.Caption:=IntToStr(forenamen[0]);
    ChangeColorStyle(LForenameV, True);
    LMostSurnameV.Caption:=MostlyLetter(surnamen);
    LMostForenameV.Caption:=MostlyLetter(forenamen);

    PayDateCalc(first, minpay, maxpay, averagepay, mindate, maxdate);
    LMinPayV.Caption:=IntToStr(minpay);
    ChangeColorStyle(LMinPayV, True);
    LMaxPayV.Caption:=IntToStr(maxpay);
    ChangeColorStyle(LMaxPayV, True);
    LAveragePayV.Caption:=IntTOStr(averagepay);
    LFirstDateV.Caption:=DateToStr(mindate);
    ChangeColorStyle(LFirstDateV, True);
    LLastDateV.Caption:=DateToStr(maxdate);
    ChangeColorStyle(LLastDateV, True);
  end;
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  statactive:=False;
end;

procedure TForm3.BCloseClick(Sender: TObject);
begin
  close;
end;

{

    Zdarzenia korekcji tekstu

}

procedure TForm3.ESurnameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  cursorpos : integer;
  newtext : string;
begin
  with ESurname do
  begin
    if IsKeyPressed(Chr(key))  then
    begin
      cursorpos:=SelStart;
      newtext:=AnsiUpperCase(Text);
      TextControl(newtext, True, True,  cursorpos);
      Text:=newtext;
      SelStart:=cursorpos;
      if Length(Text) = 1 then
      begin
        LsurnameV.Caption:=IntToStr(surnamen[FirstCharToInt(Text[1])]);
        ChangeColorStyle(LsurnameV, True);
        LSurnameV.OnClick:=LSurnameVClick;
      end
      else begin
        ChangeColorStyle(LSurnameV, False);
        LSurnameV.OnClick:=nil;
      end;
    end;
  end;
end;

procedure TForm3.EForenameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  cursorpos : integer;
  newtext : string;
begin
  with EForename do
  begin
    if IsKeyPressed(Chr(key))  then
    begin
      cursorpos:=SelStart;
      newtext:=AnsiUpperCase(Text);
      TextControl(newtext, False, True,  cursorpos);
      Text:=newtext;
      SelStart:=cursorpos;
      if Length(Text) = 1 then
      begin
        LforenameV.Caption:=IntToStr(forenamen[FirstCharToInt(Text[1])]);
        ChangeColorStyle(LsurnameV, True);
        LSurnameV.OnClick:=LForenameVClick;
      end
      else begin
        ChangeColorStyle(LForenameV, False);
        LForenameV.OnClick:=nil;
      end;
    end;
  end;
end;

{

    Zdarzenia aktywacji filtrowania

}

procedure TForm3.LsurnameVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, False);
  EFSurname0.Text:=ESurname.Text;
end;

procedure TForm3.LforenameVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, False);
  EFForename0.Text:=EForename.Text;
end;

procedure TForm3.LMinPayVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, False);
  EFPay0.Text:=LMinPayV.Caption;
end;

procedure TForm3.LMaxPayVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, False);
  EFPay0.Text:=LMaxPayV.Caption;
end;

procedure TForm3.LFirstDateVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, True);
  DFDate0.Date:=StrToDate(LFirstDateV.Caption);
  SortSG();
end;

procedure TForm3.LLastDateVClick(Sender: TObject);
begin
  Form1FilterActive(Sender, True);
  DFDate0.Date:=StrToDate(LLastDateV.Caption);
  SortSG();
end;
end.
