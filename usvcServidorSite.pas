unit usvcServidorSite;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.SvcMgr, System.Win.Registry,
    Horse, Horse.CORS, Horse.Jhonson, Horse.OctetStream, Horse.HandleException, Horse.Commons,
    Horse.Provider.Console;

type
    TsvcServidorSite = class(TService)
        procedure ServiceAfterInstall(Sender: TService);
        procedure ServiceExecute(Sender: TService);
        procedure ServiceStart(Sender: TService; var Started: Boolean);
        procedure ServiceStop(Sender: TService; var Stopped: Boolean);
        procedure ServiceCreate(Sender: TObject);
        procedure ServiceShutdown(Sender: TService);
    private
        { Private declarations }

    public
        { Public declarations }
        function GetServiceController: TServiceController; override;
    end;

var
    svcServidorSite: TsvcServidorSite;

implementation

{$R *.dfm}


uses uRotas;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
    svcServidorSite.Controller(CtrlCode);
end;

function TsvcServidorSite.GetServiceController: TServiceController;
begin
    Result := ServiceController;
end;

procedure TsvcServidorSite.ServiceAfterInstall(Sender: TService);
var
    regEdit: TRegistry;
begin
    regEdit := TRegistry.Create(KEY_READ or KEY_WRITE);
    try
        regEdit.RootKey := HKEY_LOCAL_MACHINE;
        if regEdit.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, False) then
        begin
            regEdit.WriteString('Description',
                'Serviço responsável pelo envio de dados.');
            regEdit.CloseKey;
        end;
    finally
        FreeAndNil(regEdit);
    end;
end;

procedure TsvcServidorSite.ServiceCreate(Sender: TObject);
var
    sAux: String;

begin
    THorse.Use(CORS);
    THorse.Use(Jhonson);
    THorse.Use(OctetStream);
    THorse.Use(HandleException);

    THorse.Get('/ping', GetPing);
    THorse.Get('/pdf', GetPDF);
end;

procedure TsvcServidorSite.ServiceExecute(Sender: TService);
var
    sAux: String;
begin
    if IsConsole then
        Exit;

    try
        while not Terminated do
        begin

            { "Dorme" 1.5 segundos, para não sobrecarregar o processamento.
              Somente 1.5 seg para não dar problema caso queira parar o serviço }
            Sleep(1500);
{$IFNDEF DEBUG}
            ServiceThread.ProcessRequests(False);
{$ENDIF}
        end;
    finally
        // Log.Info('Finalizando o serviço');
    end;
end;

procedure TsvcServidorSite.ServiceShutdown(Sender: TService);
begin
    // Log.Info('ServiceShutdown');
end;

procedure TsvcServidorSite.ServiceStart(Sender: TService; var Started: Boolean);
begin
    THorse.Listen(9000,
        procedure(Horse: THorse)
        begin
            if IsConsole then
                Writeln(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]));

        end);
end;

procedure TsvcServidorSite.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
    THorse.StopListen;
end;

end.
