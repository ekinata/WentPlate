package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"your-app/app/models"
)

// {{.ModelName}}Controller handles {{.ModelName}} related requests
type {{.ModelName}}Controller struct {
	DB *gorm.DB
}

// New{{.ModelName}}Controller creates a new {{.ModelName}}Controller instance
func New{{.ModelName}}Controller(db *gorm.DB) *{{.ModelName}}Controller {
	return &{{.ModelName}}Controller{DB: db}
}

// Index returns all {{.ModelName}}s with pagination and search
// GET /{{.TableName}}?page=1&limit=10&search=query&order_by=created_at
func (c *{{.ModelName}}Controller) Index(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "10"))
	search := ctx.Query("search")
	orderBy := ctx.DefaultQuery("order_by", "created_at DESC")
	offset := (page - 1) * limit

	var {{.TableName}} []models.{{.ModelName}}
	var total int64
	var err error

	if search != "" {
		{{.TableName}}, total, err = models.Search{{.ModelName}}s(c.DB, search, limit, offset)
	} else {
		{{.TableName}}, total, err = models.GetAll{{.ModelName}}s(c.DB, limit, offset, orderBy)
	}

	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	totalPages := (int(total) + limit - 1) / limit
	ctx.JSON(http.StatusOK, gin.H{
		"data": {{.TableName}},
		"meta": gin.H{
			"current_page": page,
			"total_pages":  totalPages,
			"total_count":  total,
			"limit":        limit,
		},
	})
}

// Show returns a specific {{.ModelName}}
// GET /{{.TableName}}/:id
func (c *{{.ModelName}}Controller) Show(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		ctx.JSON(status, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"data": {{.ModelName}}})
}

// Store creates a new {{.ModelName}}
// POST /{{.TableName}}
func (c *{{.ModelName}}Controller) Store(ctx *gin.Context) {
	var {{.ModelName}} models.{{.ModelName}}

	if err := ctx.ShouldBindJSON(&{{.ModelName}}); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := {{.ModelName}}.Create(c.DB); err != nil {
		ctx.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{
		"data":    {{.ModelName}},
		"message": "{{.ModelName}} created successfully",
	})
}

// Update updates an existing {{.ModelName}}
// PUT /{{.TableName}}/:id
func (c *{{.ModelName}}Controller) Update(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		ctx.JSON(status, gin.H{"error": err.Error()})
		return
	}

	if err := ctx.ShouldBindJSON({{.ModelName}}); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := {{.ModelName}}.Update(c.DB); err != nil {
		ctx.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"data":    {{.ModelName}},
		"message": "{{.ModelName}} updated successfully",
	})
}

// UpdateOrCreate updates an existing {{.ModelName}} or creates a new one
// POST /{{.TableName}}/upsert
func (c *{{.ModelName}}Controller) UpdateOrCreate(ctx *gin.Context) {
	var request struct {
		Conditions map[string]interface{} `json:"conditions"`
		Data       models.{{.ModelName}}  `json:"data"`
	}

	if err := ctx.ShouldBindJSON(&request); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if len(request.Conditions) == 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Conditions required"})
		return
	}

	if err := request.Data.UpdateOrCreate(c.DB, request.Conditions); err != nil {
		ctx.JSON(http.StatusUnprocessableEntity, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"data":    request.Data,
		"message": "{{.ModelName}} upserted successfully",
	})
}

// Delete removes a {{.ModelName}} (hard delete)
// DELETE /{{.TableName}}/:id
func (c *{{.ModelName}}Controller) Delete(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		ctx.JSON(status, gin.H{"error": err.Error()})
		return
	}

	if err := {{.ModelName}}.Delete(c.DB); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "{{.ModelName}} deleted successfully"})
}

// SoftDelete performs soft delete on a {{.ModelName}}
// DELETE /{{.TableName}}/:id/soft
func (c *{{.ModelName}}Controller) SoftDelete(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		ctx.JSON(status, gin.H{"error": err.Error()})
		return
	}

	if err := {{.ModelName}}.SoftDelete(c.DB); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "{{.ModelName}} soft deleted successfully"})
}

// Restore restores a soft deleted {{.ModelName}}
// POST /{{.TableName}}/:id/restore
func (c *{{.ModelName}}Controller) Restore(ctx *gin.Context) {
	id, err := strconv.ParseUint(ctx.Param("id"), 10, 32)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	{{.ModelName}} := &models.{{.ModelName}}{ID: uint(id)}
	if err := {{.ModelName}}.Restore(c.DB); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "{{.ModelName}} restored successfully"})
}

// Search searches for {{.ModelName}}s
// GET /{{.TableName}}/search?q=query&page=1&limit=10
func (c *{{.ModelName}}Controller) Search(ctx *gin.Context) {
	query := ctx.Query("q")
	if query == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Search query required"})
		return
	}

	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "10"))
	offset := (page - 1) * limit

	{{.TableName}}, total, err := models.Search{{.ModelName}}s(c.DB, query, limit, offset)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	totalPages := (int(total) + limit - 1) / limit
	ctx.JSON(http.StatusOK, gin.H{
		"data": {{.TableName}},
		"meta": gin.H{
			"query":        query,
			"current_page": page,
			"total_pages":  totalPages,
			"total_count":  total,
			"limit":        limit,
		},
	})
}

// BatchDelete deletes multiple {{.ModelName}}s
// DELETE /{{.TableName}}/batch
func (c *{{.ModelName}}Controller) BatchDelete(ctx *gin.Context) {
	var request struct {
		IDs  []uint `json:"ids"`
		Soft bool   `json:"soft"`
	}

	if err := ctx.ShouldBindJSON(&request); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if len(request.IDs) == 0 {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "No IDs provided"})
		return
	}

	if err := models.BatchDelete{{.ModelName}}s(c.DB, request.IDs, request.Soft); err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	action := "deleted"
	if request.Soft {
		action = "soft deleted"
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "{{.ModelName}}s " + action + " successfully",
		"count":   len(request.IDs),
	})
}

// GetByField retrieves a {{.ModelName}} by a specific field
// GET /{{.TableName}}/by/:field/:value
func (c *{{.ModelName}}Controller) GetByField(ctx *gin.Context) {
	field := ctx.Param("field")
	value := ctx.Param("value")

	{{.ModelName}}, err := models.Get{{.ModelName}}ByField(c.DB, field, value)
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		ctx.JSON(status, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"data": {{.ModelName}}})
}
