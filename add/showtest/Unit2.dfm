object Form2: TForm2
  Left = 192
  Top = 112
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'IJE ShowTest'
  ClientHeight = 105
  ClientWidth = 305
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 241
    Height = 57
    AutoSize = False
    Caption = 'Some files were found in the '#39'Archive'#39' directory.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object btLoad: TButton
    Left = 16
    Top = 72
    Width = 81
    Height = 25
    Caption = 'Load'
    ModalResult = 6
    TabOrder = 0
  end
  object btDelete: TButton
    Left = 112
    Top = 72
    Width = 81
    Height = 25
    Caption = 'Delete'
    ModalResult = 7
    TabOrder = 1
  end
  object btIgnore: TButton
    Left = 208
    Top = 72
    Width = 81
    Height = 25
    Caption = 'Ignore'
    ModalResult = 5
    TabOrder = 2
  end
end
