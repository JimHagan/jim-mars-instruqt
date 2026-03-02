# M.A.R.S. Program - Challenge Pattern Documentation

This document explains how to create instructor-controlled incident challenges for the M.A.R.S. Program Game Days.

## Overview

Each challenge follows this workflow:

1. **Setup**: Challenge begins, feature flag is enabled to trigger an incident
2. **Investigation**: Teams investigate the incident in New Relic
3. **Submission**: Teams submit answers via terminal command
4. **Validation**: Check script validates answers with flexible matching
5. **Resolution**: If correct, feature flag is disabled automatically
6. **Cleanup**: Challenge ends, ensuring clean state for next challenge

## Challenge Structure

```
mars-program/
├── XX-challenge-name/
│   ├── assignment.md          # Challenge description and instructions
│   ├── setup-k8s              # Script that triggers the incident
│   ├── check-k8s              # Script that validates answers
│   ├── cleanup-k8s            # Script that ensures clean state
│   └── www/
│       ├── index.html         # (Optional) Web form for answers
│       └── submit_answers.sh  # Terminal script for submitting answers
```

## Creating a New Challenge

### Step 1: Choose a Failure Scenario

The OpenTelemetry Demo includes several built-in feature flags:

- `productCatalogFailure` - High latency in product catalog service
- `recommendationServiceFailure` - Errors in recommendation service
- `checkoutServiceFailure` - Checkout service failures
- `cartServiceFailure` - Shopping cart issues

You can also create custom failure scenarios using:
- Chaos engineering tools (LitmusChaos, Steadybit, Gremlin)
- Custom application code changes
- Resource constraints (CPU/memory limits)

### Step 2: Create the Assignment (assignment.md)

```yaml
---
slug: incident-name
id: unique-id
type: challenge
title: "Incident X: Brief Description"
teaser: One-line summary
tabs:
- title: Shell
  type: terminal
  hostname: k8s
- title: Questions
  type: website
  url: http://k8s:8080
difficulty: basic
timelimit: 1800  # 30 minutes in seconds
---

# 🚨 Incident Alert: [Title]

[Description of the incident and business impact]

## Your Mission

Use New Relic to investigate this incident and identify:

1. **[Question 1]**
2. **[Question 2]**
3. **[Question 3]**

## Getting Started

1. Open your New Relic account
2. Navigate to the Astronomy Shop application
3. Investigate using APM, distributed tracing, logs, etc.
4. Submit answers using: `submit-answers`
5. Click the **Check** button to validate

## Important Notes

- ⏱️ You have **30 minutes** to resolve this incident
- 💡 Ask your instructor for hints after 15 minutes
- 🎯 Answer correctly to automatically resolve the incident

Good luck! 🚀
```

### Step 3: Create the Setup Script (setup-k8s)

```bash
#!/bin/bash
set -euo pipefail

echo "=== Setting up Incident X ==="

# Wait for OTel Demo to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=opentelemetry-demo -n default --timeout=300s

# Enable the feature flag
FEATURE_FLAG_POD=$(kubectl get pods -n default -l app.kubernetes.io/component=featureflagservice -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n default $FEATURE_FLAG_POD -- curl -X POST http://localhost:8081/ffsapi/v1/featureflags \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "yourFeatureFlagName",
    "description": "Description of what this triggers",
    "enabled": true
  }'

# Create state files
echo "$(date +%s)" > /tmp/incidentX_start_time
echo "0" > /tmp/check_attempt_count
echo "0" > /tmp/last_check_time

# Start web server (if using web form)
cd /root/mars-program/XX-challenge-name/www
python3 -m http.server 8080 > /tmp/webserver.log 2>&1 &
echo $! > /tmp/webserver.pid

# Copy submit script
cp /root/mars-program/XX-challenge-name/www/submit_answers.sh /usr/local/bin/submit-answers
chmod +x /usr/local/bin/submit-answers

echo "✅ Incident triggered!"
echo "📝 To submit answers, run: submit-answers"
```

Make it executable:
```bash
chmod +x setup-k8s
```

### Step 4: Create the Check Script (check-k8s)

Use the template from `01-mars-program-incident-1/check-k8s` and customize:

