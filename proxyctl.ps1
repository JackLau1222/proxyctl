# proxyctl.ps1 — mixed-port–aware proxy controller

$ConfigDir  = Join-Path $env:APPDATA "proxyctl"
$ConfigFile = Join-Path $ConfigDir "config.ps1"

function Set-ProxyConfig {
  param(
    [Parameter(Mandatory)]
    [string]$Arg1,
    [string]$Arg2
  )

  if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir | Out-Null
  }

  if ($Arg1 -notmatch '://') {
    # shorthand mixed-port
    $ProxyHttp = "http://$Arg1"
    $ProxyAll  = "socks5://$Arg1"
  } else {
    $ProxyHttp = $Arg1
    $ProxyAll  = $Arg2
  }

  @"
`$PROXY_HTTP = '$ProxyHttp'
`$PROXY_ALL  = '$ProxyAll'
"@ | Set-Content -Encoding UTF8 $ConfigFile

  Write-Output "Proxy configuration saved"
}

function Enable-Proxy {
  if (-not (Test-Path $ConfigFile)) {
    Write-Error "No proxy config found. Run Set-ProxyConfig first."
    return
  }

  . $ConfigFile

  $env:http_proxy  = $PROXY_HTTP
  $env:https_proxy = $PROXY_HTTP
  $env:all_proxy   = if ($PROXY_ALL) { $PROXY_ALL } else { $PROXY_HTTP }

  $env:HTTP_PROXY  = $env:http_proxy
  $env:HTTPS_PROXY = $env:https_proxy
  $env:ALL_PROXY   = $env:all_proxy

  $env:no_proxy = $env:NO_PROXY = 'localhost,127.0.0.1,::1'

  Write-Output "Proxy enabled"
}

function Disable-Proxy {
  'http_proxy','https_proxy','all_proxy',
  'HTTP_PROXY','HTTPS_PROXY','ALL_PROXY',
  'no_proxy','NO_PROXY' |
    ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }

  Write-Output "Proxy disabled"
}

function Show-Proxy {
  Write-Output "Status:"
  if ($env:http_proxy) { '  Enabled' } else { '  Disabled' }

  Write-Output "Config:"
  if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object { "  $_" }
  } else {
    '  <not configured>'
  }
}
