#!/bin/bash
################################################################################
# Programming Assistant Skill Uninstallation Script
#
# Features:
#   Uninstall OpenCode Skill
#   Uninstall Cursor Skill
#   Uninstall Claude Code Skill
#   Optional: Uninstall MCP server configuration
#   Automatic backup of deleted files
#
# Usage:
#   ./uninstall.sh                  # Interactive uninstallation
#   ./uninstall.sh --opencode       # Uninstall OpenCode only
#   ./uninstall.sh --cursor         # Uninstall Cursor only
#   ./uninstall.sh --claude-code    # Uninstall Claude Code only
#   ./uninstall.sh --with-mcp        # Uninstall MCP config as well
#   ./uninstall.sh --all            # Full uninstallation
#   ./uninstall.sh --dry-run         # Preview mode
#   ./uninstall.sh --help           # Show help information
#
################################################################################

set -euo pipefail

################################################################################
# Configuration Constants
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
VERSION="1.3.0"

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

# Backup Directories (Consistent with install.sh)
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
    
    if [ -e "$file" ]; then
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
# Uninstall OpenCode Skill
################################################################################

uninstall_opencode_skill() {
    info "Uninstalling OpenCode Skill..."

    if [ ! -d "$OPENCODE_SKILL_DIR" ] && [ ! -f "$OPENCODE_SKILL_FILE" ]; then
        info "OpenCode Skill not installed"
        return 0
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will delete $OPENCODE_SKILL_DIR"
        return 0
    fi

    if ! confirm "Confirm deleting OpenCode Skill?"; then
        info "Skipping OpenCode uninstallation"
        return 1
    fi

    backup_file "$OPENCODE_SKILL_DIR" "opencode"
    rm -rf "$OPENCODE_SKILL_DIR"

    success "OpenCode Skill uninstalled"
}

################################################################################
# Uninstall Claude Code Skill
################################################################################

uninstall_claude_code_skill() {
    info "Uninstalling Claude Code Skill..."

    if [ ! -d "$CLAUDE_CODE_SKILL_DIR" ] && [ ! -f "$CLAUDE_CODE_SKILL_FILE" ]; then
        info "Claude Code Skill not installed"
        return 0
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will delete $CLAUDE_CODE_SKILL_DIR"
        return 0
    fi

    if ! confirm "Confirm deleting Claude Code Skill?"; then
        info "Skipping Claude Code uninstallation"
        return 1
    fi

    backup_file "$CLAUDE_CODE_SKILL_DIR" "claude_code"
    rm -rf "$CLAUDE_CODE_SKILL_DIR"

    success "Claude Code Skill uninstalled"
}

# Uninstall OpenCode MCP Server
uninstall_opencode_mcp() {
    info "Uninstalling OpenCode MCP server configuration..."

    if ! command_exists opencode; then
        warn "OpenCode CLI not available"
        return 1
    fi

    local mcp_servers=("context7" "sequential-thinking")

    for server in "${mcp_servers[@]}"; do
        info "Uninstalling MCP server: $server"
        if [ "${DRY_RUN:-false}" = true ]; then
            info "DRY-RUN: opencode mcp remove $server"
        else
            opencode mcp remove "$server" 2>/dev/null || warn "Uninstallation failed or not existing: $server"
        fi
    done

    success "OpenCode MCP configuration cleaned"
}

################################################################################
# Uninstall Cursor Skill
################################################################################

uninstall_cursor_skill() {
    info "Uninstalling Cursor Skill..."

    if [ ! -f "$CURSOR_RULE_FILE" ]; then
        info "Cursor Skill not installed"
        return 0
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will delete $CURSOR_RULE_FILE"
        return 0
    fi

    # Confirm delete
    if ! confirm "Confirm deleting Cursor Skill?"; then
        info "Skipping Cursor uninstallation"
        return 1
    fi

    # Backup
    backup_file "$CURSOR_RULE_FILE" "cursor"

    # Delete
    rm -f "$CURSOR_RULE_FILE"

    # If rules directory is empty, delete it
    if [ -d "$CURSOR_RULES_DIR" ] && [ -z "$(ls -A "$CURSOR_RULES_DIR")" ]; then
        rmdir "$CURSOR_RULES_DIR"
        info "Deleted empty directory: $CURSOR_RULES_DIR"
    fi

    success "Cursor Skill uninstalled"
}

# Clean Cursor MCP Config (Prompt user for manual action)
uninstall_cursor_mcp() {
    info "Cursor MCP Configuration..."

    local cursor_mcp_file="$CURSOR_DIR/mcp.json"

    if [ ! -f "$cursor_mcp_file" ]; then
        info "Cursor MCP configuration file does not exist"
        return 0
    fi

    if [ "${DRY_RUN:-false}" = true ]; then
        info "DRY-RUN: Will prompt to check $cursor_mcp_file"
        return 0
    fi

    warn "Please check and edit manually: $cursor_mcp_file"
    info "Following MCP servers might need cleaning:"
    info "  - context7"
    info "  - sequential-thinking"
    info ""
    info "Tip: Edit mcp.json file, delete corresponding mcpServers configuration entries"
}

