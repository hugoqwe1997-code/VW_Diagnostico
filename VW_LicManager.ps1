# ============================================================
#  VW INFORMATICA - GERENCIADOR DE LICENCAS v2
#  Dois cliques no .bat e este script roda automaticamente
# ============================================================

$GistRawUrl = "https://gist.githubusercontent.com/hugoqwe1997-code/a1138859c1cf544c2fbe8f5676c6cefd/raw/gistfile1.txt"
$GistEditUrl = "https://gist.github.com/hugoqwe1997-code/a1138859c1cf544c2fbe8f5676c6cefd"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-GistData {
    try {
        $raw = Invoke-RestMethod -Uri $GistRawUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        if ($raw -is [PSCustomObject]) { return $raw }
        return $raw | ConvertFrom-Json
    } catch {
        try {
            $resp = Invoke-WebRequest -Uri $GistRawUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
            return $resp.Content | ConvertFrom-Json
        } catch {
            Write-Host "  [ERRO] Nao foi possivel acessar o Gist" -ForegroundColor Red
            Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkGray
            return $null
        }
    }
}

function New-Key {
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    $p2 = Get-Random -Minimum 1000 -Maximum 9999
    $p3 = -join (1..4 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    $p4 = Get-Random -Minimum 1000 -Maximum 9999
    return "VW-$p2-$p3-$p4"
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  +==============================================+" -ForegroundColor DarkCyan
    Write-Host "  |                                              |" -ForegroundColor DarkCyan
    Write-Host "  |  VW INFORMATICA - GERENCIADOR DE LICENCAS    |" -ForegroundColor Cyan
    Write-Host "  |  Xique-Xique/BA - (74) 99937-8375           |" -ForegroundColor DarkGray
    Write-Host "  |                                              |" -ForegroundColor DarkCyan
    Write-Host "  +==============================================+" -ForegroundColor DarkCyan
    Write-Host "  |  [1] Gerar nova chave (copia JSON pronto)    |" -ForegroundColor White
    Write-Host "  |  [2] Renovar licenca (+30 dias)              |" -ForegroundColor White
    Write-Host "  |  [3] Desativar licenca                       |" -ForegroundColor White
    Write-Host "  |  [4] Ver todas as licencas                   |" -ForegroundColor White
    Write-Host "  |  [5] Abrir Gist no navegador                 |" -ForegroundColor White
    Write-Host "  |  [6] Instrucoes                              |" -ForegroundColor White
    Write-Host "  |  [0] Sair                                    |" -ForegroundColor DarkGray
    Write-Host "  +==============================================+" -ForegroundColor DarkCyan
    Write-Host ""
}

function Menu-Gerar {
    Write-Host ""
    Write-Host "  === GERAR NOVA LICENCA ===" -ForegroundColor Cyan
    Write-Host ""
    $cliente = Read-Host "  Nome do cliente"
    $whatsapp = Read-Host "  WhatsApp (com DDD)"
    $pcsInput = Read-Host "  Quantos PCs (padrao 1)"
    if (-not $pcsInput) { $pcsInput = "1" }
    $pcs = [int]$pcsInput

    Write-Host ""
    Write-Host "  Gerando chave e baixando Gist atual..." -ForegroundColor DarkGray

    $chave = New-Key
    $validade = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")

    $dados = Get-GistData
    if (-not $dados) {
        # Se nao conseguiu baixar, criar novo
        $dados = [PSCustomObject]@{
            versao = "1.0"
            atualizado = (Get-Date).ToString("yyyy-MM-dd")
            licencas = [PSCustomObject]@{}
        }
    }

    # Adicionar nova licenca
    $novaLic = [PSCustomObject]@{
        cliente = $cliente
        whatsapp = $whatsapp
        validade = $validade
        ativo = $true
        pcs = $pcs
        plano = "mensal"
    }
    $dados.licencas | Add-Member -NotePropertyName $chave -NotePropertyValue $novaLic -Force
    $dados.atualizado = (Get-Date).ToString("yyyy-MM-dd")

    # Gerar JSON compacto e copiar
    $jsonFinal = $dados | ConvertTo-Json -Depth 10 -Compress
    Set-Clipboard -Value $jsonFinal

    Write-Host ""
    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
    Write-Host "  |  LICENCA GERADA COM SUCESSO!                 |" -ForegroundColor Green
    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Chave    : $chave" -ForegroundColor Yellow
    Write-Host "  Cliente  : $cliente" -ForegroundColor White
    Write-Host "  WhatsApp : $whatsapp" -ForegroundColor White
    Write-Host "  Validade : $validade (30 dias)" -ForegroundColor White
    Write-Host "  PCs      : $pcs" -ForegroundColor White
    Write-Host ""
    Write-Host "  JSON COMPLETO COPIADO PARA A AREA DE TRANSFERENCIA!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Agora faca:" -ForegroundColor Yellow
    Write-Host "    1. Opcao [5] para abrir o Gist" -ForegroundColor White
    Write-Host "    2. Clique no lapis (Edit)" -ForegroundColor White
    Write-Host "    3. CTRL+A (selecionar tudo)" -ForegroundColor White
    Write-Host "    4. CTRL+V (colar por cima)" -ForegroundColor White
    Write-Host "    5. Clique 'Update secret gist'" -ForegroundColor White
    Write-Host ""
    Write-Host "  ================================================" -ForegroundColor DarkGray
    Write-Host "  MENSAGEM PARA ENVIAR AO CLIENTE:" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  VW Informatica - Diagnostico e Reparo" -ForegroundColor White
    Write-Host ""
    Write-Host "  Sua chave: $chave" -ForegroundColor Cyan
    Write-Host "  Valida ate: $validade" -ForegroundColor White
    Write-Host ""
    Write-Host "  Para usar, abra o PowerShell como Admin e cole:" -ForegroundColor White
    Write-Host "  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hugoqwe1997-code/VW_Diagnostico/main/VW_Diagnostico.ps1'))" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Duvidas: (74) 99937-8375" -ForegroundColor White
    Write-Host "  ================================================" -ForegroundColor DarkGray
}

function Menu-Renovar {
    Write-Host ""
    Write-Host "  === RENOVAR LICENCA ===" -ForegroundColor Cyan
    Write-Host ""
    $chave = (Read-Host "  Chave do cliente").Trim().ToUpper()

    Write-Host ""
    Write-Host "  Baixando Gist e renovando..." -ForegroundColor DarkGray

    $dados = Get-GistData
    if (-not $dados) { return }

    $lic = $dados.licencas.PSObject.Properties | Where-Object { $_.Name -eq $chave }
    if (-not $lic) {
        Write-Host "  [ERRO] Chave '$chave' nao encontrada!" -ForegroundColor Red
        return
    }

    $novaVal = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")
    $lic.Value.validade = $novaVal
    $lic.Value.ativo = $true
    $dados.atualizado = (Get-Date).ToString("yyyy-MM-dd")

    $jsonFinal = $dados | ConvertTo-Json -Depth 10 -Compress
    Set-Clipboard -Value $jsonFinal

    Write-Host ""
    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
    Write-Host "  |  LICENCA RENOVADA COM SUCESSO!               |" -ForegroundColor Green
    Write-Host "  +----------------------------------------------+" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Chave         : $chave" -ForegroundColor Yellow
    Write-Host "  Cliente       : $($lic.Value.cliente)" -ForegroundColor White
    Write-Host "  Nova validade : $novaVal (+30 dias)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  JSON COPIADO! Abra o Gist > Edit > CTRL+A > CTRL+V > Update" -ForegroundColor Yellow
}

function Menu-Desativar {
    Write-Host ""
    Write-Host "  === DESATIVAR LICENCA ===" -ForegroundColor Cyan
    Write-Host ""
    $chave = (Read-Host "  Chave para desativar").Trim().ToUpper()

    Write-Host ""
    Write-Host "  Baixando Gist e desativando..." -ForegroundColor DarkGray

    $dados = Get-GistData
    if (-not $dados) { return }

    $lic = $dados.licencas.PSObject.Properties | Where-Object { $_.Name -eq $chave }
    if (-not $lic) {
        Write-Host "  [ERRO] Chave '$chave' nao encontrada!" -ForegroundColor Red
        return
    }

    $lic.Value.ativo = $false
    $dados.atualizado = (Get-Date).ToString("yyyy-MM-dd")

    $jsonFinal = $dados | ConvertTo-Json -Depth 10 -Compress
    Set-Clipboard -Value $jsonFinal

    Write-Host ""
    Write-Host "  +----------------------------------------------+" -ForegroundColor Red
    Write-Host "  |  LICENCA DESATIVADA!                         |" -ForegroundColor Red
    Write-Host "  +----------------------------------------------+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Chave   : $chave" -ForegroundColor Yellow
    Write-Host "  Cliente : $($lic.Value.cliente)" -ForegroundColor White
    Write-Host "  Status  : DESATIVADO" -ForegroundColor Red
    Write-Host ""
    Write-Host "  JSON COPIADO! Abra o Gist > Edit > CTRL+A > CTRL+V > Update" -ForegroundColor Yellow
}

function Menu-Listar {
    Write-Host ""
    Write-Host "  === LICENCAS CADASTRADAS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Buscando no Gist..." -ForegroundColor DarkGray
    Write-Host ""

    $dados = Get-GistData
    if (-not $dados) { return }

    $total = 0; $ativos = 0; $expirados = 0; $inativos = 0

    Write-Host "  Chave                  Cliente          Validade    Status" -ForegroundColor Cyan
    Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray

    foreach ($p in $dados.licencas.PSObject.Properties) {
        $total++
        $v = [datetime]::ParseExact($p.Value.validade, "yyyy-MM-dd", $null)
        $dias = ($v - (Get-Date)).Days

        if (-not $p.Value.ativo) {
            $st = "INATIVO"; $cor = "Red"; $inativos++
        } elseif ($dias -lt 0) {
            $st = "EXPIRADO"; $cor = "Red"; $expirados++
        } elseif ($dias -le 5) {
            $st = "$dias dias!"; $cor = "Yellow"; $ativos++
        } else {
            $st = "$dias dias"; $cor = "Green"; $ativos++
        }

        $nome = $p.Value.cliente
        if ($nome.Length -gt 16) { $nome = $nome.Substring(0, 16) }
        $nome = $nome.PadRight(16)

        Write-Host "  $($p.Name)  $nome  $($p.Value.validade)  " -NoNewline
        Write-Host $st -ForegroundColor $cor
    }

    Write-Host "  ---------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Total: $total | Ativos: $ativos | Expirados: $expirados | Inativos: $inativos" -ForegroundColor White
}

function Menu-Instrucoes {
    Clear-Host
    Write-Host ""
    Write-Host "  +==============================================+" -ForegroundColor Cyan
    Write-Host "  |  COMO USAR - SEMPRE O MESMO PROCESSO         |" -ForegroundColor Cyan
    Write-Host "  +==============================================+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  GERAR / RENOVAR / DESATIVAR:" -ForegroundColor Yellow
    Write-Host "  ------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  1. Escolha a opcao no menu (1, 2 ou 3)" -ForegroundColor White
    Write-Host "  2. O JSON COMPLETO e copiado automaticamente" -ForegroundColor White
    Write-Host "  3. Opcao [5] para abrir o Gist" -ForegroundColor White
    Write-Host "  4. Clique no lapis (Edit)" -ForegroundColor White
    Write-Host "  5. CTRL+A (selecionar tudo)" -ForegroundColor White
    Write-Host "  6. CTRL+V (colar por cima)" -ForegroundColor White
    Write-Host "  7. Clique 'Update secret gist'" -ForegroundColor White
    Write-Host "  8. Pronto!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  PRECOS SUGERIDOS:" -ForegroundColor Yellow
    Write-Host "  ------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  1 PC (pessoal)       : R$ 29,90/mes" -ForegroundColor White
    Write-Host "  3 PCs (profissional) : R$ 49,90/mes" -ForegroundColor White
    Write-Host "  Ilimitado (tecnico)  : R$ 79,90/mes" -ForegroundColor White
    Write-Host "  Plano anual          : 10x mensal" -ForegroundColor White
}

# ============================================================
#  LOOP PRINCIPAL
# ============================================================
do {
    Show-Menu
    $choice = Read-Host "  Escolha"

    switch ($choice) {
        "1" { Menu-Gerar }
        "2" { Menu-Renovar }
        "3" { Menu-Desativar }
        "4" { Menu-Listar }
        "5" { Start-Process $GistEditUrl }
        "6" { Menu-Instrucoes }
        "0" { exit }
    }

    if ($choice -ne "0" -and $choice -ne "5") {
        Write-Host ""
        Write-Host "  Pressione ENTER para voltar ao menu..." -ForegroundColor DarkGray
        Read-Host
    }
} while ($choice -ne "0")
