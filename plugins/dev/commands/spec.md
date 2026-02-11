---
name: dev:spec
description: Create a feature specification using AI interview and compound engineering
argument-hint: <feature-name> [--linear LINEAR-XXX] [--figma <figma-url>]
---

# /dev:spec Command

Create a comprehensive feature specification through an interactive interview, parallel research agents, and technical planning. Outputs a concise spec for stakeholder approval (80% planning, 20% execution).

## Input

<feature_name>$ARGUMENTS</feature_name>

## Workflow

### Phase 1: Setup

1. Parse the feature name from the input
   - If `--linear LINEAR-XXX` is provided, extract the Linear issue ID
2. Determine spec paths:
   - Spec directory: `/specs/{feature-name}/`
   - Concise spec: `/specs/{feature-name}/spec.md`
   - Technical spec: `/specs/{feature-name}/technical-spec.md`
   - Interview notes: `/specs/{feature-name}/interview-notes.md`
   - Research folder: `/specs/{feature-name}/research/`
3. Check if spec directory already exists:
   - If exists, use AskUserQuestion: "Spec already exists. Continue editing or start fresh?"
4. **Check if interview-notes.md already exists:**
   - If `/specs/{feature-name}/interview-notes.md` exists, **skip Phase 2 entirely**
   - Inform user: "Found existing interview notes. Skipping interview and proceeding to Phase 3."
5. Create `/specs/{feature-name}/` and `/specs/{feature-name}/research/` directories if needed
6. If Linear issue provided:
   - Check if Linear MCP is available
   - If available: Read the issue for context, extract acceptance criteria, note Figma/Postman links
   - If not available: Show warning "Linear MCP not configured. Proceeding with manual interview."
7. If `--figma` is provided:
   - Extract the Figma URL from arguments
   - Store for use in Phase 3.1.1
   - Note: Figma MCP must be configured (requires Figma account with Dev or Full seat)

---

### Phase 2: Interview

**SKIP THIS PHASE if interview-notes.md already exists (checked in Phase 1 step 4)**

Conduct a thorough interview using **AskUserQuestion** tool. Ask 2-4 focused questions at a time covering:

**Technical Implementation**
- Architecture approach
- Data models and schemas
- API contracts
- Integration points
- Technology choices

**Requirements**
- Functional requirements (user stories)
- Non-functional requirements (performance, security, scalability)
- Acceptance criteria (seed from Linear if available)

**Design & UX** (if applicable)
- User flows
- Edge cases
- Error states

**Tradeoffs & Risks**
- Alternative approaches considered
- Technical debt implications
- Security concerns
- Performance implications
- Dependencies and blockers

**Testing Strategy**
- Unit test scope
- Integration test scenarios
- E2E test coverage

#### Interview Guidelines

- Use AskUserQuestion with 2-4 focused questions per round
- Ask non-obvious questions and probe deeply on tradeoffs
- Challenge assumptions constructively
- Reference Linear context if loaded
- **Reference codebase research findings** to ask informed questions
- Continue until all sections have sufficient content

**After interview:** Write the interview transcript to `/specs/{feature-name}/interview-notes.md`

---

### Phase 2.5: Sync to Linear (if --linear provided)

**SKIP THIS PHASE if no Linear issue was provided in Phase 1**

After interview completes and interview-notes.md is written, sync the gathered requirements back to the Linear issue:

1. **Extract from interview transcript:**
   - Parse the Acceptance Criteria section (full checkbox list with nesting)
   - Extract Technical Decisions and condense to 3-5 key bullets

2. **Format Technical Notes:**
   Condense technical decisions into 3-5 bullets covering:
   - Authentication/authorization approach
   - Data architecture decisions
   - Key technical constraints
   - Integration points
   - Any TBD items

3. **Read current Linear issue:**
   ```
   mcp__plugin_dev_linear__get_issue(id="{LINEAR-XXX}")
   ```

4. **Update issue description:**
   - Find `## Acceptance Criteria` heading in the existing description
   - If found: Replace entire section content up to next heading
   - If not found: Append new `## Acceptance Criteria` section at end
   - Find `## Technical Notes` heading
   - If found: Replace entire section content up to next heading
   - If not found: Append new `## Technical Notes` section after Acceptance Criteria

