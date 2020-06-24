@echo off
openfiles > nul 2>&1
if not %errorlevel% equ 0 (
  echo You didn't run this batch file as Administrator! Please try again... Exiting in 5 seconds...
  timeout 5 > nul
  exit /b 1
)

set wtitle=Bulk Install
REM pushd %~dp0
cd %~dp0
set ext=*.exe *.msi
set quietfolder=quietinstall
set postrunfolder=postexecute
set /a count=0
set /a current=0
set /a progress=0

setlocal enabledelayedexpansion

for /r %%x in (%ext%) do set /a count+=1

title !progress!%% %wtitle% !current! of %count%

echo RECURSIVELY RUNNING FILES...
echo.

for /f %%f in ('dir /s /b /a:-d %ext% ^| findstr /v /i /c:"\%quietfolder%\\" /c:"\%postrunfolder%\\"') do (
	echo Starting file: %%f
	start /wait "wtitle" "%%f"

	if %errorlevel% equ 0 (
		echo File %%~nf returned no errors
		echo.
	) else (
		echo File %%~nf exited with error code %errorlevel%
		echo.
	)

	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)

echo RECURSIVELY AND QUIETLY INSTALLING PACKAGES IN %quietfolder%
echo.

for /r %%f in (%quietfolder%\%ext%) do (
	echo Installing: %%f...
	start /wait msiexec /i "%%f" /qn

	if %errorlevel% equ 0 (
		echo File %%~nf returned no errors
		echo.
	) else (
		echo File %%~nf exited with code %errorlevel%
		echo.
	)

	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)

echo RECURSIVELY EXECUTING POST INSTALL FOLDER %postrunfolder%
echo.

for /r %%f in (%postrunfolder%\%ext%) do (
	echo Starting file: %%f...
  start /wait "wtitle" "%%f"

	if %errorlevel% equ 0 (
		echo File %%~nf returned no errors
		echo.
	) else (
		echo File %%~nf exited with code %errorlevel%
		echo.
	)

	set /a current+=1
	set /a progress=100*current/count
	title !progress!%% %wtitle% !current! of %count%
)

endlocal
REM popd
echo Sequence complete, press any key to exit!
pause > nul
