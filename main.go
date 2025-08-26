package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
	"went-plate/commands"
)

func main() {
	// Display banner
	commands.PrintBanner()

	// Handle no arguments - default to new project creation
	if len(os.Args) < 2 {
		if err := commands.NewProject("", "", "", ""); err != nil {
			os.Exit(1)
		}
		return
	}

	// Get the command
	command := os.Args[1]

	// Handle subcommands
	switch {
	case command == "version":
		commands.VersionCommand()
		return

	case command == "help" || command == "--help" || command == "-h":
		commands.ShowHelp()
		return

	case command == "new":
		handleNewCommand()
		return

	case strings.HasPrefix(command, "make:"):
		commands.MakeCommands()
		return

	case strings.HasPrefix(command, "pkg:"):
		commands.PackageCommands()
		return

	case strings.HasPrefix(command, "-"):
		// Handle legacy flag-based usage
		handleLegacyFlags()
		return

	default:
		fmt.Printf("\033[31mBilinmeyen komut: %s\033[0m\n\n", command)
		commands.ShowHelp()
		os.Exit(2)
	}
}

// handleNewCommand handles the 'new' command with optional flags
func handleNewCommand() {
	// Create a new flag set for the new command
	newCmd := flag.NewFlagSet("new", flag.ExitOnError)

	name := newCmd.String("name", "", "Proje adı")
	newCmd.StringVar(name, "N", "", "Proje adı")

	template := newCmd.String("template", "", "Şablon (API|CLI|API+CLI|API+ReactJS|API+ReactJS+CLI)")
	newCmd.StringVar(template, "T", "", "Şablon")

	deployment := newCmd.String("deployment", "", "Dağıtım (Docker|Kubernetes|No-Deployment)")
	newCmd.StringVar(deployment, "D", "", "Dağıtım")

	router := newCmd.String("router", "", "Router (Gin|Chi)")
	newCmd.StringVar(router, "R", "", "Router")

	help := newCmd.Bool("help", false, "Yardım")
	newCmd.BoolVar(help, "h", false, "Yardım")

	// Parse flags starting from os.Args[2:]
	newCmd.Parse(os.Args[2:])

	if *help {
		commands.ShowHelp()
		return
	}

	if err := commands.NewProject(*name, *template, *deployment, *router); err != nil {
		os.Exit(1)
	}
}

// handleLegacyFlags handles the old flag-based interface for backward compatibility
func handleLegacyFlags() {
	// Validate flags
	validFlags := []string{"-N", "--name", "-T", "--template", "-D", "--deployment", "-R", "--router", "-h", "--help"}
	for _, arg := range os.Args[1:] {
		if strings.HasPrefix(arg, "-") {
			ok := false
			for _, v := range validFlags {
				if arg == v {
					ok = true
					break
				}
			}
			if !ok {
				fmt.Printf("\033[31mBilinmeyen flag: %s\033[0m\n\n", arg)
				commands.ShowHelp()
				os.Exit(2)
			}
		}
	}

	// Parse flags
	name := flag.String("name", "", "Proje adı")
	flag.StringVar(name, "N", "", "Proje adı")

	template := flag.String("template", "", "Şablon (API|CLI|API+CLI|API+ReactJS|API+ReactJS+CLI)")
	flag.StringVar(template, "T", "", "Şablon")

	deployment := flag.String("deployment", "", "Dağıtım (Docker|Kubernetes|No-Deployment)")
	flag.StringVar(deployment, "D", "", "Dağıtım")

	router := flag.String("router", "", "Router (Gin|Chi)")
	flag.StringVar(router, "R", "", "Router")

	help := flag.Bool("help", false, "Yardım")
	flag.BoolVar(help, "h", false, "Yardım")

	flag.Parse()

	if *help {
		commands.ShowHelp()
		return
	}

	if err := commands.NewProject(*name, *template, *deployment, *router); err != nil {
		os.Exit(1)
	}
}
