unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, DateUtils,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, Data.DB,
  FireDAC.Comp.Client, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Param, FireDAC.Comp.DataSet, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  uCryptHelper, ufmLoginDialog, Vcl.ComCtrls;






type
  TfmMain = class(TForm)
    btExecuteQuery: TButton;
    btSetup: TButton;
    edServerAndDB: TEdit;
    gbUseThisKey: TGroupBox;
    laKeyName: TLabel;
    edKeyName: TEdit;
    laKeyValue: TLabel;
    edKeyValue: TEdit;
    btApplyKey: TButton;
    btEncryptDatabase: TButton;
    btDecryptDatabase: TButton;
    mResult: TMemo;
    meSelectToTest: TMemo;
    btDisconnect: TButton;
    btConnect: TButton;
    meTransaction: TMemo;
    btStart: TButton;
    btRollback: TButton;
    btCommit: TButton;
    btRollbackRet: TButton;
    procedure btExecuteQueryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure btSetupClick(Sender: TObject);
    procedure btApplyKeyClick(Sender: TObject);
    procedure btEncryptDatabaseClick(Sender: TObject);
    procedure btDecryptDatabaseClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
    procedure btDisconnectClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btRollbackClick(Sender: TObject);
    procedure btCommitClick(Sender: TObject);
    procedure btRollbackRetClick(Sender: TObject);
  private
    CH                  :TCryptHelper;
    KeysArray           :TCryptKeysArray;
    FDCP                :TDBConParamRec;
    MRUDBList           :TStrings;


    //this is modification of split code for different buttons/funcions...
    FDPhysFBDriverLink1 :TFDPhysFBDriverLink;
    FDConnection1       :TFDConnection;
    FDTransaction1      :TFDTransaction;


    //To emulate key storage
    ActiveKeyName       :ANSIString;
    ActiveKeyValue      :TCryptKeyValue;

    procedure LogMessage(AMsg:String);
    procedure LogMessageNoDate(AMsg:String);
    function  DigitToStr(const AInt:Integer; const Dim:Integer):String;
  public
  end;



var
  fmMain: TfmMain;

implementation


{$R *.dfm}



{ TForm1 }
procedure TfmMain.FormCreate(Sender: TObject);
begin
  FDPhysFBDriverLink1 :=TFDPhysFBDriverLink.Create(self);
  FDPhysFBDriverLink1.VendorLib := FDCP.LibraryName;
  FDPhysFBDriverLink1.Release;
  FDConnection1:=TFDConnection.Create(self);
  FDTransaction1:=TFDTransaction.Create(self);


  FDCP.SetDefaults;
  CH:=TCryptHelper.Create(FDCP.LibraryName); //LibraryName depends on your need, may be overwritten in GrantAccess method before real use.... TCryptHelper must be created at the same thread with connect to db
  MRUDBList:=TStringList.Create;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(CH) then FreeAndNil(CH);
  if Assigned(MRUDBList) then FreeAndNil(MRUDBList);

  if Assigned(FDConnection1) then FreeAndNil(FDConnection1);
  if Assigned(FDPhysFBDriverLink1) then FreeAndNil(FDPhysFBDriverLink1);
  if Assigned(FDTransaction1) then FreeAndNil(FDTransaction1);
end;



function TfmMain.DigitToStr(const AInt:Integer; const Dim:Integer):String;
var l:Integer;
begin
  Result:=IntToStr(AInt);
  l:=Dim-length(Result);
  while l>0 do begin
    Result:='0'+Result;
    l:=l-1;
  end;
end;



procedure TfmMain.LogMessage(AMsg:String);
var
  dd,mm,yyyy,h,m,s,ms:Word;
  timestr:String;
