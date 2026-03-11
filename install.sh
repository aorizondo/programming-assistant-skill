#!/bin/bash
################################################################################
# Programming Assistant Skill One-Click Installation Script
#
# Features:
#   Install to OpenCode (Global)
#   Install to Cursor (Global Rules)
#   Install to Claude Code (Global)
#   Automatic MCP server configuration
#   Overwrite confirmation and backup
#
# Usage:
#   ./install.sh                    # Interactive installation (All platforms)
#   ./install.sh --opencode         # Install to OpenCode only
#   ./install.sh --claude-code      # Install to Claude Code only
#   ./install.sh --cursor           # Install to Cursor only
#   ./install.sh --with-mcp         # Configure MCP servers as well
#   ./install.sh --all              # Full installation (Recommended)
#   ./install.sh --dry-run          # Preview mode, no actual execution
#   ./install.sh --help             # Show help information
#
################################################################################

set -euo pipefail

################################################################################
# Configuration Constants
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
VERSION="1.4.0"

# OpenCode Path (Official docs: https://opencode.ai/docs/skills/)
OPENCODE_SKILLS_DIR="$HOME/.config/opencode/skill"
OPENCODE_SKILL_DIR="$OPENCODE_SKILLS_DIR/programming-assistant"
OPENCODE_SKILL_FILE="$OPENCODE_SKILL_DIR/SKILL.md"

# Claude Code Path (Official docs: https://docs.anthropic.com/en/docs/claude-code/skills)
CLAUDE_CODE_SKILLS_DIR="$HOME/.claude/skills"
CLAUDE_CODE_SKILL_DIR="$CLAUDE_CODE_SKILLS_DIR/programming-assistant"
CLAUDE_CODE_SKILL_FILE="$CLAUDE_CODE_SKILL_DIR/SKILL.md"

# Cursor Path
CURSOR_DIR="$HOME/.cursor"
CURSOR_RULES_DIR="$CURSOR_DIR/rules"
CURSOR_RULE_FILE="$CURSOR_RULES_DIR/programming-assistant.md"

# Source Files
SOURCE_SKILL_FILE="$SCRIPT_DIR/SKILL.md"
SOURCE_LEGACY_SKILL_FILE="$SCRIPT_DIR/programming-assistant.skill.md"
SOURCE_TEMPLATES_DIR="$SCRIPT_DIR/templates"
SOURCE_COMMAND_DIR="$SCRIPT_DIR/command"
SOURCE_REFERENCE_FILE="$SCRIPT_DIR/reference.md"
SOURCE_EXAMPLES_FILE="$SCRIPT_DIR/examples.md"

# Backup Directories
OPENCODE_BACKUP_DIR="$HOME/.config/opencode/skill/.backup"
CLAUDE_CODE_BACKUP_DIR="$HOME/.claude/skills/.backup"
CURSOR_BACKUP_DIR="$HOME/.cursor/rules/.backup"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Color Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

# Print Info
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# Print Success
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Print Warning
warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Print Error
error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Print Separator
separator() {
    echo "========================================================================"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"

    if [ "$default" = "y" ]; then
        read -p "$message [Y/n] " -n 1 -r response
        response=${response:-y}
    else
        read -p "$message [y/N] " -n 1 -r response
        response=${response:-n}
    fi
    echo

    [[ "$response" =~ ^[Yy]$ ]]
}

# Create backup
backup_file() {
    local file="$1"
    local backup_type="${2:-opencode}"
    
    if [ -f "$file" ] || [ -d "$file" ]; then
        local backup_dir
        case "$backup_type" in
            cursor)
                backup_dir="$CURSOR_BACKUP_DIR"
                ;;
            claude_code)
                backup_dir="$CLAUDE_CODE_BACKUP_DIR"
                ;;
            *)
                backup_dir="$OPENCODE_BACKUP_DIR"
                ;;
        esac
        
        mkdir -p "$backup_dir"
        local backup_loc="$backup_dir/$(basename "$file").$BACKUP_TIMESTAMP"
        cp -r "$file" "$backup_loc"
        info "Backed up: $file -> $backup_loc"
    fi
}

