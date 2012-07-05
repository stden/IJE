object Form1: TForm1
  Left = 271
  Top = 113
  Width = 696
  Height = 556
  Caption = 'problem.xml editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 688
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 81
      Height = 13
      AutoSize = False
      Caption = 'Id'
    end
    object Label2: TLabel
      Left = 16
      Top = 48
      Width = 89
      Height = 13
      AutoSize = False
      Caption = #1053#1072#1079#1074#1072#1085#1080#1077
    end
    object edId: TEdit
      Left = 80
      Top = 8
      Width = 385
      Height = 21
      TabOrder = 0
    end
    object edName: TEdit
      Left = 80
      Top = 40
      Width = 385
      Height = 21
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 73
    Width = 688
    Height = 420
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 5
      Top = 5
      Width = 678
      Height = 410
      Align = alClient
      Caption = ' Testset '
      TabOrder = 0
      object Panel3: TPanel
        Left = 2
        Top = 15
        Width = 674
        Height = 226
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label8: TLabel
          Left = 16
          Top = 173
          Width = 57
          Height = 13
          AutoSize = False
          Caption = 'ML'
        end
        object Label7: TLabel
          Left = 16
          Top = 144
          Width = 57
          Height = 13
          AutoSize = False
          Caption = 'TL'
        end
        object Label6: TLabel
          Left = 16
          Top = 112
          Width = 57
          Height = 13
          AutoSize = False
          Caption = 'Answer-href'
        end
        object Label5: TLabel
          Left = 16
          Top = 80
          Width = 57
          Height = 13
          AutoSize = False
          Caption = 'Input-href'
        end
        object Label4: TLabel
          Left = 16
          Top = 48
          Width = 65
          Height = 13
          AutoSize = False
          Caption = 'Output-name'
        end
        object Label3: TLabel
          Left = 16
          Top = 16
          Width = 57
          Height = 13
          AutoSize = False
          Caption = 'Input-name'
        end
        object Label12: TLabel
          Left = 16
          Top = 200
          Width = 65
          Height = 17
          AutoSize = False
          Caption = 'Script-type'
        end
        object edTL: TEdit
          Left = 88
          Top = 136
          Width = 177
          Height = 21
          TabOrder = 4
        end
        object edOutputName: TEdit
          Left = 88
          Top = 40
          Width = 177
          Height = 21
          TabOrder = 1
        end
        object edML: TEdit
          Left = 88
          Top = 165
          Width = 177
          Height = 21
          TabOrder = 5
        end
        object edInputName: TEdit
          Left = 88
          Top = 8
          Width = 177
          Height = 21
          TabOrder = 0
        end
        object edInputHref: TEdit
          Left = 88
          Top = 72
          Width = 177
          Height = 21
          TabOrder = 2
        end
        object edAnswerHref: TEdit
          Left = 88
          Top = 104
          Width = 177
          Height = 21
          TabOrder = 3
        end
        object edScriptType: TEdit
          Left = 88
          Top = 197
          Width = 177
          Height = 21
          TabOrder = 6
          Text = '%ioi'
        end
      end
      object Panel4: TPanel
        Left = 2
        Top = 241
        Width = 674
        Height = 167
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 1
        OnResize = Panel4Resize
        object gbTests: TGroupBox
          Left = 5
          Top = 5
          Width = 664
          Height = 157
          Align = alClient
          Caption = ' Tests '
          TabOrder = 0
          object Label9: TLabel
            Left = 16
            Top = 24
            Width = 59
            Height = 13
            Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086
          end
          object Label10: TLabel
            Left = 16
            Top = 48
            Width = 84
            Height = 13
            Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1090#1077#1089#1090#1099':'
          end
          object Label11: TLabel
            Left = 544
            Top = 24
            Width = 33
            Height = 13
            Caption = #1048#1090#1086#1075#1086':'
          end
          object edNTests: TSpinEdit
            Left = 96
            Top = 16
            Width = 49
            Height = 22
            MaxValue = 100
            MinValue = 1
            TabOrder = 0
            Value = 1
            OnChange = edNTestsChange
          end
          object edTotal: TStaticText
            Left = 592
            Top = 16
            Width = 65
            Height = 21
            AutoSize = False
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = sbsSunken
            TabOrder = 1
          end
        end
      end
    end
  end
  object Panel5: TPanel
    Left = 0
    Top = 493
    Width = 688
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    OnResize = Panel5Resize
    object btSave: TButton
      Left = 584
      Top = 0
      Width = 89
      Height = 25
      Caption = 'Save'
      TabOrder = 1
      OnClick = btSaveClick
    end
    object btLoad: TButton
      Left = 480
      Top = 0
      Width = 89
      Height = 25
      Caption = 'Load'
      TabOrder = 0
      OnClick = btLoadClick
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xml'
    Filter = 
      'problem.xml|problem.xml|XML files (*.xml)|*.xml|All files (*.*)|' +
      '*.*'
    Left = 472
    Top = 48
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xml'
    Filter = 
      'problem.xml|problem.xml|XML files (*.xml)|*.xml|All files (*.*)|' +
      '*.*'
    Left = 520
    Top = 48
  end
  object ApplicationEvents1: TApplicationEvents
    OnShortCut = ApplicationEvents1ShortCut
    Left = 568
    Top = 48
  end
end
