# MCP Installation Summary

This document summarizes the complete process of configuring MCP (Model Context Protocol) servers in OpenCode and Cursor.

## Overview

MCP (Model Context Protocol) is a protocol that allows AI assistants to access external tools and data sources in a standardized way. This project integrates two commonly used MCP servers:

1. **context7** - Documentation search tool
2. **sequential-thinking** - Structured thinking tool

## OpenCode MCP Configuration

### Config File Location
- **Configuration File**: `~/.config/opencode/opencode.json`
- **Field**: `mcp`

### Configuration Format

OpenCode uses the following JSON format to configure MCP servers:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    },
    "sequential-thinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
      "enabled": true
    }
  }
}
```

### Configuration Details

#### context7
- **Type**: `remote` (Remote server)
- **URL**: `https://mcp.context7.com/mcp`
- **Description**: Provides documentation search functionality, available when the AI assistant needs to find docs.

#### sequential-thinking
- **Type**: `local` (Local server)
- **Command**: `npx -y @modelcontextprotocol/server-sequential-thinking`
- **Description**: Provides structured thinking functionality, helping the AI with step-by-step reasoning.
- **Dependency**: Requires Node.js and npx.


### Verify Configuration

Run the following command to verify if the MCP servers are configured successfully:

```bash
opencode mcp list
```

Example successful output:

```
┌  MCP Servers
│
●  ✓ context7  connected
│      https://mcp.context7.com/mcp
│
●  ✓ sequential-thinking  connected
│      npx -y @modelcontextprotocol/server-sequential-thinking
│
└  2 server(s)
```

## Cursor MCP Configuration

### Config File Location
- **Configuration File**: `~/.cursor/mcp.json`
- **Field**: `mcpServers`

### Configuration Format

Cursor uses the following JSON format to configure MCP servers:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "autoApprove": ["sequentialthinking"]
    }
  }
}
```

### Configuration Details

#### context7
- **Command**: `npx -y @upstash/context7-mcp`
- **Description**: Provides documentation search functionality.

#### sequential-thinking
- **Command**: `npx -y @modelcontextprotocol/server-sequential-thinking`
- **Auto Approval**: `["sequentialthinking"]`
- **Description**: Provides structured thinking functionality.

## Automatic Installation Script

The `install.sh` script in this project supports automatic configuration of MCP servers.

### Usage

```bash
# Full Installation (Recommended)
./install.sh --all --with-mcp

# Install OpenCode only and configure MCP
./install.sh --opencode --with-mcp

# Install Cursor only and configure MCP
./install.sh --cursor --with-mcp
```

### Script Features

1. **Environment Detection**: Automatically detects installed tools (npx, uvx).
2. **Create Config Files**: Automatically creates configuration files if they don't exist.
3. **Smart Merge**: Intelligently merges MCP configurations without overwriting existing ones.
4. **Backup Original File**: Automatically backs up configuration files.
5. **Verify Installation**: Verifies if the MCP server configuration is complete.

## Manual Configuration Steps

If manual configuration is required, follow these steps:

### OpenCode

1. Open the configuration file:
   ```bash
   vim ~/.config/opencode/opencode.json
   ```

2. Add the `mcp` field and server configurations.

3. Verify configuration:
   ```bash
   opencode mcp list
   ```

### Cursor

1. Open the configuration file:
   ```bash
   vim ~/.cursor/mcp.json
   ```

2. Add the `mcpServers` field and server configurations.

3. Restart Cursor to apply the configuration.

## FAQ

### Q: npx command not found
A: Requires Node.js installation. Visit [https://nodejs.org](https://nodejs.org) to download and install.

### Q: uvx command not found
A: Requires uv installation (Python package manager). Run:
```bash
pip install uv
```

### Q: MCP server connection failed
A: Check the following:
- Internet connection is normal.
- Dependency tools are correctly installed.
- Configuration file format is correct (valid JSON).
- Environment variables are set correctly.

### Q: How to disable an MCP server?
A: In the config, set `"enabled": false` (OpenCode) or delete the corresponding server entry (Cursor).

### Q: How to view MCP server status?
A: OpenCode: `opencode mcp list`

## References

- [Official MCP Documentation](https://modelcontextprotocol.io/)
- [OpenCode MCP Documentation](https://opencode.ai/docs/mcp-servers/)
- [Context7 Documentation](https://github.com/upstash/context7)
- [Sequential Thinking Documentation](https://github.com/arben-adm/mcp-sequential-thinking)

## Changelog

### v1.3.0 (2025-01-16)
- Added automatic MCP configuration functionality.
- Supported MCP configuration for OpenCode and Cursor.
- Smart configuration merge without overwriting existing entries.
- Automatic backup of original config files.
