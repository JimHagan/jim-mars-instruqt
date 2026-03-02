# M.A.R.S. Program - Instruqt Track

**Maturity Architecture & Reliability Simulation**

An instructor-controlled Game Day experience for hands-on observability training with New Relic and OpenTelemetry.

## Overview

This Instruqt track provides a gamified incident response training environment where teams investigate and resolve real-world observability scenarios using New Relic. Each challenge triggers a specific failure mode in the OpenTelemetry Demo (Astronomy Shop), requiring teams to use distributed tracing, APM, logs, and other observability tools to identify root causes.

### Key Features

- **Instructor-controlled pacing**: Instructors can provide answers directly to teams when needed
- **Anti-guessing mechanisms**: Free-text answers prevent random guessing
- **Flexible answer validation**: Case-insensitive matching with multiple acceptable alternatives
- **Automatic incident resolution**: Correct answers automatically disable failure modes
- **Real-world scenarios**: Based on actual customer incidents and observability best practices
- **OpenTelemetry-first**: Demonstrates New Relic's native OTLP capabilities

## Quick Start

### For Participants

1. **Access your Instruqt environment**: Use the link provided by your instructor
2. **Login to New Relic**: Use credentials provided by your instructor
3. **Start Challenge 1**: Read the incident description in the challenge tab
4. **Investigate in New Relic**: Use APM, distributed tracing, service maps, etc.
5. **Submit your answers**:
   ```bash
   submit-answers
   ```
6. **Click Check**: Validate your answers
7. **Proceed**: Once correct, move to the next challenge

### For Instructors

1. **Review the [Instructor Guide](INSTRUCTOR_GUIDE.md)**: Complete walkthrough of running a Game Day
2. **Prepare answer keys**: Document correct answers for each challenge
3. **Test challenges**: Run through each challenge before the event
4. **Prepare New Relic**: Set up accounts, alerts, and dashboards
5. **Monitor progress**: Use Instruqt dashboard during the Game Day
6. **Provide hints**: Use the hint progression guide in the instructor docs

### For Developers

1. **Read [Challenge Pattern Documentation](CHALLENGE_PATTERN.md)**: Learn how to create new challenges
2. **Study the example**: Review `01-mars-program-incident-1/` structure
3. **Create new challenge**: Follow the step-by-step guide
4. **Test locally**: Use the testing checklist
5. **Deploy to Instruqt**: Push and test in Instruqt environment

## Track Structure

```
mars-program/
├── README.md                          # This file
├── CHALLENGE_PATTERN.md               # Developer guide for creating challenges
├── INSTRUCTOR_GUIDE.md                # Instructor guide for running Game Days
├── track.yml                          # Instruqt track configuration
├── config.yml                         # VM and infrastructure config
├── track_scripts/
│   └── setup-k8s                      # Initial track setup (deploys OTel Demo)
└── 01-mars-program-incident-1/        # Example challenge
    ├── assignment.md                  # Challenge description
    ├── setup-k8s                      # Triggers the incident
    ├── check-k8s                      # Validates answers
    ├── cleanup-k8s                    # Cleans up after challenge
    └── www/
        ├── index.html                 # Web form for answers
        └── submit_answers.sh          # Terminal script for submitting
```

## Current Challenges

### Challenge 1: Checkout Service Degradation

**Scenario:** The Astronomy Shop checkout service is experiencing performance degradation during a critical sales period.

**Learning Objectives:**
- Navigate New Relic APM
- Use distributed tracing to identify bottlenecks
- Understand service dependencies via service maps
- Identify root causes using span analysis

**Expected Investigation Path:**
1. Check alerts for checkout service
2. Examine service map to identify dependencies
3. Use distributed tracing to find slow spans
4. Identify product catalog service as root cause
5. Determine feature flag is causing the issue

**Time Limit:** 30 minutes
**Difficulty:** Basic

## Architecture

### Infrastructure

- **Platform**: Instruqt
- **VM**: n1-standard-2 (k3s Kubernetes)
- **Application**: OpenTelemetry Demo (New Relic fork)
- **Observability**: New Relic via OTLP

### Data Flow

```
OpenTelemetry Demo
    ↓ (OTLP)
New Relic OTLP Endpoint
    ↓
New Relic Platform
    ↓
Teams investigate incidents
    ↓
Submit answers via CLI
    ↓
Check script validates
    ↓
Feature flag disabled (if correct)
```

### Challenge Workflow

```
Setup Script
    ↓
Enable Feature Flag
    ↓
Incident Triggered
    ↓
Alert Fires in New Relic
    ↓
Teams Investigate
    ↓
Teams Submit Answers
    ↓
Check Script Validates
    ├─ Correct → Disable Flag → Next Challenge
    ├─ Incorrect → Wait 60s → Try Again
    └─ Bypass Code → Skip to Next Challenge
```

## Configuration

### Environment Variables

The following environment variables are set in `config.yml`:

- `IS_OPENSHIFT_CLUSTER`: Set to "n" for standard Kubernetes
- `NEW_RELIC_LICENSE_KEY`: Set to actual license key (update before deploying)

