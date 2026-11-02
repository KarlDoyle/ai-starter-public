# Observability minimum

This document describes lightweight defaults for logs, usage records, health
checks, and alerts. Treat these as starting points and adapt them to each
project's privacy and operational needs.

## 1. Structured logging

- **Services:** write JSON lines to stderr so logs can be filtered and forwarded.
- **CLIs:** provide a `--verbose` option while keeping default output concise.
- Include a timestamp, level, stable event name, relevant metadata, and an error
  summary when needed.
- Never log secrets, personal data, prompts or responses containing private
  information, or raw request bodies.

Use `debug` for diagnostic detail, `info` for lifecycle events, `warn` for a
degraded but continuing operation, and `error` when a human may need to act.

## 2. Usage records

A command-line tool may append one metadata-only JSONL record per invocation
when usage tracking is useful. Include only fields such as timestamp, command,
outcome, duration, and schema version. Do not record prompts, responses, or
sensitive input. Logging should be best-effort so a logging failure never
blocks the primary operation.

## 3. Health checks

- **Services:** expose a health endpoint that checks required dependencies and
  configuration. Return a failure status when a required dependency is
  unavailable.
- **CLIs:** provide a diagnostic command when setup involves several tools or
  credentials. Report which check failed and exit non-zero.
- **Scripts:** propagate failures honestly and explain them on stderr.

## 4. Alerts

Automated failures that require attention should reach a human. Choose a
notification or webhook supported by the deployment environment, and alert on
actionable failures rather than every successful run. Keep credentials in the
platform's secret store or a local environment file that is excluded from Git.

## 5. Adoption checklist

- [ ] Logs use stable event names and avoid sensitive payloads.
- [ ] Optional usage records are metadata-only and schema-versioned.
- [ ] Services or complex CLIs provide a useful health or diagnostic surface.
- [ ] Scripts return non-zero when required work fails.
- [ ] Scheduled jobs deliver actionable failure notifications.
