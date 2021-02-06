# horse-fastreport-pdf
Exemplo simples de geração de PDF com o Horse + Fast Report.
Gerado com Delphi 10.2 (Tokyo) e Fast Report 6.

Neste projeto também tem uso do FDManager para controle das
conexões com o banco de dados.

Se deixar o "Build Configuration" como DEBUG, o sistema irá rodar
como se fosse uma aplicação CONSOLE.
Quando muda para RELEASE, é gerado o .EXE que pode ser instalado
normalmente no Windows como um serviço.

Para instalar nos serviços do Windows, abra o prompt de comando
como administrador. Navegue até o local onde está salvo o arquivo
.EXE e digite:
ServidorSite -install

Após isso, se abrir o gerenciador de serviços do Windows, o mesmo
já estará na lista.
