# Dev Environment Manager (dev-env)

A **cross-platform, modular Dev Environment Backup, Restore, Testing, and Reporting framework** designed to simplify developer setup across multiple machines and operating systems.

---

## 🚀 Overview

`dev-env` is a structured system that allows developers to:

- Backup development environments (VS Code, Node.js, Python, PHP, etc.)
- Restore environments on new machines
- Validate setups using automated tests
- Generate environment reports
- Maintain OS-specific configurations (Windows, Linux, macOS)

It works as a **local dev environment manager and orchestration system**.

---

## 📁 Project Structure

```bash

    dev-env/
    │
    ├── dev/
    │   ├── core/                 # CLI orchestrator (backup/restore/test all modules)
    │   ├── vscode/              # VS Code module
    │   ├── nodejs/             # Node.js & npm module
    │   ├── python/             # Python module
    │   ├── php/                # PHP & Composer module
    │   └── ...                 # Future modules
    │
    ├── Reports/                # Auto-generated markdown reports
    ├── Testing/                # Test cases & execution results
    │
    ├── README.md
    ├── LICENSE
    ├── .gitignore
    ├── report.pdf              # Seminar / documentation report
    ├── ppt.pptx                # Presentation file
    └── .git/                   # Git metadata

```

---

## ⚙️ Features

### 🔧 Core System
- Central execution engine (`dev/core`)
- Backup all modules at once
- Restore all modules at once
- Future CLI-based interactive control

---

### 💻 Module-Based Design

Each tool is structured as an independent module:

#### Example Modules:
- VS Code (extensions, settings, snippets, keybindings)
- Node.js (versions, global packages)
- Python (pip packages, environments)
- PHP (Composer packages)

Each module supports:
- Windows (`.ps1`)
- Linux (`.sh`)
- macOS (`.sh`)

---

### 📦 Backup System
- Saves environment state per module
- Supports merge and overwrite modes
- Preserves configuration data in `Data/`

---

### 🔄 Restore System
- Reinstalls extensions/packages
- Restores configurations
- Handles missing dependencies safely

---

### 🧪 Testing Layer
- Module validation scripts
- JSON-based test definitions
- Result tracking per module

---

### 📊 Reporting System
- Generates markdown reports per module
- Tracks backup/restore activity
- Maintains historical snapshots

---

## 🖥 Supported Platforms

- Windows (PowerShell)
- Linux (Bash)
- macOS (Bash / Zsh compatible)

---

## 🧠 Core Concept

This project follows a **modular plugin architecture**:

```bash
    Core Engine → Modules → Data → Reports → Tests
```


The system is designed to be:

- Scalable
- Cross-platform
- Extensible
- Automation-friendly

---

## 🚀 Future Scope

Planned improvements:

- CLI tool (`dev-env`) for unified commands
- Module registry system
- Smart diff-based backups
- Cloud sync support
- Docker-based environment snapshots
- GUI dashboard (optional future version)

---

## 🛠 Example Usage (Future CLI)

```bash

dev-env backup vscode
dev-env restore nodejs
dev-env test all
dev-env report generate

```

## 📌 Philosophy

> "A developer should never lose their environment setup again."

This project is built on the principle of **automation, reproducibility, and portability**, ensuring that a developer’s environment can be restored anytime, anywhere, with minimal effort.

---

## 👤 Author

**Piyush Anand**

- GitHub: [PR2309](https://github.com/PR2309)  
- LinkedIn: [piyushanand30](https://www.linkedin.com/in/piyushanand30)  
- Email: [piyushanand2309@gmail.com](mailto:piyushanand2309@gmail.com)

Built as part of a **Development Environment Manager (dev-env)** framework project focused on:

- Automation of developer environments  
- Reproducibility across systems  
- Cross-platform compatibility  
- Improved developer productivity  

---

## 📥 Installation (Clone Repository)

To use this project, first clone the repository:

```bash
git clone https://github.com/your-username/dev-env.git
```

Then navigate into the project directory:
```bash
cd dev-env
```

---

## 📜 License

This project is licensed under the **MIT License**.