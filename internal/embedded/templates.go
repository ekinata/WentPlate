package embedded

import (
	"embed"
	"fmt"
	"io/fs"
	"strings"
)

// Embed all template files
//
//go:embed templates/*.tpl
var TemplateFS embed.FS

// GetTemplate reads a template file from the embedded filesystem
func GetTemplate(name string) ([]byte, error) {
	// Ensure the template name has the correct path and extension
	templateName := name
	if !strings.HasPrefix(templateName, "templates/") {
		templateName = "templates/" + templateName
	}
	if !strings.HasSuffix(templateName, ".tpl") {
		templateName += ".tpl"
	}

	content, err := TemplateFS.ReadFile(templateName)
	if err != nil {
		return nil, fmt.Errorf("template '%s' not found in embedded filesystem", templateName)
	}

	return content, nil
}

// ListTemplates returns a list of all available templates
func ListTemplates() ([]string, error) {
	var templates []string

	err := fs.WalkDir(TemplateFS, "templates", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(path, ".tpl") {
			// Remove the "templates/" prefix and ".tpl" suffix
			templateName := strings.TrimPrefix(path, "templates/")
			templateName = strings.TrimSuffix(templateName, ".tpl")
			templates = append(templates, templateName)
		}
		return nil
	})

	return templates, err
}

// TemplateExists checks if a template exists in the embedded filesystem
func TemplateExists(name string) bool {
	_, err := GetTemplate(name)
	return err == nil
}
