unit uDM;

interface

uses
    System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient, frxClass, frxDBSet, frxExportBaseDialog, frxExportPDF;

type
    TDM = class(TDataModule)
        CDS: TClientDataSet;
        CDSCodigo: TIntegerField;
        CDSNome: TStringField;
    frxReport1: TfrxReport;
    frxPDFExport1: TfrxPDFExport;
    frxds_Mestre: TfrxDBDataset;
    private
        { Private declarations }
    public
        { Public declarations }
        procedure CriarDados;
        function GUIDToString2(const Guid: TGUID): string;
    end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDM }

{ TDM }

procedure TDM.CriarDados;
var
    I: Integer;
begin
    CDS.Close;
    CDS.CreateDataSet;

    for I := 1 to 50 do
    begin
        CDS.Append;
        CDSCodigo.AsInteger := I;
        CDSNome.AsString := 'Nome de Teste ' + I.ToString;
        CDS.Post;
    end;
end;

function TDM.GUIDToString2(const Guid: TGUID): string;
begin
    SetLength(Result, 36);
    StrLFmt(PChar(Result), 36, '%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x',
        [Guid.d1, Guid.d2, Guid.D3, Guid.D4[0], Guid.D4[1], Guid.D4[2], Guid.D4[3],
        Guid.D4[4], Guid.D4[5], Guid.D4[6], Guid.D4[7]]);
end;

end.
