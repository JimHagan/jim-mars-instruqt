# M.A.R.S. Program - Instructor Quick Reference Guide

## Pre-Game Day Checklist

- [ ] Prepare answer keys for all challenges
- [ ] Test all challenges end-to-end
- [ ] Prepare New Relic accounts for each team
- [ ] Create answer key document
- [ ] Set up monitoring dashboard for team progress
- [ ] Prepare hint sheets for each challenge
- [ ] Test Instruqt environment provisioning
- [ ] Verify all feature flags work correctly

## Game Day Workflow

### 1. Opening (5 minutes)

- Welcome teams and explain Game Day format
- Review objectives and scoring
- Share New Relic login credentials per team
- Explain when/how to request help
- Explain the answer submission process

### 2. Challenge Progression

Each challenge follows this timeline:

**0:00 - Challenge starts**
- Teams receive Instruqt environment
- Incident is automatically triggered
- Alert fires in New Relic
- Teams begin investigation

**0:15 - First checkpoint**
- Check which teams are struggling
- Offer **Hint Level 1** (gentle nudge)
  - "Have you checked the distributed traces?"
  - "Look at the service map"
  - "Check which service has abnormal latency"

**0:20 - Second checkpoint**
- Offer **Hint Level 2** (more specific)
  - "Focus on the product catalog service"
  - "Look at the specific transaction showing high duration"
  - "Check if there's a pattern in the traces"

**0:25 - Final checkpoint**
- Offer **Hint Level 3** (very specific)
  - "The productcatalogservice is experiencing high latency"
  - "Look for the feature flag causing this behavior"

**0:30 - Time's up**
- Provide correct answers to all remaining teams
- Allow them to advance to next challenge
- Briefly explain the solution

### 3. Providing Answers

When to provide answers directly:
- After 15 minutes if team is completely stuck
- At 30-minute mark for all teams not finished
- If there's a technical issue preventing proper investigation

How to help teams:
1. Give them the correct answers verbally
2. Have them run `submit-answers` and enter the correct answers
3. They click **Check** button in Instruqt to proceed

## Challenge 1: Checkout Service Degradation

### Correct Answers

**Question 1: Which service is the root cause?**
- Primary: `productcatalogservice`
- Alternatives: `product catalog service`, `product-catalog-service`, `productcatalog`

**Question 2: What type of issue is affecting the service?**
- Primary: `high latency`
- Alternatives: `latency`, `slow response`, `slow performance`, `performance degradation`

**Question 3: What is the specific root cause?**
- Primary: `product catalog failure`
- Alternatives: `catalog failure`, `product catalog error`, `catalog service failure`, `feature flag enabled`

### Investigation Path

1. **Check New Relic Alerts**
   - Alert should show checkout service degradation
   - SLO error budget consumption increasing

2. **Navigate to APM**
   - Open checkoutservice entity
   - Notice increased response time

3. **Check Service Map**
   - See that checkoutservice depends on productcatalogservice
   - Notice productcatalogservice has high response time

4. **Distributed Tracing**
   - Find traces for `/checkout` operations
   - See most time spent in productcatalog operations
   - Identify specific slow spans

5. **Root Cause**
   - Feature flag `productCatalogFailure` is enabled
   - Causes artificial latency in product catalog

### Hints by Level

**Level 1 (subtle):**
> "Start by looking at the service dependencies. Which service is the checkout service calling?"

**Level 2 (moderate):**
> "The distributed traces will show you exactly where time is being spent. Look for the longest spans."

**Level 3 (explicit):**
> "The product catalog service is experiencing high latency due to a feature flag. Check which service shows abnormal response times."

## Common Issues & Solutions

### Teams Can't Submit Answers

**Symptoms:** Can't find `submit-answers` command

**Solution:**
```bash
# Check if script exists
ls -la /usr/local/bin/submit-answers

# If not, run manually:
bash /root/mars-program/01-mars-program-incident-1/www/submit_answers.sh
```

### Check Always Fails

**Symptoms:** Check button always fails even with correct answers

**Solution:**
```bash
# Verify answer file was created
cat /tmp/incident1_answers.json

# Check for formatting issues
jq . /tmp/incident1_answers.json

# Verify check script is executable
ls -la /root/mars-program/01-mars-program-incident-1/check-k8s
```

