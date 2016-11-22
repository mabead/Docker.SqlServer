FROM microsoft/windowsservercore:latest

COPY InstallSqlServer.ps1 SqlServerConfiguration.ini c:/SqlServerInstallation/

# Note that we don't copy the content of the SQL Server and Windows Server Core isos
# in the dockerfile through 'COPY' or 'ADD'. These instructions create new layers that 
# are a few GB big. Instead, these prerequisites are downloaded when InstallSqlServer.ps1
# is executed. This makes the final image smaller.

RUN powershell c:/SqlServerInstallation/InstallSqlServer.ps1 -SaPassword 'ENTER VALUE HERE' -PrerequisitesRootUrl 'ENTER VALUE HERE'

EXPOSE 1433
