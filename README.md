<p align="center">
  <img src="https://img.shields.io/badge/VW_INFORMATICA-Diagnostico_e_Reparo-orange?style=for-the-badge&logo=windows-terminal&logoColor=white" alt="VW Informatica"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/versao-3.1-blue?style=flat-square" alt="Versao"/>
  <img src="https://img.shields.io/badge/plataforma-Windows_10%20|%2011-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows"/>
  <img src="https://img.shields.io/badge/linguagem-PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white" alt="PowerShell"/>
  <img src="https://img.shields.io/badge/licenca-livre-green?style=flat-square" alt="Licenca"/>
  <img src="https://img.shields.io/github/last-commit/hugoqwe1997-code/VW_Diagnostico?style=flat-square&label=atualizado" alt="Ultimo commit"/>
  <img src="https://img.shields.io/github/repo-size/hugoqwe1997-code/VW_Diagnostico?style=flat-square&label=tamanho" alt="Tamanho"/>
</p>

<p align="center">
  <b>Ferramenta completa de diagnostico, varredura de seguranca e reparo para Windows</b><br/>
  Desenvolvido por <b>VW Informatica</b> - Xique-Xique/BA
</p>

---

## Executar em 1 Comando

Abra o **PowerShell como Administrador** e cole:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hugoqwe1997-code/VW_Diagnostico/main/VW_Diagnostico.ps1'))
```

> Requer conexao com a internet. O script baixa e executa automaticamente.

---

## Funcionalidades

### Diagnosticos

| # | Funcao | O que faz |
|---|--------|-----------|
| 1 | Diagnostico COMPLETO | Executa todos os testes abaixo em sequencia |
| 2 | HD / SSD | Saude SMART, velocidade leitura/escrita, espaco, erros no Event Log |
| 3 | Memoria RAM | Modulos, slots livres, tipo DDR, fabricante, teste de integridade |
| 4 | Tela / Monitor | Info da placa de video + abre teste visual HTML no navegador |
| 5 | Sistema Operacional | Versao, ativacao, CPU, temperatura, servicos, tempo ligado |
| 6 | Rede / Internet | Adaptadores, DNS, ping, velocidade download, sinal Wi-Fi |
| 7 | Bateria | Saude, capacidade original vs atual, relatorio powercfg |

### Varredura e Seguranca (Online)

| # | Funcao | O que faz |
|---|--------|-----------|
| 8 | Antivirus | Windows Defender: varredura rapida, completa, offline, atualizar definicoes |
| 9 | Drivers | Detecta drivers com erro, antigos (>3 anos), busca e instala via Windows Update |
| 10 | Seguranca | Firewall, UAC, portas abertas suspeitas, conexoes externas, RDP, contas admin |
| 11 | Programas Suspeitos | Varre adware/PUPs, extensoes Chrome, tarefas agendadas, servicos de terceiros |

### Reparos

| # | Funcao | O que faz |
|---|--------|-----------|
| 12 | Reparar Sistema (completo) | DISM + SFC + WMI + Licenca + WPA + .NET + Store + Servicos |
| 13 | CHKDSK | Verifica e corrige erros no disco |
| 14 | Limpeza Completa | Temp, cache, prefetch, WU cache, componentes DISM, logs, lixeira, fontes |
| 15 | Inicializacao | Lista programas que iniciam com o Windows |
| 16 | Windows Update | Para, limpa, re-registra DLLs, reinicia + busca e instala atualizacoes |
| 17 | Reset de Rede | DNS, IP, Winsock, TCP/IP, Firewall, ARP |
| 18 | **Reparo COMPLETO** | Executa tudo: antivirus + DISM + SFC + drivers + updates + limpeza |

### Remocao de IA do Windows 11

| # | Funcao | O que faz |
|---|--------|-----------|
| 20 | Remover IA | Remove Copilot, Recall, apps com IA, pacotes, OneDrive AI, Studio Effects |

### Ativacao Windows / Office

| # | Funcao | O que faz |
|---|--------|-----------|
| 21 | Ativar Windows/Office (MAS) | HWID, Ohook, TSforge, KMS Online, troubleshoot |

### Otimizacao para Jogos

| # | Funcao | O que faz |
|---|--------|-----------|
| 22 | Otimizar Windows para Jogos | 35+ ajustes automaticos para mais FPS e menos lag |

---

## Reparo Completo Online (Opcao 18)

Executa **7 etapas automaticamente**, sem intervencao:

```
1. Atualiza antivirus + varredura rapida
2. DISM Online (baixa arquivos da Microsoft)
3. SFC (repara arquivos do sistema)
4. Limpeza de componentes antigos
5. Busca e instala drivers via Windows Update
6. Instala atualizacoes pendentes do Windows
7. Limpeza geral do sistema
```

**Tempo estimado:** 30 a 90 minutos | Requer internet | Nao desligue o PC

---

## Remocao de IA do Windows 11 (Opcao 20)

Remove todos os recursos de inteligencia artificial do Windows 11:

| Recurso | Descricao |
|---------|-----------|
| Microsoft Copilot | Assistente de IA integrado ao sistema |
| Windows Recall | Captura de tela automatica com IA |
| IA nos Apps | Paint, Fotos, Notepad, Snipping Tool |
| Pacotes CBS/Appx | Componentes de IA do sistema |
| Chaves de Registro | Politicas e configuracoes de IA |
| Componentes Ocultos | Arquivos e tarefas agendadas de IA |
| OneDrive AI | Reconhecimento facial em imagens |
| Studio Effects | Efeitos de IA na camera e microfone |
| Busca com Bing IA | Busca com IA e sugestoes online |
| Widgets | Painel de noticias e interesses |
| Telemetria IA | Coleta de dados de IA |

**7 modos disponiveis:**

| Modo | Uso |
|------|-----|
| GUI (Recomendado) | Interface grafica do RemoveWindowsAI |
| Remocao total | RemoveWindowsAI completo automatico |
| Remocao leve | So desativa Copilot e politicas |
| Desinstalar apps | Remove Paint novo, Clipchamp, Cortana, Outlook, etc |
| Desativar extras | OneDrive AI, Studio Effects, Recall, Busca, Widgets |
| LIMPEZA TOTAL | Tudo acima de uma vez + reiniciar |
| Restaurar | Reverte alteracoes do RemoveWindowsAI |

### Apps removidos (opcao 4):

Paint (novo com IA), Clipchamp, Cortana, Copilot, Fotos (IA), Notepad (Rewrite IA), Snipping Tool (IA), Outlook novo (Copilot), Bing News, Bing Weather, Bing Search, Office Hub, Power Automate, Dev Home, Dicas, Obter Ajuda, Quick Assist, Feedback Hub, To Do, Pessoas, Solitaire.

Apos a remocao, o script oferece instalar versoes classicas (sem IA): Paint classico, Notepad classico, Visualizador de Fotos e Snipping Tool classico.

> Powered by [zoicware/RemoveWindowsAI](https://github.com/zoicware/RemoveWindowsAI) | Exclusivo para Windows 11

---

## Ativacao Windows / Office (Opcao 21)

Integra o [Microsoft Activation Scripts (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts) diretamente no menu.

| Metodo | Tipo | Uso |
|--------|------|-----|
| HWID | Permanente | Ativacao digital vinculada ao hardware |
| Ohook | Permanente | Ativacao do Office 365/2021/2024 |
| TSforge | Permanente | Metodo alternativo de ativacao |
| KMS Online | 180 dias | Renova automaticamente |
| Verificar status | Info | Mostra se Windows/Office estao ativados |
| Troubleshoot | Reparo | Soluciona problemas de ativacao |

O script tenta a URL principal e, se bloqueada pelo provedor, usa URL alternativa automaticamente. Tambem forca TLS 1.2 para compatibilidade com builds antigos.

> Powered by [massgravel/Microsoft-Activation-Scripts](https://github.com/massgravel/Microsoft-Activation-Scripts)

---

## Otimizacao para Jogos (Opcao 22)

Aplica mais de 30 ajustes automaticos para melhorar desempenho em jogos. Cria ponto de restauracao antes de comecar.

| Categoria | Ajustes |
|-----------|---------|
| Modo de Jogo e GPU | Game Mode, agendamento GPU por hardware, desativa GameDVR e otimizacao de tela cheia |
| Processador | Prioridade CPU para jogos (Win32PrioritySeparation), perfil multimedia para Games, timer preciso |
| Memoria RAM | Kernel na RAM, cache grande do sistema, desativa Superfetch em SSD |
| Rede (anti-lag) | Desativa Nagle, TcpNoDelay, TcpAckFrequency, remove limitacao de rede multimedia |
| Energia | Plano Alto Desempenho, desativa economia USB |
| Visuais | Desativa transparencia, animacoes, Aero Peek, menus instantaneos |
| Servicos | Desativa 21 servicos desnecessarios (telemetria, fax, sensores, mapas, etc) |
| Notificacoes | Desativa notificacoes em tela cheia, dicas, sugestoes, pesquisa Bing |
| Disco | Desativa Last Access Time, nomes 8.3, TRIM no SSD, limpeza de temp |
| Mouse | Desativa aceleracao (mira mais precisa em FPS) |
| DirectX | Aceleracao por hardware, otimizacao do driver de video |
| NVIDIA / AMD | Detecta GPU, desativa power throttling, economia de energia, otimiza Direct3D |
| CS2 Competitivo | Instala autoexec.cfg otimizado com rede, audio, mira, viewmodel e radar |

**NAO altera:** impressora, audio, rede essencial, seguranca, Windows Update, Windows Defender

### CS2 - Autoexec Competitivo

O script detecta automaticamente a pasta do CS2, faz backup do autoexec existente e instala um novo com:

- Rede otimizada (rate 786432, cl_interp 0, cl_interp_ratio 1)
- FPS desbloqueado (fps_max 0)
- Audio competitivo (musica desativada, passos otimizados)
- Mira estatica competitiva (crosshair style 4)
- Viewmodel que nao atrapalha a visao
- Radar otimizado
- Mouse sem aceleracao (raw input)
- Scroll down para pular
- Opcoes de lancamento recomendadas exibidas na tela

---

## Teste de Tela (Opcao 4)

Gera um arquivo HTML com **12 testes visuais** que abre no navegador:

| Teste | Finalidade |
|-------|-----------|
| Vermelho / Verde / Azul | Detectar pixels mortos |
| Branco | Verificar brilho e manchas |
| Preto (Dead Pixel) | Encontrar pontos brilhantes |
| Gradiente | Transicoes de cor |
| Xadrez | Nitidez e foco |
| Sangramento | Vazamento de cor nas bordas |
| Uniformidade (Cinza 50%) | Manchas e irregularidades |
| Angulo de Visao | Degrade preto-branco |
| Legibilidade | Texto em varios tamanhos |
| Tempo de Resposta | Mede reflexo em ms |

**Dica:** `F11` = tela cheia | `ESC` = voltar | `Setas` = navegar

---

## Requisitos

| Requisito | Detalhes |
|-----------|---------|
| Sistema | Windows 10 ou 11 |
| PowerShell | 5.1 ou superior |
| Permissao | Executar como **Administrador** |
| Internet | Necessaria para funcoes online |
| Windows 11 | Necessario para opcao 20 (Remocao de IA) |

---

## Formas de Executar

### Opcao 1 - Comando direto (recomendado)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hugoqwe1997-code/VW_Diagnostico/main/VW_Diagnostico.ps1'))
```