### Feature Flag Didn't Enable

**Symptoms:** No incident visible in New Relic

**Solution:**
```bash
# Check feature flag service
kubectl get pods -l app.kubernetes.io/component=featureflagservice

# Check if flag is enabled
FFPOD=$(kubectl get pods -n default -l app.kubernetes.io/component=featureflagservice -o jsonpath='{.items[0].metadata.name}')
kubectl exec $FFPOD -- curl http://localhost:8081/ffsapi/v1/featureflags/productCatalogFailure

# Manually enable if needed
kubectl exec $FFPOD -- curl -X POST http://localhost:8081/ffsapi/v1/featureflags \
  -H 'Content-Type: application/json' \
  -d '{"name": "productCatalogFailure", "enabled": true}'
```

### Team Can't Access New Relic

**Symptoms:** Login issues, can't see data

**Solution:**
1. Verify account credentials are correct
2. Check if license key is set correctly in environment
3. Verify data is flowing: `kubectl logs -l app.kubernetes.io/name=opentelemetry-demo`
4. Check OTLP endpoint configuration

## Monitoring Team Progress

### Via Instruqt Dashboard

- Track which teams are on which challenge
- See attempt counts in environment logs
- Monitor challenge completion times

### Via New Relic

- Create a dashboard per team showing:
  - Service health status
  - Alert states
  - SLO error budget
  - Entity health scores

### Via Scorecards (Advanced)

If using New Relic Scorecards for gamification:
- Check scorecard health for each team
- Award points based on:
  - Time to resolution
  - Number of attempts
  - SLO compliance during incident

## Scoring Suggestions

### Basic Scoring

- **Complete challenge:** 100 points
- **Bonus for speed:**
  - Under 10 minutes: +50 points
  - Under 15 minutes: +25 points
  - Under 20 minutes: +10 points
- **Penalty for attempts:**
  - 1-2 attempts: No penalty
  - 3-4 attempts: -10 points
  - 5+ attempts: -20 points
- **Bypass code used:** -50 points (but they still advance)

### Advanced Scoring (with New Relic Scorecards)

Create scorecard rules that measure:
- SLO compliance during incident
- Mean time to detection (MTTD)
- Mean time to resolution (MTTR)
- Number of affected transactions
- Error budget consumption

## Troubleshooting Commands

```bash
# Check challenge setup completed
ls -la /tmp/incident1_start_time

# View setup logs
cat /var/log/instruqt/setup-k8s.log

# Check web server
curl http://localhost:8080
ps aux | grep python3

# View check attempt history
cat /tmp/check_attempt_count
cat /tmp/last_check_time

# Manually trigger cleanup
cd /root/mars-program/01-mars-program-incident-1
./cleanup-k8s

# Manually set correct answers (as instructor helping stuck team)
echo '{"service":"productcatalogservice","issue_type":"high latency","root_cause":"product catalog failure"}' > /tmp/incident1_answers.json
```

## Tips for a Successful Game Day

1. **Start with a demo**: Walk through the first challenge together
2. **Encourage collaboration**: Teams should discuss findings
3. **Focus on learning**: It's not just about speed
4. **Explain the why**: After each challenge, explain the solution
5. **Share best practices**: Show the optimal investigation path
6. **Celebrate wins**: Acknowledge teams who complete challenges
7. **Learn from failures**: Discuss common mistakes
8. **Time management**: Keep the day moving, don't let teams get stuck too long

## Post-Game Day

### Debrief

- Review completion times and scores
- Discuss most challenging aspects
- Gather feedback on difficulty
- Identify areas for improvement

### Follow-up

- Share investigation playbooks
- Provide access to New Relic University courses
- Offer additional Game Day opportunities
- Connect teams with observability champions

## Contact & Support

- **Technical issues:** [Support contact]
- **Track problems:** [Instruqt support]
- **Content questions:** [M.A.R.S. team]

## Resources

- [Full Challenge Pattern Documentation](CHALLENGE_PATTERN.md)
- [M.A.R.S. Program Overview](../LABS-The M.A.R.S. Program-150126-193537.pdf)
- [OpenTelemetry Demo Docs](https://opentelemetry.io/docs/demo/)
