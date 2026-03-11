# Programming Assistant Skill - Usage Guide


## Overview

This is a professional programming assistant skill based on the ZhiSi Architect methodology, supporting full-stack development and architecture design. This skill integrates MCP tools such as Context7 and sequential-thinking, and can be used in **OpenCode**, **Claude Code**, and **Cursor**.

## Core Features

### Full-Stack Development Support
- **Frontend**: React, Vue, Angular, TypeScript
- **Backend**: Golang, Python, Node.js, Java
- **Database**: PostgreSQL, MySQL, MongoDB, Redis
- **Cloud Services**:
  - **Private Cloud**: Docker, Docker Compose, Kubernetes
  - **Public/Hybrid Cloud**: Primarily Tencent Cloud, Alibaba Cloud, Huawei Cloud, with AWS/Azure/Google Cloud as supplements
- **DevOps**:
  - **CI/CD**: Adapted for both private and public/hybrid cloud scenarios

### MCP Tool Integration
- **Context7**: Get latest documentation and code examples
- **sequential-thinking**: Deep analysis and problem breakdown

## Quick Start

### One-Click Install (Recommended)

```bash
# Full installation (OpenCode + Claude Code + Cursor + MCP)
./install.sh --all --with-mcp
```

This will automatically:
1. ✅ Install to OpenCode (global skill)
2. ✅ Install to Claude Code (global skill)
3. ✅ Install to Cursor (global rules)
4. ✅ Configure MCP servers (context7, sequential-thinking)
5. ✅ Verify installation results

**Restart the corresponding IDE/CLI after completion to use!**

### OpenCode Users

```bash
./install.sh --opencode --with-mcp
```

Installs to: `~/.config/opencode/skill/programming-assistant/SKILL.md`

### Claude Code Users

```bash
./install.sh --claude-code
```

Installs to: `~/.claude/skills/programming-assistant/SKILL.md`

### Cursor Users

```bash
./install.sh --cursor --with-mcp
```

Installs to: `~/.cursor/rules/programming-assistant.md`

### Detailed Documentation

