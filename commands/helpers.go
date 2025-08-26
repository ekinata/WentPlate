package commands

import (
	"encoding/json"
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

// readProjectConfig reads the project configuration from wentconfig.json
func readProjectConfig() (*Config, error) {
	configFile := "wentconfig.json"
	
	// Check if config file exists
	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		return nil, fmt.Errorf("wentconfig.json not found - make sure you're in a WentPlate project directory")
	}
	
	// Read the config file
	data, err := os.ReadFile(configFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read wentconfig.json: %v", err)
	}
	
	// Parse JSON
	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse wentconfig.json: %v", err)
	}
	
	return &config, nil
}

// createFileFromTemplate creates a file from a template
func CreateFileFromTemplate(templatePath, outputPath, modelName string) {
	// Extract template name from path (e.g., "internal/templates/model.tpl" -> "model")
	templateName := strings.TrimSuffix(strings.TrimPrefix(templatePath, "internal/templates/"), ".tpl")

	// Read project configuration to get project name
	config, err := readProjectConfig()
	if err != nil {
		fmt.Printf("%s[WARNING]%s %s\n", yellow, reset, err.Error())
		fmt.Printf("Using default app name 'your-app' for imports\n")
		// Create a default config
		config = &Config{
			ProjectName: "your-app",
			Template:    "API",
			Deployment:  "No-Deployment",
			Router:      "gin",
		}
	}

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

	// Prepare template data with project information
	data := struct {
		ModelName   string
		TableName   string
		ProjectName string
		AppName     string
	}{
		ModelName:   modelName,
		TableName:   strings.ToLower(modelName) + "s",
		ProjectName: config.ProjectName,
		AppName:     config.ProjectName, // For backward compatibility
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
