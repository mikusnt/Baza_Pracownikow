object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'BP v. 1.0 - statystyka'
  ClientHeight = 197
  ClientWidth = 402
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
  PixelsPerInch = 96
  TextHeight = 13
  object GroupSurname: TGroupBox
    Left = 8
    Top = 8
    Width = 243
    Height = 81
    Caption = 'Nazwiska'
    TabOrder = 0
    object LMostSurname: TLabel
      Left = 8
      Top = 40
      Width = 129
      Height = 13
      Caption = 'Najcz'#281'stsza pierwsza litera'
    end
    object LFSSurname: TLabel
      Left = 8
      Top = 21
      Width = 126
      Height = 13
      Caption = 'Ilo'#347#263' zaczynaj'#261'cych si'#281' od'
    end
    object LsurnameV: TLabel
      Left = 162
      Top = 21
      Width = 4
      Height = 13
      Caption = '-'
      Color = clBtnFace
      ParentColor = False
      OnClick = LsurnameVClick
    end
    object LMostSurnameV: TLabel
      Left = 162
      Top = 40
      Width = 4
      Height = 13
      Caption = '-'
    end
    object ESurname: TEdit
      Left = 140
      Top = 18
      Width = 16
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 1
      ParentFont = False
      TabOrder = 0
      Text = 'A'
      OnKeyUp = ESurnameKeyUp
    end
  end
  object GroupForename: TGroupBox
    Left = 8
    Top = 95
    Width = 243
    Height = 66
    Caption = 'Imiona'
    TabOrder = 1
    object LMostForename: TLabel
      Left = 8
      Top = 40
      Width = 129
      Height = 13
      Caption = 'Najcz'#281'stsza pierwsza litera'
    end
    object LFSForename: TLabel
      Left = 8
      Top = 21
      Width = 126
      Height = 13
      Caption = 'Ilo'#347#263' zaczynaj'#261'cych si'#281' od'
    end
    object LforenameV: TLabel
      Left = 162
      Top = 21
      Width = 4
      Height = 13
      Caption = '-'
      OnClick = LforenameVClick
    end
    object LMostForenameV: TLabel
      Left = 162
      Top = 40
      Width = 4
      Height = 13
      Caption = '-'
    end
    object EForename: TEdit
      Left = 140
      Top = 18
      Width = 16
      Height = 21
      MaxLength = 1
      TabOrder = 0
      Text = 'A'
      OnKeyUp = EForenameKeyUp
    end
  end
  object GroupPay: TGroupBox
    Left = 257
    Top = 8
    Width = 138
    Height = 81
    Caption = 'P'#322'ace'
    TabOrder = 2
    object LMinPay: TLabel
      Left = 8
      Top = 22
      Width = 57
      Height = 13
      Caption = 'Najmniejsza'
    end
    object LMaxPay: TLabel
      Left = 8
      Top = 41
      Width = 53
      Height = 13
      Caption = 'Najwi'#281'ksza'
    end
    object LAveragePay: TLabel
      Left = 9
      Top = 60
      Width = 36
      Height = 13
      Caption = #346'rednia'
    end
    object LMinPayV: TLabel
      Left = 71
      Top = 21
      Width = 4
      Height = 13
      Caption = '-'
      OnClick = LMinPayVClick
    end
    object LMaxPayV: TLabel
      Left = 71
      Top = 40
      Width = 4
      Height = 13
      Caption = '-'
      OnClick = LMaxPayVClick
    end
    object LAveragePayV: TLabel
      Left = 72
      Top = 59
      Width = 4
      Height = 13
      Caption = '-'
    end
  end
  object GroupDate: TGroupBox
    Left = 257
    Top = 95
    Width = 138
    Height = 66
    Caption = 'Data zatrudnienia'
    TabOrder = 3
    object LFirstDate: TLabel
      Left = 8
      Top = 22
      Width = 42
      Height = 13
      Caption = 'Pierwsza'
    end
    object LLastDate: TLabel
      Left = 8
      Top = 41
      Width = 41
      Height = 13
      Caption = 'Ostatnia'
    end
    object LFirstDateV: TLabel
      Left = 71
      Top = 22
      Width = 4
      Height = 13
      Caption = '-'
      OnClick = LFirstDateVClick
    end
    object LLastDateV: TLabel
      Left = 71
      Top = 41
      Width = 4
      Height = 13
      Caption = '-'
      OnClick = LLastDateVClick
    end
  end
  object BClose: TButton
    Left = 319
    Top = 167
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = BCloseClick
  end
end
