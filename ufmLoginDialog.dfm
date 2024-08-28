object fmLoginDialog: TfmLoginDialog
  Left = 1017
  Top = 184
  BorderStyle = bsDialog
  Caption = 'Login to database'
  ClientHeight = 321
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object paButtons: TPanel
    Left = 0
    Top = 281
    Width = 330
    Height = 40
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      330
      40)
    object btExit: TButton
      Left = 202
      Top = 8
      Width = 109
      Height = 22
      Hint = 'Close this dialog without connect'
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Exit'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btExitClick
    end
    object btConnect: TButton
      Left = 87
      Top = 8
      Width = 109
      Height = 22
      Hint = 'Connect using these settings'
      Anchors = [akTop, akRight]
      Caption = 'Connect'
      Default = True
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btConnectClick
    end
  end
  object gbConnection: TGroupBox
    Left = 0
    Top = 0
    Width = 330
    Height = 145
    Align = alTop
    Caption = 'Connection'
    TabOrder = 0
    DesignSize = (
      330
      145)
    object Label1: TLabel
      Left = 8
      Top = 67
      Width = 50
      Height = 13
      Caption = 'Database:'
    end
    object btDBPath: TSpeedButton
      Left = 302
      Top = 64
      Width = 23
      Height = 21
      Hint = 'Select the file'
      Anchors = [akTop, akRight]
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      OnClick = btDBPathClick
    end
    object Label6: TLabel
      Left = 8
      Top = 115
      Width = 37
      Height = 13
      Caption = 'Library:'
    end
    object sbSelectLibrary: TSpeedButton
      Left = 302
      Top = 112
      Width = 23
      Height = 21
      Hint = 'Select the file'
      Anchors = [akTop, akRight]
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      OnClick = sbSelectLibraryClick
    end
    object edLibrary: TEdit
      Left = 63
      Top = 112
      Width = 234
      Height = 21
      Hint = 'Client libraray that provides the access to the database server'
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'fbclient.dll'
    end
    object gbServer: TGroupBox
      Left = 8
      Top = 17
      Width = 313
      Height = 41
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      DesignSize = (
        313
        41)
      object laServer: TLabel
        Left = 8
        Top = 12
        Width = 36
        Height = 13
        Caption = 'Server:'
      end
      object laPort: TLabel
        Left = 213
        Top = 12
        Width = 24
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Port:'
      end
      object edServerName: TEdit
        Left = 46
        Top = 9
        Width = 161
        Height = 21
        Hint = 'Database server'
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '127.0.0.1'
      end
      object edPort: TEdit
        Left = 240
        Top = 9
        Width = 63
        Height = 21
        Hint = 'Port of the database server'
        Anchors = [akTop, akRight]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '3050'
        OnKeyPress = edPortKeyPress
      end
    end
    object cbAlias: TCheckBox
      Left = 64
      Top = 86
      Width = 232
      Height = 17
      Hint = 'Treat the database filename as an alias'
      Caption = 'This is an alias for database'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 1
      OnClick = cbAliasClick
    end
    object cbDBFilePath: TComboBox
      Left = 64
      Top = 64
      Width = 232
      Height = 21
      Hint = 'File of the database'
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = 'crypt'
      OnChange = cbDBFilePathChange
    end
  end
  object gbDBParameters: TGroupBox
    Left = 0
    Top = 145
    Width = 184
    Height = 136
    Align = alClient
    Caption = 'Login'
    TabOrder = 1
    DesignSize = (
      184
      136)
    object laPassword: TLabel
      Left = 116
      Top = 49
      Width = 50
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Password:'
    end
    object laUserName: TLabel
      Left = 111
      Top = 7
      Width = 55
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'User name:'
    end
    object laMoreLess: TLabel
      Left = 2
      Top = 121
      Width = 180
      Height = 13
      Cursor = crHandPoint
      Hint = 'Show or hide additional parameters'
      Align = alBottom
      Alignment = taRightJustify
      Caption = 'less params...'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = laMoreLessClick
      ExplicitLeft = 114
      ExplicitWidth = 68
    end
    object edUserName: TEdit
      Left = 16
      Top = 22
      Width = 150
      Height = 21
      Hint = 'Login username'
      Anchors = [akLeft, akTop, akRight]
      CharCase = ecUpperCase
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = 'SYSDBA'
    end
    object edPassword: TEdit
      Left = 16
      Top = 63
      Width = 150
      Height = 21
      Hint = 'Login password'
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      PasswordChar = '*'
      ShowHint = True
      TabOrder = 1
      Text = 'masterkey'
    end
    object cbShowPassword: TCheckBox
      Left = 16
      Top = 87
      Width = 97
      Height = 17
      Hint = 'Show/hide the password'
      Caption = 'Show password'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = cbShowPasswordClick
    end
  end
  object gbAdditional: TGroupBox
    Left = 184
    Top = 145
    Width = 146
    Height = 136
    Align = alRight
    Caption = 'Optional params'
    TabOrder = 2
    object Label2: TLabel
      Left = 57
      Top = 48
      Width = 78
      Height = 13
      Caption = 'Default charset:'
    end
    object Label5: TLabel
      Left = 75
      Top = 90
      Width = 58
      Height = 13
      Caption = 'SQL Dialect:'
    end
    object laRole: TLabel
      Left = 108
      Top = 9
      Width = 25
      Height = 13
      Caption = 'Role:'
    end
    object cbSQLDialect: TComboBox
      Left = 64
      Top = 104
      Width = 69
      Height = 21
      Hint = 'Access using this SQL dialect'
      Style = csDropDownList
      ItemIndex = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '3'
      Items.Strings = (
        '1'
        '3')
    end
    object cbCharacterSet: TComboBox
      Left = 9
      Top = 63
      Width = 126
      Height = 21
      Hint = 'Access charset'
      DropDownCount = 15
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = 'ASCII'
      Items.Strings = (
        'ASCII'
        'BIG_5'
        'CYRL'
        'DOS437'
        'DOS850'
        'DOS852'
        'DOS857'
        'DOS860'
        'DOS861'
        'DOS863'
        'DOS865'
        'EUCJ_0208'
        'GB_2312'
        'ISO8859_1'
        'KSC_5601'
        'NEXT'
        'NONE'
        'OCTETS'
        'SJIS_0208'
        'UNICODE_FSS'
        'WIN1250'
        'WIN1251'
        'WIN1252'
        'WIN1253'
        'WIN1254')
    end
    object edRole: TEdit
      Left = 9
      Top = 23
      Width = 124
      Height = 21
      Hint = 'Role to access database'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
end
