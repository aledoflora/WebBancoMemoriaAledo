# Script PowerShell para actualizar automáticamente el JSON de carpetas
param(
    [switch]$Watch
)

# Ruta al directorio del recetario
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$recetarioPath = Join-Path $scriptPath "..\data\recetario"
$jsonPath = Join-Path $recetarioPath "carpetas.json"

function Update-CarpetasJSON {
    try {
        # Obtener todas las carpetas del directorio
        $carpetas = Get-ChildItem -Path $recetarioPath -Directory | 
                   Select-Object -ExpandProperty Name | 
                   Sort-Object
        
        # Crear el objeto JSON
        $jsonData = @{
            carpetas = $carpetas
            notas = "Este archivo se actualiza automáticamente. No editar manualmente."
            ultimaActualizacion = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
        
        # Convertir a JSON y escribir al archivo
        $jsonData | ConvertTo-Json -Depth 2 | Out-File -FilePath $jsonPath -Encoding UTF8
        
        Write-Host "✅ JSON actualizado exitosamente" -ForegroundColor Green
        Write-Host "📁 Carpetas detectadas: $($carpetas.Count)" -ForegroundColor Cyan
        Write-Host "📝 Carpetas: $($carpetas -join ', ')" -ForegroundColor Yellow
        
    } catch {
        Write-Host "❌ Error al actualizar el JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Ejecutar la función
Update-CarpetasJSON

# Si se especifica -Watch, observar cambios
if ($Watch) {
    Write-Host "👀 Observando cambios en el directorio..." -ForegroundColor Magenta
    
    # Crear un FileSystemWatcher
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $recetarioPath
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true
    
    # Registrar el evento
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action {
        $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
        if (-not $name.EndsWith('.json')) {
            Write-Host "🔄 Cambio detectado: $name" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 100
            Update-CarpetasJSON
        }
    }
    
    Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action {
        $name = Split-Path $Event.SourceEventArgs.FullPath -Leaf
        if (-not $name.EndsWith('.json')) {
            Write-Host "🔄 Cambio detectado: $name" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 100
            Update-CarpetasJSON
        }
    }
    
    Write-Host "Presiona Ctrl+C para detener la observación..." -ForegroundColor Gray
    
    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        $watcher.Dispose()
    }
}
