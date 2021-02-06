program ServidorSite;
{$ifdef DEBUG}
{$APPTYPE CONSOLE}
{$endif}




{$R *.dres}

uses
  Vcl.SvcMgr,
  MidasLib,
  System.SysUtils,
  uLogArquivo in 'uLogArquivo.pas',
  usvcServidorSite in 'usvcServidorSite.pas' {svcServidorSite: TService},
  uDM in 'uDM.pas' {DM: TDataModule},
  uRotas in 'uRotas.pas',
  Rotas.Bancos in 'Rotas\Rotas.Bancos.pas',
  uFuncoes in 'uFuncoes.pas';

{$R *.RES}

var bIniciou: Boolean;

begin
{$IFDEF DEBUG}
    try
        // In debug mode the server acts as a console application.
        WriteLn('MyServiceApp DEBUG mode. Press enter to exit.');

        // Create the TService descendant manually.
        bIniciou := True;
        svcServidorSite := TsvcServidorSite.Create(nil);

        svcServidorSite.ServiceStart(svcServidorSite, bIniciou);
        // Simulate service start.
        svcServidorSite.ServiceExecute(svcServidorSite);

        // Keep the console box running (ServerContainer1 code runs in the background)
        ReadLn;

        // On exit, destroy the service object.
        FreeAndNil(svcServidorSite);
    except
        on E: Exception do
        begin
            WriteLn(E.ClassName, ': ', E.Message);
            WriteLn('Press enter to exit.');
            ReadLn;
        end;
    end;
{$ELSE}
    if not Application.DelayInitialize or Application.Installing then
        Application.Initialize;
    Application.CreateForm(TsvcServidorSite, svcServidorSite);
    Application.Run;
{$ENDIF}

end.
