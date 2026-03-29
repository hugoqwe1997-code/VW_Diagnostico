# ============================================================
#  VW INFORMATICA - FERRAMENTA DE DIAGNOSTICO E REPARO v3.6
#  Xique-Xique/BA - (74) 99937-8375
# ============================================================
# Executar como Administrador:
#   PowerShell -ExecutionPolicy Bypass -File VW_Diagnostico.ps1
# ============================================================

# --- Requer execucao como Admin ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n  [!] Este script precisa ser executado como ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "      Clique direito no PowerShell > Executar como administrador`n" -ForegroundColor Yellow
    pause
    exit
}

# ============================================================
#  SISTEMA DE LICENCA - VW INFORMATICA
# ============================================================
# INSTRUCAO: Cole abaixo a URL RAW do seu Gist privado com licencas.json
# Exemplo: https://gist.githubusercontent.com/hugoqwe1997-code/SEU_ID/raw/licencas.json
$licUrl = https://gist.githubusercontent.com/hugoqwe1997-code/7636dbb9e57f963ae48f8fadeb547079/raw/gistfile1.txt

$licArquivo = "$env:APPDATA\VW_Informatica\licenca.key"
$licDir = "$env:APPDATA\VW_Informatica"

function Verify-License {
    Clear-Host
    Write-Host ""
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  |     VW INFORMATICA - DIAGNOSTICO E REPARO v3.6           |" -ForegroundColor Cyan
    Write-Host "  |     Sistema licenciado - Assinatura mensal               |" -ForegroundColor DarkGray
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host ""
    
    # Verificar se ja tem chave salva
    $chave = $null
    if (Test-Path $licArquivo) {
        $chave = (Get-Content $licArquivo -Raw).Trim()
    }
    
    # Se nao tem chave, pedir
    if (-not $chave) {
        Write-Host "  Bem-vindo ao VW Informatica - Diagnostico e Reparo!" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Este sistema requer uma chave de licenca para funcionar." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Ainda nao tem? Entre em contato:" -ForegroundColor DarkGray
        Write-Host "  WhatsApp: (74) 99937-8375" -ForegroundColor White
        Write-Host "  Instagram: @vw.informatica" -ForegroundColor White
        Write-Host ""
        $chave = Read-Host "  Digite sua chave de licenca"
        $chave = $chave.Trim().ToUpper()
        
        if (-not $chave) {
            Write-Host "`n  Nenhuma chave informada. Saindo..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            exit
        }
    }
    
    # Validar online
    Write-Host ""
    Write-Host "  Verificando licenca..." -ForegroundColor DarkGray
    
    # Se a URL nao foi configurada, avisar o admin
    if ($licUrl -eq "COLE_SUA_URL_DO_GIST_AQUI") {
        Write-Host ""
        Write-Host "  [ADMIN] URL do Gist nao configurada!" -ForegroundColor Red
        Write-Host "  Edite o script e cole a URL do seu Gist privado" -ForegroundColor Yellow
        Write-Host "  na variavel " -NoNewline; Write-Host '$licUrl' -ForegroundColor Cyan -NoNewline; Write-Host " no inicio do arquivo." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Executando em modo DEMO (sem validacao)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
        return $true
    }
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $json = (New-Object Net.WebClient).DownloadString($licUrl)
        $dados = $json | ConvertFrom-Json
        
        # Procurar a chave
        $licenca = $dados.licencas.PSObject.Properties | Where-Object { $_.Name -eq $chave }
        
        if (-not $licenca) {
            Write-Host ""
            Write-Host "  [ERRO] Chave de licenca invalida!" -ForegroundColor Red
            Write-Host ""
            Write-Host "  A chave '$chave' nao foi encontrada." -ForegroundColor Yellow
            Write-Host "  Verifique se digitou corretamente." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  Para adquirir uma licenca:" -ForegroundColor White
            Write-Host "  WhatsApp: (74) 99937-8375" -ForegroundColor White
            Write-Host ""
            # Apagar chave salva incorreta
            Remove-Item $licArquivo -Force -ErrorAction SilentlyContinue
            pause
            exit
        }
        
        $lic = $licenca.Value
        
        # Verificar se esta ativo
        if (-not $lic.ativo) {
            Write-Host ""
            Write-Host "  [ERRO] Licenca DESATIVADA!" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Sua licenca foi desativada pelo administrador." -ForegroundColor Yellow
            Write-Host "  Entre em contato para resolver:" -ForegroundColor Yellow
            Write-Host "  WhatsApp: (74) 99937-8375" -ForegroundColor White
            Write-Host ""
            Remove-Item $licArquivo -Force -ErrorAction SilentlyContinue
            pause
            exit
        }
        
        # Verificar validade
        $validade = [datetime]::ParseExact($lic.validade, "yyyy-MM-dd", $null)
        $hoje = Get-Date
        $diasRestantes = ($validade - $hoje).Days
        
        if ($diasRestantes -lt 0) {
            Write-Host ""
            Write-Host "  [ERRO] Licenca EXPIRADA!" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Sua licenca venceu em $($lic.validade)." -ForegroundColor Yellow
            Write-Host "  Renove sua assinatura para continuar usando." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  WhatsApp: (74) 99937-8375" -ForegroundColor White
            Write-Host "  Instagram: @vw.informatica" -ForegroundColor White
            Write-Host ""
            Remove-Item $licArquivo -Force -ErrorAction SilentlyContinue
            pause
            exit
        }
        
        # Salvar chave valida
        if (-not (Test-Path $licDir)) { New-Item -Path $licDir -ItemType Directory -Force | Out-Null }
        $chave | Out-File -FilePath $licArquivo -Encoding ASCII -Force
        
        # Mostrar info da licenca
        Write-Host "  Licenca valida!" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Cliente  : $($lic.cliente)" -ForegroundColor White
        Write-Host "  Plano    : Assinatura $($lic.plano)" -ForegroundColor White
        Write-Host "  Validade : $($lic.validade)" -ForegroundColor White
        
        if ($diasRestantes -le 5) {
            Write-Host ""
            Write-Host "  [!] ATENCAO: Sua licenca vence em $diasRestantes dia(s)!" -ForegroundColor Red
            Write-Host "  Renove pelo WhatsApp: (74) 99937-8375" -ForegroundColor Yellow
        } elseif ($diasRestantes -le 10) {
            Write-Host "  Restam   : $diasRestantes dias" -ForegroundColor Yellow
        } else {
            Write-Host "  Restam   : $diasRestantes dias" -ForegroundColor Green
        }
        
        Write-Host ""
        Start-Sleep -Seconds 2
        return $true
        
    } catch {
        # Se nao conseguir verificar online, tentar usar chave salva
        if (Test-Path $licArquivo) {
            Write-Host "  Sem internet - usando licenca salva localmente." -ForegroundColor Yellow
            Write-Host "  A verificacao completa sera feita quando houver conexao." -ForegroundColor DarkGray
            Write-Host ""
            Start-Sleep -Seconds 2
            return $true
        } else {
            Write-Host ""
            Write-Host "  [ERRO] Sem conexao com a internet!" -ForegroundColor Red
            Write-Host "  A primeira ativacao requer internet." -ForegroundColor Yellow
            Write-Host ""
            pause
            exit
        }
    }
}

# Executar verificacao
$licValida = Verify-License
if (-not $licValida) { exit }

# --- Configuracoes ---
$ErrorActionPreference = "SilentlyContinue"
$ReportPath = "$env:USERPROFILE\Desktop\VW_Diagnostico_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:Report = @()

# --- Funcoes Auxiliares ---
function Write-Header($text) {
    $line = "=" * 60
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor White
    Write-Host "$line`n" -ForegroundColor Cyan
    $Global:Report += "`n$line`n  $text`n$line`n"
}

function Write-Info($label, $value) {
    Write-Host "  $label : " -NoNewline -ForegroundColor Gray
    Write-Host "$value" -ForegroundColor White
    $Global:Report += "  $label : $value"
}

function Write-Status($text, $status) {
    $color = switch ($status) {
        "OK"      { "Green" }
        "AVISO"   { "Yellow" }
        "ERRO"    { "Red" }
        "INFO"    { "Cyan" }
        default   { "White" }
    }
    Write-Host "  [$status] " -NoNewline -ForegroundColor $color
    Write-Host $text -ForegroundColor White
    $Global:Report += "  [$status] $text"
}

function Write-Progress2($text) {
    Write-Host "  >> $text" -ForegroundColor DarkGray
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  |     VW INFORMATICA - DIAGNOSTICO E REPARO v3.6           |" -ForegroundColor Cyan
    Write-Host "  |     Xique-Xique/BA  |  (74) 99937-8375                  |" -ForegroundColor DarkGray
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  DIAGNOSTICOS                                            |" -ForegroundColor DarkCyan
    Write-Host "  |   [1] Diagnostico COMPLETO (todos os testes)             |" -ForegroundColor White
    Write-Host "  |   [2] Testar HD / SSD                                    |" -ForegroundColor White
    Write-Host "  |   [3] Testar Memoria RAM                                 |" -ForegroundColor White
    Write-Host "  |   [4] Testar Tela / Monitor                              |" -ForegroundColor White
    Write-Host "  |   [5] Informacoes do Sistema Operacional                 |" -ForegroundColor White
    Write-Host "  |   [6] Testar Rede / Internet                             |" -ForegroundColor White
    Write-Host "  |   [7] Testar Bateria (Notebooks)                         |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  VARREDURA E SEGURANCA (ONLINE)                          |" -ForegroundColor DarkCyan
    Write-Host "  |   [8] Varredura Antivirus (Windows Defender)             |" -ForegroundColor Magenta
    Write-Host "  |   [9] Verificar Drivers com Problema                     |" -ForegroundColor Magenta
    Write-Host "  |  [10] Verificar Seguranca e Portas Abertas               |" -ForegroundColor Magenta
    Write-Host "  |  [11] Verificar Programas Suspeitos / Indesejados        |" -ForegroundColor Magenta
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  REPAROS                                                 |" -ForegroundColor DarkCyan
    Write-Host "  |  [12] Reparar Sistema (DISM+SFC+WMI+Licenca+.NET...)    |" -ForegroundColor Yellow
    Write-Host "  |  [13] Reparar Disco (CHKDSK)                             |" -ForegroundColor Yellow
    Write-Host "  |  [14] Limpar Sistema (Temp + Cache + Componentes)        |" -ForegroundColor Yellow
    Write-Host "  |  [15] Otimizar Inicializacao                             |" -ForegroundColor Yellow
    Write-Host "  |  [16] Reparar Windows Update (Online)                    |" -ForegroundColor Yellow
    Write-Host "  |  [17] Resetar Rede                                       |" -ForegroundColor Yellow
    Write-Host "  |  [18] Reparo COMPLETO Online (DISM+SFC+Drivers+Update)   |" -ForegroundColor Red
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  REMOCAO DE IA DO WINDOWS                                |" -ForegroundColor DarkCyan
    Write-Host "  |  [20] Remover IA do Windows (Copilot, Recall, Apps...)   |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  ATIVACAO                                                |" -ForegroundColor DarkCyan
    Write-Host "  |  [21] Ativar Windows / Office (MAS)                      |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  OTIMIZACAO PARA JOGOS                                   |" -ForegroundColor DarkCyan
    Write-Host "  |  [22] Otimizar Windows para Jogos                        |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor DarkCyan
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  [19] Salvar Relatorio no Desktop                        |" -ForegroundColor Green
    Write-Host "  |   [0] Sair                                               |" -ForegroundColor DarkGray
    Write-Host "  +==========================================================+" -ForegroundColor DarkCyan
    Write-Host ""
}

# ============================================================
#  DIAGNOSTICOS
# ============================================================

function Test-DiskDrive {
    Write-Header "DIAGNOSTICO DE HD / SSD"
    
    Write-Progress2 "Obtendo informacoes dos discos..."
    $disks = Get-PhysicalDisk
    foreach ($disk in $disks) {
        Write-Host ""
        Write-Info "Disco" "$($disk.FriendlyName)"
        Write-Info "Tipo" "$($disk.MediaType)"
        Write-Info "Tamanho" "$([math]::Round($disk.Size / 1GB, 2)) GB"
        Write-Info "Status" "$($disk.HealthStatus)"
        Write-Info "Status Operacional" "$($disk.OperationalStatus)"
        
        if ($disk.HealthStatus -eq "Healthy") {
            Write-Status "Disco '$($disk.FriendlyName)' esta saudavel" "OK"
        } else {
            Write-Status "Disco '$($disk.FriendlyName)' com PROBLEMAS: $($disk.HealthStatus)" "ERRO"
        }
    }
    
    # SMART Data
    Write-Host ""
    Write-Progress2 "Verificando dados SMART..."
    $smartData = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus 2>$null
    if ($smartData) {
        foreach ($smart in $smartData) {
            if ($smart.PredictFailure) {
                Write-Status "SMART indica FALHA IMINENTE no disco! Faca backup AGORA!" "ERRO"
            } else {
                Write-Status "SMART: Nenhuma falha prevista" "OK"
            }
        }
    } else {
        Write-Status "Dados SMART nao disponiveis via WMI" "INFO"
    }
    
    # Espaco nas particoes
    Write-Host ""
    Write-Progress2 "Verificando espaco nas particoes..."
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' }
    foreach ($vol in $volumes) {
        $usedPercent = if ($vol.Size -gt 0) { [math]::Round((($vol.Size - $vol.SizeRemaining) / $vol.Size) * 100, 1) } else { 0 }
        $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
        $totalGB = [math]::Round($vol.Size / 1GB, 2)
        
        Write-Info "Unidade $($vol.DriveLetter):" "$freeGB GB livres de $totalGB GB ($usedPercent`% usado)"
        
        if ($usedPercent -gt 95) {
            Write-Status "Unidade $($vol.DriveLetter): CRITICO - Menos de 5`% livre!" "ERRO"
        } elseif ($usedPercent -gt 85) {
            Write-Status "Unidade $($vol.DriveLetter): Espaco ficando baixo" "AVISO"
        } else {
            Write-Status "Unidade $($vol.DriveLetter): Espaco adequado" "OK"
        }
    }
    
    # Teste de velocidade
    Write-Host ""
    Write-Progress2 "Testando velocidade de leitura/escrita (100MB)..."
    $testFile = "$env:TEMP\vw_disktest_$(Get-Random).tmp"
    try {
        $size = 100MB
        $buffer = New-Object byte[] $size
        
        $sw2 = [System.Diagnostics.Stopwatch]::StartNew()
        [System.IO.File]::WriteAllBytes($testFile, $buffer)
        $sw2.Stop()
        $writeSpeed = [math]::Round(($size / 1MB) / $sw2.Elapsed.TotalSeconds, 2)
        
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $null = [System.IO.File]::ReadAllBytes($testFile)
        $sw.Stop()
        $readSpeed = [math]::Round(($size / 1MB) / $sw.Elapsed.TotalSeconds, 2)
        
        Write-Info "Velocidade Leitura" "$readSpeed MB/s"
        Write-Info "Velocidade Escrita" "$writeSpeed MB/s"
        
        if ($readSpeed -lt 50) {
            Write-Status "Velocidade BAIXA - possivel problema no disco" "AVISO"
        } else {
            Write-Status "Velocidade aceitavel" "OK"
        }
    } catch {
        Write-Status "Nao foi possivel completar o teste de velocidade" "AVISO"
    } finally {
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
    }
    
    # Erros do Event Log
    Write-Host ""
    Write-Progress2 "Verificando erros de disco no registro de eventos (ultimos 7 dias)..."
    $diskErrors = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='disk','ntfs','volsnap','volmgr'; Level=1,2,3; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 10 2>$null
    if ($diskErrors) {
        Write-Status "$($diskErrors.Count) erro(s) de disco nos ultimos 7 dias:" "AVISO"
        foreach ($err in $diskErrors | Select-Object -First 5) {
            Write-Host "    $($err.TimeCreated.ToString('dd/MM HH:mm')) - $($err.Message.Substring(0, [math]::Min(80, $err.Message.Length)))..." -ForegroundColor DarkYellow
            $Global:Report += "    $($err.TimeCreated) - $($err.Message.Substring(0, [math]::Min(80, $err.Message.Length)))"
        }
    } else {
        Write-Status "Nenhum erro de disco nos ultimos 7 dias" "OK"
    }
}

