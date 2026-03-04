# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Instruqt training track for New Relic's **M.A.R.S. Program** (Maturity Architecture & Reliability Simulation) - a game day training environment for incident response using New Relic observability.
The track simulates production incidents in a Kubernetes environment running the OpenTelemetry Demo "Astronomy Shop" application.

## Repository Structure

```
mars-program/
├── track.yml                    # Track configuration (metadata, settings)
├── config.yml                   # Environment config (VM specs, secrets, env vars)
├── track_scripts/               # Track-level setup/cleanup scripts
│   ├── setup-k8s               # Initial k8s cluster setup
│   └── cleanup-k8s             # Track cleanup
└── [01-10]-*/                  # Challenge directories
    ├── assignment.md           # Challenge instructions (frontmatter + markdown)
    ├── check-k8s              # Validation script (bash)
    ├── setup-k8s              # Challenge setup (optional)
    └── cleanup-k8s            # Challenge cleanup
```

### Challenge Pattern

The track follows a pattern of paired challenges:
- **Intro** (01): Creates team workload and New Relic setup
- **Readiness** (02): Prepares teams for incidents
- **Incident pairs** (03-10): Each incident has two challenges:
  - **Failure path** (odd numbers): Students investigate and identify root cause
  - **Golden path** (even numbers): Shows optimal debugging approach

## Key Technologies

- **Instruqt**: Interactive lab platform (documentation available on https://docs.instruqt.com)
- **Kubernetes**: k3s cluster (instruqt/k3s-v1-33-4 image)
- **Terraform**: Manages New Relic resources (sub-accounts, browser apps, alerts, SLOs)
- **New Relic**: Observability platform (GraphQL API)
- **OpenTelemetry Demo**: Example microservices application (cloned from github.com/newrelic/opentelemetry-demo)

## Common Development Tasks

### Modifying Challenge Content

Assignment files use YAML frontmatter + markdown:

```bash
# Edit challenge instructions
vim mars-program/03-mars-incident-1-failure/assignment.md
```

Frontmatter defines Instruqt UI (tabs, layout, time limits). Markdown content is student-facing instructions.

### Working with New Relic GraphQL API

As you're developing any script, you might need to call the New Relics GraphQL API.
In order to do so, you may ask the developer for a user key, which you can the use to introspect the API and test query commands.
Never test GraphQL mutation commands without permission.
You can find examples of working with this GraphQL API in https://github.com/newrelic/docs-website/tree/main/src/content/docs/apis/nerdgraph/examples

```bash
# API endpoint
https://api.newrelic.com/graphql

# Authentication
API-Key: ${NEW_RELIC_API_KEY}
```

#### Example: Finding a workload by name

```graphql
{
  actor {
    entitySearch(query: "accountId = 7783563 AND type = 'WORKLOAD' AND name = 'My Awesome Team'") {
      results {
        entities {
          guid
          name
        }
      }
    }
  }
}
```

**Important**: Use `accountId = X` (not `tags.accountId`) in the entitySearch query filter to scope searches to specific accounts.

### Track Configuration

Key files:
- `track.yml`: Track metadata, timer, UI settings
- `config.yml`: VM specs, environment variables, secrets

Environment variables and secrets in `configy.yml` are available in all scripts.
However, these env variables are not available in your local env unless the developer makes them available.

## Architecture Notes

### Setup Flow

1. **Track-level setup** (`track_scripts/setup-k8s`):
   - Installs Terraform, jq, curl
   - Clones OpenTelemetry Demo repo
   - Creates New Relic sub-account via Terraform
   - Creates browser app and configures monitoring
   - Deploys demo to k8s with Helm
   - Exposes frontend on NodePort 30080
   - Creates generic answer submission script at `/tmp/generic_prompt`

2. **Challenge-level setup** (individual `setup-k8s`):
   - Challenge-specific configuration
   - May inject failures or modify demo behavior

### Validation Pattern

All check scripts follow a common pattern:
1. Read answer from `/tmp/answers.json` (created by `/tmp/generic_prompt`)
2. Validate format (typically semicolon-separated values)
3. Normalize answers (lowercase, trim whitespace)
4. Compare against expected answers and acceptable alternatives
5. Use `fail-message` for failures, exit 0 for success

### Answer Submission Flow

Students interact with `/tmp/generic_prompt` script that:
- Displays current answer
- Accepts new answers via stdin
- Saves to `/tmp/answers.json`
- Prompts student to click Instruqt "Check" button

The prompt is cleared between challenges via `cleanup-k8s` scripts.

### Cleanup Flow

Every challenge will have a `cleanup-k8s` script that cleans up the failure mode that was triggered.

The `track_scripts/cleanup-k8s` script MUST clean up all resources created, including those created via GraphQL.

## Development Guidelines

### Check Script Best Practices

- Provide clear, specific error messages
- Validate input format before checking correctness
- Use `fail-message` for all validation failures
- Exit 0 only on complete success

### Assignment Writing

- Use clear, actionable instructions
- Include expected answer format examples
- Provide time estimates and hints
- Link to relevant New Relic documentation
- Test instructions from student perspective

### Terraform Modules

Located in `opentelemetry-demo/newrelic/terraform/` and cloned from https://github.com/newrelic/opentelemetry-demo/tree/main/newrelic/terraform:
- `nr_account/`: Creates sub-accounts, license keys, users
- `nr_browser/`: Creates browser monitoring app
- `nr_resources/`: Creates alerts, SLOs, dashboards

All modules use variables from environment (TF_VAR_* pattern).