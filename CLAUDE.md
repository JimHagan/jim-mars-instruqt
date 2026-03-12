# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Instruqt training track for New Relic's **M.A.R.S. Program** (Maturity Architecture & Reliability Simulation) - a game day training environment for incident response using New Relic observability.
The track simulates production incidents in a Kubernetes environment running the OpenTelemetry Demo "Astronomy Shop" application.

## Memory Management

**CRITICAL**: Sessions may terminate ungracefully due to VPN configuration. To prevent memory loss:

1. **Create project memory proactively** at the start of any new session:
   - Check if `~/.claude/projects/<project-path>/memory/` exists
   - If not, create it immediately with `MEMORY.md`
   - Initialize with project context and date

2. **Update memory incrementally during sessions**, not at the end:
   - After solving problems or making decisions
   - When learning user preferences or patterns
   - When discovering important architectural details
   - Immediately after any significant work

3. **Memory structure**:
   - `MEMORY.md`: Main file (keep under 200 lines, always loaded)
   - Additional topic files as needed: `debugging.md`, `patterns.md`, etc.

4. **What to save**:
   - Project patterns and conventions confirmed across work
   - Solutions to recurring problems
   - User workflow preferences
   - Key architectural decisions

5. **What NOT to save**:
   - Current session temporary state
   - Incomplete or unverified information
   - Anything duplicating CLAUDE.md

## Repository Structure

```
mars-program/
├── track.yml                    # Track configuration (metadata, settings)
├── config.yml                   # Environment config (VM specs, secrets, env vars)
├── track_scripts/               # Track-level setup/cleanup scripts
│   ├── setup-k8s               # Initial k8s cluster setup
│   └── cleanup-k8s             # Track cleanup
└── [01-13]-*/                  # Challenge directories
    ├── assignment.md           # Challenge instructions (frontmatter + markdown)
    ├── check-k8s              # Validation script (bash)
    ├── setup-k8s              # Challenge setup (optional)
    └── cleanup-k8s            # Challenge cleanup

additional-scenarios/           # Additional incidents not in main track (yet)
└── [13-20]-*/                  # Challenges for incidents 6-9
    ├── assignment.md
    ├── check-k8s
    ├── setup-k8s
    └── cleanup-k8s
```

### Challenge Pattern

The track follows a pattern of paired challenges:
- **Intro** (01): Creates team workload and New Relic setup
- **Readiness** (02): Prepares teams for incidents
- **Incident pairs** (03-12): Each incident has two challenges:
  - **Failure path** (odd numbers): Students investigate and identify root cause
  - **Golden path** (even numbers): Shows optimal debugging approach
- **Outro** (13): Track conclusion

**Challenge-to-Incident Mapping:**
- Challenges 03-04: Incident 1
- Challenges 05-06: Incident 2
- Challenges 07-08: Incident 3
- Challenges 09-10: Incident 4
- Challenges 11-12: Incident 5
- Additional scenarios: Incidents 6-9 (not yet in main track, located in `additional-scenarios/` directory)

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

As you're developing any script, you might need to call the New Relic's GraphQL API.
In order to do so, you may ask the developer for a user key, which you can then use to introspect the API and test query commands.
Never test GraphQL mutation commands without permission.
You can find examples of working with this GraphQL API in https://github.com/newrelic/docs-website/tree/main/src/content/docs/apis/nerdgraph/examples

```bash
# API endpoint
https://api.newrelic.com/graphql

# Authentication
API-Key: ${NEW_RELIC_API_KEY}

# Common queries use entitySearch for workloads, entities, teams
```

### Track Configuration

Key files:
- `track.yml`: Track metadata, timer, UI settings
- `config.yml`: VM specs, environment variables, secrets

Environment variables and secrets in `config.yml` are available in all scripts.
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

### Incident Triggering Pattern

All incidents use **feature flags** managed by flagd to trigger failures. Flags are stored in the `flagd-config` ConfigMap in the `opentelemetry-demo` namespace.

**IMPORTANT**: Always use the ConfigMap approach (not the flagd API) for consistency across all incidents.

#### Standard setup-k8s Pattern

```bash
# 1. Update flagd ConfigMap (set flag defaultVariant to "on" or specific value)
kubectl get configmap flagd-config -n opentelemetry-demo -o json | \
  jq '.data["demo.flagd.json"] |= (fromjson | .flags.<FLAG_NAME>.defaultVariant = "<VALUE>" | tojson)' | \
  kubectl apply -f -

# 2. Restart flagd deployment (to reload ConfigMap)
kubectl rollout restart deployment flagd -n opentelemetry-demo
kubectl rollout status deployment flagd -n opentelemetry-demo --timeout=60s

# 3. Restart affected service deployment (to refresh flag cache)
kubectl rollout restart deployment <SERVICE_NAME> -n opentelemetry-demo
kubectl rollout status deployment <SERVICE_NAME> -n opentelemetry-demo --timeout=60s
```

#### Standard cleanup-k8s Pattern

```bash
# 1. Update flagd ConfigMap (set flag defaultVariant back to "off")
kubectl get configmap flagd-config -n opentelemetry-demo -o json 2>/dev/null | \
  jq '.data["demo.flagd.json"] |= (fromjson | .flags.<FLAG_NAME>.defaultVariant = "off" | tojson)' | \
  kubectl apply -f - >/dev/null 2>&1

# 2. Restart flagd deployment (silent, with error handling)
kubectl rollout restart deployment flagd -n opentelemetry-demo >/dev/null 2>&1
kubectl rollout status deployment flagd -n opentelemetry-demo --timeout=30s >/dev/null 2>&1

# 3. Restart affected service deployment (silent, with error handling)
kubectl rollout restart deployment <SERVICE_NAME> -n opentelemetry-demo >/dev/null 2>&1
kubectl rollout status deployment <SERVICE_NAME> -n opentelemetry-demo --timeout=30s >/dev/null 2>&1
```

#### Feature Flag to Service Mapping

**Main Track (mars-program/):**

| Incident | Feature Flag | Flag Value | Service to Restart |
|----------|--------------|------------|-------------------|
| 1 | `productCatalogFailure` | on/off | `product-catalog` |
| 2 | `paymentUnreachable` | on/off | `checkout` |
| 3 | `imageSlowLoad` | 5sec/off | `frontend` |
| 4 | `paymentFailure` | 25%/off | `payment` |
| 5 | `recommendationCacheFailure` | on/off | `recommendation` |

**Additional Scenarios (additional-scenarios/):**

| Incident | Feature Flag | Flag Value | Service to Restart |
|----------|--------------|------------|-------------------|
| 6 | `cartFailure` | on/off | `cart` |
| 7 | `adHighCpu` | on/off | `ad` |
| 8 | `kafkaQueueProblems` | on/off | `kafka` |
| 9 | `failedReadinessProbe` | on/off | `cart` |

**Key Principles**:
- **Always restart flagd first** - It needs to reload the ConfigMap
- **Always restart the affected service** - It needs to refresh its flag cache
- The service to restart is the one that *consumes* the feature flag (checks it in code)
- Use longer timeouts (60s) in setup-k8s, shorter timeouts (30s) in cleanup-k8s
- cleanup-k8s should suppress errors and continue on failure (use `set -uo pipefail`, not `set -euo pipefail`)

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