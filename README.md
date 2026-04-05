<div align="center">

```
 ╔═══════════════════════════════════════════════════════════════════════════╗
 ║                                                                         ║
 ║   ███████╗███████╗ ██████╗██████╗ ███████╗██╗   ██╗███████╗███████╗ ██████╗  ║
 ║   ██╔════╝██╔════╝██╔════╝██╔══██╗██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝  ║
 ║   ███████╗█████╗  ██║     ██║  ██║█████╗  ██║   ██║███████╗█████╗  ██║       ║
 ║   ╚════██║██╔══╝  ██║     ██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║██╔══╝  ██║       ║
 ║   ███████║███████╗╚██████╗██████╔╝███████╗ ╚████╔╝ ███████║███████╗╚██████╗  ║
 ║   ╚══════╝╚══════╝ ╚═════╝╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝╚══════╝ ╚═════╝  ║
 ║                                                                         ║
 ║           DevSecOps VM Provisioner  ·  217+ Tools  ·  One Script        ║
 ║                  Zorin OS 17.x  ·  amd64 + arm64                        ║
 ║                                                                         ║
 ╚═══════════════════════════════════════════════════════════════════════════╝
```

[![Shell Script](https://img.shields.io/badge/Bash-5.x-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Zorin OS](https://img.shields.io/badge/Zorin%20OS-17.x-0CC1F3?style=for-the-badge&logo=zorin&logoColor=white)](https://zorin.com/os/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Tools](https://img.shields.io/badge/Tools-217+-FF6B6B?style=for-the-badge&logo=stackblitz&logoColor=white)](#-full-tool-inventory)
[![Architecture](https://img.shields.io/badge/Arch-amd64%20|%20arm64-8B5CF6?style=for-the-badge&logo=linux&logoColor=white)](#)

</div>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  WHAT IS THIS?                                                         │
  └──────────────────────────────────────────────────────────────────────────┘
```

A single shell script that transforms a fresh **Zorin OS 17.x** install into a fully-loaded **DevSecOps workstation** — mirroring the reference **SOS-DevSEC-VM** with **217+ tools** pre-configured and ready to go.

No manual package hunting. No broken dependencies. No silent failures.
Run one command and grab a coffee.

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  FEATURES                                                              │
  └──────────────────────────────────────────────────────────────────────────┘
```

```
  ╭────────────────╮  ╭────────────────╮  ╭────────────────╮  ╭────────────────╮
  │  217+ TOOLS    │  │  RESILIENT     │  │  ARCH-AWARE    │  │  IDEMPOTENT    │
  │  installed &   │  │  every install │  │  amd64 + arm64 │  │  safe to       │
  │  configured    │  │  is wrapped in │  │  auto-detected │  │  re-run        │
  │  automatically │  │  safe handlers │  │                │  │                │
  ╰────────────────╯  ╰────────────────╯  ╰────────────────╯  ╰────────────────╯

  ╭────────────────╮  ╭────────────────╮  ╭────────────────╮
  │  REAL-TIME     │  │  PRE-FLIGHT    │  │  TUI OUTPUT    │
  │  live success/ │  │  validates 11  │  │  ASCII banner, │
  │  failure logs  │  │  APT repos     │  │  progress bar, │
  │  with summary  │  │  before start  │  │  color tables  │
  ╰────────────────╯  ╰────────────────╯  ╰────────────────╯
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  QUICK START                                                           │
  └──────────────────────────────────────────────────────────────────────────┘
```

```bash
git clone https://github.com/0xBugatti/SECDevSEC.git
cd SECDevSEC
sudo bash prep.sh
```

```
  ┌─ Prerequisites ────────────────────────────────────────────────────────┐
  │                                                                        │
  │   OS ........... Zorin OS 17.x (Ubuntu 24.04 base)                     │
  │   Disk ......... 50 GB minimum (full install ~30-35 GB)                │
  │   RAM .......... 8 GB min / 16 GB recommended                          │
  │   User ......... Non-root with sudo privileges                         │
  │   Internet ..... Required (apt, snap, pip, npm, GitHub releases)       │
  │                                                                        │
  └────────────────────────────────────────────────────────────────────────┘
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  REPOSITORY STRUCTURE                                                  │
  └──────────────────────────────────────────────────────────────────────────┘
```

```
  SECDevSEC/
  ├── prep.sh          # Zorin OS 17.x DevSecOps provisioner (amd64 + arm64)
  └── README.md        # You are here
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  HOW IT WORKS                                                          │
  └──────────────────────────────────────────────────────────────────────────┘
```

### Resilient Execution Model

Every install operation goes through **safe wrapper functions** that never crash the script:

```
  ┌──────────────┬──────────────────────────────────────────────────────────┐
  │  Wrapper     │  Purpose                                                │
  ├──────────────┼──────────────────────────────────────────────────────────┤
  │  safe_apt    │  Single apt package with failure logging                │
  │  safe_apt_b  │  Multiple apt packages, detects partial failures        │
  │  safe_snap   │  Snap packages with failure logging                     │
  │  safe_pip    │  pip3 packages with failure logging                     │
  │  safe_npm    │  npm global packages with failure logging               │
  │  safe_curl   │  Binary downloads with integrity check                  │
  │  safe_curl_p │  curl-to-bash installers                                │
  │  safe_git    │  Git repository cloning                                 │
  │  safe_dpkg   │  Local .deb installation with auto-fix                  │
  │  safe_sysctl │  Service enable/start with warning on failure           │
  └──────────────┴──────────────────────────────────────────────────────────┘
```

Each wrapper: checks if already installed (SKIP) -> attempts install -> logs OK or FAIL -> **never crashes**.

### APT Source Pre-Flight

Before any packages install, `check_all_sources()` validates 11 third-party repos:

```
  APT Sources Status:
    [OK]    gierens (added)
    [OK]    sublimehq (added)
    [SKIP]  nodesource (already configured)
    [OK]    mongodb (added)
    [OK]    caddy (added)
    [OK]    docker (added)
    [OK]    hashicorp (added)
    [OK]    github-cli (added)
    [OK]    google-cloud (added)
    [OK]    trivy (added)
    [SKIP]  gitlab-runner (already configured)
```

### Installation Sections

The script runs through **23 numbered sections**, each with a TUI header:

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ STEP 07 │ CI/CD & DEVOPS TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

### Summary Output

```
  INSTALLATION SUMMARY
  ══════════════════════════════════════════════════════
  Elapsed: 42m 15s   Steps completed: 23
  INSTALLED 192  FAILED 3  SKIPPED 22  WARNINGS 5
  [████████████████████████████████░░░░░] 89% (192/217)

  TOOL VERIFICATION
  ─────────────────────────────────────────────────────
  STATUS    TOOL                   VERSION
  [OK]      Python                 3.12.3
  [OK]      Node.js                v22.x.x
  [OK]      Docker                 26.x.x
  [MISS]    Ghidra                 not found
  ...
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  DISK USAGE ESTIMATES                                                  │
  └──────────────────────────────────────────────────────────────────────────┘
```

```
  ┌──────────────────────────────────────┬──────────────┐
  │  Category                            │  Size        │
  ├──────────────────────────────────────┼──────────────┤
  │  System + Build Essentials           │  ~800 MB     │
  │  Languages & Runtimes                │  ~4.5 GB     │
  │  Databases (MySQL, PG, Mongo, Redis) │  ~1.2 GB     │
  │  Docker CE + Compose                 │  ~800 MB     │
  │  Cloud CLIs (AWS, Azure, GCloud)     │  ~1.5 GB     │
  │  Security & RE Tools                 │  ~2.4 GB     │
  │  DevSecOps Scanners                  │  ~400 MB     │
  │  IDEs (Snaps)                        │  ~12-18 GB   │
  │  Desktop/Communication Snaps         │  ~3 GB       │
  │  Python pip packages                 │  ~2 GB       │
  │  NPM globals + Monitoring            │  ~500 MB     │
  │  Browsers + Media                    │  ~1.8 GB     │
  ├──────────────────────────────────────┼──────────────┤
  │  TOTAL (full install)                │  ~30-35 GB   │
  │  TOTAL (skip IDEs)                   │  ~10-12 GB   │
  └──────────────────────────────────────┴──────────────┘
```

> JetBrains IDEs account for ~40% of total disk usage. Skip them if disk space is limited.

---

```
  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                        ║
  ║                    FULL TOOL INVENTORY                                  ║
  ║                                                                        ║
  ║          Reference: SOS-DevSEC-VM · Ubuntu 24.04.1 LTS                 ║
  ║          Kernel: 6.8.0-49-generic x86_64                               ║
  ║                                                                        ║
  ╚══════════════════════════════════════════════════════════════════════════╝
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 01 │ LANGUAGES & RUNTIMES
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/python/python-original.svg" alt="Python" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/nodejs/nodejs-original-wordmark.svg" alt="Node.js" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/go/go-original.svg" alt="Go" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/rust/rust-plain.svg" alt="Rust" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/php/php-original.svg" alt="PHP" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/java/java-original.svg" alt="Java" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/ruby/ruby-original.svg" alt="Ruby" width="40" height="40" /> <img src="https://cdn.simpleicons.org/deno/000000" alt="Deno" width="40" height="40" /> <img src="https://cdn.simpleicons.org/bun/000000" alt="Bun" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/dot-net/dot-net-original-wordmark.svg" alt=".NET" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/kotlinlang/kotlinlang-icon.svg" alt="Kotlin" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/lua/lua-icon.svg" alt="Lua" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/perl/perl-icon.svg" alt="Perl" width="40" height="40" />

| Language / Runtime | Version | Install Source |
|---|---|---|
| Python 3 | 3.12.3 | apt (`python3`, `python3.12`) |
| Python 3 Dev | 3.12.3 | apt (`python3-dev`, `python3.12-dev`) |
| Node.js | 18.19.1 | apt (`nodejs`) |
| Go | 1.22.2 | apt (`golang-1.22-go`, `golang-go`) |
| Ruby | 4.0.0 | snap (`ruby`) |
| PHP | 8.3.6 | apt (`php8.3`, `php8.3-cli`) |
| Perl | 5.38.2 | apt (`perl`) |
| Lua | 5.3.6 | apt (`lua5.3`) |
| Lua shared lib | 5.4.6 | apt (`liblua5.4-0`) |
| Java (OpenJDK JRE) | 17.0.13 | apt (`openjdk-17-jre`, `openjdk-17-jre-headless`) |
| .NET SDK | 8.0.407 | snap (`dotnet-sdk`) |
| Kotlin | 2.3.20 | snap (`kotlin`) |
| Erlang (partial) | 25.3.2 | apt (`erlang-jinterface`, `erlang-mode`) |
| Rust | 1.92.0 | rustup |
| Deno | 2.6.3 | installer |
| Bun | 1.3.5 | installer |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 02 │ PACKAGE MANAGERS & BUILD TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

#### Package Managers

| Tool | Version | Notes |
|---|---|---|
| pip3 | 25.3 | Python package manager |
| pyenv | 2.6.17 | Python version manager |
| pipenv | 2026.0.3 | Python virtualenv + pip |
| poetry | 2.2.1 | Python dependency manager |
| npm | 11.6.2 | Node.js package manager |
| NVM | -- | Node version manager |
| pnpm | 10.26.1 | Fast Node.js package manager (npm global) |
| Yarn | 1.22.22 | Node.js package manager |
| bundler | 4.0.3 | Ruby gem manager |
| rbenv | 1.3.2 | Ruby version manager |
| cargo | 1.92.0 | Rust package manager |
| rustup | 1.28.2 | Rust toolchain manager |

#### Build & Compilation Tools

| Tool | Version | Package |
|---|---|---|
| GCC | 13.2.0 | `gcc`, `gcc-13` |
| G++ | 13.2.0 | `g++`, `g++-13` |
| Clang / libclang | 18.1.3 | `libclang-cpp18`, `libclang1-18` |
| Make | 4.3 | `make` |
| CMake | 4.3.1 | snap (`cmake`) |
| Automake | 1.16.5 | `automake` |
| GYP | 0.1 | `gyp` |
| Gradle | 8.14.4 | snap (`gradle`) |
| Binutils | 2.42 | `binutils` |
| build-essential | 12.10 | `build-essential` |
| GDB (debugger) | 15.0.50 | `gdb` |
| strace | 6.8 | `strace` |
| node-gyp | 9.3.0 | apt (`node-gyp`) |
| golangci-lint | v1.64.8 | Go linter |
| gopls | -- | Go language server |
| TypeScript | 5.9.3 | npm global |
| ts-node | 10.9.2 | TypeScript runtime |
| Nodemon | 3.1.11 | Node.js auto-restart |
| PM2 | 6.0.14 | Node.js process manager |

#### PHP Extensions

`php8.3-cli`, `php8.3-curl`, `php8.3-gd`, `php8.3-mbstring`, `php8.3-mcrypt`,
`php8.3-mysql`, `php8.3-opcache`, `php8.3-readline`, `php8.3-xml`, `php8.3-zip`,
`php-bz2`, `php-common`, `libapache2-mod-php8.3`

#### PHP Libraries

`php-composer-ca-bundle`, `php-psr-log`, `php-psr-cache`, `php-psr-http-message`,
`php-twig`, `php-symfony-cache`, `php-symfony-dependency-injection`, `php-tcpdf`,
`php-nikic-fast-route`, `php-slim-psr7`, `phpmyadmin`

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 03 │ EDITORS & IDEs
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/visualstudiocode/visualstudiocode-original.svg" alt="VS Code" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jetbrains/jetbrains-icon.svg" alt="JetBrains" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jetbrains_pycharm/jetbrains_pycharm-icon.svg" alt="PyCharm" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jetbrains_goland/jetbrains_goland-icon.svg" alt="GoLand" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jetbrains_clion/jetbrains_clion-icon.svg" alt="CLion" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jetbrains_webstorm/jetbrains_webstorm-icon.svg" alt="WebStorm" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/android/android-icon.svg" alt="Android Studio" width="40" height="40" />

#### Terminal Editors

| Editor | Version |
|---|---|
| Vim | 9.1.0016 |
| Neovim | 0.9.5 |
| Emacs (GTK) | 29.3 |
| xxd | 9.1 (bundled with Vim) |
| Sublime Text | Build 4200 |

#### IDEs & GUI Editors (snap)

| Application | Version | Channel |
|---|---|---|
| VS Code | ddc367ed | latest/stable |
| VS Code Insiders | 00515ed0 | latest/stable |
| IntelliJ IDEA Community | 2024.3.4.1 | latest/stable |
| IntelliJ IDEA Ultimate | 2024.3.4.1 | latest/stable |
| PyCharm Community | 2024.3.5 | latest/stable |
| PyCharm Professional | 2024.3.5 | latest/stable |
| CLion | 2024.3.5 | latest/stable |
| GoLand | 2024.3.5 | latest/stable |
| WebStorm | 2024.3.5 | latest/stable |
| PhpStorm | 2024.3.5 | latest/stable |
| RubyMine | 2024.3.5 | latest/stable |
| Rider | 2024.3.6 | latest/stable |
| RustRover | 2024.3.7 | latest/stable |
| DataGrip | 2024.3.3 | latest/stable |
| DataSpell | 2024.3.2 | latest/stable |
| Android Studio (Koala) | 2024.1.1.11 | latest/stable |
| Eclipse | 2026-03 | latest/stable |
| MarkText | 0.17.1 | latest/stable |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 04 │ DATABASES
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/mysql/mysql-original-wordmark.svg" alt="MySQL" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/postgresql/postgresql-original-wordmark.svg" alt="PostgreSQL" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/mongodb/mongodb-original-wordmark.svg" alt="MongoDB" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/redis/redis-original-wordmark.svg" alt="Redis" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/sqlite/sqlite-icon.svg" alt="SQLite" width="40" height="40" />

#### Database Servers

| Database | Version | Install Source | Status |
|---|---|---|---|
| MySQL Server | 8.0.40 | apt | Running (systemd) |
| PostgreSQL | 16.6 | apt | Running (systemd) |
| MongoDB | 8.0.4 | apt (mongodb-org) | Running (systemd) |
| Redis | 7.0.15 | apt | Running (systemd) |
| SQLite3 | 3.45.1 | apt (libsqlite3-0) | Library only |

#### Database Clients & Tools

| Tool | Version | Source |
|---|---|---|
| mysql-client | 8.0.40 | apt |
| postgresql-client | 16.6 | apt |
| mongodb-mongosh | 2.3.4 | apt |
| mongodb-database-tools | 100.10.0 | apt |
| redis-tools | 7.0.15 | apt |
| phpMyAdmin | 5.2.1 | apt |
| DBeaver CE | 25.0.1 | snap |
| Beekeeper Studio | 5.6.3 | snap |
| DataGrip | 2024.3.3 | snap |

#### Database Python & PHP Packages

- **Python:** `psycopg2` 2.9.10, `pymongo` 4.10.1, `docker` 5.0.3
- **PHP:** `php-mysql`, `php8.3-mysql`, `dbconfig-mysql`, `libmysqlclient21`, `libpq-dev`, `libpq5`

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 05 │ WEB SERVERS & PROXIES
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/nginx/nginx-original.svg" alt="Nginx" width="40" height="40" /> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/apache/apache-original-wordmark.svg" alt="Apache" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/caddyserver/caddyserver-icon.svg" alt="Caddy" width="40" height="40" /> <img src="https://cdn.simpleicons.org/letsencrypt/003A70" alt="Certbot" width="40" height="40" />

| Server | Version | Source | Status |
|---|---|---|---|
| Nginx | 1.24.0 | apt | Running (systemd) |
| Apache2 | 2.4.58 | apt | Installed |
| Gunicorn (Python WSGI) | 20.1.0 | apt + pip | Library |
| Certbot | 2.9.0 | apt | SSL cert management |
| Caddy | 2.10.2 | binary | Reverse proxy / web server |
| vsftpd | -- | apt | FTP server |
| FileZilla | -- | apt | FTP client (GUI) |

#### Web Frameworks (Python)

| Package | Version |
|---|---|
| Django | 4.0.4 |
| django-cleanup | 6.0.0 |
| django-froala-editor | 4.0.14 |
| gunicorn | 20.1.0 |
| Jinja2 | 3.1.2 |
| MarkupSafe | 2.1.5 |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 06 │ CONTAINERS & ORCHESTRATION
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="Docker" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/kubernetes/kubernetes-icon.svg" alt="Kubernetes" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/helmsh/helmsh-icon.svg" alt="Helm" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/minikube/minikube-icon.svg" alt="Minikube" width="40" height="40" />

| Tool | Version | Source |
|---|---|---|
| Docker | 26.1.3 | apt (`docker.io`) |
| docker-compose | 1.29.2 | apt |
| kubectl | 1.34.6 | snap |
| Minikube | 0.8.0 | snap |
| VirtualBox API | 1.0 (vboxapi) | pip |

**Docker Python packages:** `docker` 5.0.3, `docker-compose` 1.29.2, `dockerpty` 0.4.1, `python3-compose`

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 07 │ CI/CD & DEVOPS TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/terraformio/terraformio-icon.svg" alt="Terraform" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/ansible/ansible-icon.svg" alt="Ansible" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/github/github-icon.svg" alt="GitHub" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg" alt="Jenkins" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/argoproj/argoproj-icon.svg" alt="ArgoCD" width="40" height="40" />

| Tool | Version | Source |
|---|---|---|
| Ansible | 9.2.0 | apt + pip |
| ansible-core | 2.16.3 | apt + pip |
| Terraform | 1.14.8 | snap |
| Packer | 1.14.3 | binary |
| Jenkins | 2.554 | snap |
| GitHub CLI (gh) | 2.83.2 | binary |
| GitLab Runner | 18.7.0 | binary |
| ArgoCD CLI | -- | binary |
| Flux CLI | 2.7.5 | binary |
| Skaffold | -- | binary |
| Telepresence | -- | binary |
| Tilt | -- | binary |
| Pulumi | -- | binary |
| Vagrant | 2.4.9 | binary |
| Task (taskfile) | 3.46.3 | binary |
| Helm | -- | binary |
| eksctl | -- | binary |
| k9s | -- | binary |
| yq | v4.50.1 | binary |
| direnv | 2.37.1 | apt |
| JetBrains Space | 2023.1.7 | snap |

<details>
<summary><b>Ansible Python dependencies</b></summary>

`paramiko` 2.12.0, `jinja2` 3.1.2, `pexpect` 4.9.0, `pywinrm` 0.4.3,
`requests-ntlm` 1.1.0, `ntlm-auth` 1.5.0, `kerberos` 1.1.14, `resolvelib` 1.0.1,
`dnspython` 2.6.1, `netaddr` 0.8.0, `netifaces` 0.11.0, `xmltodict` 0.13.0

</details>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 08 │ SECURITY & NETWORK TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/nmaporg/nmaporg-icon.svg" alt="Nmap" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/wireshark/wireshark-icon.svg" alt="Wireshark" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/owasp/owasp-icon.svg" alt="OWASP" width="40" height="40" />

| Tool | Version | Package |
|---|---|---|
| nmap | 7.94SVN | `nmap` |
| Masscan | -- | binary |
| netcat (OpenBSD) | 1.226 | `netcat-openbsd` |
| ncat | 7.94SVN | `nmap` (bundled) |
| socat | -- | apt |
| tcpdump | 4.99.4 | `tcpdump` |
| tshark | 4.2.2 | `tshark` |
| Wireshark | 4.2.2 | apt |
| curl | 8.5.0 | `curl` |
| wget | 1.21.4 | `wget` |
| OpenSSL | 3.0.13 | `openssl`, `libssl-dev` |
| strace | 6.8 | `strace` |
| ltrace | 0.7.3 | apt |
| GDB | 15.0.50 | `gdb` |
| Valgrind | 3.22.0 | apt |
| binutils (nm, objdump, ld...) | 2.42 | `binutils` |
| strings | 2.42 | `binutils` |
| readelf | 2.42 | `binutils` |
| libpcap | 1.10.4 | `libpcap0.8t64` |
| xxd | 9.1 | `xxd` |
| file | 5.45 | apt |
| hexedit | -- | apt |
| ExifTool | -- | apt |
| YARA | 4.5.0 | binary |
| mtr-tiny | 0.95 | `mtr-tiny` |
| strace-static | 6.8 | snap |
| ProxyChains | -- | apt |
| Nikto | -- | apt |
| Dirb | -- | apt |
| Gobuster | -- | binary |
| Wfuzz | 3.1.0 | pip |
| SQLMap | 1.8.4 | pip/binary |
| ffuf | -- | binary |
| mitmproxy | 8.1.1 | pip |

<details>
<summary><b>Python Security / Crypto packages</b></summary>

`cryptography` 41.0.7, `bcrypt` 3.2.2, `PyNaCl` 1.5.0, `PyJWT` 2.7.0,
`passlib` 1.7.4, `paramiko` 2.12.0, `pyOpenSSL` (via cryptography)

</details>

<details>
<summary><b>SSL / TLS libraries</b></summary>

`libssl-dev` 3.0.13, `libssl3t64` 3.0.13, `libssh-4` 0.10.6, `ssl-cert`

</details>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 09 │ TERMINAL & SHELL TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/zsh/zsh-icon.svg" alt="Zsh" width="40" height="40" /> <img src="https://cdn.simpleicons.org/tmux/1BB91F" alt="tmux" width="40" height="40" /> <img src="https://cdn.simpleicons.org/starship/FF016B" alt="Starship" width="40" height="40" /> <img src="https://cdn.simpleicons.org/kittyterminal/5A46F5" alt="Kitty" width="40" height="40" />

| Tool | Version | Source |
|---|---|---|
| tmux | 3.4 | apt |
| screen | 4.09.01 | apt |
| Vim | 9.1 | apt |
| Terminator | 2.1.3 | pip/apt |
| Alacritty | 0.13.2 | apt/binary |
| Kitty | 0.32.2 | binary |
| WaveTerm | 0.14.4 | snap |
| Termius | 9.37.5 | snap |
| Termius Beta | 9.37.6 | snap |
| PowerShell | 7.6.0 | snap |
| zsh | 5.9 | apt (`zsh-common`) |
| Oh-My-Zsh | -- | installer |
| Powerlevel10k | -- | Oh-My-Zsh plugin |
| Starship | 1.24.1 | binary |
| Nerd Fonts | -- | manual install |
| bash | System default | apt |
| Midnight Commander | 4.8.30 | apt |
| Ranger | 1.9.3 | apt |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 10 │ PYTHON PACKAGES (pip3)
  └──────────────────────────────────────────────────────────────────────────┘
```

<details>
<summary><b>Click to expand full pip3 package list</b></summary>

| Package | Version | Category |
|---|---|---|
| ansible | 9.2.0 | DevOps |
| ansible-core | 2.16.3 | DevOps |
| apache-libcloud | 3.4.1 | Cloud |
| attrs | 23.2.0 | Utils |
| autopep8 | 1.6.0 | Dev tools |
| Babel | 2.10.3 | i18n |
| bcrypt | 3.2.2 | Security |
| bcc | 0.29.1 | BPF/Tracing |
| certifi | 2023.11.17 | TLS |
| click | 8.1.6 | CLI |
| colorama | 0.4.6 | Terminal |
| cryptography | 41.0.7 | Security |
| Django | 4.0.4 | Web framework |
| django-cleanup | 6.0.0 | Django |
| django-froala-editor | 4.0.14 | Django |
| dnspython | 2.6.1 | Network |
| docker | 5.0.3 | Containers |
| docker-compose | 1.29.2 | Containers |
| dotenv (python-dotenv) | 1.0.1 | Config |
| gunicorn | 20.1.0 | WSGI server |
| httplib2 | 0.20.4 | HTTP |
| Jinja2 | 3.1.2 | Templates |
| jmespath | 1.0.1 | JSON query |
| jsonschema | 4.10.3 | Validation |
| PyJWT | 2.7.0 | Auth |
| Mako | 1.3.2 | Templates |
| netaddr | 0.8.0 | Network |
| netifaces | 0.11.0 | Network |
| oauthlib | 3.2.2 | Auth |
| packaging | 24.0 | Utils |
| paramiko | 2.12.0 | SSH |
| passlib | 1.7.4 | Password hashing |
| pexpect | 4.9.0 | Automation |
| Pillow | 9.4.0 | Image processing |
| pip | 24.0 | Package manager |
| psutil | 5.9.8 | System monitoring |
| psycopg2 | 2.9.10 | PostgreSQL |
| pycairo | 1.25.1 | Graphics |
| Pygments | 2.17.2 | Syntax highlight |
| PyGObject | 3.48.2 | GTK bindings |
| pymongo | 4.10.1 | MongoDB |
| PyNaCl | 1.5.0 | Crypto |
| pyparsing | 3.1.1 | Parsing |
| pyserial | 3.5 | Serial comm |
| python-dateutil | 2.8.2 | Dates |
| pytz | 2024.1 | Timezones |
| pywinrm | 0.4.3 | WinRM |
| PyYAML | 6.0.1 | YAML |
| requests | 2.31.0 | HTTP |
| requests-ntlm | 1.1.0 | Auth |
| rich | 13.7.1 | Terminal UI |
| setuptools | 68.1.2 | Build |
| simplejson | 3.19.2 | JSON |
| six | 1.16.0 | Compat |
| sqlparse | 0.4.2 | SQL parsing |
| terminator | 2.1.3 | Terminal |
| texttable | 1.6.7 | Tables |
| toml | 0.10.2 | Config |
| typing_extensions | 4.10.0 | Types |
| urllib3 | 2.0.7 | HTTP |
| vboxapi | 1.0 | VirtualBox |
| websocket-client | 1.7.0 | WebSocket |
| wheel | 0.42.0 | Build |
| xmltodict | 0.13.0 | XML |
| IPython | 9.8.0 | Interactive Python shell |
| jupyter | -- | Notebook environment |
| black | 25.12.0 | Code formatter |
| flake8 | 7.3.0 | Linter |
| pylint | 4.0.4 | Linter |
| mypy | 1.19.1 | Static type checker |
| pytest | 9.0.2 | Testing framework |
| Wfuzz | 3.1.0 | Web fuzzer |
| mitmproxy | 8.1.1 | HTTP proxy |

</details>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 11 │ NODE.js ECOSYSTEM
  └──────────────────────────────────────────────────────────────────────────┘
```

#### Runtime

| Package | Version |
|---|---|
| Node.js | 24.12.0 |
| npm | 11.6.2 |
| NVM | -- |
| pnpm | 10.26.1 (global) |
| Yarn | 1.22.22 (global) |
| TypeScript | 5.9.3 (global) |
| ts-node | 10.9.2 (global) |
| Nodemon | 3.1.11 (global) |
| PM2 | 6.0.14 (global) |
| Deno | 2.6.3 |
| Bun | 1.3.5 |
| @anthropic-ai/claude-code | 2.1.86 (global) |

#### NPM Global Packages

`commitizen`, `semantic-release`, `eslint`, `prettier`, `swagger-cli`, `graphql-cli`

<details>
<summary><b>apt-installed Node packages</b></summary>

`eslint` 6.4.0, `node-babel7`, `node-jest-debbundle`, `node-webpack-sources`,
`node-postcss`, `node-typescript` (tslib), `node-lodash`, `node-tap`,
`node-mocha` (tap-mocha-reporter), `node-semver`, `node-uuid`, `node-yaml`,
`node-ws`, `node-fetch`, `node-got`, `node-undici`, `handlebars`

</details>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 12 │ RUBY GEMS & RUST TOOLCHAIN
  └──────────────────────────────────────────────────────────────────────────┘
```

Ruby 3.2.2 (rbenv) / 4.0.0 (snap) with standard library gems:

`bundler` 4.0.2, `rake`, `irb`, `rdoc`, `test-unit`, `minitest`, `debug`,
`rbs`, `typeprof`, `json`, `openssl`, `yaml`, `csv`, `date`, `net-http`,
`net-ftp`, `net-imap`, `net-smtp`, `psych`, `rexml`, `erb`, `fiddle`,
`bigdecimal`, `racc`, `prism`, `reline`, `io-console`, `stringio`

#### Rails

| Tool | Version |
|---|---|
| rbenv | 1.3.2 |
| Rails | 8.1.1 |
| RubyGems | 3.4.10 |

#### Rust Toolchain

| Tool | Version |
|---|---|
| rustc | 1.92.0 |
| cargo | 1.92.0 |
| rustup | 1.28.2 |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 13 │ SNAP APPLICATIONS
  └──────────────────────────────────────────────────────────────────────────┘
```

<details>
<summary><b>Development Tools</b></summary>

| App | Version |
|---|---|
| VS Code | ddc367ed |
| VS Code Insiders | 00515ed0 |
| Android Studio (Koala) | 2024.1.1.11 |
| Eclipse | 2026-03 |
| IntelliJ IDEA Community | 2024.3.4.1 |
| IntelliJ IDEA Ultimate | 2024.3.4.1 |
| PyCharm Community | 2024.3.5 |
| PyCharm Professional | 2024.3.5 |
| CLion | 2024.3.5 |
| GoLand | 2024.3.5 |
| WebStorm | 2024.3.5 |
| PhpStorm | 2024.3.5 |
| RubyMine | 2024.3.5 |
| Rider | 2024.3.6 |
| RustRover | 2024.3.7 |
| DataGrip | 2024.3.3 |
| DataSpell | 2024.3.2 |
| Gradle | 8.14.4 |
| CMake | 4.3.1 |
| Kotlin | 2.3.20 |
| .NET SDK | 8.0.407 |
| Ruby | 4.0.0 |
| Terraform | 1.14.8 |
| Jenkins | 2.554 |
| kubectl | 1.34.6 |
| Minikube | 0.8.0 |
| GitHub CLI (gh) | 2.6.0 |
| PowerShell | 7.6.0 |
| Flutter Gallery | v2.8.1 |

</details>

<details>
<summary><b>API & Database Clients</b></summary>

| App | Version |
|---|---|
| Postman | 11.71.7 |
| Insomnia | 12.4.0 |
| DBeaver CE | 25.0.1 |
| Beekeeper Studio | 5.6.3 |
| Azure Storage Explorer | 1.42.0 |

</details>

<details>
<summary><b>Terminal & Communication</b></summary>

| App | Version |
|---|---|
| Alacritty | 0.16.1 |
| WaveTerm | 0.14.4 |
| Termius | 9.37.5 |
| Termius Beta | 9.37.6 |
| Remmina (RDP/VNC) | v1.4.41 |

</details>

<details>
<summary><b>Productivity & Browsers</b></summary>

| App | Version |
|---|---|
| Notion Desktop | 1.1.2 |
| MarkText | 0.17.1 |
| AppFlowy | 0.10.6 |
| OnlyOffice | 8.3.3 |
| Skype | 8.138.0 |
| Slack | 4.46.99 |
| Discord | 0.0.130 |
| Telegram | 6.6.2 |
| Session Desktop | 1.17.15 |
| Thunderbird | 140.9.0 |
| JetBrains Space | 2023.1.7 |
| Umbrello (UML) | 23.08.3 |
| Brave Browser | 1.88.136 |
| Firefox | 136.0.1 |
| Google Chrome | 143.0.7499.169 |
| Bruno | -- |

</details>

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 14 │ RUNNING SERVICES
  └──────────────────────────────────────────────────────────────────────────┘
```

```
  ┌──────────────────────────────────┬─────────────────────────┐
  │  Service                         │  Status                 │
  ├──────────────────────────────────┼─────────────────────────┤
  │  docker.service                  │  active/running         │
  │  mysql.service                   │  active/running         │
  │  nginx.service                   │  active/running         │
  │  postgresql@16-main.service      │  active/running         │
  │  redis-server.service            │  active/running         │
  │  ssh.service                     │  active/running         │
  │  mongodb.service                 │  active (exited)        │
  │  postgresql.service              │  active (exited — meta) │
  └──────────────────────────────────┴─────────────────────────┘
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 15 │ CLI & SYSTEM UTILITIES
  └──────────────────────────────────────────────────────────────────────────┘
```

| Tool | Version | Notes |
|---|---|---|
| git | 2.43.0 | Version control |
| nano | 7.2 | Terminal text editor |
| htop | 3.3.0 | Interactive process viewer |
| tree | 2.1.1 | Directory listing |
| unzip | -- | Archive extraction |
| zip | -- | Archive creation |
| tar | 1.35 | Archive tool |
| screen | 4.09.01 | Terminal multiplexer |
| jq | 1.7 | JSON processor |
| fd-find (fdfind) | 9.0.0 | Fast file finder |
| bat | 0.24.0 | `cat` with syntax highlighting |
| fzf | 0.44.1 | Fuzzy finder |
| ncdu | 1.19 | Disk usage analyzer |
| duf | -- | Disk usage / free (modern `df`) |
| eza | -- | Modern `ls` replacement |
| btop | 1.3.0 | Resource monitor |
| tldr | 3.4.0 | Simplified man pages |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 16 │ REVERSE ENGINEERING TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/radareorg/radareorg-icon.svg" alt="radare2" width="40" height="40" /> <img src="https://cdn.simpleicons.org/yara/0066CC" alt="YARA" width="40" height="40" />

| Tool | Version | Notes |
|---|---|---|
| radare2 | -- | Reverse engineering framework |
| rizin | -- | Radare2 fork |
| cutter | -- | GUI for radare2/rizin |
| binwalk | -- | Firmware analysis |
| foremost | -- | File carving |
| GDB | 15.0.50 | GNU debugger |
| pwndbg | -- | GDB plugin for exploit dev |
| Valgrind | 3.22.0 | Memory error detector |
| strace | 6.8 | System call tracer |
| ltrace | 0.7.3 | Library call tracer |
| strings | 2.42 | Extract strings from binaries |
| objdump | 2.42 | Object file disassembler |
| readelf | 2.42 | ELF file reader |
| nm | 2.42 | Symbol table tool |
| file | 5.45 | File type identifier |
| hexedit | -- | Hex editor |
| xxd | -- | Hex dump |
| ExifTool | -- | Metadata extraction |
| YARA | 4.5.0 | Malware pattern matching |
| APKTool | 2.7.0 | Android APK reverse engineering |
| jadx | -- | DEX to Java decompiler |
| dex2jar | -- | DEX to JAR converter |
| Ghidra | -- | NSA reverse engineering tool |
| Frida | -- | Dynamic instrumentation |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 17 │ WEB SECURITY & TESTING TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/nmaporg/nmaporg-icon.svg" alt="Nmap" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/wireshark/wireshark-icon.svg" alt="Wireshark" width="40" height="40" /> <img src="https://cdn.simpleicons.org/sqlmap/FF0000" alt="SQLMap" width="40" height="40" />

| Tool | Version | Notes |
|---|---|---|
| Nmap | 7.94SVN | Network scanner |
| Masscan | -- | Fast port scanner |
| Nikto | -- | Web server scanner |
| Dirb | -- | Directory brute-forcer |
| Gobuster | -- | Directory/DNS brute-forcer |
| Wfuzz | 3.1.0 | Web fuzzer |
| ffuf | -- | Fast web fuzzer |
| SQLMap | 1.8.4 | SQL injection tool |
| Wireshark | 4.2.2 | Network protocol analyser (GUI) |
| tshark | 4.2.2 | Wireshark CLI |
| tcpdump | 4.99.4 | Packet capture |
| socat | -- | Multipurpose relay |
| ProxyChains | -- | Proxy chain tool |
| mitmproxy | 8.1.1 | HTTP/S intercept proxy |
| HTTPie | 3.2.2 | HTTP client CLI |
| grpcurl | 1.8.9 | gRPC CLI client |
| evans | 0.10.11 | gRPC interactive client |
| DBeaver | 25.3.0 | Universal DB GUI |
| PlantUML | -- | Diagram generator |
| Protocol Buffers (protoc) | 3.21.12 | Protobuf compiler |
| OWASP ZAP | -- | Web app scanner |
| DirBuster | -- | Directory brute-forcer GUI |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 18 │ DEVSECOPS TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://cdn.simpleicons.org/aquasecurity/1904DA" alt="Trivy" width="40" height="40" /> <img src="https://cdn.simpleicons.org/gitleaks/F05032" alt="GitLeaks" width="40" height="40" />

| Tool | Version | Notes |
|---|---|---|
| Trivy | 0.68.2 | Container/IaC vulnerability scanner |
| Grype | 0.104.2 | Container image vulnerability scanner |
| Syft | 1.38.2 | SBOM generator |
| tfsec | -- | Terraform security scanner |
| GitLeaks | -- | Secret detection in git repos |
| TruffleHog | 3.63.7 | Secret scanning |
| Hadolint | 2.12.0 | Dockerfile linter |
| Kubesec | -- | Kubernetes security scanner |
| kube-bench | -- | CIS Kubernetes benchmark |
| pre-commit | 4.5.1 | Git pre-commit hook framework |
| Checkov | -- | IaC security scanner |
| Terrascan | -- | IaC scanner |
| Snyk CLI | -- | Vulnerability scanner |
| kube-hunter | -- | Kubernetes penetration testing |
| OWASP Dependency-Check | -- | Dependency vulnerability scanner |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 19 │ MONITORING & OBSERVABILITY
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/netdata/netdata-icon.svg" alt="Netdata" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/prometheusio/prometheusio-icon.svg" alt="Prometheus" width="40" height="40" />

| Tool | Version | Notes |
|---|---|---|
| Glances | 3.4.0.3 | System monitoring (web + CLI) |
| iotop | 0.6 | I/O usage monitor |
| iftop | -- | Network bandwidth monitor |
| nethogs | -- | Per-process network usage |
| ctop | -- | Container metrics top |
| dive | 0.11.0 | Docker image layer explorer |
| Netdata | -- | Real-time monitoring |
| Prometheus Node Exporter | -- | Metrics exporter |
| lazydocker | -- | Docker TUI |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 20 │ VPN & NETWORK TUNNELING
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/openvpn/openvpn-icon.svg" alt="OpenVPN" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/wireguard/wireguard-icon.svg" alt="WireGuard" width="40" height="40" />

| Tool | Version | Notes |
|---|---|---|
| OpenVPN | 2.6.14 | VPN client/server |
| WireGuard | 1.0.20210914 | Modern VPN |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 21 │ MEDIA & FILE TOOLS
  └──────────────────────────────────────────────────────────────────────────┘
```

| Tool | Version | Notes |
|---|---|---|
| FFmpeg | 6.1.1 | Video/audio processing |
| ImageMagick | 6.9.12 | Image manipulation |
| RAR | -- | RAR archive tool |
| unRAR | -- | RAR extraction |
| Flameshot | 12.1.0 | Screenshot tool |
| scrot | 1.10 | Screenshot CLI |
| Midnight Commander (mc) | 4.8.30 | Terminal file manager |
| Ranger | 1.9.3 | Terminal file manager |

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 22 │ BROWSERS & COMMUNICATION
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/google_chrome/google_chrome-icon.svg" alt="Chrome" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/firefox/firefox-icon.svg" alt="Firefox" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/brave/brave-icon.svg" alt="Brave" width="40" height="40" /> <img src="https://cdn.simpleicons.org/slack/4A154B" alt="Slack" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/telegram/telegram-icon.svg" alt="Telegram" width="40" height="40" /> <img src="https://cdn.simpleicons.org/notion/000000" alt="Notion" width="40" height="40" />

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │ 23 │ API CLIENTS
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://www.vectorlogo.zone/logos/getpostman/getpostman-icon.svg" alt="Postman" width="40" height="40" /> <img src="https://cdn.simpleicons.org/insomnia/4000BF" alt="Insomnia" width="40" height="40" /> <img src="https://cdn.simpleicons.org/dbeaver/372923" alt="DBeaver" width="40" height="40" />

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  CLOUD PROVIDERS                                                       │
  └──────────────────────────────────────────────────────────────────────────┘
```

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/amazonwebservices/amazonwebservices-original-wordmark.svg" alt="AWS" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/microsoft_azure/microsoft_azure-icon.svg" alt="Azure" width="40" height="40" /> <img src="https://www.vectorlogo.zone/logos/google_cloud/google_cloud-icon.svg" alt="GCP" width="40" height="40" />

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  CONTRIBUTING                                                          │
  └──────────────────────────────────────────────────────────────────────────┘
```

```bash
# 1. Fork the repository
# 2. Create a feature branch
git checkout -b feature/my-feature

# 3. Commit your changes
git commit -m 'Add some feature'

# 4. Push to the branch
git push origin feature/my-feature

# 5. Open a Pull Request
```

---

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  LICENSE                                                               │
  └──────────────────────────────────────────────────────────────────────────┘
```

This project is licensed under the MIT License.

---

<div align="center">

```
  ╔══════════════════════════════════════════════════════════════════════════╗
  ║                                                                        ║
  ║              Built by 0xBugatti                                        ║
  ║              github.com/0xBugatti                                      ║
  ║                                                                        ║
  ║              If this saved you hours of manual setup,                  ║
  ║              consider giving it a star.                                ║
  ║                                                                        ║
  ╚══════════════════════════════════════════════════════════════════════════╝
```

</div>
