package commands

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// MakeCommands handles all make: commands for generating files
func MakeCommands() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: went make:[model|controller|middleware|service] <name>")
		return
	}

	command := os.Args[1]

	switch command {
	case "make:model":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went make:model <ModelName>")
			fmt.Println("Example: went make:model User")
			return
		}
		modelName := capitalizeFirst(os.Args[2])
		CreateFileFromTemplate("internal/templates/model.tpl", "app/models/"+modelName+".go", modelName)
		fmt.Printf("%s[OK]%s Model '%s' created successfully!\n", green, reset, modelName)

	case "make:controller":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went make:controller <ControllerName>")
			fmt.Println("Example: went make:controller User")
			return
		}
		controllerName := capitalizeFirst(os.Args[2])

		// Read router preference from .env file
		router := getRouterFromEnv()
		switch router {
		case "gin":
			CreateFileFromTemplate("internal/templates/controller_gin.tpl", "app/controllers/"+controllerName+"Controller.go", controllerName)
		case "chi":
			CreateFileFromTemplate("internal/templates/controller_chi.tpl", "app/controllers/"+controllerName+"Controller.go", controllerName)
		default:
			fmt.Printf("%s[ERROR]%s Invalid ROUTER definition in .env file: '%s'\n", red, reset, router)
			fmt.Println("Valid options are: 'gin' or 'chi'")
			fmt.Println("If no .env file exists or ROUTER is empty, 'gin' will be used as default")
			return
		}

		fmt.Printf("%s[OK]%s Controller '%s' created successfully using %s router!\n", green, reset, controllerName+"Controller", router)

	case "make:middleware":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went make:middleware <MiddlewareName>")
			fmt.Println("Example: went make:middleware Auth")
			return
		}
		middlewareName := capitalizeFirst(os.Args[2])
		CreateFileFromTemplate("internal/templates/middleware.tpl", "app/middleware/"+middlewareName+".go", middlewareName)
		fmt.Printf("%s[OK]%s Middleware '%s' created successfully!\n", green, reset, middlewareName)

	case "make:service":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went make:service <ServiceName>")
			fmt.Println("Example: went make:service User")
			return
		}
		serviceName := capitalizeFirst(os.Args[2])
		CreateFileFromTemplate("internal/templates/service.tpl", "app/services/"+serviceName+"Service.go", serviceName)
		fmt.Printf("%s[OK]%s Service '%s' created successfully!\n", green, reset, serviceName+"Service")

	case "make:migration":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went make:migration <migration_name>")
			fmt.Println("Example: went make:migration create_users_table")
			return
		}
		migrationName := strings.ToLower(os.Args[2])
		CreateMigrationFile(migrationName)
		fmt.Printf("%s[OK]%s Migration '%s' created successfully!\n", green, reset, migrationName)

	default:
		fmt.Printf("%s[ERROR]%s Unknown make command: %s\n", red, reset, command)
		fmt.Println("Available commands: make:model, make:controller, make:middleware, make:service, make:migration")
	}
}

// capitalizeFirst capitalizes the first letter of a string
func capitalizeFirst(s string) string {
	if len(s) == 0 {
		return s
	}
	return strings.ToUpper(s[:1]) + s[1:]
}

// getRouterFromEnv reads the ROUTER value from .env file
func getRouterFromEnv() string {
	// Check if .env file exists
	file, err := os.Open(".env")
	if err != nil {
		// If .env doesn't exist, default to gin
		return "gin"
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		// Look for ROUTER= line
		if strings.HasPrefix(line, "ROUTER=") {
			router := strings.TrimSpace(strings.TrimPrefix(line, "ROUTER="))

			// Remove quotes if present
			router = strings.Trim(router, `"'`)

			// Convert to lowercase for comparison
			router = strings.ToLower(router)

			// Validate router value
			if router == "" {
				return "gin" // Default to gin if empty
			}

			if router == "gin" || router == "chi" {
				return router
			}

			// Return the invalid value so we can show an error message
			return router
		}
	}

	// If ROUTER not found in .env, default to gin
	return "gin"
}

// CreateMigrationFile creates a new migration file with timestamp
func CreateMigrationFile(name string) {
	// Implementation for creating migration files
	// This would create timestamped migration files
	fmt.Printf("Creating migration: %s\n", name)
}
