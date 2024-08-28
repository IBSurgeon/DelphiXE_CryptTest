object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Test for connection to encrypted database'
  ClientHeight = 652
  ClientWidth = 759
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    759
    652)
  PixelsPerInch = 96
  TextHeight = 13
  object btExecuteQuery: TButton
    Left = 24
    Top = 407
    Width = 719
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Execute Query....'
    TabOrder = 11
    OnClick = btExecuteQueryClick
  end
  object btSetup: TButton
    Left = 24
    Top = 8
    Width = 105
    Height = 25
    Caption = '1. SETUP!!!!'
    TabOrder = 0
    OnClick = btSetupClick
  end
  object edServerAndDB: TEdit
    Left = 135
    Top = 8
    Width = 608
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 1
  end
  object gbUseThisKey: TGroupBox
    Left = 24
    Top = 48
    Width = 719
    Height = 113
    Anchors = [akLeft, akTop, akRight]
    Caption = 
      'UseThisKey (rename or remove keyholder.conf from server plugin d' +
      'irectory, becouse it will overwrite/disable client keys if exist' +
      's)'
    TabOrder = 2
    DesignSize = (
      719
      113)
    object laKeyName: TLabel
      Left = 24
      Top = 24
      Width = 52
      Height = 13
      Caption = 'Key Name:'
    end
    object laKeyValue: TLabel
      Left = 25
      Top = 51
      Width = 51
      Height = 13
      Caption = 'Key Value:'
    end
    object edKeyName: TEdit
      Left = 82
      Top = 21
      Width = 431
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'Zero'
    end
    object edKeyValue: TEdit
      Left = 82
      Top = 48
      Width = 625
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 
        '0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30' +
        ',0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x3' +
        '0,0x30,0x30,0x30,0x30,0x30,0x30,'
    end
    object btApplyKey: TButton
      Left = 546
      Top = 17
      Width = 163
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '2. Apply Key'
      TabOrder = 2
      OnClick = btApplyKeyClick
    end
    object btEncryptDatabase: TButton
      Left = 95
      Top = 75
      Width = 233
      Height = 25
      Caption = '2(a) Encrypt Database'
      TabOrder = 3
      OnClick = btEncryptDatabaseClick
    end
    object btDecryptDatabase: TButton
      Left = 334
      Top = 75
      Width = 233
      Height = 25
      Caption = '2(b) Decrypt Database'
      TabOrder = 4
      OnClick = btDecryptDatabaseClick
    end
  end
  object mResult: TMemo
    Left = 0
    Top = 438
    Width = 759
    Height = 214
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 12
  end
  object meSelectToTest: TMemo
    Left = 24
    Top = 310
    Width = 719
    Height = 91
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'select * from RDB$RELATIONS')
    TabOrder = 6
  end
  object btDisconnect: TButton
    Left = 438
    Top = 167
    Width = 305
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Disconnect'
    TabOrder = 4
    OnClick = btDisconnectClick
  end
  object btConnect: TButton
    Left = 24
    Top = 167
    Width = 304
    Height = 25
    Caption = 'Connect'
    TabOrder = 3
    OnClick = btConnectClick
  end
  object meTransaction: TMemo
    Left = 24
    Top = 215
    Width = 513
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    Lines.Strings = (
      'read'
      'read_committed'
      'rec_version'
      'nowait')
    TabOrder = 5
  end
  object btStart: TButton
    Left = 570
    Top = 213
    Width = 137
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Start'
    TabOrder = 7
    OnClick = btStartClick
  end
  object btRollback: TButton
    Left = 543
    Top = 244
    Width = 97
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Rollback'
    TabOrder = 8
    OnClick = btRollbackClick
  end
  object btCommit: TButton
    Left = 570
    Top = 275
    Width = 137
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Commit'
    TabOrder = 10
    OnClick = btCommitClick
  end
  object btRollbackRet: TButton
    Left = 646
    Top = 244
    Width = 97
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Rollback Ret'
    TabOrder = 9
    OnClick = btRollbackRetClick
  end
end
