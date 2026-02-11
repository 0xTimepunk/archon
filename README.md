# Archon

General-purpose spec-driven development plugin for [Claude Code](https://claude.ai/code). Create specs with AI interviews, execute them with adaptive agent teams.

## What It Does

**`/dev:spec`** — Plan features (80% of effort)
- Interactive AI interview to gather requirements
- Parallel research agents analyze your codebase, best practices, and framework docs
- Generates structured spec for stakeholder approval

**`/dev:work`** — Execute features (20% of effort)
- Reads your approved spec and assesses complexity
- Selects team size: Solo, Lean (2 streams), or Full (3+ streams)
- Creates tasks, spawns agent teammates, and orchestrates parallel execution
- Compounds learnings for future reference

## Installation

```bash
git clone <repo-url> ~/work/archon
cd ~/work/archon
chmod +x install.sh
./install.sh
source ~/.zshrc  # or ~/.bashrc
```

This adds a shell alias so Claude Code loads the plugin automatically.

## Usage

### Create a Spec

```bash
claude
/dev:spec user-authentication
```

With optional integrations:

```bash
# With Linear issue context
/dev:spec user-auth --linear LINEAR-123

# With Figma design reference
/dev:spec hero-section --figma https://figma.com/file/abc123/design?node-id=45:678
```

### Execute a Spec

```bash
/dev:work specs/user-authentication/technical-spec.md
```

The work command will:
1. Read and clarify the spec
2. Assess complexity and select team tier
3. Decompose into tasks
4. Execute (solo or with agent teammates)
5. Run quality checks
6. Compound learnings

## Adaptive Team Strategy

`/dev:work` scores your spec's complexity and picks the right team size:

| Tier | When | Team |
|------|------|------|
| **Solo** | Score 0-25 or 1 parallel stream | Single agent |
| **Lean** | Score 26-50, 2 parallel streams | Lead + 1-2 Builders |
| **Full** | Score 51+, 3+ parallel streams | Lead + 2-4 Builders + Reviewer |

Scoring factors: phase count, file count, package scope, and parallelizable streams.

You can always override the suggested tier.

## Integrations

| Integration | Setup | Used By |
|-------------|-------|---------|
| **Linear** | Auth via Linear MCP at `https://mcp.linear.app/mcp` | `/dev:spec --linear` |
| **Figma** | Requires Dev/Full seat, enable MCP in Figma | `/dev:spec --figma` |
| **compound-engineering** | Available via Task tool (no setup needed) | Both commands |

All integrations are optional. Commands gracefully degrade without them.

## Uninstall

```bash
cd ~/work/archon
./uninstall.sh
source ~/.zshrc
```

## How It Works

### The Philosophy

**80% planning, 20% execution.** Invest in understanding the problem before writing code. Each solved problem is documented, compounding your team's knowledge over time.

### Spec Creation Flow

```
Interview → Research (parallel agents) → SpecFlow Analysis → Technical Spec → Stakeholder Spec
```

### Work Execution Flow

```
Read Spec → Assess Complexity → Select Tier → Decompose Tasks → Execute → Quality Check → Compound
```

### Knowledge Compounding

After completing work, the compound phase captures:
- Problem symptoms and root causes
- Working solutions with code examples
- Prevention strategies
- Cross-references to related issues

Stored in `/specs/knowledge/` for searchable future reference.
