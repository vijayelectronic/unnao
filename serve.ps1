# Simple PowerShell static file server
param(
  [int]$Port = 8000,
  [string]$Root = (Get-Location).Path
)

Add-Type -AssemblyName System.Net.HttpListener
$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving $Root at $prefix" -ForegroundColor Green

function Get-ContentType($path) {
  if ($path.EndsWith('.html')) { return 'text/html' }
  elseif ($path.EndsWith('.css')) { return 'text/css' }
  elseif ($path.EndsWith('.js')) { return 'application/javascript' }
  elseif ($path.EndsWith('.svg')) { return 'image/svg+xml' }
  elseif ($path.EndsWith('.png')) { return 'image/png' }
  elseif ($path.EndsWith('.jpg') -or $path.EndsWith('.jpeg')) { return 'image/jpeg' }
  else { return 'application/octet-stream' }
}

try {
  while ($true) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response

    $path = $req.Url.AbsolutePath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($path)) { $path = 'index.html' }

    $full = Join-Path $Root $path
    if (-not (Test-Path $full)) {
      # try default file for directories
      if (Test-Path (Join-Path $full 'index.html')) { $full = Join-Path $full 'index.html' }
    }

    if (Test-Path $full) {
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $res.ContentType = Get-ContentType $full
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
      $res.OutputStream.Write($msg, 0, $msg.Length)
    }
    $res.Close()
  }
}
finally {
  $listener.Stop()
}