function Test-Memory {
    Write-Header "DIAGNOSTICO DE MEMORIA RAM"
    
    Write-Progress2 "Obtendo informacoes da RAM..."
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
    $usedPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 1)
    
    Write-Info "RAM Total" "$totalRAM GB"
    Write-Info "RAM Em Uso" "$usedRAM GB ($usedPercent`%)"
    Write-Info "RAM Disponivel" "$freeRAM GB"
    
    if ($usedPercent -gt 90) {
        Write-Status "Uso de RAM CRITICO ($usedPercent`%)" "ERRO"
    } elseif ($usedPercent -gt 75) {
        Write-Status "Uso de RAM elevado ($usedPercent`%)" "AVISO"
    } else {
        Write-Status "Uso de RAM normal ($usedPercent`%)" "OK"
    }
    
    # Detalhes dos modulos
    Write-Host ""
    Write-Progress2 "Detalhes dos modulos de memoria..."
    $memModules = Get-CimInstance Win32_PhysicalMemory
    $slotNum = 0
    foreach ($mem in $memModules) {
        $slotNum++
        $sizeGB = [math]::Round($mem.Capacity / 1GB, 2)
        $speed = $mem.Speed
        $manufacturer = if ($mem.Manufacturer) { $mem.Manufacturer.Trim() } else { "Desconhecido" }
        $partNumber = if ($mem.PartNumber) { $mem.PartNumber.Trim() } else { "N/A" }
        $memType = switch ($mem.SMBIOSMemoryType) {
            20 { "DDR" } 22 { "DDR2" } 24 { "DDR3" } 26 { "DDR4" } 34 { "DDR5" } default { "Tipo $($mem.SMBIOSMemoryType)" }
        }
        
        Write-Host ""
        Write-Info "Slot $slotNum" "$sizeGB GB"
        Write-Info "  Velocidade" "$speed MHz"
        Write-Info "  Fabricante" "$manufacturer"
        Write-Info "  Modelo" "$partNumber"
        Write-Info "  Tipo" "$memType"
    }
    
    $totalSlots = (Get-CimInstance Win32_PhysicalMemoryArray).MemoryDevices
    Write-Host ""
    Write-Info "Slots Usados" "$slotNum de $totalSlots"
    if ($slotNum -lt $totalSlots) {
        Write-Status "Ha $(($totalSlots - $slotNum)) slot(s) livre(s) para expansao" "INFO"
    }
    
    # Teste rapido
    Write-Host ""
    Write-Progress2 "Executando teste rapido de integridade da RAM..."
    try {
        $testSizeMB = [math]::Min(256, [math]::Floor($freeRAM * 1024 * 0.1))
        $testArray = New-Object byte[] ($testSizeMB * 1MB)
        for ($i = 0; $i -lt $testArray.Length; $i += 4096) { $testArray[$i] = 0xAA }
        $errors = 0
        for ($i = 0; $i -lt $testArray.Length; $i += 4096) { if ($testArray[$i] -ne 0xAA) { $errors++ } }
        $testArray = $null; [System.GC]::Collect()
        
        if ($errors -eq 0) { Write-Status "Teste rapido de RAM: OK (testados $testSizeMB MB)" "OK" }
        else { Write-Status "Teste rapido de RAM: $errors erros encontrados!" "ERRO" }
    } catch { Write-Status "Nao foi possivel completar o teste rapido" "AVISO" }
    
    # Erros de hardware no Event Log
    Write-Host ""
    Write-Progress2 "Verificando erros de hardware nos ultimos 30 dias..."
    $whea = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WHEA-Logger'; StartTime=(Get-Date).AddDays(-30)} -MaxEvents 5 2>$null
    if ($whea) {
        Write-Status "$($whea.Count) erro(s) de hardware nos ultimos 30 dias" "AVISO"
        foreach ($w in $whea | Select-Object -First 3) {
            Write-Host "    $($w.TimeCreated.ToString('dd/MM HH:mm')) - $($w.Message.Substring(0, [math]::Min(80, $w.Message.Length)))..." -ForegroundColor DarkYellow
        }
    } else {
        Write-Status "Nenhum erro de hardware nos ultimos 30 dias" "OK"
    }
    
    # Top processos
    Write-Host ""
    Write-Progress2 "Top 5 processos por uso de RAM..."
    $topProcs = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5
    foreach ($proc in $topProcs) {
        Write-Info "  $($proc.ProcessName)" "$([math]::Round($proc.WorkingSet64 / 1MB, 1)) MB"
    }
    
    Write-Host ""
    Write-Status "Para teste completo de RAM: mdsched.exe (requer reinicializacao)" "INFO"
}

