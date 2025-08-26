package commands

import (
	"fmt"
	"os/exec"
)

const Version = "v1.1.0"

// VersionCommand shows version information
func VersionCommand() {
	fmt.Println(bold + "went " + Version + reset)
}

// ShowHelp displays help information
func ShowHelp() {
	fmt.Println(dim + "Kullanım:" + reset)
	fmt.Println("  " + bold + "went" + reset + " [command] [arguments]\n")

	fmt.Println(dim + "Proje Komutları:" + reset)
	fmt.Println("  new                    Yeni proje oluştur (interaktif)")
	fmt.Println("  new --name <name>      Proje adı ile yeni proje oluştur")
	fmt.Println("      --template <type>  Şablon türü (API|CLI|API+CLI|API+ReactJS|API+ReactJS+CLI)")
	fmt.Println("      --deployment <type> Dağıtım türü (Docker|Kubernetes|No-Deployment)")
	fmt.Println("      --router <type>    Router türü (Gin|Chi) - varsayılan: Gin\n")

	fmt.Println(dim + "Template Üretimi:" + reset)
	fmt.Println("  make:model <name>      Model dosyası oluştur")
	fmt.Println("  make:controller <name> Controller dosyası oluştur (.env ROUTER değerine göre)")
	fmt.Println("  make:middleware <name> Middleware dosyası oluştur")
	fmt.Println("  make:service <name>    Service dosyası oluştur")
	fmt.Println("  make:migration <name>  Migration dosyası oluştur\n")

	fmt.Println(dim + "Paket Yönetimi:" + reset)
	fmt.Println("  pkg:install <url> <name>  Git reposundan paket indir")
	fmt.Println("  pkg:list                  Kurulu paketleri listele")
	fmt.Println("  pkg:remove <name>         Paketi kaldır")
	fmt.Println("  pkg:update <name> <dir>   Import yollarını güncelle\n")

	fmt.Println(dim + "Router Konfigürasyonu:" + reset)
	fmt.Println("  .env dosyasında ROUTER=gin veya ROUTER=chi")
	fmt.Println("  Varsayılan: gin (eğer .env yoksa veya ROUTER boşsa)")
	fmt.Println("  Controller üretimi .env ROUTER değerine göre yapılır\n")

	fmt.Println(dim + "Diğer Komutlar:" + reset)
	fmt.Println("  version                Versiyon bilgisini göster")
	fmt.Println("  help                   Bu yardım mesajını göster\n")

	fmt.Println(dim + "Örnekler:" + reset)
	fmt.Println("  went new --name my-app --template API --deployment Docker --router chi")
	fmt.Println("  echo \"ROUTER=gin\" > .env && went make:controller User")
	fmt.Println("  echo \"ROUTER=chi\" > .env && went make:controller Product")
	fmt.Println("  went pkg:install https://github.com/gin-gonic/gin gin")
	fmt.Println("  went pkg:list")
	fmt.Println()
}

// CheckGoVersion checks if Go is installed and returns version info
func CheckGoVersion() (string, error) {
	cmd := exec.Command("go", "version")
	output, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return string(output), nil
}
