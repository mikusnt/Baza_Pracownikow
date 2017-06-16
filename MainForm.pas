unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.Mask,
  Vcl.Menus, Vcl.ComCtrls, TPulseLab, Vcl.ExtCtrls, savephoto;

const
  surnamel = 20;
  forenamel = 20;
  smallheight = 350;
  bigheight = 450;
  ENGdllname = 'LangENG.dll';
  POLdllname = 'LangPOL.dll';
  maindllname = 'MainLibrary.dll';
  restartname = 'restart.temp';
  appname = 'Baza_Pracowników.exe';
  highsigns = ['A'..'Z'];
  lowsigns = ['a'..'z'];

type
  surnames = string[surnamel];
  forenames = string[forenamel];
  langline = string[25];
  mbline = string[100];
  plist = ^list;
  list = record
    surname : surnames;
    forename : forenames;
    pay : integer;
    date : TDateTime;
    id : integer;
    next : plist;
  end;
  sortarray = array[0..1] of byte;
  filterarray = array[0..3] of byte;
{
    sortarray[0] - sortowanie wysokiego priorytetu
    sortarray[1] - sortowanie niskiego priorytetu
}

  TForm1 = class(TForm)
    BOptions: TButton;
    BClose: TButton;
    BDelete: TButton;
    BEdit: TButton;
    StringGrid1: TStringGrid;
    ESurname: TEdit;
    GroupNew: TGroupBox;
    EForename: TEdit;
    EPay: TEdit;
    MDate: TMaskEdit;
    BAdd: TButton;
    BSave: TButton;
    BFilter: TButton;
    LRecCount: TPulseLabel;
    BFind: TButton;

    {  Zdarzenia ogólne, przycisków formy  }

    procedure BAddClick(Sender: TObject);
    procedure BEditClick(Sender: TObject);
    procedure BDeleteClick(Sender: TObject);
    procedure BFilterClick(Sender: TObject);
    procedure BFindClick(Sender: TObject);
    procedure BSaveClick(Sender: TObject);
    procedure BOptionsClick(Sender: TObject);
    procedure BCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    {  Zdarzenia StringGrida  }

    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1FixedCellClick(Sender: TObject; ACol, ARow: Integer);

    {  Zdarzenia skrótów klawiszowych formy ogólnej  }

    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ESurnameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    {  Zdarzenia korekcji tekstu formy głównej  }

    procedure ESurnameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EForenameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    {  Zdarzenia menu wyszukiwania  }

    procedure BdownfindClick(Sender: TObject);
    procedure BupfindClick(Sender: TObject);
    procedure CfindsortClick(Sender: TObject);
    procedure EfindOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    {  Zdarzenia menu filtrowania  }

    procedure FilterFieldsEdit(Sender : TObject);
    procedure LfsurnameClick(Sender: TObject);
    procedure LfforenameClick(Sender: TObject);
    procedure LfpayClick(Sender: TObject);
    procedure LfdateClick(Sender: TObject);
    procedure MenuItemClick(Sender: TObject);
    procedure LreccountClick(Sender: TObject);
    procedure PulseLab1Click(Sender: TObject);

  private
    { Private declarations }
  public

  end;

