---
slug: mars-incident-4-failure
id: 1hpiyuerfoi7
type: challenge
title: 'Incident 4: Failure'
teaser: Some orders are going through, some aren't
tabs:
- id: txdrnbxnjvtm
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: pasimdme17il
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Intermittent Payment Failures

**Severity:** P1 — Revenue Impact
**Impact:** A percentage of payment charges are failing — affected customers cannot complete purchases

Your team is paged. New Relic is showing errors in the payment flow, but they're **not 100% failures** — some transactions are succeeding while others fail.
This is trickier than a total outage. Customers are having inconsistent experiences and support tickets are piling up.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Paste the name of the service** that is intermittently failing?
2. **What is the approximate error rate** observed in APM?
3. **Past the name of the transaction that** is failing?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads to get awareness of impacted entities:


### Step 1: Dig into APM
1. Go to **APM & Services**
2. Look for services with elevated **error rates** (check the error % column) — **note the approximate error percentage**
3. Click into the affected service and examine:
   - The **Errors** tab — look at the error messages and stack traces
   - **Distributed Tracing** — find traces with errors and examine the failing span

### Step 2: Dig into Errors Inbox
1. Go to **Errors Inbox**
2. Look for unique error patterns

### Step 3: Look at application logs
1. Go to **Logs**
2. Look for unique log patterns related to all or to specific services

### Step 4: Look at distributed tracing
1. Find anomalous spans related to services you suspect may be at fault
2. Capture error messages, logs or other details.


### Step 5: Try to Reproduce
Open the **Astronomy Shop** tab and browse the product catalog.
Try clicking on **"Roof Binoculars"** — what happens?



## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter your answers:

**Answer Format:**

```
failing service; approximate error rate; failing transaction type
```

**Example:** `checkoutservice; 10%; PlaceOrder`

**Format hints:**
- Failing service: use the exact name as it appears in New Relic (e.g., `checkoutservice`)
- Approximate error rate: the % of transactions failing — observe the error rate in APM and round to the nearest 5% (e.g., `10%`)
- Failing transaction type: what operation is erroring? — look in the Errors tab or Distributed Tracing (e.g., `PlaceOrder`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **15 minutes** for this incident
- If stuck after 10 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

<!--

## Gotchas to Watch in Beta Testing

- This is the first incident where teams must observe a PATTERN, not a
  single event. Watch for groups who try checkout once, it happens to
  succeed, and they report "no incident." Game manager hint: "The error
  is intermittent — try at least 5 times."

- The error rate fluctuates over time. A student who checks APM in a
  "lucky" window may see a lower rate than the configured ~25%. The check
  script needs to accept a range (e.g., 15%–35%) not just "25%".

- Students who did Incident 2 will recognize "paymentservice" immediately
  and may jump straight to that service — which is actually correct here!
  But the reason is different (internal error vs. connection refused).
  Watch for teams who get the right answer for the wrong reason and then
  struggle to explain WHY in a debrief.

- The transaction name ("ChargeRequest", "Charge", etc.) may differ
  between the OTel span name and the APM transaction name. Verify the
  exact string that appears in APM before the beta and ensure the check
  script matches it exactly. Also handle case variants.

- Teams fatigued from Incidents 1–3 may rush this one and miss the
  "intermittent" nuance. This is arguably the most analytically
  challenging incident — game managers should be ready to slow teams
  down and prompt reflection.
=============================================================================
-->