begin
  //for demo only
  DecodeDateTime(now(), yyyy, mm, dd, h, m, s, ms);
  timestr:=DigitToStr(yyyy, 4)+'-'+DigitToStr(mm, 2)+'-'+DigitToStr(dd, 2)
         +' '
         +DigitToStr(h, 2)+'.'+DigitToStr(m, 2)+'.'+DigitToStr(s, 2)+'.'+DigitToStr(ms, 3);
  mResult.Lines.Add(timestr+'> '+AMsg);
end;


procedure TfmMain.LogMessageNoDate(AMsg:String);
begin
  mResult.Lines.Add(AMsg);
end;


procedure TfmMain.FDConnection1BeforeConnect(Sender: TObject);
begin
  if (ActiveKeyName='') then begin
    LogMessage('Key name is not present. Will not use it!');
  end;
  LogMessage('-->BeforeConnect');
  try
    try
      SetLength(KeysArray, 1);
      LogMessage('Will use key "'+ActiveKeyName+'" (leave it empty to turn of cypher)');
      KeysArray[0].Name   := ActiveKeyName;
      KeysArray[0].pValue := @ActiveKeyValue; //Actually you need to copy array values...
      //Some other keys
      //KeysArray[0].Name:='Red';
      //KeysArray[0].pValue := @keyRed;
      CH.GrantAccess(KeysArray, FDCP.LibraryName);
    except
      on E:Exception do begin
        LogMessage('BeforeConnect error:'+E.Message);
      end
    end
  finally
    LogMessage('<--BeforeConnect');
  end;
end;


procedure TfmMain.btApplyKeyClick(Sender: TObject);
var
  strKeyValue   :String;
  strBytesLine :String;
  strByteValues :TStrings;
  tmpByteArray  :TBytes;
  f, v :Integer;
begin
  ActiveKeyName := Trim(edKeyName.Text);

  //key may be in different form here - in Text or in Hex-codes for Pascal, C and JavaScript form. So check it anyway you like

  strKeyValue:=Trim(edKeyValue.Text);
  if (Length(strKeyValue)=32) then begin
    //Key value set as text
    tmpByteArray := TEncoding.ANSI.GetBytes(strKeyValue); //ANSI or UTF8 is for example here...
    if (Length(tmpByteArray)<>32) then begin
      MessageBox(self.Handle, 'Key value in text form must be 32byte length (ANSI string) or 32bytes array of int', 'Error', MB_OK or MB_ICONERROR);
      abort;
    end;
    for f:=0 to 31 do begin
      ActiveKeyValue[f]:=tmpByteArray[f];
    end;
  end else begin
    //Key values as array of hex codes...
    strByteValues := TStringList.Create;
    try

      strBytesLine := Trim(edKeyValue.Text);
      If String.EndsText(',', strBytesLine) then begin
        strBytesLine:=Copy(strBytesLine, 0, Length(strBytesLine)-1);
      end;

      strByteValues.Clear;
      strByteValues.Delimiter       := ',';
      strByteValues.StrictDelimiter := True;
      strByteValues.DelimitedText   := strBytesLine;
      if (strByteValues.Count<>32) then begin
        MessageBox(self.Handle, PChar('Found '+IntToStr(strByteValues.Count)+' elements. Expected 32 only! Key value must be in plain text form (32byte length ANSI string) or 32bytes array of int in hex encoded (as array) form'), 'Error', MB_OK or MB_ICONERROR);
        abort;
      end;
      for f:=0 to strByteValues.Count-1 do begin
        strKeyValue := UpperCase(Trim(strByteValues.Strings[f]));
        if ( not TryStrToInt(strKeyValue, v) ) then begin
          MessageBox(self.Handle, 'Cannot convert string element to ineger value.  Key value must be in plain text form (32byte length ANSI string) or 32bytes array of int in hex encoded (as array) form', 'Error', MB_OK or MB_ICONERROR);
          abort;
        end;
        ActiveKeyValue[f]:=v;
      end;
    finally
      FreeAndNil(strByteValues);
    end;
  end;


end;





procedure TfmMain.btSetupClick(Sender: TObject);
var
  LD: TfmLoginDialog;
  mres:Integer;
