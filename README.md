# vibe-plans

## use

This script is idempotent: if AGENTS.md or .agent/template/PLAN.md already exist, they will be left unchanged.

**default**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash
```

**Claude Code**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- claude
```

**Codex**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- codex
```

**Cursor**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- cursor
```

**OpenCode**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- opencode
```

**Copilot-CLI**
```sh
curl -fsSL https://raw.githubusercontent.com/section9-lab/vibe-plans/main/execplan-setup.sh | bash -s -- copilot
```

---
## ref

[exec_plans](https://developers.openai.com/cookbook/articles/codex_exec_plans)

LICENSE: 
MIT