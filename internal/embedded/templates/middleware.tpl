package middleware

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// {{.ModelName}}Middleware implements {{.ModelName}} middleware
func {{.ModelName}}Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// TODO: Implement your middleware logic here
		// Example: Authentication, logging, rate limiting, etc.
		
		// For example, a simple authentication check:
		// token := c.GetHeader("Authorization")
		// if token == "" {
		//     c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
		//     c.Abort()
		//     return
		// }
		
		// Continue to next handler
		c.Next()
	}
}

// {{.ModelName}}Logger logs requests for {{.ModelName}} endpoints
func {{.ModelName}}Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		// Custom log format for {{.ModelName}} endpoints
		return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
			param.ClientIP,
			param.TimeStamp.Format("02/Jan/2006:15:04:05 -0700"),
			param.Method,
			param.Path,
			param.Request.Proto,
			param.StatusCode,
			param.Latency,
			param.Request.UserAgent(),
			param.ErrorMessage,
		)
	})
}