var
  Form1: TForm1;
  first : plist;
  sortid : sortarray;
  sortorder : boolean;
  langid : byte;
  editactive : bool;
  recqcount : integer;
  recsgcount : integer;
  maxrecqid : integer;
  optionsactive : boolean;
  statactive : boolean;

  {  Stringi przechowujące frazy językowe  }

  SGS : array[0..3] of string; {StringGrid Strings}
  BS : array[0..4, 0..1] of string; {Buttons Strings}
  MBS : array[0..6, 0..1] of string; {MessageBox Strings}
  CS : string; {Counter String}

  {  Dynamiczne przyciski menu wyszukiwania, zmienne wyszukiwania }

  Groupfind : TGroupBox;
  Lfind : TLabel;
  Cfindsort : TComboBox;
  Efind : TEdit;
  Bdownfind, Bupfind : TButton;

  findactive : boolean;
  findedid : integer;

  {  Dynamiczne przyciski menu filtrowania, zmienne filtrowania }

  GroupFilter : TGroupBox;
  LFSurname, LFForename, LFPay, LFDate : TLabel;
  PMFMenu0, PMFMenu1, PMFMenu2 : TPopupMenu;
  EFSurname0, EFForename0, EFPay0, EFPay1 : TEdit;
  DFDate0, DFDate1 : TDateTimePicker;

  filterclicked : byte;
  filterid : filterarray;
  filteractive : boolean;

  {  Funkcje biblioteki dll }

  function DateToStr(date : TDateTime) : string; stdcall external maindllname;
  function StrToDate(datestr : string) : TDateTime; stdcall external maindllname;
  function TextControl(var text : string; issurname : boolean; upsigns : boolean; var cursorpos : integer) : boolean; stdcall external maindllname;
  function IsKeyPressed(sign : Widechar) : boolean; stdcall external maindllname;

  procedure AddRecQ(var first : plist; newrec : list); stdcall external maindllname;
  function ReadRecQ(first : plist; id : integer) : list; stdcall external maindllname;
  procedure DeleteRecQ(var first : plist; id : integer); stdcall external maindllname;
  procedure EditRecQ(first : plist; editrec : list); stdcall external maindllname;
  procedure SaveRecQToFile(first : plist); stdcall external maindllname;
  procedure ReadRecQFromFile(out first : plist; out recqcount : integer; out maxid : integer);  stdcall external maindllname;
  procedure SaveOptionsToFile(sortid : sortarray; sortorder : boolean; lang : byte);
    stdcall external maindllname;
  procedure ReadOptionsFromFile(out sortid : sortarray; out sortorder : boolean; out lang : byte);
    stdcall external maindllname;

  {  Funkcje/procedury ogólne  }

  procedure AddButtonsCaption();
  procedure AddRecCount();
  function CmpIntStr(string0, string1 : string) : integer;
  procedure EditDeleteVisible();
  function FieldsCorrect() : boolean;
  function FilterAllConditions(row : list) : boolean;
  function FilterCondition(longstr, shortstr0, shortstr1 : string; filterid : byte) : boolean;
  procedure FindClick(button : boolean);
  function ReadRecFromFields() : list;
  procedure SaveFiles();
  procedure SaveRecToFields(rec : list);
  procedure ShowInt(value : integer);
  function SortCondition(rec0, rec1 : list; kind : boolean) : boolean;

  {  Funkcje/procedury obsługujące języki  }

  procedure ChangeForm1Lang(lang : byte);
  procedure ChangeMBForm1Lang(lang : byte);
  function LangIdToName(langid : byte) : string;
  procedure NoLibrary(name : string);

  {  Funkcje/procedury podstawowej obsługi StringGrida  }

  procedure CleanFields();
  procedure CleanSG();
  procedure ColumnSG();
  function FindSGStr(findstr : string; startid, sortid : integer; direction : boolean) : integer;
  function TestCondition(findstr : string; startid, sortid : integer; i : integer) : boolean;


  {  We/Wy danych StringGrida  }

  procedure AddAllRecSG(filteractive : boolean);
  procedure AddRecSG(newrec : list);
  procedure ChangeRecPosSG(startid : integer; itemscount : integer; direction : bool);
  procedure DeleteRecSG(id : integer; out recqid : integer);
  procedure EditRecSG(rec : list; id : integer);
  function ReadRecSG(id : integer) : list;
  procedure SaveRecSG(rec : list; id : integer);
  procedure SortSG();

  {***  Definicje zdarzeń formy  ***}

  {  Funkcje tworzenia/usuwania dynamicznych komponentów  }

  procedure AddItemToMenu(var menu : TPopupMenu; id : byte; itemcaption : string);
  procedure CreateArrowButtonInFind(var buttonname : TButton; leftposition : word; arrowsign : boolean);
  procedure CreateLabelInFilter(var lname : TLabel; leftposition : word);
  procedure CreateEditInFilter(var EName : TEdit; leftposition, topposition : word; isenabled : boolean);
  procedure CreateDTPInFilter(var DTPName : TDateTimePicker; topposition : word; isenabled : boolean);
  procedure CreateGroupBox(var GName : TGroupBox; leftposition, topposition, widthsize, heightsize : word; textcaption : string);
  procedure DestroyItemsInMenu(menu : TPopupMenu);
  function FindCreate(langid : byte) : boolean;
  function FindDestroy() : boolean;
  function FilterCreate() : boolean;
  function FilterDestroy() : boolean;

implementation

{$R *.dfm}

uses OptionsForm, StatForm;

{

    Funkcje/procedury ogólne

}

procedure AddButtonsCaption();
{Edycja przycisków, etykiety groupboxa podczas zmiany trybu (dodawanie i edycja rekordu)}
var
  editcount, filtercount, findcount : byte;
begin
  with Form1 do
  begin
    if editactive = False then editcount:=0
      else editcount:=1;
    if filteractive = False then filtercount:=0
      else filtercount:=1;
    if findactive = False then findcount:=0
      else findcount:=1;
    Groupnew.Caption:=BS[0][editcount];
    Badd.Caption:=BS[1][editcount];
    Bedit.Caption:=BS[2][editcount];
    Bfilter.Caption:=BS[3][filtercount];
    BFind.Caption:=BS[4][findcount];
  end;
end;

procedure AddRecCount();
begin
  with Form1 do
  begin
    if first <> nil then
      Lreccount.NoLinkText:=CS+' '+IntToStr(recsgcount)
    else Lreccount.NoLinkText:=CS+' 0';
  end;
end;

function CmpIntStr(string0, string1 : string) : integer;
begin
  if Length(String0) < Length(String1) then Result:=-1
  else if Length(String0) > Length(String1) then Result:=1
  else Result:=CompareStr(string0, string1);
end;

procedure EditDeleteVisible();
{Aktywuje/dezaktywuje przycisk Dodaj i Edytuj}
begin
  with Form1 do
  begin
    if (StringGrid1.Row >= 1) And (first <> nil) then
    begin
      Bedit.Enabled:=True;
      Bdelete.Enabled:=True;
    end else
    begin
      Bedit.Enabled:=False;
      Bdelete.Enabled:=False;
    end;
  end;
end;

function FieldsCorrect() : boolean;
{Sprawdza czy pola nowego rekordu są dobrze usupełnione}
begin
  with Form1 do
  begin
    try
      StrToDate(Mdate.Text);
      StrToInt(Epay.Text);
    except
      Result:=False;
      exit;
    end;
    if (Esurname.Text<>'') AND (Eforename.Text<>'') then Result:=True
      else Result:=False;
  end;
end;

function FilterAllConditions(row : list) : boolean;
begin
  if FilterCondition(String(row.surname), Efsurname0.Text, '', filterid[0]) AND
      FilterCondition(String(row.forename), Efforename0.Text, '', filterid[1]) AND
      FilterCondition(IntToStr(row.pay), Efpay0.Text, Efpay1.Text, filterid[2]) AND
      FilterCondition(DateToStr(row.date), DateToStr(Dfdate0.Date), DateToStr(Dfdate1.Date), filterid[3]+1)
      then Result:=True
      else Result:=False;

end;

function FilterCondition(longstr, shortstr0, shortstr1 : string; filterid : byte) : boolean;
var
  llongstr, lshortstr0, lshortstr1 : string;
