# WentPlate

<div align="center">
  <img src="logo.png" alt="WentPlate Logo" width="200"/>
  
  <h3>A minimal project initializer for Go applications</h3>
  
  [![Go Version](https://img.shields.io/badge/go-1.21+-blue.svg)](https://golang.org)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Release](https://img.shields.io/github/v/release/ekinata/WentPlate.svg)](https://github.com/ekinata/WentPlate/releases)
</div>

---

## 🚀 Features

- **Multiple Templates**: Choose from API, CLI, API+CLI, API+ReactJS, or API+ReactJS+CLI project templates
- **Deployment Options**: Built-in support for Docker, Kubernetes, or no-deployment configurations
- **Interactive Mode**: User-friendly prompts when arguments are not provided
- **Command Line Interface**: Full CLI support with flags for automation
- **Cross-Platform**: Works on Linux, macOS, and Windows
- **Go Integration**: Automatically detects Go installation and version
- **Clean Configuration**: Generates structured `wentconfig.json` for your project setup

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

### Interactive Mode

Simply run `went` without any arguments to start the interactive setup:

```bash
went
```

This will guide you through:
1. **Project Name**: Enter your project name (will be sanitized automatically)
2. **Template Selection**: Choose from available templates
3. **Deployment Configuration**: Select your deployment strategy

### Command Line Mode

Use flags for automated project creation:

```bash
went --name my-awesome-project --template API --deployment Docker
```

#### Available Flags

| Flag | Short | Description | Options |
|------|-------|-------------|---------|
| `--name` | `-N` | Project name | Any valid project name |
| `--template` | `-T` | Project template | `API`, `CLI`, `API+CLI`, `API+ReactJS`, `API+ReactJS+CLI` |
| `--deployment` | `-D` | Deployment type | `Docker`, `Kubernetes`, `No-Deployment` |
| `--help` | `-h` | Show help | - |

### Examples

#### Basic API Project
```bash
went -N my-api -T API -D No-Deployment
```

#### Full-Stack Application with Kubernetes
```bash
went --name my-fullstack-app --template "API+ReactJS" --deployment Kubernetes
```

#### CLI Tool with Docker
```bash
went -N my-cli-tool -T CLI -D Docker
```

## 🎨 Templates

### API
- RESTful API server
- Basic routing structure
- Middleware support
- Database integration ready

### CLI
- Command-line interface
- Subcommand support
- Flag parsing
- User-friendly help system

### API+CLI
- Combined API server and CLI tool
- Shared business logic
- Flexible deployment options

### API+ReactJS
- Full-stack web application
- React frontend
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

## 📋 Output

After running `went`, you'll get a `wentconfig.json` file with your project configuration:

```json
{
  "project_name": "my-awesome-project",
  "template": "API+ReactJS",
  "deployment": "Docker"
}
```

This configuration file can be used by other tools in the Went ecosystem to generate your project structure.

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

## 📚 Additional Commands

### Version Information
```bash
went version
```

### Help
```bash
went help
# or
went --help
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
- Inspired by modern project scaffolding tools
- Thanks to all contributors and users

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/ekinata">ekinata</a></p>
  <p>⭐ Star this project if you find it helpful!</p>
</div>