5. **Write updated description:**
   ```
   mcp__plugin_dev_linear__update_issue(
     id="{LINEAR-XXX}",
     description="{updated_description_markdown}"
   )
   ```

6. **Confirm success:**
   > "Synced to Linear {LINEAR-XXX}: Acceptance Criteria and Technical Notes updated."

**Section Templates:**

**Acceptance Criteria:**
```markdown
## Acceptance Criteria

- [ ] {requirement 1}
- [ ] {requirement 2}
  - [ ] {sub-requirement}
  - [ ] {sub-requirement}
- [ ] {requirement 3}
```

**Technical Notes:**
```markdown
## Technical Notes

- **{Topic 1}:** {Brief description of technical decision/constraint}
- **{Topic 2}:** {Brief description}
- **{Topic 3}:** {Brief description}
- **{Topic 4}:** {Brief description} (if applicable)
- **{Topic 5}:** {Brief description} (if applicable)
```

---

### Phase 3: Research & Technical Planning

**First, read the interview notes:**
1. Read `/specs/{feature-name}/interview-notes.md` to extract all gathered requirements
2. Parse the interview transcript to identify:
   - Feature summary and goals
   - Functional and non-functional requirements
   - Technical decisions and constraints
   - Risks and tradeoffs discussed
   - Testing strategy

#### 3.1 Repository Research & Context Gathering

Run these three agents **in parallel** using the Task tool:

```
Task(subagent_type="compound-engineering:research:repo-research-analyst", prompt="{feature_description_from_interview}")
Task(subagent_type="compound-engineering:research:best-practices-researcher", prompt="{feature_description_from_interview}")
Task(subagent_type="compound-engineering:research:framework-docs-researcher", prompt="{feature_description_from_interview}")
```

**Save Research Outputs:**
After each agent completes, write its findings to the research folder:
- `/specs/{feature-name}/research/repo-analysis.md` - Repository patterns, similar code, conventions
- `/specs/{feature-name}/research/best-practices.md` - External best practices and recommendations
- `/specs/{feature-name}/research/framework-docs.md` - Framework documentation and examples

**Reference Collection:**
- [ ] Document all research findings with specific file paths (e.g., `app/services/example_service.rb:42`)
- [ ] Include URLs to external documentation and best practices guides
- [ ] Create a reference list of similar issues or PRs (e.g., `#123`, `#456`)
- [ ] Note any team conventions discovered in `CLAUDE.md` or team documentation

#### 3.1.1 Figma Design Specification (if --figma provided)

**ONLY run if `--figma` flag was used in Phase 1**

1. Create design directory: `/specs/{feature-name}/design/`

2. Run Figma design sync agent:
   ```
   Task(subagent_type="compound-engineering:design:figma-design-sync", prompt="
   Extract design specifications from Figma URL: {figma_url}

   Output comprehensive design spec including:
   - Layout structure and component hierarchy
   - Typography (font family, sizes, weights, line heights)
   - Colors (backgrounds, text, borders, accents)
   - Spacing (padding, margins, gaps)
   - Responsive breakpoints
   - Interactive states (hover, focus, active)
   - Shadows, borders, decorative elements
   - Component variants and states
   ")
   ```

3. Save output to `/specs/{feature-name}/design/specification.md`

4. Take screenshot of design and save to `/specs/{feature-name}/design/reference.png`

5. Update technical-spec.md template to include design reference section:
   ```markdown
   ## Design Reference
   See: [design/specification.md](./design/specification.md)
   ![Design Reference](./design/reference.png)
   ```

#### 3.2 SpecFlow Analysis

After research completes, run the spec-flow-analyzer:

```
Task(subagent_type="compound-engineering:workflow:spec-flow-analyzer", prompt="{feature_description_with_research_findings}")
```

**Save SpecFlow Output:**
Write the analysis to `/specs/{feature-name}/research/specflow-analysis.md`

**SpecFlow Analyzer Output:**
- [ ] Review SpecFlow analysis results
- [ ] Incorporate any identified gaps or edge cases
- [ ] Update acceptance criteria based on SpecFlow findings