begin
  if shortstr0='' then
  begin
    Result:=True;
    exit;
  end;
  llongstr:=AnsiLowerCase(longstr);
  lshortstr0:=AnsiLowerCase(shortstr0);
  lshortstr1:=AnsiLowerCase(shortstr1);
  Result:=False;
  case filterid of
  0: if CompareStr(Copy(llongstr, 1, Length(lshortstr0)), lshortstr0) = 0 then Result:=True;
  1: if CompareStr(llongstr, lshortstr0) = 0 then Result:=True;
  2: if CmpIntStr(llongstr, lshortstr0) > 0 then Result:=True;
  3: if CmpIntStr(llongstr, lshortstr0) >= 0 then Result:=True;
  4: if CmpIntStr(llongstr, lshortstr0) < 0 then Result:=True;
  5: if CmpIntStr(llongstr, lshortstr0) <= 0 then Result:=True;
  6: if (CmpIntStr(llongstr, lshortstr0) >= 0) AND ((lshortstr1 = '') OR (CmpIntStr(llongstr, lshortstr1) <= 0)) then Result:=True;
  end;
end;

procedure FindClick(button : boolean);
{Zdarzenie zastępcze odpowiedzialne za przyciśnięcie klawiszy wyszukiwania
button:
False  - kliknięcie w przycisk wyszukiwania w dół
True  - kliknięcie w przycisk wyszukiwania w górę  }
var
  startid : integer;
begin
  with Form1 do
  begin
    if findedid > 0 then
    begin
      if button then startid:=findedid-1
      else startid:=findedid+1
    end
    else startid:=0;
    if Efind.Text <> '' then
    begin
      Efind.Text:=Trim(Efind.Text);
      findedid:=FindSGStr(Efind.Text, startid, Cfindsort.ItemIndex, button);
      if findedid > -1 then StringGrid1.Row:=findedid+1
      else findedid:=StringGrid1.Row-1;
    end
    else Application.MessageBox(PChar(MBS[2][0]), PChar(MBS[2][1]), MB_OK OR MB_ICONWARNING);
  end;
end;

function ReadRecFromFields() : list;
{Wygenerowanie rekordu z pól nowego rekordu}
var
  temprow : list;
begin
  with Form1 do
  begin
    temprow.surname:=Trim(Esurname.Text);
    temprow.forename:=Trim(Eforename.Text);
    temprow.pay:=StrToInt(Epay.Text);
    temprow.date:=StrToDate(Mdate.Text);
    temprow.id:=maxrecqid+1;
  end;
  Result:=temprow;
end;

procedure SaveFiles();
{Zapis plików przechowujących rekordy i ustawienia}
begin
    SaveRecQToFile(first);
    SaveOptionsToFile(sortid, sortorder, langid);
end;

procedure SaveRecToFields(rec : list);
{Załadowanie rekordu do pól nowego rekordu}
begin
  with Form1 do
  begin
    Esurname.Text:=String(rec.surname);
    Eforename.Text:=String(rec.forename);
    Epay.Text:=IntToStr(rec.pay);
    Mdate.Text:=DateToStr(rec.date);
  end;
end;

procedure ShowInt(value : integer);
{Wyświetla porządany integer}
begin
  ShowMessage(IntToStr(value));
end;

function SortCondition(rec0, rec1 : list; kind : boolean) : boolean;
{Generuje wartości logiczne potrzebne do wstawiania noweych rekordów / funkcja sortujące}
var
  if00sort, if01sort, if10sort, if11sort : string;
  tempfunction0, tempfunction1 : function (S1, S2 : string) : integer;
begin
  @tempfunction0:=@CompareStr;;
  case sortid[0] of
    0: begin if00sort:=rec0.surname; if01sort:=rec1.surname; end;
    1: begin if00sort:=rec0.forename; if01sort:=rec1.forename; end;
    2: begin if00sort:=IntToStr(rec0.pay); if01sort:=IntToStr(rec1.pay); @tempfunction0:=@CmpIntStr; end;
    3: begin if00sort:=DateToStr(rec0.date); if01sort:=DateToStr(rec1.date);  end;
  end;
  @tempfunction1:=@CompareStr;
  case sortid[1] of
    0: begin if10sort:=rec0.surname; if11sort:=rec1.surname; end;
    1: begin if10sort:=rec0.forename; if11sort:=rec1.forename; end;
    2: begin if10sort:=IntToStr(rec0.pay); if11sort:=IntToStr(rec1.pay); @tempfunction1:=@CmpIntStr; end;
    3: begin if10sort:=DateToStr(rec0.date); if11sort:=DateToStr(rec1.date);  end;
  end;
  if kind = False then
  begin
    Result:=(tempfunction0(if00sort, if01sort) > 0) OR ((tempfunction0(if00sort, if01sort) = 0) AND (tempfunction1(if10sort, if11sort)> 0));
    if sortorder=True then Result:=not Result;
  end
  else begin
    Result:=(tempfunction0(if00sort, if01sort) < 0) OR ((tempfunction0(if00sort, if01sort) = 0) AND (tempfunction1(if10sort, if11sort) < 0));
    if sortorder=True then Result:=not Result;
  end;
end;

{

    Funkcje/procedury podstawowej obsługujące języki

}

function LangIdToName(langid : byte) : string;
begin
  case langid of
  0: Result:=ENGdllname;
  1: Result:=POLdllname;
  else Result:=ENGdllname;
  end;
end;

procedure ChangeForm1Lang(lang : byte);
var
  DLL : HModule;
  tempf : function (index : byte) : langline; stdcall;
  dllname : string;
  i : byte;
