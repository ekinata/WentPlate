# Generated CRUD Methods Documentation

This document explains all the CRUD methods that are automatically generated when you create models and controllers using WentPlate.

## Model Methods

When you run `went make:model User`, the following methods are automatically generated:

### Basic CRUD Operations

#### `GetAll{ModelName}s(db *gorm.DB, limit, offset int, orderBy string) ([]ModelName, int64, error)`
- Retrieves all records with pagination and ordering
- Returns slice of models, total count, and error
- Supports custom ordering (default: "created_at DESC")

#### `Get{ModelName}ByID(db *gorm.DB, id uint) (*ModelName, error)`
- Retrieves a single record by ID
- Returns pointer to model or error if not found

#### `Get{ModelName}ByField(db *gorm.DB, field string, value interface{}) (*ModelName, error)`
- Retrieves a record by any field
- Useful for finding by email, username, etc.

#### `Create{ModelName}(db *gorm.DB, model *ModelName) error`
- Creates a new record
- Includes validation before saving

#### `Update{ModelName}(db *gorm.DB, id uint, updates *ModelName) (*ModelName, error)`
- Updates an existing record by ID
- Only updates non-empty fields
- Includes validation

### Advanced Operations

#### `UpdateOrCreate{ModelName}(db *gorm.DB, conditions map[string]interface{}, model *ModelName) (*ModelName, bool, error)`
- Updates existing record or creates new one based on conditions
- Returns the model, whether it was created (bool), and error
- Useful for idempotent operations

#### `Delete{ModelName}(db *gorm.DB, id uint) error`
- Performs hard delete (permanently removes record)
- Checks if record exists before deletion

#### `ParanoidDelete{ModelName}(db *gorm.DB, id uint) error`
- Performs soft delete (sets deleted_at timestamp)
- Record remains in database but is excluded from queries

#### `Restore{ModelName}(db *gorm.DB, id uint) error`
- Restores a soft-deleted record
- Sets deleted_at to NULL

#### `Search{ModelName}s(db *gorm.DB, query string, limit, offset int) ([]ModelName, int64, error)`
- Full-text search on name and description fields
- Supports pagination
- Uses ILIKE for case-insensitive search

### Utility Methods

#### `Validate() error`
- Validates model data before save
- Can be customized for each model

#### `ToMap() map[string]interface{}`
- Converts model to map for JSON serialization
- Useful for custom responses

## Controller Methods

When you run `went make:controller User`, the following HTTP endpoints are automatically generated:

### RESTful API Endpoints

#### `GET /{models}` - Index
```go
func (c *UserController) Index(ctx *gin.Context)
```
- **Query Parameters:**
  - `page` (int): Page number (default: 1)
  - `limit` (int): Records per page (default: 10)
  - `search` (string): Search query
  - `order_by` (string): Ordering field (default: "created_at DESC")
- **Response:** Paginated list with metadata

#### `GET /{models}/:id` - Show
```go
func (c *UserController) Show(ctx *gin.Context)
```
- **Parameters:** `id` (uint): Record ID
- **Response:** Single record or 404 error

#### `POST /{models}` - Store
```go
func (c *UserController) Store(ctx *gin.Context)
```
- **Body:** JSON object with model fields
- **Response:** Created record with 201 status

#### `PUT /{models}/:id` - Update
```go
func (c *UserController) Update(ctx *gin.Context)
```
- **Parameters:** `id` (uint): Record ID
- **Body:** JSON object with fields to update
- **Response:** Updated record

#### `DELETE /{models}/:id` - Delete
```go
func (c *UserController) Delete(ctx *gin.Context)
```
- **Parameters:** `id` (uint): Record ID
- **Response:** Success message
- **Note:** Performs hard delete

### Advanced Endpoints

#### `POST /{models}/upsert` - UpdateOrCreate
```go
func (c *UserController) UpdateOrCreate(ctx *gin.Context)
```
- **Body:**
  ```json
  {
    "conditions": {"email": "user@example.com"},
    "data": {"name": "John Doe", "email": "user@example.com"}
  }
  ```
- **Response:** Record with `created` boolean flag

#### `DELETE /{models}/:id/soft` - SoftDelete
```go
func (c *UserController) SoftDelete(ctx *gin.Context)
```
- **Parameters:** `id` (uint): Record ID
- **Response:** Success message
- **Note:** Performs soft delete (sets deleted_at)

#### `POST /{models}/:id/restore` - Restore
```go
func (c *UserController) Restore(ctx *gin.Context)
```
- **Parameters:** `id` (uint): Record ID of soft-deleted record
- **Response:** Success message

#### `GET /{models}/search` - Search
```go
func (c *UserController) Search(ctx *gin.Context)
```
- **Query Parameters:**
  - `q` (string): Search query (required)
  - `page` (int): Page number
  - `limit` (int): Records per page
