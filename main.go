package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/manifoldco/promptui"
)

const version = "v1.1.0"

func checkGoVersionOnSystem() ([]byte, error) {
	cmd := exec.Command("go", "version")
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	return output, nil
}

var outputBytes, _ = checkGoVersionOnSystem()
var output = string(outputBytes)

// ---- Renkler ----
const (
	reset   = "\033[0m"
	bold    = "\033[1m"
	dim     = "\033[2m"
	red     = "\033[31m"
	green   = "\033[32m"
	yellow  = "\033[33m"
	blue    = "\033[34m"
	magenta = "\033[35m"
	cyan    = "\033[36m"
	white   = "\033[37m"
)

// ---- Veri Modeli ----
type Config struct {
	ProjectName string `json:"project_name"`
	Template    string `json:"template"`   // API | CLI | W/ReactJS
	Deployment  string `json:"deployment"` // docker | kubernetes | no-deployment
}

var (
	templateOptions   = []string{"API", "CLI", "API+CLI", "API+ReactJS", "API+ReactJS+CLI"}
	deploymentOptions = []string{"Docker", "Kubernetes", "No-Deployment"}
)

// ---- Yardımcılar ----
func in[T comparable](v T, list []T) bool {
	for _, x := range list {
		if v == x {
			return true
		}
	}
	return false
}

func sanitizeName(s string) string {
	s = strings.TrimSpace(s)
	s = strings.ToLower(s)
	re := regexp.MustCompile(`[^a-z0-9_-]+`)
	s = re.ReplaceAllString(s, "-")
	s = strings.Trim(s, "-_")
	if s == "" {
		return "my-project"
	}
	return s
}

func selectFrom(label string, items []string) (string, error) {
	templates := &promptui.SelectTemplates{
		Active:   "➤ {{ . | cyan }}",
		Inactive: "  {{ . }}",
		Selected: "✔ {{ . | green }} — " + label,
		FuncMap:  promptui.FuncMap,
	}
	p := promptui.Select{
		Label:     label,
		Items:     items,
		Templates: templates,
		Size:      len(items),
	}
	_, res, err := p.Run()
	return res, err
}

func writeJSON(path string, v any) error {
	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(path, b, 0o644)
}

func printHelp() {
	fmt.Println(dim + "Kullanım:" + reset)
	fmt.Println("  " + bold + "went" + reset + " [flags] [command]\n")
	fmt.Println(dim + "Flags:" + reset)
	fmt.Println("  -N, --name         Proje adı")
	fmt.Println("  -T, --template     Şablon (API | CLI | W/ReactJS)")
	fmt.Println("  -D, --deployment   Dağıtım (docker | kubernetes | no-deployment)")
	fmt.Println("  -h, --help         Yardım\n")
	fmt.Println(dim + "Komutlar:" + reset)
	fmt.Println("  version            Versiyon bilgisini göster\n")
	fmt.Println(dim + "Örnekler:" + reset)
	fmt.Println("  went --name my-app --template api --deployment no-deployment")
	fmt.Println("  went -N my-app -T full -D docker")
	fmt.Println("  went                # eksikleri interaktif sorar")
	fmt.Println()
}

func printBanner() {
	// ASCII "WentPlate" — figlet-style
	banner := []string{
		"  (`\\ .-') /`   ('-.       .-') _  .-') _      _ (`-.              ('-.     .-') _     ('-.   ",
		"   `.( OO ),' _(  OO)     ( OO ) )(  OO) )    ( (OO  )            ( OO ).-.(  OO) )  _(  OO)  ",
		",--./  .--.  (,------.,--./ ,--,' /     '._  _.`     \\ ,--.       / . --. //     '._(,------. ",
		"|      |  |   |  .---'|   \\ |  |\\ |'--...__)(__...--'' |  |.-')   | \\-.  \\ |'--...__)|  .---' ",
		"|  |   |  |,  |  |    |    \\|  | )'--.  .--' |  /  | | |  | OO ).-'-'  |  |'--.  .--'|  |     ",
		"|  |.'.|  |_)(|  '--. |  .     |/    |  |    |  |_.' | |  |`-' | \\| |_.'  |   |  |  (|  '--.  ",
		"|         |   |  .--' |  |\\    |     |  |    |  .___.'(|  '---.'  |  .-.  |   |  |   |  .--'  ",
		"|   ,'.   |   |  `---.|  | \\   |     |  |    |  |      |      |   |  | |  |   |  |   |  `---. ",
		"'--'   '--'   `------'`--'  `--'     `--'    `--'      `------'   `--' `--'   `--'   `------' ",
	}
	// Çerçeve ve renk
	top := "┌" + strings.Repeat("─", len(banner[0])+2) + "┐"
	bot := "└" + strings.Repeat("─", len(banner[0])+2) + "┘"
	fmt.Println(cyan + top + reset)
	for _, line := range banner {
		fmt.Println(cyan + "│ " + reset + bold + white + line + reset + cyan + " │" + reset)
	}
	fmt.Println(cyan + bot + reset)
	fmt.Println(dim + "      A minimal project initializer · " + reset + magenta + version + reset + "\n")
	fmt.Println(dim + "      " + reset + magenta + output + reset + "\n")
}

