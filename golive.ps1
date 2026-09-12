$ErrorActionPreference = "Stop"

function Show-Logo {

    Write-Host @'
      ++*             
     +++       %*#%   
   =++==+     %+#% %% 
   ======    %#++***% 
   ======= %#***#%%%  
    =====+#*#*#%      
     ==+#*#*#+=       
     %#*#*#+=======   
  %##*++#*=========== 
 %#% %*%   ========*# 
  %*##%               
'@ -ForegroundColor Yellow

    Write-Host ""
    Write-Host "PEDRO COMPUTING" -ForegroundColor White
    Write-Host ""
}

# ============================================
# GoLiveBypass - Pedro Computing
# ============================================

$Version = "2.0.5"
$FileName = "GoLiveBypass-$Version.exe"

$DownloadUrl = "https://github.com/bezumiya/GoLiveBypass/releases/download/v$Version/$FileName"

$ExpectedHash = "d7160df223f8d508e2bf30cc606dded44bb155c5678dc69a8be74bc391bc3ff1"

$InstallDir = Join-Path $env:LOCALAPPDATA "PedroComputing\GoLiveBypass"
$ExePath = Join-Path $InstallDir "GoLiveBypass.exe"
$TempPath = Join-Path $env:TEMP $FileName


# ============================================
# INICIO
# ============================================

Clear-Host
Show-Logo

Write-Host "GoLiveBypass v$Version" -ForegroundColor Cyan
Write-Host ""
Write-Host "Preparando instalacao..." -ForegroundColor Gray
Write-Host ""


# TLS para Windows PowerShell antigo
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# ============================================
# CRIAR PASTA
# ============================================

if (!(Test-Path $InstallDir)) {

    Write-Host "[+] Criando pasta..." -ForegroundColor Green

    New-Item `
        -ItemType Directory `
        -Path $InstallDir `
        -Force | Out-Null
}


# ============================================
# VERIFICAR INSTALACAO
# ============================================

$AlreadyInstalled = $false

if (Test-Path $ExePath) {

    Write-Host "[*] GoLiveBypass encontrado." -ForegroundColor Cyan

    try {

        $CurrentHash = (
            Get-FileHash `
                $ExePath `
                -Algorithm SHA256
        ).Hash.ToLower()

        if ($CurrentHash -eq $ExpectedHash.ToLower()) {

            Write-Host "[+] GoLiveBypass v$Version ja esta instalado." -ForegroundColor Green

            $AlreadyInstalled = $true
        }
        else {

            Write-Host "[*] Versao diferente detectada." -ForegroundColor Yellow
            Write-Host "[*] Atualizando GoLiveBypass..." -ForegroundColor Yellow
        }
    }
    catch {

        Write-Host "[!] Nao foi possivel verificar a versao instalada." -ForegroundColor Yellow
        Write-Host "[*] Reinstalando..." -ForegroundColor Yellow
    }

    Write-Host ""
}


# ============================================
# DOWNLOAD
# ============================================

if (!$AlreadyInstalled) {

    Write-Host "[+] Baixando GoLiveBypass v$Version..." -ForegroundColor Green

    Write-Host ""
    Write-Host $DownloadUrl -ForegroundColor DarkGray
    Write-Host ""

    if (Test-Path $TempPath) {

        Remove-Item `
            $TempPath `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Invoke-WebRequest `
        -Uri $DownloadUrl `
        -OutFile $TempPath `
        -UseBasicParsing


    if (!(Test-Path $TempPath)) {

        throw "O download falhou."
    }


    Write-Host "[+] Download concluido." -ForegroundColor Green
    Write-Host "[*] Verificando SHA-256..." -ForegroundColor Cyan


    # ============================================
    # HASH
    # ============================================

    $DownloadedHash = (
        Get-FileHash `
            $TempPath `
            -Algorithm SHA256
    ).Hash.ToLower()


    if ($DownloadedHash -ne $ExpectedHash.ToLower()) {

        Remove-Item `
            $TempPath `
            -Force `
            -ErrorAction SilentlyContinue

        Write-Host ""
        Write-Host "[ERRO] SHA-256 invalido!" -ForegroundColor Red
        Write-Host ""

        Write-Host "Esperado:" -ForegroundColor Gray
        Write-Host $ExpectedHash -ForegroundColor Yellow

        Write-Host ""

        Write-Host "Recebido:" -ForegroundColor Gray
        Write-Host $DownloadedHash -ForegroundColor Red

        Write-Host ""

        throw "O arquivo baixado nao passou na verificacao de integridade."
    }


    Write-Host "[+] SHA-256 confirmado." -ForegroundColor Green
    Write-Host ""


    # ============================================
    # FECHAR VERSAO ANTIGA
    # ============================================

    $Processes = Get-Process -ErrorAction SilentlyContinue |
        Where-Object {

            try {

                $_.Path -eq $ExePath
            }
            catch {

                $false
            }
        }


    if ($Processes) {

        Write-Host "[*] Fechando GoLiveBypass antigo..." -ForegroundColor Yellow

        $Processes |
            Stop-Process `
                -Force `
                -ErrorAction SilentlyContinue

        Start-Sleep -Seconds 1
    }


    # ============================================
    # INSTALAR
    # ============================================

    Copy-Item `
        $TempPath `
        $ExePath `
        -Force


    Remove-Item `
        $TempPath `
        -Force `
        -ErrorAction SilentlyContinue


    Write-Host "[+] GoLiveBypass instalado com sucesso." -ForegroundColor Green

    Write-Host ""
    Write-Host "Local:" -ForegroundColor Gray
    Write-Host $ExePath -ForegroundColor Cyan
    Write-Host ""
}


# ============================================
# EXECUTAR
# ============================================

Write-Host "[+] Abrindo GoLiveBypass..." -ForegroundColor Green
Write-Host ""

Start-Process $ExePath


# ============================================
# FIM
# ============================================

Start-Sleep -Seconds 1

Write-Host ""
Write-Host "============================================" -ForegroundColor DarkGray
Write-Host " GoLiveBypass iniciado com sucesso" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor DarkGray
Write-Host ""

Show-Logo