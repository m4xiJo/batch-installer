@echo off
openfiles > nul 2>&1
if not %errorlevel% equ 0 (
  echo You didn't run this batch file as Administrator! Please try again... Exiting in 5 seconds...
  timeout 5 > nul
  exit /b 1
)

set wtitle=Bulk Install
pushd %~dp0
REM cd %~dp0
set ext=*.exe *.msi
set postfolder=postexecute
set quietfolder=quietinstall
set /a count=0
set /a current=0
set /a progress=0

setlocal enabledelayedexpansion

for /r %%x in (%ext%) do set /a count+=1
title !progress!%% %wtitle% !current! of %count%

echo RECURSIVELY RUNNING FILES...
echo.
for /f "delims=" %%f in ('dir /s /b /a:-d %ext% ^| findstr /v /i /c:"\%quietfolder%\\" /c:"\%postfolder%\\"') do (
	echo Starting: %%f
	start /wait "wtitle" "%%f"
	echo File %%~nf exited with error code %errorlevel%
	echo.
	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)

echo RECURSIVELY AND QUIETLY INSTALLING PACKAGES IN %quietfolder%
echo.
for /f "delims=" %%f in ('dir /s /b /a:-d %ext% ^| findstr /i /c:"\%quietfolder%\\"') do (
	echo Installing: %%f
	start /wait msiexec /i "%%f" /qn
	echo File %%~nf exited with code %errorlevel%
	echo.
	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)

echo RUNNING POST INSTALL FILES IN %postfolder%...
echo.
for /f "delims=" %%f in ('dir /s /b /a:-d %ext% ^| findstr /i /c:"\%postfolder%\\"') do (
	echo Installing: %%f
  start /wait "wtitle" "%%f"
	echo File %%~nf exited with code %errorlevel%
	echo.
	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)
endlocal
popd
echo Sequence complete, press any key to exit!
pause > nul
