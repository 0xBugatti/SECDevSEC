#!/usr/bin/env bash
# =============================================================================
# install_zorin.sh
# Full development stack installer for Zorin OS 17.x (Ubuntu 24.04 base)
# Run as root or with sudo: sudo bash install_zorin.sh
# =============================================================================

set -uo pipefail

# ── colour & TUI helpers ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
MAGENTA='\033[0;35m'; BLUE='\033[0;34m'; DIM='\033[2m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

_section_num=0
section_header() {
    ((_section_num++)) || true
    local title="$1"
    local num_label
    num_label=$(printf "%02d" "$_section_num")
    echo ""
    echo -e "${DIM}┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DIM}│${NC} ${MAGENTA}${BOLD}STEP ${num_label}${NC} ${DIM}│${NC} ${BOLD}${CYAN}${title}${NC}"
    echo -e "${DIM}└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
}

progress_bar() {
    local current=$1 total=$2 width=50
    local pct=$(( (current * 100) / total ))
    local filled=$(( (current * width) / total ))
    local empty=$(( width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    printf "  ${CYAN}[%s${NC}]${NC} ${BOLD}%3d%%${NC} (%d/%d)\r" "$bar" "$pct" "$current" "$total"
}

_spinner_pid=""
_start_spinner() {
    local msg="${1:-working}"
    tput civis 2>/dev/null || true
    (while true; do for c in "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"; do printf "\r  ${CYAN}%s${NC} %s" "$c" "$msg"; sleep 0.08; done; done) &
    _spinner_pid=$!
}

_stop_spinner() {
    if [[ -n "$_spinner_pid" ]] && kill -0 "$_spinner_pid" 2>/dev/null; then
        kill "$_spinner_pid" 2>/dev/null
        wait "$_spinner_pid" 2>/dev/null
        _spinner_pid=""
    fi
    tput cnorm 2>/dev/null || true
    printf "\r%80s\r" ""
}

print_splash() {
    clear 2>/dev/null || true
    echo -e "${CYAN}"
    cat <<'SPLASH'
    ╔══════════════════════════════════════════════════════════════════╗
    ║                                                                  ║
    ║     █████╗ ██╗   ██╗██████╗ ██████╗ ███████╗                     ║
    ║    ██╔══██╗██║   ██║██╔══██╗██╔══██╗██╔════╝                     ║
    ║    ███████║██║   ██║██████╔╝██████╔╝███████╗                     ║
    ║    ██╔══██║██║   ██║██╔══██╗██╔══██╗╚════██║                     ║
    ║    ██║  ██║╚██████╔╝██████╔╝██║  ██║███████║                     ║
    ║    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝                     ║
    ║                                                                  ║
    ║          ██████╗ ██████╗  █████╗ ███╗   ██╗██╗  ██╗              ║
    ║         ██╔════╝ ██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝              ║
    ║         ██║  ███╗██████╔╝███████║██╔██╗ ██║█████╔╝               ║
    ║         ██║   ██║██╔══██╗██╔══██║██║╚██╗██║██╔═██╗               ║
    ║         ╚██████╔╝██║  ██║██║  ██║██║ ╚████║██║  ██╗              ║
    ║          ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝              ║
    ║                                                                  ║
    ║           Zorin OS DevSecOps Provisioner  ·  Zorin OS 17.x          ║
    ║           Architecture-aware ·  amd64 + arm64                  ║
    ║                                                                  ║
    ╚══════════════════════════════════════════════════════════════════╝
SPLASH
    echo -e "${NC}"
    echo -e "  ${DIM}User:${NC}        ${BOLD}$REAL_USER${NC}"
    echo -e "  ${DIM}Home:${NC}        ${BOLD}$REAL_HOME${NC}"
    echo -e "  ${DIM}Kernel:${NC}      ${BOLD}$(uname -r)${NC}"
    echo -e "  ${DIM}Arch:${NC}        ${BOLD}$(uname -m)${NC}"
    echo -e "  ${DIM}Started:${NC}     ${BOLD}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "  ${DIM}Uptime:${NC}      ${BOLD}$(uptime -p 2>/dev/null || uptime)${NC}"
    echo ""
    echo -e "  ${YELLOW}This will install 217+ packages. Architecture: amd64 + arm64. Grab a coffee ...${NC}"
    echo ""
}

[[ $EUID -ne 0 ]] && die "Please run with sudo or as root."

export DEBIAN_FRONTEND=noninteractive

# ── OS Detection & Architecture ───────────────────────────────────────────────
if ! grep -qi "zorin" /etc/os-release 2>/dev/null; then
    die "This script is designed for Zorin OS only. For Ubuntu, use install_devstack.sh"
fi

SYSARCH=$(uname -m)
case "$SYSARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    *)       die "Unsupported architecture: $SYSARCH (only amd64 and arm64 are supported)" ;;
esac

ZORIN_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")
declare -A UBUNTU_CODEMAP=(
    [vera]="noble"    [warren]="noble"
    [vaela]="focal"   [groovy]="focal"
    [focal]="focal"   [noble]="noble"
)
UB_CODENAME="${UBUNTU_CODEMAP[$ZORIN_CODENAME]:-noble}"

info "Zorin OS detected: codename=${ZORIN_CODENAME} -> Ubuntu base=${UB_CODENAME} arch=${ARCH}"

REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
[[ -z "$REAL_USER" || "$REAL_USER" == "root" ]] && die "Run with sudo from a non-root user account."
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

print_splash

run_as_user() { sudo -u "$REAL_USER" bash -c "$1"; }

# ─────────────────────────────────────────────────────────────────────────────
# LOGGING INFRASTRUCTURE
# ─────────────────────────────────────────────────────────────────────────────

declare -a LOG_INSTALLED=()
declare -a LOG_FAILED=()
declare -a LOG_SKIPPED=()
declare -a LOG_WARNINGS=()
_INSTALL_START_TIME=$(date +%s)

_log_result() {
    local status="$1" name="$2" method="$3" detail="${4:-}"
    local entry
    entry=$(printf "%-40s %-14s %s" "$name" "$method" "$detail")
    case "$status" in
        ok)   LOG_INSTALLED+=("$entry") ;;
        fail) LOG_FAILED+=("$entry")    ;;
        skip) LOG_SKIPPED+=("$entry")   ;;
        warn) LOG_WARNINGS+=("$entry")  ;;
    esac
}

safe_apt() {
    local pkg="$1"
    if command -v "$pkg" &>/dev/null; then
        _log_result skip "$pkg" "apt" "already installed"
        return 0
    fi
    if apt-get install -y -qq "$pkg" 2>/tmp/_safe_apt_err.log; then
        _log_result ok "$pkg" "apt"
        return 0
    else
        local err
        err=$(head -3 /tmp/_safe_apt_err.log 2>/dev/null || echo "unknown")
        _log_result fail "$pkg" "apt" "$err"
        return 1
    fi
}