## Development

### Prerequisites

- Instruqt account with track creation permissions
- Access to New Relic account
- Basic knowledge of Kubernetes, bash scripting
- Understanding of OpenTelemetry Demo

### Creating a New Challenge

See [CHALLENGE_PATTERN.md](CHALLENGE_PATTERN.md) for detailed instructions.

Quick steps:

1. Copy an existing challenge directory
2. Update `assignment.md` with new scenario
3. Modify `setup-k8s` to trigger different failure
4. Update `check-k8s` with new expected answers
5. Test locally, then deploy to Instruqt

### Testing Locally

```bash
# Navigate to challenge directory
cd 01-mars-program-incident-1

# Run setup
./setup-k8s

# Verify incident triggered
kubectl get pods
# Check New Relic for alerts

# Test answer submission
./www/submit_answers.sh

# Test validation
./check-k8s

# Clean up
./cleanup-k8s
```

## Available Failure Scenarios

The OpenTelemetry Demo includes these feature flags:

| Feature Flag | Effect | Services Impacted |
|--------------|--------|-------------------|
| `productCatalogFailure` | High latency | productcatalogservice, checkout |
| `recommendationServiceFailure` | Errors | recommendationservice |
| `adServiceFailure` | Ad serving failures | adservice |
| `cartServiceFailure` | Cart operations fail | cartservice |

See the [OpenTelemetry Demo documentation](https://opentelemetry.io/docs/demo/) for more.

## Troubleshooting

### Feature Flag Not Working

```bash
# Check feature flag service
kubectl get pods -l app.kubernetes.io/component=featureflagservice

# View feature flags
FFPOD=$(kubectl get pods -n default -l app.kubernetes.io/component=featureflagservice -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FFPOD -- curl http://localhost:8081/ffsapi/v1/featureflags
```

### Data Not in New Relic

```bash
# Check OTel Collector logs
kubectl logs -l app.kubernetes.io/component=otelcol

# Verify license key
kubectl get secret newrelic-license-key -o jsonpath='{.data.NEW_RELIC_LICENSE_KEY}' | base64 -d

# Check app logs
kubectl logs -l app.kubernetes.io/name=opentelemetry-demo
```

### Check Script Issues

```bash
# View check script logs in Instruqt
cat /var/log/instruqt/check-k8s.log

# Check state files
ls -la /tmp/incident*
cat /tmp/incident1_answers.json

# Test check script with debug
bash -x ./check-k8s
```

## Best Practices

### For Instructors

- **Prepare thoroughly**: Test all challenges before the event
- **Monitor actively**: Keep an eye on team progress
- **Provide hints progressively**: Don't give away answers immediately
- **Explain solutions**: Debrief after each challenge
- **Keep it moving**: Use bypass codes to prevent teams from getting stuck

### For Participants

- **Investigate thoroughly**: Don't rush to guess
- **Use all tools**: APM, traces, logs, service maps, etc.
- **Collaborate**: Discuss findings with your team
- **Learn the platform**: Focus on understanding New Relic capabilities
- **Ask for help**: Don't waste time if completely stuck

### For Developers

- **Follow the pattern**: Use the established challenge structure
- **Test extensively**: Verify both success and failure paths
- **Document clearly**: Write clear incident descriptions
- **Use realistic scenarios**: Base on real customer issues
- **Consider difficulty**: Progress from easy to complex

## Contributing

### Adding New Challenges

1. Fork or branch this repository
2. Create a new challenge directory: `XX-challenge-name/`
3. Follow [CHALLENGE_PATTERN.md](CHALLENGE_PATTERN.md)
4. Submit a pull request with:
   - Challenge files
   - Updated README with challenge description
   - Test results

### Improving Existing Challenges

1. Identify improvement opportunity
2. Test changes locally
3. Update documentation if needed
4. Submit PR with clear description

### Reporting Issues

- Use GitHub issues
- Include challenge name and error details
- Provide logs if applicable
- Describe expected vs actual behavior

## Resources

- **[Challenge Pattern Documentation](CHALLENGE_PATTERN.md)**: For creating new challenges
- **[Instructor Guide](INSTRUCTOR_GUIDE.md)**: For running Game Days
- **[M.A.R.S. Program Overview](../LABS-The M.A.R.S. Program-150126-193537.pdf)**: Program strategy and goals
- **[OpenTelemetry Demo](https://opentelemetry.io/docs/demo/)**: Application documentation
- **[New Relic OpenTelemetry Demo Fork](https://github.com/newrelic/opentelemetry-demo)**: Our fork
- **[Instruqt Documentation](https://docs.instruqt.com/)**: Platform documentation

## Support

For assistance:

1. Check this README and linked documentation
2. Review the example challenge
3. Consult the troubleshooting sections
4. Contact the M.A.R.S. Program team
5. Open a GitHub issue

## License

[Add appropriate license information]

## Acknowledgments

- OpenTelemetry Demo community
- New Relic Strategic Solutions team
- New Relic DevRel team
- Instruqt platform team

---

**Happy Game Day! 🚀**
