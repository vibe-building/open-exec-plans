#!/usr/bin/env bash

# ============================================================
# VibePlans: ExecPlan + Brainstorming Setup Script
# ============================================================
# 兼容工具及配置文件:
# - Codex CLI    → AGENTS.md, .agent/AGENTS.md
# - Claude Code  → CLAUDE.md
# - Cursor IDE   → CLAUDE.md, AGENTS.md
# - Copilot-CLI  → AGENTS.md
# - OpenCode     → AGENTS.md
#
# 用法: ./execplan-setup.sh [codex|claude|cursor|copilot|opencode]
#        默认: codex
# ============================================================

set -euo pipefail

# --- 常量 ---
MARKER="Brainstorming Ideas Into Designs"
PLAN_MARKER="Codex Execution Plans (ExecPlans) with Brainstorming"

AGENT_DIR=".agent"
TEMPLATE_DIR="$AGENT_DIR/template"
PLAN_FILE="$TEMPLATE_DIR/PLAN.md"

# 各工具的配置文件（按优先级排序）
# 使用关联数组，兼容 bash 4+
get_tool_files() {
  local tool="$1"
  case "$tool" in
    codex)    echo "AGENTS.md .agent/AGENTS.md" ;;
    claude)  echo "CLAUDE.md" ;;
    cursor)  echo "CLAUDE.md AGENTS.md" ;;
    copilot) echo "AGENTS.md" ;;
    opencode) echo "AGENTS.md" ;;
    *)       echo "AGENTS.md" ;;
  esac
}

# 核心内容片段（所有工具共用）
INTRO_CONTENT='Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you are building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.'

EXECPLAN_CONTENT="After the design is explicitly approved by the user, you may:
- Create or update an ExecPlan document that the coding agent can follow.
- Use the milestones, logs, and validation steps described in .agent/template/PLAN.md.
- Implement the plan autonomously without asking for \"next steps\" at every stage."

# --- 函数 ---
usage() {
  cat << EOF
用法: $0 [选项]

选项:
  --tool <codex|claude|cursor|copilot|opencode>  指定目标工具 (默认: codex)
  -h, --help                                    显示帮助

示例:
  $0 --tool claude
  $0 codex
EOF
  exit 0
}

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

has_marker() {
  local file="$1"
  grep -q "$MARKER" "$file" 2>/dev/null
}

ensure_dir() {
  mkdir -p "$1"
}

# 追加内容到文件（检测重复）
append_if_missing() {
  local file="$1"
  local section="$2"
  local marker="$3"

  if [[ ! -f "$file" ]]; then
    cat > "$file"
    log "创建: $file"
    return
  fi

  if has_marker "$file"; then
    log "跳过: $file (已包含 Brainstorming)"
    return
  fi

  cat >> "$file" << 'SECTION'

---

SECTION
  echo "$section" >> "$file"
  log "追加: $file"
}

# 创建 PLAN.md 模板
create_plan_template() {
  ensure_dir "$TEMPLATE_DIR"

  cat > "$PLAN_FILE" << 'PLANEOF'
# Codex Execution Plans (ExecPlans) with Brainstorming

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

## 0. Brainstorming Ideas Into Designs (Required Pre‑ExecPlan Phase)

Brainstorming Ideas Into Designs.
Help turn ideas into fully formed designs and specs through natural collaborative dialogue.
Start by understanding the current project context, then ask questions one at a time to refine the idea.
Once you understand what you are building, present the design and get user approval.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
This applies to EVERY project regardless of perceived simplicity.

Before you create or modify an ExecPlan, you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options and get explicit user approval of the chosen design.
4. Only after approval, proceed to author or update the ExecPlan described below.

## 1. How to Use ExecPlans and This PLAN.md

When authoring an executable specification (ExecPlan), follow this PLAN.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLAN.md file. Be thorough in reading (and re‑reading) source material to produce an accurate specification. When creating a spec, start from the skeleton and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an executable specification (ExecPlan), record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, use milestones to implement proof of concepts, "toy implementations", etc., that allow validating whether the user's proposal is feasible. Read the source code of libraries by finding or acquiring them, research deeply, and include prototypes to guide a fuller implementation.

## 2. ExecPlan Skeleton

Every ExecPlan MUST include the following sections. Fill in each section completely.

### Purpose / Big Picture

Explain in a few sentences what the user gets, and how they can see it working. What is the end result that makes this worth doing?

### Progress

A checkbox list tracking granular steps. MUST reflect actual current state.

```
- [x] Completed step (timestamp)
- [ ] Incomplete step
- [ ] Partially done (completed: X; remaining: Y)
```

### Surprises & Discoveries

Record unexpected behaviors, bugs, optimizations, or insights.

```
- Observation: ...
- Evidence: ...
```

### Decision Log

Record each decision made with context and rationale.

```
- Decision: ...
- Rationale: ...
- Date/Author: ...
```

### Outcomes & Retrospective

Summary of achievements, gaps, and lessons learned. Completed at milestones or upon completion.

### Context and Orientation

Describe the current state. Introduce key files and modules. What problem are we solving? What files/systems are involved? What prior designs or docs are relevant?

### Goals and Non‑Goals

- Explicitly list what success looks like.
- Explicitly list what is out of scope.

### Plan of Work

Describe the order in which sections are edited and added. A numbered list of milestones, each small enough to implement and validate.

### Concrete Steps

Specific commands with expected outputs. For each milestone, describe:
- The concrete change to make.
- How you will validate it (tests, manual steps, metrics).

### Validation and Acceptance

How to start/test the system, what to observe. How to verify the whole change end‑to‑end. Which tests or checks MUST pass before considering the plan done.

### Idempotence and Recovery

Explain how to safely repeat steps or recover from failures. Instructions for restarting from the ExecPlan alone.

### Artifacts and Notes

Important outputs, diffs, code snippets.

### Interfaces and Dependencies

Required libraries, modules, services, and their signatures.

## 3. Non‑Negotiable Requirements

NON‑NEGOTIABLE REQUIREMENTS:

- Every ExecPlan must be fully self‑contained.
  - Self‑contained means that in its current form it contains all information needed for an agent to understand and execute the plan, given only the current working tree and this plan file.
- ExecPlans MUST NOT reference prior, superseded specs as required reading.
- ExecPlans MUST be kept up to date as work progresses.
- ExecPlans MUST always reflect the actual state of the work and the next steps.
- Format: Use a single code block with ```md ... ``` to surround the entire plan.
- Use two blank lines after headings.
- Prefer sentences over bullet points where possible.
- Avoid nested triple backticks.

PLANEOF

  log "创建: $PLAN_FILE"
}

