# Ruta del fichero de debug en el Escritorio
$desktop    = [Environment]::GetFolderPath('Desktop')
$debugFile  = Join-Path $desktop 'wifi_debug.txt'

# 1) Volcar salida completa de netsh wlan show profiles
"netsh wlan show profiles → salida cruda" | Out-File $debugFile -Encoding utf8
netsh wlan show profiles 2>&1 | Out-File $debugFile -Append -Encoding utf8

# 2) Volcar sólo las líneas que coincidan con el filtro singular y plural
""                               | Out-File $debugFile -Append -Encoding utf8
"Filtrado regex 'Perfil de usuario':" | Out-File $debugFile -Append -Encoding utf8
netsh wlan show profiles | Select-String 'Perfil de usuario' | Out-File $debugFile -Append -Encoding utf8

""                               | Out-File $debugFile -Append -Encoding utf8
"Filtrado regex 'Perfiles de usuario':" | Out-File $debugFile -Append -Encoding utf8
netsh wlan show profiles | Select-String 'Perfiles de usuario' | Out-File $debugFile -Append -Encoding utf8

# 3) Aviso en pantalla
Write-Host "`n=== Debug volcado en:`n  $debugFile`nPresiona ENTER para cerrar..."
Read-Host