- **Quick Start**: [QUICK-START.md](QUICK-START.md)
- **Skill Details**: [SKILL.md](SKILL.md)
- **MCP Installation**: [MCP-INSTALL.md](MCP-INSTALL.md)
- **OpenCode Configuration**: [OpenCode Skills Official Docs](https://opencode.ai/docs/skills/)
- **OpenCode MCP Docs**: [OpenCode MCP Server Docs](https://opencode.ai/docs/mcp-servers/)
- **Claude Code Config**: [Claude Code Skills Official Docs](https://docs.anthropic.com/en/docs/claude-code/skills)


## Workflow

### Project Initialization
```
Input: New project requirements
Process:
  1. Read SOLUTION.md and TASK.md in project root (if they exist)
  2. If files do not exist:
     - Use sequential-thinking MCP to analyze requirements
     - Generate SOLUTION.md architecture document
     - Break down SOLUTION.md into TASK.md task list (including implementation steps, tech selection, code snippets)
  3. Transform TASK.md into feature_list.json (contains only basic task info and status)
  4. Understand architecture design and technical selection
  5. Check README.md, create if not exists
  6. Create progress.txt
  7. Initialize git repository
Output: Project initialization complete, ready for development
```

### Requirement Analysis
```
Input: User functional requirements
Process:
  1. Deeply understand requirements from the user's perspective
  2. Use sequential-thinking to analyze requirement completeness
  3. Identify missing requirements or gaps, discuss and refine with user
  4. Choose the simplest solution, avoid over-engineering
Output: Requirement confirmation and technical plan
```

### Code Implementation
```
Input: Confirmed requirements and plan
Process:
  1. Execute tasks in TASK.md order
  2. Complete only one task at a time
  3. Use Context7 to query latest docs and examples
  4. Write compliant code (precise, modular, testable)
  5. Run tests to verify functionality
  6. Confirm no regressions in existing features
Output: Testable code units
```
### Problem Solving
```
Input: User-reported issues or errors
Process:
  1. Thoroughly review relevant code
  2. Use sequential-thinking for deep analysis
  3. Use Context7 to query relevant documentation and best practices
  4. Propose multiple solutions, evaluate using decision tree
  5. Select optimal solution and implement
  6. Minimize modifications, ensure no impact on existing features
  7. Test and verify fix effect
Output: Resolved issue and fix code
```

## Usage Examples

### Example 1: New Project Initialization

**User Input**:
```
Help me develop an e-commerce system with features including:
- Product browsing and search
- Shopping cart and order management
- User registration and login
- Payment integration

Frontend uses Vue.js, backend uses Golang 1.22+, database uses PostgreSQL.
```

**Assistant will automatically**:
1. Check if SOLUTION.md and TASK.md exist
2. If not:
   - Use sequential-thinking MCP to analyze requirements
   - Generate SOLUTION.md architecture document
   - Break down SOLUTION.md into TASK.md task list
3. Create progress.txt and feature_list.json
4. Create project directory structure
5. Initialize configuration files
6. Initialize git repository and make first commit

### Example 2: Feature Implementation

**User Input**:
```
Implement user login feature
```

**Assistant will automatically**:
1. Read SOLUTION.md and TASK.md
2. Use Context7 to query JWT best practices
3. Design login API interface
4. Implement backend authentication logic
5. Implement frontend login component
6. Write test cases
7. Run tests to verify

### Example 3: Problem Fix

**User Input**:
```
Session expires too quickly after login, how to adjust?
```

**Assistant will automatically**:
1. Review authentication-related code
2. Use sequential-thinking to analyze cause
3. Use Context7 to query session configuration best practices
4. Propose adjustment to session expiration time
5. Implement modifications
6. Test and verify effect

## Coding Standards

### Must Follow
1. Complete tasks with minimal code
2. Code must be precise, modular, and testable
3. Always consider security
4. Optimize code performance
5. Test after completing each task

### Code Style
- Do not use emojis
- Minimize code comments, write only when necessary
- Follow existing codebase standards and style
- Maintain code clarity and maintainability

### Documentation Standards
- Minimize documentation count
- Keep only main docs: README.md, SOLUTION.md, TASK.md, DEPLOYMENT.md
- Use English for documentation
- Technical terms remain as original (API, React, Vue, etc.)

## Response Rules

### Language Rules
- **Must use English for replies** (Highest Priority)
- Technical terms use original English (API, React, Vue, etc.)
- Product names, brand names use original English
- Code snippets, commands use original English

### Communication Style
- **Concise and Direct**: No fluff, start working immediately
- **No Flattery**: Do not use "Good question", "Excellent", etc.
- **No Status Reporting**: Do not say "I am...", "Let me start..."
- **Use TODOs**: Use todo tools to track progress instead of verbal reports
- **Match User**: Be concise if the user is concise, provide details if needed

## Tool Priority

```
1. Requirement Analysis
   ↓ sequential-thinking (Deep Analysis)

2. Technical Research
   ↓ Context7 (Doc Search)
   ↓ grep/Grep (Code Search)

3. Code Implementation
   ↓ Read/Write/Edit (File Operations)
   ↓ lsp_* (LSP Tools)
   ↓ Bash (Command Execution)

4. Verification & Testing
   ↓ Bash (Run Tests)
   ↓ lsp_diagnostics (Code Check)

5. User Interaction
   ↓ todoread (Get Feedback)
   ↓ todowrite (Progress Tracking)
```

## Quality Assurance

### Code Quality
- Use LSP tools for code inspection
- Run build commands to ensure compilation passes
- Execute test cases to verify functionality
- Check for type errors and warnings

### Testing Strategy
- Write unit tests to cover core logic
- Write integration tests to verify module interactions
- Test immediately after completing each task
- Ensure tests pass before continuing to next task

### Security Check
- Validate user input
- Prevent common vulnerabilities like SQL Injection, XSS, etc.
- Use HTTPS and encrypted transmission
- Follow principle of least privilege

## Best Practices

1. **Understanding before Implementation**: Thoroughly understand requirements before acting
2. **Test Driven**: Test immediately after completing each unit
3. **Minimal Modifications**: Keep modifications as small as possible to reduce risk
4. **Continuous Feedback**: Communicate with user, adjust direction timely
5. **Doc Sync**: Keep code and documentation updated synchronously
6. **Security First**: Always consider security and data protection
7. **Performance Optimization**: Optimize performance while ensuring functionality

## Failure Recovery

### Handling Fix Failures
1. Fix root cause, not just symptoms
2. Re-verify after each fix
3. No shotgun debugging

### Consecutive Failures (3+ times)
1. Stop all editing
2. Roll back to last known working state
3. Record all attempts and failure reasons
4. Report issue to user, seek guidance

## Version History

### v1.3.0 (2025-01-16)
- Added automatic MCP configuration
- Support for OpenCode MCP config (~/.config/opencode/opencode.json)
- Support for Cursor MCP config (~/.cursor/mcp.json)
- Smart config merging, does not overwrite existing config
- Automatic backup of original config files
- Added MCP config verification
- Created detailed MCP installation doc (MCP-INSTALL.md)
- Fixed install script parameter to --with-mcp

### v1.2.1 (2025-01-16)
- Fixed OpenCode skill not taking effect - triggers field in metadata
- Added command directory copy to OpenCode and Claude Code install paths
- Created compatible version for Cursor - removed YAML frontmatter
- Added MCP tool check and fallback mechanism - skip MCP config if not installed
- Fixed install.sh installation logic

### v1.2.0 (2025-01-15)
- Unified version number management, created VERSION file
- Optimized doc structure, clarified responsibilities
- Created MCP-SERVERS.md unified MCP doc
- Created DOCS-STRUCTURE.md doc structure explanation
- Fixed version inconsistency issues
- Improved MCP config management

### v1.1.0 (2025-01-13)
- Added Claude Code support
- Added progressive workflow
- Dual-agent strategy (Initialization Agent + Coding Agent)
- Three key files (progress.txt, feature_list.json, git history)
- Golden Rule (Clean Slate)
- Fixed OpenCode install path (unified to `~/.config/opencode/skill/`)
- Fixed Cursor install path (proper `~/.cursor/rules/` path)
- Unified install.sh and uninstall.sh path definitions
- Auto-detect OpenCode, Claude Code, Cursor installation

### v1.0.0 (2025-01-13)
- Initial version release
- Based on ZhiSi Architect methodology
- Integrated Context7, sequential-thinking, mcp-feedback-enhanced MCP servers
- Support for OpenCode and Cursor platforms

## Contribution

Suggestions and feedback are welcome!

## License

This skill is created based on the ZhiSi Architect methodology, free to use and modify.

---
