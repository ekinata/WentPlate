package commands

import (
	"fmt"
	"os"
	"strings"
	"text/template"
	"went-plate/internal/embedded"
)

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

func PrintBanner() {
	// Get Go version for banner
	goVersion, err := CheckGoVersion()
	if err != nil {
		goVersion = "Go not found"
	}

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
	fmt.Println(dim + "      A minimal project initializer · " + reset + magenta + Version + reset + "\n")
	fmt.Println(dim + "      " + reset + magenta + goVersion + reset + "\n")
}

func PrintHelp() {
	ShowHelp()
}

// createFileFromTemplate creates a file from a template
func CreateFileFromTemplate(templatePath, outputPath, modelName string) {
	// Extract template name from path (e.g., "internal/templates/model.tpl" -> "model")
	templateName := strings.TrimSuffix(strings.TrimPrefix(templatePath, "internal/templates/"), ".tpl")

	// Get template content from embedded filesystem
	templateContent, err := embedded.GetTemplate(templateName)
	if err != nil {
		fmt.Printf("%s[ERROR]%s %s\n", red, reset, err.Error())
		fmt.Printf("Make sure you're running this command from within a WentPlate project directory\n")
		fmt.Printf("or that the template files are available.\n")
		return
	}

	// Parse the template content
	tpl, err := template.New(templateName).Parse(string(templateContent))
	if err != nil {
		fmt.Printf("%s[ERROR]%s Failed to parse template %s: %v\n", red, reset, templateName, err)
		return
	}

	// Create output directory if it doesn't exist
	os.MkdirAll(GetDir(outputPath), os.ModePerm)

	// Check if file already exists
	if _, err := os.Stat(outputPath); err == nil {
		fmt.Printf("Skipped (already exists): %s\n", outputPath)
		return
	}

	// Create the output file
	f, err := os.Create(outputPath)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	// Prepare template data
	data := struct {
		ModelName string
		TableName string
	}{
		ModelName: modelName,
		TableName: strings.ToLower(modelName) + "s",
	}

	// Execute template
	err = tpl.Execute(f, data)
	if err != nil {
		panic(err)
	}

	fmt.Printf("%s[OK]%s %s '%s' created successfully!\n", green, reset, strings.Title(templateName), modelName)
}

// ListAvailableTemplates shows all available templates embedded in the binary
func ListAvailableTemplates() {
	fmt.Printf("%sAvailable Templates:%s\n", cyan, reset)
	templates, err := embedded.ListTemplates()
	if err != nil {
		fmt.Printf("%s[ERROR]%s Failed to list templates: %v\n", red, reset, err)
		return
	}

	for _, tmpl := range templates {
		fmt.Printf("  - %s%s%s\n", green, tmpl, reset)
	}
}

// getDir gets the directory part of a file path
func GetDir(path string) string {
	idx := strings.LastIndex(path, "/")
	if idx == -1 {
		return "."
	}
	return path[:idx]
}