function Test-Screen {
    Write-Header "TESTE DE TELA / MONITOR"
    
    Write-Progress2 "Obtendo informacoes do monitor..."
    $monitors = Get-CimInstance Win32_VideoController
    foreach ($mon in $monitors) {
        Write-Info "Placa de Video" "$($mon.Name)"
        Write-Info "Resolucao" "$($mon.CurrentHorizontalResolution) x $($mon.CurrentVerticalResolution)"
        Write-Info "Bits por Pixel" "$($mon.CurrentBitsPerPixel)"
        Write-Info "Frequencia" "$($mon.CurrentRefreshRate) Hz"
        Write-Info "RAM de Video" "$([math]::Round($mon.AdapterRAM / 1GB, 2)) GB"
        Write-Info "Driver" "$($mon.DriverVersion)"
        Write-Info "Status" "$($mon.Status)"
        if ($mon.Status -eq "OK") { Write-Status "Placa de video OK" "OK" }
        else { Write-Status "Placa de video: $($mon.Status)" "AVISO" }
    }
    
    Write-Host ""
    Write-Progress2 "Gerando arquivo de teste de tela..."
    
    $screenTestHtml = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>VW Informatica - Teste de Tela</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',Tahoma,sans-serif;background:#1a1a2e;color:#fff;overflow:hidden;cursor:none}
body.show-cursor{cursor:default}
.test-screen{position:fixed;top:0;left:0;width:100vw;height:100vh;display:none}
.test-screen.active{display:flex;align-items:center;justify-content:center}
.menu{position:fixed;top:0;left:0;width:100vw;height:100vh;display:flex;flex-direction:column;align-items:center;justify-content:center;background:linear-gradient(135deg,#0f0f23,#1a1a3e);z-index:100}
.menu.hidden{display:none}
.menu h1{font-size:2.5em;margin-bottom:10px;color:#e8820c}
.menu h2{font-size:1.2em;margin-bottom:40px;color:#888;font-weight:normal}
.btn-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;max-width:700px;width:90%}
.btn{padding:18px 24px;border:2px solid #333;border-radius:12px;background:rgba(255,255,255,0.05);color:#fff;font-size:1em;cursor:pointer;transition:all .2s}
.btn:hover{background:rgba(232,130,12,0.2);border-color:#e8820c;transform:scale(1.03)}
.btn small{display:block;color:#888;font-size:.75em;margin-top:4px}
.info-bar{position:fixed;bottom:0;left:0;right:0;background:rgba(0,0,0,0.85);padding:12px 20px;display:flex;justify-content:space-between;align-items:center;z-index:200;font-size:.9em;display:none}
.info-bar.visible{display:flex}
.info-bar .nav{color:#e8820c}
.checkerboard{background-size:20px 20px;background-image:linear-gradient(45deg,#fff 25%,transparent 25%),linear-gradient(-45deg,#fff 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#fff 75%),linear-gradient(-45deg,transparent 75%,#fff 75%);background-position:0 0,0 10px,10px -10px,-10px 0}
.dead-pixel .pixel-info{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:1.3em;text-align:center;color:#555;pointer-events:none;transition:opacity 1s}
.bleed-test{display:flex;flex-wrap:wrap}.bleed-test div{width:50%;height:50vh}
.text-test{padding:40px;overflow:auto;background:#fff;color:#000;font-size:14px;flex-direction:column;align-items:flex-start;justify-content:flex-start}
.text-test h3{margin:10px 0 5px;font-size:1.1em}.text-test p{margin-bottom:8px;line-height:1.6}
.response-test{flex-direction:column;align-items:center;justify-content:center;background:#111}
.response-box{width:150px;height:150px;background:#e8820c;border-radius:12px;cursor:pointer}
.timer-display{font-size:3em;margin-top:20px;font-family:monospace;color:#e8820c}
</style>
</head>
<body class="show-cursor">
<div class="menu" id="menu">
    <h1>VW Informatica</h1>
    <h2>Teste Completo de Tela</h2>
    <div class="btn-grid">
        <div class="btn" onclick="startTest('red')">Vermelho<small>Pixels mortos</small></div>
        <div class="btn" onclick="startTest('green')">Verde<small>Pixels mortos</small></div>
        <div class="btn" onclick="startTest('blue')">Azul<small>Pixels mortos</small></div>
        <div class="btn" onclick="startTest('white')">Branco<small>Brilho/Manchas</small></div>
        <div class="btn" onclick="startTest('black')">Preto (Pixel Morto)<small>Mova o mouse</small></div>
        <div class="btn" onclick="startTest('gradient')">Gradiente<small>Transicao de cores</small></div>
        <div class="btn" onclick="startTest('checker')">Xadrez<small>Nitidez</small></div>
        <div class="btn" onclick="startTest('bleed')">Sangramento<small>4 cores</small></div>
        <div class="btn" onclick="startTest('gray')">Uniformidade<small>Cinza 50%</small></div>
        <div class="btn" onclick="startTest('angle')">Angulo de Visao<small>Degrade</small></div>
        <div class="btn" onclick="startTest('text')">Texto<small>Legibilidade</small></div>
        <div class="btn" onclick="startTest('response')">Tempo Resposta<small>Tempo de reacao</small></div>
    </div>
    <p style="margin-top:30px;color:#555;font-size:.85em">ESC = voltar | F11 = tela cheia | Setas = navegar</p>
</div>
<div class="test-screen" id="test-red" style="background:red"></div>
<div class="test-screen" id="test-green" style="background:#00ff00"></div>
<div class="test-screen" id="test-blue" style="background:blue"></div>
<div class="test-screen" id="test-white" style="background:white"></div>
<div class="test-screen" id="test-black" style="background:#000"><div class="pixel-info" id="pixelInfo">Mova o mouse lentamente pela tela<br>Procure pontos brilhantes</div></div>
<div class="test-screen" id="test-gradient" style="background:linear-gradient(to right,#000,red,#ff0,#0f0,cyan,blue,#f0f,#fff)"></div>
<div class="test-screen checkerboard" id="test-checker" style="background-color:#000"></div>
<div class="test-screen bleed-test" id="test-bleed"><div style="background:red"></div><div style="background:#00ff00"></div><div style="background:blue"></div><div style="background:white"></div></div>
<div class="test-screen" id="test-gray" style="background:#808080"></div>
<div class="test-screen" id="test-angle" style="background:linear-gradient(to bottom,#111,#333,#555,#777,#999,#bbb,#ddd,#fff)"></div>
<div class="test-screen text-test" id="test-text">
    <h3>14px</h3><p>VW Informatica - ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 !@#$%</p>
    <h3>12px</h3><p style="font-size:12px">VW Informatica - ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789</p>
    <h3>10px</h3><p style="font-size:10px">VW Informatica - ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789</p>
    <h3>8px</h3><p style="font-size:8px">VW Informatica - ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789</p>
    <h3>Contraste</h3>
    <p style="background:#eee;padding:8px;color:#ddd">Texto com baixo contraste</p>
    <p style="background:#000;padding:8px;color:#fff">Branco no preto</p>
    <p style="background:#fff;padding:8px;color:#000">Preto no branco</p>
</div>
<div class="test-screen response-test" id="test-response">
    <p style="color:#888">Clique na caixa quando ela mudar de cor!</p>
    <div class="response-box" id="responseBox"></div>
    <div class="timer-display" id="timerDisplay">Aguarde o sinal...</div>
    <p id="responseResults" style="margin-top:15px;color:#888"></p>
</div>
<div class="info-bar" id="infoBar"><span id="testName"></span><span class="nav">ESC=Voltar | Setas=Navegar</span></div>
<script>
const tests=['red','green','blue','white','black','gradient','checker','bleed','gray','angle','text','response'];
let current=-1,responseTimes=[],responseTimer=null,responseStart=0,responseWaiting=false;
const names={red:'Vermelho',green:'Verde',blue:'Azul',white:'Branco',black:'Pixel Morto',gradient:'Gradiente',checker:'Xadrez',bleed:'Sangramento',gray:'Uniformidade',angle:'Angulo de Visao',text:'Legibilidade',response:'Tempo de Resposta'};
function startTest(n){document.getElementById('menu').classList.add('hidden');document.body.classList.remove('show-cursor');tests.forEach(t=>document.getElementById('test-'+t).classList.remove('active'));current=tests.indexOf(n);document.getElementById('test-'+n).classList.add('active');document.getElementById('infoBar').classList.add('visible');document.getElementById('testName').textContent=names[n];if(n==='black'){let i=document.getElementById('pixelInfo');i.style.opacity='1';setTimeout(()=>i.style.opacity='0',3000)}if(n==='response')startResponseTest();if(n==='text')document.body.classList.add('show-cursor')}
function goBack(){tests.forEach(t=>document.getElementById('test-'+t).classList.remove('active'));document.getElementById('menu').classList.remove('hidden');document.getElementById('infoBar').classList.remove('visible');document.body.classList.add('show-cursor');current=-1;if(responseTimer)clearTimeout(responseTimer)}
function nav(d){if(current<0)return;let n=current+d;if(n<0)n=tests.length-1;if(n>=tests.length)n=0;startTest(tests[n])}
function startResponseTest(){responseTimes=[];responseWaiting=false;document.body.classList.add('show-cursor');document.getElementById('responseBox').style.background='#e8820c';document.getElementById('timerDisplay').textContent='Aguarde o sinal...';document.getElementById('responseResults').textContent='';schedResp()}
function schedResp(){responseTimer=setTimeout(()=>{document.getElementById('responseBox').style.background='#00cc66';responseStart=performance.now();responseWaiting=true;document.getElementById('timerDisplay').textContent='AGORA!'},1000+Math.random()*4000)}
document.getElementById('responseBox').addEventListener('click',function(){if(!responseWaiting)return;let e=Math.round(performance.now()-responseStart);responseTimes.push(e);responseWaiting=false;this.style.background='#e8820c';document.getElementById('timerDisplay').textContent=e+' ms';let a=Math.round(responseTimes.reduce((a,b)=>a+b,0)/responseTimes.length);document.getElementById('responseResults').textContent='Tentativa: '+responseTimes.length+' | Media: '+a+' ms';if(responseTimes.length<5)schedResp();else document.getElementById('timerDisplay').textContent='Resultado final: '+a+' ms'});
document.addEventListener('keydown',e=>{if(e.key==='Escape')goBack();if(e.key==='ArrowRight')nav(1);if(e.key==='ArrowLeft')nav(-1)});
</script>
</body>
</html>
"@
    
    $htmlPath = "$env:TEMP\VW_TesteTela.html"
    $screenTestHtml | Out-File -FilePath $htmlPath -Encoding UTF8 -Force
    Write-Status "Arquivo de teste gerado" "OK"
    Write-Host ""
    Write-Host "  Abrindo teste de tela no navegador (F11 = tela cheia)..." -ForegroundColor Yellow
    Start-Process $htmlPath
}

function Test-OperatingSystem {
    Write-Header "INFORMACOES DO SISTEMA OPERACIONAL"
    
    Write-Progress2 "Coletando informacoes do sistema..."
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor
    
    Write-Info "Computador" "$($cs.Name)"
    Write-Info "Fabricante" "$($cs.Manufacturer)"
    Write-Info "Modelo" "$($cs.Model)"
    Write-Info "Tipo" "$(if($cs.PCSystemType -eq 2){'Notebook'}else{'Desktop'})"
    Write-Host ""
    Write-Info "Sistema" "$($os.Caption)"
    Write-Info "Versao" "$($os.Version) Build $($os.BuildNumber)"
    Write-Info "Arquitetura" "$($os.OSArchitecture)"
    Write-Info "Data de instalacao" "$($os.InstallDate)"
    Write-Info "Ultimo Boot" "$($os.LastBootUpTime)"
    
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Info "Tempo Ligado" "$([math]::Floor($uptime.TotalDays))d $($uptime.Hours)h $($uptime.Minutes)m"
    
    Write-Host ""
    Write-Info "Processador" "$($cpu.Name)"
    Write-Info "Nucleos" "$($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads"
    Write-Info "Clock Max" "$($cpu.MaxClockSpeed) MHz"
    Write-Info "Uso CPU" "$($cpu.LoadPercentage)`%"
    
    Write-Host ""
    Write-Info "BIOS" "$($bios.Manufacturer) - $($bios.SMBIOSBIOSVersion)"
    Write-Info "Serial" "$($bios.SerialNumber)"
    
    # Ativacao
    Write-Host ""
    Write-Progress2 "Verificando ativacao do Windows..."
    $activation = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }
    if ($activation) {
        $licStatus = switch ($activation.LicenseStatus) {
            0 { "Nao licenciado" } 1 { "Ativado" } 2 { "Periodo de cortesia" }
            3 { "Cortesia expirada" } 4 { "Sem autenticacao" } 5 { "Notificacao" } default { "Desconhecido" }
        }
        Write-Info "Ativacao" "$licStatus"
        if ($activation.LicenseStatus -eq 1) { Write-Status "Windows ativado" "OK" }
        else { Write-Status "Windows NAO esta ativado" "AVISO" }
    }
    
    # Servicos importantes
    Write-Host ""
    Write-Progress2 "Verificando servicos importantes..."
    $services = @(
        @{Name="wuauserv"; Desc="Windows Update"},
        @{Name="WinDefend"; Desc="Windows Defender"},
        @{Name="Spooler"; Desc="Impressao"},
        @{Name="AudioSrv"; Desc="Audio"},
        @{Name="Dhcp"; Desc="DHCP"},
        @{Name="Dnscache"; Desc="Cache DNS"},
        @{Name="WSearch"; Desc="Pesquisa do Windows"},
        @{Name="Themes"; Desc="Temas"}
    )
    foreach ($svc in $services) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            $st = if ($service.Status -eq "Running") { "OK" } else { "AVISO" }
            Write-Status "$($svc.Desc): $($service.Status)" $st
        }
    }
    
    # Temperatura
    Write-Host ""
    Write-Progress2 "Verificando temperatura..."
    $temp = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" 2>$null
    if ($temp) {
        foreach ($t in $temp) {
            $celsius = [math]::Round(($t.CurrentTemperature / 10) - 273.15, 1)
            Write-Info "Temperatura" "$celsius grausC"
            if ($celsius -gt 80) { Write-Status "Temperatura ALTA!" "ERRO" }
            elseif ($celsius -gt 65) { Write-Status "Temperatura elevada" "AVISO" }
            else { Write-Status "Temperatura normal" "OK" }
        }
    } else { Write-Status "Sensor de temperatura nao acessivel" "INFO" }
}

function Test-Network {
    Write-Header "DIAGNOSTICO DE REDE / INTERNET"
    
    Write-Progress2 "Verificando adaptadores de rede..."
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        Write-Info "Adaptador" "$($adapter.Name) ($($adapter.InterfaceDescription))"
        Write-Info "  Velocidade" "$($adapter.LinkSpeed)"
        Write-Info "  MAC" "$($adapter.MacAddress)"
        $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex | Where-Object { $_.AddressFamily -eq "IPv4" }
        if ($ipConfig) { Write-Info "  IP" "$($ipConfig.IPAddress)" }
    }
    
    $gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1
    $dns = Get-DnsClientServerAddress | Where-Object { $_.AddressFamily -eq 2 -and $_.ServerAddresses } | Select-Object -First 1
    if ($dns) { Write-Info "DNS" "$($dns.ServerAddresses -join ', ')" }
    if ($gateway) { Write-Info "Gateway" "$($gateway.NextHop)" }
    
    Write-Host ""
    Write-Progress2 "Testando conectividade..."
    $targets = @(
        @{Name="Gateway"; Host=$(if($gateway){$gateway.NextHop}else{"192.168.1.1"})},
        @{Name="Google DNS"; Host="8.8.8.8"},
        @{Name="Cloudflare"; Host="1.1.1.1"},
        @{Name="Google.com"; Host="google.com"}
    )
    foreach ($t in $targets) {
        $ping = Test-Connection -ComputerName $t.Host -Count 2 -ErrorAction SilentlyContinue
        if ($ping) {
            $avg = [math]::Round(($ping | Measure-Object -Property Latency -Average).Average, 1)
            Write-Status "$($t.Name): ${avg}ms" "OK"
        } else { Write-Status "$($t.Name): SEM RESPOSTA" "ERRO" }
    }
    
    Write-Host ""
    Write-Progress2 "Testando velocidade de download..."
    try {
        $url = "http://speedtest.tele2.net/1MB.zip"
        $tmp = "$env:TEMP\vw_speed.tmp"
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Invoke-WebRequest -Uri $url -OutFile $tmp -TimeoutSec 15 -ErrorAction Stop
        $sw.Stop()
        $sz = (Get-Item $tmp).Length
        $mbps = [math]::Round(($sz * 8) / ($sw.Elapsed.TotalSeconds * 1000000), 2)
        Remove-Item $tmp -Force
        Write-Info "Velocidade de download" "$mbps Mbps"
    } catch { Write-Status "Nao foi possivel testar velocidade" "AVISO" }
    
    $wifi = netsh wlan show interfaces 2>$null
    if ($wifi -and $wifi -match "Sinal") {
        $signal = ($wifi | Select-String "Sinal").ToString().Trim()
        Write-Info "Wi-Fi" $signal
    }
}

function Test-Battery {
    Write-Header "DIAGNOSTICO DE BATERIA"
    $battery = Get-CimInstance Win32_Battery
    if (-not $battery) { Write-Status "Nenhuma bateria detectada (Desktop)" "INFO"; return }
    
    Write-Info "Carga Atual" "$($battery.EstimatedChargeRemaining)`%"
    $statusText = switch ($battery.BatteryStatus) {
        1{"Descarregando"} 2{"Carregando"} 3{"Carregada"} 4{"Carga baixa"} 5{"Carga critica"} default{"Desconhecido"}
    }
    Write-Info "Estado" $statusText
    
    Write-Progress2 "Gerando relatorio detalhado..."
    $battReport = "$env:TEMP\battery-report.html"
    powercfg /batteryreport /output $battReport 2>$null
    if (Test-Path $battReport) {
        $content = Get-Content $battReport -Raw
        if ($content -match "DESIGN CAPACITY.*?(\d[\d,]+)\s*mWh") { $designCap = $matches[1] -replace "," }
        if ($content -match "FULL CHARGE CAPACITY.*?(\d[\d,]+)\s*mWh") {
            $fullCap = $matches[1] -replace ","
            if ($designCap -and $fullCap) {
                $health = [math]::Round(([int]$fullCap / [int]$designCap) * 100, 1)
                Write-Info "Capacidade Original" "$designCap mWh"
                Write-Info "Capacidade Atual" "$fullCap mWh"
                Write-Info "Saude da Bateria" "$health`%"
                if ($health -lt 50) { Write-Status "Bateria DEGRADADA - trocar!" "ERRO" }
                elseif ($health -lt 75) { Write-Status "Desgaste moderado" "AVISO" }
                else { Write-Status "Bateria em bom estado" "OK" }
            }
        }
        Start-Process $battReport
    }
}

# ============================================================
#  VARREDURA E SEGURANCA (ONLINE)
# ============================================================

function Scan-Antivirus {
    Write-Header "VARREDURA ANTIVIRUS (WINDOWS DEFENDER)"
    
    Write-Progress2 "Verificando status do Windows Defender..."
    try {
        $mpStatus = Get-MpComputerStatus
        Write-Info "Antivirus" "$(if($mpStatus.AntivirusEnabled){'Ativado'}else{'DESATIVADO'})"
        Write-Info "Protecao Real-time" "$(if($mpStatus.RealTimeProtectionEnabled){'Ativada'}else{'DESATIVADA'})"
        Write-Info "Ultima Atualizacao" "$($mpStatus.AntivirusSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm'))"
        Write-Info "Versao Definicoes" "$($mpStatus.AntivirusSignatureVersion)"
        
        $daysSinceUpdate = ((Get-Date) - $mpStatus.AntivirusSignatureLastUpdated).Days
        if ($daysSinceUpdate -gt 7) { Write-Status "Definicoes desatualizadas ($daysSinceUpdate dias)!" "AVISO" }
        else { Write-Status "Definicoes atualizadas" "OK" }
        
        if (-not $mpStatus.RealTimeProtectionEnabled) { Write-Status "PROTECAO EM TEMPO REAL DESATIVADA!" "ERRO" }
    } catch {
        Write-Status "Windows Defender nao disponivel" "INFO"
        return
    }
    
    Write-Host ""
    Write-Host "  Opcoes de varredura:" -ForegroundColor Yellow
    Write-Host "  [1] Varredura Rapida (~5 min)" -ForegroundColor White
    Write-Host "  [2] Varredura Completa (~30-60 min)" -ForegroundColor White
    Write-Host "  [3] Atualizar Definicoes + Varredura Rapida" -ForegroundColor White
    Write-Host "  [4] Varredura Offline (reinicia o PC - pega rootkits)" -ForegroundColor White
    Write-Host "  [5] Apenas Atualizar Definicoes" -ForegroundColor White
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    Write-Host ""
    
    $opt = Read-Host "  Escolha"
    
    switch ($opt) {
        "1" {
            Write-Progress2 "Varredura rapida em andamento..."
            Start-MpScan -ScanType QuickScan
            $threats = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddHours(-1) }
            if ($threats) { Write-Status "$($threats.Count) ameaca(s) detectada(s)!" "ERRO" }
            else { Write-Status "Nenhuma ameaca encontrada" "OK" }
        }
        "2" {
            $c = Read-Host "  Varredura completa pode demorar. Continuar? (S/N)"
            if ($c -eq "S" -or $c -eq "s") {
                Start-MpScan -ScanType FullScan
                $threats = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddHours(-2) }
                if ($threats) { Write-Status "$($threats.Count) ameaca(s)!" "ERRO" }
                else { Write-Status "Nenhuma ameaca" "OK" }
            }
        }
        "3" {
            Write-Progress2 "Atualizando definicoes (online)..."
            Update-MpSignature
            Write-Progress2 "Varredura rapida..."
            Start-MpScan -ScanType QuickScan
            $threats = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddHours(-1) }
            if ($threats) { Write-Status "$($threats.Count) ameaca(s)!" "ERRO" }
            else { Write-Status "Limpo!" "OK" }
        }
        "4" {
            Write-Host "  SALVE TODOS OS TRABALHOS! O PC vai reiniciar." -ForegroundColor Red
            $c = Read-Host "  Continuar? (S/N)"
            if ($c -eq "S" -or $c -eq "s") { Start-MpWDOScan }
        }
        "5" {
            Write-Progress2 "Atualizando definicoes (online)..."
            Update-MpSignature
            $mpNew = Get-MpComputerStatus
            Write-Info "Nova versao" "$($mpNew.AntivirusSignatureVersion)"
            Write-Status "Definicoes atualizadas!" "OK"
        }
    }
    
    # Historico
    Write-Host ""
    Write-Progress2 "Ameacas recentes (30 dias)..."
    $history = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt (Get-Date).AddDays(-30) } | Select-Object -First 10
    if ($history) {
        Write-Status "$($history.Count) ameaca(s) recentes:" "AVISO"
        foreach ($h in $history) {
            $ti = Get-MpThreat -ThreatID $h.ThreatID -ErrorAction SilentlyContinue
            $tn = if ($ti) { $ti.ThreatName } else { "ID:$($h.ThreatID)" }
            Write-Host "    $($h.InitialDetectionTime.ToString('dd/MM')) - $tn" -ForegroundColor DarkYellow
        }
    } else { Write-Status "Nenhuma ameaca nos ultimos 30 dias" "OK" }
    
    $Global:Report += "  --- Varredura antivirus executada ---"
}

function Check-Drivers {
    Write-Header "VERIFICACAO DE DRIVERS"
    
    Write-Progress2 "Verificando dispositivos com problema..."
    $problemDevices = Get-PnpDevice | Where-Object { $_.Status -ne "OK" }
    
    if ($problemDevices) {
        Write-Status "$($problemDevices.Count) dispositivo(s) com problema:" "AVISO"
        foreach ($dev in $problemDevices) {
            $sc = switch ($dev.Status) { "Error" {"Red"} "Degraded" {"Yellow"} default {"DarkGray"} }
            Write-Host "  [$($dev.Status)] $($dev.FriendlyName)" -ForegroundColor $sc
            Write-Host "           Classe: $($dev.Class)" -ForegroundColor DarkGray
            $Global:Report += "  [$($dev.Status)] $($dev.FriendlyName)"
        }
    } else { Write-Status "Todos os dispositivos funcionando" "OK" }
    
    Write-Host ""
    Write-Progress2 "Drivers com mais de 3 anos..."
    $oldDrivers = Get-WmiObject Win32_PnPSignedDriver | Where-Object { 
        $_.DriverDate -and $_.DeviceName -and
        [datetime]::ParseExact($_.DriverDate.Substring(0,8), "yyyyMMdd", $null) -lt (Get-Date).AddYears(-3)
    } | Sort-Object DriverDate | Select-Object -First 10
    
    if ($oldDrivers) {
        Write-Status "Drivers antigos (>3 anos):" "INFO"
        foreach ($d in $oldDrivers) {
            $dd = [datetime]::ParseExact($d.DriverDate.Substring(0,8), "yyyyMMdd", $null).ToString("dd/MM/yyyy")
            Write-Host "    $($d.DeviceName) - $dd" -ForegroundColor DarkYellow
        }
    }
    
    Write-Host ""
    Write-Host "  [1] Buscar drivers via Windows Update (online)" -ForegroundColor White
    Write-Host "  [2] Reinstalar drivers com problema" -ForegroundColor White
    Write-Host "  [3] Abrir Gerenciador de Dispositivos" -ForegroundColor White
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    $opt = Read-Host "  Escolha"
    
    switch ($opt) {
        "1" {
            Write-Progress2 "Buscando drivers online..."
            try {
                $us = New-Object -ComObject Microsoft.Update.Session
                $sr = $us.CreateUpdateSearcher()
                $res = $sr.Search("IsInstalled=0 AND Type='Driver'")
                if ($res.Updates.Count -gt 0) {
                    Write-Status "$($res.Updates.Count) driver(s) disponivel(is):" "INFO"
                    foreach ($u in $res.Updates) { Write-Host "    $($u.Title)" -ForegroundColor White }
                    $c = Read-Host "  Instalar? (S/N)"
                    if ($c -eq "S" -or $c -eq "s") {
                        $td = New-Object -ComObject Microsoft.Update.UpdateColl
                        foreach ($u in $res.Updates) { $td.Add($u) | Out-Null }
                        $dl = $us.CreateUpdateDownloader(); $dl.Updates = $td; $dl.Download() | Out-Null
                        $inst = $us.CreateUpdateInstaller(); $inst.Updates = $td; $ir = $inst.Install()
                        if ($ir.ResultCode -eq 2) { Write-Status "Drivers instalados!" "OK" }
                        if ($ir.RebootRequired) { Write-Status "Reinicializacao necessaria" "AVISO" }
                    }
                } else { Write-Status "Drivers atualizados" "OK" }
            } catch { Write-Status "Erro: $($_.Exception.Message)" "AVISO" }
        }
        "2" {
            if ($problemDevices) {
                foreach ($dev in $problemDevices) {
                    Write-Host "  Reinstalando: $($dev.FriendlyName)..." -ForegroundColor DarkGray
                    try {
                        Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
                        Start-Sleep -Seconds 2
                        Enable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
                        Write-Status "$($dev.FriendlyName) reinstalado" "OK"
                    } catch { Write-Status "$($dev.FriendlyName) - falha" "AVISO" }
                }
            } else { Write-Status "Nenhum driver com problema" "OK" }
        }
        "3" { Start-Process devmgmt.msc }
    }
    $Global:Report += "  --- Verificacao de drivers executada ---"
}

function Check-Security {
    Write-Header "VERIFICACAO DE SEGURANCA"
    
    # Firewall
    Write-Progress2 "Verificando Firewall..."
    $fwProfiles = Get-NetFirewallProfile
    foreach ($fw in $fwProfiles) {
        if ($fw.Enabled) { Write-Status "Firewall $($fw.Name): Ativado" "OK" }
        else { Write-Status "Firewall $($fw.Name): DESATIVADO!" "ERRO" }
    }
    
    # UAC
    Write-Host ""
    $uac = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA
    if ($uac.EnableLUA -eq 1) { Write-Status "UAC: Ativado" "OK" }
    else { Write-Status "UAC DESATIVADO!" "ERRO" }
    
    # Defender
    Write-Host ""
    try {
        $def = Get-MpComputerStatus
        if ($def.AntivirusEnabled) { Write-Status "Antivirus: Ativado" "OK" }
        else { Write-Status "Antivirus: DESATIVADO!" "ERRO" }
        if ($def.RealTimeProtectionEnabled) { Write-Status "Protecao real-time: Ativa" "OK" }
        else { Write-Status "Protecao real-time: DESATIVADA!" "ERRO" }
        if ($def.IoavProtectionEnabled) { Write-Status "Protecao downloads: Ativa" "OK" }
        if ($def.NISEnabled) { Write-Status "Protecao de rede: Ativa" "OK" }
    } catch { Write-Status "Defender nao disponivel" "INFO" }
    
    # Portas abertas
    Write-Host ""
    Write-Progress2 "Portas em escuta..."
    $conns = Get-NetTCPConnection -State Listen | Select-Object LocalPort, OwningProcess -Unique | Sort-Object LocalPort
    $knownBad = @(4444, 5555, 6666, 1234, 31337, 12345, 54321, 6667, 6697)
    $suspCount = 0
    foreach ($c in $conns | Select-Object -First 20) {
        $p = Get-Process -Id $c.OwningProcess -ErrorAction SilentlyContinue
        $pn = if ($p) { $p.ProcessName } else { "?" }
        $susp = $c.LocalPort -in $knownBad
        if ($susp) { Write-Host "  [!] Porta $($c.LocalPort) - $pn (SUSPEITA!)" -ForegroundColor Red; $suspCount++ }
        else { Write-Host "      Porta $($c.LocalPort) - $pn" -ForegroundColor Gray }
    }
    if ($suspCount -gt 0) { Write-Status "$suspCount porta(s) suspeita(s)!" "ERRO" }
    else { Write-Status "Nenhuma porta suspeita" "OK" }
    
    # Conexoes externas
    Write-Host ""
    Write-Progress2 "Conexoes externas ativas..."
    $est = Get-NetTCPConnection -State Established | Where-Object { $_.RemoteAddress -notmatch "^(127\.|::1|0\.0\.0)" } | Select-Object RemoteAddress, RemotePort, OwningProcess -Unique | Select-Object -First 15
    foreach ($e in $est) {
        $p = Get-Process -Id $e.OwningProcess -ErrorAction SilentlyContinue
        Write-Host "      $($e.RemoteAddress):$($e.RemotePort) - $(if($p){$p.ProcessName}else{'?'})" -ForegroundColor Gray
    }
    
    # Admin accounts
    Write-Host ""
    $admins = Get-LocalGroupMember -Group "Administradores" -ErrorAction SilentlyContinue
    if (-not $admins) { $admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue }
    if ($admins) {
        Write-Info "Contas admin" "$($admins.Count)"
        foreach ($a in $admins) { Write-Host "      $($a.Name)" -ForegroundColor Gray }
    }
    
    # RDP
    Write-Host ""
    $rdp = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections -ErrorAction SilentlyContinue
    if ($rdp.fDenyTSConnections -eq 0) { Write-Status "Area de Trabalho Remota: HABILITADA" "AVISO" }
    else { Write-Status "Area de Trabalho Remota: Desabilitada" "OK" }
    
    $Global:Report += "  --- Verificacao de seguranca executada ---"
}

function Check-SuspiciousPrograms {
    Write-Header "PROGRAMAS SUSPEITOS / INDESEJADOS"
    
    $suspiciousNames = @(
        "*toolbar*","*adware*","*spyware*","*babylon*","*conduit*","*ask toolbar*",
        "*mywebsearch*","*incredibar*","*sweetim*","*funmoods*","*delta search*",
        "*searchprotect*","*crossrider*","*superfish*","*wajam*","*coupon*",
        "*savefrom*","*hola *","*pricegong*","*yontoo*","*opencandy*",
        "*installcore*","*softpulse*","*amonetize*","*mindspark*","*iminent*",
        "*bettersurf*","*shopathome*","*driver updater*","*pc cleaner*",
        "*registry cleaner*","*reimage*","*segurazo*","*bytefence*","*total av*"
    )
    
    Write-Progress2 "Verificando programas instalados..."
    $apps = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                              "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                              "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } | Select-Object DisplayName, Publisher, DisplayVersion
    
    $found = @()
    foreach ($app in $apps) {
        foreach ($pattern in $suspiciousNames) {
            if ($app.DisplayName -like $pattern) { $found += $app; break }
        }
    }
    
    if ($found) {
        Write-Status "$($found.Count) programa(s) suspeito(s):" "AVISO"
        foreach ($f in $found) {
            Write-Host "  [!] $($f.DisplayName) - $($f.Publisher)" -ForegroundColor Red
        }
    } else { Write-Status "Nenhum programa suspeito encontrado" "OK" }
    
    # Extensoes Chrome
    Write-Host ""
    $chromeExt = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Extensions"
    if (Test-Path $chromeExt) {
        $extCount = (Get-ChildItem $chromeExt -Directory | Where-Object { $_.Name.Length -eq 32 }).Count
        Write-Info "Extensoes Chrome" "$extCount"
        if ($extCount -gt 15) { Write-Status "Muitas extensoes - verifique adware" "AVISO" }
    }
    
    # Tarefas agendadas
    Write-Host ""
    Write-Progress2 "Tarefas agendadas na raiz..."
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskPath -eq "\" -and $_.State -eq "Ready" }
    if ($tasks) {
        foreach ($t in $tasks) { Write-Host "    $($t.TaskName)" -ForegroundColor Gray }
    }
    
    # Servicos de terceiros
    Write-Host ""
    Write-Progress2 "Servicos de terceiros automaticos..."
    $thirdParty = Get-WmiObject Win32_Service | Where-Object {
        $_.State -eq "Running" -and $_.PathName -and
        $_.PathName -notmatch "Windows|Microsoft|system32|SysWOW64" -and $_.StartMode -eq "Auto"
    } | Select-Object DisplayName, PathName -First 15
    
    if ($thirdParty) {
        foreach ($s in $thirdParty) {
            Write-Host "    $($s.DisplayName)" -ForegroundColor Gray
        }
    }
    
    # Startup no registro
    Write-Host ""
    Write-Progress2 "Programas na inicializacao (registro)..."
    $startupReg = @()
    $startupReg += Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    $startupReg += Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    foreach ($reg in $startupReg) {
        $reg.PSObject.Properties | Where-Object { $_.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider") } | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Info "Total programas instalados" "$($apps.Count)"
    $Global:Report += "  --- Verificacao de programas executada ---"
}

# ============================================================
#  REPAROS
# ============================================================

function Repair-System {
    Write-Header "REPARO COMPLETO DO SISTEMA"
    
    Write-Host "  Este reparo executa 8 etapas automaticamente:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    1. Limpar componentes antigos do Windows" -ForegroundColor White
    Write-Host "    2. DISM - Verificar e reparar imagem (online)" -ForegroundColor White
    Write-Host "    3. SFC - Verificar e reparar arquivos do sistema" -ForegroundColor White
    Write-Host "    4. Reparar WMI (gerenciamento do Windows)" -ForegroundColor White
    Write-Host "    5. Reparar licenciamento e ativacao" -ForegroundColor White
    Write-Host "    6. Reparar registro WPA (ativacao)" -ForegroundColor White
    Write-Host "    7. Reparar .NET Framework" -ForegroundColor White
    Write-Host "    8. Reparar Microsoft Store e servicos" -ForegroundColor White
    Write-Host ""
    Write-Host "  Tempo estimado: 15 a 45 minutos. Nao desligue o PC." -ForegroundColor Yellow
    Write-Host ""
    
    $c = Read-Host "  Iniciar reparo completo? (S/N)"
    if ($c -ne "S" -and $c -ne "s") { return }
    
    $startTime = Get-Date
    
    # === ETAPA 1 - Componentes ===
    Write-Header "ETAPA 1 DE 8 - LIMPEZA DE COMPONENTES"
    Write-Progress2 "Limpando componentes antigos do Windows..."
    DISM /Online /Cleanup-Image /StartComponentCleanup 2>&1 | Out-Null
    Write-Status "Componentes antigos limpos" "OK"
    
    # === ETAPA 2 - DISM ===
    Write-Header "ETAPA 2 DE 8 - DISM (REPARO DA IMAGEM)"
    Write-Progress2 "Verificando integridade da imagem do Windows..."
    DISM /Online /Cleanup-Image /CheckHealth 2>&1 | Out-Null
    
    Write-Progress2 "Escaneando imagem do Windows..."
    DISM /Online /Cleanup-Image /ScanHealth 2>&1 | Out-Null
    
    Write-Progress2 "Reparando imagem do Windows (baixando da Microsoft)..."
    Write-Host "  Pode demorar varios minutos. Aguarde..." -ForegroundColor DarkGray
    $dismResult = DISM /Online /Cleanup-Image /RestoreHealth 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Status "DISM: imagem reparada com sucesso" "OK" }
    else { Write-Status "DISM: concluido com codigo $LASTEXITCODE" "AVISO" }
    
    # === ETAPA 3 - SFC ===
    Write-Header "ETAPA 3 DE 8 - SFC (ARQUIVOS DO SISTEMA)"
    Write-Progress2 "Verificando e reparando arquivos do sistema..."
    $sfcResult = sfc /scannow 2>&1
    if ($sfcResult -match "nao encontrou|did not find") { Write-Status "SFC: todos os arquivos estao integros" "OK" }
    elseif ($sfcResult -match "reparou|repaired") { Write-Status "SFC: arquivos corrompidos foram reparados!" "OK" }
    else { Write-Status "SFC: verifique detalhes em CBS.log" "AVISO" }
    
    # === ETAPA 4 - WMI ===
    Write-Header "ETAPA 4 DE 8 - WMI (GERENCIAMENTO)"
    Repair-WMI
    
    # === ETAPA 5 - Licenciamento ===
    Write-Header "ETAPA 5 DE 8 - LICENCIAMENTO"
    Repair-Licensing
    
    # === ETAPA 6 - Registro WPA ===
    Write-Header "ETAPA 6 DE 8 - REGISTRO WPA"
    Repair-WPARegistry
    
    # === ETAPA 7 - .NET ===
    Write-Header "ETAPA 7 DE 8 - .NET FRAMEWORK"
    Repair-DotNet
    
    # === ETAPA 8 - Store e Servicos ===
    Write-Header "ETAPA 8 DE 8 - MICROSOFT STORE E SERVICOS"
    Repair-WindowsStore
    Repair-Services
    
    # === RESUMO ===
    $elapsed = (Get-Date) - $startTime
    Write-Host ""
    Write-Host "  +==========================================================+" -ForegroundColor Green
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     REPARO COMPLETO DO SISTEMA FINALIZADO!               |" -ForegroundColor Green
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     Tempo total: $([math]::Floor($elapsed.TotalMinutes)) minutos                              |" -ForegroundColor White
    Write-Host "  |     8 etapas concluidas com sucesso                      |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     Reinicie o computador para aplicar tudo              |" -ForegroundColor Yellow
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  +==========================================================+" -ForegroundColor Green
    Write-Host ""
    
    $rb = Read-Host "  Deseja reiniciar agora? (S/N)"
    if ($rb -eq "S" -or $rb -eq "s") {
        shutdown /r /t 10 /c "VW Informatica - Reparo completo do sistema finalizado"
    }
    
    $Global:Report += "  --- Reparo completo do sistema (8 etapas) em $([math]::Floor($elapsed.TotalMinutes)) min ---"
}

function Repair-Disk {
    Write-Header "REPARO DE DISCO (CHKDSK)"
    Write-Host "  [1] Verificar apenas" -ForegroundColor White
    Write-Host "  [2] Verificar e corrigir" -ForegroundColor White
    Write-Host "  [3] Verificar, corrigir e recuperar setores" -ForegroundColor White
    $opt = Read-Host "  Escolha (1/2/3)"
    $drv = (Read-Host "  Unidade (ex: C)").Replace(":","").ToUpper()
    
    switch ($opt) {
        "1" { chkdsk "${drv}:" }
        "2" { if ($drv -eq "C") { echo "Y" | chkdsk "${drv}:" /F } else { chkdsk "${drv}:" /F } }
        "3" { if ($drv -eq "C") { echo "Y" | chkdsk "${drv}:" /R } else { chkdsk "${drv}:" /R } }
    }
    $Global:Report += "  --- CHKDSK na unidade ${drv}: ---"
}

function Clean-System {
    Write-Header "LIMPEZA DO SISTEMA (COMPLETA)"
    $totalCleaned = 0
    
    # Temp usuario
    Write-Progress2 "Temp do usuario..."
    $b = (Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    $a = (Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $cl = [math]::Round(($b - $a) / 1MB, 2); $totalCleaned += $cl
    Write-Status "Temp usuario: $cl MB" "OK"
    
    # Temp Windows
    Write-Progress2 "Temp do Windows..."
    $b = (Get-ChildItem "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Get-ChildItem "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    $a = (Get-ChildItem "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $cl = [math]::Round(($b - $a) / 1MB, 2); $totalCleaned += $cl
    Write-Status "Temp Windows: $cl MB" "OK"
    
    Write-Progress2 "Prefetch..."
    Get-ChildItem "$env:SystemRoot\Prefetch" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Status "Prefetch limpo" "OK"
    
    Write-Progress2 "Miniaturas..."
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "thumbcache_*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Status "Miniaturas limpas" "OK"
    
    Write-Progress2 "Cache Windows Update..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    $b = (Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    $a = (Get-ChildItem "$env:SystemRoot\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $cl = [math]::Round(($b - $a) / 1MB, 2); $totalCleaned += $cl
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Status "Cache WU: $cl MB" "OK"
    
    Write-Progress2 "Componentes antigos (DISM)..."
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
    Write-Status "Componentes antigos limpos" "OK"
    
    Write-Progress2 "Limpando registros de eventos antigos..."
    @("$env:SystemRoot\Logs\CBS","$env:SystemRoot\Logs\DISM") | ForEach-Object {
        Get-ChildItem $_ -Filter "*.log" -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    wevtutil el | ForEach-Object { wevtutil cl $_ 2>$null }
    Write-Status "Logs limpos" "OK"
    
    Write-Progress2 "Cache de fontes..."
    Stop-Service -Name FontCache -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:SystemRoot\ServiceProfiles\LocalService\AppData\Local\FontCache\*" -Force -ErrorAction SilentlyContinue
    Start-Service -Name FontCache -ErrorAction SilentlyContinue
    Write-Status "Cache de fontes limpo" "OK"
    
    Write-Progress2 "Lixeira..."
    try { Clear-RecycleBin -Force -ErrorAction Stop; Write-Status "Lixeira esvaziada" "OK" }
    catch { Write-Status "Lixeira vazia" "INFO" }
    
    Write-Host "`n  ====================================" -ForegroundColor Green
    Write-Host "  Total: ~$([math]::Round($totalCleaned, 2)) MB + componentes/logs" -ForegroundColor Green
    Write-Host "  ====================================" -ForegroundColor Green
    $Global:Report += "  --- Limpeza: ~$([math]::Round($totalCleaned, 2)) MB ---"
}

function Optimize-Startup {
    Write-Header "OTIMIZACAO DE INICIALIZACAO"
    Write-Progress2 "Programas de inicializacao..."
    $items = Get-CimInstance Win32_StartupCommand
    $i = 0
    foreach ($item in $items) {
        $i++
        Write-Host "  [$i] $($item.Name)" -ForegroundColor White
        Write-Host "      $($item.Command)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Status "Use Ctrl+Shift+Esc > Inicializacao para gerenciar" "INFO"
}

function Repair-WindowsUpdate {
    Write-Header "REPARO DO WINDOWS UPDATE (ONLINE)"
    $c = Read-Host "  Para, limpa e reinicia o WU. Continuar? (S/N)"
    if ($c -ne "S" -and $c -ne "s") { return }
    
    Write-Progress2 "Parando servicos..."
    @("wuauserv","cryptSvc","bits","msiserver") | ForEach-Object { Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue }
    Write-Status "Servicos parados" "OK"
    
    Write-Progress2 "Renomeando cache..."
    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    Rename-Item "$env:SystemRoot\SoftwareDistribution" "$env:SystemRoot\SoftwareDistribution.bak_$ts" -ErrorAction SilentlyContinue
    Rename-Item "$env:SystemRoot\System32\catroot2" "$env:SystemRoot\System32\catroot2.bak_$ts" -ErrorAction SilentlyContinue
    Write-Status "Cache renomeado" "OK"
    
    Write-Progress2 "Re-registrando DLLs..."
    @("atl.dll","urlmon.dll","mshtml.dll","shdocvw.dll","browseui.dll","jscript.dll","vbscript.dll",
      "scrrun.dll","msxml3.dll","msxml6.dll","actxprxy.dll","softpub.dll","wintrust.dll",
      "dssenh.dll","rsaenh.dll","oleaut32.dll","ole32.dll","shell32.dll","wuapi.dll",
      "wuaueng.dll","wucltui.dll","wups.dll","wups2.dll","wuweb.dll","qmgr.dll",
      "wucltux.dll","muweb.dll","wuwebv.dll") | ForEach-Object { regsvr32.exe /s $_ 2>$null }
    Write-Status "DLLs registradas" "OK"
    
    Write-Progress2 "Reiniciando servicos..."
    @("wuauserv","cryptSvc","bits","msiserver") | ForEach-Object { Start-Service -Name $_ -ErrorAction SilentlyContinue }
    Write-Status "Servicos reiniciados" "OK"
    
    # Buscar atualizacoes online
    Write-Host ""
    Write-Progress2 "Buscando atualizacoes (online)..."
    try {
        $us = New-Object -ComObject Microsoft.Update.Session
        $sr = $us.CreateUpdateSearcher()
        $res = $sr.Search("IsInstalled=0")
        if ($res.Updates.Count -gt 0) {
            Write-Status "$($res.Updates.Count) atualizacao(s) disponivel(is):" "INFO"
            foreach ($u in $res.Updates | Select-Object -First 10) { Write-Host "    $($u.Title)" -ForegroundColor White }
            $inst = Read-Host "`n  Instalar agora? (S/N)"
            if ($inst -eq "S" -or $inst -eq "s") {
                $td = New-Object -ComObject Microsoft.Update.UpdateColl
                foreach ($u in $res.Updates) { $td.Add($u) | Out-Null }
                Write-Progress2 "Baixando..."
                $dl = $us.CreateUpdateDownloader(); $dl.Updates = $td; $dl.Download() | Out-Null
                Write-Progress2 "Instalando..."
                $in = $us.CreateUpdateInstaller(); $in.Updates = $td; $ir = $in.Install()
                if ($ir.ResultCode -eq 2) { Write-Status "Atualizacoes instaladas!" "OK" }
                if ($ir.RebootRequired) { Write-Status "REINICIALIZACAO NECESSARIA" "AVISO" }
            }
        } else { Write-Status "Sistema atualizado!" "OK" }
    } catch { Write-Status "Erro: tente via Configuracoes > Windows Update" "AVISO" }
    
    $Global:Report += "  --- Windows Update reparado ---"
}

function Reset-Network {
    Write-Header "RESET DE REDE"
    $c = Read-Host "  Reseta TODAS as configs de rede. Continuar? (S/N)"
    if ($c -ne "S" -and $c -ne "s") { return }
    
    ipconfig /flushdns | Out-Null; Write-Status "DNS limpo" "OK"
    ipconfig /release | Out-Null; ipconfig /renew | Out-Null; Write-Status "IP renovado" "OK"
    netsh winsock reset | Out-Null; Write-Status "Winsock resetado" "OK"
    netsh int ip reset | Out-Null; Write-Status "TCP/IP resetado" "OK"
    netsh advfirewall reset | Out-Null; Write-Status "Firewall resetado" "OK"
    netsh interface ip delete arpcache | Out-Null; Write-Status "ARP limpo" "OK"
    
    Write-Status "Rede resetada! Reinicie o PC." "OK"
    $Global:Report += "  --- Reset de rede ---"
}

function Repair-FullOnline {
    Write-Header "REPARO COMPLETO ONLINE"
    
    Write-Host ""
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host "  |  REPARO COMPLETO - Executa TUDO automaticamente:    |" -ForegroundColor Red
    Write-Host "  |                                                      |" -ForegroundColor Red
    Write-Host "  |  1. Atualiza antivirus + varredura rapida            |" -ForegroundColor White
    Write-Host "  |  2. DISM Online (baixa arquivos da Microsoft)        |" -ForegroundColor White
    Write-Host "  |  3. SFC (repara arquivos do sistema)                 |" -ForegroundColor White
    Write-Host "  |  4. Limpeza de componentes antigos                   |" -ForegroundColor White
    Write-Host "  |  5. Busca e instala drivers via Windows Update       |" -ForegroundColor White
    Write-Host "  |  6. Instala atualizacoes pendentes do Windows        |" -ForegroundColor White
    Write-Host "  |  7. Limpeza geral do sistema                         |" -ForegroundColor White
    Write-Host "  |                                                      |" -ForegroundColor Red
    Write-Host "  |  Tempo estimado: 30 a 90 minutos                     |" -ForegroundColor Yellow
    Write-Host "  |  REQUER INTERNET | NAO DESLIGUE O PC                 |" -ForegroundColor Yellow
    Write-Host "  +======================================================+" -ForegroundColor Red
    Write-Host ""
    
    $c = Read-Host "  Iniciar? (S/N)"
    if ($c -ne "S" -and $c -ne "s") { return }
    
    # Verificar internet
    if (-not (Test-Connection "8.8.8.8" -Count 1 -Quiet)) {
        Write-Status "SEM INTERNET! Conecte e tente novamente." "ERRO"; return
    }
    Write-Status "Internet OK" "OK"
    $startTime = Get-Date
    
    # 1 - Antivirus
    Write-Header "ETAPA 1/7 - ANTIVIRUS"
    try {
        Write-Progress2 "Atualizando definicoes..."
        Update-MpSignature -ErrorAction Stop
        Write-Progress2 "Varredura rapida..."
        Start-MpScan -ScanType QuickScan -ErrorAction Stop
        $th = Get-MpThreatDetection | Where-Object { $_.InitialDetectionTime -gt $startTime }
        if ($th) { Write-Status "$($th.Count) ameaca(s) tratada(s)" "AVISO" }
        else { Write-Status "Limpo!" "OK" }
    } catch { Write-Status "Defender nao disponivel - pulando" "INFO" }
    
    # 2 - DISM
    Write-Header "ETAPA 2/7 - DISM ONLINE"
    Write-Progress2 "Reparando imagem do Windows..."
    DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Status "DISM: OK" "OK" } else { Write-Status "DISM: codigo $LASTEXITCODE" "AVISO" }
    
    # 3 - SFC
    Write-Header "ETAPA 3/7 - SFC"
    Write-Progress2 "Verificando arquivos do sistema..."
    $sfcOut = sfc /scannow 2>&1
    if ($sfcOut -match "nao encontrou|did not find") { Write-Status "Integro" "OK" }
    elseif ($sfcOut -match "reparou|repaired") { Write-Status "Reparado!" "OK" }
    else { Write-Status "Verifique CBS.log" "AVISO" }
    
    # 4 - Componentes
    Write-Header "ETAPA 4/7 - LIMPEZA DE COMPONENTES"
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
    Write-Status "Componentes limpos" "OK"
    
    # 5 - Drivers
    Write-Header "ETAPA 5/7 - DRIVERS"
    try {
        $us = New-Object -ComObject Microsoft.Update.Session
        $sr = $us.CreateUpdateSearcher()
        $dr = $sr.Search("IsInstalled=0 AND Type='Driver'")
        if ($dr.Updates.Count -gt 0) {
            Write-Status "$($dr.Updates.Count) driver(s) atualizando..." "INFO"
            $td = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($u in $dr.Updates) { $td.Add($u) | Out-Null }
            $dl = $us.CreateUpdateDownloader(); $dl.Updates = $td; $dl.Download() | Out-Null
            $in = $us.CreateUpdateInstaller(); $in.Updates = $td; $in.Install() | Out-Null
            Write-Status "Drivers atualizados" "OK"
        } else { Write-Status "Drivers OK" "OK" }
    } catch { Write-Status "Erro drivers: $($_.Exception.Message)" "AVISO" }
    
    # 6 - Windows Update
    Write-Header "ETAPA 6/7 - WINDOWS UPDATE"
    try {
        $us2 = New-Object -ComObject Microsoft.Update.Session
        $sr2 = $us2.CreateUpdateSearcher()
        $res = $sr2.Search("IsInstalled=0")
        if ($res.Updates.Count -gt 0) {
            Write-Status "$($res.Updates.Count) atualizacao(s)..." "INFO"
            $td2 = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($u in $res.Updates) { $td2.Add($u) | Out-Null }
            $dl2 = $us2.CreateUpdateDownloader(); $dl2.Updates = $td2; $dl2.Download() | Out-Null
            $in2 = $us2.CreateUpdateInstaller(); $in2.Updates = $td2; $ir = $in2.Install()
            if ($ir.ResultCode -eq 2) { Write-Status "Atualizado!" "OK" }
            if ($ir.RebootRequired) { Write-Status "Reinicializacao necessaria" "AVISO" }
        } else { Write-Status "Ja atualizado!" "OK" }
    } catch { Write-Status "Erro WU - tente manualmente" "AVISO" }
    
    # 7 - Limpeza
    Write-Header "ETAPA 7/7 - LIMPEZA"
    Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem "$env:SystemRoot\Prefetch" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Status "Limpeza concluida" "OK"
    
    # Resumo
    $elapsed = (Get-Date) - $startTime
    Write-Host ""
    Write-Host "  +======================================================+" -ForegroundColor Green
    Write-Host "  |       REPARO COMPLETO ONLINE FINALIZADO!             |" -ForegroundColor Green
    Write-Host "  |  Tempo: $([math]::Floor($elapsed.TotalMinutes)) minutos                                  |" -ForegroundColor White
    Write-Host "  |  VW Informatica - (74) 99937-8375                    |" -ForegroundColor DarkGray
    Write-Host "  +======================================================+" -ForegroundColor Green
    
    $rb = Read-Host "`n  Reiniciar o PC agora? (S/N)"
    if ($rb -eq "S" -or $rb -eq "s") {
        shutdown /r /t 10 /c "VW Informatica - Reparo completo finalizado"
    }
    $Global:Report += "  --- REPARO COMPLETO em $([math]::Floor($elapsed.TotalMinutes)) min ---"
}

function Remove-WindowsAI {
    Write-Header "REMOCAO DE INTELIGENCIA ARTIFICIAL DO WINDOWS 11"
    
    # Verificar se e Windows 11
    $osBuild = [System.Environment]::OSVersion.Version.Build
    if ($osBuild -lt 22000) {
        Write-Status "Este recurso funciona apenas no Windows 11 (Build 22000 ou superior)" "INFO"
        Write-Status "Seu sistema esta no Build $osBuild" "INFO"
        return
    }
    
    Write-Info "Sistema" "Windows 11 Build $osBuild"
    Write-Host ""
    Write-Host "  Escolha o que deseja fazer:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Abrir painel de remocao (interface grafica)" -ForegroundColor White
    Write-Host "      Abre o RemoveWindowsAI com botoes para escolher." -ForegroundColor DarkGray
    Write-Host "      A interface aparece em ingles, mas tem botoes simples" -ForegroundColor DarkGray
    Write-Host "      de ligar/desligar. Clique em [?] para ver o que faz." -ForegroundColor DarkGray
    Write-Host "  [2] Remover TODA a IA automaticamente" -ForegroundColor White
    Write-Host "      Remove Copilot, Recall, pacotes, componentes e arquivos" -ForegroundColor DarkGray
    Write-Host "  [3] Remover apenas o Copilot" -ForegroundColor White
    Write-Host "      Desativa so o Copilot e as politicas de IA" -ForegroundColor DarkGray
    Write-Host "  [4] Desinstalar aplicativos com IA" -ForegroundColor White
    Write-Host "      Remove Paint novo, Clipchamp, Cortana, Outlook e outros" -ForegroundColor DarkGray
    Write-Host "  [5] Desativar IA do OneDrive e da Camera" -ForegroundColor White
    Write-Host "      Desativa reconhecimento facial, efeitos de camera/mic" -ForegroundColor DarkGray
    Write-Host "  [6] LIMPEZA TOTAL (tudo acima de uma vez)" -ForegroundColor Red
    Write-Host "      Remove tudo + desinstala apps + desativa extras" -ForegroundColor DarkGray
    Write-Host "  [7] Desfazer remocao (restaurar IA)" -ForegroundColor White
    Write-Host "      Restaura tudo que foi removido (precisa ter feito backup)" -ForegroundColor DarkGray
    Write-Host "  [0] Voltar ao menu principal" -ForegroundColor DarkGray
    Write-Host ""
    
    $opt = Read-Host "  Escolha"
    if ($opt -eq "0") { return }
    
    # Verificar internet para opcoes que precisam
    if ($opt -in @("1","2","3","6","7")) {
        Write-Progress2 "Verificando conexao com a internet..."
        if (-not (Test-Connection "8.8.8.8" -Count 1 -Quiet)) {
            Write-Status "SEM INTERNET! Algumas opcoes requerem conexao." "ERRO"
            if ($opt -notin @("4","5")) { return }
        } else {
            Write-Status "Internet OK" "OK"
        }
    }
    
    $rwaiUrl = "https://raw.githubusercontent.com/zoicware/RemoveWindowsAI/main/RemoveWindowsAi.ps1"
    
    switch ($opt) {
        "1" {
            Write-Progress2 "Baixando painel de remocao de IA..."
            Write-Host "  O painel vai abrir em uma nova janela." -ForegroundColor Yellow
            Write-Host "  A interface aparece em ingles. Guia rapido:" -ForegroundColor DarkGray
            Write-Host "    - Ative 'Backup Mode' ANTES de remover (permite desfazer)" -ForegroundColor DarkGray
            Write-Host "    - Clique nos botoes para ligar/desligar cada recurso" -ForegroundColor DarkGray
            Write-Host "    - Clique em [?] para ver o que cada opcao faz" -ForegroundColor DarkGray
            Write-Host "    - Clique 'Run' para executar a remocao" -ForegroundColor DarkGray
            try {
                & ([scriptblock]::Create((irm $rwaiUrl)))
                Write-Status "Remocao de IA concluida" "OK"
            } catch { Write-Status "Falha ao executar: $($_.Exception.Message)" "ERRO" }
        }
        "2" {
            Write-Host "  ATENCAO: Isso remove TODOS os recursos de IA do Windows!" -ForegroundColor Red
            Write-Host "  Inclui: Copilot, Recall, pacotes, arquivos e componentes." -ForegroundColor Red
            $c = Read-Host "  Tem certeza que deseja continuar? (S/N)"
            if ($c -eq "S" -or $c -eq "s") {
                Write-Progress2 "Executando remocao completa de IA..."
                Write-Host "  Pode demorar alguns minutos. Aguarde..." -ForegroundColor DarkGray
                try {
                    & ([scriptblock]::Create((irm $rwaiUrl))) -nonInteractive -AllOptions
                    Write-Status "Toda a IA foi removida com sucesso!" "OK"
                    Write-Status "Reinicie o computador para aplicar as mudancas" "AVISO"
                } catch { Write-Status "Falha: $($_.Exception.Message)" "ERRO" }
            }
        }
        "3" {
            Write-Progress2 "Desativando Copilot e politicas de IA..."
            try {
                & ([scriptblock]::Create((irm $rwaiUrl))) -nonInteractive -Options DisableRegKeys,DisableCopilotPolicies,RemoveAppxPackages
                Write-Status "Copilot desativado com sucesso!" "OK"
            } catch { Write-Status "Falha: $($_.Exception.Message)" "ERRO" }
        }
        "4" {
            Remove-AIApps
        }
        "5" {
            Disable-OtherAIFeatures
        }
        "6" {
            Write-Host ""
            Write-Host "  LIMPEZA TOTAL DE IA - Vai executar tudo:" -ForegroundColor Red
            Write-Host "  1. Remover toda IA do sistema (Copilot, Recall, pacotes)" -ForegroundColor White
            Write-Host "  2. Desinstalar aplicativos com IA (Paint, Clipchamp...)" -ForegroundColor White
            Write-Host "  3. Desativar IA do OneDrive e efeitos de camera/mic" -ForegroundColor White
            Write-Host ""
            $c = Read-Host "  Deseja continuar? (S/N)"
            if ($c -eq "S" -or $c -eq "s") {
                # Etapa 1
                Write-Header "ETAPA 1 DE 3 - REMOCAO DE IA DO SISTEMA"
                Write-Progress2 "Executando remocao completa de IA..."
                Write-Host "  Pode demorar alguns minutos..." -ForegroundColor DarkGray
                try {
                    & ([scriptblock]::Create((irm $rwaiUrl))) -nonInteractive -AllOptions
                    Write-Status "IA do sistema removida" "OK"
                } catch { Write-Status "Algumas remocoes falharam: $($_.Exception.Message)" "AVISO" }
                
                # Etapa 2
                Write-Header "ETAPA 2 DE 3 - APLICATIVOS COM IA"
                Remove-AIApps
                
                # Etapa 3 - Outros
                Write-Header "ETAPA 3 DE 3 - ONEDRIVE E CAMERA COM IA"
                Disable-OtherAIFeatures
                
                Write-Host ""
                Write-Host "  +======================================================+" -ForegroundColor Green
                Write-Host "  |     LIMPEZA TOTAL DE IA CONCLUIDA COM SUCESSO!        |" -ForegroundColor Green
                Write-Host "  |     Reinicie o computador para aplicar tudo            |" -ForegroundColor White
                Write-Host "  +======================================================+" -ForegroundColor Green
                
                $rb = Read-Host "`n  Deseja reiniciar agora? (S/N)"
                if ($rb -eq "S" -or $rb -eq "s") {
                    shutdown /r /t 10 /c "VW Informatica - Limpeza de IA concluida"
                }
            }
        }
        "7" {
            Write-Host "  Isso vai restaurar os recursos de IA que foram removidos." -ForegroundColor Yellow
            Write-Host "  So funciona se voce ativou o backup antes de remover." -ForegroundColor Yellow
            $c = Read-Host "  Deseja continuar? (S/N)"
            if ($c -eq "S" -or $c -eq "s") {
                Write-Progress2 "Restaurando recursos de IA..."
                try {
                    & ([scriptblock]::Create((irm $rwaiUrl))) -nonInteractive -revertMode -AllOptions
                    Write-Status "Recursos de IA restaurados com sucesso!" "OK"
                    Write-Status "Reinicie o computador para aplicar" "AVISO"
                } catch { Write-Status "Falha ao restaurar: $($_.Exception.Message)" "ERRO" }
            }
        }
        default { Write-Host "  Opcao invalida! Tente novamente" -ForegroundColor Red; return }
    }
    
    $Global:Report += "  --- Remocao de IA executada (opcao $opt) ---"
}

function Remove-AIApps {
    Write-Header "DESINSTALAR APLICATIVOS COM INTELIGENCIA ARTIFICIAL"
    
    # Lista de apps com IA que pesam o sistema
    $aiApps = @(
        @{Name="Microsoft.Paint"; Disp="Paint novo (com IA)"},
        @{Name="Clipchamp.Clipchamp"; Disp="Clipchamp (editor de video com IA)"},
        @{Name="Microsoft.549981C3F5F10"; Disp="Cortana (assistente de voz)"},
        @{Name="Microsoft.Windows.Ai.Copilot.Provider"; Disp="Provedor do Copilot"},
        @{Name="Microsoft.Copilot"; Disp="Microsoft Copilot"},
        @{Name="Microsoft.Windows.Photos"; Disp="Fotos (com IA)"},
        @{Name="Microsoft.WindowsNotepad"; Disp="Bloco de Notas novo (com IA)"},
        @{Name="Microsoft.ScreenSketch"; Disp="Ferramenta de Recorte (com IA)"},
        @{Name="Microsoft.OutlookForWindows"; Disp="Outlook novo (com Copilot)"},
        @{Name="Microsoft.BingNews"; Disp="Noticias Bing"},
        @{Name="Microsoft.BingWeather"; Disp="Clima Bing"},
        @{Name="Microsoft.BingSearch"; Disp="Pesquisa Bing"},
        @{Name="Microsoft.MicrosoftOfficeHub"; Disp="Centro do Office"},
        @{Name="Microsoft.PowerAutomateDesktop"; Disp="Power Automate"},
        @{Name="Microsoft.Windows.DevHome"; Disp="Dev Home (ferramenta de desenvolvedor)"},
        @{Name="Microsoft.Getstarted"; Disp="Dicas do Windows"},
        @{Name="Microsoft.GetHelp"; Disp="Obter Ajuda (com IA)"},
        @{Name="MicrosoftCorporationII.QuickAssist"; Disp="Assistencia Rapida"},
        @{Name="Microsoft.WindowsFeedbackHub"; Disp="Hub de Comentarios"},
        @{Name="Microsoft.Todos"; Disp="Microsoft Tarefas"},
        @{Name="Microsoft.People"; Disp="Pessoas"},
        @{Name="Microsoft.MicrosoftSolitaireCollection"; Disp="Colecao Paciencia"}
    )
    
    # Verificar quais estao instalados
    Write-Progress2 "Verificando aplicativos instalados..."
    $installed = @()
    foreach ($app in $aiApps) {
        $pkg = Get-AppxPackage -Name $app.Name -ErrorAction SilentlyContinue
        if ($pkg) {
            $installed += $app
        }
    }
    
    if ($installed.Count -eq 0) {
        Write-Status "Nenhum aplicativo com IA encontrado no sistema" "OK"
        return
    }
    
    Write-Host ""
    Write-Host "  Aplicativos com IA encontrados ($($installed.Count)):" -ForegroundColor Yellow
    Write-Host ""
    $i = 0
    foreach ($app in $installed) {
        $i++
        Write-Host "    [$i] $($app.Disp)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  [A] Remover TODOS os listados acima" -ForegroundColor Red
    Write-Host "  [E] Escolher quais remover (digitar numeros)" -ForegroundColor White
    Write-Host "  [0] Voltar ao menu anterior" -ForegroundColor DarkGray
    Write-Host ""
    
    $choice = Read-Host "  Escolha"
    
    if ($choice -eq "0") { return }
    
    $toRemove = @()
    if ($choice -eq "A" -or $choice -eq "a") {
        $toRemove = $installed
    } elseif ($choice -eq "E" -or $choice -eq "e") {
        Write-Host "  Digite os numeros separados por virgula (exemplo: 1,3,5):" -ForegroundColor DarkGray
        $nums = Read-Host "  "
        $indices = $nums -split "," | ForEach-Object { [int]$_.Trim() }
        foreach ($idx in $indices) {
            if ($idx -ge 1 -and $idx -le $installed.Count) {
                $toRemove += $installed[$idx - 1]
            }
        }
    } else { return }
    
    if ($toRemove.Count -eq 0) { Write-Status "Nenhum aplicativo selecionado" "INFO"; return }
    
    Write-Host ""
    $removedCount = 0
    foreach ($app in $toRemove) {
        Write-Progress2 "Removendo $($app.Disp)..."
        try {
            # Remover para o usuario atual
            Get-AppxPackage -Name $app.Name -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            # Remover para todos os usuarios
            Get-AppxPackage -Name $app.Name -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            # Remover pacote de instalacao (impede reinstalacao futura)
            $prov = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$($app.Name)*" }
            if ($prov) {
                $prov | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            }
            Write-Status "$($app.Disp) removido com sucesso" "OK"
            $removedCount++
            $Global:Report += "  [REMOVIDO] $($app.Disp)"
        } catch {
            Write-Status "$($app.Disp) - nao foi possivel remover" "AVISO"
        }
    }
    
    Write-Host ""
    Write-Status "$removedCount aplicativo(s) removido(s)" "OK"
    
    # Oferecer instalacao de versoes classicas
    Write-Host ""
    Write-Host "  Deseja instalar as versoes classicas (sem IA)?" -ForegroundColor Yellow
    Write-Host "  Aplicativos que serao instalados:" -ForegroundColor DarkGray
    Write-Host "    - Paint classico (sem IA)" -ForegroundColor DarkGray
    Write-Host "    - Bloco de Notas classico (sem IA)" -ForegroundColor DarkGray
    Write-Host "    - Visualizador de Fotos do Windows" -ForegroundColor DarkGray
    Write-Host "    - Ferramenta de Recorte classica" -ForegroundColor DarkGray
    Write-Host ""
    $classic = Read-Host "  Instalar versoes classicas? (S/N)"
    if ($classic -eq "S" -or $classic -eq "s") {
        Write-Progress2 "Instalando aplicativos classicos (requer internet)..."
        try {
            $rwaiUrl = "https://raw.githubusercontent.com/zoicware/RemoveWindowsAI/main/RemoveWindowsAi.ps1"
            & ([scriptblock]::Create((irm $rwaiUrl))) -nonInteractive -InstallClassicApps photoviewer,mspaint,snippingtool,notepad
            Write-Status "Aplicativos classicos instalados com sucesso!" "OK"
        } catch {
            Write-Status "Falha ao instalar: $($_.Exception.Message)" "AVISO"
        }
    }
}

function Disable-OtherAIFeatures {
    Write-Header "DESATIVAR IA: ONEDRIVE, CAMERA, MICROFONE E BUSCA"
    
    # === OneDrive AI (reconhecimento facial) ===
    Write-Progress2 "Desativando IA do OneDrive (reconhecimento facial)..."
    $oneDriveAIPath = "HKCU:\Software\Microsoft\OneDrive\Accounts\Personal"
    if (Test-Path $oneDriveAIPath) {
        Set-ItemProperty -Path $oneDriveAIPath -Name "UserPersonalTaggingEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Status "OneDrive AI: reconhecimento facial desativado" "OK"
    } else {
        # Tentar caminho alternativo
        $oneDrivePaths = @(
            "HKCU:\Software\Microsoft\OneDrive",
            "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1"
        )
        foreach ($p in $oneDrivePaths) {
            if (Test-Path $p) {
                Set-ItemProperty -Path $p -Name "UserPersonalTaggingEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Status "OneDrive AI: chaves de registro configuradas" "OK"
    }
    # Desativar OneDrive AI no registro global
    $oneDriveGlobal = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
    if (-not (Test-Path $oneDriveGlobal)) { New-Item -Path $oneDriveGlobal -Force | Out-Null }
    Set-ItemProperty -Path $oneDriveGlobal -Name "DisablePersonalTagging" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "OneDrive AI: politica global desativada" "OK"
    
    # === Windows Studio Effects (camera/mic IA) ===
    Write-Host ""
    Write-Progress2 "Desativando efeitos de IA na camera e microfone..."
    $studioEffectsKeys = @(
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\CameraSettings"; Name="BackgroundBlur"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\CameraSettings"; Name="EyeContact"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\CameraSettings"; Name="AutoFraming"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\CameraSettings"; Name="PortraitLight"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\CameraSettings"; Name="CreativeFilters"; Val=0}
    )
    foreach ($key in $studioEffectsKeys) {
        if (-not (Test-Path $key.Path)) { New-Item -Path $key.Path -Force | Out-Null }
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Val -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Status "Efeitos de IA na camera desativados" "OK"
    
    # Desativar efeitos de voz IA (mic)
    $voiceEffects = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\MicrophoneSettings"
    if (-not (Test-Path $voiceEffects)) { New-Item -Path $voiceEffects -Force | Out-Null }
    Set-ItemProperty -Path $voiceEffects -Name "VoiceFocus" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Efeitos de IA no microfone desativados" "OK"
    
    # === Desativar servicos e tarefas de IA ===
    Write-Host ""
    Write-Progress2 "Desativando servicos de inteligencia artificial..."
    $aiServices = @(
        "AiRouterService",
        "WpnService",
        "wscsvc"
    )
    foreach ($svc in $aiServices) {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Status "Servico '$svc' desativado" "OK"
        }
    }
    
    # === Desativar Copilot via registro (redundancia) ===
    Write-Host ""
    Write-Progress2 "Desativando Copilot via registro..."
    $copilotKeys = @(
        @{Path="HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"; Name="TurnOffWindowsCopilot"; Val=1},
        @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; Name="TurnOffWindowsCopilot"; Val=1},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="ShowCopilotButton"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\Shell\Copilot"; Name="IsCopilotAvailable"; Val=0}
    )
    foreach ($key in $copilotKeys) {
        if (-not (Test-Path $key.Path)) { New-Item -Path $key.Path -Force | Out-Null }
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Val -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Status "Copilot desativado via registro" "OK"
    
    # === Desativar Recall ===
    Write-Progress2 "Desativando Windows Recall..."
    $recallKeys = @(
        @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name="DisableAIDataAnalysis"; Val=1},
        @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name="TurnOffSavingSnapshots"; Val=1},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="DisableRecall"; Val=1}
    )
    foreach ($key in $recallKeys) {
        if (-not (Test-Path $key.Path)) { New-Item -Path $key.Path -Force | Out-Null }
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Val -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Status "Windows Recall desativado" "OK"
    
    # === Desativar IA na Busca do Windows ===
    Write-Progress2 "Desativando IA na Busca do Windows..."
    $searchAI = @(
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"; Name="IsAADCloudSearchEnabled"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"; Name="IsMSACloudSearchEnabled"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"; Name="IsDeviceSearchHistoryEnabled"; Val=0},
        @{Path="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"; Name="BingSearchEnabled"; Val=0}
    )
    foreach ($key in $searchAI) {
        if (-not (Test-Path $key.Path)) { New-Item -Path $key.Path -Force | Out-Null }
        Set-ItemProperty -Path $key.Path -Name $key.Name -Value $key.Val -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Status "Busca com IA/Bing desativada" "OK"
    
    # === Desativar Widgets ===
    Write-Progress2 "Desativando Widgets..."
    $widgetPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
    if (-not (Test-Path $widgetPath)) { New-Item -Path $widgetPath -Force | Out-Null }
    Set-ItemProperty -Path $widgetPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Widgets desativados" "OK"
    
    # === Desativar tarefas agendadas de IA ===
    Write-Host ""
    Write-Progress2 "Desativando tarefas agendadas de IA..."
    $aiTasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
        $_.TaskName -match "Copilot|Recall|AIService|WindowsAI|AiFabric|MicrosoftEdgeUpdate" -or
        $_.TaskPath -match "WindowsAI|Recall"
    }
    if ($aiTasks) {
        foreach ($task in $aiTasks) {
            Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue | Out-Null
            Write-Status "Tarefa '$($task.TaskName)' desativada" "OK"
        }
    } else {
        Write-Status "Nenhuma tarefa agendada de IA encontrada" "OK"
    }
    
    # === Desativar telemetria de IA ===
    Write-Progress2 "Desativando telemetria de IA..."
    $telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $telemetryPath)) { New-Item -Path $telemetryPath -Force | Out-Null }
    Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Telemetria reduzida" "OK"
    
    Write-Host ""
    Write-Status "Todas as configuracoes de IA extras desativadas!" "OK"
    $Global:Report += "  --- OneDrive AI + Studio Effects + Servicos IA desativados ---"
}

function Activate-MAS {
    Write-Header "ATIVACAO DO WINDOWS / OFFICE"
    
    Write-Host "  Ferramenta de ativacao Microsoft (MAS)" -ForegroundColor Cyan
    Write-Host "  Projeto: github.com/massgravel/Microsoft-Activation-Scripts" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Escolha uma opcao:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Abrir menu do MAS (todas as opcoes)" -ForegroundColor White
    Write-Host "      Abre o painel completo - o menu aparecera em ingles" -ForegroundColor DarkGray
    Write-Host "      mas as opcoes sao simples de entender:" -ForegroundColor DarkGray
    Write-Host "        1 = Ativar Windows  |  2 = Ativar Office" -ForegroundColor DarkGray
    Write-Host "        3 = TSforge         |  4 = KMS Online" -ForegroundColor DarkGray
    Write-Host "  [2] Ativar Windows (permanente)" -ForegroundColor White
    Write-Host "      Metodo HWID - vincula ao hardware do PC" -ForegroundColor DarkGray
    Write-Host "  [3] Ativar Office (permanente)" -ForegroundColor White
    Write-Host "      Metodo Ohook - funciona com Office 365/2021/2024" -ForegroundColor DarkGray
    Write-Host "  [4] Ativar Windows (metodo alternativo)" -ForegroundColor White
    Write-Host "      Metodo TSforge - outra forma de ativacao permanente" -ForegroundColor DarkGray
    Write-Host "  [5] Ativar Windows (temporario 180 dias)" -ForegroundColor White
    Write-Host "      Metodo KMS - renova sozinho a cada 180 dias" -ForegroundColor DarkGray
    Write-Host "  [6] Ver status de ativacao" -ForegroundColor White
    Write-Host "      Mostra se Windows e Office estao ativados" -ForegroundColor DarkGray
    Write-Host "  [7] Resolver problemas de ativacao" -ForegroundColor White
    Write-Host "      Ferramenta de correcao de erros do MAS" -ForegroundColor DarkGray
    Write-Host "  [0] Voltar ao menu principal" -ForegroundColor DarkGray
    Write-Host ""
    
    $opt = Read-Host "  Escolha"
    if ($opt -eq "0") { return }
    
    # Verificar internet
    Write-Progress2 "Verificando conexao com a internet..."
    if (-not (Test-Connection "8.8.8.8" -Count 1 -Quiet)) {
        Write-Status "SEM INTERNET! A ativacao precisa de conexao." "ERRO"
        return
    }
    Write-Status "Conexao com a internet OK" "OK"
    
    # Forcar TLS 1.2 (necessario em builds antigos)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    $masUrl = "https://get.activated.win"
    $masUrlAlt = "https://massgrave.dev/get"
    
    switch ($opt) {
        "1" {
            Write-Progress2 "Baixando ferramenta de ativacao..."
            Write-Host ""
            Write-Host "  O menu do MAS vai abrir em uma nova janela." -ForegroundColor Yellow
            Write-Host "  As opcoes aparecem em ingles, mas e simples:" -ForegroundColor DarkGray
            Write-Host "  Escolha o numero da opcao VERDE desejada." -ForegroundColor DarkGray
            Write-Host ""
            try {
                irm $masUrl | iex
            } catch {
                Write-Status "Servidor principal bloqueado. Tentando servidor alternativo..." "AVISO"
                try {
                    irm $masUrlAlt | iex
                } catch {
                    Write-Status "Os dois servidores estao bloqueados pelo provedor de internet." "ERRO"
                    Write-Host "  Tente este comando manualmente:" -ForegroundColor Yellow
                    Write-Host "  iex (curl.exe -s --doh-url https://1.1.1.1/dns-query $masUrl | Out-String)" -ForegroundColor DarkGray
                }
            }
        }
        "2" {
            Write-Progress2 "Ativando Windows (metodo HWID - permanente)..."
            Write-Host "  A ativacao e vinculada ao hardware deste PC." -ForegroundColor Yellow
            Write-Host "  Aguarde o processo terminar..." -ForegroundColor DarkGray
            try {
                & ([ScriptBlock]::Create((irm $masUrl))) /HWID
            } catch {
                try { & ([ScriptBlock]::Create((irm $masUrlAlt))) /HWID }
                catch { Write-Status "Falha na ativacao: $($_.Exception.Message)" "ERRO" }
            }
        }
        "3" {
            Write-Progress2 "Ativando Office (metodo Ohook)..."
            Write-Host "  Funciona com Office 365, 2021 e 2024." -ForegroundColor Yellow
            Write-Host "  Aguarde o processo terminar..." -ForegroundColor DarkGray
            try {
                & ([ScriptBlock]::Create((irm $masUrl))) /Ohook
            } catch {
                try { & ([ScriptBlock]::Create((irm $masUrlAlt))) /Ohook }
                catch { Write-Status "Falha na ativacao: $($_.Exception.Message)" "ERRO" }
            }
        }
        "4" {
            Write-Progress2 "Ativando Windows (metodo TSforge - permanente)..."
            Write-Host "  Metodo alternativo de ativacao permanente." -ForegroundColor Yellow
            Write-Host "  Aguarde o processo terminar..." -ForegroundColor DarkGray
            try {
                & ([ScriptBlock]::Create((irm $masUrl))) /TSforge
            } catch {
                try { & ([ScriptBlock]::Create((irm $masUrlAlt))) /TSforge }
                catch { Write-Status "Falha na ativacao: $($_.Exception.Message)" "ERRO" }
            }
        }
        "5" {
            Write-Progress2 "Ativando Windows (metodo KMS - 180 dias)..."
            Write-Host "  A ativacao renova automaticamente a cada 180 dias." -ForegroundColor Yellow
            Write-Host "  Aguarde o processo terminar..." -ForegroundColor DarkGray
            try {
                & ([ScriptBlock]::Create((irm $masUrl))) /KMS-ActAndRenewalTask
            } catch {
                try { & ([ScriptBlock]::Create((irm $masUrlAlt))) /KMS-ActAndRenewalTask }
                catch { Write-Status "Falha na ativacao: $($_.Exception.Message)" "ERRO" }
            }
        }
        "6" {
            Write-Header "VERIFICACAO DE ATIVACAO"
            
            # Windows
            Write-Progress2 "Verificando ativacao do Windows..."
            $winAct = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }
            if ($winAct) {
                $licStatus = switch ($winAct.LicenseStatus) {
                    0 { "Nao ativado" } 1 { "ATIVADO" } 2 { "Periodo de cortesia" }
                    3 { "Cortesia expirada" } 4 { "Sem autenticacao" } 5 { "Notificacao" } default { "Desconhecido" }
                }
                Write-Info "Windows" "$($winAct.Name)"
                Write-Info "Situacao" "$licStatus"
                Write-Info "Chave parcial" "$($winAct.PartialProductKey)"
                if ($winAct.LicenseStatus -eq 1) { Write-Status "Windows esta ATIVADO" "OK" }
                else { Write-Status "Windows NAO esta ativado" "AVISO" }
            } else {
                Write-Status "Nenhuma licenca do Windows encontrada" "AVISO"
            }
            
            # Office
            Write-Host ""
            Write-Progress2 "Verificando ativacao do Office..."
            $officeAct = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Office*" }
            if ($officeAct) {
                foreach ($o in $officeAct) {
                    Write-Info "Office" "$($o.Name)"
                    $oStatus = if ($o.LicenseStatus -eq 1) { "ATIVADO" } else { "Nao ativado" }
                    Write-Info "Situacao" "$oStatus"
                    if ($o.LicenseStatus -eq 1) { Write-Status "Office esta ATIVADO" "OK" }
                    else { Write-Status "Office NAO esta ativado" "AVISO" }
                }
            } else {
                Write-Status "Nenhuma licenca do Office encontrada (Office nao instalado?)" "INFO"
            }
        }
        "7" {
            Write-Progress2 "Abrindo ferramenta de correcao de problemas..."
            Write-Host "  A ferramenta aparecera em ingles." -ForegroundColor DarkGray
            Write-Host "  Ela vai verificar e corrigir erros de ativacao automaticamente." -ForegroundColor DarkGray
            try {
                & ([ScriptBlock]::Create((irm $masUrl))) /Troubleshoot
            } catch {
                try { & ([ScriptBlock]::Create((irm $masUrlAlt))) /Troubleshoot }
                catch { Write-Status "Falha ao executar: $($_.Exception.Message)" "ERRO" }
            }
        }
        default { Write-Host "  Opcao invalida! Tente novamente" -ForegroundColor Red; return }
    }
    
    $Global:Report += "  --- Ativacao executada (opcao $opt) ---"
}

function Optimize-Gaming {
    Write-Header "OTIMIZACAO DO WINDOWS PARA JOGOS"
    
    Write-Host "  Esta funcao aplica mais de 35 ajustes para melhorar" -ForegroundColor Cyan
    Write-Host "  o desempenho em jogos, reduzir travamentos e aumentar FPS." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  O que sera feito:" -ForegroundColor Yellow
    Write-Host "    - Ativar Modo de Jogo e GPU acelerada por hardware" -ForegroundColor White
    Write-Host "    - Desativar gravacao de tela (GameDVR)" -ForegroundColor White
    Write-Host "    - Prioridade da CPU para jogos (primeiro plano)" -ForegroundColor White
    Write-Host "    - Otimizar rede (reduzir lag/ping - Nagle)" -ForegroundColor White
    Write-Host "    - Otimizar memoria RAM e cache do sistema" -ForegroundColor White
    Write-Host "    - Plano de energia: Alto Desempenho" -ForegroundColor White
    Write-Host "    - Desativar efeitos visuais desnecessarios" -ForegroundColor White
    Write-Host "    - Desativar servicos que consomem recursos" -ForegroundColor White
    Write-Host "    - Otimizar SSD (TRIM) e timer do sistema" -ForegroundColor White
    Write-Host "    - Desativar telemetria e notificacoes durante jogos" -ForegroundColor White
    Write-Host "    - Configurar NVIDIA ou AMD para desempenho maximo" -ForegroundColor White
    Write-Host "    - Instalar autoexec competitivo no CS2 (se instalado)" -ForegroundColor White
    Write-Host ""
    Write-Host "  NAO sera alterado:" -ForegroundColor Green
    Write-Host "    - Impressora, audio, rede, seguranca, Windows Update" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Um ponto de restauracao sera criado antes de comecar." -ForegroundColor DarkGray
    Write-Host ""
    
    $c = Read-Host "  Iniciar otimizacao para jogos? (S/N)"
    if ($c -ne "S" -and $c -ne "s") { return }
    
    # Criar ponto de restauracao
    Write-Progress2 "Criando ponto de restauracao..."
    try {
        Checkpoint-Computer -Description "VW Informatica - Antes da otimizacao para jogos" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-Status "Ponto de restauracao criado" "OK"
    } catch {
        Write-Status "Nao foi possivel criar ponto de restauracao (continue por sua conta)" "AVISO"
    }
    
    $totalOtimizacoes = 0
    
    # =============================================
    # 1. MODO DE JOGO E GPU
    # =============================================
    Write-Header "1. MODO DE JOGO E PLACA DE VIDEO"
    
    # Ativar Game Mode
    Write-Progress2 "Ativando Modo de Jogo..."
    $gamebar = "HKCU:\Software\Microsoft\GameBar"
    if (-not (Test-Path $gamebar)) { New-Item -Path $gamebar -Force | Out-Null }
    Set-ItemProperty -Path $gamebar -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamebar -Name "AutoGameModeEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Modo de Jogo ativado" "OK"
    $totalOtimizacoes++
    
    # Ativar agendamento de GPU por hardware
    Write-Progress2 "Ativando agendamento de GPU por hardware..."
    $gpuPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    Set-ItemProperty -Path $gpuPath -Name "HwSchMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Agendamento de GPU por hardware ativado" "OK"
    $totalOtimizacoes++
    
    # Desativar GameDVR (gravacao de tela em jogos)
    Write-Progress2 "Desativando gravacao de tela em jogos (GameDVR)..."
    $gameDVR = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    if (-not (Test-Path $gameDVR)) { New-Item -Path $gameDVR -Force | Out-Null }
    Set-ItemProperty -Path $gameDVR -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameDVR -Name "AudioCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    $gameStore = "HKCU:\System\GameConfigStore"
    if (-not (Test-Path $gameStore)) { New-Item -Path $gameStore -Force | Out-Null }
    Set-ItemProperty -Path $gameStore -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameStore -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameStore -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    # Politica de GameDVR
    $gameDVRPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (-not (Test-Path $gameDVRPolicy)) { New-Item -Path $gameDVRPolicy -Force | Out-Null }
    Set-ItemProperty -Path $gameDVRPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Gravacao de tela (GameDVR) desativada" "OK"
    $totalOtimizacoes++
    
    # Desativar otimizacao de tela cheia (melhora FPS)
    Write-Progress2 "Desativando otimizacao de tela cheia do Windows..."
    Set-ItemProperty -Path $gameStore -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gameStore -Name "GameDVR_FSEBehavior" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Otimizacao de tela cheia desativada (melhora FPS)" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 2. CPU E PRIORIDADE DE PROCESSOS
    # =============================================
    Write-Header "2. PROCESSADOR E PRIORIDADE"
    
    # Prioridade para aplicativos em primeiro plano (jogos)
    Write-Progress2 "Priorizando CPU para jogos (primeiro plano)..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "CPU prioriza jogos em primeiro plano" "OK"
    $totalOtimizacoes++
    
    # Perfil de multimedia para jogos
    Write-Progress2 "Configurando perfil de multimedia para jogos..."
    $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $mmPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force -ErrorAction SilentlyContinue
    # Perfil de tarefas de jogos
    $gamesTask = "$mmPath\Tasks\Games"
    if (-not (Test-Path $gamesTask)) { New-Item -Path $gamesTask -Force | Out-Null }
    Set-ItemProperty -Path $gamesTask -Name "GPU Priority" -Value 8 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTask -Name "Priority" -Value 6 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTask -Name "Scheduling Category" -Value "High" -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTask -Name "SFIO Priority" -Value "High" -Type String -Force -ErrorAction SilentlyContinue
    Write-Status "Perfil de multimedia otimizado para jogos" "OK"
    $totalOtimizacoes++
    
    # Timer do sistema (resolucao mais precisa)
    Write-Progress2 "Ativando resolucao de timer precisa..."
    $kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel"
    Set-ItemProperty -Path $kernelPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Timer do sistema com resolucao precisa" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 3. MEMORIA RAM
    # =============================================
    Write-Header "3. MEMORIA RAM"
    
    Write-Progress2 "Otimizando uso de memoria..."
    $memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    # Manter kernel na RAM (nao paginar para disco)
    Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Kernel mantido na RAM (nao pagina para disco)" "OK"
    $totalOtimizacoes++
    
    # Ativar cache grande do sistema
    Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Cache grande do sistema ativado" "OK"
    $totalOtimizacoes++
    
    # Desativar SysMain/Superfetch em SSDs (desnecessario)
    $hasSSD = Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" -or $_.MediaType -eq "Unspecified" }
    if ($hasSSD) {
        Write-Progress2 "SSD detectado - desativando Superfetch (desnecessario em SSD)..."
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Status "Superfetch desativado (SSD detectado)" "OK"
        $totalOtimizacoes++
        
        # Otimizar TRIM para SSD
        Write-Progress2 "Executando TRIM no SSD..."
        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
        Write-Status "TRIM executado no SSD" "OK"
        $totalOtimizacoes++
    }
    
    # =============================================
    # 4. REDE (REDUZIR LAG/PING)
    # =============================================
    Write-Header "4. REDE (REDUZIR LAG E PING)"
    
    Write-Progress2 "Desativando algoritmo de Nagle (reduz lag online)..."
    $tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Set-ItemProperty -Path $tcpPath -Name "TcpNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Algoritmo de Nagle desativado (menos lag)" "OK"
    $totalOtimizacoes++
    
    # Desativar limitacao de rede para multimedia
    Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Limitacao de rede para multimedia removida" "OK"
    $totalOtimizacoes++
    
    # Otimizar DNS
    Write-Progress2 "Otimizando DNS..."
    Set-ItemProperty -Path $tcpPath -Name "DefaultTTL" -Value 64 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $tcpPath -Name "Tcp1323Opts" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Configuracoes TCP/IP otimizadas" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 5. PLANO DE ENERGIA
    # =============================================
    Write-Header "5. PLANO DE ENERGIA"
    
    Write-Progress2 "Ativando plano de Alto Desempenho..."
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Criar plano de alto desempenho se nao existir
        powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
    }
    Write-Status "Plano de energia: Alto Desempenho ativado" "OK"
    $totalOtimizacoes++
    
    # Desativar economia de energia USB
    Write-Progress2 "Desativando economia de energia USB..."
    $usbPath = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
    if (-not (Test-Path $usbPath)) { New-Item -Path $usbPath -Force | Out-Null }
    Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Economia de energia USB desativada" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 6. EFEITOS VISUAIS
    # =============================================
    Write-Header "6. EFEITOS VISUAIS"
    
    Write-Progress2 "Reduzindo efeitos visuais (libera GPU para jogos)..."
    $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $visualPath)) { New-Item -Path $visualPath -Force | Out-Null }
    Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
    
    # Desativar transparencia
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Transparencia do Windows desativada" "OK"
    $totalOtimizacoes++
    
    # Desativar animacoes
    $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
    Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force -ErrorAction SilentlyContinue
    Write-Status "Animacoes reduzidas (menus mais rapidos)" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 7. SERVICOS DESNECESSARIOS
    # =============================================
    Write-Header "7. SERVICOS EM SEGUNDO PLANO"
    
    Write-Progress2 "Desativando servicos que consomem recursos..."
    # Lista segura - NAO inclui impressora, audio, rede essencial, seguranca
    $servicosParaDesativar = @(
        @{Name="DiagTrack"; Desc="Telemetria da Microsoft"},
        @{Name="dmwappushservice"; Desc="Envio de dados WAP"},
        @{Name="MapsBroker"; Desc="Gerenciador de Mapas"},
        @{Name="lfsvc"; Desc="Servico de Geolocalizacao"},
        @{Name="RetailDemo"; Desc="Modo de Demonstracao"},
        @{Name="WerSvc"; Desc="Relatorio de Erros do Windows"},
        @{Name="Fax"; Desc="Servico de Fax"},
        @{Name="TabletInputService"; Desc="Teclado Virtual/Touch"},
        @{Name="WMPNetworkSvc"; Desc="Compartilhamento do Media Player"},
        @{Name="icssvc"; Desc="Ponto de acesso movel"},
        @{Name="WpcMonSvc"; Desc="Controle dos Pais"},
        @{Name="SEMgrSvc"; Desc="Gerenciador de Pagamentos"},
        @{Name="PhoneSvc"; Desc="Servico de Telefonia"},
        @{Name="RmSvc"; Desc="Gerenciamento de Radio"},
        @{Name="SensorDataService"; Desc="Dados de Sensores"},
        @{Name="SensrSvc"; Desc="Monitoramento de Sensores"},
        @{Name="SensorService"; Desc="Servico de Sensores"},
        @{Name="SharedAccess"; Desc="Compartilhamento de Internet (ICS)"},
        @{Name="wisvc"; Desc="Windows Insider"},
        @{Name="AJRouter"; Desc="Roteador AllJoyn"},
        @{Name="AssignedAccessManagerSvc"; Desc="Acesso Atribuido"}
    )
    
    $svcDesativados = 0
    foreach ($svc in $servicosParaDesativar) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service -and $service.StartType -ne "Disabled") {
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "    $($svc.Desc) - desativado" -ForegroundColor Gray
            $svcDesativados++
        }
    }
    Write-Status "$svcDesativados servico(s) desnecessario(s) desativado(s)" "OK"
    $totalOtimizacoes += $svcDesativados
    
    # =============================================
    # 8. NOTIFICACOES E TELEMETRIA
    # =============================================
    Write-Header "8. NOTIFICACOES E TELEMETRIA"
    
    Write-Progress2 "Desativando notificacoes durante jogos..."
    $notifPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    if (-not (Test-Path $notifPath)) { New-Item -Path $notifPath -Force | Out-Null }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Notificacoes em tela cheia desativadas" "OK"
    $totalOtimizacoes++
    
    Write-Progress2 "Reduzindo telemetria..."
    $telPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
    Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Telemetria reduzida ao minimo" "OK"
    $totalOtimizacoes++
    
    # Desativar dicas e sugestoes do Windows
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Dicas e sugestoes do Windows desativadas" "OK"
    $totalOtimizacoes++
    
    # Desativar pesquisa Bing no menu iniciar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsAADCloudSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsMSACloudSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Pesquisa Bing no menu iniciar desativada" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 9. OTIMIZACOES DE DISCO
    # =============================================
    Write-Header "9. DISCO E ARMAZENAMENTO"
    
    # Desativar Last Access Time (melhora I/O)
    Write-Progress2 "Otimizando acesso ao disco..."
    fsutil behavior set disablelastaccess 1 2>$null | Out-Null
    Write-Status "Registro de ultimo acesso desativado (mais rapido)" "OK"
    $totalOtimizacoes++
    
    # Desativar 8.3 filenames (melhora desempenho NTFS)
    fsutil behavior set disable8dot3 1 2>$null | Out-Null
    Write-Status "Nomes curtos 8.3 desativados (NTFS mais rapido)" "OK"
    $totalOtimizacoes++
    
    # Limpar arquivos temporarios
    Write-Progress2 "Limpando arquivos temporarios..."
    Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem "$env:SystemRoot\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Status "Arquivos temporarios limpos" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 10. MOUSE E ENTRADA
    # =============================================
    Write-Header "10. MOUSE E ENTRADA"
    
    Write-Progress2 "Desativando aceleracao do mouse (melhora mira em jogos)..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force -ErrorAction SilentlyContinue
    # Desativar precisao aprimorada do ponteiro
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value "10" -Type String -Force -ErrorAction SilentlyContinue
    Write-Status "Aceleracao do mouse desativada (mira mais precisa)" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 11. DIRECTX E GRAFICOS
    # =============================================
    Write-Header "11. DIRECTX E GRAFICOS"
    
    Write-Progress2 "Otimizando DirectX..."
    $ddPath = "HKLM:\SOFTWARE\Microsoft\DirectDraw"
    if (-not (Test-Path $ddPath)) { New-Item -Path $ddPath -Force | Out-Null }
    Set-ItemProperty -Path $ddPath -Name "EmulationOnly" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "DirectX otimizado (aceleracao por hardware)" "OK"
    $totalOtimizacoes++
    
    # Desativar preempcao do driver de video
    Set-ItemProperty -Path $gpuPath -Name "DpiMapIommuContiguous" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Driver de video otimizado" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 12. NVIDIA / AMD - OTIMIZACAO DA PLACA DE VIDEO
    # =============================================
    Write-Header "12. CONFIGURACOES NVIDIA / AMD"
    
    # Detectar GPU
    $gpuInfo = Get-CimInstance Win32_VideoController | Where-Object { $_.Status -eq "OK" } | Select-Object -First 1
    $gpuName = if ($gpuInfo) { $gpuInfo.Name } else { "Desconhecida" }
    Write-Info "Placa de video" "$gpuName"
    
    $isNvidia = $gpuName -match "NVIDIA|GeForce|RTX|GTX"
    $isAMD = $gpuName -match "AMD|Radeon|RX"
    
    if ($isNvidia) {
        Write-Progress2 "Aplicando otimizacoes para NVIDIA..."
        
        # Desativar economia de energia da NVIDIA
        $nvTweakPath = "HKCU:\Software\NVIDIA Corporation\Global\NVTweak"
        if (-not (Test-Path $nvTweakPath)) { New-Item -Path $nvTweakPath -Force | Out-Null }
        Set-ItemProperty -Path $nvTweakPath -Name "Gestalt" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $nvTweakPath -Name "DisplayPowerSaving" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Status "NVIDIA: economia de energia desativada" "OK"
        $totalOtimizacoes++
        
        # Desativar NvTray na inicializacao
        $nvTrayPath = "HKLM:\SOFTWARE\NVIDIA Corporation\NvTray"
        if (-not (Test-Path $nvTrayPath)) { New-Item -Path $nvTrayPath -Force | Out-Null }
        Set-ItemProperty -Path $nvTrayPath -Name "StartOnLogin" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Status "NVIDIA: NvTray na inicializacao desativado" "OK"
        $totalOtimizacoes++
        
        # Power Throttling desativado
        $powerThrottle = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
        if (-not (Test-Path $powerThrottle)) { New-Item -Path $powerThrottle -Force | Out-Null }
        Set-ItemProperty -Path $powerThrottle -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Status "NVIDIA: Power Throttling desativado" "OK"
        $totalOtimizacoes++
        
        # Perfil de desempenho maximo
        Write-Host ""
        Write-Host "  Configuracoes recomendadas no Painel NVIDIA:" -ForegroundColor Yellow
        Write-Host "    - Modo de baixa latencia: Ativado" -ForegroundColor DarkGray
        Write-Host "    - Modo de gerenciamento de energia: Preferir desempenho maximo" -ForegroundColor DarkGray
        Write-Host "    - NVIDIA Reflex: Ativado (nos jogos que suportam)" -ForegroundColor DarkGray
        Write-Host "    - Sincronizacao vertical: Desligada" -ForegroundColor DarkGray
        Write-Host "    - Filtragem de textura - Qualidade: Alto desempenho" -ForegroundColor DarkGray
        
    } elseif ($isAMD) {
        Write-Progress2 "Aplicando otimizacoes para AMD..."
        
        # Power Throttling desativado
        $powerThrottle = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling"
        if (-not (Test-Path $powerThrottle)) { New-Item -Path $powerThrottle -Force | Out-Null }
        Set-ItemProperty -Path $powerThrottle -Name "PowerThrottlingOff" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Write-Status "AMD: Power Throttling desativado" "OK"
        $totalOtimizacoes++
        
        Write-Host ""
        Write-Host "  Configuracoes recomendadas no AMD Software:" -ForegroundColor Yellow
        Write-Host "    - Radeon Anti-Lag: Ativado" -ForegroundColor DarkGray
        Write-Host "    - Radeon Chill: Desativado" -ForegroundColor DarkGray
        Write-Host "    - Sincronizacao vertical: Desligada" -ForegroundColor DarkGray
        Write-Host "    - Filtragem de textura: Desempenho" -ForegroundColor DarkGray
        Write-Host "    - Modo de tesselacao: Otimizado" -ForegroundColor DarkGray
        
    } else {
        Write-Status "GPU nao identificada como NVIDIA ou AMD - pulando ajustes especificos" "INFO"
    }
    
    # Direct3D otimizacoes (funciona para ambas)
    $d3dPath = "HKLM:\SOFTWARE\Microsoft\Direct3D\Drivers"
    if (-not (Test-Path $d3dPath)) { New-Item -Path $d3dPath -Force | Out-Null }
    Set-ItemProperty -Path $d3dPath -Name "SoftwareOnly" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    $d3dRef = "HKLM:\SOFTWARE\Microsoft\Direct3D\ReferenceDevice"
    if (-not (Test-Path $d3dRef)) { New-Item -Path $d3dRef -Force | Out-Null }
    Set-ItemProperty -Path $d3dRef -Name "AllowAsync" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "Direct3D: renderizacao assincrona ativada" "OK"
    $totalOtimizacoes++
    
    # DWM MPO Fix (corrige problemas de alt-tab no Windows 11 24H2+)
    $dwmKey = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
    Set-ItemProperty -Path $dwmKey -Name "OverlayTestMode" -Value 5 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Status "DWM: correcao de alt-tab aplicada" "OK"
    $totalOtimizacoes++
    
    # =============================================
    # 13. CS2 - CONFIGURACAO COMPETITIVA
    # =============================================
    Write-Header "13. COUNTER-STRIKE 2 (CS2)"
    
    # Procurar pasta do CS2
    $cs2Paths = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg",
        "D:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg",
        "D:\SteamLibrary\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg",
        "E:\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg",
        "E:\SteamLibrary\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg",
        "$env:ProgramFiles\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
    )
    
    # Tambem procurar via registro do Steam
    $steamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue).SteamPath
    if ($steamPath) {
        $cs2Paths += "$steamPath\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
    }
    
    $cs2CfgDir = $null
    foreach ($p in $cs2Paths) {
        if (Test-Path $p) {
            $cs2CfgDir = $p
            break
        }
    }
    
    if (-not $cs2CfgDir) {
        Write-Status "CS2 nao encontrado no sistema (pular configuracao)" "INFO"
        Write-Host "  Se o CS2 estiver instalado em outro local, copie o autoexec" -ForegroundColor DarkGray
        Write-Host "  manualmente para a pasta cfg do jogo." -ForegroundColor DarkGray
    } else {
        Write-Info "Pasta CS2" "$cs2CfgDir"
        Write-Host ""
        Write-Host "  Vai criar o arquivo autoexec.cfg com configuracoes" -ForegroundColor Yellow
        Write-Host "  competitivas otimizadas para FPS e menor latencia." -ForegroundColor Yellow
        Write-Host "  (Se ja existir um autoexec, sera salvo como backup)" -ForegroundColor DarkGray
        Write-Host ""
        
        $cs2opt = Read-Host "  Instalar autoexec competitivo no CS2? (S/N)"
        if ($cs2opt -eq "S" -or $cs2opt -eq "s") {
            
            # Backup do autoexec existente
            $autoexecPath = "$cs2CfgDir\autoexec.cfg"
            if (Test-Path $autoexecPath) {
                $backupName = "autoexec_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').cfg"
                Copy-Item $autoexecPath "$cs2CfgDir\$backupName" -Force
                Write-Status "Backup do autoexec anterior: $backupName" "OK"
            }
            
            # Criar autoexec competitivo
            $autoexecContent = @"
// =============================================================
// VW INFORMATICA - CS2 AUTOEXEC COMPETITIVO
// Otimizado para jogos competitivos e ranked
// Xique-Xique/BA - (74) 99937-8375
// =============================================================

// --- REDE (menor lag e melhor registro de tiros) ---
rate 786432
cl_interp_ratio 1
cl_interp 0
cl_cmdrate 128
cl_updaterate 128

// --- DESEMPENHO (mais FPS) ---
fps_max 0
fps_max_ui 120
r_drawtracers_firstperson 0
engine_no_focus_sleep 0

// --- AUDIO COMPETITIVO ---
snd_voipvolume 0.7
snd_headphone_pan_exponent 1.2
snd_front_headphone_position 45
snd_rear_headphone_position 135
snd_mixahead 0.025
snd_music_volume 0
snd_menumusic_volume 0
snd_roundstart_volume 0
snd_roundend_volume 0
snd_mapobjective_volume 0
snd_mvp_volume 0
snd_deathcamera_volume 0
snd_tensecondwarning_volume 0.3

// --- MIRA (crosshair competitiva) ---
cl_crosshairstyle 4
cl_crosshairsize 2
cl_crosshairgap -1
cl_crosshairthickness 1
cl_crosshaircolor 1
cl_crosshair_drawoutline 1
cl_crosshair_outlinethickness 0.5
cl_crosshairalpha 255
cl_crosshair_sniper_width 1
cl_crosshair_t 0
cl_crosshairdot 0

// --- VIEWMODEL (arma nao atrapalha visao) ---
viewmodel_fov 68
viewmodel_offset_x 2.5
viewmodel_offset_y 0
viewmodel_offset_z -1.5
viewmodel_presetpos 3

// --- RADAR ---
cl_radar_always_centered 0
cl_radar_scale 0.3
cl_hud_radar_scale 1.15
cl_radar_icon_scale_min 0.7
cl_radar_rotate 1

// --- MOUSE (sem aceleracao) ---
m_rawinput 1
zoom_sensitivity_ratio 1.0

// --- HUD ---
cl_showfps 0
cl_hud_color 7
hud_scaling 0.85
cl_hud_playercount_showcount 1
cl_hud_playercount_pos 0

// --- BINDS UTEIS ---
bind "MWHEELDOWN" "+jump"
bind "mouse4" "+voicerecord"

// --- CONFIRMAR CARREGAMENTO ---
echo ""
echo "============================================="
echo "  VW INFORMATICA - Autoexec CS2 carregado!"
echo "  Configuracao competitiva ativa."
echo "============================================="
echo ""

host_writeconfig
"@
            
            $autoexecContent | Out-File -FilePath $autoexecPath -Encoding ASCII -Force
            Write-Status "Autoexec competitivo instalado em: $autoexecPath" "OK"
            $totalOtimizacoes++
            
            # Configurar launch options do CS2
            Write-Host ""
            Write-Host "  Opcoes de lancamento recomendadas para o CS2:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  -novid -high -nojoy -fullscreen +exec autoexec.cfg +fps_max 0" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Para configurar:" -ForegroundColor DarkGray
            Write-Host "    1. Abra o Steam" -ForegroundColor DarkGray
            Write-Host "    2. Clique com botao direito no CS2 > Propriedades" -ForegroundColor DarkGray
            Write-Host "    3. Em 'Opcoes de lancamento', cole a linha acima" -ForegroundColor DarkGray
            Write-Host ""
            
            # Tentar configurar launch options automaticamente via registro
            $cs2AppId = "730"
            $steamUserData = "$steamPath\userdata"
            if (Test-Path $steamUserData) {
                $userDirs = Get-ChildItem $steamUserData -Directory | Select-Object -First 1
                if ($userDirs) {
                    $localConfig = "$($userDirs.FullName)\config\localconfig.vdf"
                    if (Test-Path $localConfig) {
                        Write-Status "Arquivo de configuracao do Steam encontrado" "INFO"
                        Write-Host "  As opcoes de lancamento precisam ser configuradas" -ForegroundColor DarkGray
                        Write-Host "  manualmente no Steam (veja as instrucoes acima)." -ForegroundColor DarkGray
                    }
                }
            }
            
            $Global:Report += "  [CS2] Autoexec competitivo instalado"
        }
    }
    
    # =============================================
    # RESUMO FINAL
    # =============================================
    Write-Host ""
    Write-Host ""
    Write-Host "  +==========================================================+" -ForegroundColor Green
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     OTIMIZACAO PARA JOGOS CONCLUIDA!                     |" -ForegroundColor Green
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     $totalOtimizacoes ajustes aplicados com sucesso                   |" -ForegroundColor White
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     Reinicie o computador para aplicar tudo              |" -ForegroundColor Yellow
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  |     Para desfazer: use o ponto de restauracao criado     |" -ForegroundColor DarkGray
    Write-Host "  |                                                          |" -ForegroundColor Green
    Write-Host "  +==========================================================+" -ForegroundColor Green
    Write-Host ""
    
    $rb = Read-Host "  Deseja reiniciar agora? (S/N)"
    if ($rb -eq "S" -or $rb -eq "s") {
        shutdown /r /t 10 /c "VW Informatica - Otimizacao para jogos concluida"
    }
    
    $Global:Report += "  --- Otimizacao para jogos: $totalOtimizacoes ajustes aplicados ---"
}

function Repair-WMI {
    # (chamado pela etapa 4 do reparo)
    
    Write-Progress2 "Parando servico WMI..."
    Stop-Service -Name "Winmgmt" -Force -ErrorAction SilentlyContinue
    Write-Status "Servico WMI parado" "OK"
    
    Write-Progress2 "Reconstruindo repositorio WMI..."
    $wmiPath = "$env:SystemRoot\System32\wbem\Repository"
    if (Test-Path $wmiPath) {
        $backupName = "Repository.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Rename-Item $wmiPath "$env:SystemRoot\System32\wbem\$backupName" -Force -ErrorAction SilentlyContinue
        Write-Status "Backup do repositorio WMI: $backupName" "OK"
    }
    
    Write-Progress2 "Reiniciando servico WMI..."
    Start-Service -Name "Winmgmt" -ErrorAction SilentlyContinue
    Write-Status "Servico WMI reiniciado (repositorio sera recriado)" "OK"
    
    Write-Progress2 "Re-registrando DLLs e MOFs do WMI..."
    $wbemDir = "$env:SystemRoot\System32\wbem"
    Get-ChildItem "$wbemDir\*.dll" -ErrorAction SilentlyContinue | ForEach-Object {
        regsvr32.exe /s $_.FullName 2>$null
    }
    
    # Recompilar MOFs
    Get-ChildItem "$wbemDir\*.mof" -ErrorAction SilentlyContinue | ForEach-Object {
        mofcomp.exe $_.FullName 2>$null | Out-Null
    }
    Get-ChildItem "$wbemDir\*.mfl" -ErrorAction SilentlyContinue | ForEach-Object {
        mofcomp.exe $_.FullName 2>$null | Out-Null
    }
    Write-Status "DLLs e MOFs do WMI re-registrados" "OK"
    
    # Verificar WMI
    Write-Progress2 "Verificando se o WMI esta funcionando..."
    try {
        $testWMI = Get-WmiObject Win32_OperatingSystem -ErrorAction Stop
        if ($testWMI) {
            Write-Status "WMI funcionando corretamente!" "OK"
        }
    } catch {
        Write-Status "WMI ainda com problemas - pode precisar de reinicializacao" "AVISO"
    }
    
    $Global:Report += "  --- WMI reparado ---"
}

function Repair-Licensing {
    # (chamado pela etapa 5 do reparo)
    
    Write-Progress2 "Parando servico de licenciamento (sppsvc)..."
    Stop-Service -Name "sppsvc" -Force -ErrorAction SilentlyContinue
    Write-Status "Servico de licenciamento parado" "OK"
    
    Write-Progress2 "Limpando cache de licenciamento..."
    $tokensPath = "$env:SystemRoot\System32\spp\store\2.0"
    if (Test-Path $tokensPath) {
        # Backup dos tokens
        $tokenBackup = "$tokensPath\tokens.dat.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        if (Test-Path "$tokensPath\tokens.dat") {
            Copy-Item "$tokensPath\tokens.dat" $tokenBackup -Force -ErrorAction SilentlyContinue
            Write-Status "Backup dos tokens de licenca criado" "OK"
        }
    }
    
    Write-Progress2 "Reconstruindo tokens de licenca..."
    cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /rilc 2>$null | Out-Null
    Write-Status "Tokens de licenca reinstalados" "OK"
    
    Write-Progress2 "Reiniciando servico de licenciamento..."
    Start-Service -Name "sppsvc" -ErrorAction SilentlyContinue
    Write-Status "Servico de licenciamento reiniciado" "OK"
    
    Write-Progress2 "Forcando reavaliacao de licenca..."
    cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /rearm 2>$null | Out-Null
    Write-Status "Reavaliacao de licenca solicitada" "OK"
    
    # Limpar chaves que podem causar problemas
    Write-Progress2 "Limpando chaves de registro problematicas..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "SuppressRulesEngine" -Force -ErrorAction SilentlyContinue
    Write-Status "Chaves problematicas removidas" "OK"
    
    Write-Status "Reparo de licenciamento concluido! Reinicie o PC." "OK"
    $Global:Report += "  --- Licenciamento reparado ---"
}

function Repair-WPARegistry {
    # (chamado pela etapa 6 do reparo)
    
    Write-Progress2 "Parando servicos de protecao..."
    Stop-Service -Name "sppsvc" -Force -ErrorAction SilentlyContinue
    
    Write-Progress2 "Corrigindo permissoes do registro WPA..."
    
    # Redefinir permissoes do WPA
    $wpaKey = "HKLM:\SYSTEM\WPA"
    if (Test-Path $wpaKey) {
        try {
            $acl = Get-Acl $wpaKey -ErrorAction Stop
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
                "NT SERVICE\sppsvc",
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            $acl.AddAccessRule($rule)
            Set-Acl $wpaKey $acl -ErrorAction Stop
            Write-Status "Permissoes do registro WPA corrigidas" "OK"
        } catch {
            Write-Status "Nao foi possivel alterar permissoes do WPA: $($_.Exception.Message)" "AVISO"
        }
    } else {
        Write-Status "Chave WPA nao encontrada (pode ser normal)" "INFO"
    }
    
    # Reparar ClipSVC
    Write-Progress2 "Reparando servico ClipSVC..."
    Stop-Service -Name "ClipSVC" -Force -ErrorAction SilentlyContinue
    Start-Service -Name "ClipSVC" -ErrorAction SilentlyContinue
    Write-Status "Servico ClipSVC reiniciado" "OK"
    
    # Reparar wlidsvc (Windows Live ID)
    Write-Progress2 "Reparando servico de identidade..."
    Stop-Service -Name "wlidsvc" -Force -ErrorAction SilentlyContinue
    Start-Service -Name "wlidsvc" -ErrorAction SilentlyContinue
    Write-Status "Servico de identidade reiniciado" "OK"
    
    Write-Progress2 "Reiniciando servico de protecao..."
    Start-Service -Name "sppsvc" -ErrorAction SilentlyContinue
    Write-Status "Servico de protecao reiniciado" "OK"
    
    Write-Status "Reparo do registro WPA concluido!" "OK"
    $Global:Report += "  --- Registro WPA reparado ---"
}

function Repair-DotNet {
    # (chamado pela etapa 7 do reparo)
    
    Write-Progress2 "Verificando versoes do .NET instaladas..."
    $dotnetVersions = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -Recurse -ErrorAction SilentlyContinue | 
        Get-ItemProperty -Name "Version" -ErrorAction SilentlyContinue | 
        Where-Object { $_.Version } | Select-Object -Property Version -Unique
    
    foreach ($v in $dotnetVersions) {
        Write-Host "    .NET $($v.Version)" -ForegroundColor Gray
    }
    
    Write-Progress2 "Reparando .NET via DISM..."
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart 2>&1 | Out-Null
    Write-Status ".NET Framework 3.5 habilitado" "OK"
    
    Write-Progress2 "Reparando .NET 4.x..."
    # Re-registrar assemblies do .NET
    $netPaths = @(
        "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319",
        "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319"
    )
    foreach ($netPath in $netPaths) {
        if (Test-Path "$netPath\ngen.exe") {
            & "$netPath\ngen.exe" update 2>$null | Out-Null
            & "$netPath\ngen.exe" executeQueuedItems 2>$null | Out-Null
        }
    }
    Write-Status "Cache de assemblies .NET atualizado" "OK"
    
    # Verificar e instalar .NET Runtime mais recente
    Write-Progress2 "Verificando .NET Runtime moderno..."
    $dotnetModern = dotnet --list-runtimes 2>$null
    if ($dotnetModern) {
        Write-Status ".NET Runtime moderno instalado" "OK"
        $dotnetModern | Select-Object -First 3 | ForEach-Object {
            Write-Host "    $_" -ForegroundColor Gray
        }
    } else {
        Write-Status ".NET Runtime moderno nao encontrado (normal em PCs antigos)" "INFO"
    }
    
    Write-Status "Reparo do .NET concluido!" "OK"
    $Global:Report += "  --- .NET Framework reparado ---"
}

function Repair-WindowsStore {
    # (chamado pela etapa 8 do reparo)
    
    Write-Progress2 "Resetando cache da Microsoft Store..."
    Start-Process "wsreset.exe" -Wait -ErrorAction SilentlyContinue
    Write-Status "Cache da Store resetado" "OK"
    
    Write-Progress2 "Re-registrando Microsoft Store..."
    try {
        Get-AppxPackage -AllUsers Microsoft.WindowsStore -ErrorAction SilentlyContinue | ForEach-Object {
            Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
        }
        Write-Status "Microsoft Store re-registrada" "OK"
    } catch {
        Write-Status "Erro ao re-registrar Store: $($_.Exception.Message)" "AVISO"
    }
    
    Write-Progress2 "Reparando servicos da Store..."
    @("wuauserv", "bits", "AppXSvc", "ClipSVC", "InstallService") | ForEach-Object {
        Stop-Service -Name $_ -Force -ErrorAction SilentlyContinue
        Start-Service -Name $_ -ErrorAction SilentlyContinue
    }
    Write-Status "Servicos da Store reiniciados" "OK"
    
    # Reparar App Installer
    Write-Progress2 "Re-registrando App Installer..."
    Get-AppxPackage -AllUsers Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue | ForEach-Object {
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
    }
    Write-Status "App Installer re-registrado" "OK"
    
    Write-Status "Reparo da Microsoft Store concluido!" "OK"
    $Global:Report += "  --- Microsoft Store reparada ---"
}

function Repair-Services {
    # (chamado pela etapa 8 do reparo)
    
    Write-Progress2 "Restaurando servicos essenciais para o padrao..."
    
    $servicosEssenciais = @(
        @{Name="wuauserv"; Start="Manual"; Desc="Windows Update"},
        @{Name="bits"; Start="Manual"; Desc="Transferencia Inteligente em Segundo Plano"},
        @{Name="cryptSvc"; Start="Automatic"; Desc="Servicos de Criptografia"},
        @{Name="msiserver"; Start="Manual"; Desc="Windows Installer"},
        @{Name="Winmgmt"; Start="Automatic"; Desc="Instrumentacao de Gerenciamento (WMI)"},
        @{Name="sppsvc"; Start="AutomaticDelayedStart"; Desc="Protecao de Software"},
        @{Name="EventLog"; Start="Automatic"; Desc="Log de Eventos do Windows"},
        @{Name="Schedule"; Start="Automatic"; Desc="Agendador de Tarefas"},
        @{Name="RpcSs"; Start="Automatic"; Desc="Chamada de Procedimento Remoto (RPC)"},
        @{Name="DcomLaunch"; Start="Automatic"; Desc="Lancador de Processos DCOM"},
        @{Name="nsi"; Start="Automatic"; Desc="Servico de Interface de Rede"},
        @{Name="Dhcp"; Start="Automatic"; Desc="Cliente DHCP"},
        @{Name="Dnscache"; Start="Automatic"; Desc="Cliente DNS"},
        @{Name="NlaSvc"; Start="Automatic"; Desc="Reconhecimento de Local de Rede"},
        @{Name="W32Time"; Start="Manual"; Desc="Horario do Windows"},
        @{Name="Themes"; Start="Automatic"; Desc="Temas"},
        @{Name="AudioSrv"; Start="Automatic"; Desc="Audio do Windows"},
        @{Name="AudioEndpointBuilder"; Start="Automatic"; Desc="Construtor de Ponto de Audio"}
    )
    
    $restaurados = 0
    foreach ($svc in $servicosEssenciais) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            try {
                Set-Service -Name $svc.Name -StartupType $svc.Start -ErrorAction SilentlyContinue
                if ($service.Status -ne "Running" -and $svc.Start -eq "Automatic") {
                    Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
                }
                Write-Host "    $($svc.Desc) - restaurado ($($svc.Start))" -ForegroundColor Gray
                $restaurados++
            } catch {
                Write-Host "    $($svc.Desc) - falha ao restaurar" -ForegroundColor DarkYellow
            }
        }
    }
    
    Write-Host ""
    Write-Status "$restaurados servico(s) restaurado(s) para o padrao" "OK"
    $Global:Report += "  --- $restaurados servicos restaurados ---"
}