begin
  with Form1 do
  begin
    dllname:=LangIdToName(lang);
    DLL:=LoadLibrary(PChar(dllname));
    if DLL <> 0 then
    try
      @tempf := GetProcAddress(DLL, 'Form1Lang');
      Bdelete.Caption:=String(tempf(5));
      Bsave.Caption:=tempf(6);
      Boptions.Caption:=tempf(7);
      Bclose.Caption:=tempf(8);

      for i := 0 to 4 do
        BS[i][0]:=tempf(i);
      for i := 0 to 4 do
        BS[i][1]:=tempf(9+i);
      CS:=tempf(14);
      LRecCount.LinkText:=tempf(15);
      for i := 0 to 3 do
        SGS[i]:=tempf(16+i);
    finally
      FreeLibrary(DLL);
    end
    else NoLibrary(dllname);
  end;
end;

procedure ChangeMBForm1Lang(lang : byte);
var
  DLL : HModule;
  tempf : function (indexr, indexc : byte) : mbline; stdcall;
  dllname : string;
  i, ii : byte;
begin
  with Form1 do
  begin
    dllname:=LangIdToName(lang);
    DLL:=LoadLibrary(PChar(dllname));
    if DLL <> 0 then
    try
      @tempf := GetProcAddress(DLL, 'MBForm1Lang');
      for i := 0 to 4 do
        for ii := 0 to 1 do
          MBS[i][ii]:=tempf(i, ii);
      Caption:=tempf(5, 0);
    finally
      FreeLibrary(DLL);
    end
    else NoLibrary(dllname);
  end;
end;

procedure NoLibrary(name : string);
begin
  Application.MessageBox(PChar('Not found library ' + name + ', please contact with administrator. Program will be closed.'), 'Error of loading library', MB_OK OR MB_ICONWARNING);
  Application.Terminate;
end;

{

    Funkcje/procedury podstawowej obsługi StringGrida

}

procedure CleanFields();
{Oczyszcza pola tekstowe wprowadzania rekordu }
begin
  with Form1 do
  begin
    Esurname.Text:='';
    Eforename.Text:='';
    Epay.Text:='';
    Mdate.Text:='';
  end;
end;

procedure CleanSG();
{Oczyszcza całego StringGrida}
var
  i : integer;
begin
  with Form1 do
  begin
    for i := 1 to StringGrid1.RowCount-1 do
      StringGrid1.Rows[i].Clear;
    StringGrid1.RowCount:=2;
    recsgcount:=0;
  end;
end;

procedure ColumnSG();
{Wyświetla opis kolumn wraz z rodzajem sortowania}
var
  arrow : char;
begin
  with Form1 do
  begin
    if sortorder = False then arrow:=char($25B2)
    else arrow:=char($25BC);

    StringGrid1.Cells[0,0]:=SGS[0];
    StringGrid1.Cells[1,0]:=SGS[1];
    StringGrid1.Cells[2,0]:=SGS[2];
    StringGrid1.Cells[3,0]:=SGS[3];

    StringGrid1.Cells[sortid[0],0]:=SGS[sortid[0]]+arrow;
    if arrow = char($25B2) then arrow:=char($25B3)
    else arrow:=char($25BD);
    StringGrid1.Cells[sortid[1],0]:=SGS[sortid[1]]+arrow;
  end;
end;

function FindSGStr(findstr : string; startid, sortid : integer; direction : boolean) : integer;
{Wyszukiwanie ciągu znaków w StringGridzie
direction = False  - przeszukiwanie w dół
direction = True  - przeszukiwanie w górę}
var
  i : integer;
begin
  i:=startid;
  //findstr:=LowerCase(findstr);
  with Form1 do
  begin
    if direction then
    begin
      while i >= 0 do
      begin
        if  TestCondition(findstr, startid, sortid, i) then
        begin
          Result:=i;
          exit;
        end;
        Dec(i);
      end;
    end else
    begin
      while i <= StringGrid1.RowCount-2 do
      begin
        if TestCondition(findstr, startid, sortid, i) then
        begin
          //Application.MessageBox('Znaleziono pasujący rekord.', 'Wyszukiwanie', MB_OK OR MB_ICONINFORMATION);
          Result:=i;
          exit;
        end;
        Inc(i);
      end;
    end;
    Application.MessageBox(PChar(MBS[3][0]), PChar(MBS[3][1]), MB_OK OR MB_ICONINFORMATION);
    Result:=-1;
  end;
end;

function TestCondition(findstr : string; startid, sortid : integer; i : integer) : boolean;
begin
  with Form1 do
  begin
    Result:=False;
    case sortid of
    0..3: if (Pos(findstr, AnsiLowercase(StringGrid1.Cells[sortid, i+1])) > 0) then Result:=True;
    4: if (Pos(findstr, AnsiLowerCase(StringGrid1.Cells[0, i+1])) > 0) OR
        (Pos(findstr, AnsiLowerCase(StringGrid1.Cells[1, i+1])) > 0) OR
        (Pos(findstr, AnsiLowerCase(StringGrid1.Cells[2, i+1])) > 0) OR
        (Pos(findstr, AnsiLowerCase(StringGrid1.Cells[3, i+1])) > 0) then Result:=True;
    5: if (Pos(findstr, StringGrid1.Cells[4, i+1]) > 0) then Result:=True;
    end;
  end;
end;

{

    We/Wy danych strigrGrida

}

procedure AddAllRecSG(filteractive : boolean);
{Dodaje rekordy z listy do StringGrida
filter:
  False: wszystkie rekordy
  True: rekordy spełniające kryteria filtrów}
var
  prev : plist;
begin
  prev:=first;
  recsgcount:=0;
  //for i := 0 to recqcount-1 do
  while prev <> nil do
  begin
    if (not filteractive) OR (filteractive AND FilterAllConditions(prev^)) then
      AddRecSG(prev^);
    prev:=prev^.next;
  end;
end;

procedure AddRecSG(newrec : list);
{Dodaje wybrany rekord do StringGrida}
var
  i : integer;