begin
  LD := TfmLoginDialog.Create(fmMain);
  try
    LD.ApplyOldDCP(FDCP, MRUDBList);
    mres := LD.ShowModal;
    if mres <> mrOK then Exit;
    FDCP := LD.GetConnectionParam;
  finally
    FreeAndNil(LD);
  end;
  edServerAndDB.Text := FDCP.GetFullDBName;
  LogMessage('Will be connected to '+FDCP.GetFullDBName);
end;




procedure TfmMain.btExecuteQueryClick(Sender: TObject);
var
  quCheckQuery :TFDQuery;
  f, r:Integer;
  tmpStr:String;
begin
  quCheckQuery:=TFDQuery.Create(self);
  try
    quCheckQuery.Connection := FDConnection1;
    quCheckQuery.Transaction := FDTransaction1;
    //quCheckQuery.FetchOptions.AssignedValues := [evAutoClose];
    //quCheckQuery.FetchOptions.AutoClose := False;

    quCheckQuery.SQL.Text:=meSelectToTest.Lines.Text; // 'select * from rdb$database';
    LogMessage('Prepare');
    quCheckQuery.Prepare;
    LogMessage('Open query');
    quCheckQuery.Open;
    LogMessage('Go first');
    quCheckQuery.First;


    if (quCheckQuery.Fields.Count>0) then begin
      tmpStr:=quCheckQuery.Fields[0].FieldName;
      for f := 1 to quCheckQuery.Fields.Count-1 do begin
        tmpStr:=tmpStr+', '+quCheckQuery.Fields[f].FieldName;
      end;
      LogMessageNoDate('Fields: '+tmpStr);
      LogMessageNoDate('-----------');

      r:=1;
      while not quCheckQuery.Eof do begin
        tmpStr:='Row '+IntToStr(r)+': '+quCheckQuery.Fields[0].AsString;
        for f := 1 to quCheckQuery.Fields.Count-1 do begin
          tmpStr:=tmpStr+', '+quCheckQuery.Fields[f].AsString;
        end;
        quCheckQuery.Next;
      end;
      LogMessageNoDate(tmpStr);
      LogMessageNoDate('-----------');
    end;



    //quCheckQuery.ExecSQL;
    quCheckQuery.Close;
    LogMessage('Query closed');
  finally
    FreeAndNil(quCheckQuery);
  end;
end;






procedure TfmMain.btEncryptDatabaseClick(Sender: TObject);
var
  ParentObj           :TComponent; //needed for non gui thread...
  FDPhysFBDriverLink1 :TFDPhysFBDriverLink;
  FDConnection1       :TFDConnection;
  FDTransaction1      :TFDTransaction;
  quCheckQuery        :TFDQuery;
  strErrMst:String;
