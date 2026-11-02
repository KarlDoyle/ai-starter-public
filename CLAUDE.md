# Contributor Guide

## Project

AI Starter provides three copy-based templates: a Next.js AI app, a Python AI
service, and a keyword-retrieval tool. Each template is self-contained and
inherits its checks from `_standard/`.

## Development

- Keep credentials and real environment files out of the repository. Commit only
  empty or clearly documented example values in `.env.example`.
- Keep templates generic and safe to copy into new projects.
- Include prompts, smoke evaluations, tests, and security guidance in each
  template.
- Run the repository test suite and the relevant template checks before opening
  a pull request.

See `docs/standard.md` and `docs/project-generation.md` for the build rules
and template inheritance checklist.
