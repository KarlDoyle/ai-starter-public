# Local verification

`scripts/verify-all.sh` runs the standard local checks for Node and Python
projects. With no arguments, it checks this repository. Pass one or more
project directories to check a selected set:

```bash
scripts/verify-all.sh
scripts/verify-all.sh ../service-a ../service-b
scripts/verify-all.sh --no-color ../service-a ../service-b
```

It exits non-zero if any selected project fails. Missing directories are
reported as skipped, and unknown project types are reported without being
treated as passing.

## Checks

- **Node / TypeScript:** optional `typecheck` and `lint` scripts, plus the
  `test` script. When a pinned package manager cannot be downloaded, the
  script can fall back to project-local runners.
- **Python:** `pytest` through `uv run`, an existing virtual environment, or
  `python3 -m pytest`.

The script sets `COREPACK_ENABLE_DOWNLOAD_PROMPT=0` so a package-manager
version download cannot pause for interactive input. Its output includes a
summary of passing, failing, and skipped projects.