begin
  with Form1 do
  begin
    if StringGrid1.Cells[0,1]= '' then begin SaveRecSG(newrec, 0); end
    else begin
      if SortCondition(ReadRecSG(0), newrec, False) then
      begin
        ChangeRecPosSG(0, recsgcount, False);
        SaveRecSG(newrec, 0);
      end
      else begin
        i:=0;
        while (i < recsgcount) AND SortCondition(ReadRecSG(i), newrec, True) do Inc(i);
        ChangeRecPosSG(i, recsgcount, False);
        SaveRecSG(newrec, i);
      end;
    end;
    Inc(recsgcount);
  end;
  AddRecCount();
end;

procedure ChangeRecPosSG(startid : integer; itemscount : integer; direction : bool);
{Przesuwa zawartość StringGrida o jedno miejsce
direction:
  False  - przesuwanie w dół/dodawanie
  direction = True  - przesuwanie w górę/usuwanie}
var
  i : integer;
begin
  with Form1 do
  begin
    if direction=False then
      begin
        for i := StringGrid1.RowCount downto  startid+2 do
          StringGrid1.Rows[i]:=StringGrid1.Rows[i-1];
        if itemscount > 0 then Form1.StringGrid1.RowCount:=Form1.StringGrid1.RowCount+1;
      end
      else begin
        for i := startid+1 to  StringGrid1.RowCount-1 do StringGrid1.Rows[i]:=StringGrid1.Rows[i+1];
        StringGrid1.Rows[i].Clear;
        if itemscount > 1 then Form1.StringGrid1.RowCount:=Form1.StringGrid1.RowCount-1;
      end;
  end;
end;

procedure DeleteRecSG(id : integer; out recqid : integer);
{Usuwa wybrany rekord ze StringGrida}
begin
  with Form1 do
  begin
    recqid:=StrToInt(StringGrid1.Cells[4,id+1]);
    ChangeRecPosSG(id, recsgcount, True);
    Dec(recsgcount);
  end;
  AddRecCount();
end;

procedure EditRecSG(rec : list; id : integer);
{Edytuje wybrany rekord ze StrngGrida}
var
  temprelation : integer;
begin
  DeleteRecSG(id, temprelation);
  AddRecSG(rec);
end;

function ReadRecSG(id : integer) : list;
{Odczytuje wybrany rekord ze StringGrida}
var
  temprow : list;
begin
  with Form1 do
  begin
    temprow.surname:=StringGrid1.Cells[0, id+1];
    temprow.forename:=StringGrid1.Cells[1, id+1];
    temprow.pay:=StrToInt(StringGrid1.Cells[2, id+1]);
    temprow.date:=StrToDate(StringGrid1.Cells[3, id+1]);
    temprow.id:=StrToInt(StringGrid1.Cells[4, id+1]);
  end;
  Result:=temprow;
end;

procedure SaveRecSG(rec : list; id : integer);
{Zapisuje wybrany rekord do StringGrida}
begin
  with Form1 do
  begin
    StringGrid1.Cells[0, id+1]:=rec.surname;
    StringGrid1.Cells[1, id+1]:=rec.forename;
    StringGrid1.Cells[2, id+1]:=IntToStr(rec.pay);
    StringGrid1.Cells[3, id+1]:=DateToStr(rec.date);
    StringGrid1.Cells[4, id+1]:=IntToStr(rec.id);
  end;
end;

procedure SortSG();
{Sortuje całego StringGrida}
begin
  CleanSG();
  AddAllRecSG(filteractive);
end;

{

    Zdarzenia ogólne formy, przycisków

}

procedure TForm1.BAddClick(Sender: TObject);
var
  temprec : list;
  temprow : word;
begin
  if FieldsCorrect() then
  begin
    {if filteractive then
    begin
      Application.MessageBox(Pchar(MBS[4][0]), Pchar(MBS[4][1]), MB_OK OR MB_ICONINFORMATION);
      FilterDestroy();
      Height:=smallheight;
      filteractive:=False;
      CleanSG();
      AddAllRecSG(filteractive);
    end;

    if findactive then
    begin
      Application.MessageBox(PChar(MBS[5][0]), Pchar(MBS[5][1]), MB_OK OR MB_ICONINFORMATION);
      FindDestroy();
      Height:=smallheight;
      findactive:=False;
      findedid:=0;
    end;}

    temprec:=ReadRecFromFields();
    temprow:=0;
    if editactive = False then
    begin
      AddRecQ(first, temprec);
      AddRecSG(temprec);
      Inc(recqcount);
      Inc(maxrecqid);
    end
    else begin
      temprow:=Form1.StringGrid1.Row;
      temprec.id:=StrToInt(Form1.StringGrid1.Cells[4, temprow]);
      EditRecQ(first, temprec);
      EditRecSG(temprec, temprow-1);
    end;

    if temprow <> 0 then Form1.StringGrid1.Row:=temprow
    else Form1.StringGrid1.Row:=1;
    EditDeleteVisible();
    editactive:=False;
    AddButtonsCaption();
    CleanFields();
  end
  else begin
    if Application.MessageBox(Pchar(MBS[0][0]), Pchar(MBS[0][1]), MB_YESNO OR MB_ICONWARNING) = IDYES then
      CleanFields();
  end;
end;

procedure TForm1.BEditClick(Sender: TObject);
begin
  editactive:=not editactive;
  CleanFields();
  AddButtonsCaption();
  StringGrid1Click(Sender);

end;

procedure TForm1.BDeleteClick(Sender: TObject);
var
  recqrelation : integer;