begin
  if Trim(edServerAndDB.Text)='' then begin
    btSetupClick(nil);
  end;

  btApplyKeyClick(nil);

  //todo: access code here...
  try
    ParentObj:=TComponent.Create(nil);
    try
      FDPhysFBDriverLink1 :=TFDPhysFBDriverLink.Create(ParentObj);
      try
        try
          FDPhysFBDriverLink1.VendorLib := FDCP.LibraryName;
          FDPhysFBDriverLink1.Release;
        except
          on E:Exception do begin
            strErrMst := 'Error, can''t execute "FDPhysFBDriverLink1.Release;" : '+E.Message;
            LogMessage(strErrMst);
            MessageBox(0,
              PWideChar(strErrMst),
              'Crypt Error!' ,
              MB_ICONERROR or MB_OK or MB_SETFOREGROUND or MB_TOPMOST or MB_APPLMODAL);
          end;
        end;

        FDConnection1:=TFDConnection.Create(ParentObj);
        try
          FDConnection1.LoginPrompt := False;
          FDConnection1.DriverName := 'FB';
          FDConnection1.Params.Clear;
          FDConnection1.Params.Add('DriverID=FB');

          if FDCP.GetFullServerName <>'' then begin
            //this must be like: 'Server=127.0.0.1/3050:crypt'
            FDConnection1.Params.Add('Server='+FDCP.GetFullServerName);
            FDConnection1.Params.Add('Protocol=TCPIP');
          end;
          FDConnection1.Params.Add('Database='+FDCP.DBFileName);
          FDConnection1.Params.Add('User_Name='+FDCP.UserName);
          FDConnection1.Params.Add('Password='+FDCP.Password);
          FDConnection1.Params.Add('RoleName='+FDCP.RoleName);
          FDConnection1.Params.Add('CharacterSet='+FDCP.Charset);
          FDConnection1.Params.Add('SQLDialect='+FDCP.Charset);
          FDConnection1.Params.Add('ExtendedMetadata=False');
          FDConnection1.UpdateOptions.LockWait := False;
          FDConnection1.ResourceOptions.AutoConnect:=true;
          FDConnection1.ResourceOptions.AutoReconnect:=true;

          FDConnection1.BeforeConnect:=FDConnection1BeforeConnect;


          FDTransaction1 := TFDTransaction.Create(ParentObj);
          try
            FDTransaction1.Connection := FDConnection1;
            FDTransaction1.Options.Isolation := xiReadCommitted;
            FDTransaction1.Options.ReadOnly  := true;
            FDTransaction1.Options.Params.Clear;
            FDTransaction1.Options.Params.Add('read');
            FDTransaction1.Options.Params.Add('read_committed');
            FDTransaction1.Options.Params.Add('rec_version');
            FDTransaction1.Options.Params.Add('nowait');

            LogMessage('Try to open connection');
            FDConnection1.Open();
            LogMessage('Connected!');


            {$REGION 'Query or Execute'}
            quCheckQuery:=TFDQuery.Create(ParentObj);
            try
              quCheckQuery.Connection := FDConnection1;
              quCheckQuery.Transaction := FDTransaction1;
              quCheckQuery.FetchOptions.AssignedValues := [evAutoClose];
              quCheckQuery.FetchOptions.AutoClose := False;

              //цикл на случай требования коммитить транзакцию после каждой команды
              LogMessage('StartTransaction');
              FDTransaction1.StartTransaction;
              quCheckQuery.SQL.Text:='alter database encrypt with DbCrypt key '+ActiveKeyName+';';  //alter database decrypt;
              LogMessage('executing query: '+quCheckQuery.SQL.Text);
              quCheckQuery.ExecSQL;
              LogMessage('Done');
              quCheckQuery.Close;

              if FDTransaction1.Active then begin
                FDTransaction1.Commit;
              end;
            finally
              FreeAndNil(quCheckQuery);
            end;
            {$ENDREGION}

            if FDConnection1.Connected then begin //Разрываем коннект
              FDConnection1.Close;
              end;
          finally
            if FDTransaction1.Active then begin
              FDTransaction1.Commit;
            end;
            LogMessage('Transaction closed');
            FreeAndNil(FDTransaction1);
            if FDConnection1.Connected then begin
              FDConnection1.Close;
            end;
            LogMessage('Connection closed');
          end;
        finally
          FreeAndNil(FDConnection1);
        end;
      finally
        FreeAndNil(FDPhysFBDriverLink1);
      end;
    finally
      FreeAndNil(ParentObj);
    end;
  except
    on E:Exception do begin
      LogMessage('Error: '+E.Message);
      MessageBox(0,
        PWideChar(E.Message),
        'Can''t perform crypt db access check!' ,
        MB_ICONERROR or MB_OK or MB_SETFOREGROUND or MB_TOPMOST or MB_APPLMODAL);
    end;
  end;
end;




procedure TfmMain.btDecryptDatabaseClick(Sender: TObject);
var
  ParentObj           :TComponent; //needed for non gui thread...
  FDPhysFBDriverLink1 :TFDPhysFBDriverLink;
  FDConnection1       :TFDConnection;
  FDTransaction1      :TFDTransaction;
  quCheckQuery        :TFDQuery;
