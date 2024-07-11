unit UPrincipal.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.JSON, ExcelXP, ComObj, System.Threading,
  Vcl.Samples.Gauges;

type
   TfrmPrincipal = class(TForm)
      sbrBarra: TStatusBar;
      pnlBotao: TPanel;
      pnlCorpo: TPanel;
      lblLink: TLabel;
      edtLink: TEdit;
      btnRequest: TBitBtn;
      lblStatus: TLabel;
      btnSair: TBitBtn;
      btnExecel: TBitBtn;
      lblAuth: TLabel;
      menAuth: TMemo;
      gauProgresso: TGauge;
      procedure btnSairClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure btnRequestClick(Sender: TObject);
      procedure btnExecelClick(Sender: TObject);
  private
    { Private declarations }
     vObjArrayJson : TJSONArray;
     vSaveDialog   : TSaveDialog;

     procedure ControlaCampos(pOpcao : Boolean);
     procedure RealizaGet;
     procedure GeraPlanilha;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
   URest.Model, UMensagem.Util;

const
   CAPTION_STATUS = 'Status Request: ';

{$R *.dfm}

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
   Application.Terminate;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
   edtLink.Text := 'https://apidecepbr.squareweb.app/cep/[Insira aqui o cep a ser buscado]';
   menAuth.Clear;

   if edtLink.CanFocus then
      edtLink.SetFocus;
end;

procedure TfrmPrincipal.ControlaCampos(pOpcao: Boolean);
var
   xAux : Integer;
begin
   for xAux := 0 to ComponentCount - 1 do
   begin
      if (Components[xAux] Is TEdit) then
         (Components[xAux] As TEdit).Enabled   := pOpcao;

      if (Components[xAux] Is TBitBtn) then
         (Components[xAux] As TBitBtn).Enabled := pOpcao;

      if (Components[xAux] Is TMemo) then
         (Components[xAux] As TMemo).Enabled   := pOpcao;
   end;
end;

procedure TfrmPrincipal.btnRequestClick(Sender: TObject);
begin
   try
      if edtLink.Text <> EmptyStr then
      begin
         TTask.Run(RealizaGet);
         ControlaCampos(False);
      end
      else
         TMensagemUtil.Alerta(Self, 'Por favor, preencha o campo Link antes de realizar o Request!');
   except
      on e:exception do
         raise Exception.Create(e.Message);
   end;
end;

procedure TfrmPrincipal.RealizaGet;
begin
   try
      vObjArrayJson := TRest.getInstancia.GetDatos(edtLink.Text, menAuth.Text);

      if vObjArrayJson <> nil then
      begin
         lblStatus.Caption    := CAPTION_STATUS + 'Requisição realizada com sucesso!';
         lblStatus.Font.Color := clGreen;
      end
      else
      begin
         lblStatus.Caption    := CAPTION_STATUS + 'Falha na Requisição!';
         lblStatus.Font.Color := clRed;
      end;

      ControlaCampos(True);
   except
      on e:exception do
      begin
         TThread.Synchronize(nil,
            procedure
            begin
               TMensagemUtil.Alerta(Self, 'Falha ao realizar requisição: ' + e.Message);
            end
         );
      end;
   end;
end;

procedure TfrmPrincipal.btnExecelClick(Sender: TObject);
begin
   if vObjArrayJson = nil then
   begin
      TMensagemUtil.Alerta(Self, 'Realize um Request antes de gerar uma planilha!');
      Exit;
   end;

   vSaveDialog          := TSaveDialog.Create(nil);
   vSaveDialog.Filter   := 'Arquivo do Excel |*.xlsx';
   vSaveDialog.FileName := 'Request ' + FormatDateTime('dd-mm-yyyy hh-MM-ss', Now);

   if vSaveDialog.Execute then
   begin
      ControlaCampos(False);
      TTask.Run(GeraPlanilha);
   end;
end;

procedure TfrmPrincipal.GeraPlanilha;
var
   xApp,
   xWorkbook,
   xWorksheet      : OleVariant;
   I,
   J               : Integer;
   xObjJson        : TJSONObject;
   xChaves         : TStringList;
   xChave          : String;
   xTamanhoPalavra : Array of Integer;
begin
   try
      gauProgresso.Progress := 0;
      gauProgresso.MaxValue := vObjArrayJson.Count;
      try
         xApp         := CreateOleObject('Excel.Application');
         xApp.Visible := False;
         xWorkbook    := xApp.Workbooks.Add;
         xWorksheet   := xWorkbook.Worksheets[1];

         // Alinhamento Centralizado
         xWorksheet.Cells.HorizontalAlignment := 3;
      except
         on EOleSysError do
         begin
            TThread.Synchronize(nil,
               procedure
               begin
                  TMensagemUtil.Alerta(Self, 'Falha ao criar Planilha Excel!' + #13 +
                  'Verifique a instalação do Excel em seu Computador.');
                  ControlaCampos(True);
                  Exit;
               end
            );
         end;
      end;

      if vObjArrayJson.Count > 0 then
      begin
         // Obter as chaves do primeiro objeto para criar os cabeçalhos
         xObjJson := vObjArrayJson.Items[0] as TJSONObject;
         xChaves  := TStringList.Create;

         // Inicializar a lista de comprimentos máximos de palavras
         SetLength(xTamanhoPalavra, xObjJson.Count);

         for J := 0 to Pred(xObjJson.Count) do
         begin
            xChaves.Add(xObjJson.Pairs[J].JsonString.Value);
            xTamanhoPalavra[J] := Length(xChaves[J]);
         end;

         // Preencher os cabeçalhos na primeira linha
         for J := 0 to Pred(xChaves.Count) do
            xWorksheet.Cells[1, J + 1].Value := xChaves[J];

         // Preencher os dados
         for I := 0 to Pred(vObjArrayJson.Count) do
         begin
            xObjJson := vObjArrayJson.Items[I] as TJSONObject;
            for J := 0 to Pred(xChaves.Count) do
            begin
               xChave := xChaves[J];
               xWorksheet.Cells[I + 2, J + 1].Value := xObjJson.GetValue<String>(xChave);

               gauProgresso.Progress := gauProgresso.Progress + 1;
               gauProgresso.Repaint;

               // Atualizar o comprimento máximo da palavra para a coluna
               if Length(xObjJson.GetValue<String>(xChave)) > xTamanhoPalavra[J] then
                  xTamanhoPalavra[J] := Length(xObjJson.GetValue<String>(xChave));
            end;
         end;

         // Definir a largura das colunas com base na palavra mais longa
         for J := 0 to Pred(xChaves.Count) do
            xWorksheet.Columns[J + 1].ColumnWidth := xTamanhoPalavra[J] + 2; // Adicionando um buffer para espaços
      end;

      if VarIsType(xApp, varDispatch) then
      begin
         xWorkbook.SaveAs(vSaveDialog.FileName);
         xApp.Quit;
         xApp := Unassigned;

         TThread.Synchronize(nil,
            procedure
            begin
               TMensagemUtil.Informacao(Self, 'Planilha Excel gerada com sucesso!');
               ControlaCampos(True);

               lblStatus.Caption := 'Status Request: Pendente';
               lblStatus.Font.Color := clWindowText;
               gauProgresso.Progress := 0;
            end
         );
      end;
   finally
      if xChaves <> nil then
         FreeAndNil(xChaves);

      if vSaveDialog <> nil then
         FreeAndNil(vSaveDialog);

      if vObjArrayJson <> nil then
         FreeAndNil(vObjArrayJson);
   end;
end;


end.