begin
  if Application.MessageBox(Pchar(MBS[1][0]), Pchar(MBS[1][1]), MB_YESNO OR MB_ICONQUESTION OR MB_DEFBUTTON2) = IDYES then
  begin
    DeleteRecSG(StringGrid1.Row-1, recqrelation);
    DeleteRecQ(first, recqrelation);
    if first = nil then maxrecqid:=0;

    Dec(recqcount);
    if recqcount > 2 then Form1.StringGrid1.RowCount:=Form1.StringGrid1.RowCount-1;
    EditDeleteVisible();
  end;
end;

procedure TForm1.BFilterClick(Sender: TObject);
var
  relationid : string;
begin
  if findactive then
  begin
    FindDestroy();
    findactive:=False;
  end;

  if filteractive then
  begin
    relationid:=StringGrid1.Cells[4, StringGrid1.Row];
    FilterDestroy();
    filteractive:=False;
    Height:=smallheight;
    SortSG();
    if first  <> nil then StringGrid1.Row:=FindSGStr(relationid, 0, 5, False)+1;
  end else
  begin
    FilterCreate();
    filteractive:=True;
    Height:=bigheight;
  end;
end;

procedure TForm1.BFindClick(Sender: TObject);
begin
  if filteractive then
  begin
    FilterDestroy();
    filteractive:=False;
    SortSG();
  end;
  if not findactive then
  begin
    FindCreate(langid);
    Height:=bigheight;
  end else
  begin
    FindDestroy();
    Height:=smallheight;
  end;
  findactive:=not findactive;
end;

procedure TForm1.BSaveClick(Sender: TObject);
begin
  SaveFiles();
end;

procedure TForm1.BOptionsClick(Sender: TObject);
begin
  if not optionsactive then
  begin
    Application.CreateForm(TForm2, Form2);
    Form2.Visible:=true;
    optionsactive:=True;
  end;
end;

procedure TForm1.BCloseClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(MBS[4][0]), Pchar(MBS[4][1]), MB_YESNO OR MB_DEFBUTTON1 OR MB_ICONQUESTION) = IDNO then exit;
  close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  maxrecqid:=0;
  editactive:=False;
  filteractive:=False;
  recsgcount:=0;
  findedid:=-1;
  ReadOptionsFromFile(sortid, sortorder, langid);
  ReadRecQFromFile(first, recqcount, maxrecqid);
  ChangeForm1Lang(langid);
  ChangeMBForm1Lang(langid);
  ColumnSG();
  StringGrid1.ColWidths[4]:=-1;
  AddButtonsCaption();
  AddAllRecSG(filteractive);
  EditDeleteVisible();
  Bdownfind.Caption:=char($21E9);
  Bupfind.Caption:=char($21E7);
  Height:=smallheight;
  LRecCount.TimerEnabled:=True;
  ShowScrollBar(Stringgrid1.Handle, SB_VERT, True);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFiles();
end;

{

    Zdarzenia StringGrida

}

procedure TForm1.StringGrid1Click(Sender: TObject);
var
  temprec : list;
begin
    if editactive then
    begin
      temprec:=ReadRecSG(StringGrid1.Row-1);
      SaveRecToFields(temprec);
    end;
    findedid:=Form1.StringGrid1.Row-1;
end;

procedure TForm1.StringGrid1FixedCellClick(Sender: TObject; ACol,
  ARow: Integer);
begin
  if sortid[0] = ACol then sortorder:=not sortorder
  else sortid[0]:=ACol;

  if sortid[0] = sortid[1] then
  begin
    case sortid[1] of
      0: sortid[1]:=1;
      1..3: sortid[1]:=0;
    end;
  end;
  ColumnSG();
  SortSG();
end;

{

    Zdarzenia skrótów klawiszowych formy ogólnej

}

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then BCloseClick(Sender);
end;

procedure TForm1.ESurnameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then BAddClick(Sender);
  if Key = 27 then BcloseClick(Sender);
end;

procedure TForm1.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then BcloseClick(Sender);
  if (Key = 46) AND (Bdelete.Enabled) then BdeleteClick(Sender);
end;

{

    Zdarzenia korekcji tekstu formy głównej

}

procedure TForm1.ESurnameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  cursorpos : integer;
  newtext : string;
begin
  with Esurname do
  begin
    if IsKeyPressed(Chr(key))  then
    begin
      cursorpos:=SelStart;
      newtext:=Text;
      TextControl(newtext, True, True,  cursorpos);
      Text:=newtext;
      SelStart:=cursorpos;
    end;
  end;
end;

procedure TForm1.EForenameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  cursorpos : integer;
  newtext : string;
begin
  with Eforename do
  begin
    if IsKeyPressed(Chr(Key))  then
    begin
      cursorpos:=SelStart;
      newtext:=Text;
      TextControl(newtext, False, True, cursorpos);
      Text:=newtext;
      SelStart:=cursorpos;
    end;
  end;
end;

{

    Zdarzenia menu wyszukiwania

}

procedure TForm1.BdownfindClick(Sender: TObject);
begin
  FindClick(False);
end;

procedure TForm1.BupfindClick(Sender: TObject);
begin
  FindClick(True);
end;

procedure TForm1.CfindsortClick(Sender: TObject);
begin
  if Cfindsort.ItemIndex = 2 then
  begin
    Efind.NumbersOnly:=True;
    try
      StrToInt(Efind.Text);
    except
      Efind.Text:='';
    end;
  end
  else Efind.NumbersOnly:=False;
end;

procedure TForm1.EfindOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  cursorpos : integer;
begin
  if Cfindsort.ItemIndex in [0..1] then
  begin
    with Efind do
    begin
      if IsKeyPressed(Chr(key))  then
      begin
        cursorpos:=Selstart;
        Text:=AnsiLowerCase(Text);
        if Selstart < cursorpos then Selstart:=cursorpos;
      end;
    end;
  end;
end;

{

    Zdarzenia menu filtrowania

}

procedure TForm1.FilterFieldsEdit(Sender : TObject);
begin
  SortSG();
end;

