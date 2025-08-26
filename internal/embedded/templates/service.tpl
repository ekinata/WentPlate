package services

import (
	"errors"
	"{{.ProjectName}}/app/models"
)

// {{.ModelName}}Service handles business logic for {{.ModelName}}
type {{.ModelName}}Service struct {
	// Add dependencies like database, cache, etc.
	// db *gorm.DB
}

// New{{.ModelName}}Service creates a new {{.ModelName}}Service instance
func New{{.ModelName}}Service() *{{.ModelName}}Service {
	return &{{.ModelName}}Service{
		// Initialize dependencies
	}
}

// GetAll{{.ModelName}}s retrieves all {{.ModelName}}s
func (s *{{.ModelName}}Service) GetAll{{.ModelName}}s() ([]models.{{.ModelName}}, error) {
	var {{.TableName}} []models.{{.ModelName}}
	
	// TODO: Implement business logic
	// Example: Apply filters, sorting, pagination
	// if err := s.db.Find(&{{.TableName}}).Error; err != nil {
	//     return nil, err
	// }
	
	return {{.TableName}}, nil
}

// Get{{.ModelName}}ByID retrieves a {{.ModelName}} by ID
func (s *{{.ModelName}}Service) Get{{.ModelName}}ByID(id uint) (*models.{{.ModelName}}, error) {
	var {{.ModelName}} models.{{.ModelName}}
	
	// TODO: Implement business logic
	// if err := s.db.First(&{{.ModelName}}, id).Error; err != nil {
	//     if errors.Is(err, gorm.ErrRecordNotFound) {
	//         return nil, errors.New("{{.ModelName}} not found")
	//     }
	//     return nil, err
	// }
	
	return &{{.ModelName}}, nil
}

// Create{{.ModelName}} creates a new {{.ModelName}}
func (s *{{.ModelName}}Service) Create{{.ModelName}}({{.ModelName}} *models.{{.ModelName}}) error {
	// TODO: Implement validation and business logic
	if {{.ModelName}}.Name == "" {
		return errors.New("name is required")
	}
	
	// TODO: Save to database
	// if err := s.db.Create({{.ModelName}}).Error; err != nil {
	//     return err
	// }
	
	return nil
}

// Update{{.ModelName}} updates an existing {{.ModelName}}
func (s *{{.ModelName}}Service) Update{{.ModelName}}(id uint, updates *models.{{.ModelName}}) error {
	// TODO: Implement validation and business logic
	existing, err := s.Get{{.ModelName}}ByID(id)
	if err != nil {
		return err
	}
	
	// Apply updates
	if updates.Name != "" {
		existing.Name = updates.Name
	}
	if updates.Description != "" {
		existing.Description = updates.Description
	}
	
	// TODO: Save to database
	// if err := s.db.Save(existing).Error; err != nil {
	//     return err
	// }
	
	return nil
}

// Delete{{.ModelName}} deletes a {{.ModelName}}
func (s *{{.ModelName}}Service) Delete{{.ModelName}}(id uint) error {
	// TODO: Implement business logic and validation
	// Check if {{.ModelName}} exists
	_, err := s.Get{{.ModelName}}ByID(id)
	if err != nil {
		return err
	}
	
	// TODO: Delete from database
	// if err := s.db.Delete(&models.{{.ModelName}}{}, id).Error; err != nil {
	//     return err
	// }
	
	return nil
}

// Validate{{.ModelName}} validates {{.ModelName}} data
func (s *{{.ModelName}}Service) Validate{{.ModelName}}({{.ModelName}} *models.{{.ModelName}}) error {
	if {{.ModelName}}.Name == "" {
		return errors.New("name is required")
	}
	
	// Add more validation rules as needed
	
	return nil
}