begin
  if Trim(edServerAndDB.Text)='' then begin
    btSetupClick(nil);
  end;

  btApplyKeyClick(nil);

  //todo: access code here...
  try
    ParentObj:=TComponent.Create(nil);
    try
      FDPhysFBDriverLink1 :=TFDPhysFBDriverLink.Create(ParentObj);
      try
        FDPhysFBDriverLink1.VendorLib := FDCP.LibraryName;
        FDPhysFBDriverLink1.Release;

        FDConnection1:=TFDConnection.Create(ParentObj);
        try
          FDConnection1.LoginPrompt := False;
          FDConnection1.DriverName := 'FB';
          FDConnection1.Params.Clear;
          FDConnection1.Params.Add('DriverID=FB');

          if FDCP.GetFullServerName <>'' then begin
            //this must be like: 'Server=127.0.0.1/3050:crypt'
            FDConnection1.Params.Add('Server='+FDCP.GetFullServerName);
            FDConnection1.Params.Add('Protocol=TCPIP');
          end;
          FDConnection1.Params.Add('Database='+FDCP.DBFileName);
          FDConnection1.Params.Add('User_Name='+FDCP.UserName);
          FDConnection1.Params.Add('Password='+FDCP.Password);
          FDConnection1.Params.Add('RoleName='+FDCP.RoleName);
          FDConnection1.Params.Add('CharacterSet='+FDCP.Charset);
          FDConnection1.Params.Add('SQLDialect='+FDCP.Charset);
          FDConnection1.Params.Add('ExtendedMetadata=False');
          FDConnection1.UpdateOptions.LockWait := False;
          FDConnection1.ResourceOptions.AutoConnect:=true;
          FDConnection1.ResourceOptions.AutoReconnect:=true;

          FDConnection1.BeforeConnect:=FDConnection1BeforeConnect;


          FDTransaction1 := TFDTransaction.Create(ParentObj);
          try
            FDTransaction1.Connection := FDConnection1;
            FDTransaction1.Options.Isolation := xiReadCommitted;
            FDTransaction1.Options.ReadOnly  := true;
            FDTransaction1.Options.Params.Clear;
            FDTransaction1.Options.Params.Add('read');
            FDTransaction1.Options.Params.Add('read_committed');
            FDTransaction1.Options.Params.Add('rec_version');
            FDTransaction1.Options.Params.Add('nowait');

            LogMessage('Try to open connection');
            FDConnection1.Open();
            LogMessage('Connected!');


            {$REGION 'Query or Execute'}
            quCheckQuery:=TFDQuery.Create(ParentObj);
            try
              quCheckQuery.Connection := FDConnection1;
              quCheckQuery.Transaction := FDTransaction1;
              quCheckQuery.FetchOptions.AssignedValues := [evAutoClose];
              quCheckQuery.FetchOptions.AutoClose := False;

              //цикл на случай требования коммитить транзакцию после каждой команды
              LogMessage('StartTransaction');
              FDTransaction1.StartTransaction;
              quCheckQuery.SQL.Text:='alter database decrypt';
              LogMessage('executing query: '+quCheckQuery.SQL.Text);
              quCheckQuery.ExecSQL;
              LogMessage('Done');
              quCheckQuery.Close;

              if FDTransaction1.Active then begin
                FDTransaction1.Commit;
              end;
            finally
              FreeAndNil(quCheckQuery);
            end;
            {$ENDREGION}

            if FDConnection1.Connected then begin //Разрываем коннект
              FDConnection1.Close;
              end;
          finally
            if FDTransaction1.Active then begin
              FDTransaction1.Commit;
            end;
            LogMessage('Transaction closed');
            FreeAndNil(FDTransaction1);
            if FDConnection1.Connected then begin
              FDConnection1.Close;
            end;
            LogMessage('Connection closed');
          end;
        finally
          FreeAndNil(FDConnection1);
        end;
      finally
        FreeAndNil(FDPhysFBDriverLink1);
      end;
    finally
      FreeAndNil(ParentObj);
    end;
  except
    on E:Exception do begin
      LogMessage('Error: '+E.Message);
      MessageBox(0,
        PWideChar(E.Message),
        'Can''t perform crypt db access check!' ,
        MB_ICONERROR or MB_OK or MB_SETFOREGROUND or MB_TOPMOST or MB_APPLMODAL);
    end;
  end;
