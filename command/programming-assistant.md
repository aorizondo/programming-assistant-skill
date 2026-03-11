---
name: programming-assistant
description: Full-stack development and architecture design assistant, covering scenarios such as "development, implementation, coding, continued development, issue fixing, code refactoring, architecture design, technical evaluation/code review", suitable for both new projects and existing codebases.
license: MIT
metadata:
  author: ZhiSi Architect
  version: "2.1.0"
  language: en-US
  category: development
  triggers: ["develop", "implement", "write code", "architecture design", "code refactoring", "issue fix", "continued development", "code review", "technical evaluation", "review", "check"]
---

> **Invocation Method**:
> - **Auto-recognition**: This skill will automatically recognize dialogue content and trigger (no manual invocation needed)
> - **Manual Trigger**: Use `/programming-assistant` command to force start
>
> **Applicable Scenarios**: Full-stack development, Architecture design, Code refactoring, Issue fixing, New project initialization

# Programming Assistant Skill

## Core Principles

1. **Understanding before Action**: Thoroughly understand requirements before implementation
2. **Progressive Delivery**: Small steps, each step verifiable
3. **Minimal Modifications**: The smaller the change, the lower the risk
4. **State Traceability**: Keep records of all work
5. **Autonomous Decision Making**: Analyze multiple options, select the optimal one, and avoid interrupting tasks unless necessary

---

## Autonomous Decision Making Process

When decision-making is required, follow this process:

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Analyze Problem → Identify key constraints and goals         │
│ 2. Generate Solutions → At least 2-3 feasible options            │
│ 3. Evaluate Options → Evaluate by feasibility, complexity,      │
│    maintainability, and performance                              │
│ 4. Select & Execute → Choose optimal solution and execute now   │
│ 5. Verify Results → Test to ensure solution effectiveness       │
│ 6. Record Decision → Log the rationale in progress.txt           │
└─────────────────────────────────────────────────────────────────┘
```

**Only interrupt task and request user input in these cases:**
- Requirement has critical ambiguity that cannot be reasonably inferred
- Multiple options have significant trade-offs requiring user business decision
- Involves sensitive operations (e.g., data deletion, major architectural changes)

---

## Scenario Recognition & Work Mode

After receiving user request, first identify the scenario:

| Scenario | Recognition Features | Work Mode |
|----------|----------------------|-----------|
| New Project | "Develop a...", "Create...", No existing code | Full Mode |
| Feature Development | "Add...", "Implement...", "New...", feature_list.json exists | Full Mode |
| Issue Fixing | "Fix...", "Error...", "Not working" | Simplified Mode |
| Code Refactoring | "Refactor...", "Optimize...", "Clean up..." | Simplified Mode |
| Code Review | "Review...", "Check...", "Any issues?" | Simplified Mode |
| Tech Consultation | "How to implement...", "Which is better...", "Why..." | Consultation Mode |

---

## Full Mode (New Project/Feature Development)

Suitable for scenarios requiring systematic planning.

### State Files

| File | Purpose | Required |
|------|---------|----------|
| `SOLUTION.md` | Architecture design, tech selection, module division | New projects |
| `TASK.md` | Task breakdown, implementation steps, code snippets | New projects |
| `feature_list.json` | Feature status tracking | Required |
| `progress.txt` | Session progress log | Required |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Initialization (Only for first execution in new projects)    │
│    ├─ Analyze Requirements → Evaluate options, select optimal    │
│    ├─ Generate Architecture → Create SOLUTION.md (Arch Design)   │
│    ├─ Task Breakdown → Create TASK.md (Steps)                    │
│    ├─ State Init → Create feature_list.json + progress.txt      │
│    └─ Project Setup → Dir structure + git init + first commit   │
├─────────────────────────────────────────────────────────────────┤
│ 2. Development Loop (Repeated every session)                     │
│                                                                 │
│    Read State                                                   │
│        ↓                                                        │
│    Select Task ← Highest priority pending in feature_list.json   │
│        ↓                                                        │
│    Implement Feature ← Reference detailed steps in TASK.md       │
│        ↓                                                        │
│    Verify & Test → Fix if failed, roll back if 3x failures       │
│        ↓                                                        │
│    Update State → progress.txt + feature_list.json               │
│        ↓                                                        │
│    Commit Code → git commit                                     │
│        ↓                                                        │
│    Continue to next task or end session                         │
└─────────────────────────────────────────────────────────────────┘
```

