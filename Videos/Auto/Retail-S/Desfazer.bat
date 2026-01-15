<# :
@echo off
setlocal
title Desinstalador Retail-S

REM 1. Checar privilégios de Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [AVISO] Solicitando privilegios de administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "start -verb runas '%0'"
    exit /b
)

cls
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((Get-Content '%~f0') -join [Environment]::NewLine)"
exit /b
#>

# --- Bloco PowerShell ---

$OK = "[OK]"
$Red = "Red"
$Green = "Green"

# 1. Verificação de Senha
Write-Host "--- DESINSTALADOR RETAIL-S (MODO EXTERNO) ---" -ForegroundColor Cyan
Write-Host "Digite a senha para prosseguir: " -NoNewline
$inputPass = Read-Host
if ($inputPass -ne "fuji123") {
    Write-Host "[ERRO] Senha incorreta." -ForegroundColor $Red
    Start-Sleep -Seconds 2
    return
}

# 2. Encerrar todos os processos que podem travar a pasta
$processes = "KeyboardLocker", "Retail-S", "TryScripts", "KeyFreeze_x64", "Retail S Bloqueio"
Write-Host "`nEncerrando processos..."
foreach ($p in $processes) {
    $proc = Get-Process -Name $p -ErrorAction SilentlyContinue
    if ($proc) {
        Stop-Process -Name $p -Force -ErrorAction SilentlyContinue
        Write-Host "  > $p encerrado."
    }
}

# 3. Criar o "Detonador" Externo (Arquivo .bat temporário fora da C:\Retail-S)
$detonadorPath = "$env:TEMP\limpeza_final.bat"
$scriptDeLimpeza = @"
@echo off
timeout /t 2 /nobreak > nul
echo Removendo C:\Retail-S...
rd /s /q "C:\Retail-S" 2>nul
del "C:\*.mp4" 2>nul
del "C:\*.vbs" 2>nul
del "C:\*.bat" 2>nul
echo Limpeza concluida com sucesso!
pause
del "%detonadorPath%"
exit
"@

$scriptDeLimpeza | Out-File -FilePath $detonadorPath -Encoding ascii

# 4. Limpezas que podem ser feitas agora (Rede e Desktop)
Write-Host "Limpando configuracoes de sistema..."
netsh wlan delete profile name="Fujioka" | Out-Null
$tasks = "Desligar $($env:COMPUTERNAME)", "Desligar $($env:COMPUTERNAME) Domingo", "Desligar $($env:COMPUTERNAME) Sabado"
foreach ($t in $tasks) { schtasks /delete /TN $t /f 2>$null }

$desktopTargets = @(
    "$env:USERPROFILE\Desktop\*.vbs",
    "$env:USERPROFILE\Desktop\*.bat",
    "$env:USERPROFILE\Desktop\Videos.lnk",
    "$env:USERPROFILE\Desktop\Iniciar.lnk",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Iniciar.lnk"
)
foreach ($target in $desktopTargets) { Remove-Item $target -Force -ErrorAction SilentlyContinue }

# 5. Finalização: Chama o detonador e fecha este script
Write-Host "`nIniciando fase final de exclusao de pastas..." -ForegroundColor Yellow
Write-Host "Este terminal sera fechado para permitir a remocao da pasta Retail-S."
Start-Sleep -Seconds 2

Start-Process "$detonadorPath"
exit