**Key Configuration Variables:**

```bash
# Expected answers (lowercase)
EXPECTED_SERVICE="servicename"
EXPECTED_ISSUE_TYPE="issue description"
EXPECTED_ROOT_CAUSE="root cause description"

# Alternative acceptable answers
ALT_SERVICE_ANSWERS=("alt1" "alt2" "alt3")
ALT_ISSUE_ANSWERS=("alt1" "alt2")
ALT_ROOT_CAUSE_ANSWERS=("alt1" "alt2")

# Answer file location
ANSWER_FILE="/tmp/incidentX_answers.json"

# Feature flag to disable on success
FEATURE_FLAG_NAME="yourFeatureFlagName"
```

**Important:** Update the feature flag disable command:

```bash
kubectl exec -n default "$FEATURE_FLAG_POD" -- curl -X PUT http://localhost:8081/ffsapi/v1/featureflags/yourFeatureFlagName \
  -H 'Content-Type: application/json' \
  -d '{"enabled": false}'
```

Make it executable:
```bash
chmod +x check-k8s
```

### Step 5: Create the Submit Answers Script

Copy `01-mars-program-incident-1/www/submit_answers.sh` and update:

```bash
# Change the JSON output file name
cat > /tmp/incidentX_answers.json <<EOF
{
  "service": "$SERVICE",
  "issue_type": "$ISSUE_TYPE",
  "root_cause": "$ROOT_CAUSE"
}
EOF
```

### Step 6: Create the Cleanup Script (cleanup-k8s)

```bash
#!/bin/bash
set -euo pipefail

echo "=== Cleaning up Incident X ==="

# Disable feature flag
FEATURE_FLAG_POD=$(kubectl get pods -n default -l app.kubernetes.io/component=featureflagservice -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [[ -n "$FEATURE_FLAG_POD" ]]; then
    kubectl exec -n default "$FEATURE_FLAG_POD" -- curl -X PUT http://localhost:8081/ffsapi/v1/featureflags/yourFeatureFlagName \
      -H 'Content-Type: application/json' \
      -d '{"enabled": false}' 2>/dev/null || true
fi

# Stop web server
if [[ -f /tmp/webserver.pid ]]; then
    kill $(cat /tmp/webserver.pid) 2>/dev/null || true
fi

# Clean up state files
rm -f /tmp/incidentX_start_time
rm -f /tmp/check_attempt_count
rm -f /tmp/last_check_time
rm -f /tmp/incidentX_answers.json
rm -f /tmp/webserver.pid

echo "✅ Cleanup complete"
```

Make it executable:
```bash
chmod +x cleanup-k8s
```

## Instructor Workflow

### Before the Game Day

1. **Test all challenges**: Run through each challenge to verify functionality
2. **Prepare New Relic**: Ensure alerts, dashboards, and SLOs are configured
3. **Document answers**: Create an answer key for instructors

### During the Game Day

1. **Monitor progress**: Check team progress in Instruqt dashboard
2. **Provide hints**: After 15 minutes, offer hints to struggling teams
3. **Provide answers**: If needed, give teams the answers directly to advance
4. **Track metrics**: Note completion times and attempt counts for scoring

## Answer Validation Strategy

### Flexible Matching

The check script uses flexible matching to prevent frustration:

- **Case-insensitive**: "CheckoutService" = "checkoutservice"
- **Whitespace trimmed**: " checkout service " = "checkout service"
- **Multiple alternatives**: Accepts synonyms and variations

### Preventing Guessing

To prevent rapid-fire guessing:

- **Multiple questions**: Require all 3 to be correct
- **No multiple choice**: Free-text answers only
- **No hints in errors**: Don't reveal which answers are wrong

### Setting Good Questions

Good questions require specific investigation:

1. **Service name**: Forces them to identify the exact service
2. **Symptom**: Forces them to look at metrics (latency, errors, etc.)
3. **Root cause**: Forces them to use distributed tracing or logs

**Example:**
```
Question 1: Which service is the root cause?
Expected: productcatalogservice

Question 2: What metric indicates the problem?
Expected: high latency (or: slow response time, increased duration)

Question 3: What is causing this behavior?
Expected: feature flag enabled (or: product catalog failure, catalog service failure)
```

