object Form1: TForm1
  Left = 192
  Top = 109
  Width = 741
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StaticText1: TStaticText
    Left = 120
    Top = 80
    Width = 4
    Height = 4
    TabOrder = 0
  end
  object output: TMemo
    Left = 0
    Top = 0
    Width = 733
    Height = 424
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 424
    Width = 733
    Height = 27
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      733
      27)
    object Button1: TButton
      Left = 637
      Top = 2
      Width = 97
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Font'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMinimize = ApplicationEvents1Minimize
    Left = 240
    Top = 96
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 448
    Top = 64
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 392
    Top = 144
  end
end
