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
rem       install.bat - Install the log file archiver inside the webMethods installation
rem  
rem  
rem   SYNOPSIS
rem  
rem       install.bat [WEBMETHODS_HOME]
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
rem            be if checked if webMethods is installed at the default location
rem  
rem       JAVA_HOME
rem            The JVM that comes with the webMethods Suite will be used.
rem  
rem       ANT_HOME
rem            The Ant installation that comes with the webMethods Suite will be used.
rem  

setlocal

rem   The default installation path for webMethods
set DEFAULT_PATH=c:\SoftwareAG

rem   Use optional command line argument to specify/override the 
rem   installation's main directory
if not "%1"=="" (
	set WEBMETHODS_HOME="%1"
)

rem   If no installation directory is defined or provided,
rem   check the default location. If it contains the
rem   "install" directory, it is assumed to be existing
if "%WEBMETHODS_HOME%"=="" (
	echo No environment variable WEBMETHODS_HOME found, checking default location ^(%DEFAULT_PATH%^)

    if exist "%DEFAULT_PATH%\install\" (
        echo Found webMethods installation at default location, setting environment variable WEBMETHODS_HOME accordingly ...
        set WEBMETHODS_HOME=%DEFAULT_PATH%
    ) else (
        echo No webMethods installation found at default location, aborting
        goto end
    )
)


rem   The locations (separated by space) that will be check for Ant
set CHECK_ANT_INSTALLATIONS=%WEBMETHODS_HOME%\common\lib\ant %WEBMETHODS_HOME%\common\AssetBuildEnvironment\ant
rem   The locations (separated by space) that will be check for Java
set CHECK_JAVA_INSTALLATIONS=%WEBMETHODS_HOME%\jvm\jvm %WEBMETHODS_HOME%\jvm\jvm180_64 %WEBMETHODS_HOME%\jvm\jvm180_32 %WEBMETHODS_HOME%\jvm\jvm180


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

call %ANT_CMD% -lib %ANT_HOME% -DwebMethods.home="%WEBMETHODS_HOME%" install


:end
endlocal
