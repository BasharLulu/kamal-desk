# Contributing to Kamal Desk

Thanks for your interest in Kamal Desk! Contributions are welcome.

## Getting started

1. Fork the repository and clone your fork.
2. Run `bin/setup` to install dependencies and prepare the database.
3. Start the app (see [README.md](README.md#running)).

## Development workflow

1. Create a branch from `main` for your change.
2. Make focused changes — one logical fix or feature per pull request.
3. Test manually against a real Kamal project when your change touches deploy, logs, console, or CLI integration.
4. Open a pull request with a clear description of what changed and why.

## What to work on

Check [open issues](https://github.com/BasharLulu/kamal-desk/issues) or [PLAN.md](PLAN.md) for deferred work (tests, auto-discovery improvements, keyboard shortcuts, etc.).

## Code style

- Match existing patterns in the codebase (service objects under `app/services/kamal/`, Hotwire/Stimulus for interactivity).
- Kamal commands run via `Kamal::CommandRunner` with `chdir:` — never use `Dir.chdir` in request/job code.
- Never expose raw `kamal config` output or `.kamal/secrets` in the UI.

## Reporting bugs

Open an issue with:

- What you expected vs. what happened
- Steps to reproduce
- Ruby/Rails/Kamal versions
- Relevant logs (redact secrets)

## Questions

Open a [GitHub Discussion](https://github.com/BasharLulu/kamal-desk/discussions) or issue if you're unsure where to start.
