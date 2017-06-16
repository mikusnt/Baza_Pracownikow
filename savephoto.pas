unit savephoto;

interface

uses
  Vcl.Dialogs,System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.ExtDlgs;

type
  TSavePhoto = class(TImage)
  private
    fCaption,fhint,fCatalog,name:string;
     fOnclick:tnotifyevent;
  protected
    { Protected declarations }
  public
  procedure save(Sender: TObject);
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;

  published
   property hint : string read Fhint write Fhint;
   //property Onclick : TNotifyEvent read FOnclick write FOnclick;


  end;

procedure Register;
implementation

procedure Register;
begin
  RegisterComponents('Samples', [TSavePhoto]);
end;



procedure TSavePhoto.save(Sender: TObject);
var app:tsavephoto;
begin
Left:=150;
Width:=150;
showmessage('save');

end;

 constructor TSavePhoto.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);
  OnClick:=save;
  hint:='mmm';

end;

destructor TSavePhoto.Destroy;
begin
  inherited Destroy;
end;

end.
