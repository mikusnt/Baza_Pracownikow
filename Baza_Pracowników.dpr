program Baza_Pracowników;

uses
  Vcl.Forms,
  Windows,
  SysUtils,
  MainForm in 'MainForm.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  OptionsForm in 'OptionsForm.pas' {Form2},
  StatForm in 'StatForm.pas' {Form3},
  TPulseLab in 'TPulseLab.pas',
  savephoto in 'savephoto.pas';

{$R *.res}
var
  DLL0, DLL1 : HModule;

begin
  CreateMutex(nil, FALSE, 'Baza_Pracowników.exe');
  if (GetLastError() <> 0) AND (not FileExists(restartname)) then Application.Terminate;
  DeleteFile(restartname);

  DLL0:=LoadLibrary(ENGdllname);
  DLL1:=LoadLibrary(POLdllname);

  if (DLL0 = 0) then NoLibrary(ENGdllname)
  else if (DLL1 = 0) then NoLIbrary(POLdllname);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