safe_apt_batch() {
    local pkgs=("$@")
    local failed=() installed=() skipped=()
    for pkg in "${pkgs[@]}"; do
        if command -v "${pkg%%/*}" &>/dev/null; then
            skipped+=("$pkg")
        else
            installed+=("$pkg")
        fi
    done
    if [[ ${#installed[@]} -gt 0 ]]; then
        if apt-get install -y -qq "${installed[@]}" 2>/tmp/_safe_apt_batch_err.log; then
            for pkg in "${installed[@]}"; do
                _log_result ok "$pkg" "apt"
            done
        else
            local err missing=()
            err=$(head -5 /tmp/_safe_apt_batch_err.log 2>/dev/null || echo "unknown")
            for pkg in "${installed[@]}"; do
                if dpkg -l "$pkg" &>/dev/null 2>&1; then
                    _log_result ok "$pkg" "apt"
                else
                    missing+=("$pkg")
                    _log_result fail "$pkg" "apt" "$err"
                fi
            done
        fi
    fi
    for pkg in "${skipped[@]}"; do
        _log_result skip "$pkg" "apt" "already installed"
    done
}

safe_snap() {
    local name="$1"; shift
    if command -v "$name" &>/dev/null || snap list "$name" &>/dev/null 2>&1; then
        _log_result skip "$name" "snap" "already installed"
        return 0
    fi
    if snap install "$name" "$@" 2>/tmp/_safe_snap_err.log; then
        _log_result ok "$name" "snap"
        return 0
    else
        local err
        err=$(head -3 /tmp/_safe_snap_err.log 2>/dev/null || echo "unknown")
        _log_result fail "$name" "snap" "$err"
        return 1
    fi
}

safe_pip() {
    local name="$1"
    if pip3 show "$name" &>/dev/null 2>&1; then
        _log_result skip "$name" "pip3" "already installed"
        return 0
    fi
    if pip3 install --break-system-packages --ignore-installed "$name" 2>/tmp/_safe_pip_err.log; then
        _log_result ok "$name" "pip3"
        return 0
    else
        local err
        err=$(tail -5 /tmp/_safe_pip_err.log 2>/dev/null || echo "unknown")
        _log_result fail "$name" "pip3" "$err"
        return 1
    fi
}

safe_npm() {
    local name="$1"
    if npm list -g "$name" &>/dev/null 2>&1; then
        _log_result skip "$name" "npm" "already installed"
        return 0
    fi
    if npm install -g "$name" 2>/tmp/_safe_npm_err.log; then
        _log_result ok "$name" "npm"
        return 0
    else
        local err
        err=$(tail -3 /tmp/_safe_npm_err.log 2>/dev/null || echo "unknown")
        _log_result fail "$name" "npm" "$err"
        return 1
    fi
}

safe_curl() {
    local name="$1" url="$2" dest="$3"; shift 3
    if command -v "$name" &>/dev/null; then
        _log_result skip "$name" "curl-binary" "already installed"
        return 0
    fi
    if curl -fsSL "$url" -o "$dest" "$@" 2>/tmp/_safe_curl_err.log && [[ -f "$dest" ]]; then
        _log_result ok "$name" "curl-binary" "$url"
        return 0
    else
        local err
        err=$(cat /tmp/_safe_curl_err.log 2>/dev/null || echo "download failed")
        _log_result fail "$name" "curl-binary" "$err"
        return 1
    fi
}

safe_curl_pipe() {
    local name="$1" url="$2"; shift 2
    if command -v "$name" &>/dev/null; then
        _log_result skip "$name" "curl|pipe" "already installed"
        return 0
    fi
    if curl -fsSL "$url" | sh 2>/tmp/_safe_curlpipe_err.log; then
        _log_result ok "$name" "curl|pipe" "$url"
        return 0
    else
        local err
        err=$(tail -5 /tmp/_safe_curlpipe_err.log 2>/dev/null || echo "script failed")
        _log_result fail "$name" "curl|pipe" "$err"
        return 1
    fi
}

safe_git_clone() {
    local name="$1" repo="$2" dest="$3"; shift 3
    if [[ -d "$dest" ]]; then
        _log_result skip "$name" "git-clone" "already exists"
        return 0
    fi
    if git clone "$repo" "$dest" "$@" 2>/tmp/_safe_git_err.log; then
        _log_result ok "$name" "git-clone" "$repo"
        return 0
    else
        local err
        err=$(cat /tmp/_safe_git_err.log 2>/dev/null || echo "clone failed")
        _log_result fail "$name" "git-clone" "$err"
        return 1
    fi
}

safe_dpkg() {
    local name="$1" deb="$2"; shift 2
    if command -v "$name" &>/dev/null; then
        _log_result skip "$name" "dpkg" "already installed"
        return 0
    fi
    if dpkg -i "$deb" 2>/tmp/_safe_dpkg_err.log; then
        _log_result ok "$name" "dpkg" "$deb"
        return 0
    else
        local err
        err=$(cat /tmp/_safe_dpkg_err.log 2>/dev/null || echo "install failed")
        _log_result fail "$name" "dpkg" "$err"
        apt-get install -y -f -qq 2>/dev/null || true
        return 1
    fi
}

safe_systemctl() {
    local service="$1" action="$2"
    if systemctl "$action" "$service" 2>/tmp/_safe_systemctl_err.log; then
        return 0
    else
        local err
        err=$(cat /tmp/_safe_systemctl_err.log 2>/dev/null || echo "systemctl $action failed")
        warn "systemctl $action $service: $err"
        _log_result warn "$service" "systemctl" "$action: $err"
        return 1
    fi
}

print_summary_table() {
    local elapsed=$(( $(date +%s) - _INSTALL_START_TIME ))
    local mins=$(( elapsed / 60 ))
    local secs=$(( elapsed % 60 ))
    local total=$(( ${#LOG_INSTALLED[@]} + ${#LOG_FAILED[@]} + ${#LOG_SKIPPED[@]} ))
    local pct=0
    [[ $total -gt 0 ]] && pct=$(( (${#LOG_INSTALLED[@]} * 100) / total ))

    echo ""
    echo -e "${DIM}╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${DIM}║${NC}  ${BOLD}INSTALLATION SUMMARY${NC}                                                                          ${DIM}║${NC}"
    echo -e "${DIM}╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${DIM}║${NC}  Elapsed: ${BOLD}${mins}m ${secs}s${NC}   Steps completed: ${BOLD}${_section_num}${NC}                                           ${DIM}║${NC}"
    echo -e "${DIM}╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"

    local status_line=""
    if [[ ${#LOG_FAILED[@]} -eq 0 ]]; then
        status_line="  ${GREEN}${BOLD}ALL PACKAGES RESOLVED${NC}"
    else
        status_line="  ${RED}${BOLD}${#LOG_FAILED[@]} PACKAGE(S) FAILED${NC} -- review logs below"
    fi
    echo -e "${DIM}║${NC}  ${GREEN}${BOLD}INSTALLED${NC} ${BOLD}${#LOG_INSTALLED[@]}${NC}  ${RED}${BOLD}FAILED${NC} ${BOLD}${#LOG_FAILED[@]}${NC}  ${YELLOW}${BOLD}SKIPPED${NC} ${BOLD}${#LOG_SKIPPED[@]}${NC}  ${YELLOW}${BOLD}WARNINGS${NC} ${BOLD}${#LOG_WARNINGS[@]}${NC}  ${status_line}${DIM}║${NC}"
    echo -e "${DIM}╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣${NC}"

    progress_bar "${#LOG_INSTALLED[@]}" "$total"
    echo ""
    echo -e "${DIM}║${NC}  Success rate: ${BOLD}${pct}%${NC}  ${CYAN}████████████████████████████████████████████████████████████████████${NC}  ${DIM}║${NC}"
    echo -e "${DIM}╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ ${#LOG_FAILED[@]} -gt 0 ]]; then
        echo -e "  ${RED}┌─ FAILED (${#LOG_FAILED[@]}) ─────────────────────────────────────────────────────────────────────────────┐${NC}"
        printf "  ${RED}│${NC}  %-40s %-14s %s${RED}│${NC}\n" "PACKAGE" "METHOD" "DETAIL"
        echo -e "  ${RED}├────────────────────────────────────────────────────────────────────────────────────────────────────────┤${NC}"
        for entry in "${LOG_FAILED[@]}"; do
            printf "  ${RED}│${NC}  %-40s %-14s %s${RED}│${NC}\n" $entry
        done
        echo -e "  ${RED}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    if [[ ${#LOG_WARNINGS[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}┌─ WARNINGS (${#LOG_WARNINGS[@]}) ──────────────────────────────────────────────────────────────────────┐${NC}"
        printf "  ${YELLOW}│${NC}  %-40s %-14s %s${YELLOW}│${NC}\n" "PACKAGE" "METHOD" "DETAIL"
        echo -e "  ${YELLOW}├────────────────────────────────────────────────────────────────────────────────────────────────────────┤${NC}"
        for entry in "${LOG_WARNINGS[@]}"; do
            printf "  ${YELLOW}│${NC}  %-40s %-14s %s${YELLOW}│${NC}\n" $entry
        done
        echo -e "  ${YELLOW}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    if [[ ${#LOG_SKIPPED[@]} -gt 0 ]]; then
        echo -e "  ${DIM}┌─ SKIPPED (${#LOG_SKIPPED[@]}) ────────────────────────────────────────────────────────────────────────┐${NC}"
        printf "  ${DIM}│${NC}  %-40s %-14s %s${DIM}│${NC}\n" "PACKAGE" "METHOD" "DETAIL"
        echo -e "  ${DIM}├────────────────────────────────────────────────────────────────────────────────────────────────────────┤${NC}"
        for entry in "${LOG_SKIPPED[@]}"; do
            printf "  ${DIM}│${NC}  %-40s %-14s %s${DIM}│${NC}\n" $entry
        done
        echo -e "  ${DIM}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    if [[ ${#LOG_INSTALLED[@]} -gt 0 ]]; then
        echo -e "  ${GREEN}┌─ INSTALLED (${#LOG_INSTALLED[@]}) ─────────────────────────────────────────────────────────────────────┐${NC}"
        printf "  ${GREEN}│${NC}  %-40s %-14s %s${GREEN}│${NC}\n" "PACKAGE" "METHOD" "DETAIL"
        echo -e "  ${GREEN}├────────────────────────────────────────────────────────────────────────────────────────────────────────┤${NC}"
        for entry in "${LOG_INSTALLED[@]}"; do
            printf "  ${GREEN}│${NC}  %-40s %-14s %s${GREEN}│${NC}\n" $entry
        done
        echo -e "  ${GREEN}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi

    if [[ ${#LOG_FAILED[@]} -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}  ✓  Zero failures. VM is ready.${NC}"
    else
        echo -e "  ${RED}Full error logs: /tmp/_safe_apt_err.log  /tmp/_safe_snap_err.log  /tmp/_safe_pip_err.log  /tmp/_safe_npm_err.log${NC}"
    fi
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# APT SOURCE MANAGER -- validates & auto-pulls missing sources
# ─────────────────────────────────────────────────────────────────────────────

declare -A APT_SOURCES_REGISTRY=(
    [gierens]="deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main"
    [sublimehq]="deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/"
    [nodesource]=""
    [mongodb]="deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse"
    [caddy]="deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main"
    [docker]=""
    [hashicorp]="deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $UB_CODENAME main"
    [gitlab-runner]=""
    [github-cli]=""
    [google-cloud]="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"
    [trivy]="deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main"
)

APT_SOURCES_LOG=()

ensure_apt_source() {
    local source_name="$1"
    local source_list_file="${2:-}"
    local gpg_url="${3:-}"
    local gpg_dest="${4:-}"
    local repo_line="${5:-}"

    if [[ -z "$source_list_file" ]]; then
        source_list_file="/etc/apt/sources.list.d/${source_name}.list"
    fi

    if [[ -f "$source_list_file" ]] && grep -q "signed-by" "$source_list_file" 2>/dev/null; then
        APT_SOURCES_LOG+=("skip $source_name (already configured)")
        return 0
    fi

    if [[ -n "$gpg_url" && -n "$gpg_dest" ]]; then
        mkdir -p "$(dirname "$gpg_dest")"
        if curl -fsSL "$gpg_url" 2>/dev/null | gpg --dearmor -o "$gpg_dest" 2>/dev/null; then
            chmod 644 "$gpg_dest"
        else
            APT_SOURCES_LOG+=("warn $source_name (GPG key fetch failed)")
            return 1
        fi
    fi

    if [[ -n "$repo_line" ]]; then
        echo "$repo_line" > "$source_list_file"
        chmod 644 "$source_list_file"
    fi

    APT_SOURCES_LOG+=("ok $source_name (added)")
    return 0
}

check_all_sources() {
    echo ""
    info "Checking and configuring APT sources..."
    echo ""

    local _sources_ok=0 _sources_added=0 _sources_failed=0

    ensure_apt_source "gierens" \
        "/etc/apt/sources.list.d/gierens.list" \
        "https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" \
        "/etc/apt/keyrings/gierens.gpg" \
        "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "sublimehq" \
        "/etc/apt/sources.list.d/sublime-text.list" \
        "https://download.sublimetext.com/sublimehq-pub.gpg" \
        "/etc/apt/keyrings/sublimehq-pub.gpg" \
        "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "nodesource" \
        "/etc/apt/sources.list.d/nodesource.list" \
        "" "" "" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "mongodb" \
        "/etc/apt/sources.list.d/mongodb-org-8.0.list" \
        "https://www.mongodb.org/static/pgp/server-8.0.asc" \
        "/usr/share/keyrings/mongodb-server-8.0.gpg" \
        "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "caddy" \
        "/etc/apt/sources.list.d/caddy-stable.list" \
        "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" \
        "/usr/share/keyrings/caddy-stable-archive-keyring.gpg" \
        "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "docker" \
        "/etc/apt/sources.list.d/docker.list" \
        "https://download.docker.com/linux/ubuntu/gpg" \
        "/etc/apt/keyrings/docker.asc" \
        "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UB_CODENAME stable" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "hashicorp" \
        "/etc/apt/sources.list.d/hashicorp.list" \
        "https://apt.releases.hashicorp.com/gpg" \
        "/usr/share/keyrings/hashicorp-archive-keyring.gpg" \
        "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $UB_CODENAME main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "github-cli" \
        "/etc/apt/sources.list.d/github-cli.list" \
        "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
        "/usr/share/keyrings/githubcli-archive-keyring.gpg" \
        "deb [arch=$ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "google-cloud" \
        "/etc/apt/sources.list.d/google-cloud-sdk.list" \
        "https://packages.cloud.google.com/apt/doc/apt-key.gpg" \
        "/usr/share/keyrings/cloud.google.gpg" \
        "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "trivy" \
        "/etc/apt/sources.list.d/trivy.list" \
        "https://aquasecurity.github.io/trivy-repo/deb/public.key" \
        "/usr/share/keyrings/trivy.gpg" \
        "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
        && ((_sources_ok++)) || ((_sources_failed++))

    ensure_apt_source "gitlab-runner" \
        "/etc/apt/sources.list.d/runner_gitlab-runner.list" \
        "" "" "" \
        && ((_sources_ok++)) || ((_sources_failed++))

    echo ""
    echo -e "${BOLD}  APT Sources Status:${NC}"
    for entry in "${APT_SOURCES_LOG[@]}"; do
        local tag entry_val
        tag="${entry%% *}"
        entry_val="${entry#* }"
        case "$tag" in
            ok)   echo -e "    ${GREEN}[OK]${NC}    $entry_val" ;;
            skip) echo -e "    ${YELLOW}[SKIP]${NC}  $entry_val" ;;
            warn) echo -e "    ${YELLOW}[WARN]${NC}  $entry_val" ;;
        esac
    done
    echo ""

    info "Running apt-get update after source configuration..."
    apt-get update -qq 2>/dev/null || warn "apt-get update returned non-zero -- continuing"
    echo ""
}

trap 'echo -e "\n${RED}[TRAP]${NC} Script interrupted. Printing summary before exit..."; print_summary_table; exit 130' INT TERM

# ─────────────────────────────────────────────────────────────────────────────
# 0. SYSTEM UPDATE
# ─────────────────────────────────────────────────────────────────────────────
section_header "SYSTEM UPDATE"
info "Updating system packages..."
apt-get update -qq 2>/dev/null || warn "apt-get update had issues -- continuing"
apt-get upgrade -y -qq 2>/dev/null || warn "apt-get upgrade had issues -- continuing"
safe_apt_batch apt-transport-https ca-certificates gnupg lsb-release curl wget software-properties-common snapd
success "System updated."

check_all_sources

# ─────────────────────────────────────────────────────────────────────────────
# 1. BUILD ESSENTIALS & CORE DEV TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "BUILD ESSENTIALS & CORE DEV TOOLS"
info "Installing build essentials and core dev tools..."
safe_apt_batch build-essential gcc g++ binutils automake make gdb strace ltrace valgrind xxd \
    libssl-dev libpcap-dev libpcre2-dev libffi-dev libreadline-dev \
    zlib1g-dev libbz2-dev libsqlite3-dev libncurses-dev liblzma-dev \
    libgdbm-dev uuid-dev libpq-dev node-gyp \
    clang libclang-dev libclang-cpp-dev \
    gyp erlang-jinterface erlang-mode libkrb5-dev
success "Build essentials installed."

# ─────────────────────────────────────────────────────────────────────────────
# 2. CLI & SYSTEM UTILITIES
# ─────────────────────────────────────────────────────────────────────────────
section_header "CLI & SYSTEM UTILITIES"
info "Installing CLI and system utilities..."
safe_apt_batch nano vim vim-common vim-runtime neovim screen tmux git git-lfs \
    htop tree ncdu jq fzf bat fd-find unzip zip tar file hexedit \
    mc ranger direnv mtr-tiny exiftool terminator

safe_apt eza || {
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        > /etc/apt/sources.list.d/gierens.list
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
    apt-get update -qq 2>/dev/null || true
    safe_apt eza || true
}

safe_apt btop || safe_snap btop --classic || true

if ! command -v duf &>/dev/null; then
    DUF_VER="0.8.1"
    safe_curl duf "https://github.com/muesli/duf/releases/download/v${DUF_VER}/duf_${DUF_VER}_linux_${ARCH}.deb" /tmp/duf.deb && \
        safe_dpkg duf /tmp/duf.deb && rm -f /tmp/duf.deb || true
fi

safe_pip tldr || true
git lfs install --system 2>/dev/null || true

safe_apt sublime-text || {
    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg \
        | gpg --dearmor -o /etc/apt/keyrings/sublimehq-pub.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" \
        > /etc/apt/sources.list.d/sublime-text.list
    chmod 644 /etc/apt/keyrings/sublimehq-pub.gpg /etc/apt/sources.list.d/sublime-text.list 2>/dev/null || true
    apt-get update -qq 2>/dev/null || true
    safe_apt sublime-text || true
}

success "CLI utilities installed."

# ─────────────────────────────────────────────────────────────────────────────
# 3. LANGUAGES & RUNTIMES
# ─────────────────────────────────────────────────────────────────────────────
section_header "LANGUAGES & RUNTIMES"

# ── Python 3 ──────────────────────────────────────────────────────────────────
info "Installing Python 3.12..."
safe_apt_batch python3 python3-dev python3-pip python3-venv python3-setuptools python3-wheel \
    python3.12 python3.12-dev python3.12-venv python3.12-minimal python3-full
success "Python 3.12 installed."

# ── pyenv (user-level) ────────────────────────────────────────────────────────
info "Installing pyenv for $REAL_USER..."
if [[ ! -d "$REAL_HOME/.pyenv" ]]; then
    run_as_user 'curl -fsSL https://pyenv.run | bash' 2>/dev/null && \
        _log_result ok "pyenv" "curl|pipe" "user install" || \
        _log_result fail "pyenv" "curl|pipe" "install failed"
else
    _log_result skip "pyenv" "curl|pipe" "already installed"
fi
success "pyenv installed."

# ── bcc (BPF Compiler Collection) ────────────────────────────────────────────
info "Installing BPF tools..."
safe_apt_batch bpfcc-tools python3-bpfcc || true
safe_apt "linux-headers-$(uname -r)" || warn "linux-headers for $(uname -r) not available"
success "bcc/bpfcc installed."

# ── pipenv & poetry ───────────────────────────────────────────────────────────
info "Installing pipenv and poetry..."
safe_pip pipenv || true
if ! run_as_user 'command -v poetry &>/dev/null'; then
    run_as_user 'curl -sSL https://install.python-poetry.org | python3 -' 2>/dev/null && \
        _log_result ok "poetry" "curl|pipe" "user install" || \
        _log_result fail "poetry" "curl|pipe" "install failed"
else
    _log_result skip "poetry" "curl|pipe" "already installed"
fi
success "pipenv and poetry installed."

# ── Node.js 22 LTS (via NodeSource) ──────────────────────────────────────────
info "Installing Node.js 22 LTS..."
if ! command -v node &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - 2>/dev/null || true
    apt-get update -qq 2>/dev/null || true
    safe_apt nodejs
else
    _log_result skip "nodejs" "apt" "already installed"
fi
success "Node.js $(node -v 2>/dev/null || echo '?') + npm $(npm -v 2>/dev/null || echo '?') installed."

# ── NVM (user-level) ──────────────────────────────────────────────────────────
info "Installing NVM for $REAL_USER..."
if [[ ! -d "$REAL_HOME/.nvm" ]]; then
    run_as_user 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash' 2>/dev/null && \
        _log_result ok "nvm" "curl|pipe" "user install" || \
        _log_result fail "nvm" "curl|pipe" "install failed"
else
    _log_result skip "nvm" "curl|pipe" "already installed"
fi
success "NVM installed."

# ── Go 1.22 ───────────────────────────────────────────────────────────────────
info "Installing Go 1.22..."
safe_apt_batch golang-1.22-go golang-go golang-src
GO_VER=$(dpkg -s golang-1.22-go 2>/dev/null | grep '^Version' | awk '{print $2}' || echo '?')
success "Go ${GO_VER} installed. Binaries at /usr/lib/go-1.22/bin -- add to PATH if needed."

# ── Go ecosystem tools ────────────────────────────────────────────────────────
info "Installing Go ecosystem tools..."
export PATH="$PATH:/usr/lib/go-1.22/bin"
if command -v go &>/dev/null; then
    if ! command -v golangci-lint &>/dev/null; then
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null && \
            _log_result ok "golangci-lint" "go-install" || \
            _log_result fail "golangci-lint" "go-install" "build failed"
    else
        _log_result skip "golangci-lint" "go-install" "already installed"
    fi
    if ! command -v gopls &>/dev/null; then
        go install golang.org/x/tools/gopls@latest 2>/dev/null && \
            _log_result ok "gopls" "go-install" || \
            _log_result fail "gopls" "go-install" "build failed"
    else
        _log_result skip "gopls" "go-install" "already installed"
    fi
fi
success "golangci-lint and gopls installed."

# ── Rust (user-level via rustup) ──────────────────────────────────────────────
info "Installing Rust for $REAL_USER..."
if [[ ! -d "$REAL_HOME/.rustup" ]]; then
    run_as_user 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y' 2>/dev/null && \
        _log_result ok "rustup" "curl|pipe" "user install" || \
        _log_result fail "rustup" "curl|pipe" "install failed"
else
    _log_result skip "rustup" "curl|pipe" "already installed"
fi
success "Rust (rustc + cargo + rustup) installed."

# ── Deno (user-level) ─────────────────────────────────────────────────────────
info "Installing Deno for $REAL_USER..."
if ! run_as_user 'command -v deno &>/dev/null'; then
    run_as_user 'curl -fsSL https://deno.land/install.sh | sh' 2>/dev/null && \
        _log_result ok "deno" "curl|pipe" "user install" || \
        _log_result fail "deno" "curl|pipe" "install failed"
else
    _log_result skip "deno" "curl|pipe" "already installed"
fi
success "Deno installed."

# ── Bun (user-level) ──────────────────────────────────────────────────────────
info "Installing Bun for $REAL_USER..."
if ! run_as_user 'command -v bun &>/dev/null'; then
    run_as_user 'curl -fsSL https://bun.sh/install | bash' 2>/dev/null && \
        _log_result ok "bun" "curl|pipe" "user install" || \
        _log_result fail "bun" "curl|pipe" "install failed"
else
    _log_result skip "bun" "curl|pipe" "already installed"
fi
success "Bun installed."

# ── PHP 8.3 ───────────────────────────────────────────────────────────────────
info "Installing PHP 8.3..."
safe_apt_batch php php8.3 php8.3-cli php8.3-common php8.3-curl php8.3-gd php8.3-mbstring \
    php8.3-mcrypt php8.3-mysql php8.3-opcache php8.3-readline php8.3-xml php8.3-zip \
    php-bz2 php-common \
    php-psr-log php-psr-cache php-psr-http-message \
    php-twig php-tcpdf php-nikic-fast-route php-slim-psr7 \
    php-symfony-cache php-symfony-dependency-injection \
    php-composer-ca-bundle
if ! command -v composer &>/dev/null; then
    curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 2>/dev/null && \
        _log_result ok "composer" "curl|php" || \
        _log_result fail "composer" "curl|php" "install failed"
else
    _log_result skip "composer" "curl|php" "already installed"
fi
success "PHP 8.3 + Composer installed."

# ── Perl 5 ────────────────────────────────────────────────────────────────────
info "Installing Perl 5..."
safe_apt_batch perl perl-modules-5.38 libperl5.38t64
success "Perl $(perl -e 'print $^V' 2>/dev/null || echo '?') installed."

# ── Lua ───────────────────────────────────────────────────────────────────────
info "Installing Lua..."
safe_apt_batch lua5.3 lua5.4 liblua5.4-0
success "Lua installed."
#--VM Tools#
info "Installing VMware guest tools..."
safe_apt_batch open-vm-tools-desktop open-vm-tools
success "VMware Tools: $(vmtoolsd -v 2>/dev/null || echo 'installed')"

# ── Java 17 (JDK) ─────────────────────────────────────────────────────────────
info "Installing OpenJDK 17..."
safe_apt_batch openjdk-17-jdk openjdk-17-jre openjdk-17-jre-headless
success "Java: $(java -version 2>&1 | head -1)"

# ── Ruby + rbenv + Rails ──────────────────────────────────────────────────────
info "Installing Ruby..."
safe_apt_batch ruby ruby-dev ruby-bundler libyaml-dev
if [[ ! -d "$REAL_HOME/.rbenv" ]]; then
    safe_git_clone "rbenv" "https://github.com/rbenv/rbenv.git" "$REAL_HOME/.rbenv" --depth=1
    safe_git_clone "ruby-build" "https://github.com/rbenv/ruby-build.git" "$REAL_HOME/.rbenv/plugins/ruby-build" --depth=1
else
    _log_result skip "rbenv" "git-clone" "already exists"
fi
if ! command -v rails &>/dev/null; then
    gem install rails 2>/dev/null && _log_result ok "rails" "gem" || _log_result fail "rails" "gem" "install failed"
else
    _log_result skip "rails" "gem" "already installed"
fi
success "Ruby + rbenv + Rails installed."

# ─────────────────────────────────────────────────────────────────────────────
# 4. DATABASES
# ─────────────────────────────────────────────────────────────────────────────
section_header "DATABASES"

info "Installing MySQL 8.0..."
safe_apt_batch mysql-server mysql-client
safe_systemctl mysql enable --now
success "MySQL installed."

info "Installing PostgreSQL 16..."
safe_apt_batch postgresql postgresql-contrib postgresql-client libpq-dev
safe_systemctl postgresql enable --now
success "PostgreSQL installed."

info "Installing MongoDB 8.0..."
if ! dpkg -l | grep -q mongodb-org 2>/dev/null; then
    apt-get update -qq 2>/dev/null || true
    safe_apt_batch mongodb-org mongodb-mongosh mongodb-database-tools || \
        _log_result fail "mongodb-org" "apt" "repo may not be available"
else
    _log_result skip "mongodb-org" "apt" "already installed"
fi
safe_systemctl mongod enable --now || true
success "MongoDB installed."

info "Installing Redis 7..."
safe_apt_batch redis-server redis-tools
safe_systemctl redis-server enable --now
success "Redis installed."

info "Installing SQLite3..."
safe_apt_batch sqlite3 libsqlite3-dev
success "SQLite3 installed."

info "Installing phpMyAdmin..."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true"          | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/app-password-confirm password ''"       | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ''"           | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/mysql/app-pass password ''"             | debconf-set-selections 2>/dev/null || true
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections 2>/dev/null || true
safe_apt phpmyadmin
success "phpMyAdmin installed."

# ─────────────────────────────────────────────────────────────────────────────
# 5. WEB SERVERS & PROXIES
# BUG: nginx and Apache2 both default to port 80 -- conflict.
#      Apache2 is installed but NOT auto-started.
# ─────────────────────────────────────────────────────────────────────────────
section_header "WEB SERVERS & PROXIES"
info "Installing web servers..."
safe_apt_batch nginx apache2 apache2-utils libapache2-mod-php8.3
safe_systemctl nginx enable --now
safe_systemctl apache2 enable || true
warn "Apache2 installed but NOT started -- nginx holds port 80."
warn "Edit /etc/apache2/ports.conf (e.g. port 8080) then: systemctl start apache2"

info "Installing Certbot..."
safe_apt_batch certbot python3-certbot-nginx python3-certbot-apache
success "Certbot installed."

info "Installing Caddy..."
safe_apt caddy || {
    curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
        | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" \
        > /etc/apt/sources.list.d/caddy-stable.list
    apt-get update -qq 2>/dev/null || true
    safe_apt caddy || true
}
success "Caddy installed."

info "Installing FTP tools..."
safe_apt_batch vsftpd filezilla
success "vsftpd and FileZilla installed."

success "Web servers installed."

# ─────────────────────────────────────────────────────────────────────────────
# 6. CONTAINERS & ORCHESTRATION
# ─────────────────────────────────────────────────────────────────────────────
section_header "CONTAINERS & ORCHESTRATION"
info "Installing Docker..."
if ! command -v docker &>/dev/null; then
    install -m 0755 -d /etc/apt/keyrings 2>/dev/null || true
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc 2>/dev/null || true
    chmod a+r /etc/apt/keyrings/docker.asc 2>/dev/null || true
    echo \
      "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $UB_CODENAME stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -qq 2>/dev/null || true
    safe_apt_batch docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    _log_result skip "docker" "apt" "already installed"
fi
safe_systemctl docker enable --now
[[ -n "$REAL_USER" ]] && usermod -aG docker "$REAL_USER" 2>/dev/null || true
success "Docker $(docker --version 2>/dev/null || echo '?') installed."

info "Installing docker-compose (legacy v1 style)..."
safe_apt docker-compose || safe_pip docker-compose || true
success "docker-compose installed."

info "Installing ctop..."
if ! command -v ctop &>/dev/null; then
    CTOP_VER="0.7.7"
    safe_curl ctop "https://github.com/bcicen/ctop/releases/download/v${CTOP_VER}/ctop-${CTOP_VER}-linux-${ARCH}" /usr/local/bin/ctop && \
        chmod +x /usr/local/bin/ctop 2>/dev/null || true
else
    _log_result skip "ctop" "curl-binary" "already installed"
fi
success "ctop installed."

info "Installing dive..."
if ! command -v dive &>/dev/null; then
    DIVE_VER="0.11.0"
    safe_curl dive "https://github.com/wagoodman/dive/releases/download/v${DIVE_VER}/dive_${DIVE_VER}_linux_${ARCH}.deb" /tmp/dive.deb && \
        safe_dpkg dive /tmp/dive.deb && rm -f /tmp/dive.deb || true
else
    _log_result skip "dive" "curl-binary" "already installed"
fi
success "dive installed."

# ─────────────────────────────────────────────────────────────────────────────
# 7. CI/CD & DEVOPS TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "CI/CD & DEVOPS TOOLS"
info "Installing Ansible..."
safe_apt_batch ansible ansible-core
success "Ansible $(ansible --version 2>/dev/null | head -1 || echo '?') installed."

info "Installing Terraform and Packer..."
safe_apt terraform || {
    curl -fsSL https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $UB_CODENAME main" \
        > /etc/apt/sources.list.d/hashicorp.list
    apt-get update -qq 2>/dev/null || true
    safe_apt terraform || true
}
safe_apt packer || {
    apt-get update -qq 2>/dev/null || true
    safe_apt packer || true
}
success "Terraform and Packer installed."

info "Installing Vagrant..."
safe_apt vagrant || safe_snap vagrant --classic || true
success "Vagrant installed."

info "Installing GitLab Runner..."
if ! command -v gitlab-runner &>/dev/null; then
    curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash 2>/dev/null || true
    apt-get update -qq 2>/dev/null || true
    safe_apt gitlab-runner || curl -L "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-${ARCH}" -o /usr/local/bin/gitlab-runner && chmod +x /usr/local/bin/gitlab-runner 2>/dev/null && _log_result ok "gitlab-runner" "curl-binary" || true
else
    _log_result skip "gitlab-runner" "apt" "already installed"
fi
success "GitLab Runner installed."

info "Installing GitHub CLI..."
safe_apt gh || {
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null || true
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
    apt-get update -qq 2>/dev/null || true
    safe_apt gh || true
}
success "gh $(gh --version 2>/dev/null | head -1 || echo '?') installed."

info "Installing ArgoCD CLI..."
if ! command -v argocd &>/dev/null; then
    ARGOCD_VER=$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$ARGOCD_VER" ]]; then
        curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VER}/argocd-linux-${ARCH}" \
            -o /usr/local/bin/argocd 2>/dev/null && chmod +x /usr/local/bin/argocd 2>/dev/null && \
            _log_result ok "argocd" "curl-binary" "$ARGOCD_VER" || \
            _log_result fail "argocd" "curl-binary" "download failed"
    else
        _log_result fail "argocd" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "argocd" "curl-binary" "already installed"
fi
success "ArgoCD CLI installed."

info "Installing Flux CLI..."
safe_curl_pipe flux "https://fluxcd.io/install.sh" || true
success "Flux CLI installed."

info "Installing Skaffold..."
if ! command -v skaffold &>/dev/null; then
    curl -fsSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-${ARCH} \
        -o /usr/local/bin/skaffold 2>/dev/null && chmod +x /usr/local/bin/skaffold 2>/dev/null && \
        _log_result ok "skaffold" "curl-binary" || \
        _log_result fail "skaffold" "curl-binary" "download failed"
else
    _log_result skip "skaffold" "curl-binary" "already installed"
fi
success "Skaffold installed."

info "Installing Tilt..."
safe_curl_pipe tilt "https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh" || true
success "Tilt installed."

info "Installing Telepresence..."
if ! command -v telepresence &>/dev/null; then
    curl -fsSL "https://app.getambassador.io/download/tel2oss/releases/latest/telepresence-linux-${ARCH}" \
        -o /usr/local/bin/telepresence 2>/dev/null && chmod +x /usr/local/bin/telepresence 2>/dev/null && \
        _log_result ok "telepresence" "curl-binary" || \
        _log_result fail "telepresence" "curl-binary" "download failed"
else
    _log_result skip "telepresence" "curl-binary" "already installed"
fi
success "Telepresence installed."

info "Installing Pulumi..."
safe_curl_pipe pulumi "https://get.pulumi.com" || true
success "Pulumi installed."

info "Installing eksctl..."
if ! command -v eksctl &>/dev/null; then
    curl -fsSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${ARCH}.tar.gz" \
        | tar xz -C /usr/local/bin 2>/dev/null && \
        _log_result ok "eksctl" "curl|tar" || \
        _log_result fail "eksctl" "curl|tar" "download failed"
else
    _log_result skip "eksctl" "curl|tar" "already installed"
fi
success "eksctl installed."

info "Installing Helm..."
safe_curl_pipe helm "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" || true
success "Helm installed."

info "Installing k9s..."
if ! command -v k9s &>/dev/null; then
    K9S_VER=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$K9S_VER" ]]; then
        curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_${ARCH}.tar.gz" \
            | tar xz -C /usr/local/bin k9s 2>/dev/null && \
            _log_result ok "k9s" "curl|tar" "$K9S_VER" || \
            _log_result fail "k9s" "curl|tar" "download failed"
    else
        _log_result fail "k9s" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "k9s" "curl|tar" "already installed"
fi
success "k9s installed."

info "Installing Task..."
safe_curl_pipe task "https://taskfile.dev/install.sh" || true
success "Task installed."

info "Installing yq..."
if ! command -v yq &>/dev/null; then
    YQ_VER=$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$YQ_VER" ]]; then
        curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_${ARCH}" \
            -o /usr/local/bin/yq 2>/dev/null && chmod +x /usr/local/bin/yq 2>/dev/null && \
            _log_result ok "yq" "curl-binary" "$YQ_VER" || \
            _log_result fail "yq" "curl-binary" "download failed"
    else
        _log_result fail "yq" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "yq" "curl-binary" "already installed"
fi
success "yq installed."

info "Installing AWS CLI..."
if ! command -v aws &>/dev/null; then
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${SYSARCH}.zip" -o /tmp/awscliv2.zip 2>/dev/null && \
        unzip -q /tmp/awscliv2.zip -d /tmp/awscliv2 2>/dev/null && \
        /tmp/awscliv2/aws/install 2>/dev/null && \
        rm -rf /tmp/awscliv2 /tmp/awscliv2.zip 2>/dev/null && \
        _log_result ok "aws" "curl|zip" || \
        { rm -rf /tmp/awscliv2 /tmp/awscliv2.zip 2>/dev/null; _log_result fail "aws" "curl|zip" "install failed"; }
else
    _log_result skip "aws" "curl|zip" "already installed"
fi
success "AWS CLI installed."

info "Installing Azure CLI..."
safe_curl_pipe az "https://aka.ms/InstallAzureCLIDeb" || true
success "Azure CLI installed."

info "Installing Google Cloud SDK..."
safe_apt google-cloud-cli || {
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
        > /etc/apt/sources.list.d/google-cloud-sdk.list
    apt-get update -qq 2>/dev/null || true
    safe_apt google-cloud-cli || true
}
success "Google Cloud SDK installed."

success "CI/CD & DevOps tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 8. SECURITY & NETWORK TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "SECURITY & NETWORK TOOLS"
info "Installing security and network tools (apt)..."
safe_apt_batch nmap nmap-common masscan netcat-openbsd socat tcpdump wireshark-common tshark \
    proxychains4 nikto dirb sqlmap openssl mtr-tiny curl wget

info "Installing Gobuster..."
if ! command -v gobuster &>/dev/null; then
    GOBUSTER_VER=$(curl -fsSL https://api.github.com/repos/OJ/gobuster/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$GOBUSTER_VER" ]]; then
        mkdir -p /tmp/gobuster && cd /tmp/gobuster && \
        curl -fsSL "https://github.com/OJ/gobuster/releases/download/${GOBUSTER_VER}/gobuster_Linux_${ARCH}.tar.gz" \
            -o gobuster.tar.gz 2>/dev/null && \
        tar xzf gobuster.tar.gz 2>/dev/null && \
        find . -type f -name "gobuster" -exec mv {} /usr/local/bin/gobuster \; 2>/dev/null && \
        chmod +x /usr/local/bin/gobuster 2>/dev/null && \
        cd - && rm -rf /tmp/gobuster && \
        _log_result ok "gobuster" "curl|tar" "$GOBUSTER_VER" || \
        { cd - && rm -rf /tmp/gobuster; _log_result fail "gobuster" "curl|tar" "extract failed"; }
    else
        _log_result fail "gobuster" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "gobuster" "curl|tar" "already installed"
fi
success "Gobuster installed."

info "Installing ffuf..."
if ! command -v ffuf &>/dev/null; then
    FFUF_VER=$(curl -fsSL https://api.github.com/repos/ffuf/ffuf/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$FFUF_VER" ]]; then
        curl -fsSL "https://github.com/ffuf/ffuf/releases/download/${FFUF_VER}/ffuf_${FFUF_VER#v}_linux_${ARCH}.tar.gz" \
            | tar xz -C /usr/local/bin ffuf 2>/dev/null && \
            _log_result ok "ffuf" "curl|tar" "$FFUF_VER" || \
            _log_result fail "ffuf" "curl|tar" "download failed"
    else
        _log_result fail "ffuf" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "ffuf" "curl|tar" "already installed"
fi
success "ffuf installed."

info "Installing Wfuzz, mitmproxy, HTTPie..."
safe_pip wfuzz || true
safe_pip mitmproxy || true
safe_pip httpie || true
success "Wfuzz, mitmproxy, HTTPie installed."

info "Installing OWASP ZAP..."
#safe_snap zaproxy --classic || true
#success "OWASP ZAP installed."


success "Security and network tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 9. REVERSE ENGINEERING TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "REVERSE ENGINEERING TOOLS"
info "Installing reverse engineering tools..."
safe_apt_batch radare2 binwalk foremost yara file hexedit exiftool

info "Installing rizin..."
safe_apt rizin || pip3 install --break-system-packages rizin 2>/dev/null || true
success "rizin installed."

info "Installing APKTool..."
if ! command -v apktool &>/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool \
        -o /usr/local/bin/apktool 2>/dev/null && chmod +x /usr/local/bin/apktool 2>/dev/null || true
    APKTOOL_VER=$(curl -fsSL https://api.github.com/repos/iBotPeaches/Apktool/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$APKTOOL_VER" ]]; then
        curl -fsSL "https://github.com/iBotPeaches/Apktool/releases/download/${APKTOOL_VER}/apktool_${APKTOOL_VER#v}.jar" \
            -o /usr/local/bin/apktool.jar 2>/dev/null && \
            _log_result ok "apktool" "curl-binary" "$APKTOOL_VER" || \
            _log_result fail "apktool" "curl-binary" "download failed"
    else
        _log_result fail "apktool" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "apktool" "curl-binary" "already installed"
fi
success "APKTool installed."

info "Installing Cutter..."
if ! command -v cutter &>/dev/null; then
    CUTTER_VER=$(curl -fsSL https://api.github.com/repos/rizinorg/cutter/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$CUTTER_VER" ]]; then
        mkdir -p /tmp/cutter && cd /tmp/cutter && \
        curl -fsSL "https://github.com/rizinorg/cutter/releases/download/${CUTTER_VER}/Cutter-${CUTTER_VER#v}-Linux-x86_64.AppImage" \
            -o cutter.AppImage 2>/dev/null && \
        chmod +x cutter.AppImage 2>/dev/null && \
        mv cutter.AppImage /usr/local/bin/cutter 2>/dev/null && \
        cd - && rm -rf /tmp/cutter && \
        _log_result ok "cutter" "curl-binary" "$CUTTER_VER" || \
        { cd - && rm -rf /tmp/cutter; _log_result fail "cutter" "curl-binary" "download failed"; }
    else
        _log_result fail "cutter" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "cutter" "curl-binary" "already installed"
fi
success "Cutter installed."

info "Installing Frida..."
safe_pip frida || true
safe_pip frida-tools || true
success "Frida installed."

info "Installing pwndbg..."
if [[ ! -d /opt/pwndbg ]]; then
    safe_apt_batch python3-dev python3-pip || true
    if git clone https://github.com/pwndbg/pwndbg /opt/pwndbg 2>/dev/null; then
        (cd /opt/pwndbg && bash setup.sh 2>/dev/null) && \
            _log_result ok "pwndbg" "git-clone" "/opt/pwndbg" || \
            _log_result fail "pwndbg" "git-clone" "setup.sh failed"
    else
        _log_result fail "pwndbg" "git-clone" "clone failed"
    fi
else
    _log_result skip "pwndbg" "git-clone" "already exists"
fi
success "pwndbg installed."

info "Installing jadx..."
if ! command -v jadx &>/dev/null; then
    JADX_VER=$(curl -fsSL https://api.github.com/repos/skylot/jadx/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$JADX_VER" ]]; then
        curl -fsSL "https://github.com/skylot/jadx/releases/download/${JADX_VER}/jadx-${JADX_VER#v}.zip" \
            -o /tmp/jadx.zip 2>/dev/null && \
            unzip -q /tmp/jadx.zip -d /opt/jadx 2>/dev/null && \
            rm -f /tmp/jadx.zip 2>/dev/null && \
            ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx 2>/dev/null && \
            ln -sf /opt/jadx/bin/jadx-gui /usr/local/bin/jadx-gui 2>/dev/null && \
            _log_result ok "jadx" "curl|zip" "$JADX_VER" || \
            { rm -f /tmp/jadx.zip 2>/dev/null; _log_result fail "jadx" "curl|zip" "install failed"; }
    else
        _log_result fail "jadx" "curl|zip" "could not fetch version"
    fi
else
    _log_result skip "jadx" "curl|zip" "already installed"
fi
success "jadx installed."

info "Installing dex2jar..."
if [[ ! -d /opt/dex2jar ]]; then
    DEX2JAR_VER=$(curl -fsSL https://api.github.com/repos/pxb1988/dex2jar/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$DEX2JAR_VER" ]]; then
        curl -fsSL "https://github.com/pxb1988/dex2jar/releases/download/${DEX2JAR_VER}/dex-tools-${DEX2JAR_VER#v}.zip" \
            -o /tmp/dex2jar.zip 2>/dev/null && \
            unzip -q /tmp/dex2jar.zip -d /opt 2>/dev/null && \
            mv /opt/dex-tools-* /opt/dex2jar 2>/dev/null && \
            rm -f /tmp/dex2jar.zip 2>/dev/null && \
            chmod +x /opt/dex2jar/d2j-*.sh 2>/dev/null || true && \
            ln -sf /opt/dex2jar/d2j-dex2jar.sh /usr/local/bin/d2j-dex2jar 2>/dev/null && \
            _log_result ok "dex2jar" "curl|zip" "$DEX2JAR_VER" || \
            { rm -f /tmp/dex2jar.zip 2>/dev/null; _log_result fail "dex2jar" "curl|zip" "install failed"; }
    else
        _log_result fail "dex2jar" "curl|zip" "could not fetch version"
    fi
else
    _log_result skip "dex2jar" "curl|zip" "already exists"
fi
success "dex2jar installed."

info "Installing Ghidra (requires Java)..."
if [[ ! -d /opt/ghidra ]]; then
    GHIDRA_VER=$(curl -fsSL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$GHIDRA_VER" ]]; then
        GHIDRA_NUM="${GHIDRA_VER#Ghidra_}"
        curl -fsSL "https://github.com/NationalSecurityAgency/ghidra/releases/download/${GHIDRA_VER}/ghidra_${GHIDRA_NUM}_PUBLIC.zip" \
            -o /tmp/ghidra.zip 2>/dev/null && \
            unzip -q /tmp/ghidra.zip -d /opt 2>/dev/null && \
            mv /opt/ghidra_*_PUBLIC /opt/ghidra 2>/dev/null && \
            rm -f /tmp/ghidra.zip 2>/dev/null && \
            printf '#!/bin/sh\nexec /opt/ghidra/ghidraRun "$@"\n' > /usr/local/bin/ghidra && \
            chmod +x /usr/local/bin/ghidra 2>/dev/null && \
            _log_result ok "ghidra" "curl|zip" "$GHIDRA_VER" || \
            { rm -f /tmp/ghidra.zip 2>/dev/null; _log_result fail "ghidra" "curl|zip" "install failed"; }
    else
        _log_result fail "ghidra" "curl|zip" "could not fetch version"
    fi
else
    _log_result skip "ghidra" "curl|zip" "already exists"
fi
success "Ghidra installed."

success "Reverse engineering tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 10. DEVSECOPS TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "DEVSECOPS TOOLS"
info "Installing Trivy..."
safe_apt trivy || {
    curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key \
        | gpg --dearmor -o /usr/share/keyrings/trivy.gpg 2>/dev/null || true
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb generic main" \
        > /etc/apt/sources.list.d/trivy.list
    apt-get update -qq 2>/dev/null || true
    safe_apt trivy || true
}
success "Trivy installed."

info "Installing Grype..."
safe_curl_pipe grype "https://raw.githubusercontent.com/anchore/grype/main/install.sh" || true
success "Grype installed."

info "Installing Syft..."
safe_curl_pipe syft "https://raw.githubusercontent.com/anchore/syft/main/install.sh" || true
success "Syft installed."

info "Installing tfsec..."
if ! command -v tfsec &>/dev/null; then
    TFSEC_VER=$(curl -fsSL https://api.github.com/repos/aquasecurity/tfsec/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$TFSEC_VER" ]]; then
        curl -fsSL "https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VER}/tfsec-linux-${ARCH}" \
            -o /usr/local/bin/tfsec 2>/dev/null && chmod +x /usr/local/bin/tfsec 2>/dev/null && \
            _log_result ok "tfsec" "curl-binary" "$TFSEC_VER" || \
            _log_result fail "tfsec" "curl-binary" "download failed"
    else
        _log_result fail "tfsec" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "tfsec" "curl-binary" "already installed"
fi
success "tfsec installed."

info "Installing GitLeaks..."
if ! command -v gitleaks &>/dev/null; then
    GITLEAKS_VER=$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$GITLEAKS_VER" ]]; then
        mkdir -p /tmp/gitleaks && cd /tmp/gitleaks && \
        curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VER}/gitleaks_${GITLEAKS_VER#v}_linux_${ARCH}.tar.gz" \
            -o gitleaks.tar.gz 2>/dev/null && \
        tar xzf gitleaks.tar.gz 2>/dev/null && \
        find . -type f -name "gitleaks" -exec mv {} /usr/local/bin/gitleaks \; 2>/dev/null && \
        chmod +x /usr/local/bin/gitleaks 2>/dev/null && \
        cd - && rm -rf /tmp/gitleaks && \
        _log_result ok "gitleaks" "curl|tar" "$GITLEAKS_VER" || \
        { cd - && rm -rf /tmp/gitleaks; _log_result fail "gitleaks" "curl|tar" "extract failed"; }
    else
        _log_result fail "gitleaks" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "gitleaks" "curl|tar" "already installed"
fi
success "GitLeaks installed."

info "Installing TruffleHog..."
safe_curl_pipe trufflehog "https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh" || true
success "TruffleHog installed."

info "Installing Hadolint..."
if ! command -v hadolint &>/dev/null; then
    HADOLINT_VER=$(curl -fsSL https://api.github.com/repos/hadolint/hadolint/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$HADOLINT_VER" ]]; then
        curl -fsSL "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VER}/hadolint-Linux-x86_64" \
            -o /usr/local/bin/hadolint 2>/dev/null && chmod +x /usr/local/bin/hadolint 2>/dev/null && \
            _log_result ok "hadolint" "curl-binary" "$HADOLINT_VER" || \
            _log_result fail "hadolint" "curl-binary" "download failed"
    else
        _log_result fail "hadolint" "curl-binary" "could not fetch version"
    fi
else
    _log_result skip "hadolint" "curl-binary" "already installed"
fi
success "Hadolint installed."

info "Installing Kubesec..."
if ! command -v kubesec &>/dev/null; then
    KUBESEC_VER=$(curl -fsSL https://api.github.com/repos/controlplaneio/kubesec/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$KUBESEC_VER" ]]; then
        curl -fsSL "https://github.com/controlplaneio/kubesec/releases/download/${KUBESEC_VER}/kubesec_linux_${ARCH}.tar.gz" \
            | tar xz -C /usr/local/bin kubesec 2>/dev/null && \
            _log_result ok "kubesec" "curl|tar" "$KUBESEC_VER" || \
            _log_result fail "kubesec" "curl|tar" "download failed"
    else
        _log_result fail "kubesec" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "kubesec" "curl|tar" "already installed"
fi
success "Kubesec installed."

info "Installing kube-bench..."
if ! command -v kube-bench &>/dev/null; then
    KUBEBENCH_VER=$(curl -fsSL https://api.github.com/repos/aquasecurity/kube-bench/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$KUBEBENCH_VER" ]]; then
        curl -fsSL "https://github.com/aquasecurity/kube-bench/releases/download/${KUBEBENCH_VER}/kube-bench_${KUBEBENCH_VER#v}_linux_${ARCH}.deb" \
            -o /tmp/kube-bench.deb 2>/dev/null && \
            safe_dpkg kube-bench /tmp/kube-bench.deb && rm -f /tmp/kube-bench.deb || \
            { rm -f /tmp/kube-bench.deb 2>/dev/null; _log_result fail "kube-bench" "curl|dpkg" "install failed"; }
    else
        _log_result fail "kube-bench" "curl|dpkg" "could not fetch version"
    fi
else
    _log_result skip "kube-bench" "curl|dpkg" "already installed"
fi
success "kube-bench installed."

info "Installing pre-commit..."
safe_pip pre-commit || true
success "pre-commit installed."

info "Installing Checkov..."
safe_pip checkov || true
success "Checkov installed."

info "Installing Terrascan..."
if ! command -v terrascan &>/dev/null; then
    TERRASCAN_VER=$(curl -fsSL https://api.github.com/repos/tenable/terrascan/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$TERRASCAN_VER" ]]; then
        mkdir -p /tmp/terrascan && cd /tmp/terrascan && \
        curl -fsSL "https://github.com/tenable/terrascan/releases/download/${TERRASCAN_VER}/terrascan_${TERRASCAN_VER#v}_Linux_${ARCH}.tar.gz" \
            -o terrascan.tar.gz 2>/dev/null && \
        tar xzf terrascan.tar.gz 2>/dev/null && \
        find . -type f -name "terrascan" -exec mv {} /usr/local/bin/terrascan \; 2>/dev/null && \
        chmod +x /usr/local/bin/terrascan 2>/dev/null && \
        cd - && rm -rf /tmp/terrascan && \
        _log_result ok "terrascan" "curl|tar" "$TERRASCAN_VER" || \
        { cd - && rm -rf /tmp/terrascan; _log_result fail "terrascan" "curl|tar" "extract failed"; }
    else
        _log_result fail "terrascan" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "terrascan" "curl|tar" "already installed"
fi
success "Terrascan installed."

info "Installing Snyk CLI..."
safe_npm snyk || true
success "Snyk CLI installed."

info "Installing kube-hunter..."
safe_pip kube-hunter || true
success "kube-hunter installed."

info "Installing OWASP Dependency-Check..."
if [[ ! -d /opt/dependency-check ]]; then
    DC_VER=$(curl -fsSL https://api.github.com/repos/jeremylong/DependencyCheck/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$DC_VER" ]]; then
        curl -fsSL "https://github.com/jeremylong/DependencyCheck/releases/download/${DC_VER}/dependency-check-${DC_VER#v}-release.zip" \
            -o /tmp/dc.zip 2>/dev/null && \
            unzip -q /tmp/dc.zip -d /opt 2>/dev/null && \
            rm -f /tmp/dc.zip 2>/dev/null && \
            ln -sf /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check 2>/dev/null && \
            chmod +x /opt/dependency-check/bin/dependency-check.sh 2>/dev/null && \
            _log_result ok "dependency-check" "curl|zip" "$DC_VER" || \
            { rm -f /tmp/dc.zip 2>/dev/null; _log_result fail "dependency-check" "curl|zip" "install failed"; }
    else
        _log_result fail "dependency-check" "curl|zip" "could not fetch version"
    fi
else
    _log_result skip "dependency-check" "curl|zip" "already exists"
fi
success "OWASP Dependency-Check installed."

success "DevSecOps tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 11. TERMINAL & SHELL SETUP
# ─────────────────────────────────────────────────────────────────────────────
section_header "TERMINAL & SHELL SETUP"
info "Installing terminal tools..."
safe_apt_batch zsh zsh-common emacs

info "Installing Kitty..."
if ! command -v kitty &>/dev/null; then
    run_as_user 'curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n' 2>/dev/null && \
        _log_result ok "kitty" "curl|pipe" "user install" || \
        _log_result fail "kitty" "curl|pipe" "install failed"
else
    _log_result skip "kitty" "curl|pipe" "already installed"
fi
success "Kitty installed."

info "Installing Starship..."
safe_curl_pipe starship "https://starship.rs/install.sh" || true
success "Starship installed."

info "Installing Oh-My-Zsh for $REAL_USER..."
if [[ ! -d "$REAL_HOME/.oh-my-zsh" ]]; then
    run_as_user 'RUNZSH=no CHSH=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"' 2>/dev/null && \
        _log_result ok "oh-my-zsh" "curl|pipe" "user install" || \
        _log_result fail "oh-my-zsh" "curl|pipe" "install failed"
else
    _log_result skip "oh-my-zsh" "curl|pipe" "already installed"
fi

if [[ ! -d "$REAL_HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    safe_git_clone "powerlevel10k" "https://github.com/romkatv/powerlevel10k.git" "$REAL_HOME/.oh-my-zsh/custom/themes/powerlevel10k" --depth=1
else
    _log_result skip "powerlevel10k" "git-clone" "already exists"
fi
success "Oh-My-Zsh + Powerlevel10k installed."

info "Installing Nerd Fonts (JetBrainsMono)..."
FONT_DIR="$REAL_HOME/.local/share/fonts"
mkdir -p "$FONT_DIR" 2>/dev/null || true
if ! ls "$FONT_DIR"/JetBrainsMonoNerdFont* &>/dev/null 2>&1; then
    NF_VER=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$NF_VER" ]]; then
        curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VER}/JetBrainsMono.tar.xz" \
            | tar -xJ -C "$FONT_DIR" 2>/dev/null && \
            chown -R "$REAL_USER":"$REAL_USER" "$FONT_DIR" 2>/dev/null && \
            fc-cache -fv "$FONT_DIR" >/dev/null 2>&1 && \
            _log_result ok "JetBrainsMono-NF" "curl|tar" "$NF_VER" || \
            _log_result fail "JetBrainsMono-NF" "curl|tar" "install failed"
    else
        _log_result fail "JetBrainsMono-NF" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "JetBrainsMono-NF" "curl|tar" "already installed"
fi
success "Nerd Fonts installed."

success "Terminal and shell tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 12. MONITORING & OBSERVABILITY
# ─────────────────────────────────────────────────────────────────────────────
section_header "MONITORING & OBSERVABILITY"
info "Installing monitoring tools..."
safe_apt_batch iotop iftop nethogs
safe_pip glances || safe_apt glances || true

info "Installing Netdata..."
safe_curl_pipe netdata "https://my-netdata.io/kickstart.sh" || true
success "Netdata installed."

info "Installing Prometheus Node Exporter..."
if ! command -v node_exporter &>/dev/null; then
    NE_VER=$(curl -fsSL https://api.github.com/repos/prometheus/node_exporter/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$NE_VER" ]]; then
        curl -fsSL "https://github.com/prometheus/node_exporter/releases/download/${NE_VER}/node_exporter-${NE_VER#v}.linux-${ARCH}.tar.gz" \
            | tar xz --strip-components=1 -C /usr/local/bin \
              "node_exporter-${NE_VER#v}.linux-${ARCH}/node_exporter" 2>/dev/null && \
            _log_result ok "node_exporter" "curl|tar" "$NE_VER" || \
            _log_result fail "node_exporter" "curl|tar" "download failed"
    else
        _log_result fail "node_exporter" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "node_exporter" "curl|tar" "already installed"
fi
success "Prometheus Node Exporter installed."

info "Installing lazydocker..."
if ! command -v lazydocker &>/dev/null; then
    mkdir -p /tmp/lazydocker && cd /tmp/lazydocker && \
    LD_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '') && \
    if [[ -n "$LD_VER" ]]; then
        curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/download/${LD_VER}/lazydocker_${LD_VER#v}_Linux_${ARCH}.tar.gz" \
            -o lazydocker.tar.gz 2>/dev/null && \
        tar xzf lazydocker.tar.gz 2>/dev/null && \
        find . -type f -name "lazydocker" -exec mv {} /usr/local/bin/lazydocker \; 2>/dev/null && \
        chmod +x /usr/local/bin/lazydocker 2>/dev/null && \
        cd - && rm -rf /tmp/lazydocker && \
        _log_result ok "lazydocker" "curl|tar" "$LD_VER" || \
        { cd - && rm -rf /tmp/lazydocker; _log_result fail "lazydocker" "curl|tar" "extract failed"; }
    else
        _log_result fail "lazydocker" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "lazydocker" "curl|tar" "already installed"
fi
success "lazydocker installed."

success "Monitoring tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 13. VPN & NETWORKING
# ─────────────────────────────────────────────────────────────────────────────
section_header "VPN & NETWORKING"
info "Installing VPN tools..."
safe_apt_batch openvpn wireguard wireguard-tools
success "OpenVPN and WireGuard installed."

# ─────────────────────────────────────────────────────────────────────────────
# 14. MEDIA & FILE TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "MEDIA & FILE TOOLS"
info "Installing media and file tools..."
safe_apt_batch ffmpeg imagemagick rar unrar flameshot scrot
success "Media and file tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 15. DEVELOPMENT TOOLS (gRPC, PlantUML, Protocol Buffers)
# ─────────────────────────────────────────────────────────────────────────────
section_header "DEVELOPMENT TOOLS (gRPC, PlantUML, Protobuf)"
info "Installing Protocol Buffers..."
safe_apt protobuf-compiler || safe_snap protobuf --classic || true
success "protoc installed."

info "Installing grpcurl..."
if ! command -v grpcurl &>/dev/null; then
    GRPCURL_VER=$(curl -fsSL https://api.github.com/repos/fullstorydev/grpcurl/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$GRPCURL_VER" ]]; then
        mkdir -p /tmp/grpcurl && cd /tmp/grpcurl && \
        curl -fsSL "https://github.com/fullstorydev/grpcurl/releases/download/${GRPCURL_VER}/grpcurl_${GRPCURL_VER#v}_linux_${ARCH}.tar.gz" \
            -o grpcurl.tar.gz 2>/dev/null && \
        tar xzf grpcurl.tar.gz 2>/dev/null && \
        find . -type f -name "grpcurl" -exec mv {} /usr/local/bin/grpcurl \; 2>/dev/null && \
        chmod +x /usr/local/bin/grpcurl 2>/dev/null && \
        cd - && rm -rf /tmp/grpcurl && \
        _log_result ok "grpcurl" "curl|tar" "$GRPCURL_VER" || \
        { cd - && rm -rf /tmp/grpcurl; _log_result fail "grpcurl" "curl|tar" "extract failed"; }
    else
        _log_result fail "grpcurl" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "grpcurl" "curl|tar" "already installed"
fi
success "grpcurl installed."

info "Installing evans..."
if ! command -v evans &>/dev/null; then
    EVANS_VER=$(curl -fsSL https://api.github.com/repos/ktr0731/evans/releases/latest 2>/dev/null | jq -r '.tag_name' || echo '')
    if [[ -n "$EVANS_VER" ]]; then
        curl -fsSL "https://github.com/ktr0731/evans/releases/download/${EVANS_VER}/evans_linux_${ARCH}.tar.gz" \
            | tar xz -C /usr/local/bin evans 2>/dev/null && \
            _log_result ok "evans" "curl|tar" "$EVANS_VER" || \
            _log_result fail "evans" "curl|tar" "download failed"
    else
        _log_result fail "evans" "curl|tar" "could not fetch version"
    fi
else
    _log_result skip "evans" "curl|tar" "already installed"
fi
success "evans installed."

info "Installing PlantUML..."
safe_apt plantuml || {
    if curl -fsSL https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar \
        -o /usr/local/share/plantuml.jar 2>/dev/null; then
        printf '#!/bin/sh\nexec java -jar /usr/local/share/plantuml.jar "$@"\n' \
            > /usr/local/bin/plantuml && chmod +x /usr/local/bin/plantuml 2>/dev/null && \
            _log_result ok "plantuml" "curl|jar" "fallback install" || \
            _log_result fail "plantuml" "curl|jar" "fallback failed"
    else
        _log_result fail "plantuml" "apt" "not in repos, download failed"
    fi
}
success "PlantUML installed."

success "Development tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 16. PYTHON PACKAGES (pip3)
# ─────────────────────────────────────────────────────────────────────────────
section_header "PYTHON PACKAGES (pip3)"
info "Installing Python packages via pip3..."

mkdir -p "$REAL_HOME/.config/devstack"
if [[ ! -f "$REAL_HOME/.config/devstack/.pip_batch_done" ]]; then
    cat > /tmp/devstack_requirements.txt << 'PYEOF'
ansible==9.2.0
ansible-core==2.16.3
apache-libcloud
argcomplete
attrs
autopep8
Babel
bcrypt
black
certifi
click
colorama
cryptography
Django>=4.0
django-cleanup
django-froala-editor
dnspython
docker
docker-compose
flake8
gunicorn
httpie
httplib2
ipython
Jinja2
jmespath
jsonpatch
jsonpointer
jsonschema
jupyter
Mako
markdown-it-py
MarkupSafe
mitmproxy
monotonic
mypy
netaddr
netifaces
ntlm-auth
oauthlib
olefile
packaging
paramiko
passlib
pexpect
Pillow
pre-commit
psutil
psycopg2-binary
ptyprocess
pycairo
Pygments
PyJWT
PyNaCl
pymongo
pyparsing
pyserial
pytest
python-dateutil
python-dotenv
pytz
pywinrm
PyYAML
requests
requests-ntlm
rich
setuptools
simplejson
six
sqlparse
texttable
tldr
toml
typing_extensions
urllib3
wfuzz
websocket-client
wheel
xmltodict
grpcio
protobuf
resolvelib
kerberos
vboxapi
PYEOF

    pip3 install --break-system-packages -r /tmp/devstack_requirements.txt 2>/tmp/_safe_pip_batch_err.log
    if [[ $? -eq 0 ]]; then
        _log_result ok "devstack-pip-packages" "pip3" "batch install"
        touch "$REAL_HOME/.config/devstack/.pip_batch_done"
    else
        _log_result fail "devstack-pip-packages" "pip3" "batch had failures -- see /tmp/_safe_pip_batch_err.log"
    fi
    rm -f /tmp/devstack_requirements.txt
else
    _log_result skip "devstack-pip-packages" "pip3" "already installed (marker found)"
fi
success "Python packages installed."

# ─────────────────────────────────────────────────────────────────────────────
# 17. SNAP PACKAGES -- LANGUAGES & BUILD TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "SNAP: LANGUAGES & BUILD TOOLS"
info "Installing snap language tools..."
safe_snap cmake --classic || true
safe_snap kotlin --classic || true
safe_snap dotnet-sdk --classic --channel=8.0/stable || true
safe_snap ruby --classic || true
safe_snap gradle --classic || true
success "Snap language tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 18. SNAP PACKAGES -- EDITORS & IDEs
# ─────────────────────────────────────────────────────────────────────────────
section_header "SNAP: EDITORS & IDEs"
info "Installing VS Code..."
safe_snap code --classic || true
safe_snap code-insiders --classic || true
success "VS Code installed."

info "Installing JetBrains IDEs (this may take a while)..."
safe_snap intellij-idea-community --classic || true
#safe_snap intellij-idea-ultimate --classic || true
safe_snap pycharm-community --classic || true
#safe_snap pycharm-professional --classic || true
safe_snap clion --classic || true
#safe_snap goland --classic || true
#safe_snap webstorm --classic || true
#safe_snap phpstorm --classic || true
safe_snap rubymine --classic || true
safe_snap rider --classic || true
safe_snap rustrover --classic || true
#safe_snap datagrip --classic || true
#safe_snap dataspell --classic || true
#safe_snap android-studio --classic || true
#safe_snap eclipse --classic || true
safe_snap marktext || true
success "JetBrains IDEs and editors installed."

# ─────────────────────────────────────────────────────────────────────────────
# 19. SNAP PACKAGES -- DEVOPS & API TOOLS
# ─────────────────────────────────────────────────────────────────────────────
section_header "SNAP: DEVOPS & API TOOLS"
info "Installing DevOps snap tools..."
safe_snap kubectl --classic || true
safe_snap minikube || true
safe_snap jenkins --classic || true
safe_snap powershell --classic || true
info "Installing JetBrains Space CLI..."
if ! command -v space &>/dev/null; then
    curl -fsSL https://download.jetbrains.com/space/jbspace -o /usr/local/bin/space 2>/dev/null && \
        chmod +x /usr/local/bin/space 2>/dev/null && \
        _log_result ok "jetbrains-space" "curl-binary" || \
        _log_result fail "jetbrains-space" "curl-binary" "download failed"
else
    _log_result skip "jetbrains-space" "curl-binary" "already installed"
fi
success "JetBrains Space CLI installed."
success "kubectl, minikube, jenkins, powershell, JetBrains Space installed."

info "Installing API and DB client tools..."
#safe_snap postman || true
#safe_snap insomnia || true
#safe_snap bruno || true
#safe_snap dbeaver-ce || true
safe_snap beekeeper-studio || true
safe_snap storage-explorer || true
success "API and DB tools installed."

# ─────────────────────────────────────────────────────────────────────────────
# 20. SNAP PACKAGES -- TERMINAL & COMMUNICATION
# ─────────────────────────────────────────────────────────────────────────────
section_header "SNAP: TERMINAL & COMMUNICATION"
info "Installing terminal and communication snaps..."
safe_snap alacritty --classic || true
safe_snap waveterm --classic || true
safe_snap termius-app || true
safe_snap remmina || true
success "Terminal and comms snaps installed."

info "Installing productivity and browser snaps..."
safe_snap notion-desktop || true
#safe_snap appflowy || true
safe_snap onlyoffice-desktopeditors || true
#safe_snap brave || true
#safe_snap slack --classic || true
#safe_snap discord || true
#safe_snap telegram-desktop || true
#safe_snap skype --classic || true
#safe_snap thunderbird || true
safe_snap session-desktop || true
#safe_snap umbrello || true
#safe_snap 0ad || true
#safe_snap flutter-gallery || true
success "Productivity snaps installed."

# ─────────────────────────────────────────────────────────────────────────────
# 21. BROWSERS
# ─────────────────────────────────────────────────────────────────────────────
section_header "BROWSERS"
#info "Installing Google Chrome..."
#if ! command -v google-chrome &>/dev/null; then
    #safe_curl google-chrome "https://dl.google.com/linux/direct/google-chrome-stable_current_${ARCH}.deb" /tmp/chrome.deb && \
#        safe_dpkg google-chrome /tmp/chrome.deb && rm -f /tmp/chrome.deb || \
#        { rm -f /tmp/chrome.deb 2>/dev/null; _log_result fail "google-chrome" "curl|dpkg" "install failed"; }
#else
#    _log_result skip "google-chrome" "curl|dpkg" "already installed"
#fi
#success "Google Chrome installed."

info "Installing Chromium..."
#safe_snap chromium || safe_apt chromium-browser || true
#success "Chromium installed."

info "Installing Firefox..."
safe_apt firefox || safe_snap firefox || true
success "Firefox installed."

# ─────────────────────────────────────────────────────────────────────────────
# 22. NPM GLOBAL PACKAGES
# ─────────────────────────────────────────────────────────────────────────────
section_header "NPM GLOBAL PACKAGES"
info "Installing global npm packages..."
safe_npm pnpm || true
safe_npm yarn || true
safe_npm typescript || true
safe_npm ts-node || true
safe_npm nodemon || true
safe_npm pm2 || true
safe_npm eslint || true
safe_npm prettier || true
safe_npm commitizen || true
safe_npm semantic-release || true
safe_npm swagger-cli || true
safe_npm graphql-cli || true
safe_npm @anthropic-ai/claude-code || true
success "Global npm packages installed."

# ─────────────────────────────────────────────────────────────────────────────
# 23. FINAL CHECKS
# ─────────────────────────────────────────────────────────────────────────────
section_header "FINAL VERIFICATION"
info "Running final verification checks..."
echo ""

declare -a VERIFY_TOOLS=(
    "python3:Python:$(python3 --version 2>/dev/null || echo '?')"
    "node:Node.js:$(node --version 2>/dev/null || echo '?')"
    "npm:npm:$(npm --version 2>/dev/null || echo '?')"
    "go:Go:$(go version 2>/dev/null | awk '{print $3}' || echo '?')"
    "rustc:Rust:$(rustc --version 2>/dev/null | awk '{print $2}' || echo '?')"
    "deno:Deno:$(deno --version 2>/dev/null | head -1 || echo '?')"
    "bun:Bun:$(bun --version 2>/dev/null || echo '?')"
    "php:PHP:$(php --version 2>/dev/null | head -1 || echo '?')"
    "java:Java:$(java -version 2>&1 | head -1 || echo '?')"
    "ruby:Ruby:$(ruby --version 2>/dev/null | awk '{print $2}' || echo '?')"
    "gcc:GCC:$(gcc --version 2>/dev/null | head -1 || echo '?')"
    "git:Git:$(git --version 2>/dev/null || echo '?')"
    "docker:Docker:$(docker --version 2>/dev/null || echo '?')"
    "kubectl:kubectl:installed"
    "helm:Helm:installed"
    "terraform:Terraform:$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo '?')"
    "ansible:Ansible:$(ansible --version 2>/dev/null | head -1 || echo '?')"
    "aws:AWS CLI:installed"
    "az:Azure CLI:installed"
    "gcloud:gcloud:installed"
    "mysql:mysql:$(mysql --version 2>/dev/null || echo '?')"
    "psql:PostgreSQL:$(psql --version 2>/dev/null || echo '?')"
    "redis-cli:Redis:$(redis-cli --version 2>/dev/null || echo '?')"
    "nginx:nginx:$(nginx -v 2>&1 || echo '?')"
    "caddy:caddy:installed"
    "tmux:tmux:$(tmux -V 2>/dev/null || echo '?')"
    "nmap:nmap:$(nmap --version 2>/dev/null | head -1 || echo '?')"
    "gobuster:gobuster:installed"
    "ffuf:ffuf:installed"
    "trivy:trivy:installed"
    "grype:grype:installed"
    "syft:syft:installed"
    "gitleaks:gitleaks:installed"
    "trufflehog:trufflehog:installed"
    "hadolint:hadolint:installed"
    "radare2:radare2:installed"
    "yara:yara:installed"
    "apktool:apktool:installed"
    "jadx:jadx:installed"
    "grpcurl:grpcurl:installed"
    "terrascan:terrascan:installed"
    "node_exporter:node_exporter:installed"
    "lazydocker:lazydocker:installed"
    "netdata:netdata:installed"
    "dependency-check:OWASP Dep-Check:installed"
)

echo -e "${BOLD}  TOOL VERIFICATION${NC}"
echo -e "${BOLD}─────────────────────────────────────────────────────────────────────────────────────────────${NC}"
printf "  ${GREEN}%-8s${NC}  %-20s  %s\n" "STATUS" "TOOL" "VERSION"
echo -e "${BOLD}─────────────────────────────────────────────────────────────────────────────────────────────${NC}"

declare -i verify_ok=0 verify_fail=0
for entry in "${VERIFY_TOOLS[@]}"; do
    IFS=':' read -r cmd name ver <<< "$entry"
    if command -v "$cmd" &>/dev/null || [[ -f "/usr/local/bin/$cmd" ]] || [[ -d "/opt/${cmd}" ]]; then
        printf "  ${GREEN}%-8s${NC}  %-20s  %s\n" "[OK]" "$name" "$ver"
        ((verify_ok++))
    else
        printf "  ${RED}%-8s${NC}  %-20s  %s\n" "[MISS]" "$name" "not found"
        ((verify_fail++))
    fi
done

echo -e "${BOLD}─────────────────────────────────────────────────────────────────────────────────────────────${NC}"
printf "  Verification: ${GREEN}%d OK${NC} / ${RED}%d MISSING${NC} / %d total\n" "$verify_ok" "$verify_fail" "$((verify_ok + verify_fail))"
echo ""

print_summary_table

success "Installation complete! Log out and back in for docker group to take effect."
echo ""
echo -e "${DIM}┌─ POST-INSTALL REMINDERS ─────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Go binaries:${NC}      /usr/lib/go-1.22/bin/ -- add to PATH in ~/.bashrc if needed              ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Apache2:${NC}          on standby -- change port in /etc/apache2/ports.conf then start it       ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}User tools:${NC}       pyenv / nvm / rbenv / rustup / bun / deno installed for: $REAL_USER                  ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Shell reload:${NC}     restart shell or source ~/.bashrc / ~/.zshrc to activate user-level     ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}JetBrains:${NC}        some IDEs require accepting the license on first launch                 ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}MongoDB:${NC}          service name: mongod  (systemctl status mongod)                          ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Ghidra:${NC}          requires Java 17+ -- launch via: ghidra                                  ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}pwndbg:${NC}          add 'source /opt/pwndbg/gdbinit.py' to ~/.gdbinit                       ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Snyk CLI:${NC}        run 'snyk auth' after installation                                       ${DIM}│${NC}"
echo -e "${DIM}│${NC}  ${YELLOW}Netdata:${NC}         dashboard at http://localhost:19999                                       ${DIM}│${NC}"
echo -e "${DIM}└───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "  ${GREEN}${BOLD}Done.${NC} ${DIM}-- 0xbugatti // SOS-DevSEC-VM${NC}"
echo ""