end;



procedure TfmMain.btConnectClick(Sender: TObject);
begin
  if Trim(edServerAndDB.Text)='' then begin
    btSetupClick(nil);
  end;

  btApplyKeyClick(nil);

  FDPhysFBDriverLink1.VendorLib := FDCP.LibraryName;
  FDPhysFBDriverLink1.Release;
  FDConnection1.LoginPrompt := False;
  FDConnection1.DriverName := 'FB';
  FDConnection1.Params.Clear;
  FDConnection1.Params.Add('DriverID=FB');

  if FDCP.GetFullServerName <>'' then begin
    //this must be like: 'Server=127.0.0.1/3050:crypt'
    FDConnection1.Params.Add('Server='+FDCP.GetFullServerName);
    FDConnection1.Params.Add('Protocol=TCPIP');
  end;

  FDConnection1.Params.Add('Database='+FDCP.DBFileName);
  FDConnection1.Params.Add('User_Name='+FDCP.UserName);
  FDConnection1.Params.Add('Password='+FDCP.Password);
  FDConnection1.Params.Add('RoleName='+FDCP.RoleName);
  FDConnection1.Params.Add('CharacterSet='+FDCP.Charset);
  FDConnection1.Params.Add('SQLDialect='+FDCP.Charset);
  FDConnection1.Params.Add('ExtendedMetadata=False');
  FDConnection1.UpdateOptions.LockWait := False;
  FDConnection1.ResourceOptions.AutoConnect:=true;
  FDConnection1.ResourceOptions.AutoReconnect:=true;

  FDConnection1.BeforeConnect:=FDConnection1BeforeConnect;

  LogMessage('Try to open connection');
  FDConnection1.Open();
  LogMessage('Connected!');

end;

procedure TfmMain.btDisconnectClick(Sender: TObject);
begin
  if FDConnection1.Connected then begin
    FDConnection1.Close;
  end;
  LogMessage('Connection closed');
end;

procedure TfmMain.btStartClick(Sender: TObject);
begin
  FDTransaction1.Connection := FDConnection1;
  //FDTransaction1.Options.Isolation := xiReadCommitted;
  //FDTransaction1.Options.ReadOnly  := true;
  FDTransaction1.Options.AutoCommit:=false;
  FDTransaction1.Options.AutoStart:=false;
  FDTransaction1.Options.AutoStop:=false;

  FDTransaction1.Options.Params.Clear;
  FDTransaction1.Options.Params.AddStrings(meTransaction.Lines);
  //FDTransaction1.Options.Params.Add('read');
  //FDTransaction1.Options.Params.Add('read_committed');
  //FDTransaction1.Options.Params.Add('rec_version');
  //FDTransaction1.Options.Params.Add('nowait');

  FDTransaction1.StartTransaction;
  LogMessage('Transaction Started');
end;


procedure TfmMain.btRollbackClick(Sender: TObject);
begin
  //if FDTransaction1.Active then
  FDTransaction1.Rollback;
  LogMessage('Transaction Rollback');
end;

procedure TfmMain.btRollbackRetClick(Sender: TObject);
begin
  //if FDTransaction1.Active then
  FDTransaction1.RollbackRetaining;
  LogMessage('Transaction RollbackRetaining');

end;

procedure TfmMain.btCommitClick(Sender: TObject);
begin
  //if FDTransaction1.Active then
  FDTransaction1.Commit;
  LogMessage('Transaction Commit');
end;


end.



