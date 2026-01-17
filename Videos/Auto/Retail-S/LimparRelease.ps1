# Script para remover arquivos desnecessários da pasta Release
# Mantém apenas os essenciais para executar o reprodutor

$releasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$releasePath = Join-Path $releasePath "Release"

if (-not (Test-Path $releasePath)) {
    Write-Host "❌ Pasta Release não encontrada em: $releasePath" -ForegroundColor Red
    exit 1
}

Write-Host "🧹 Limpando pasta Release..." -ForegroundColor Yellow
Write-Host "Caminho: $releasePath`n" -ForegroundColor Gray

# Contar espaço antes
$espacoAntes = (Get-ChildItem -Path $releasePath -Recurse -Force | Measure-Object -Property Length -Sum).Sum
$espacoAntesGB = [math]::Round($espacoAntes / 1GB, 2)

Write-Host "Espaço antes: $espacoAntesGB GB`n" -ForegroundColor Cyan

# 1. Remover arquivos .xml (documentação - desenvolvimento apenas)
Write-Host "Removendo arquivos .xml (documentação)..." -ForegroundColor White
Get-ChildItem -Path $releasePath -Filter "*.xml" -Depth 0 -Force | Remove-Item -Force
Write-Host "✓ Arquivos .xml removidos" -ForegroundColor Green

# 2. Remover pasta app.publish (publicação/deploy)
Write-Host "Removendo pasta app.publish..." -ForegroundColor White
$appPublishPath = Join-Path $releasePath "app.publish"
if (Test-Path $appPublishPath) {
    Remove-Item -Path $appPublishPath -Recurse -Force
    Write-Host "✓ Pasta app.publish removida" -ForegroundColor Green
}

# 3. Remover pastas de idiomas (exceto português)
Write-Host "Removendo pastas de idiomas desnecessários..." -ForegroundColor White
$idiomasRemover = @("de", "es", "fr", "it", "ja", "pl", "ru", "sv", "tr", "zh-CN", "zh-Hant")

foreach ($idioma in $idiomasRemover) {
    $caminhoIdioma = Join-Path $releasePath $idioma
    if (Test-Path $caminhoIdioma) {
        Remove-Item -Path $caminhoIdioma -Recurse -Force
        Write-Host "  ✓ Removido: $idioma" -ForegroundColor Green
    }
}

# 4. Remover arquivos desnecessários (mantém apenas .exe e .config)
Write-Host "Removendo arquivos desnecessários..." -ForegroundColor White
$arquivosRemover = @("*.application", "*.manifest", "*Atalho.lnk")

foreach ($filtro in $arquivosRemover) {
    Get-ChildItem -Path $releasePath -Filter $filtro -Depth 0 -Force | Remove-Item -Force
    Write-Host "  ✓ Removidos: $filtro" -ForegroundColor Green
}

# Contar espaço depois
$espacoDepois = (Get-ChildItem -Path $releasePath -Recurse -Force | Measure-Object -Property Length -Sum).Sum
$espacoDepoisGB = [math]::Round($espacoDepois / 1GB, 2)
$reducao = [math]::Round(($espacoAntes - $espacoDepois) / 1GB, 2)
$percentualReducao = [math]::Round(($reducao / $espacoAntes) * 100, 1)

Write-Host "`n" -ForegroundColor Gray
Write-Host "✅ Limpeza concluída!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Espaço antes:      $espacoAntesGB GB" -ForegroundColor Cyan
Write-Host "Espaço depois:     $espacoDepoisGB GB" -ForegroundColor Cyan
Write-Host "Espaço liberado:   $reducao GB ($percentualReducao%)" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

Write-Host "`n📦 Arquivos mantidos (essenciais):" -ForegroundColor Yellow
Write-Host "  • Retail S Video.exe" -ForegroundColor White
Write-Host "  • Retail S Video.exe.config" -ForegroundColor White
Write-Host "  • libvlc/ (biblioteca de reprodução de vídeo)" -ForegroundColor White
