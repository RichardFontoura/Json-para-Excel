program API4Execel;

uses
  Vcl.Forms,
  UPrincipal.View in 'View\UPrincipal.View.pas' {frmPrincipal},
  URest.Model in 'Model\URest.Model.pas',
  UMensagem.Util in 'Model\Util\UMensagem.Util.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