# --- 主逻辑 ---
main() {
  local tool="codex"

  # 解析参数
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tool|-t)
        tool="${2:-codex}"
        shift 2
        ;;
      --help|-h)
        usage
        ;;
      codex|claude|cursor|copilot|opencode)
        tool="$1"
        shift
        ;;
      *)
        echo "未知选项: $1"
        usage
        ;;
    esac
  done

  log "开始为 $tool 设置 Brainstorming + ExecPlan..."

  # 1. 处理项目根目录的配置文件
  local tool_files
  tool_files=$(get_tool_files "$tool")
  local files=($tool_files)
  for file in "${files[@]}"; do
    local dir
    dir=$(dirname "$file")
    [[ -n "$dir" && "$dir" != "." ]] && ensure_dir "$dir"

    if [[ ! -f "$file" ]]; then
      cat > "$file" << HEADER
# Project Instructions

## Brainstorming Ideas Into Designs (Pre‑Implementation)

$INTRO_CONTENT

## ExecPlans (Design → Implementation)

$EXECPLAN_CONTENT
HEADER
      log "创建: $file"
    elif ! has_marker "$file"; then
      cat >> "$file" << APPEND

---

## Brainstorming Ideas Into Designs (Pre‑Implementation)

$INTRO_CONTENT

## ExecPlans (Design → Implementation)

$EXECPLAN_CONTENT
APPEND
      log "追加: $file"
    else
      log "跳过: $file (已包含 Brainstorming)"
    fi
  done

  # 2. 创建 .agent/AGENTS.md (仅 Codex 需要)
  if [[ "$tool" == "codex" ]]; then
    ensure_dir "$AGENT_DIR"
    local agent_file="$AGENT_DIR/AGENTS.md"

    if [[ ! -f "$agent_file" ]]; then
      cat > "$agent_file" << AGENTS
# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

$INTRO_CONTENT

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/template/PLAN.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/template/PLAN.md _to the letter_ during implementation.
AGENTS
      log "创建: $agent_file"
    elif ! has_marker "$agent_file"; then
      cat >> "$agent_file" << AGENTS

---

# Repo Agents Instructions

This repository uses a two‑phase workflow:

1. Brainstorming Ideas Into Designs (pre‑implementation)
2. ExecPlans (design → implementation)

## 1. Brainstorming Ideas Into Designs (Pre‑Implementation Phase)

$INTRO_CONTENT

When starting ANY new task (feature, refactor, config, documentation structure, etc.) you MUST:

1. Explore the current project context (files, docs, recent changes).
2. Ask clarifying questions one at a time until the goal and constraints are clear.
3. Propose one or more design options with trade‑offs and a recommendation.
4. Present a concise design/spec and get explicit user approval before any implementation.

## 2. ExecPlans (Design → Implementation Phase)

When writing complex features or significant refactors, AFTER the design has been approved,
use an ExecPlan (as described in .agent/template/PLAN.md) from design to implementation.

ExecPlans are living documents that:
- Are fully self‑contained (no external memory beyond the working tree and the plan file itself).
- Contain milestones, validation steps, and logs of decisions.
- Allow a coding agent to continue work or restart from ONLY the ExecPlan + repo state.

Agents MUST:
- Always follow the Brainstorming phase BEFORE creating or modifying ExecPlans.
- Then follow the ExecPlan rules in .agent/template/PLAN.md _to the letter_ during implementation.
AGENTS
      log "追加: $agent_file"
    else
      log "跳过: $agent_file (已包含 Brainstorming)"
    fi
  fi

  # 3. 创建/更新 PLAN.md 模板
  if [[ -f "$PLAN_FILE" ]] && grep -q "$PLAN_MARKER" "$PLAN_FILE"; then
    log "跳过: $PLAN_FILE (已是最新版模板)"
  else
    create_plan_template
  fi

  echo ""
  log "完成！已为 $tool 配置 Brainstorming + ExecPlan"
  echo ""
  echo "创建/更新的文件:"
  echo "  - ${files[*]}"
  [[ "$tool" == "codex" ]] && echo "  - $AGENT_DIR/AGENTS.md"
  echo "  - $PLAN_FILE"
}

main "$@"
