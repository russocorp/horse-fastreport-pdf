object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 339
  Width = 641
  object CDS: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 156
    Top = 147
    object CDSCodigo: TIntegerField
      FieldName = 'Codigo'
    end
    object CDSNome: TStringField
      FieldName = 'Nome'
      Size = 40
    end
  end
  object frxReport1: TfrxReport
    Version = '6.6.15'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick, pbCopy, pbSelection]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Padr'#227'o'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 44019.552763171300000000
    ReportOptions.LastChange = 44019.556719756950000000
    ScriptLanguage = 'PascalScript'
    ShowProgress = False
    StoreInDFM = False
    Left = 332
    Top = 36
  end
  object frxPDFExport1: TfrxPDFExport
    ShowDialog = False
    UseFileCache = False
    ShowProgress = False
    OverwritePrompt = False
    DataOnly = False
    EmbedFontsIfProtected = False
    OpenAfterExport = False
    PrintOptimized = False
    Outline = False
    Background = False
    HTMLTags = True
    Quality = 95
    Transparency = False
    Author = 'FastReport'
    Subject = 'FastReport PDF export'
    ProtectionFlags = [ePrint, eModify, eCopy, eAnnot]
    HideToolbar = False
    HideMenubar = False
    HideWindowUI = False
    FitWindow = False
    CenterWindow = False
    PrintScaling = False
    PdfA = False
    PDFStandard = psNone
    PDFVersion = pv17
    Left = 360
    Top = 36
  end
  object frxds_Mestre: TfrxDBDataset
    UserName = 'Mestre'
    CloseDataSource = False
    BCDToCurrency = False
    Left = 328
    Top = 80
  end
  object ConnBanco: TFDConnection
    Params.Strings = (
      'Database=D:\Rafael\github\horse-fastreport-pdf\servidorsite.db'
      'DriverID=SQLite')
    FormatOptions.AssignedValues = [fvDefaultParamDataType]
    ConnectedStoredUsage = [auDesignTime]
    LoginPrompt = False
    Left = 36
    Top = 30
  end
  object qrAux: TFDQuery
    Connection = ConnBanco
    Left = 30
    Top = 87
  end
  object qrBancos: TFDQuery
    Connection = ConnBanco
    SQL.Strings = (
      'select *'
      'from bancos')
    Left = 54
    Top = 207
    object qrBancosid: TStringField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      FixedChar = True
      Size = 3
    end
    object qrBancosnome: TStringField
      FieldName = 'nome'
      Origin = 'nome'
      Required = True
      Size = 100
    end
    object qrBancoscnpj: TStringField
      FieldName = 'cnpj'
      Origin = 'cnpj'
      Size = 30
    end
  end
end
