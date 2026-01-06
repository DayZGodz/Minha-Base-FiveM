# GODZ Auto-Updater
# Developed for GODZ Base
$ErrorActionPreference = "Stop"

Write-Host "=== GODZ AUTO-UPDATER ===" -ForegroundColor Cyan
Write-Host "Iniciando processo de atualização de artefatos..."

# URL oficial para a última build (master/latest)
# Nota: Para produção, muitas vezes usa-se a "Recommended", mas a "Latest" garante as últimas correções.
$url = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/latest.zip"
$output = "$env:TEMP\fivem_artifacts.zip"
$destination = Join-Path $PSScriptRoot "GODZ_Base\artifacts"

# Criar diretório se não existir
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
}

try {
    Write-Host "Baixando artefatos do FiveM..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    
    if (Test-Path $output) {
        Write-Host "Download concluído. Extraindo arquivos..." -ForegroundColor Yellow
        # Extrair sobrescrevendo arquivos existentes
        Expand-Archive -Path $output -DestinationPath $destination -Force
        
        Write-Host "Limpando arquivos temporários..." -ForegroundColor Yellow
        Remove-Item -Path $output -Force
        
        Write-Host "Atualização de Artefatos concluída com SUCESSO!" -ForegroundColor Green
        Write-Host "Artefatos atualizados em: $destination"
    } else {
        Write-Error "Falha no download do arquivo."
    }
} catch {
    Write-Error "Ocorreu um erro durante a atualização: $_"
    Read-Host "Pressione ENTER para sair..."
}
