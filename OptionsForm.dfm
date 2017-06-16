object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'BP v. 1.0 - opcje'
  ClientHeight = 186
  ClientWidth = 249
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Llang: TLabel
    Left = 24
    Top = 122
    Width = 27
    Height = 13
    Caption = 'J'#281'zyk'
  end
  object Gsort: TGroupBox
    Left = 8
    Top = 8
    Width = 233
    Height = 105
    Caption = 'Sortowanie'
    TabOrder = 0
    object Lmaxpriority: TLabel
      Left = 16
      Top = 24
      Width = 96
      Height = 13
      Caption = 'Najwy'#380'szy priorytet'
    end
    object Lminpriority: TLabel
      Left = 16
      Top = 51
      Width = 90
      Height = 13
      Caption = 'Najni'#380'szy priorytet'
    end
    object Lorder: TLabel
      Left = 16
      Top = 78
      Width = 45
      Height = 13
      Caption = 'Kolejno'#347#263
    end
    object Csort0: TComboBox
      AlignWithMargins = True
      Left = 118
      Top = 21
      Width = 107
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'Nazwisko'
      OnClick = Csort0Click
      OnKeyDown = FormKeyDown
      Items.Strings = (
        'Nazwisko'
        'Imi'#281
        'P'#322'aca brutto'
        'Rok zatrudnienia')
    end
    object Csort1: TComboBox
      Left = 118
      Top = 48
      Width = 107
      Height = 21
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 1
      Text = 'Imi'#281
      OnClick = Csort0Click
      OnKeyDown = FormKeyDown
      Items.Strings = (
        'Nazwisko'
        'Imi'#281
        'P'#322'aca brutto'
        'Rok zatrudnienia')
    end
    object Csort2: TComboBox
      Left = 118
      Top = 75
      Width = 107
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 2
      Text = 'Rosn'#261'co'
      OnClick = Csort0Click
      OnKeyDown = FormKeyDown
      Items.Strings = (
        'Rosn'#261'co'
        'Malej'#261'co')
    end
  end
  object Bok: TButton
    Left = 158
    Top = 153
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = BokClick
    OnKeyDown = FormKeyDown
  end
  object Clang: TComboBox
    Left = 126
    Top = 119
    Width = 107
    Height = 21
    Style = csDropDownList
    ItemIndex = 1
    TabOrder = 1
    Text = 'Polski'
    OnClick = ClangClick
    OnKeyDown = FormKeyDown
    Items.Strings = (
      'Angielski'
      'Polski')
  end
end
