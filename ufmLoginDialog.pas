unit ufmLoginDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;



type


  TDBConParamRec = record
    LibraryName :AnsiString; //String;
    Server      :AnsiString;
    Port        :Integer;
    DBFileName  :AnsiString;
    UserName    :AnsiString;
    Password    :AnsiString;
    RoleName    :AnsiString;
    Charset     :AnsiString;
    SQLDialect  :Integer;
    function GetFullDBName:AnsiString;
    function GetFullServerName:AnsiString;
    procedure SetDefaults;
  end;


  TfmLoginDialog = class(TForm)
    paButtons: TPanel;
    btExit: TButton;
    btConnect: TButton;
    gbConnection: TGroupBox;
    Label1: TLabel;
    btDBPath: TSpeedButton;
    Label6: TLabel;
    sbSelectLibrary: TSpeedButton;
    edServerName: TEdit;
    edLibrary: TEdit;
    gbDBParameters: TGroupBox;
    laPassword: TLabel;
    laUserName: TLabel;
    edUserName: TEdit;
    edPassword: TEdit;
    gbAdditional: TGroupBox;
    Label2: TLabel;
    Label5: TLabel;
    laRole: TLabel;
    cbSQLDialect: TComboBox;
    cbCharacterSet: TComboBox;
    edRole: TEdit;
    gbServer: TGroupBox;
    laServer: TLabel;
    laPort: TLabel;
    edPort: TEdit;
    laMoreLess: TLabel;
    cbAlias: TCheckBox;
    cbShowPassword: TCheckBox;
    cbDBFilePath: TComboBox;
    procedure btExitClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDBPathClick(Sender: TObject);
    procedure sbSelectLibraryClick(Sender: TObject);
    procedure edPageSizeKeyPress(Sender: TObject; var Key: Char);
    procedure edPortKeyPress(Sender: TObject; var Key: Char);
    procedure laMoreLessClick(Sender: TObject);
    procedure cbAliasClick(Sender: TObject);
    procedure cbShowPasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbDBFilePathChange(Sender: TObject);
  private
    procedure UpdateState();
  public
    function GetConnectionParam:TDBConParamRec;
    procedure ApplyOldDCP(const ADCP:TDBConParamRec; const MRUDBList:TStrings);
  end;


implementation


{$R *.dfm}

procedure TfmLoginDialog.UpdateState;
begin
  btConnect.Enabled:=length(Trim(cbDBFilePath.Text))>0;
  if FileExists(cbDBFilePath.Text) or cbAlias.Checked then begin
    cbDBFilePath.Font.Color:=clWindowText;
  end else begin
    cbDBFilePath.Font.Color:=clRed;
  end;

  if gbAdditional.Visible then begin
    laMoreLess.Caption := 'less params...';
  end else begin
    laMoreLess.Caption := 'more params...';
  end;
end;


procedure TfmLoginDialog.btExitClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  //close;
end;


procedure TfmLoginDialog.btConnectClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;


procedure TfmLoginDialog.ApplyOldDCP(const ADCP: TDBConParamRec; const MRUDBList:TStrings);
var
  ii         :Integer;
  SQLDialect :Integer;
begin
  //fill MRU List
  cbDBFilePath.Items.Clear;
  cbDBFilePath.Items.AddStrings(MRUDBList);

  edServerName.Text   := ADCP.Server;
  edPort.Text         := IntToStr(ADCP.Port);
  cbDBFilePath.Text   := ADCP.DBFileName;
  edLibrary.Text      := ADCP.LibraryName;
  edUserName.Text     := ADCP.UserName;
  edPassword.Text     := ADCP.Password;
  edRole.Text         := ADCP.RoleName;


  SQLDialect := ADCP.SQLDialect;
  //Приводим диалекты к разрешенной величине.
  if (SQLDialect=0) then SQLDialect:=1;
  if (SQLDialect<>1) and (SQLDialect<>3)
    then SQLDialect:=3;
  ii:=cbSQLDialect.Items.IndexOf(IntToStr(SQLDialect));
  if ii>=0 then cbSQLDialect.ItemIndex:=ii
           else cbSQLDialect.ItemIndex:=1;

  if Trim(ADCP.Charset)<>''
    then cbCharacterSet.Text:=ADCP.Charset
    else cbCharacterSet.Text:='NONE';

  UpdateState;
end;