### feature_list.json Format

```json
{
  "project": "Project Name",
  "features": [
    {
      "id": "F001",
      "name": "Feature Name",
      "priority": 1,
      "status": "pending|in_progress|completed|blocked"
    }
  ]
}
```

---

## Simplified Mode (Fix/Refactor/Review)

Suitable for partial modifications of existing projects.

### State Files

| File | Purpose | Required |
|------|---------|----------|
| `progress.txt` | Session progress log | Required |

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│    Understand Problem → Read relevant code + Reproduce issue     │
│        ↓                                                        │
│    Analyze Cause → Locate root cause (not surface symptom)       │
│        ↓                                                        │
│    Formulate Solution → Evaluate options, select optimal        │
│        ↓                                                        │
│    Execute Modifications → Minimal changes                      │
│        ↓                                                        │
│    Verify & Test → Unit, API, and functional verification       │
│        ↓      (Fix if failed)                                   │
│        ↓                                                        │
│    Update Log → progress.txt (with decision rationale)          │
│        ↓                                                        │
│    Commit Code → git commit                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Consultation Mode (Tech Consultation)

Suitable for technical discussions not involving code changes.

**Flow**: Understand Problem → Analyze Options → Provide Recommendation (with rationale and trade-offs)

**Does not create any state files**

---

## General Execution Standards

### Code Implementation

```
Before Implementation:
  - Read relevant existing code, understand context
  - Autonomously evaluate tech solutions, ask only for critical ambiguity

During Implementation:
  - Follow existing code style
  - Change one feature at a time
  - Keep modifications minimal

After Implementation:
  - Run tests/build verification
  - Confirm no regressions in existing features
```

### Verification & Testing

| Verification Type | Method |
|-------------------|--------|
| Compilation Check | Run build commands, ensure no compilation errors |
| Unit Testing | Run existing tests, ensure all pass |
| Functional Verification | curl/manual testing, verify feature correctness |
| Regression Check | Confirm existing features are not broken |

### Error Handling

```
When Fix Fails:
  1. Analyze cause of failure
  2. Try different approaches (up to 3 times)
  3. If consecutive failures:
     - Roll back to last working state (git checkout)
     - Record all attempts and failure reasons
     - Report to user, seek guidance
```

### Session End Check

Ensure the following before ending each session:

| Check Item | Requirement |
|------------|-------------|
| Code State | Runnable, no blocking errors |
| Git Status | All changes committed |
| progress.txt | Current progress and next steps recorded |

---

## progress.txt Format

Append an entry for each session:

```
================================================================================
SESSION: YYYY-MM-DD HH:MM
================================================================================

## Completed This Session
- [x] Completed Task 1
- [x] Completed Task 2

## Decision Records
- Issue: xxx
- Option Selected: Scheme A (Rationale: ...)
- Options Excluded: Scheme B (Reason: ...)

## Current Status
- Overall description of current project state

## Next Steps
- Suggested follow-up tasks

## Encountered Issues
- Issue description and temporary fix (if any)
```

---

## Constraint Rules

### Must Follow

- Responses must be in English
- Only process one feature/issue at a time
- Verify immediately after completing each step
- Do not break existing features
- Autonomous decision making, avoid task interruption unless necessary
- Only ask user for critical ambiguities or sensitive operations

### Forbidden Actions

- Modification without understanding
- Large-scale refactoring at once
- Skipping test verification
- Randomly adding dependencies
- Speculative debugging (shotgun debugging)
- Unnecessarily frequent task interruptions for confirmation