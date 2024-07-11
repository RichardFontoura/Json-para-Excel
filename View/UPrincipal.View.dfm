object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'API Json to Excel'
  ClientHeight = 261
  ClientWidth = 397
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object sbrBarra: TStatusBar
    Left = 0
    Top = 242
    Width = 397
    Height = 19
    Panels = <>
  end
  object pnlBotao: TPanel
    Left = 0
    Top = 198
    Width = 397
    Height = 44
    Align = alBottom
    TabOrder = 1
    object gauProgresso: TGauge
      Left = 98
      Top = 10
      Width = 212
      Height = 25
      Progress = 0
    end
    object btnSair: TBitBtn
      Left = 316
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Sair'
      TabOrder = 0
      OnClick = btnSairClick
    end
    object btnExecel: TBitBtn
      Left = 6
      Top = 10
      Width = 86
      Height = 25
      Caption = 'Gerar Planilha'
      TabOrder = 1
      OnClick = btnExecelClick
    end
  end
  object pnlCorpo: TPanel
    Left = 0
    Top = 0
    Width = 397
    Height = 198
    Align = alClient
    TabOrder = 0
    object lblLink: TLabel
      Left = 6
      Top = 7
      Width = 86
      Height = 13
      Caption = 'Link para Request'
    end
    object lblStatus: TLabel
      Left = 6
      Top = 167
      Width = 127
      Height = 13
      Caption = 'Status Request: Pendente'
    end
    object lblAuth: TLabel
      Left = 6
      Top = 53
      Width = 64
      Height = 13
      Caption = 'Authorization'
    end
    object edtLink: TEdit
      Left = 6
      Top = 26
      Width = 385
      Height = 21
      TabOrder = 0
    end
    object btnRequest: TBitBtn
      Left = 316
      Top = 167
      Width = 75
      Height = 25
      Caption = 'Request'
      TabOrder = 1
      OnClick = btnRequestClick
    end
    object menAuth: TMemo
      Left = 6
      Top = 72
      Width = 385
      Height = 89
      Lines.Strings = (
        'menAuth')
      TabOrder = 2
    end
  end
end
