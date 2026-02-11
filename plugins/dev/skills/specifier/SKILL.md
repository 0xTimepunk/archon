---
name: dev:specifier
description: This skill should be used when creating feature specifications. Auto-triggers on requests like "create a spec", "design a feature", "plan a feature", "write a specification", or when discussing planning new functionality.
---

# Dev Specifier

Creates comprehensive feature specifications through an interactive interview process with parallel research agents.

## When This Skill Activates

This skill auto-triggers when the user:
- Asks to "create a spec" or "write a specification"
- Wants to "plan a feature" or "design a new feature"
- Mentions needing to document requirements
- Discusses planning implementation for a new feature
- Says "I need to spec out..." or "Let's plan..."

## Core Principle

**80% planning, 20% execution.** Invest heavily in understanding the problem before writing code.

## Workflow

### Phase 1: Setup

1. Parse the feature name from the user's request
2. Determine spec path: `/specs/{feature-name}/spec.md`
3. Check if spec already exists (offer continue or restart)
4. Create `/specs/` directory if needed

### Phase 2: Interview

Conduct thorough interview using **AskUserQuestion** tool with 2-4 focused questions at a time:

**Technical Implementation**
- Architecture approach
- Data models and schemas
- API contracts
- Integration points

**Requirements**
- Functional requirements (user stories)
- Non-functional requirements
- Acceptance criteria

**Design & UX** (if applicable)
- User flows
- Edge cases
- Error states

**Tradeoffs & Risks**
- Alternative approaches
- Technical debt implications
- Security/performance concerns

**Testing Strategy**
- Unit/integration/E2E scope

### Interview Guidelines

- Use AskUserQuestion with 2-4 focused questions at a time
- Probe deeply on tradeoffs
- Challenge assumptions constructively
- Continue until all sections have sufficient content

### Phase 3: Scope Analysis

Estimate Lines of Code:

| Component | Estimation |
|-----------|------------|
| Backend/API | Endpoints x 50-100 LoC |
| Data models | Models x 30-50 LoC |
| Services | Complexity x 100-200 LoC |
| Tests | ~1.5x implementation |

**If LoC > 2,000:** Warn and recommend splitting into milestones.

### Phase 4: Generate Spec

Write spec to `/specs/{feature-name}/spec.md` using the standard template:

```markdown
# {Feature Name} Spec

## Metadata
- Project: {project}
- Milestone: {milestone}
- Linear Issue: {LINEAR-XXX} or N/A
- Author: {name}
- Interview Date: {YYYY-MM-DD}
- Predicted LoC: {estimate}
- Scope Risk: Within limit / Exceeds 2,000 LoC
- Reviewed: [ ] Pending / [x] Approved by {name}

## Summary
{1-2 paragraph executive summary}

## Requirements
### Functional
### Non-Functional

## Technical Design
### Architecture
### Data Model
### API Changes

## Scope Estimate

## Implementation Plan

## Test Plan

## Risks & Mitigations

## Interview Notes
```

### Phase 5: Finalization

1. Remind user to get stakeholder approval before implementation
2. Mention `/dev:work` command for execution after approval
3. Reference compound engineering for post-implementation knowledge capture

## Example Triggers

- "I need to create a spec for user authentication"
- "Help me plan out the payment integration feature"
- "Let's write a specification for the new dashboard"
- "Can you help me design the notification system?"
- "I want to spec out the API changes"
