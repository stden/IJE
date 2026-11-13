object Form1: TForm1
  Left = 226
  Top = 194
  BorderStyle = bsNone
  Caption = 'IJE ShowTest'
  ClientHeight = 479
  ClientWidth = 711
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000000
    000AAA00000000000000000000000000000AAAA0000000000000000000000000
    000AAAAA00000000000000000000000000AAAAAA000000000000000000000000
    00AAAAAA0000000000000000000000000AAAAAAAA00000000000000000000000
    0AAAA0AAA00000000000000000000000AAAA00AAAA0000000000000000000000
    AAAA000AAAA00000000000000000000AAAAA0000AAA0000000000000000000AA
    AAA00000AAAA000000000000000000AAAA0000000AAA0000000000000000000A
    A000000000AAA00000000000000000000000000000AAAA000000000000000000
    00000000000AAAA00000000000000000000000000000AAA00000000000000000
    0000000000000AAA000000000000000000000000000000AAA000000000000000
    000000000000000AAA000000000000000000000000000000AAA0000000000000
    00000000000000000AAA000000000000000000000000000000AAA00000000000
    0000000000000000000AAA000000000000000000000000000000AAA000000000
    000000000000000000000AAA000000000000000000000000000000AAA0000000
    000000000000000000000000AA0000000000000000000000000000000A000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FFFFFFFFFFFFFE3FFFFFFE1FFFFFFE0FFFFFFC0FFFFFFC0FFFFFF807FFFFF847
    FFFFF0C3FFFFF0E1FFFFE0F1FFFFC1F0FFFFC3F8FFFFE7FC7FFFFFFC3FFFFFFE
    1FFFFFFF1FFFFFFF8FFFFFFFC7FFFFFFE3FFFFFFF1FFFFFFF8FFFFFFFC7FFFFF
    FE3FFFFFFF1FFFFFFF8FFFFFFFC7FFFFFFF3FFFFFFFBFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 710
    Height = 483
    ActivePage = TestSheet
    MultiLine = True
    OwnerDraw = True
    TabOrder = 0
    TabPosition = tpBottom
    OnDrawTab = PageControl1DrawTab
    object TestSheet: TTabSheet
      Caption = 'Testing'
      OnShow = TestSheetShow
      object Bevel1: TBevel
        Left = 0
        Top = 379
        Width = 702
        Height = 3
        Align = alBottom
        Shape = bsTopLine
      end
      object Grid: TDrawGrid
        Left = 0
        Top = 0
        Width = 702
        Height = 379
        Align = alClient
        BorderStyle = bsNone
        ColCount = 1
        DefaultColWidth = 10
        DefaultRowHeight = 18
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [goThumbTracking]
        ParentFont = False
        TabOrder = 0
        OnDrawCell = GridDrawCell
      end
      object Panel1: TPanel
        Left = 0
        Top = 382
        Width = 702
        Height = 75
        Align = alBottom
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 1
        object LogoBox: TImage
          Left = 600
          Top = 0
          Width = 77
          Height = 49
          Stretch = True
        end
        object Legend: TDrawGrid
          Left = 0
          Top = 0
          Width = 575
          Height = 75
          BorderStyle = bsNone
          ColCount = 3
          DefaultColWidth = 171
          DefaultRowHeight = 18
          DefaultDrawing = False
          FixedCols = 0
          RowCount = 4
          FixedRows = 0
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          Options = [goThumbTracking]
          ParentFont = False
          TabOrder = 0
          OnDrawCell = LegendDrawCell
        end
      end
    end
    object TotalSheet: TTabSheet
      Caption = 'Total'
      ImageIndex = 1
      OnShow = TotalSheetShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object TotalGrid: TDrawGrid
        Left = 0
        Top = 0
        Width = 702
        Height = 457
        Align = alClient
        BorderStyle = bsNone
        ColCount = 1
        DefaultColWidth = 10
        DefaultRowHeight = 18
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Options = [goThumbTracking]
        ParentFont = False
        TabOrder = 0
        OnDrawCell = TotalGridDrawCell
      end
    end
  end
  object AutoSwitch: TCheckBox
    Left = 584
    Top = 464
    Width = 121
    Height = 17
    Alignment = taLeftJustify
    Caption = #1040#1074#1090#1086' '#1087#1077#1088#1077#1082#1083#1102#1095#1077#1085#1080#1077
    TabOrder = 1
    OnClick = AutoSwitchClick
  end
  object ClearTable: TButton
    Left = 448
    Top = 464
    Width = 121
    Height = 17
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1090#1072#1073#1083#1080#1094#1091
    TabOrder = 2
    OnClick = ClearTableClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 120
    Top = 32
  end
  object ShowTestingTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = ShowTestingTimerTimer
    Left = 184
    Top = 40
  end
  object ShowTotalTimer: TTimer
    Enabled = False
    OnTimer = ShowTotalTimerTimer
    Left = 248
    Top = 40
  end
  object fpstimer: TTimer
    Interval = 2000
    OnTimer = fpstimerTimer
    Left = 384
    Top = 48
  end
end
