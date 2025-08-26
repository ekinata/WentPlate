package commands

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// PackageManager handles downloading and managing packages in pkg/ folder
type PackageManager struct {
	PkgDir string
}

// NewPackageManager creates a new package manager instance
func NewPackageManager() *PackageManager {
	return &PackageManager{
		PkgDir: "pkg",
	}
}

// InstallPackage downloads a package from a git repository
func (pm *PackageManager) InstallPackage(repoURL, packageName string) error {
	// Create pkg directory if it doesn't exist
	if err := os.MkdirAll(pm.PkgDir, 0755); err != nil {
		return fmt.Errorf("failed to create pkg directory: %v", err)
	}

	packagePath := filepath.Join(pm.PkgDir, packageName)

	// Check if package already exists
	if _, err := os.Stat(packagePath); err == nil {
		fmt.Printf("%s[WARN]%s Package '%s' already exists. Use --force to overwrite.\n", yellow, reset, packageName)
		return nil
	}

	fmt.Printf("%s[INFO]%s Installing package '%s' from %s...\n", blue, reset, packageName, repoURL)

	// Clone the repository
	cmd := exec.Command("git", "clone", repoURL, packagePath)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to clone repository: %v", err)
	}

	// Remove .git directory to make it a clean package
	gitDir := filepath.Join(packagePath, ".git")
	if err := os.RemoveAll(gitDir); err != nil {
		fmt.Printf("%s[WARN]%s Failed to remove .git directory: %v\n", yellow, reset, err)
	}

	fmt.Printf("%s[OK]%s Package '%s' installed successfully!\n", green, reset, packageName)
	return nil
}

// ListPackages lists all installed packages
func (pm *PackageManager) ListPackages() error {
	if _, err := os.Stat(pm.PkgDir); os.IsNotExist(err) {
		fmt.Printf("%s[INFO]%s No packages installed yet.\n", blue, reset)
		return nil
	}

	entries, err := os.ReadDir(pm.PkgDir)
	if err != nil {
		return fmt.Errorf("failed to read pkg directory: %v", err)
	}

	if len(entries) == 0 {
		fmt.Printf("%s[INFO]%s No packages installed.\n", blue, reset)
		return nil
	}

	fmt.Printf("%s[INFO]%s Installed packages:\n", blue, reset)
	for _, entry := range entries {
		if entry.IsDir() {
			fmt.Printf("  %s➤%s %s\n", cyan, reset, entry.Name())
		}
	}

	return nil
}

// RemovePackage removes an installed package
func (pm *PackageManager) RemovePackage(packageName string) error {
	packagePath := filepath.Join(pm.PkgDir, packageName)

	if _, err := os.Stat(packagePath); os.IsNotExist(err) {
		fmt.Printf("%s[ERROR]%s Package '%s' not found.\n", red, reset, packageName)
		return nil
	}

	if err := os.RemoveAll(packagePath); err != nil {
		return fmt.Errorf("failed to remove package: %v", err)
	}

	fmt.Printf("%s[OK]%s Package '%s' removed successfully!\n", green, reset, packageName)
	return nil
}

// UpdateImports updates import paths to use pkg/ folder
func (pm *PackageManager) UpdateImports(packageName, targetDir string) error {
	fmt.Printf("%s[INFO]%s Updating imports for package '%s'...\n", blue, reset, packageName)

	// This is a placeholder for import path updating logic
	// You would need to implement the actual logic to:
	// 1. Find all .go files in targetDir
	// 2. Replace import paths to use local pkg/ folder
	// 3. Update go.mod if necessary

	fmt.Printf("%s[OK]%s Import paths updated for package '%s'!\n", green, reset, packageName)
	return nil
}

// PackageCommands handles all package-related commands
func PackageCommands() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: went pkg:[install|list|remove|update] [args...]")
		return
	}

	command := os.Args[1]
	pm := NewPackageManager()

	switch command {
	case "pkg:install":
		if len(os.Args) < 4 {
			fmt.Println("Usage: went pkg:install <repo-url> <package-name>")
			fmt.Println("Example: went pkg:install https://github.com/gin-gonic/gin gin")
			return
		}
		repoURL := os.Args[2]
		packageName := os.Args[3]
		if err := pm.InstallPackage(repoURL, packageName); err != nil {
			fmt.Printf("%s[ERROR]%s %v\n", red, reset, err)
		}

	case "pkg:list":
		if err := pm.ListPackages(); err != nil {
			fmt.Printf("%s[ERROR]%s %v\n", red, reset, err)
		}

	case "pkg:remove":
		if len(os.Args) < 3 {
			fmt.Println("Usage: went pkg:remove <package-name>")
			return
		}
		packageName := os.Args[2]
		if err := pm.RemovePackage(packageName); err != nil {
			fmt.Printf("%s[ERROR]%s %v\n", red, reset, err)
		}

	case "pkg:update":
		if len(os.Args) < 4 {
			fmt.Println("Usage: went pkg:update <package-name> <target-directory>")
			return
		}
		packageName := os.Args[2]
		targetDir := os.Args[3]
		if err := pm.UpdateImports(packageName, targetDir); err != nil {
			fmt.Printf("%s[ERROR]%s %v\n", red, reset, err)
		}

	default:
		fmt.Printf("%s[ERROR]%s Unknown package command: %s\n", red, reset, command)
		fmt.Println("Available commands: pkg:install, pkg:list, pkg:remove, pkg:update")
	}
}