## Available Feature Flags

The OpenTelemetry Demo includes these flags (check the latest version):

| Flag Name | Effect | Services Affected |
|-----------|--------|-------------------|
| `productCatalogFailure` | High latency in product catalog | productcatalogservice, checkoutservice, frontend |
| `recommendationCache` | Disable recommendation cache | recommendationservice |
| `adServiceFailure` | Errors in ad service | adservice |
| `cartServiceFailure` | Cart operations fail | cartservice, checkoutservice |

Check the current flags:
```bash
kubectl exec -n default <featureflag-pod> -- curl http://localhost:8081/ffsapi/v1/featureflags
```

## Testing Your Challenge

### Local Testing

1. **Test setup script**:
   ```bash
   cd mars-program/XX-challenge-name
   ./setup-k8s
   ```

2. **Verify incident is triggered**: Check New Relic for alerts

3. **Test answer submission**:
   ```bash
   submit-answers
   # Enter test answers
   ```

4. **Test check script** (simulating Instruqt check):
   ```bash
   ./check-k8s
   ```

5. **Test cleanup**:
   ```bash
   ./cleanup-k8s
   ```

6. **Verify resolution**: Check that feature flag is disabled

### Instruqt Testing

1. Push changes to GitHub
2. Update your Instruqt track
3. Run through the complete challenge
4. Test both success and failure paths
5. Test bypass code functionality

## Troubleshooting

### Feature Flag Not Enabling

```bash
# Check feature flag service is running
kubectl get pods -l app.kubernetes.io/component=featureflagservice

# Check logs
kubectl logs -l app.kubernetes.io/component=featureflagservice

# Manually verify flag
kubectl exec <pod> -- curl http://localhost:8081/ffsapi/v1/featureflags/<flagname>
```

### Check Script Failing

```bash
# Check state files exist
ls -la /tmp/incident*
ls -la /tmp/check_*
ls -la /tmp/last_check_time

# Verify answer file
cat /tmp/incidentX_answers.json

# Test check script with debug output
bash -x ./check-k8s
```

### Web Server Not Starting

```bash
# Check if port 8080 is available
netstat -tlnp | grep 8080

# Check web server logs
cat /tmp/webserver.log

# Manually start server
cd www && python3 -m http.server 8080
```

## Best Practices

1. **Unique identifiers**: Use unique names for all state files per challenge
2. **Defensive scripting**: Always check if pods/services exist before operations
3. **Clear error messages**: Help teams understand what went wrong
4. **Realistic scenarios**: Base incidents on real customer issues
5. **Progressive difficulty**: Start easy, increase complexity
6. **Test thoroughly**: Verify both happy and error paths
7. **Document answers**: Maintain an instructor answer key
8. **Update bypass codes**: Change codes for each Game Day session

## Example Scenarios

### High CPU Usage

- **Trigger**: Apply CPU limits via kubectl
- **Questions**: Service name, resource issue type, threshold exceeded
- **Resolution**: Remove CPU limits

### Database Connection Pool Exhaustion

- **Trigger**: Custom env var to reduce pool size
- **Questions**: Service affected, connection metric, root cause
- **Resolution**: Reset env var to default

### Distributed Tracing Investigation

- **Trigger**: Inject random latency in downstream service
- **Questions**: Slowest span, service causing delay, operation name
- **Resolution**: Disable latency injection

### Memory Leak

- **Trigger**: Feature flag causing memory retention
- **Questions**: Service name, memory metric, trend direction
- **Resolution**: Disable feature flag

## Resources

- [OpenTelemetry Demo Documentation](https://opentelemetry.io/docs/demo/)
- [New Relic OpenTelemetry Demo Fork](https://github.com/newrelic/opentelemetry-demo)
- [Instruqt Documentation](https://docs.instruqt.com/)
- [M.A.R.S. Program Overview](../LABS-The M.A.R.S. Program-150126-193537.pdf)

## Support

For questions or issues:
1. Check this documentation
2. Review the example challenge (`01-mars-program-incident-1`)
3. Consult the M.A.R.S. Program team
4. Open an issue in the track repository
