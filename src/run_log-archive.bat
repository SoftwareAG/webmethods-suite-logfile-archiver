@echo off

rem   (c) Copyright 2012-2023 Software AG, Darmstadt, Germany and/or Software AG USA  Inc.,
rem   Reston, United States of America, and/or their suppliers.
rem   http://www.softwareag.com
rem
rem SPDX-License-Identifier: Apache-2.0
rem
rem   Licensed under the Apache License, Version 2.0 (the "License");
rem   you may not use this file except in compliance with the License.
rem   You may obtain a copy of the License at
rem
rem       http://www.apache.org/licenses/LICENSE-2.0
rem
rem   Unless required by applicable law or agreed to in writing, software
rem   distributed under the License is distributed on an "AS IS" BASIS,
rem   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem   See the License for the specific language governing permissions and
rem   limitations under the License.


rem   NAME
rem       run_log-archive.bat - Archive and, where appropriate, delete log files
rem  
rem  
rem   SYNOPSIS
rem  
rem       run_log-archive.bat [WEBMETHODS_HOME]
rem  
rem  
rem   DESCRIPTION
rem       This script acts as a convenience wrapper to run the Ant script that 
rem       does the actual work. It takes care of checking for the existence of
rem       required environment variables and, if they are not defined, tries
rem       to auto-set them. The variables are
rem       - WEBMETHODS_HOME
rem       - ANT_HOME
rem       - JAVA_HOME
rem  
rem       WEBMETHODS_HOME
rem            If not set (either system-wide or from the command line), it will
rem            be determined by taking this script's location, assuming the latter is
rem            $WEBMETHODS_HOME/tools/operations/logArchiver
rem  
rem       JAVA_HOME
rem            The JVM that comes with the webMethods Suite will be used.
rem  
rem       ANT_HOME
rem            The Ant installation that comes with the Asset Build Environment (ABE) 
rem            will be used.
rem  


setlocal 

rem   Log files older than $RETENTION_DAYS days, will be deleted from the archive location
rem   (The default in the Ant script is 30 days and will be overriden with this value.)
set RETENTION_DAYS=30


set CHECK_ANT_INSTALLATIONS=..\..\..\common\lib\ant ..\apache-ant ..\..\..\common\AssetBuildEnvironment\ant
set CHECK_JAVA_INSTALLATIONS=..\..\..\jvm\jvm ..\..\..\jvm\jvm180_64 ..\..\..\jvm\jvm180_32 ..\..\..\jvm\jvm180


rem   Use optional command line argument to specify/override the 
rem   installation's main directory
if not "%1"=="" (
	set WEBMETHODS_HOME="%1"
)

rem   If no installation directory is defined or provided,
rem   determine it from this script's location, assuming the
rem   script is installed in $WEBMETHODS_HOME/tools/operations/logArchiver
if "%WEBMETHODS_HOME%"=="" (
	set WEBMETHODS_HOME=%~dp0..\..\..
)



rem   If ANT_HOME is not defined, try to find an installation
if "%ANT_HOME%"=="" (
	echo ANT_HOME is not set
	for %%i in (%CHECK_ANT_INSTALLATIONS%) do (
		echo Checking %%i
		if exist "%%i" (
			echo Found %%i
			set ANT_HOME=%%i
			goto end_find_ANT_HOME
		)
	)
)
:end_find_ANT_HOME

rem   Abort if ANT_HOME is not defined and could also not be located
if "%ANT_HOME%"=="" (
	echo ANT_HOME is not set and no installation could be found automatically. Aborting
	goto end
) else (
	echo ANT_HOME = "%ANT_HOME%"
)



rem   If JAVA_HOME is not defined, try to find an installation
if "%JAVA_HOME%"=="" (
	echo JAVA_HOME is not set
	for %%i in (%CHECK_JAVA_INSTALLATIONS%) do (
		echo Checking %%i
		if exist "%%i" (
			echo Found %%i
			set JAVA_HOME=%%i
			goto end_find_JAVA_HOME
		)
	)
)
:end_find_JAVA_HOME


rem   Abort if JAVA_HOME is not defined and could also not be located
if "%JAVA_HOME%"=="" (
	echo JAVA_HOME is not set and no installation could be found automatically. Aborting
	goto end
) else (
	echo JAVA_HOME = "%JAVA_HOME%"
)

set ANT_CMD="%ANT_HOME%\bin\ant.bat"

call %ANT_CMD% -lib %ANT_HOME% -f build_log-archive.xml -DretentionDays=%RETENTION_DAYS% -DwebMethods.home="%WEBMETHODS_HOME%" 


:end
endlocal
