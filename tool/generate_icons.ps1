Add-Type -AssemblyName System.Drawing
$srcPath = "assets\icon\caliope_icon.jpg"
if (Test-Path $srcPath) {
    $img = [System.Drawing.Image]::FromFile((Resolve-Path $srcPath))
    $sizes = @{
        "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" = 48
        "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" = 72
        "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" = 96
        "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" = 144
        "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" = 192
        "web\icons\Icon-192.png" = 192
        "web\icons\Icon-512.png" = 512
        "web\favicon.png" = 64
    }
    foreach ($entry in $sizes.GetEnumerator()) {
        $outPath = $entry.Key
        $dim = $entry.Value
        $dir = [System.IO.Path]::GetDirectoryName($outPath)
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $bmp = New-Object System.Drawing.Bitmap $dim, $dim
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.DrawImage($img, 0, 0, $dim, $dim)
        $g.Dispose()
        $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Host "Generated $outPath ($dim x $dim)"
    }
    $img.Dispose()
} else {
    Write-Error "Source image not found: $srcPath"
}
