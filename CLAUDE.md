# CLAUDE.md — Project Brain
# Keep this file under 200 lines. Every line must earn its place.
# If removing a line won't cause mistakes → remove it.

## WHO I AM
Dev: Ali. Vibe coder. Move fast, ship clean.
Workflow: Claude.ai (planner) → Claude Code (executor).
Default model: Sonnet. Use Opus only for hard architecture decisions.

## RESPONSE STYLE
- Talk like caveman unless I say otherwise: /caveman full
- No filler. No "I'd be happy to". No restating the task.
- Code blocks always exact. Paths always exact.
- If something is bad idea → say it straight, then give better option.

## TOKEN RULES (ENFORCE ALWAYS)
- Never read files I didn't reference unless task requires it
- Never run full test suite — run single targeted test file only
- Never cat node_modules, dist, build, .next, .git, coverage, *.lock
- If context > 70% full → stop, run /compact, then resume
- Filter command output: failures only, no verbose success logs
- Summarize findings before editing — never edit blind
- Use subagents for noisy tasks (test runs, log parsing, grep sweeps)

## TOOLS & MCPS (USE SMARTLY, NOT ALWAYS)
### Context7 — Live Docs
- USE when: working with any lib where version matters
  (Next.js, Prisma, Supabase, shadcn, tRPC, etc.)
- SKIP when: core JS/TS, React basics, stuff you already know well
- Trigger: "use context7 to check [library] docs before writing"

### Playwright — Browser Automation
- USE when: testing UI flows, verifying frontend behavior, e2e tests
- USE when: automation tasks that need a real browser
- SKIP when: pure backend, logic-only, no UI involved
- Trigger: "use playwright to test [flow]"

### GitHub MCP — Git Workflow
- USE when: creating PRs, reading issues, checking comments
- USE when: I say "open a PR" or "create an issue"
- SKIP when: just committing locally
- Trigger: auto on PR/issue commands

### context-mode — Sandbox Noisy Output
- USE when: running test suites, grepping large codebases
- USE when: any command that dumps more than ~50 lines of output
- Rule: verbose output stays in subagent context, only summary returns

### Firecrawl / Tavily — Web Search
- USE when: I reference an external URL or say "look this up"
- USE when: debugging against external API behavior
- SKIP when: internal codebase only

### Caveman Skill
- Default: /caveman full every session
- Drop to /caveman lite when: explaining something new to me
- Drop to normal when: security warnings, destructive ops, architecture
- Never use caveman for: first explanation of a new concept

## WORKFLOW — ALWAYS FOLLOW THIS ORDER
1. EXPLORE: read only referenced files + direct dependencies
2. PLAN: list exact files changing + why, before touching anything
3. IMPLEMENT: follow existing patterns in the codebase
4. VERIFY: run targeted test / build / specific check — never blind ship
5. COMMIT: conventional commit, ≤50 char subject, why over what

## CODE STYLE
- ESM only (import/export) — never CommonJS (require)
- async/await — never raw .then() chains
- TypeScript strict mode — no `any` unless explicitly told
- Destructure imports: import { x } from 'y'
- No inline styles unless Tailwind isn't available
- Component files: PascalCase. Utils/hooks: camelCase.

## VERIFICATION (REQUIRED BEFORE DONE)
- Every task needs a verify step — tests, build check, or visible output
- Run: `[project test command]` — single file, not full suite
- Build check: `[project build command]`
- If can't verify → flag it, don't ship blind

## ERRORS
- Paste full error → go straight to root cause, no symptom suppression
- Write failing test first → fix → verify test passes
- Address root cause always — never suppress errors

## WHAT NOT TO DO
- Never install new packages without asking first
- Never modify .env files
- Never run destructive commands (drop db, delete files) without explicit confirm
- Never use Opus model for routine tasks
- Never read entire codebase on startup — ask what's relevant
- Never skip the plan step for multi-file changes
- Never string together multiple unrelated tasks in one session

## STACK
# UPDATE THIS WHEN STACK CHANGES:
Framework:     [e.g. Next.js 15]
Language:      [e.g. TypeScript]
Styling:       [e.g. Tailwind + shadcn/ui]
Database:      [e.g. Supabase / PostgreSQL]
ORM:           [e.g. Prisma / Drizzle]
Auth:          [e.g. NextAuth / Supabase Auth]
Deployment:    [e.g. Vercel]
Package mgr:   [e.g. pnpm]
Test runner:   [e.g. Vitest / Jest]
Build check:   [e.g. pnpm build]
Test command:  [e.g. pnpm test]