procedure TForm1.LfsurnameClick(Sender: TObject);
var
  tempp : TPoint;
begin
  filterclicked:=0;
  PMfmenu0.Items[filterid[0]].Default:=True;
  if GetCursorPos(tempp) then
    PMfmenu0.Popup(tempp.X, tempp.Y);
end;

procedure TForm1.LreccountClick(Sender: TObject);
begin
  if not statactive then
  begin
    Application.CreateForm(TForm3, Form3);
    Form3.Visible:=true;
    statactive:=True;
  end;
end;


procedure TForm1.LfforenameClick(Sender: TObject);
var
  tempp : TPoint;
begin
  filterclicked:=1;
  PMfmenu0.Items[filterid[1]].Default:=True;
  if GetCursorPos(tempp) then
    PMfmenu0.Popup(tempp.X, tempp.Y);
end;

procedure TForm1.LfpayClick(Sender: TObject);
var
  tempp : TPoint;
begin
  filterclicked:=2;
  PMfmenu1.Items[filterid[2]].Default:=True;
   if GetCursorPos(tempp) then
      PMfmenu1.Popup(tempp.X, tempp.Y);
end;

procedure TForm1.LfdateClick(Sender: TObject);
var
  tempp : TPoint;
begin
  filterclicked:=3;
  PMfmenu2.Items[filterid[3]].Default:=True;
  if GetCursorPos(tempp) then
    PMfmenu2.Popup(tempp.X, tempp.Y);
end;

procedure TForm1.MenuItemClick(Sender: TObject);
var
  templabel : string;
begin
  filterid[filterclicked]:=TMenuItem(Sender).Tag;
  templabel:= TMenuItem(Sender).Caption;
  case filterclicked of
  0:  Lfsurname.Caption:=templabel;
  1:  Lfforename.Caption:=templabel;
  2:  begin
        Lfpay.Caption:=templabel;
        if filterid[2]=6 then Efpay1.Enabled:=True
          else Efpay1.Enabled:=False;
      end;
  3:  begin
        Lfdate.Caption:=templabel;
        if filterid[3]=5 then Dfdate1.Enabled:=True
          else Dfdate1.Enabled:=False;
      end;
  end;
  SortSG();
end;

procedure TForm1.PulseLab1Click(Sender: TObject);
begin

end;

{

    funkcje tworzenia/usuwania dynamicznych komponentów

}

procedure AddItemToMenu(var menu : TPopupMenu; id : byte; itemcaption : string);
var
  tempitem : TMenuItem;
begin
  tempitem:=TMenuItem.Create(menu);
  tempitem.Caption:=itemcaption;
  tempitem.Name:='item'+IntToStr(id);
  tempitem.Tag:=id;
  tempitem.OnClick:=Form1.MenuItemClick;
  menu.Items.Add(tempitem);
end;

procedure CreateArrowButtonInFind(var buttonname : TButton; leftposition : word; arrowsign : boolean);
var
  sign : char;
begin
  if not arrowsign then sign:=char($21E9)
  else sign:=char($21E7);

  buttonname:=TButton.Create(Groupfind);
  with buttonname do
  begin
    Height:=25;
    Width:=24;
    Left:=leftposition;
    Top:=48;
    Caption:=sign;
    Font.Size:=14;
    Font.Style:=[fsBold];
    Parent:=Groupfind;
    if arrowsign then OnClick:=Form1.BupfindClick
    else OnClick:=Form1.BdownfindClick;
    Visible:=True;
    Enabled:=True;
  end;
end;

procedure CreateLabelInFilter(var lname : TLabel; leftposition : word);
begin
  lname:=TLabel.Create(Groupfilter);
  with lname do
    begin
      Height:=13;
      Width:=31;
      Left:=leftposition;
      Top:=15;
      Font.Style:=[fsUnderline];
      Font.Color:=clBlue;
      Parent:=Groupfilter;
      Visible:=True;
      Enabled:=True;
    end;
end;

procedure CreateEditInFilter(var EName : TEdit; leftposition, topposition : word; isenabled : boolean);
begin
  ename:=TEdit.Create(Groupfilter);
  with EName do
    begin
      Height:=21;
      Width:=129;
      Left:=leftposition;
      Top:=topposition;
      Text:='';
      Parent:=Groupfilter;
      Visible:=True;
      Enabled:=isenabled;
      OnChange:=Form1.FilterFieldsEdit;
    end;
end;

procedure CreateDTPInFilter(var DTPName : TDateTimePicker; topposition : word; isenabled : boolean);
begin
  DTPName:=TDateTimePicker.Create(Groupfilter);
  with DTPName do
  begin
    Height:=21;
    Width:=129;
    Left:=412;
    Top:=topposition;
    Parent:=Groupfilter;
    Visible:=True;
    Enabled:=isenabled;
    OnChange:=Form1.FilterFieldsEdit;
  end;
end;

procedure CreateGroupBox(var GName : TGroupBox; leftposition, topposition, widthsize, heightsize : word; textcaption : string);
begin
  gname:=TGroupBox.Create(Form1);
  with gname do
  begin
    Height:=heightsize;
    Width:=widthsize;
    Left:=leftposition;
    Top:=topposition;

    Parent:=Form1;
    Caption:=textcaption;
    Visible:=True;
    Enabled:=True;
    TabOrder:=9;
  end;
end;

procedure DestroyItemsInMenu(menu : TPopupMenu);
begin
  while menu.Items.Count>0 do
  menu.Items[0].Free;
end;

function FindCreate(langid : byte) : Boolean;
var
  DLL : HModule;
  tempf : function (index : byte) : langline; stdcall;
  i : byte;
  dllname : string;
