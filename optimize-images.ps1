# Image Optimization Script
# Gets ImageMagick path from registry
$imPath = (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\Software\ImageMagick\Current" -Name "BinPath" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty BinPath) + "\magick.exe"
$imagePath = "c:\Users\cukormegtej\Documents\momecodingclass\mrmettyou.github.io\IMAGES"
$images = @(Get-ChildItem -Path $imagePath -Recurse -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|gif)$' })

Write-Host "Found $($images.Count) images to optimize..."
Write-Host "Using ImageMagick at: $imPath"

$count = 0
$totalSize = 0
$optimizedSize = 0

foreach ($img in $images) {
    $originalSize = (Get-Item $img.FullName).Length
    $tempFile = "$($img.FullName).tmp"
    
    try {
        & $imPath "$($img.FullName)" -quality 85 "$tempFile" 2>$null
        
        if (Test-Path $tempFile) {
            $newSize = (Get-Item $tempFile).Length
            Remove-Item -Path $img.FullName -Force
            Move-Item -Path $tempFile -Destination $img.FullName -Force
            
            $totalSize += $originalSize
            $optimizedSize += $newSize
            $count++
            
            if ($count % 50 -eq 0) {
                Write-Host "Processed $count images..."
            }
        }
    }
    catch {
        Write-Host "Error processing $($img.Name): $_"
    }
}

$saved = $totalSize - $optimizedSize
$percent = if ($totalSize -gt 0) { [math]::Round(($saved / $totalSize) * 100, 2) } else { 0 }

Write-Host ""
Write-Host "=== Optimization Complete ==="
Write-Host "Total images optimized: $count"
Write-Host "Original total size: $(($totalSize/1MB).ToString('F2')) MB"
Write-Host "Optimized total size: $(($optimizedSize/1MB).ToString('F2')) MB"
Write-Host "Space saved: $(($saved/1MB).ToString('F2')) MB ($percent%)"