#### 3.3 Technical Spec Generation

Based on all gathered research, write the technical specification to `/specs/{feature-name}/technical-spec.md`.

**Choose detail level based on complexity:**

---

##### MINIMAL (Simple features)

```markdown
# {Feature Name} Technical Specification

## Overview
[Brief problem/feature description from interview]

## Acceptance Criteria
- [ ] Core requirement 1
- [ ] Core requirement 2

## Context
[Critical information from research]

## Implementation
### {filename}.{ext}
```{language}
// Pseudo-code or skeleton
```

## References
- Related issue: #[issue_number]
- Documentation: [relevant_docs_url]
```

---

##### STANDARD (Recommended for most features)

```markdown
# {Feature Name} Technical Specification

## Overview
[Comprehensive description from interview]

## Problem Statement / Motivation
[Why this matters - from interview]

## Proposed Solution
[High-level approach]

## Technical Considerations
- Architecture impacts
- Performance implications
- Security considerations

## Acceptance Criteria
- [ ] Detailed requirement 1
- [ ] Detailed requirement 2
- [ ] Testing requirements

## Success Metrics
[How we measure success]

## Dependencies & Risks
[What could block or complicate this]

## Implementation

### {filename}.{ext}
```{language}
// Implementation skeleton with key methods
```

## References & Research
- Similar implementations: [file_path:line_number]
- Best practices: [documentation_url]
- Related PRs: #[pr_number]
```

---

##### COMPREHENSIVE (Major features, architectural changes)

```markdown
# {Feature Name} Technical Specification

## Overview
[Executive summary]

## Problem Statement
[Detailed problem analysis from interview]

## Proposed Solution
[Comprehensive solution design]

## Technical Approach

### Architecture
[Detailed technical design]

### Implementation Phases

#### Phase 1: [Foundation]
- Tasks and deliverables
- Success criteria

#### Phase 2: [Core Implementation]
- Tasks and deliverables
- Success criteria

#### Phase 3: [Polish & Optimization]
- Tasks and deliverables
- Success criteria

## Alternative Approaches Considered
[Other solutions evaluated and why rejected - from interview]

## Acceptance Criteria

### Functional Requirements
- [ ] Detailed functional criteria

### Non-Functional Requirements
- [ ] Performance targets
- [ ] Security requirements
- [ ] Accessibility standards

### Quality Gates
- [ ] Test coverage requirements
- [ ] Documentation completeness
- [ ] Code review approval

## Success Metrics
[Detailed KPIs and measurement methods]

## Dependencies & Prerequisites
[Detailed dependency analysis]

## Risk Analysis & Mitigation
[Comprehensive risk assessment from interview]

## Implementation

### {filename}.{ext}
```{language}
// Detailed implementation with all key components
```

## Future Considerations
[Extensibility and long-term vision]

## Documentation Plan
[What docs need updating]

## References & Research

### Internal References
- Architecture decisions: [file_path:line_number]
- Similar features: [file_path:line_number]
- Configuration: [file_path:line_number]

### External References
- Framework documentation: [url]
- Best practices guide: [url]
- Industry standards: [url]

### Related Work
- Previous PRs: #[pr_numbers]
- Related issues: #[issue_numbers]
- Design documents: [links]
```

---

### Phase 4: Distill Stakeholder Summary

**IMPORTANT: No additional questions in this phase. Pure distillation.**

Read the technical spec from Phase 3 (`/specs/{feature-name}/technical-spec.md`) and distill into a concise spec for stakeholder approval.

Write to `/specs/{feature-name}/spec.md` using this **strict template** (enforced):