begin
  if Groupfind = nil then
  begin
    Form1.BFind.Caption:=BS[4][1];
    CreateGroupBox(Groupfind, 176, 310, 203, 88, '');
    Lfind:=TLabel.Create(Groupfind);
    with Lfind do
    begin
      Height:=13;
      Width:=54;
      Left:=7;
      Top:=24;
      Parent:=Groupfind;
      Visible:=True;
      Enabled:=True;
    end;
    Cfindsort:=TComboBox.Create(Groupfind);

    with Cfindsort do
    begin
      Height:=21;
      Width:=113;
      Left:=83;
      Top:=21;
      Style:=csDropDownList;
      Parent:=Groupfind;
      Visible:=True;
      Enabled:=True;
      OnClick:=Form1.CfindsortClick;
    end;

    Efind:=TEdit.Create(Groupfind);
    with Efind do
    begin
      Height:=21;
      Width:=129;
      Left:=7;
      Top:=50;
      Text:='';
      Parent:=Groupfind;
      Visible:=True;
      Enabled:=True;
      OnKeyUp:=Form1.EfindOnKeyUp;
    end;

    CreateArrowButtonInFind(Bdownfind, 142, False);
    CreateArrowButtonInFind(Bupfind, 172, True);
    with Form1 do
    begin
      dllname:=LangIdToName(langid);
      DLL:=LoadLibrary(PChar(dllname));
      if DLL <> 0 then
      try
        @tempf := GetProcAddress(DLL, 'FindLang');
        Groupfind.Caption:=tempf(0);
        Lfind.Caption:=tempf(1);

        for i := 2 to 6 do
          Cfindsort.Items.Add(tempf(i));
        Cfindsort.ItemIndex:=0;
      finally
        FreeLibrary(DLL);
      end else NoLibrary(dllname);
    end;
    Result:=True;
  end
  else Result:=False;
end;

function FindDestroy() : boolean;
begin
  if Groupfind <> nil then
  begin
    Result:=True;
    try
    Form1.BFind.Caption:=BS[4][0];
    Efind.Free;
    Cfindsort.Free;
    Lfind.Free;
    Bdownfind.Free;
    Bupfind.Free;

    Groupfind.Free;
    Groupfind:=nil;
    except
      Result:=False;
    end;
  end;
end;

function FilterCreate() : boolean;
var
  DLL : HModule;
  tempf : function (index : byte) : langline; stdcall;
  i : byte;
  dllname : string;
begin
  if Groupfilter = nil then
  begin
    Form1.Bfilter.Caption:=BS[3][1];
    CreateGroupBox(Groupfilter, 8, 310, 569, 95, '');

    CreateLabelInFilter(Lfsurname, 7);
    Lfsurname.OnClick:=Form1.LfsurnameClick;
    CreateLabelInFilter(Lfforename, 143);
    Lfforename.OnClick:=Form1.LfforenameClick;
    CreateLabelInFilter(Lfpay, 278);
    Lfpay.OnClick:=Form1.LfpayClick;
    CreateLabelInFilter(Lfdate, 413);
    Lfdate.OnClick:=Form1.LfdateClick;
    filterid[0]:=0;
    filterid[1]:=0;
    filterid[2]:=0;
    filterid[3]:=5;
    CreateEditInFilter(Efsurname0, 7, 30, True);
    CreateEditInFilter(Efforename0, 142, 30, True);
    CreateEditInFilter(Efpay0, 277, 30, True);
    Efpay0.NumbersOnly:=True;
    CreateEditInFilter(Efpay1, 277, 57, False);
    Efpay1.NumbersOnly:=True;
    CreateDTPInFilter(Dfdate0, 30, True);
    Dfdate0.OnChange:=Form1.FilterFieldsEdit;
    Dfdate0.Date:=StrToDate('1899-01-01');
    CreateDTPInFilter(Dfdate1, 57, True);
    Dfdate1.OnChange:=Form1.FilterFieldsEdit;

    PMfmenu0:=TPopupMenu.Create(Groupfilter);
    PMfmenu1:=TPopupMenu.Create(Groupfilter);
    PMfmenu2:=TPopupMenu.Create(Groupfilter);

    with Form1 do
    begin
      dllname:=LangIdToName(langid);
      DLL:=LoadLibrary(PChar(dllname));
      if DLL <> 0 then
      try
        @tempf := GetProcAddress(DLL, 'FilterLang');
        Groupfilter.Caption:=tempf(0);

        Lfsurname.Caption:=tempf(1);
        Lfforename.Caption:=tempf(1);
        Lfpay.Caption:=tempf(1);
        Lfdate.Caption:=tempf(7);

        for i := 0 to 1 do
          AddItemToMenu(PMfmenu0, i, tempf(i+1));

        for i := 0 to 6 do
        begin
          AddItemToMenu(PMfmenu1, i, tempf(i+1));
          if i > 0 then AddItemToMenu(PMfmenu2, i-1, tempf(i+1));
        end;
        PMfmenu2.Items[5].Default:=True;


      finally
        FreeLibrary(DLL);
      end else NoLibrary(dllname);
    end;

    Result:=True;
  end
  else Result:=False;
end;


function FilterDestroy() : boolean;
begin
  if Groupfilter <> nil then
  begin
    Result:=True;
    try
    Form1.Bfilter.Caption:=BS[3][0];
    Lfsurname.Free;
    Lfforename.Free;
    Lfpay.Free;
    Lfdate.Free;
    Efsurname0.Free;
    Efforename0.Free;
    Efpay0.Free;
    Dfdate0.Free;
    Efpay1.Free;
    Dfdate1.Free;
    DestroyItemsInMenu(PMfmenu0);
    PMfmenu0.Free;
    DestroyItemsInMenu(PMfmenu1);
    PMfmenu1.Free;

    Groupfilter.Free;
    Groupfilter:=nil;

    except
      Result:=False;
    end;
  end;
end;

end.
