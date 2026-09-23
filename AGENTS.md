# AGENTS.md — AI entry (auto-read by Claude / Codex / Opencode)

> Full spec: `PROJECT_BLUEPRINT.md`. Token-safe splits: `docs/`. Start at `docs/00_AI_START_HERE.md`.

## Map

- Why/scope → `docs/01_vision.md`
- Who + routes + nav → `docs/02_users-navigation.md`
- What (F1–F6) → `docs/03_features.md`
- How (monorepo/OOP/UseCase/dual-deploy) → `docs/04_architecture.md`
- Data + rules → `docs/05_database-schema.md`
- Strings/i18n → `docs/06_i18n-strings.md`
- Code rules → `docs/07_coding-standards.md`
- UI/motion tokens → `docs/08_ui-motion.md`
- Admin powers → `docs/09_admin.md`
- Tasks + DoD → `docs/10_plan-tasks.md` (pick ONE pending id per session)
- Memory → `docs/PROGRESS_LOG.md` (append every session end + commit)

## Laws

Monorepo `apps/public + apps/admin + packages/shared`; `apps/* → packages/shared` only; UI never touches Firebase; all copy via `t()`; ESLint/Prettier/Husky gate CI; Conventional Commits; `main` always deployable.

## Doc-update contract (every agent, every session — blocks DONE)

No task is complete without its doc trail. Next AI must resume from docs alone, zero chat history assumed.
- Task state: tick `[x]` / add sub-task id in `docs/10_plan-tasks.md`.
- Memory: append `date | task | did | next | blockers` to `docs/PROGRESS_LOG.md`.
- In-place sync: schema→`05`, strings→`06`, routes/nav→`02`, rules/patterns→`07`/`08`, scope→`01`+`10`.
- One commit = code + docs together. End reply: `DONE <id> | verified: <cmd> | next: <next-id>`.
