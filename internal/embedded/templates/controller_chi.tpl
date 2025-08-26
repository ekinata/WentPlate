package controllers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
	"{{.ProjectName}}/app/models"
)

// {{.ModelName}}Controller handles {{.ModelName}} related requests
type {{.ModelName}}Controller struct {
	DB *gorm.DB
}

// New{{.ModelName}}Controller creates a new {{.ModelName}}Controller instance
func New{{.ModelName}}Controller(db *gorm.DB) *{{.ModelName}}Controller {
	return &{{.ModelName}}Controller{DB: db}
}

// Routes sets up the routes for {{.ModelName}}Controller
func (c *{{.ModelName}}Controller) Routes() chi.Router {
	r := chi.NewRouter()
	
	r.Get("/", c.Index)
	r.Post("/", c.Store)
	r.Get("/{id}", c.Show)
	r.Put("/{id}", c.Update)
	r.Delete("/{id}", c.Delete)
	r.Delete("/{id}/soft", c.SoftDelete)
	r.Post("/{id}/restore", c.Restore)
	r.Post("/upsert", c.UpdateOrCreate)
	r.Get("/search", c.Search)
	r.Delete("/batch", c.BatchDelete)
	r.Get("/by/{field}/{value}", c.GetByField)
	
	return r
}

