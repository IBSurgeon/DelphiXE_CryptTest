program CryptTest;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fmMain},
  Firebird in 'Firebird.pas',
  uCryptHelper in 'uCryptHelper.pas',
  ufmLoginDialog in 'ufmLoginDialog.pas' {fmLoginDialog};

{$R *.res}


begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