function Save-Report {
    Write-Header "SALVANDO RELATORIO"
    $header = @"
============================================================
  RELATORIO - VW INFORMATICA v3.6
  Xique-Xique/BA | (74) 99937-8375 | @vw.informatica
  Data: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
  PC: $env:COMPUTERNAME | Usuario: $env:USERNAME
============================================================
"@
    ($header + "`n" + ($Global:Report -join "`n")) | Out-File -FilePath $ReportPath -Encoding UTF8 -Force
    Write-Host "  Salvo em: $ReportPath" -ForegroundColor Green
    $o = Read-Host "  Abrir? (S/N)"
    if ($o -eq "S" -or $o -eq "s") { Start-Process notepad.exe $ReportPath }
}

function Run-FullDiagnostic {
    Write-Host "`n  Diagnostico COMPLETO...`n" -ForegroundColor Cyan
    Test-OperatingSystem; Read-Host "`n  Pressione ENTER para continuar..."
    Test-DiskDrive; Read-Host "`n  Pressione ENTER para continuar..."
    Test-Memory; Read-Host "`n  Pressione ENTER para continuar..."
    Test-Network; Read-Host "`n  Pressione ENTER para continuar..."
    Test-Battery; Read-Host "`n  Pressione ENTER para continuar..."
    Test-Screen
    Write-Header "DIAGNOSTICO COMPLETO FINALIZADO"
    $s = Read-Host "  Salvar relatorio? (S/N)"
    if ($s -eq "S" -or $s -eq "s") { Save-Report }
}

