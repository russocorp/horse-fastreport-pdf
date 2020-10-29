object svcServidorSite: TsvcServidorSite
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'Servi'#231'o API de Recebimentos'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 299
  Width = 605
end
