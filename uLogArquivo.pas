unit uLogArquivo;

interface

uses SysUtils, Classes, Windows;

type
    TTipoLog = (tlcInformation, tlcError, tlcWarning, tlcDebug);

    ILogArquivo = interface
        ['{23E1C114-AFAC-4CC3-B5FB-8248459C31CE}']
        function NomeArquivo: String;
        procedure Info(ATexto: String);
        procedure Erro(ATexto: String);
        procedure Warn(ATexto: String);
        procedure Debug(ATexto: String);
    end;

    TLogArquivo = class(TInterfacedObject, ILogArquivo)
    private
        FFileName: String;
        // FStreamWriter: TStreamWriter;
        FSeq: SmallInt;
        procedure DoLog(ATexto: String; ATipoLog: TTipoLog);
        procedure SetFileName;
        function GetSizeOfFile(FileName: string): Int64;
    public
        constructor Create;
        function NomeArquivo: String;
        procedure Info(ATexto: String);
        procedure Erro(ATexto: String);
        procedure Warn(ATexto: String);
        procedure Debug(ATexto: String);
    end;

const
    K = Int64(1024);
    M = K * K;
    G = K * M;
    T = K * G;

var
    LOGCriticalSection: TRTLCriticalSection;

function Log: ILogArquivo;

implementation

var
    _Log: ILogArquivo;

function Log: ILogArquivo;
begin
    Result := _Log;
end;

{ TLogArquivo }

procedure TLogArquivo.SetFileName;
var
    FileSize: Int64;
begin
    if Trim(FFileName) = '' then
    begin
        // Verificando se existe a pasta LOG, dentro da pasta que fica o .exe
        if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'LOG') then
            ForceDirectories(ExtractFilePath(ParamStr(0)) + 'LOG');

        FFileName := ExtractFilePath(ParamStr(0)) + 'LOG\' + ExtractFileName(ParamStr(0));
        FFileName := ChangeFileExt(FFileName, '.000.log');
        FSeq := 0;
    end;

    if FileExists(FFileName) then
    begin
        FileSize := GetSizeOfFile(FFileName);
        if FileSize > (M * 5) then
        begin
            Inc(FSeq);
            FFileName := ExtractFilePath(ParamStr(0)) + 'LOG\' + ExtractFileName(ParamStr(0));
            FFileName := ChangeFileExt(FFileName, '.' + FormatFloat('000', FSeq) + '.log');

            SetFileName;
        end;
    end;
end;

constructor TLogArquivo.Create;
begin
    inherited;
    SetFileName;
end;

procedure TLogArquivo.Debug(ATexto: String);
begin
    DoLog(ATexto, tlcDebug);
end;

procedure TLogArquivo.DoLog(ATexto: String; ATipoLog: TTipoLog);
const
    sTipoLog: array [0 .. 3] of string = ('INFO', 'ERROR', 'WARN', 'DEBUG');
var
    FStreamWriter: TStreamWriter;
begin
    EnterCriticalSection(LOGCriticalSection);
    FStreamWriter := nil;
    try
        try
            FStreamWriter := TStreamWriter.Create(FFileName, True, TEncoding.UTF8);
            FStreamWriter.WriteLine(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', now) + ' [' + Format('%-10.10s', [sTipoLog[Ord(ATipoLog)]]) + '] ' + ATexto);
        except
        end;
    finally
        FStreamWriter.Free;
        LeaveCriticalSection(LOGCriticalSection);
        SetFileName;
    end;
end;

procedure TLogArquivo.Erro(ATexto: String);
begin
    DoLog(ATexto, tlcError);
end;

procedure TLogArquivo.Info(ATexto: String);
begin
    DoLog(ATexto, tlcInformation);
end;

function TLogArquivo.NomeArquivo: String;
begin
    Result := FFileName;
end;

procedure TLogArquivo.Warn(ATexto: String);
begin
    DoLog(ATexto, tlcWarning);
end;

function TLogArquivo.GetSizeOfFile(FileName: string): Int64;
var
    Handle: Integer;
begin
    EnterCriticalSection(LOGCriticalSection);
    try
        Handle := FileOpen(FileName, fmOpenRead);
        Result := 0;
        if Handle <> -1 then
        begin
            try
                Result := FileSeek(Handle, Int64(0), 2);
            finally
                FileClose(Handle);
            end;
        end;
    finally
        LeaveCriticalSection(LOGCriticalSection);
    end;
end;

initialization

InitializeCriticalSection(LOGCriticalSection);
_Log := TLogArquivo.Create;

finalization

DeleteCriticalSection(LOGCriticalSection);

end.
