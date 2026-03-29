# ============================================================
#  VW INFORMATICA - Gerador de EXE
#  Executa este script no Windows para gerar o VW_Diagnostico.exe
#  O .exe gerado executa o diagnostico direto do GitHub
# ============================================================

$desktop = [Environment]::GetFolderPath("Desktop")
$tempDir = "$env:TEMP\VW_Build_$(Get-Random)"
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

Write-Host ""
Write-Host "  VW INFORMATICA - Gerador de EXE" -ForegroundColor Cyan
Write-Host "  ================================" -ForegroundColor Cyan
Write-Host ""

# 1. Criar o .bat que o .exe vai executar
$batContent = @'
@echo off
title VW INFORMATICA - Diagnostico e Reparo v3.6
color 0B
echo.
echo   ===================================================
echo    VW INFORMATICA - Diagnostico e Reparo v3.6
echo    Xique-Xique/BA  -  (74) 99937-8375
echo   ===================================================
echo.
echo    Baixando e executando do GitHub...
echo    Aguarde...
echo.
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iex ((New-Object Net.WebClient).DownloadString(''https://raw.githubusercontent.com/hugoqwe1997-code/VW_Diagnostico/main/VW_Diagnostico.ps1''))\"'"
'@

$batPath = "$tempDir\VW_Launcher.bat"
$batContent | Out-File -FilePath $batPath -Encoding ASCII -Force

Write-Host "  [1/3] Arquivo .bat criado" -ForegroundColor Green

# 2. Criar o arquivo .sed para o IExpress
$exePath = "$desktop\VW_Diagnostico.exe"

$sedContent = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=0
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=Executar VW Informatica - Diagnostico e Reparo v3.6?
DisplayLicense=
FinishMessage=
TargetName=$exePath
FriendlyName=VW Informatica - Diagnostico v3.6
AppLaunched=VW_Launcher.bat
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles
FILE0="VW_Launcher.bat"
[SourceFiles]
SourceFiles0=$tempDir\
[SourceFiles0]
%FILE0%=
"@

$sedPath = "$tempDir\VW_Diagnostico.sed"
$sedContent | Out-File -FilePath $sedPath -Encoding ASCII -Force

Write-Host "  [2/3] Configuracao IExpress criada" -ForegroundColor Green

# 3. Gerar o .exe usando IExpress (ja vem no Windows)
Write-Host "  [3/3] Gerando VW_Diagnostico.exe..." -ForegroundColor Yellow

$iexpress = "$env:SystemRoot\System32\iexpress.exe"
if (Test-Path $iexpress) {
    Start-Process -FilePath $iexpress -ArgumentList "/N $sedPath" -Wait -NoNewWindow
    
    if (Test-Path $exePath) {
        Write-Host ""
        Write-Host "  ====================================================" -ForegroundColor Green
        Write-Host "  VW_Diagnostico.exe gerado com sucesso!" -ForegroundColor Green
        Write-Host "  Local: $exePath" -ForegroundColor White
        Write-Host "  ====================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "  O .exe faz o seguinte:" -ForegroundColor DarkGray
        Write-Host "    1. Pede permissao de administrador" -ForegroundColor DarkGray
        Write-Host "    2. Baixa o script mais recente do GitHub" -ForegroundColor DarkGray
        Write-Host "    3. Executa o diagnostico completo" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Pode copiar para pendrive e usar em qualquer PC!" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "  [!] Erro: .exe nao foi gerado" -ForegroundColor Red
        Write-Host "  Tente executar este script como Administrador" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [!] IExpress nao encontrado em: $iexpress" -ForegroundColor Red
}

# Limpar temp
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "  Pressione ENTER para sair..." -ForegroundColor DarkGray
Read-Host
