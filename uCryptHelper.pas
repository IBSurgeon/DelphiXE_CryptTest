unit uCryptHelper;

interface

{$DEFINE FBPROV} //if you want access through the provider - use Firebird unit, but also do not forget to properly change path to client library inside it unit...
{$UNDEF FBPROV}

uses
  System.SysUtils, System.Variants, Windows
  {$IFDEF FBPROV}
  , Firebird
  {$ENDIF}
  ;

//Your keys here
const keyRed: array [0..31] of byte  = ($ec,$a1,$52,$f6,$4d,$27,$da,$93,$53,$e5,$48,$86,$b9,$7d,$e2,$8f,$3b,$fa,$b7,$91,$22,$5b,$59,$15,$82,$35,$f5,$30,$1f,$04,$dc,$75);
const keyGreen: array [0..31] of byte = ($00,$d7,$34,$63,$ae,$19,$52,$00,$b8,$84,$a3,$44,$bd,$11,$9f,$72,$e0,$04,$68,$4f,$c4,$89,$3b,$20,$8d,$2a,$a7,$07,$32,$3b,$5e,$74);
const keyBlue: array [0..31] of byte = ($00,$83,$46,$88,$f2,$1d,$2c,$69,$48,$56,$7a,$4a,$0a,$85,$35,$22,$5c,$02,$4f,$65,$b8,$73,$77,$07,$89,$b2,$c6,$04,$da,$e4,$03,$5d);



type

  TCryptKeyValue = array [0..31] of byte;
  PCryptKeyValue = ^TCryptKeyValue;


  TDBCryptKey = record
    Name   :AnsiString;
    pValue :PCryptKeyValue;
  end;

  TCryptKeysArray = array of TDBCryptKey;


  TCryptHelper = class
  {$REGION 'fbprov'}
  private
    {$IFDEF FBPROV}
    // Declare pointers to required interfaces
    // Status is used to return wide error description to user
    st : IStatus;

    // This is main interface of firebird, and the only one
    // for getting which there is special function in our API
    master : IMaster;
    util : IUtil;

    // XpbBuilder helps to create various parameter blocks for API calls
    dpb : IXpbBuilder;

    // Provider is needed to start to work with database (or service)
    prov : IProvider;

    // Attachment and Transaction contain methods to work with
    // database attachment and transaction
    att : IAttachment;
    tra : ITransaction;
  public
  function PrintError(s: IStatus):String;
    {$ENDIF}
    {$ENDREGION}
  private
    ClientLibrary :AnsiString;
  public
    constructor Create(const AClientLibrary :AnsiString);
    destructor Destroy();override;
    procedure GrantAccess(DBKeysArray:TCryptKeysArray; const AClientLibrary :AnsiString='');//also must be called on reconnect event (if needed)
  end;


//Access to crypt library functions to communicate with FB server
//extern "C" __declspec(dllexport) int fbcrypt_init(const char* clientPathName);
function fbcrypt_init(pszClientPathName:Pointer) : integer; stdcall; external 'fbcrypt.dll'; //cdecl //stdcall

//extern "C" __declspec(dllexport) int fbcrypt_key(const char* name, const unsigned char* data, unsigned dl);
function fbcrypt_key(pszKeyName:Pointer;pKeyValue:Pointer;iKeyLength:Cardinal) : integer; stdcall; external 'fbcrypt.dll'; //'Library.dll';

//extern "C" __declspec(dllexport) int fbcrypt_callback(void* provider); //__declspec(dllexport)
function fbcrypt_callback(provider:Pointer) : integer; stdcall; external 'fbcrypt.dll';






implementation

//{$L f:\WORK\FBCrypt\pas\Library.obj} : [dcc32 Error] uCryptHelper.pas(269): E1028 Bad global symbol definition: '?cloopinitDispatcher@?$IStatusBaseImpl@VCheckStatusWrapper@Firebird@@V12@V?$IDisposableImpl@VCheckStatusWrapper@Firebird@@V12@V?$Inherit@V?$IVersionedImpl@VCheckStatusWrapper@Firebird@@V12@V?$Inherit@VIStatus@Firebird@@@2@@Firebird@@@2@@2@@Firebird@@SAXPAVIStatus@2@@Z' in object file 'f:\WORK\FBCrypt\pas\Library.obj'

{ TCryptHelper }


constructor TCryptHelper.Create(const AClientLibrary :AnsiString);
begin
  if AClientLibrary<>'' then begin
    ClientLibrary:=AClientLibrary;
  end else begin
    ClientLibrary:='fbclient.dll'
  end;
  {$REGION 'fbprov'}
  {$IFDEF FBPROV}
  st:=nil;
  master:=nil;
  util:=nil;
  dpb:=nil;
  prov:=nil;
  att:=nil;
  tra:=nil;
  {$ENDIF}
  {$ENDREGION}
end;


destructor TCryptHelper.Destroy;
begin
  {$REGION 'fbprov'}
  {$IFDEF FBPROV}
  if Assigned(dpb) then begin
    dpb.dispose;
    dpb:=nil;
  end;

  if Assigned(prov) then begin
    prov.release;
    prov:=nil;
  end;
  {$ENDIF}
  {$ENDREGION}

  inherited;
