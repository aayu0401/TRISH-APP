@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM   https://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "BASE_DIR=%~dp0"
IF "!BASE_DIR:~-1!"=="\" SET "BASE_DIR=!BASE_DIR:~0,-1!"
SET "WRAPPER_DIR=%BASE_DIR%\.mvn\wrapper"
SET "PROPS_FILE=%WRAPPER_DIR%\maven-wrapper.properties"
SET "JAR_FILE=%WRAPPER_DIR%\maven-wrapper.jar"

IF NOT EXIST "!PROPS_FILE!" (
  ECHO Missing !PROPS_FILE! 1>&2
  EXIT /B 1
)

FOR /F "usebackq tokens=1,* delims==" %%A IN ("!PROPS_FILE!") DO (
  IF "%%A"=="wrapperUrl" SET WRAPPER_URL=%%B
)

IF NOT EXIST "!JAR_FILE!" (
  IF "!WRAPPER_URL!"=="" (
    ECHO Missing maven-wrapper.jar and wrapperUrl in !PROPS_FILE! 1>&2
    EXIT /B 1
  )
  ECHO Downloading Maven Wrapper jar... 1>&2
  IF NOT EXIST "!WRAPPER_DIR!" MKDIR "!WRAPPER_DIR!"
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Invoke-WebRequest -UseBasicParsing -Uri '!WRAPPER_URL!' -OutFile '!JAR_FILE!'" || EXIT /B 1
)

IF "!JAVA_HOME!"=="" (
  SET JAVA_EXEC=java
) ELSE (
  SET "JAVA_EXEC=!JAVA_HOME!\bin\java"
)

"%JAVA_EXEC%" -Dmaven.multiModuleProjectDirectory="%BASE_DIR%" -classpath "%JAR_FILE%" org.apache.maven.wrapper.MavenWrapperMain %*

ENDLOCAL