function TfmLoginDialog.GetConnectionParam: TDBConParamRec;
begin
  Result.Server      := edServerName.Text;
  Result.Port        := StrToIntDef(Trim(edPort.Text), 3050);
  Result.DBFileName  := cbDBFilePath.Text;
  Result.LibraryName := edLibrary.Text;
  Result.UserName  := edUserName.Text;
  Result.Password  := edPassword.Text;
  Result.RoleName  := edRole.Text;

  Result.Charset     := cbCharacterSet.Text;
  Result.SQLDialect  := StrToIntDef(Trim(cbSQLDialect.Text), 3);
end;



procedure TfmLoginDialog.laMoreLessClick(Sender: TObject);
begin
  gbAdditional.Visible := not gbAdditional.Visible;
  UpdateState;
end;


procedure TfmLoginDialog.sbSelectLibraryClick(Sender: TObject);
var odLibrary:TOpenDialog;
begin
  odLibrary:=TOpenDialog.Create(self);
  try
    odLibrary.DefaultExt:='*.DLL';
    odLibrary.Filter:='Known library files|gds32.dll;fbclient.dll;gds*.dll;fbclient*.dll'
                     +'|gds32.dll|gds32.dll'
                     +'|fbclient.dll|fbclient.dll'
                     +'|All dll files (*.dll)|*.dll'
                     +'|All files (*.*)|*.*';
    odLibrary.Options:=[ofReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
    odLibrary.Title:='client library';
    if odLibrary.Execute then begin
      edLibrary.Text:=odLibrary.FileName;
    end;
  finally
    FreeAndNil(odLibrary);
  end;
end;



procedure TfmLoginDialog.btDBPathClick(Sender: TObject);
var odDBPath:TOpenDialog;
begin
  odDBPath:=TOpenDialog.Create(self);
  try
    odDBPath.DefaultExt:='*.fdb';
    odDBPath.Filter:='Known databases|*.fdb;*.gdb;*.ib'
                    +'|Firebird database (*.fdb)|*.fdb'
                    +'|Interbase database (*.gdb;*.ib)|*.gdb;*.ib'
                    +'|All Files(*.*)|*.*';
    odDBPath.Options:=[ofReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
    odDBPath.Title:='database file';
    if odDBPath.Execute then begin
      cbDBFilePath.Text:=odDBPath.FileName;
      cbAlias.Checked := False;
      cbDBFilePath.OnChange(nil);
    end;
  finally
    FreeAndNil(odDBPath);
  end;
end;



procedure TfmLoginDialog.edPageSizeKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key>=' ') and ((Key<'0') or (Key>'9')) then begin
    Key:=#0;
  end;
end;


procedure TfmLoginDialog.edPortKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key>=' ') and ((Key<'0') or (Key>'9')) then begin
    Key:=#0;
  end;
end;


procedure TfmLoginDialog.FormShow(Sender: TObject);
begin
  UpdateState;
  //При первом показе - позиционируем фокус на поле для ввода пароля.
  if edPassword.CanFocus then edPassword.SetFocus;
  OnShow := nil;
end;

procedure TfmLoginDialog.cbAliasClick(Sender: TObject);
begin
  UpdateState;
end;

procedure TfmLoginDialog.cbDBFilePathChange(Sender: TObject);
begin
  UpdateState;
end;



procedure TfmLoginDialog.cbShowPasswordClick(Sender: TObject);
begin
  if cbShowPassword.Checked then begin
    edPassword.PasswordChar:=#0;
  end else begin
    edPassword.PasswordChar:='*';
  end;
end;


{ TDBConParamRec }

function TDBConParamRec.GetFullDBName: AnsiString;
//This version is TCP only:
begin
  //For non TCP use: "qqqsever:" or "\\qqqsever\" or "qqqsever@"
  //qqqsever:c:\temp\test.gdb   - TCP
  //\\qqqsever\c:\temp\test.gdb - NamedPipe
  //qqqsever@c:\temp\test.gdb   - IPX
  if Trim(Server)=''  then begin
    Result:=''; //No server name -> local connection!
  end else begin
    Result:=trim(Server)+'/'+IntToStr(Port);
  end;
  if Length(Result)<>0 then Result:=Result+':';

  Result:=Result+DBFileName;
end;


function TDBConParamRec.GetFullServerName: AnsiString;
begin
  if Trim(Server)=''  then begin
    Result:=''; //No server name -> local connection!
  end else begin
    Result:=trim(Server)+'/'+IntToStr(Port);
  end;
end;


procedure TDBConParamRec.SetDefaults;
begin
  LibraryName := 'fbclient.dll';
  Server      := '127.0.0.1';
  Port        := 3050;
  DBFileName  := 'crypt';
  UserName    := 'SYSDBA';
  Password    := 'masterkey';
  RoleName    := '';
  Charset     := 'none';
  SQLDialect := 3;
end;

end.
