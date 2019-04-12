object Form1: TForm1
  Left = 209
  Top = 145
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #28165#25195#23567#23627' - '#37921#21733#21046#20316
  ClientHeight = 284
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btn1: TButton
    Left = 288
    Top = 231
    Width = 113
    Height = 41
    Caption = #24320'  '#22987
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = btn1Click
  end
  object grp1: TGroupBox
    Left = 288
    Top = 10
    Width = 113
    Height = 153
    Caption = #35828#26126
    TabOrder = 1
    object lbl1: TLabel
      Left = 8
      Top = 24
      Width = 105
      Height = 137
      AutoSize = False
      Caption = 
        '1.'#28857#20987#26684#23376#25918#32622#13#10'   '#38556#30861#65292#30333#33394#26684#13#10'   '#23376#21487#20197#33258#30001#36890#13#10'   '#34892#65292#32418#33394#26684#23376#13#10'   '#20195#34920#26377#38556#30861#13#10#13#10'2.'#28165#25195#36335#32447#32534#21495#13 +
        #10'   '#20174'1'#12289'2'#12289'3'#20381#27425#13#10'   '#24320#22987
      Transparent = True
      WordWrap = True
    end
  end
  object strngrd1: TStringGrid
    Left = 12
    Top = 14
    Width = 260
    Height = 260
    DefaultColWidth = 50
    DefaultRowHeight = 50
    FixedCols = 0
    FixedRows = 0
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 2
    OnClick = strngrd1Click
    OnDrawCell = strngrd1DrawCell
  end
  object btn2: TButton
    Left = 288
    Top = 182
    Width = 113
    Height = 41
    Caption = #37325'  '#32622
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = btn2Click
  end
  object mmo1: TMemo
    Left = 16
    Top = 296
    Width = 385
    Height = 153
    Lines.Strings = (
      'mmo1')
    ScrollBars = ssVertical
    TabOrder = 4
    Visible = False
  end
end
