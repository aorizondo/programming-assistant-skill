# Programming Assistant - Quick Start Guide

## 5-Minute Quick Start

### Recommended Method: One-Click Installation (1 Minute)

Use the provided installation script to automatically complete all configurations:

```bash
# Full Installation (OpenCode + Cursor + MCP)
./install.sh --all --with-mcp
```

This command will:
1. ✅ Install to OpenCode (Global)
2. ✅ Install to Cursor (Global Rules)
3. ✅ Configure MCP Servers (context7, sequential-thinking)
4. ✅ Verify installation results

**After installation, restart OpenCode and Cursor to use!**

Other options:
```bash
./install.sh                    # Interactive Installation
./install.sh --opencode         # Install to OpenCode only
./install.sh --cursor           # Install to Cursor only
./install.sh --dry-run          # Preview installation without execution
./install.sh --help             # Show help information
```

Uninstallation:
```bash
./uninstall.sh --all --with-mcp
```

---

### Traditional Method: Manual Installation (5 Minutes)

#### Step 1: Prepare Files (1 Minute)

#### If you use OpenCode

> 📚 Reference: [OpenCode Skills Official Documentation](https://opencode.ai/docs/skills/)

**One-Click Install (Recommended)**:
```bash
./install.sh --opencode --with-mcp
```

This will automatically:
1. ✅ Install skill to `~/.config/opencode/skill/programming-assistant/`
2. ✅ Configure MCP servers
3. ✅ Verify installation results

**Manual Installation**:
```bash
# Create global skill directory (Note the path)
mkdir -p ~/.config/opencode/skill/programming-assistant

# Copy SKILL.md
cp SKILL.md ~/.config/opencode/skill/programming-assistant/

# Configure MCP servers (Optional)
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
EOF

# Restart OpenCode
```

**Project-Level Installation** (If project-specific config is needed):
```bash
# In project root
cd /your/project

# Create project skill directory
mkdir -p .opencode/skill/programming-assistant

# Copy SKILL.md
cp /path/to/SKILL.md .opencode/skill/programming-assistant/
```

**Important Notes**:
- ✅ Global path: `~/.config/opencode/skill/<name>/SKILL.md`
- ✅ Project path: `.opencode/skill/<name>/SKILL.md`
- ❌ Incorrect path: `~/.opencode/skills/` (Note: not this one!)

#### If you use Cursor

**One-Click Install (Recommended)**:
```bash
./install.sh --cursor --with-mcp
```

**Manual Installation (Global Skills)**:
```bash
# Create Claude skills directory (OpenCode and Cursor compatible)
mkdir -p ~/.claude/skills/programming-assistant

# Copy SKILL.md
cp SKILL.md ~/.claude/skills/programming-assistant/

# Configure MCP servers (Edit ~/.cursor/mcp.json)
# Refer to 3.MCP.txt file

# Restart Cursor to apply changes
```

**Manual Installation (Project-Level)**:
Create a `.cursorrules` file in project root and add:
```markdown
# Reference Programming Assistant Skill

You are a senior software engineer and architect "ZhiSi Architect" with over 10 years of full-stack development experience.

For complete instructions, refer to: programming-assistant.skill.md
```

### Step 3: Start Using (2 Minutes)

#### Scenario 1: Create New Project
```
Help me develop a simple blog system:
- Post list and detail page
- Comments feature
- User registration and login

Frontend with Vue 3, backend with Go, database with PostgreSQL.
```

Assistant will automatically:
1. Confirm requirements with you
2. Generate SOLUTION.md and TASK.md
3. Create project structure
4. Prepare to start development

#### Scenario 2: Implement Feature
```
Implement user registration feature
```

Assistant will automatically:
1. Consult relevant docs (via Context7)
2. Design API interface
3. Implement frontend and backend code
4. Write tests
5. Verify feature

#### Scenario 3: Fix Issue
```
User login token expiration is too short, how to extend?
```

Assistant will automatically:
1. Analyze cause
2. Research best practices
3. Provide solution
4. Implement modifications
5. Test and verify

## Using in OpenCode

> 📚 Official Docs: https://opencode.ai/docs/skills/

### Usage Method

After installation, **restart OpenCode**, and the skill will load automatically:

```bash
opencode
```

OpenCode automatically discovers available skills, and the Agent will call them when needed:
```javascript
skill({ name: "programming-assistant" })
```

You can also explicitly prompt in conversation:
```
Use programming-assistant skill to help me develop an API service
```

### Verification

**Method 1: Check Files**
```bash
# Check global skill
ls -la ~/.config/opencode/skill/programming-assistant/SKILL.md

# Check frontmatter
head -15 ~/.config/opencode/skill/programming-assistant/SKILL.md
```

**Method 2: Start OpenCode**

Upon startup, the Agent should see `programming-assistant` in the available skills list.

### Troubleshooting

**Issue 1: Skill does not appear**

Checklist:
1. ✅ Filename is `SKILL.md` (All caps)
2. ✅ Path is correct: `~/.config/opencode/skill/programming-assistant/SKILL.md`
3. ✅ frontmatter contains `name` and `description`
4. ✅ `name` value is `programming-assistant` (Matches directory name)
5. ✅ OpenCode has been restarted

**Issue 2: Incorrect Path**

❌ Incorrect paths:
- `~/.opencode/skills/` (Missing `config`, and `skills` is plural)
- `~/.opencode/skill/`  (Missing `config`)

✅ Correct path:
- `~/.config/opencode/skill/programming-assistant/SKILL.md`

**Issue 3: MCP tools unavailable**

MCP servers need individual configuration (not included in the skill):

```bash
# Create global MCP configuration
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
EOF
```

Or use the installation script:
```bash
./install.sh --opencode --mcp-auto
```


## Using in Cursor

### Configuration

**Method 1: .cursorrules file**
Create or edit `.cursorrules` in project root and add:
```markdown
# Reference Programming Assistant Skill

You are a senior software engineer and architect "ZhiSi Architect" with over 10 years of full-stack experience.

For complete instructions, refer to: programming-assistant.skill.md
```

**Method 2: .cursorrules.md file**
Create `.cursorrules.md` in project root containing the full skill content:
```markdown
<!-- Copy full content of programming-assistant.skill.md here -->
```

### Usage

Use directly in Cursor Chat without extra commands:
```
Help me develop an e-commerce system: Vue frontend, Go backend
```

## Project Structure Requirements

### Required Files
```
your-project/
├── README.md           # Project description
├── SOLUTION.md         # Architecture design doc
└── TASK.md            # Build task list
```

### Optional Files
```
your-project/
├── DEPLOYMENT.md      # Deployment documentation
├── package.json       # Node.js project
├── go.mod             # Go project
└── requirements.txt   # Python project
```

## Templates

### SOLUTION.md Template
```markdown
# Project Architecture Design

## Project Overview
[Describe goals and core features]

## Tech Stack
- Frontend: [Framework and version]
- Backend: [Framework and version]
- Database: [Type and version]
- Cloud Services:
  - Private Cloud: Docker, Docker Compose, Kubernetes
  - Public/Hybrid Cloud: Primarily Tencent/Alibaba/Huawei, supplements AWS/Azure/GCP
- DevOps:
  - CI/CD: Adapted for both private and public/hybrid cloud
- Other: [Other tools etc.]

## File Structure
```
project/
├── frontend/          # Frontend code
├── backend/           # Backend code
├── database/          # Database scripts
└── docs/              # Documentation
```

## Architecture Description
[Describe role and connection of each part]

## Data Model
[Describe core tables and relations]

## API Design
[List main API endpoints]

## State Management
[Describe storage location and management]
```

### TASK.md Template
```markdown
# Build Task List

## Phase 1: Project Initialization
- [ ] Create project directory structure
- [ ] Initialize frontend project
- [ ] Initialize backend project
- [ ] Configure database connection

## Phase 2: Core Functionality
- [ ] Implement user authentication module
- [ ] Implement data models
- [ ] Implement API interfaces
- [ ] Implement frontend pages

## Phase 3: Testing & Optimization
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Performance optimization
- [ ] Deployment preparation
```

## Core Principles (Keep In Mind)

### Must Follow
1. Complete only one task at a time
2. Test immediately after completion
3. Minimal code for tasks
4. Do not break existing features

### Forbidden
1. Do not use emojis
2. Do not over-engineer
3. No irrelevant modifications
4. Do not skip tests

## MCP Tools Description

### Context7
- **Purpose**: Get latest docs and code examples
- **When to use**: When unfamiliar with a library or framework usage
- **Example**: "Use Context7 to search for Vue 3 Composition API best practices"

### sequential-thinking
- **Purpose**: Deep analysis of complex problems
- **When to use**: When deep thinking or breaking down complex tasks is needed
- **Example**: "Use sequential-thinking to analyze how to design a high-concurrency order system"

## FAQ

### Q: How to update the skill?
A: Replace the corresponding skill file and **restart OpenCode** to apply changes.

### Q: MCP tools not working?
A: Check the following:
1. Confirm `npx` and `uvx` runtimes are installed
2. Refer to config examples in `mcp-config.json`
3. Try manual registration of MCP servers (see Troubleshooting above)
4. Confirm `programming-assistant.skill.json` is loaded correctly

### Q: Why recommendation for global install over project-level?
A: Global install is more stable; OpenCode prioritizes global skills, avoiding uncertainty and potential conflicts from project-level loading.

### Q: Can I customize the skill?
A: Yes, modify existing skill files to add your own rules and workflows.

### Q: Supports other programming languages?
A: Yes, the skill is language-agnostic and supports any programming language or framework.

### Q: How to disable an MCP tool?
A: Edit `programming-assistant.skill.json` and set `enabled` to `false` for that tool.

## File Descriptions

```
SKILL.md                          # OpenCode/Cursor spec format skill file
VERSION                           # Version number (single source of truth)
mcp-config.json                    # MCP server configuration template
install.sh                        # One-click install script
uninstall.sh                      # Uninstall script
programming-assistant.skill.json    # skill configuration file
README.md                         # Project description doc
QUICK-START.md                   # Quick Start Guide (This file)
templates/                        # Templates directory
  ├── progress.txt                # Progress log template
  └── feature_list.json          # Feature list template
```

## Getting Help

### Encountered Issues?
1. Check `README.md` for full documentation
2. Inspect config in `programming-assistant.skill.json`
3. Confirm MCP servers are running
4. Try manual registration:
   ```bash
   opencode mcp add context7 npx -y @upstash/context7-mcp
   opencode mcp add sequential-thinking npx -y @modelcontextprotocol/server-sequential-thinking
   ```

### Skill Up
- Read `programming-assistant.skill.md` for full workflow
- Practice with different project types
- Customize skill rules based on actual needs

## Next Steps

1. Read the full `README.md` for detailed documentation
2. Start your first project
3. Record usage experience and improvement suggestions

Happy Coding!