// Index returns all {{.ModelName}}s with pagination and search
// GET /{{.TableName}}?page=1&limit=10&search=query&order_by=created_at
func (c *{{.ModelName}}Controller) Index(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page == 0 {
		page = 1
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit == 0 {
		limit = 10
	}
	search := r.URL.Query().Get("search")
	orderBy := r.URL.Query().Get("order_by")
	if orderBy == "" {
		orderBy = "created_at DESC"
	}
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
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	totalPages := (int(total) + limit - 1) / limit
	response := map[string]interface{}{
		"data": {{.TableName}},
		"meta": map[string]interface{}{
			"current_page": page,
			"total_pages":  totalPages,
			"total_count":  total,
			"limit":        limit,
		},
	}
	c.jsonResponse(w, http.StatusOK, response)
}

// Show returns a specific {{.ModelName}}
// GET /{{.TableName}}/{id}
func (c *{{.ModelName}}Controller) Show(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.jsonError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		c.jsonError(w, status, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{"data": {{.ModelName}}})
}

// Store creates a new {{.ModelName}}
// POST /{{.TableName}}
func (c *{{.ModelName}}Controller) Store(w http.ResponseWriter, r *http.Request) {
	var {{.ModelName}} models.{{.ModelName}}

	if err := json.NewDecoder(r.Body).Decode(&{{.ModelName}}); err != nil {
		c.jsonError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := {{.ModelName}}.Create(c.DB); err != nil {
		c.jsonError(w, http.StatusUnprocessableEntity, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusCreated, map[string]interface{}{
		"data":    {{.ModelName}},
		"message": "{{.ModelName}} created successfully",
	})
}

// Update updates an existing {{.ModelName}}
// PUT /{{.TableName}}/{id}
func (c *{{.ModelName}}Controller) Update(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.jsonError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		c.jsonError(w, status, err.Error())
		return
	}

	if err := json.NewDecoder(r.Body).Decode({{.ModelName}}); err != nil {
		c.jsonError(w, http.StatusBadRequest, err.Error())
		return
	}

	if err := {{.ModelName}}.Update(c.DB); err != nil {
		c.jsonError(w, http.StatusUnprocessableEntity, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{
		"data":    {{.ModelName}},
		"message": "{{.ModelName}} updated successfully",
	})
}

// UpdateOrCreate updates an existing {{.ModelName}} or creates a new one
// POST /{{.TableName}}/upsert
func (c *{{.ModelName}}Controller) UpdateOrCreate(w http.ResponseWriter, r *http.Request) {
	var request struct {
		Conditions map[string]interface{} `json:"conditions"`
		Data       models.{{.ModelName}}  `json:"data"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		c.jsonError(w, http.StatusBadRequest, err.Error())
		return
	}

	if len(request.Conditions) == 0 {
		c.jsonError(w, http.StatusBadRequest, "Conditions required")
		return
	}

	if err := request.Data.UpdateOrCreate(c.DB, request.Conditions); err != nil {
		c.jsonError(w, http.StatusUnprocessableEntity, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{
		"data":    request.Data,
		"message": "{{.ModelName}} upserted successfully",
	})
}

// Delete removes a {{.ModelName}} (hard delete)
// DELETE /{{.TableName}}/{id}
func (c *{{.ModelName}}Controller) Delete(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.jsonError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		c.jsonError(w, status, err.Error())
		return
	}

	if err := {{.ModelName}}.Delete(c.DB); err != nil {
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{"message": "{{.ModelName}} deleted successfully"})
}

// SoftDelete performs soft delete on a {{.ModelName}}
// DELETE /{{.TableName}}/{id}/soft
func (c *{{.ModelName}}Controller) SoftDelete(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.jsonError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	{{.ModelName}}, err := models.Get{{.ModelName}}ByID(c.DB, uint(id))
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		c.jsonError(w, status, err.Error())
		return
	}

	if err := {{.ModelName}}.SoftDelete(c.DB); err != nil {
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{"message": "{{.ModelName}} soft deleted successfully"})
}

// Restore restores a soft deleted {{.ModelName}}
// POST /{{.TableName}}/{id}/restore
func (c *{{.ModelName}}Controller) Restore(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.jsonError(w, http.StatusBadRequest, "Invalid ID")
		return
	}

	{{.ModelName}} := &models.{{.ModelName}}{ID: uint(id)}
	if err := {{.ModelName}}.Restore(c.DB); err != nil {
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{"message": "{{.ModelName}} restored successfully"})
}

// Search searches for {{.ModelName}}s
// GET /{{.TableName}}/search?q=query&page=1&limit=10
func (c *{{.ModelName}}Controller) Search(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query().Get("q")
	if query == "" {
		c.jsonError(w, http.StatusBadRequest, "Search query required")
		return
	}

	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	if page == 0 {
		page = 1
	}
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	if limit == 0 {
		limit = 10
	}
	offset := (page - 1) * limit

	{{.TableName}}, total, err := models.Search{{.ModelName}}s(c.DB, query, limit, offset)
	if err != nil {
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	totalPages := (int(total) + limit - 1) / limit
	response := map[string]interface{}{
		"data": {{.TableName}},
		"meta": map[string]interface{}{
			"query":        query,
			"current_page": page,
			"total_pages":  totalPages,
			"total_count":  total,
			"limit":        limit,
		},
	}
	c.jsonResponse(w, http.StatusOK, response)
}

// BatchDelete deletes multiple {{.ModelName}}s
// DELETE /{{.TableName}}/batch
func (c *{{.ModelName}}Controller) BatchDelete(w http.ResponseWriter, r *http.Request) {
	var request struct {
		IDs  []uint `json:"ids"`
		Soft bool   `json:"soft"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		c.jsonError(w, http.StatusBadRequest, err.Error())
		return
	}

	if len(request.IDs) == 0 {
		c.jsonError(w, http.StatusBadRequest, "No IDs provided")
		return
	}

	if err := models.BatchDelete{{.ModelName}}s(c.DB, request.IDs, request.Soft); err != nil {
		c.jsonError(w, http.StatusInternalServerError, err.Error())
		return
	}

	action := "deleted"
	if request.Soft {
		action = "soft deleted"
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{
		"message": "{{.ModelName}}s " + action + " successfully",
		"count":   len(request.IDs),
	})
}

// GetByField retrieves a {{.ModelName}} by a specific field
// GET /{{.TableName}}/by/{field}/{value}
func (c *{{.ModelName}}Controller) GetByField(w http.ResponseWriter, r *http.Request) {
	field := chi.URLParam(r, "field")
	value := chi.URLParam(r, "value")

	{{.ModelName}}, err := models.Get{{.ModelName}}ByField(c.DB, field, value)
	if err != nil {
		status := http.StatusInternalServerError
		if strings.Contains(err.Error(), "record not found") {
			status = http.StatusNotFound
		}
		c.jsonError(w, status, err.Error())
		return
	}

	c.jsonResponse(w, http.StatusOK, map[string]interface{}{"data": {{.ModelName}}})
}

// Helper methods for JSON responses

func (c *{{.ModelName}}Controller) jsonResponse(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func (c *{{.ModelName}}Controller) jsonError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": message})
}