```markdown
# {Feature Name} Spec

## Metadata
- Project: {project-name}
- Milestone: {milestone-name}
- Linear Issue: {LINEAR-XXX} or N/A
- Interview Date: {date}
- Status: [ ] Draft / [ ] Ready for Review / [x] Approved

## Summary
{1-2 paragraph executive summary}

## Requirements

### Functional
1. {requirement}
2. {requirement}

### Non-Functional
- {requirement}

## Technical Design

### Architecture
{Diagrams, component descriptions}

### Data Model
{Schema changes, new models}

### API Changes
{Endpoints, contracts}

## Implementation Plan

### Phase 1: {Name}
- [ ] Task 1
- [ ] Task 2

## Test Plan
- [ ] Unit tests for: {components}
- [ ] Integration tests for: {flows}
- [ ] E2E tests for: {scenarios}

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|

## Open Questions (Resolved)
| Question | Answer | Decided By |
|----------|--------|------------|

## Interview Notes
See: [interview-notes.md](./interview-notes.md)

## Technical Details
See: [technical-spec.md](./technical-spec.md)

## Research
See: [research/](./research/)

---

## Approval
- [ ] Stakeholder Approved
- Approved date: ___

## Next Steps
After approval, run: `/dev:work specs/{feature-name}/technical-spec.md`
```

---

### Phase 5: Post-Generation Options

Present completion summary and options using **AskUserQuestion**:

```
Spec created at: specs/{feature-name}/

Files:
- spec.md              - Stakeholder spec (strict template)
- technical-spec.md    - Detailed technical specification
- interview-notes.md   - Interview transcript
- research/            - Research agent outputs
  |- repo-analysis.md
  |- best-practices.md
  |- framework-docs.md
  \- specflow-analysis.md
```

**Question:** "Spec ready. What would you like to do next?"

**Options:**
1. **Open in editor** - Open the spec files for review
2. **Deepen research** - Enhance each section with parallel research agents (best practices, performance, UI)
3. **Get feedback** - Run `/plan_review` for feedback from reviewers (DHH, Kieran, Simplicity)
4. **Start `/dev:work`** - Begin implementing this spec locally
5. **Start `/dev:work` on remote** - Begin implementing in Claude Code web (use `&` to run in background)
6. **Create Linear issue** - Create issue in Linear with spec content
7. **Simplify** - Reduce detail level of technical spec

**Based on selection:**

- **Open in editor** -> Run `open specs/{feature-name}/spec.md`
- **Deepen research** -> Run additional targeted research agents on weak sections
- **Get feedback** -> `Skill(skill="compound-engineering:plan_review", args="specs/{feature-name}/technical-spec.md")`
- **`/dev:work`** -> `Skill(skill="dev:work", args="specs/{feature-name}/technical-spec.md")`
- **`/dev:work` on remote** -> Run `/dev:work specs/{feature-name}/technical-spec.md &` to start work in background for Claude Code web
- **Create Linear issue** -> Create Linear issue with spec.md content (requires Linear MCP)
- **Simplify** -> Ask "What should I simplify?" then regenerate simpler version
- **Other** (automatically provided) -> Accept free text for rework or specific changes

**Loop** back to options after Simplify or Other changes until user selects `/dev:work` or `/plan_review`.

---

## Output Structure

```
/specs/{feature-name}/
|- spec.md              # Stakeholder spec (strict template - for approval)
|- technical-spec.md    # Detailed technical spec with implementation guidance
|- interview-notes.md   # Interview transcript
|- design/              # Design specification (if --figma used)
|  |- specification.md  # Figma design spec from design-sync agent
|  \- reference.png     # Design screenshot
\- research/            # Research agent outputs (for reference)
   |- repo-analysis.md
   |- best-practices.md
   |- framework-docs.md
   \- specflow-analysis.md
```

## Usage Examples

```bash
# Basic usage
/dev:spec user-authentication

# With Linear issue reference
/dev:spec user-authentication --linear LINEAR-123

# With Figma design reference
/dev:spec hero-section --figma https://figma.com/file/abc123/design?node-id=45:678

# With both Linear and Figma
/dev:spec user-dashboard --linear LINEAR-123 --figma https://figma.com/file/xyz789/app?node-id=12:34
```

## Key Principles

- **NEVER CODE** - This command produces specs, not implementation
- **80/20 Rule** - 80% planning effort here, 20% execution later
- **Research First** - Parallel agents gather context before planning
- **Interview Notes as Source of Truth** - All specs derive from interview-notes.md
- **Stakeholder Approval Required** - spec.md is the approval artifact
