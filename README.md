# Overview
This repository shows how to build a Docker image containing a full version of SQL Server. If your demands on SQL Server are simple, it is suggested that you look at the already existing image [microsoft/mssql-server-windows-express](https://hub.docker.com/r/microsoft/mssql-server-windows-express/) that runs SQL Express. The current repository is for those of you that need to use features that are not available in SQL Server Express.

The provided scripts were tested with SQL Server 2012 SP2.

# Prerequisites
The provided Dockerfile will need two things:

- A zip file that contains the content of the SQL Server iso.
- The file `microsoft-windows-netfx3-ondemand-package.cab` contained in the `sources\sxs` folder of your Windows Server 2016 Core iso.

These two files will need to be stored on a web server accessible when building the docker image.

To simplify the setup of these prerequisites, you can use the script `PrepareWebServer.ps1`. Just give it the path to your SQL Server and Windows Server Core isos to prepare the files that need to be placed in your web server. The following example assumes that the folder `C:\Public\DockerBuildContent` is exposed by IIS through a virtual directory.

    .\PrepareWebServer.ps1 -SqlServerIso '\\w483\isos\en_sql_server_2012_developer_edition_with_service_pack_2_x64_dvd_4668513.iso' `
                           -WindowsServerCoreIso '\\w483\isos\en_windows_server_2016_x64_dvd_9327751.iso' `
                           -Destination 'C:\public\DockerBuildContent\'

# Generate Docker image

Now that you have prepared the prerequisites, you are almost ready to generate the image. Before calling `docker build`, edit the Dockerfile and substitute the values `ENTER VALUE HERE` for the desired values in the Powershell call. In my case, it resulted in the following:

    RUN powershell c:/SqlServerInstallation/InstallSqlServer.ps1 -SaPassword 'SqlServer1!' -PrerequisitesRootUrl 'http://w483/public/DockerBuildContent/'

You can now build the image:

    docker build -t sql-server .

If you need to tweek the SQL server installation parameters, simply edit the file SqlServerConfiguration.ini before calling `docker build`.

# Using the resulting image

You can now start this image:

    docker run --name sql sql-server