- **Response:** Paginated search results

#### `DELETE /{models}/batch` - BatchDelete
```go
func (c *UserController) BatchDelete(ctx *gin.Context)
```
- **Body:**
  ```json
  {
    "ids": [1, 2, 3],
    "soft": true
  }
  ```
- **Response:** Delete summary with error details

#### `GET /{models}/by/:field/:value` - GetByField
```go
func (c *UserController) GetByField(ctx *gin.Context)
```
- **Parameters:** 
  - `field` (string): Field name
  - `value` (string): Field value
- **Example:** `GET /users/by/email/john@example.com`
- **Response:** Single record or 404 error

## Usage Examples

### Model Usage

```go
package main

import (
    "your-app/app/models"
    "gorm.io/gorm"
)

func example(db *gorm.DB) {
    // Create a new user
    user := &models.User{
        Name: "John Doe",
        Description: "Software Engineer",
    }
    err := models.CreateUser(db, user)
    
    // Get all users with pagination
    users, total, err := models.GetAllUsers(db, 10, 0, "name ASC")
    
    // Search users
    results, count, err := models.SearchUsers(db, "john", 10, 0)
    
    // Update or create
    conditions := map[string]interface{}{"email": "john@example.com"}
    user, created, err := models.UpdateOrCreateUser(db, conditions, user)
    
    // Soft delete
    err = models.ParanoidDeleteUser(db, user.ID)
    
    // Restore
    err = models.RestoreUser(db, user.ID)
}
```

### Controller Usage

```go
package routes

import (
    "github.com/gin-gonic/gin"
    "your-app/app/controllers"
)

func SetupRoutes(router *gin.Engine, db *gorm.DB) {
    userController := controllers.NewUserController(db)
    
    v1 := router.Group("/api/v1")
    {
        users := v1.Group("/users")
        {
            users.GET("", userController.Index)
            users.POST("", userController.Store)
            users.GET("/:id", userController.Show)
            users.PUT("/:id", userController.Update)
            users.DELETE("/:id", userController.Delete)
            users.POST("/upsert", userController.UpdateOrCreate)
            users.DELETE("/:id/soft", userController.SoftDelete)
            users.POST("/:id/restore", userController.Restore)
            users.GET("/search", userController.Search)
            users.DELETE("/batch", userController.BatchDelete)
            users.GET("/by/:field/:value", userController.GetByField)
        }
    }
}
```

### API Examples

#### Create User
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "description": "Software Engineer"}'
```

#### Get Users with Pagination
```bash
curl "http://localhost:8080/api/v1/users?page=1&limit=5&order_by=name ASC"
```

#### Search Users
```bash
curl "http://localhost:8080/api/v1/users/search?q=john&page=1&limit=10"
```

#### Update or Create
```bash
curl -X POST http://localhost:8080/api/v1/users/upsert \
  -H "Content-Type: application/json" \
  -d '{
    "conditions": {"email": "john@example.com"},
    "data": {"name": "John Doe", "email": "john@example.com"}
  }'
```

#### Batch Delete
```bash
curl -X DELETE http://localhost:8080/api/v1/users/batch \
  -H "Content-Type: application/json" \
  -d '{"ids": [1, 2, 3], "soft": true}'
```

## Response Formats

### Success Response
```json
{
  "data": { /* record or array of records */ },
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 95,
    "limit": 10,
    "has_next": true,
    "has_prev": false
  }
}
```

### Error Response
```json
{
  "error": "Validation failed",
  "message": "name is required"
}
```

### Batch Operation Response
```json
{
  "deleted_count": 2,
  "total_count": 3,
  "errors": ["ID 3: User not found"],
  "message": "Batch delete completed with some errors"
}
```

## Customization

### Adding Custom Fields
Edit the generated model file to add your specific fields:

```go
type User struct {
    gorm.Model
    Name        string `json:"name" gorm:"column:name"`
    Description string `json:"description" gorm:"column:description"`
    Email       string `json:"email" gorm:"column:email;unique"`
    Age         int    `json:"age" gorm:"column:age"`
}
```

### Custom Validation
Modify the `Validate()` method in your model:

```go
func (m *User) Validate() error {
    if m.Name == "" {
        return errors.New("name is required")
    }
    if m.Email == "" {
        return errors.New("email is required")
    }
    if !strings.Contains(m.Email, "@") {
        return errors.New("invalid email format")
    }
    return nil
}
```

### Adding Custom Controller Methods
Add your own methods to the generated controller:

```go
func (c *UserController) GetProfile(ctx *gin.Context) {
    // Custom logic here
}
```

This comprehensive CRUD system provides everything you need for a modern REST API with advanced features like soft deletes, batch operations, search, and pagination!