################################################################################
# Detection and Validation
################################################################################

# Check source file existence
check_source_file() {
    if [ ! -f "$SOURCE_SKILL_FILE" ]; then
        error "Source file not found: $SOURCE_SKILL_FILE"
        if [ -f "$SOURCE_LEGACY_SKILL_FILE" ]; then
            info "Legacy file found, will use: $SOURCE_LEGACY_SKILL_FILE"
            SOURCE_SKILL_FILE="$SOURCE_LEGACY_SKILL_FILE"
        else
            exit 1
        fi
    fi
}

# Check OpenCode installation
check_opencode() {
    if command_exists opencode; then
        local version=$(opencode --version 2>/dev/null || echo "unknown")
        info "Detected OpenCode CLI: v$version"
        return 0
    else
        warn "OpenCode CLI not detected, skipping OpenCode installation"
        return 1
    fi
}

# Check Claude Code installation
check_claude_code() {
    if command_exists claude; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        info "Detected Claude Code CLI: $version"
        return 0
    else
        warn "Claude Code CLI not detected, skipping Claude Code installation"
        return 1
    fi
}

# Check Cursor installation
check_cursor() {
    if [ -d "$CURSOR_DIR" ]; then
        info "Detected Cursor installation: $CURSOR_DIR"
        return 0
    else
        warn "Cursor not detected, skipping Cursor installation"
        return 1
    fi
}

# Check MCP tools availability
check_mcp_tools() {
    local missing_tools=()
    local all_available=true

    # Check npx
    if ! command_exists npx; then
        missing_tools+=("npx (Requires Node.js)")
        all_available=false
    fi

    if [ "$all_available" = false ]; then
        warn "Following MCP tools are not installed:"
        for tool in "${missing_tools[@]}"; do
            warn "  - $tool"
        done
        warn "MCP features will be unavailable, but the skill will still work"
        warn "Recommendation: Install missing tools to enable full MCP functionality"
        return 1
    else
        info "All MCP tools are installed"
        return 0
    fi
}

################################################################################
# Install OpenCode Skill
################################################################################

