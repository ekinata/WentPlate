#!/usr/bin/env bash
set -euo pipefail

### === Genel Fonksiyonlar === ###
check_and_install() {
  local pkg="$1"
  local check_cmd="$2"
  local install_cmd="$3"

  if ! command -v "$check_cmd" >/dev/null 2>&1; then
    echo "[INFO] $pkg bulunamadı. Kurulum başlatılıyor..."
    eval "$install_cmd"
  else
    echo "[OK] $pkg zaten kurulu."
  fi
}

### === Linux için === ###
install_for_linux() {
  if command -v apt-get >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "sudo apt-get update && sudo apt-get install -y golang"
  elif command -v dnf >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "sudo dnf install -y golang"
  elif command -v yum >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "sudo yum install -y golang"
  elif command -v zypper >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "sudo zypper install -y go"
  elif command -v pacman >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "sudo pacman -Sy --noconfirm go"
  else
    echo "[WARN] Linux için uygun paket yöneticisi bulunamadı."
  fi
}

### === macOS için === ###
install_for_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "[ERROR] Homebrew bulunamadı. https://brew.sh adresinden yükleyin."
    exit 1
  fi
  check_and_install "Go"  "go"  "brew install go"
}

### === Windows (Git-Bash/MSYS) için === ###
install_for_windows_layer() {
  if command -v pacman >/dev/null 2>&1; then
    check_and_install "Go"  "go"  "pacman -Sy --noconfirm mingw-w64-x86_64-go"
  else
    echo "[WARN] Windows ortamı için uygun paket yöneticisi bulunamadı."
  fi
}

### === Binary İndirme ve Test === ###
install_went() {
  local RELEASE_URL="https://github.com/ekinata/WentPlate/releases/download/latest/went"
  local INSTALL_DIR="/usr/local/bin"
  local BINARY="$INSTALL_DIR/went"

  echo "[INFO] 'went' binary indiriliyor..."
  sudo curl -L "$RELEASE_URL" -o "$BINARY"

  echo "[INFO] Çalıştırılabilir izin veriliyor..."
  sudo chmod +x "$BINARY"

  echo "[INFO] Binary test ediliyor..."
  if "$BINARY" -h >/dev/null 2>&1; then
      VERSION="$("$BINARY" version 2>/dev/null || echo 'versiyon bilgisi yok')"
      echo "[OK] Kurulum başarılı ✅"
      echo "$VERSION"
  else
      echo "[ERROR] Kurulum başarısız ❌"
      exit 1
  fi
}

### === Ortam Tespiti ve Akış === ###
KERNEL="$(uname -s)"

case "$KERNEL" in
  Linux)
    echo "[INFO] Linux ortamı tespit edildi."
    install_for_linux
    install_went
    ;;
  Darwin)
    echo "[INFO] macOS ortamı tespit edildi."
    install_for_macos
    install_went
    ;;
  CYGWIN*|MINGW*|MSYS*)
    echo "[INFO] Windows POSIX layer tespit edildi."
    install_for_windows_layer
    install_went
    ;;
  *)
    echo "[WARN] Desteklenmeyen kernel/OS: $KERNEL"
    ;;
esac
