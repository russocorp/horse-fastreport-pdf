unit uRotas;

interface

uses Horse;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure GetPDF(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
    System.Classes, uDM, System.SysUtils;

procedure GetPing(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
    Res.Send('pong');
end;

procedure GetPDF(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    ADM: TDM;
    AStream: TResourceStream;
    sDirSistema: String;
    sNomeArquivo: String;
    ID: TGUID;
    FStream: TFileStream;
begin
    ADM := TDM.Create(nil);
    try
        ADM.CriarDados;

        try
            AStream := TResourceStream.Create(hInstance, 'RelTeste', 'IMPRESSAO');
            ADM.frxReport1.LoadFromStream(AStream);
        finally
            AStream.Free
        end;

        ADM.frxds_Mestre.DataSet := ADM.CDS;

        sDirSistema := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

        if not DirectoryExists(sDirSistema + 'Declaracao') then
            ForceDirectories(sDirSistema + 'Declaracao');

        CreateGUID(ID);

        sNomeArquivo := sDirSistema + 'Declaracao\' + ADM.GUIDToString2(ID) + '.pdf';

        ADM.frxPDFExport1.FileName := sNomeArquivo;

        ADM.frxReport1.PrepareReport();
        ADM.frxReport1.Export(ADM.frxPDFExport1);

        FStream := TFileStream.Create(sNomeArquivo, fmOpenRead);

        FStream.Position := 0;
        Res.Send(FStream);
    finally
        ADM.Free;
    end;
end;

end.