func printSection(title string) {
	fmt.Println("\n" + blue + "── " + bold + title + reset + blue + " ─────────────────────────────" + reset)
}

func printKeyVal(key, val string) {
	fmt.Printf("%s%-12s%s %s\n", dim, key+":", reset, bold+val+reset)
}

func printSuccessBox(msg string) {
	border := strings.Repeat("─", len(msg)+2)
	fmt.Printf("\n%s┌%s┐%s\n", green, border, reset)
	fmt.Printf("%s│ %s │%s\n", green, msg, reset)
	fmt.Printf("%s└%s┘%s\n", green, border, reset)
}

// ---- main ----
func main() {
	// Kullanıcı deneyimini yukarı taşı: önce banner
	printBanner()
	checkGoVersionOnSystem()
	// "unknown flag" yakalama — kullanıcı dostu
	for _, arg := range os.Args[1:] {
		if strings.HasPrefix(arg, "-") {
			valid := []string{"-N", "--name", "-T", "--template", "-D", "--deployment", "-h", "--help"}
			ok := false
			for _, v := range valid {
				if arg == v {
					ok = true
					break
				}
			}
			// subcommand'lar flag değil
			if !ok && arg != "version" && arg != "help" {
				fmt.Printf(red+"Bilinmeyen flag: %s"+reset+"\n\n", arg)
				printHelp()
				os.Exit(2)
			}
		}
	}

	// Subcommand
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "version":
			fmt.Println(bold + "went " + version + reset)
			return
		case "help", "--help", "-h":
			printHelp()
			return
		}
	}

	// Flags
	name := flag.String("name", "", "Proje adı")
	flag.StringVar(name, "N", "", "Proje adı")

	template := flag.String("template", "", "Şablon (API | CLI | W/ReactJS)")
	flag.StringVar(template, "T", "", "Şablon (API | CLI | W/ReactJS)")

	deployment := flag.String("deployment", "", "Dağıtım (API | Kubernetes | No-Deployment)")
	flag.StringVar(deployment, "D", "", "Dağıtım (API | Kubernetes | No-Deployment)")

	help := flag.Bool("help", false, "Yardım")
	flag.BoolVar(help, "h", false, "Yardım")

	flag.Parse()

	if *help {
		printHelp()
		return
	}

	cfg := Config{}

	// Normalize
	if *name != "" {
		cfg.ProjectName = sanitizeName(*name)
	}
	if *template != "" {
		cfg.Template = strings.ToLower(*template)
	}
	if *deployment != "" {
		d := strings.ToLower(*deployment)
		if d == "nodeployment" {
			d = "no-deployment"
		}
		cfg.Deployment = d
	}

	// Eksikleri interaktif doldur
	if cfg.ProjectName == "" {
		p := promptui.Prompt{Label: "Proje adı", Default: "my-project", AllowEdit: true}
		res, err := p.Run()
		if err != nil {
			fmt.Println(red + "İptal edildi." + reset)
			return
		}
		cfg.ProjectName = sanitizeName(res)
	}
	if !in(cfg.Template, templateOptions) {
		choice, err := selectFrom("Şablon (API / CLI / W/ReactJS)", templateOptions)
		if err != nil {
			fmt.Println(red + "İptal edildi." + reset)
			return
		}
		cfg.Template = choice
	}
	if !in(cfg.Deployment, deploymentOptions) {
		choice, err := selectFrom("Dağıtım (docker/kubernetes/no-deployment)", deploymentOptions)
		if err != nil {
			fmt.Println(red + "İptal edildi." + reset)
			return
		}
		cfg.Deployment = choice
	}

	// Özet
	printSection("Seçimler")
	printKeyVal("Project", cfg.ProjectName)
	printKeyVal("Template", cfg.Template)
	printKeyVal("Deployment", cfg.Deployment)

	// JSON yaz
	out := "wentconfig.json"
	if err := writeJSON(out, cfg); err != nil {
		fmt.Printf("\n"+red+"Hata:"+reset+" JSON yazılamadı: %v\n", err)
		return
	}
	abs, _ := filepath.Abs(out)
	printSuccessBox("Kaydedildi: " + abs)
	fmt.Println()
}
