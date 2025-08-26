package models

import (
	"time"
	"gorm.io/gorm"
	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

// {{.ModelName}} represents the {{.ModelName}} model
type {{.ModelName}} struct {
	ID          uint           `json:"id" gorm:"primaryKey,autoIncrement"`
	Name        string         `json:"name" gorm:"column:name" validate:"required"`
	Description string         `json:"description" gorm:"column:description"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"deleted_at,omitempty" gorm:"index"`
}

// TableName returns the table name for {{.ModelName}}
func ({{.ModelName}}) TableName() string {
	return "{{.TableName}}"
}

// Validate validates {{.ModelName}} data
func (m *{{.ModelName}}) Validate() error {
	return validate.Struct(m)
}

// BeforeCreate hook
func (m *{{.ModelName}}) BeforeCreate(tx *gorm.DB) error {
	return m.Validate()
}

// BeforeUpdate hook  
func (m *{{.ModelName}}) BeforeUpdate(tx *gorm.DB) error {
	return m.Validate()
}

// Create creates a new {{.ModelName}}
func (m *{{.ModelName}}) Create(db *gorm.DB) error {
	return db.Create(m).Error
}

// GetAll{{.ModelName}}s retrieves all {{.ModelName}}s with pagination
func GetAll{{.ModelName}}s(db *gorm.DB, limit, offset int, orderBy string) ([]{{.ModelName}}, int64, error) {
	var {{.TableName}} []{{.ModelName}}
	var count int64

	if orderBy == "" {
		orderBy = "created_at DESC"
	}

	query := db.Model(&{{.ModelName}}{})
	query.Count(&count)

	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}

	err := query.Order(orderBy).Find(&{{.TableName}}).Error
	return {{.TableName}}, count, err
}

// Get{{.ModelName}}ByID retrieves a {{.ModelName}} by ID
func Get{{.ModelName}}ByID(db *gorm.DB, id uint) (*{{.ModelName}}, error) {
	var {{.ModelName}} {{.ModelName}}
	err := db.First(&{{.ModelName}}, id).Error
	return &{{.ModelName}}, err
}

// Get{{.ModelName}}ByField retrieves a {{.ModelName}} by any field
func Get{{.ModelName}}ByField(db *gorm.DB, field string, value interface{}) (*{{.ModelName}}, error) {
	var {{.ModelName}} {{.ModelName}}
	err := db.Where(field+" = ?", value).First(&{{.ModelName}}).Error
	return &{{.ModelName}}, err
}

// Update updates the {{.ModelName}}
func (m *{{.ModelName}}) Update(db *gorm.DB) error {
	return db.Save(m).Error
}

// UpdateFields updates specific fields of the {{.ModelName}}
func (m *{{.ModelName}}) UpdateFields(db *gorm.DB, fields map[string]interface{}) error {
	return db.Model(m).Updates(fields).Error
}

// UpdateOrCreate updates an existing {{.ModelName}} or creates a new one
func (m *{{.ModelName}}) UpdateOrCreate(db *gorm.DB, conditions map[string]interface{}) error {
	query := db
	for field, value := range conditions {
		query = query.Where(field+" = ?", value)
	}
	return query.Assign(m).FirstOrCreate(m).Error
}

// Delete performs hard delete
func (m *{{.ModelName}}) Delete(db *gorm.DB) error {
	return db.Unscoped().Delete(m).Error
}

// SoftDelete performs soft delete
func (m *{{.ModelName}}) SoftDelete(db *gorm.DB) error {
	return db.Delete(m).Error
}

// Restore restores a soft deleted {{.ModelName}}
func (m *{{.ModelName}}) Restore(db *gorm.DB) error {
	return db.Unscoped().Model(m).Update("deleted_at", nil).Error
}

// Search{{.ModelName}}s searches {{.ModelName}}s by name or description
func Search{{.ModelName}}s(db *gorm.DB, query string, limit, offset int) ([]{{.ModelName}}, int64, error) {
	var {{.TableName}} []{{.ModelName}}
	var count int64

	searchQuery := db.Model(&{{.ModelName}}{}).Where("name ILIKE ? OR description ILIKE ?", "%"+query+"%", "%"+query+"%")
	searchQuery.Count(&count)

	if limit > 0 {
		searchQuery = searchQuery.Limit(limit)
	}
	if offset > 0 {
		searchQuery = searchQuery.Offset(offset)
	}

	err := searchQuery.Order("created_at DESC").Find(&{{.TableName}}).Error
	return {{.TableName}}, count, err
}

// BatchDelete deletes multiple {{.ModelName}}s
func BatchDelete{{.ModelName}}s(db *gorm.DB, ids []uint, soft bool) error {
	if soft {
		return db.Delete(&{{.ModelName}}{}, ids).Error
	}
	return db.Unscoped().Delete(&{{.ModelName}}{}, ids).Error
}

// ToMap converts {{.ModelName}} to map for JSON serialization
func (m *{{.ModelName}}) ToMap() map[string]interface{} {
	return map[string]interface{}{
		"id":          m.ID,
		"name":        m.Name,
		"description": m.Description,
		"created_at":  m.CreatedAt,
		"updated_at":  m.UpdatedAt,
		"deleted_at":  m.DeletedAt,
	}
}