### Opcao 2 - Arquivo .bat (dois cliques)

Baixe o `VW_Diagnostico.bat`, de dois cliques e aceite o UAC. Ele baixa e executa do GitHub automaticamente.

### Opcao 3 - Download manual

Baixe o `VW_Diagnostico.ps1`, abra o PowerShell como Admin na pasta e execute:

```powershell
PowerShell -ExecutionPolicy Bypass -File VW_Diagnostico.ps1
```

---

## Relatorio

Ao final dos testes, salva um `.txt` no Desktop com todos os resultados, identificado com a marca VW Informatica. Pode ser entregue ao cliente como comprovante do servico.

---

## Contato

<p align="center">
  <img src="https://img.shields.io/badge/telefone-(74)%2099937--8375-25D366?style=for-the-badge&logo=whatsapp&logoColor=white" alt="Telefone"/>
  <img src="https://img.shields.io/badge/email-vw.informatica1@gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white" alt="Email"/>
  <img src="https://img.shields.io/badge/instagram-@vw.informatica-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram"/>
</p>

<p align="center">
  <b>VW Informatica</b><br/>
  Rua 13 de junho, n 73, Polivalente<br/>
  Xique-Xique/BA - CEP 47400-045
</p>

---

<p align="center">
  <sub>Feito com dedicacao para facilitar o dia a dia da assistencia tecnica</sub>
</p>
