# WentPlate

<div align="center">
  <h3>A comprehensive project scaffolding tool for Go applications</h3>
  
  [![Go Version](https://img.shields.io/badge/go-1.21+-blue.svg)](https://golang.org)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Release](https://img.shields.io/github/v/release/ekinata/WentPlate.svg)](https://github.com/ekinata/WentPlate/releases)
</div>

---

## 🚀 Features

- **🏗️ Project Scaffolding**: Multiple templates for different project types
- **🎛️ Router Selection**: Choose between Gin and Chi HTTP routers
- **📁 Code Generation**: Laravel Artisan-style commands for generating boilerplate code  
- **📦 Package Management**: Download and manage external packages in your project
- **🎯 Interactive Mode**: User-friendly prompts when arguments are not provided
- **⚡ Command Line Interface**: Full CLI support with flags for automation
- **🌐 Cross-Platform**: Works on Linux, macOS, and Windows
- **🔗 Go Integration**: Automatically detects Go installation and version
- **⚙️ Clean Configuration**: Generates structured `wentconfig.json` for your project setup

## 📦 Installation

### Quick Install (Linux/macOS)

```bash
curl -sSL https://raw.githubusercontent.com/ekinata/WentPlate/main/install.sh | bash
```

### Manual Installation

#### Linux/macOS
```bash
# Download the install script
wget https://raw.githubusercontent.com/ekinata/WentPlate/main/install.sh
chmod +x install.sh
./install.sh
```

#### Windows (PowerShell)
```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Download and run the install script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ekinata/WentPlate/main/install.ps1" -OutFile "install.ps1"
.\install.ps1
```

### Prerequisites

The installer will automatically check and install:
- **Go** (1.21 or later)
- Platform-specific package managers (Homebrew, apt, dnf, choco, etc.)

## 🎯 Usage

### 1. Project Creation

#### Interactive Mode
Simply run `went` or `went new` without any arguments:

```bash
went
# or
went new
```

#### Command Line Mode
```bash
went new --name my-awesome-project --template API --deployment Docker --router gin
```

#### Router Selection
WentPlate supports multiple HTTP routers:

- **Gin** (default): Fast and simple web framework
- **Chi**: Lightweight, composable router

Choose your router during project creation or via `.env` configuration:

```bash
# Create project with Chi router
went new --name my-app --router chi

# Or set in .env file
echo "ROUTER=chi" > .env
went make:controller User  # Uses Chi template
```

### 2. Code Generation (Laravel Artisan Style)

#### Generate Models
```bash
went make:model User
went make:model Product
```

#### Generate Controllers
```bash
went make:controller Auth
went make:controller User
```

#### Generate Middleware
```bash
went make:middleware JWT
went make:middleware CORS
```

#### Generate Services
```bash
went make:service User
went make:service Email
```

#### Generate Migrations
```bash
went make:migration create_users_table
went make:migration add_email_to_users
```

### 3. Package Management

#### Install Packages from Git Repositories
```bash
# Install Gin web framework
went pkg:install https://github.com/gin-gonic/gin gin

# Install GORM
went pkg:install https://github.com/go-gorm/gorm gorm

# Install custom packages
went pkg:install https://github.com/your-org/your-package custom-pkg
```

#### List Installed Packages
```bash
went pkg:list
```

#### Remove Packages
```bash
went pkg:remove gin
went pkg:remove gorm
```

#### Update Import Paths
```bash
went pkg:update gin ./app
```

## 📋 Command Reference

### Project Commands

| Command | Description | Example |
|---------|-------------|---------|
| `went` | Create new project (interactive) | `went` |
| `went new` | Create new project with options | `went new --name my-app` |

#### Project Creation Flags

| Flag | Short | Description | Options |
|------|-------|-------------|---------|
| `--name` | `-N` | Project name | Any valid project name |
| `--template` | `-T` | Project template | `API`, `CLI`, `API+CLI`, `API+ReactJS`, `API+ReactJS+CLI` |
| `--deployment` | `-D` | Deployment type | `Docker`, `Kubernetes`, `No-Deployment` |
| `--router` | `-R` | HTTP router | `Gin`, `Chi` (default: `Gin`) |

### Code Generation Commands

| Command | Description | Example |
|---------|-------------|---------|
| `make:model <name>` | Generate model file | `went make:model User` |
| `make:controller <name>` | Generate controller file | `went make:controller Auth` |
| `make:middleware <name>` | Generate middleware file | `went make:middleware JWT` |
| `make:service <name>` | Generate service file | `went make:service User` |
| `make:migration <name>` | Generate migration file | `went make:migration create_users` |

### Package Management Commands

| Command | Description | Example |
|---------|-------------|---------|
| `pkg:install <url> <name>` | Install package from Git | `went pkg:install https://github.com/gin-gonic/gin gin` |
| `pkg:list` | List installed packages | `went pkg:list` |
| `pkg:remove <name>` | Remove package | `went pkg:remove gin` |
| `pkg:update <name> <dir>` | Update import paths | `went pkg:update gin ./app` |

### Utility Commands

| Command | Description |
|---------|-------------|
| `version` | Show version information |
| `help` | Show help message |

## 🎨 Project Templates

### API
- RESTful API server with Gin
- Basic routing structure
- Middleware support
- Database integration ready
- GORM models

### CLI
- Command-line interface with Cobra
- Subcommand support
- Flag parsing
- User-friendly help system

### API+CLI
- Combined API server and CLI tool
- Shared business logic
- Flexible deployment options

### API+ReactJS
- Full-stack web application
- React frontend with modern tooling
- Go API backend
- Development and production builds

### API+ReactJS+CLI
- Complete solution with all components
- Web interface, API, and CLI tool
- Maximum flexibility

## 🐳 Deployment Options

### Docker
- Multi-stage Dockerfile
- Optimized container size
- Development and production configurations
- Docker Compose setup

### Kubernetes
- Deployment manifests
- Service configurations
- ConfigMap and Secret templates
- Ingress setup ready

### No-Deployment
- Local development focus
- Simple build scripts
- Environment configuration
- Manual deployment ready

## � Generated File Structure

When you run generation commands, files are created in the following structure:

```
your-project/
├── app/
│   ├── controllers/     # Generated controllers
│   ├── models/         # Generated models
│   ├── middleware/     # Generated middleware
│   ├── services/       # Generated services
│   └── migrations/     # Generated migrations
├── pkg/               # Installed packages
├── internal/
│   └── templates/     # Template files
└── wentconfig.json   # Project configuration
```

## 📦 Package Management

WentPlate includes a powerful package management system that allows you to:

1. **Install packages** directly from Git repositories into a local `pkg/` folder
2. **Manage dependencies** without affecting your `go.mod`
3. **Update import paths** to use local packages
4. **Version control** your dependencies as part of your project

This is particularly useful for:
- **Private packages** that aren't available in public repositories
- **Vendoring dependencies** for air-gapped environments
- **Customizing third-party packages** without forking
- **Ensuring reproducible builds** across environments

## 🛠️ Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/ekinata/WentPlate.git
cd WentPlate

# Build the binary
go build -o went main.go

# Run locally
./went --help
```

### Dependencies

- [promptui](https://github.com/manifoldco/promptui) - Interactive prompts
- Go standard library

## � Examples

### Complete Workflow Example

```bash
# 1. Create a new API project
went new --name blog-api --template API --deployment Docker

# 2. Generate models
went make:model User
went make:model Post
went make:model Comment

# 3. Generate controllers
went make:controller User
went make:controller Post
went make:controller Comment

# 4. Generate services
went make:service User
went make:service Post

# 5. Generate middleware
went make:middleware Auth
went make:middleware CORS

# 6. Install packages
went pkg:install https://github.com/gin-gonic/gin gin
went pkg:install https://github.com/go-gorm/gorm gorm

# 7. List installed packages
went pkg:list
```

### Laravel Artisan Style Commands

If you're familiar with Laravel, you'll feel right at home:

```bash
# Laravel Artisan          # WentPlate Equivalent
php artisan make:model User    # went make:model User
php artisan make:controller    # went make:controller User
php artisan make:middleware    # went make:middleware Auth
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the Go community
- Inspired by Laravel Artisan and modern project scaffolding tools
- Thanks to all contributors and users

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/ekinata">ekinata</a></p>
  <p>⭐ Star this project if you find it helpful!</p>
</div>
