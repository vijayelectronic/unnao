param(
  [int]$Width = 4096,
  [int]$Height = 7680,
  [string]$Output = "images/large-90MiB.bmp"
)

# 24-bit BMP (uncompressed) with simple solid color
$bitsPerPixel = 24
$headerSize = 54
$rowSize = [int](((($Width * 3) + 3) / 4)) * 4  # row padded to 4 bytes
$imageSize = $rowSize * $Height
$fileSize = $headerSize + $imageSize

$dir = Split-Path $Output
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$fs = [System.IO.File]::Open($Output, [System.IO.FileMode]::Create)
$bw = New-Object System.IO.BinaryWriter($fs)

try {
  # BITMAPFILEHEADER
  $bw.Write([byte]0x42) # 'B'
  $bw.Write([byte]0x4D) # 'M'
  $bw.Write([BitConverter]::GetBytes([int]$fileSize))
  $bw.Write([BitConverter]::GetBytes([int]0)) # reserved1+2
  $bw.Write([BitConverter]::GetBytes([int]$headerSize)) # offset

  # BITMAPINFOHEADER
  $bw.Write([BitConverter]::GetBytes([int]40)) # info header size
  $bw.Write([BitConverter]::GetBytes([int]$Width))
  $bw.Write([BitConverter]::GetBytes([int]$Height))
  $bw.Write([BitConverter]::GetBytes([int]1)) # planes
  $bw.Write([BitConverter]::GetBytes([int]$bitsPerPixel))
  $bw.Write([BitConverter]::GetBytes([int]0)) # compression BI_RGB
  $bw.Write([BitConverter]::GetBytes([int]$imageSize))
  $bw.Write([BitConverter]::GetBytes([int]2835)) # x ppm (~72 dpi)
  $bw.Write([BitConverter]::GetBytes([int]2835)) # y ppm
  $bw.Write([BitConverter]::GetBytes([int]0)) # clr used
  $bw.Write([BitConverter]::GetBytes([int]0)) # clr important

  # Pixel data: fill with dark gray (BGR)
  $row = New-Object byte[] $rowSize
  for ($i = 0; $i -lt $rowSize; $i += 3) {
    $row[$i] = 0x20   # Blue
    if ($i + 1 -lt $rowSize) { $row[$i+1] = 0x20 } # Green
    if ($i + 2 -lt $rowSize) { $row[$i+2] = 0x20 } # Red
  }
  for ($y = 0; $y -lt $Height; $y++) { $bw.Write($row) }
}
finally {
  $bw.Close(); $fs.Close()
}

Write-Host "Generated BMP: $Output (size $fileSize bytes)" -ForegroundColor Green