end;


{$REGION 'fbprov'}
{$IFDEF FBPROV}
function TCryptHelper.PrintError(s: IStatus):String;
var
		maxMessage : Integer;
		outMessage : PAnsiChar;
begin
		maxMessage := 256;
		outMessage := AnsiStrAlloc(maxMessage);
		util.formatStatus(outMessage, maxMessage, s);
    Result := String(AnsiString(outMessage));
		StrDispose(outMessage);
end;
{$ENDIF}
{$ENDREGION}



procedure TCryptHelper.GrantAccess(DBKeysArray: TCryptKeysArray; const AClientLibrary :AnsiString='');
var f:Integer;
begin
  if AClientLibrary<>'' then begin //Update ClientLibrary path if it needed
    ClientLibrary:=AClientLibrary;
  end;

  if Length(DBKeysArray)=0 then begin
    raise Exception.Create('At least one key must be present in DBKeysArray!');
  end;

  {$REGION 'fbprov'}
  {$IFDEF FBPROV}
  // *	DESCRIPTION:	A sample of creating new database and new table in it.
  // *					Run second time (when database already exists) to see
  // *					how FbException is caught and handled by this code.
  // *
  // *					Example for the following interfaces:
  // *					IMaster - main inteface to access all the rest
  // *					Status - returns the status of executed command
  // *					Provider - main interface to access DB / service
  // *					Attachment - database attachment interface
  // *					Transaction - transaction interface
  // *					Util - helper calls here and there
  // *					XpbBuilder - build various parameters blocks


	// Here we get access to master interface and helper utility interface
	// no error return may happen - these functions always succeed
	master := fb_get_master_interface;
	util := master.getUtilInterface;

	// status vector and main dispatcher are returned by calls to IMaster functions
	// no error return may happen - these functions always succeed
	st := master.getStatus;
	prov := master.getDispatcher;
  {$ENDIF}
  {$ENDREGION}

  //If you want debug calls inside VisualStudio you can stop this thread by MessageBox
  //MessageBox(0, 'Start debug', 'Start debug', MB_OK);
  //MessageBoxA(0, PAnsiChar(ClientLibrary), 'fbcrypt_init with param', 0);

  if (fbcrypt_init(PAnsiChar(ClientLibrary)) < 0) then begin //ClientLibrary
    raise Exception.Create('fbcrypt_init failed');
  end;


  for f:=0 to Length(DBKeysArray)-1 do begin
    if (fbcrypt_key(PAnsiChar(DBKeysArray[f].Name), DBKeysArray[f].pValue, sizeof(DBKeysArray[f].pValue^)) < 0) then begin
      raise Exception.Create('fbcrypt_key failed'); //"'+DBKeysArray[f].Name+'"
    end;
  end;


  {$IFDEF FBPROV}
  if (fbcrypt_callback(prov) < 0) then begin
  {$ELSE}
  if (fbcrypt_callback(nil) < 0) then begin
  {$ENDIF}
    raise Exception.Create('fbcrypt_callback');
  end;


  {$REGION 'fbprov'}
  //Here some sampeles of access to DB
  {$IFDEF FBPROV}
  try
    //Here is test example for access
		// create DPB
		dpb := util.getXpbBuilder(st, IXpbBuilder.DPB, nil, 0);
		//dpb.insertInt(st, isc_dpb_page_size, 4 * 1024);
		dpb.insertString(st, isc_dpb_user_name, 'sysdba');   //todo: change it!
		dpb.insertString(st, isc_dpb_password, 'masterkey'); //

		// create empty database
		//att := prov.createDatabase(st, PAnsiChar(AnsiString(YourDatabaseNameFullPath)), dpb.getBufferLength(st), dpb.getBuffer(st));

		// detach from database
		//att.detach(st);
		//att := nil;

		// remove unneeded any more tag from DPB
		//if dpb.findFirst(st, isc_dpb_page_size)
		//	then dpb.removeCurrent(st);

		// attach it once again
    att := prov.attachDatabase(st, PAnsiChar(AnsiString('127.0.0.1/3050:crypt')), dpb.getBufferLength(st), dpb.getBuffer(st)); //todo: for YourDatabaseNameFullPath

		// start transaction
		tra := att.startTransaction(st, 0, nil);

		//recreate table
		att.execute(st, tra, 0, 'recreate table dates_table (d1 date)', 3, nil, nil, nil, nil);	// Input parameters and output data not used

		// commit transaction retaining
		tra.commitRetaining(st);

		// insert a record into dates_table
		att.execute(st, tra, 0, 'insert into dates_table values (CURRENT_DATE)', 3,	nil, nil, nil, nil);	// Input parameters and output data not used

		// commit transaction (will close interface)
		tra.commit(st);
		tra := nil;

		// detach from database (will close interface)
		att.detach(st);
		att := nil;
	except
		on e: FbException do raise Exception.Create(PrintError(e.getStatus))
    else
      raise;
	end;
  {$ENDIF}
  {$ENDREGION}
end;

end.