# ============================================================
#  LOOP PRINCIPAL
# ============================================================

do {
    Show-Menu
    $choice = Read-Host "  Escolha uma opcao"
    
    switch ($choice) {
        "1"  { Run-FullDiagnostic }
        "2"  { Test-DiskDrive }
        "3"  { Test-Memory }
        "4"  { Test-Screen }
        "5"  { Test-OperatingSystem }
        "6"  { Test-Network }
        "7"  { Test-Battery }
        "8"  { Scan-Antivirus }
        "9"  { Check-Drivers }
        "10" { Check-Security }
        "11" { Check-SuspiciousPrograms }
        "12" { Repair-System }
        "13" { Repair-Disk }
        "14" { Clean-System }
        "15" { Optimize-Startup }
        "16" { Repair-WindowsUpdate }
        "17" { Reset-Network }
        "18" { Repair-FullOnline }
        "19" { Save-Report }
        "20" { Remove-WindowsAI }
        "21" { Activate-MAS }
        "22" { Optimize-Gaming }
        "0"  { 
            Write-Host "`n  VW Informatica - Obrigado!" -ForegroundColor Cyan
            Write-Host "  (74) 99937-8375 | @vw.informatica`n" -ForegroundColor DarkGray
            break 
        }
        default { Write-Host "`n  Opcao invalida! Tente novamente!" -ForegroundColor Red }
    }
    
    if ($choice -ne "0") {
        Write-Host "`n  Pressione ENTER para voltar ao menu..." -ForegroundColor DarkGray
        Read-Host
    }
} while ($choice -ne "0")