install_opencode_skill() {
    info "Installing OpenCode Skill..."

    # Check for overwrite
    if [ -f "$OPENCODE_SKILL_FILE" ]; then
        warn "Target file already exists: $OPENCODE_SKILL_FILE"
        if [ "${DRY_RUN:-false}" = true ]; then
            info "DRY-RUN: Will overwrite $OPENCODE_SKILL_FILE"
            return 0
        fi

        if ! confirm "Overwrite existing file?"; then
            info "Skipping OpenCode installation"
            return 1
        fi

        backup_file "$OPENCODE_SKILL_FILE" "opencode"
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will create directory $OPENCODE_SKILL_DIR"
        info "DRY-RUN: Will copy $SOURCE_SKILL_FILE -> $OPENCODE_SKILL_FILE"
        return 0
    fi

    # Create directory
    mkdir -p "$OPENCODE_SKILL_DIR"

    cp "$SOURCE_SKILL_FILE" "$OPENCODE_SKILL_FILE"

    [ -f "$SOURCE_REFERENCE_FILE" ] && cp "$SOURCE_REFERENCE_FILE" "$OPENCODE_SKILL_DIR/"
    [ -f "$SOURCE_EXAMPLES_FILE" ] && cp "$SOURCE_EXAMPLES_FILE" "$OPENCODE_SKILL_DIR/"

    if [ -d "$SOURCE_TEMPLATES_DIR" ]; then
        mkdir -p "$OPENCODE_SKILL_DIR/templates"
        cp -r "$SOURCE_TEMPLATES_DIR"/* "$OPENCODE_SKILL_DIR/templates/" 2>/dev/null || true
        info "Template files installed to: $OPENCODE_SKILL_DIR/templates/"
    fi

    if [ -d "$SOURCE_COMMAND_DIR" ]; then
        mkdir -p "$OPENCODE_SKILL_DIR/command"
        cp -r "$SOURCE_COMMAND_DIR"/* "$OPENCODE_SKILL_DIR/command/" 2>/dev/null || true
        info "Command files installed to: $OPENCODE_SKILL_DIR/command/"
    fi

    success "OpenCode Skill installation complete: $OPENCODE_SKILL_FILE"
}

# Configure OpenCode MCP server
configure_opencode_mcp() {
    info "Configuring OpenCode MCP server..."

    # Check MCP tools
    if ! check_mcp_tools; then
        warn "MCP tools not fully installed, skipping MCP configuration"
        warn "Skill is still usable, but MCP features will be unavailable"
        return 0
    fi

    # OpenCode uses ~/.config/opencode/opencode.json configuration file
    local opencode_config_file="$HOME/.config/opencode/opencode.json"
    local script_mcp_file="$SCRIPT_DIR/mcp-config.json"

    if [ ! -f "$script_mcp_file" ]; then
        warn "MCP configuration template not found: $script_mcp_file"
        return 1
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will check and update $opencode_config_file"
        return 0
    fi

    # Ensure opencode.json directory exists
    mkdir -p "$(dirname "$opencode_config_file")"

    # If opencode.json doesn't exist, create base config
    if [ ! -f "$opencode_config_file" ]; then
        info "Creating OpenCode configuration file"
        cat > "$opencode_config_file" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {}
}
EOF
    fi

    info "Adding MCP configuration to: $opencode_config_file"

    # Use Python script to merge JSON configuration
    python3 << 'PYTHON_SCRIPT'
import json
import os

config_file = os.path.expanduser("~/.config/opencode/opencode.json")
mcp_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mcp-config.json")

# Read existing config
try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except Exception as e:
    print(f"Failed to read configuration file: {e}")
    exit(1)

# Read MCP config
try:
    with open(mcp_file, 'r') as f:
        mcp_config = json.load(f)
except Exception as e:
    print(f"Failed to read MCP configuration: {e}")
    exit(1)

# Convert MCP configuration format
# Cursor format: mcpServers -> { name: { command, args } }
# OpenCode format: mcp -> { name: { type, command (array), environment } }
opencode_mcp = {}

# context7 - Remote server
if "context7" in mcp_config.get("mcpServers", {}):
    opencode_mcp["context7"] = {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp"
    }

# sequential-thinking - Local server (using npx)
if "sequential-thinking" in mcp_config.get("mcpServers", {}):
    st_config = mcp_config["mcpServers"]["sequential-thinking"]
    opencode_mcp["sequential-thinking"] = {
        "type": "local",
        "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
        "enabled": True
    }

# Merge into main config
if "mcp" not in config:
    config["mcp"] = {}

# Add or update MCP config
for name, mcp_entry in opencode_mcp.items():
    if name in config["mcp"]:
        print(f"Updating MCP config: {name}")
    else:
        print(f"Adding MCP config: {name}")
    config["mcp"][name] = mcp_entry

# Backup original file
backup_file = f"{config_file}.backup.{os.popen('date +%Y%m%d_%H%M%S').read().strip()}"
with open(backup_file, 'w') as f:
    json.dump(config, f, indent=2)
print(f"Backed up to: {backup_file}")

# Write new config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print("OpenCode MCP configuration complete")
PYTHON_SCRIPT

    success "OpenCode MCP configuration complete"
    info "Configured servers: context7, sequential-thinking"
}

verify_opencode() {
    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Skipping verification"
        return 0
    fi

    info "Verifying OpenCode installation..."

    if [ ! -f "$OPENCODE_SKILL_FILE" ]; then
        error "SKILL.md file does not exist"
        return 1
    fi

    info "✓ SKILL.md file exists"

    if grep -q "^name: " "$OPENCODE_SKILL_FILE" && grep -q "^description: " "$OPENCODE_SKILL_FILE"; then
        info "✓ YAML frontmatter format is correct"
    else
        error "YAML frontmatter format is incorrect"
        return 1
    fi

    # Verify MCP configuration
    local opencode_config_file="$HOME/.config/opencode/opencode.json"
    if [ -f "$opencode_config_file" ]; then
        info "✓ Configuration file exists: $opencode_config_file"

        # Check MCP configuration
        if command -v python3 >/dev/null 2>&1; then
            local mcp_count=$(python3 -c "
import json
try:
    with open('$opencode_config_file', 'r') as f:
        config = json.load(f)
    mcp_servers = config.get('mcp', {})
    count = 0
    if 'context7' in mcp_servers: count += 1
    if 'sequential-thinking' in mcp_servers: count += 1
    print(count)
except:
    print(0)
" 2>/dev/null || echo "0")

            if [ "$mcp_count" -eq 2 ]; then
                info "✓ MCP configuration complete (2/2)"
            elif [ "$mcp_count" -gt 0 ]; then
                warn "MCP configuration partially complete ($mcp_count/2)"
            else
                warn "MCP configuration not detected"
            fi
        else
            warn "Python3 required to verify MCP configuration"
        fi
    else
        warn "Configuration file not found: $opencode_config_file"
    fi

    success "OpenCode verification complete"
}

################################################################################
# Install Claude Code Skill
################################################################################

install_claude_code_skill() {
    info "Installing Claude Code Skill..."

    if [ -f "$CLAUDE_CODE_SKILL_FILE" ]; then
        warn "Target file already exists: $CLAUDE_CODE_SKILL_FILE"
        if [ "${DRY_RUN:-false}" = true ]; then
            info "DRY-RUN: Will overwrite $CLAUDE_CODE_SKILL_FILE"
            return 0
        fi

        if ! confirm "Overwrite existing file?"; then
            info "Skipping Claude Code installation"
            return 1
        fi

        backup_file "$CLAUDE_CODE_SKILL_FILE" "claude_code"
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will create directory $CLAUDE_CODE_SKILL_DIR"
        info "DRY-RUN: Will copy $SOURCE_SKILL_FILE -> $CLAUDE_CODE_SKILL_FILE"
        return 0
    fi

    mkdir -p "$CLAUDE_CODE_SKILL_DIR"
    cp "$SOURCE_SKILL_FILE" "$CLAUDE_CODE_SKILL_FILE"

    [ -f "$SOURCE_REFERENCE_FILE" ] && cp "$SOURCE_REFERENCE_FILE" "$CLAUDE_CODE_SKILL_DIR/"
    [ -f "$SOURCE_EXAMPLES_FILE" ] && cp "$SOURCE_EXAMPLES_FILE" "$CLAUDE_CODE_SKILL_DIR/"

    if [ -d "$SOURCE_TEMPLATES_DIR" ]; then
        mkdir -p "$CLAUDE_CODE_SKILL_DIR/templates"
        cp -r "$SOURCE_TEMPLATES_DIR"/* "$CLAUDE_CODE_SKILL_DIR/templates/" 2>/dev/null || true
        info "Template files installed to: $CLAUDE_CODE_SKILL_DIR/templates/"
    fi

    if [ -d "$SOURCE_COMMAND_DIR" ]; then
        mkdir -p "$CLAUDE_CODE_SKILL_DIR/command"
        cp -r "$SOURCE_COMMAND_DIR"/* "$CLAUDE_CODE_SKILL_DIR/command/" 2>/dev/null || true
        info "Command files installed to: $CLAUDE_CODE_SKILL_DIR/command/"
    fi

    success "Claude Code Skill installation complete: $CLAUDE_CODE_SKILL_FILE"
}

verify_claude_code() {
    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Skipping verification"
        return 0
    fi

    info "Verifying Claude Code installation..."

    if [ ! -f "$CLAUDE_CODE_SKILL_FILE" ]; then
        error "SKILL.md file does not exist"
        return 1
    fi

    info "✓ SKILL.md file exists"

    if grep -q "^name: " "$CLAUDE_CODE_SKILL_FILE" && grep -q "^description: " "$CLAUDE_CODE_SKILL_FILE"; then
        info "✓ YAML frontmatter format is correct"
    else
        error "YAML frontmatter format is incorrect"
        return 1
    fi

    success "Claude Code verification complete"
}

################################################################################
# Install Cursor Rules
################################################################################

install_cursor_skill() {
    info "Installing Cursor Rules..."

    if [ -f "$CURSOR_RULE_FILE" ]; then
        warn "Target file already exists: $CURSOR_RULE_FILE"
        if [ "${DRY_RUN:-false}" = true ]; then
            info "DRY-RUN: Will overwrite $CURSOR_RULE_FILE"
            return 0
        fi

        if ! confirm "Overwrite existing file?"; then
            info "Skipping Cursor installation"
            return 1
        fi

        backup_file "$CURSOR_RULE_FILE" "cursor"
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will create directory $CURSOR_RULES_DIR"
        info "DRY-RUN: Will copy $SOURCE_SKILL_FILE (removing frontmatter) -> $CURSOR_RULE_FILE"
        return 0
    fi

    mkdir -p "$CURSOR_RULES_DIR"
    
    # Remove YAML frontmatter and copy to Cursor rule file
    # Use awk to skip rows between first and second ---
    awk '/^---$/ { skip++; next; } skip == 1 { next; } { print }' "$SOURCE_SKILL_FILE" > "$CURSOR_RULE_FILE"

    success "Cursor Rules installation complete: $CURSOR_RULE_FILE"
}

# Update Cursor MCP Configuration
configure_cursor_mcp() {
    info "Configuring Cursor MCP server..."

    # Check MCP tools
    if ! check_mcp_tools; then
        warn "MCP tools not fully installed, skipping MCP configuration"
        warn "Skill is still usable, but MCP features will be unavailable"
        return 0
    fi

    # Cursor MCP config is in ~/.cursor/mcp.json
    local cursor_dir="$HOME/.cursor"
    if [ ! -d "$cursor_dir" ]; then
        warn "Cursor directory not found, skipping MCP configuration"
        return 1
    fi

    local cursor_mcp_file="$cursor_dir/mcp.json"
    local script_mcp_file="$SCRIPT_DIR/mcp-config.json"

    if [ ! -f "$script_mcp_file" ]; then
        warn "MCP configuration template not found: $script_mcp_file"
        return 1
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will check and update $cursor_mcp_file"
        return 0
    fi

    # If mcp.json doesn't exist, create it
    if [ ! -f "$cursor_mcp_file" ]; then
        info "Creating Cursor MCP configuration file"
        mkdir -p "$(dirname "$cursor_mcp_file")"
        cat > "$cursor_mcp_file" << 'EOF'
{
  "mcpServers": {}
}
EOF
    fi

    info "Adding MCP configuration to: $cursor_mcp_file"

    # Use Python script to merge JSON configuration
    python3 << 'PYTHON_SCRIPT'
import json
import os

config_file = os.path.expanduser("~/.cursor/mcp.json")
mcp_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mcp-config.json")

# Read existing config
try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except Exception as e:
    print(f"Failed to read configuration file: {e}")
    exit(1)

# Read MCP config
try:
    with open(mcp_file, 'r') as f:
        mcp_config = json.load(f)
except Exception as e:
    print(f"Failed to read MCP configuration: {e}")
    exit(1)

# Ensure mcpServers exists
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Add or update MCP config
for name, mcp_entry in mcp_config.get("mcpServers", {}).items():
    if name in config["mcpServers"]:
        print(f"Updating MCP config: {name}")
    else:
        print(f"Adding MCP config: {name}")
    config["mcpServers"][name] = mcp_entry

# Backup original file
backup_file = f"{config_file}.backup.{os.popen('date +%Y%m%d_%H%M%S').read().strip()}"
with open(backup_file, 'w') as f:
    json.dump(config, f, indent=2)
print(f"Backed up to: {backup_file}")

# Write new config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print("Cursor MCP configuration complete")
PYTHON_SCRIPT

    success "Cursor MCP configuration complete"
    info "Configured servers: context7, sequential-thinking"
}

verify_cursor() {
    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Skipping verification"
        return 0
    fi

    info "Verifying Cursor installation..."

    if [ ! -f "$CURSOR_RULE_FILE" ]; then
        error "Cursor rule file does not exist"
        return 1
    fi

    info "✓ Cursor rule file exists: $CURSOR_RULE_FILE"

    # Verify MCP configuration
    local cursor_mcp_file="$HOME/.cursor/mcp.json"
    if [ -f "$cursor_mcp_file" ]; then
        info "✓ MCP configuration file exists: $cursor_mcp_file"

        # Check MCP configuration
        if command -v python3 >/dev/null 2>&1; then
            local mcp_count=$(python3 -c "
import json
try:
    with open('$cursor_mcp_file', 'r') as f:
        config = json.load(f)
    mcp_servers = config.get('mcpServers', {})
    count = len(mcp_servers)
    print(count)
except:
    print(0)
" 2>/dev/null || echo "0")

            if [ "$mcp_count" -ge 2 ]; then
                info "✓ MCP configuration complete (2/2)"
            elif [ "$mcp_count" -gt 0 ]; then
                warn "MCP configuration partially complete ($mcp_count/2)"
            else
                warn "MCP configuration not detected"
            fi
        else
            local mcp_check=$(grep -c "context7\|sequential-thinking" "$cursor_mcp_file" || echo "0")
            if [ "$mcp_check" -ge 2 ]; then
                info "✓ MCP configuration set ($mcp_check servers)"
            else
                warn "MCP configuration not fully set ($mcp_check/2)"
            fi
        fi
    else
        warn "MCP configuration file does not exist: $cursor_mcp_file"
    fi

    success "Cursor verification complete"
}

################################################################################
# Main Process
################################################################################

show_help() {
    cat << EOF
Programming Assistant Skill One-Click Installation Script v${VERSION}

Usage:
    $SCRIPT_NAME [options]

Options:
    --opencode              Install to OpenCode only
    --claude-code           Install to Claude Code only
    --cursor                Install to Cursor only
    --with-mcp              Configure MCP servers as well (Auto-config context7, sequential-thinking)
    --all                   Full installation (Recommended)
    --dry-run               Preview mode, no actual execution
    --uninstall             Uninstall already installed skill
    --help                  Show this help information

Examples:
    $SCRIPT_NAME                    # Interactive installation
    $SCRIPT_NAME --all --with-mcp   # Full installation, auto-config MCP (Recommended)
    $SCRIPT_NAME --opencode         # Install OpenCode only
    $SCRIPT_NAME --opencode --with-mcp  # Install OpenCode and config MCP
    $SCRIPT_NAME --claude-code      # Install Claude Code only
    $SCRIPT_NAME --cursor           # Install Cursor only
    $SCRIPT_NAME --cursor --with-mcp    # Install Cursor and config MCP
    $SCRIPT_NAME --dry-run          # Preview installation

Installation Paths:
    OpenCode:    $OPENCODE_SKILL_FILE
    Claude Code: $CLAUDE_CODE_SKILL_FILE
    Cursor:      $CURSOR_RULE_FILE

MCP Configuration:
    OpenCode:    ~/.config/opencode/opencode.json (mcp field)
    Cursor:      ~/.cursor/mcp.json (mcpServers field)

MCP Servers:
    - context7: Documentation search (https://mcp.context7.com)
    - sequential-thinking: Structured thinking (@modelcontextprotocol/server-sequential-thinking)

More information: https://github.com/aorizondo/programming-assistant-skill
EOF
}

uninstall_legacy() {
    info "Starting uninstallation..."

    if [ -d "$OPENCODE_SKILL_DIR" ]; then
        info "Uninstalling OpenCode Skill..."
        backup_file "$OPENCODE_SKILL_FILE" "opencode"
        rm -rf "$OPENCODE_SKILL_DIR"
        success "OpenCode Skill uninstalled"
    else
        info "OpenCode Skill not installed"
    fi

    if [ -d "$CLAUDE_CODE_SKILL_DIR" ]; then
        info "Uninstalling Claude Code Skill..."
        backup_file "$CLAUDE_CODE_SKILL_FILE" "claude_code"
        rm -rf "$CLAUDE_CODE_SKILL_DIR"
        success "Claude Code Skill uninstalled"
    else
        info "Claude Code Skill not installed"
    fi

    if [ -f "$CURSOR_RULE_FILE" ]; then
        info "Uninstalling Cursor Rules..."
        backup_file "$CURSOR_RULE_FILE" "cursor"
        rm -f "$CURSOR_RULE_FILE"
        success "Cursor Rules uninstalled"
    else
        info "Cursor Rules not installed"
    fi

    success "Uninstallation complete"
    exit 0
}

main() {
    local install_opencode=false
    local install_claude_code=false
    local install_cursor=false
    local configure_mcp=false
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --opencode)
                install_opencode=true
                shift
                ;;
            --claude-code)
                install_claude_code=true
                shift
                ;;
            --cursor)
                install_cursor=true
                shift
                ;;
            --with-mcp)
                configure_mcp=true
                shift
                ;;
            --all)
                install_opencode=true
                install_claude_code=true
                install_cursor=true
                configure_mcp=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --uninstall)
                uninstall_legacy
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    DRY_RUN=$dry_run

    separator
    info "Programming Assistant Skill Installation Script v${VERSION}"
    separator

    if [ "$DRY_RUN" = true ]; then
        warn "DRY-RUN Mode: No actual actions will be performed"
    fi

    check_source_file

    if [ "$install_opencode" = false ] && [ "$install_claude_code" = false ] && [ "$install_cursor" = false ]; then
        separator
        info "Select platforms to install:"
        info "1) OpenCode"
        info "2) Claude Code"
        info "3) Cursor"
        info "4) Install All"
        info "5) Exit"
        separator

        read -p "Please select [1-5]: " choice
        case $choice in
            1)
                install_opencode=true
                ;;
            2)
                install_claude_code=true
                ;;
            3)
                install_cursor=true
                ;;
            4)
                install_opencode=true
                install_claude_code=true
                install_cursor=true
                ;;
            5)
                info "Exiting installation"
                exit 0
                ;;
            *)
                error "Invalid choice"
                exit 1
                ;;
        esac

        if confirm "Configure MCP servers?"; then
            configure_mcp=true
        fi
    fi

    if [ "$install_opencode" = true ]; then
        separator
        info "=== Installing OpenCode Skill ==="
        separator

        if check_opencode; then
            install_opencode_skill

            if [ "$configure_mcp" = true ]; then
                configure_opencode_mcp
            fi

            verify_opencode
        fi
    fi

    if [ "$install_claude_code" = true ]; then
        separator
        info "=== Installing Claude Code Skill ==="
        separator

        if check_claude_code; then
            install_claude_code_skill
            verify_claude_code
        fi
    fi

    if [ "$install_cursor" = true ]; then
        separator
        info "=== Installing Cursor Rules ==="
        separator

        if check_cursor; then
            install_cursor_skill

            if [ "$configure_mcp" = true ]; then
                configure_cursor_mcp
            fi

            verify_cursor
        fi
    fi

    separator
    success "Installation Complete!"
    separator

    if [ "$DRY_RUN" = false ]; then
        info "Installation Locations:"
        if [ -f "$OPENCODE_SKILL_FILE" ]; then
            info "  OpenCode:    $OPENCODE_SKILL_FILE"
        fi
        if [ -f "$CLAUDE_CODE_SKILL_FILE" ]; then
            info "  Claude Code: $CLAUDE_CODE_SKILL_FILE"
        fi
        if [ -f "$CURSOR_RULE_FILE" ]; then
            info "  Cursor:      $CURSOR_RULE_FILE"
        fi

        info ""
        info "Next Steps:"
        info "1. Restart corresponding IDE/CLI for changes to take effect"
        if [ "$install_opencode" = true ]; then
            info "2. Use in OpenCode: /programming-assistant"
        fi
        if [ "$install_claude_code" = true ]; then
            info "2. Use in Claude Code: /programming-assistant"
        fi
        if [ "$install_cursor" = true ]; then
            info "2. Global rules in Cursor take effect automatically"
        fi
    fi
}

# Execute main function
main "$@"
