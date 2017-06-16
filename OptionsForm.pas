unit OptionsForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MainForm;

type
  TForm2 = class(TForm)
    Gsort: TGroupBox;
    Lmaxpriority: TLabel;
    Csort0: TComboBox;
    Lminpriority: TLabel;
    Csort1: TComboBox;
    Lorder: TLabel;
    Csort2: TComboBox;
    Bok: TButton;
    Llang: TLabel;
    Clang: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Csort0Click(Sender: TObject);
    procedure ClangClick(Sender: TObject);
    procedure BokClick(Sender: TObject);

  private

  public

  end;

var
  Form2 : TForm2;

   {  Stringi przechowujące frazy językowe  }

  MBS : array[0..1] of string;

  {  Funkcje biblioteki dll }

  function MyBoolToByte(value : boolean) : byte; stdcall external 'MainLibrary.dll';
  function MyIntToBool(value : integer) : boolean; stdcall external 'MainLibrary.dll';

  {  Funkcje/procedury obsługujące komponenty  }

  procedure SortMask();

  {  Funkcje/procedury obsługujące języki  }

  procedure ChangeForm2Lang(lang : byte);
  procedure ChangeMBForm2Lang(lang : byte);

  {***  Definicje zdarzeń formy  ***}

implementation

{$R *.dfm}

{

    Funkcje/procedury obsługujące komponenty

}

procedure SortMask();
begin
  with Form2 do
  begin
    if Csort1.ItemIndex = Csort0.ItemIndex then
    case Csort1.ItemIndex of
      0: Csort1.ItemIndex:=1;
      1..3: Csort1.ItemIndex:=0;
    end;
  end;
end;

{

    Funkcje/procedury obsługujące języki

}

procedure ChangeForm2Lang(lang : byte);
var
  DLL : HModule;
  tempf : function (index : byte) : langline; stdcall;
  i : byte;
  dllname : string;
begin
  with Form2 do
  begin
    dllname:=LangIdToName(lang);
    DLL:=LoadLibrary(PChar(dllname));
    if DLL <> 0 then
    try
      @tempf := GetProcAddress(DLL, 'Form2Lang');
      Gsort.Caption:=tempf(0);
      Lmaxpriority.Caption:=tempf(1);
      Lminpriority.Caption:=tempf(2);
      Lorder.Caption:=tempf(3);
      Llang.Caption:=tempf(4);

      Csort2.Items.Clear;
      Clang.Items.Clear;
      for i := 0 to 1 do
        begin
          Csort2.Items.Add(tempf(i+5));
          Clang.Items.Add(tempf(i+7));
        end;
      Caption:=tempf(9);
      //@tempf := GetProcAddress(DLL, 'Form1Lang');
      Csort0.Items.Clear;
      Csort1.Items.Clear;
      for i := 0 to 3 do
        begin
          Csort0.Items.Add(tempf(i+10));
          Csort1.Items.Add(tempf(i+10));
        end;

    finally
      FreeLibrary(DLL);
    end else NoLibrary(dllname);
  end;
end;

procedure ChangeMBForm2Lang(lang : byte);
var
  DLL : HModule;
  tempf : function (index : byte) : mbline; stdcall;
  dllname : string;
begin
  with Form2 do
  begin
    dllname:=LangIdToName(lang);
    DLL:=LoadLibrary(PChar(dllname));
    if DLL <> 0 then
    try
      @tempf := GetProcAddress(DLL, 'MBForm2Lang');
      MBS[0]:=tempf(0);
      MBS[1]:=tempf(1);

    finally
      FreeLibrary(DLL);
    end else NoLibrary(dllname);
  end;
end;
{

    Zdarzenia formy

}

procedure TForm2.FormCreate(Sender: TObject);
begin
{  wczytywanie wartości z formy głównej  }
  ChangeForm2Lang(MainForm.langid);
  ChangeMBForm2Lang(MainForm.langid);
  Csort0.ItemIndex:=MainForm.sortid[0];
  Csort1.ItemIndex:=MainForm.sortid[1];
  Csort2.ItemIndex:=MyBoolToByte(MainForm.sortorder);
  Clang.ItemIndex:=MainForm.langid;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ColumnSG();
  SortSG();
  MainForm.optionsactive:=False;
end;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) OR (key = 27) then close;
end;

procedure TForm2.Csort0Click(Sender: TObject);
begin
  SortMask();
  MainForm.sortid[0]:=Csort0.ItemIndex;
  MainForm.sortid[1]:=Csort1.ItemIndex;
  MainForm.sortorder:=MyIntToBool(Csort2.ItemIndex);
end;

procedure TForm2.ClangClick(Sender: TObject);
var
  file0: textfile;
begin
  if (Clang.ItemIndex <> MainForm.langid) then
  begin
    MainForm.langid:=Clang.ItemIndex;
    if Application.MessageBox(PChar(MBS[0]), PChar(MBS[1]), MB_YESNO OR MB_ICONQUESTION OR MB_DEFBUTTON1) = IDYES then
    begin
      AssignFile(file0, restartname);
      Rewrite(file0);
      CloseFile(file0);
      Form2.Close;
      Form1.Close;
      WinExec(appname, SW_SHOW);
    end;
  end;
end;

procedure TForm2.BokClick(Sender: TObject);
begin
  close;
end;

end.
