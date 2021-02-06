unit usvcServidorSite;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.SvcMgr, System.Win.Registry, Horse, Horse.CORS,
    Horse.Jhonson, Horse.OctetStream, Horse.HandleException, Horse.Commons, Horse.Provider.Console, uLogArquivo,
    Firedac.Stan.Option, Firedac.Stan.Error, Firedac.UI.Intf, Firedac.Phys.Intf, Firedac.Stan.Def, Firedac.Stan.Pool,
    Firedac.Stan.Async, Firedac.Phys, Firedac.Stan.Param, Firedac.DatS, Firedac.DApt.Intf, Firedac.DApt,
    Firedac.Comp.DataSet, Firedac.Comp.Client, Firedac.Stan.Intf, Firedac.Stan.ExprFuncs, Firedac.Phys.SQLiteDef,
    Firedac.Phys.SQLite;

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
        FDManager: TFDManager;
    public
        { Public declarations }
        function GetServiceController: TServiceController; override;
    end;

var
    svcServidorSite: TsvcServidorSite;

implementation

{$R *.dfm}


uses uRotas, Rotas.Bancos, uFuncoes;

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
    Log.Info('Gerando as informações de registro do serviço.');
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
    oDef: IFDStanConnectionDef;
    oPars: TFDPhysSQLiteConnectionDefParams;
begin
    Log.Info('ServiceCreate');

    FDManager := TFDManager.Create(nil);

    oDef := FDManager.ConnectionDefs.AddConnectionDef;
    oDef.Name := 'PRINCIPAL';
    oPars := TFDPhysSQLiteConnectionDefParams(oDef.Params);
    oPars.DriverID := 'SQLite';
    oPars.Database := LerIni('CONFIGURACAO', 'BANCODADOS');
    oPars.Pooled := True;
    FDManager.Active := True;

    THorse.Use(CORS);
    THorse.Use(Jhonson);
    THorse.Use(OctetStream);
    THorse.Use(HandleException);

    THorse
        .Get('/ping', GetPing)
        .Get('/pdf', GetPDF)
        .Get('/bancos', Bancos_Get)
        .Get('/bancos/:id', Bancos_Get);
end;

procedure TsvcServidorSite.ServiceExecute(Sender: TService);
var
    sAux: String;
    I: Integer;
begin
    if IsConsole then
        Exit;
    Log.Info('Iniciando o serviço');
    I := 0;
    try
        while not Terminated do
        begin
            { "Dorme" 1.5 segundos, para não sobrecarregar o processamento.
              Somente 1.5 seg para não dar problema caso queira parar o serviço }
            Sleep(1500);
{$IFNDEF DEBUG}
            ServiceThread.ProcessRequests(False);
            Inc(I);
{$ENDIF}
        end;
    finally
        Log.Info('Finalizando o serviço');
    end;
end;

procedure TsvcServidorSite.ServiceShutdown(Sender: TService);
begin
    Log.Info('ServiceShutdown');
end;

procedure TsvcServidorSite.ServiceStart(Sender: TService; var Started: Boolean);
begin
    FDManager.Active := True;

    THorse.Listen(9000,
        procedure(Horse: THorse)
        begin
            if IsConsole then
                Writeln(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]))
            else
                Log.Info(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]));
        end);
end;

procedure TsvcServidorSite.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
    Log.Info('Parando o serviço.');
    THorse.StopListen;
end;

end.
