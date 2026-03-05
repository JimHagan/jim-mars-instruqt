---
slug: mars-incident-4-failure
id: rg7h8x1ythy9
type: challenge
title: 'Incident 4: Failure'
teaser: Some orders are going through, some aren't — intermittent payment failures
tabs:
- id: rxlwz6w4wgkg
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: 5dgenglsxhny
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

1. **Which service** is failing?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

### Step 1: Reproduce the Problem
Open the **Astronomy Shop** tab and try to complete a purchase:
1. Add an item to your cart
2. Click **Place Order**
3. Try this **multiple times** — what do you notice?
   - Does it fail every time, or just sometimes?
   - What error message do you see when it fails?

The intermittent nature is an important clue.

### Step 2: Check APM Error Rate
1. Go to **APM & Services**
2. Look for services with elevated **error rates** (but less than 100%)
3. Which service is showing intermittent errors?
4. What is the approximate error rate? (10%? 25%? 50%?)

### Step 3: Look at Errors Inbox
1. Go to **Errors Inbox** and filter by the affected service
2. What error message is appearing?
3. Look at the **occurrence count** and **frequency** — is it random or patterned?

### Step 4: Dig into Distributed Traces
In APM, find the affected service and go to **Distributed Tracing**:
1. Filter for traces containing errors
2. Compare a **failing trace** with a **successful trace** side by side
3. Which specific operation is failing?
4. Look at span attributes on the failing span — is there any attribute (like `app.payment.amount`) that differs between successful and failed transactions?

### Step 5: Identify the Root Cause
Based on your investigation:
- Is the failure truly random, or does it correlate with something (transaction amount, product type, user)?
- What does the error message tell you about what's happening in the payment service?
- What is causing the `paymentservice` to intermittently reject charges?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `paymentservice; high error rate; payment failure`

**Format hints:**
- Service name: which service has the errors? (e.g., `paymentservice`)
- Issue type: what kind of problem is this? (e.g., `high error rate`)
- Root cause: what is causing the failures? (e.g., `payment failure`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Hint: look at the **payment service itself**, not checkout — the error is generated inside payment 🚀