################################################################################
# Main Process
################################################################################

show_help() {
    cat << EOF
Programming Assistant Skill Uninstallation Script v${VERSION}

Usage:
    $SCRIPT_NAME [options]

Options:
    --opencode              Uninstall OpenCode only
    --claude-code           Uninstall Claude Code only
    --cursor                Uninstall Cursor only
    --with-mcp              Uninstall MCP config as well
    --all                   Full uninstallation (Recommended)
    --dry-run               Preview mode, no actual execution
    --help                  Show this help information

Examples:
    $SCRIPT_NAME                    # Interactive uninstallation
    $SCRIPT_NAME --all --with-mcp   # Full uninstallation (Recommended)
    $SCRIPT_NAME --opencode         # Uninstall OpenCode only
    $SCRIPT_NAME --claude-code      # Uninstall Claude Code only
    $SCRIPT_NAME --dry-run          # Preview uninstallation

Warning:
    Uninstallation is irreversible, all deleted files will be backed up to the .backup folder in the corresponding installation directory.

More information: https://github.com/aorizondo/programming-assistant-skill
EOF
}

main() {
    local uninstall_opencode=false
    local uninstall_claude_code=false
    local uninstall_cursor=false
    local uninstall_mcp_local=false
    local dry_run=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --opencode)
                uninstall_opencode=true
                shift
                ;;
            --claude-code)
                uninstall_claude_code=true
                shift
                ;;
            --cursor)
                uninstall_cursor=true
                shift
                ;;
            --with-mcp)
                uninstall_mcp_local=true
                shift
                ;;
            --all)
                uninstall_opencode=true
                uninstall_claude_code=true
                uninstall_cursor=true
                uninstall_mcp_local=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
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
    info "Programming Assistant Skill Uninstallation Script v${VERSION}"
    separator

    if [ "${DRY_RUN:-false}" = true ]; then
        warn "DRY-RUN Mode: No actual actions will be performed"
    fi

    warn "This action will delete installed skill files"
    info "Backups will be saved in corresponding installation directories:"
    info "  OpenCode:    $OPENCODE_BACKUP_DIR"
    info "  Claude Code: $CLAUDE_CODE_BACKUP_DIR"
    info "  Cursor:      $CURSOR_BACKUP_DIR"
    echo ""

    if [ "$uninstall_opencode" = false ] && [ "$uninstall_claude_code" = false ] && [ "$uninstall_cursor" = false ]; then
        separator
        info "Select platforms to uninstall:"
        info "1) OpenCode"
        info "2) Claude Code"
        info "3) Cursor"
        info "4) Uninstall All"
        info "5) Exit"
        separator

        read -p "Please select [1-5]: " choice
        case $choice in
            1)
                uninstall_opencode=true
                ;;
            2)
                uninstall_claude_code=true
                ;;
            3)
                uninstall_cursor=true
                ;;
            4)
                uninstall_opencode=true
                uninstall_claude_code=true
                uninstall_cursor=true
                ;;
            5)
                info "Exiting uninstallation"
                exit 0
                ;;
            *)
                error "Invalid choice"
                exit 1
                ;;
        esac

        if confirm "Uninstall MCP server configuration?"; then
            uninstall_mcp_local=true
        fi
    fi

    if [ "${DRY_RUN:-false}" = false ]; then
        separator
        warn "About to perform uninstallation:"
        [ "$uninstall_opencode" = true ] && info "  - OpenCode Skill"
        [ "$uninstall_claude_code" = true ] && info "  - Claude Code Skill"
        [ "$uninstall_cursor" = true ] && info "  - Cursor Rules"
        [ "$uninstall_mcp_local" = true ] && info "  - MCP server configuration"
        separator
        echo ""

        if ! confirm "Confirm continuation?"; then
            info "Uninstallation cancelled"
            exit 0
        fi
        echo ""
    fi

    if [ "$uninstall_opencode" = true ]; then
        separator
        info "=== Uninstalling OpenCode Skill ==="
        separator

        uninstall_opencode_skill

        if [ "$uninstall_mcp_local" = true ]; then
            uninstall_opencode_mcp
        fi
    fi

    if [ "$uninstall_claude_code" = true ]; then
        separator
        info "=== Uninstalling Claude Code Skill ==="
        separator

        uninstall_claude_code_skill
    fi

    if [ "$uninstall_cursor" = true ]; then
        separator
        info "=== Uninstalling Cursor Rules ==="
        separator

        uninstall_cursor_skill

        if [ "$uninstall_mcp_local" = true ]; then
            uninstall_cursor_mcp
        fi
    fi

    separator
    success "Uninstallation Complete!"
    separator

    if [ "${DRY_RUN:-false}" = false ]; then
        info "Backup locations:"
        info "  OpenCode:    $OPENCODE_BACKUP_DIR"
        info "  Claude Code: $CLAUDE_CODE_BACKUP_DIR"
        info "  Cursor:      $CURSOR_BACKUP_DIR"
        info ""
        info "If recovery is needed, please use files in corresponding backup directories"
    fi
}

# Execute main function
main "$@"
