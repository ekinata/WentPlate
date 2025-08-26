# PowerShell Install Script for Went
# Requires PowerShell 5.1 or later

# Error handling
$ErrorActionPreference = "Stop"

### === Genel Fonksiyonlar === ###
function Check-AndInstall {
    param(
        [string]$PackageName,
        [string]$CheckCommand,
        [scriptblock]$InstallAction
    )
    
    try {
        if (Get-Command $CheckCommand -ErrorAction SilentlyContinue) {
            Write-Host "[OK] $PackageName zaten kurulu." -ForegroundColor Green
        } else {
            Write-Host "[INFO] $PackageName bulunamadı. Kurulum başlatılıyor..." -ForegroundColor Yellow
            & $InstallAction
        }
    } catch {
        Write-Host "[WARN] $PackageName kurulumu sırasında hata oluştu: $_" -ForegroundColor Red
    }
}

### === Windows için === ###
function Install-ForWindows {
    # Check if running as Administrator
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "[ERROR] Bu script Administrator olarak çalıştırılmalıdır." -ForegroundColor Red
        Write-Host "PowerShell'i 'Run as Administrator' ile açın ve tekrar deneyin." -ForegroundColor Red
        exit 1
    }

    # Check for package managers and install Go
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Check-AndInstall "Go" "go" { choco install golang -y }
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        Check-AndInstall "Go" "go" { winget install GoLang.Go }
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        Check-AndInstall "Go" "go" { scoop install go }
    } else {
        Write-Host "[WARN] Desteklenen paket yöneticisi bulunamadı (Chocolatey, Winget, Scoop)." -ForegroundColor Red
        Write-Host "Go'yu manuel olarak https://golang.org/dl/ adresinden yükleyebilirsiniz." -ForegroundColor Yellow
    }
}

### === Binary İndirme ve Test === ###
function Install-Went {
    $RELEASE_URL = "https://github.com/ekinata/WentPlate/releases/download/test/went.exe"
    $INSTALL_DIR = "$env:ProgramFiles\went"
    $BINARY = "$INSTALL_DIR\went.exe"

    # Create install directory if it doesn't exist
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }

    Write-Host "[INFO] 'went' binary indiriliyor..." -ForegroundColor Blue
    try {
        # Download the binary
        Invoke-WebRequest -Uri $RELEASE_URL -OutFile $BINARY -UseBasicParsing
        Write-Host "[OK] Binary başarıyla indirildi." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Binary indirilemedi: $_" -ForegroundColor Red
        exit 1
    }

    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$INSTALL_DIR*") {
        Write-Host "[INFO] PATH'e ekleniyor..." -ForegroundColor Blue
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$INSTALL_DIR", "Machine")
        $env:PATH += ";$INSTALL_DIR"
    }

    Write-Host "[INFO] Binary test ediliyor..." -ForegroundColor Blue
    try {
        # Test the binary
        $output = & $BINARY -h 2>&1
        if ($LASTEXITCODE -eq 0) {
            try {
                $version = & $BINARY version 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $version = "versiyon bilgisi yok"
                }
            } catch {
                $version = "versiyon bilgisi yok"
            }
            Write-Host "[OK] Kurulum başarılı ✅" -ForegroundColor Green
            Write-Host "$version" -ForegroundColor Cyan
        } else {
            Write-Host "[ERROR] Kurulum başarısız ❌" -ForegroundColor Red
            Write-Host "Binary çalıştırılamadı: $output" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "[ERROR] Binary test edilemedi: $_" -ForegroundColor Red
        exit 1
    }
}

### === Ana Akış === ###
Write-Host "=== Went Installation Script ===" -ForegroundColor Magenta
Write-Host "[INFO] Windows ortamı tespit edildi." -ForegroundColor Blue

# Install dependencies
Install-ForWindows

# Install went binary
Install-Went

Write-Host ""
Write-Host "Kurulum tamamlandı! Yeni bir PowerShell oturumu açarak 'went' komutunu kullanabilirsiniz." -ForegroundColor Green
Write-Host "Veya mevcut oturumda çalıştırmak için: refreshenv (Chocolatey) veya PowerShell'i yeniden başlatın." -ForegroundColor Yellow
