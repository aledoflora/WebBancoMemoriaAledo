# Script PowerShell para actualizar automáticamente el JSON de carpetas
param(
    [switch]$Watch
)

# Ruta al directorio del recetario
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$recetarioPath = Join-Path $scriptPath "..\data\recetario"
$huertaPath    = Join-Path $scriptPath "..\data\huerta"
$jsonRecetario = Join-Path $recetarioPath "carpetas.json"
$jsonHuerta    = Join-Path $huertaPath "carpetas.json"

function Get-IndexJson($folderPath) {
    $imageCandidates = @('cover.jpg','portada.jpg','imagen.jpg','foto.jpg','450_1000.jpg','*.jpg','*.jpeg','*.png')
    $pdfCandidates   = @('*.pdf')
    $cover = $null
    foreach ($img in $imageCandidates) {
        $found = Get-ChildItem -Path $folderPath -Filter $img -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $cover = $found.Name; break }
    }
    $pdf = $null
    foreach ($pdfpat in $pdfCandidates) {
        $found = Get-ChildItem -Path $folderPath -Filter $pdfpat -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $pdf = $found.Name; break }
    }
    $index = @{}
    if ($cover) { $index['cover'] = $cover }
    if ($pdf)   { $index['pdf']   = $pdf }
    if ($index.Keys.Count -gt 0) {
        $index | ConvertTo-Json -Depth 2 | Out-File -FilePath (Join-Path $folderPath 'index.json') -Encoding UTF8
    }
}

function Update-CarpetasJSON {
    try {
        # Recetario
        $carpetasRecetario = Get-ChildItem -Path $recetarioPath -Directory | Select-Object -ExpandProperty Name | Sort-Object
        foreach ($carpeta in $carpetasRecetario) {
            $folderPath = Join-Path $recetarioPath $carpeta
            Get-IndexJson $folderPath
        }
        $jsonDataRecetario = @{
            'carpetas' = $carpetasRecetario
            'notas' = "Este archivo se actualiza automáticamente. No editar manualmente."
            'ultimaActualizacion' = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
        $jsonDataRecetario | ConvertTo-Json -Depth 2 | Out-File -FilePath $jsonRecetario -Encoding UTF8
        Write-Host "✅ JSON recetario actualizado" -ForegroundColor Green
        Write-Host "📁 Carpetas recetario: $($carpetasRecetario.Count)" -ForegroundColor Cyan
        Write-Host "📝 Carpetas recetario: $($carpetasRecetario -join ', ')" -ForegroundColor Yellow

        # Huerta
        if (Test-Path $huertaPath) {
            $carpetasHuerta = Get-ChildItem -Path $huertaPath -Directory | Select-Object -ExpandProperty Name | Sort-Object
            foreach ($carpeta in $carpetasHuerta) {
                $folderPath = Join-Path $huertaPath $carpeta
                Get-IndexJson $folderPath
            }
            $jsonDataHuerta = @{
                'carpetas' = $carpetasHuerta
                'notas' = "Este archivo se actualiza automáticamente. No editar manualmente."
                'ultimaActualizacion' = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            }
            $jsonDataHuerta | ConvertTo-Json -Depth 2 | Out-File -FilePath $jsonHuerta -Encoding UTF8
            Write-Host "✅ JSON huerta actualizado" -ForegroundColor Green
            Write-Host "📁 Carpetas huerta: $($carpetasHuerta.Count)" -ForegroundColor Cyan
            Write-Host "📝 Carpetas huerta: $($carpetasHuerta -join ', ')" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Error al actualizar el JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Ejecutar la función
Update-CarpetasJSON

# Si se especifica -Watch, observar cambios
if ($Watch) {
    Write-Host "👀 Observando cambios en los directorios..." -ForegroundColor Magenta
    $watcherRecetario = New-Object System.IO.FileSystemWatcher
    $watcherRecetario.Path = $recetarioPath
    $watcherRecetario.IncludeSubdirectories = $true
    $watcherRecetario.EnableRaisingEvents = $true
    $watcherHuerta = $null
    if (Test-Path $huertaPath) {
        $watcherHuerta = New-Object System.IO.FileSystemWatcher
        $watcherHuerta.Path = $huertaPath
        $watcherHuerta.IncludeSubdirectories = $true
        $watcherHuerta.EnableRaisingEvents = $true
    }
    Register-ObjectEvent -InputObject $watcherRecetario -EventName "Created" -Action {
        $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
        if (-not $name.EndsWith('.json')) { Start-Sleep -Milliseconds 100; Update-CarpetasJSON }
    }
    Register-ObjectEvent -InputObject $watcherRecetario -EventName "Deleted" -Action {
        $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
        if (-not $name.EndsWith('.json')) { Start-Sleep -Milliseconds 100; Update-CarpetasJSON }
    }
    if ($watcherHuerta) {
        Register-ObjectEvent -InputObject $watcherHuerta -EventName "Created" -Action {
            $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
            if (-not $name.EndsWith('.json')) { Start-Sleep -Milliseconds 100; Update-CarpetasJSON }
        }
        Register-ObjectEvent -InputObject $watcherHuerta -EventName "Deleted" -Action {
            $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
            if (-not $name.EndsWith('.json')) { Start-Sleep -Milliseconds 100; Update-CarpetasJSON }
        }
    }
    Write-Host "Presiona Ctrl+C para detener la observación..." -ForegroundColor Gray
    try { while ($true) { Start-Sleep -Seconds 1 } } finally {
        $watcherRecetario.Dispose()
        if ($watcherHuerta) { $watcherHuerta.Dispose() }
    }
}
