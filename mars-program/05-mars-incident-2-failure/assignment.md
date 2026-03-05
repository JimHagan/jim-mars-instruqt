---
slug: mars-incident-2-failure
id: l9hhxsicfkgf
type: challenge
title: 'Incident 2: Failure'
teaser: Checkouts are failing — no one can complete a purchase
tabs:
- id: pbbntcr3meqw
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: t1oyak3sxy9k
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Checkout Failures — Revenue at Risk

**Severity:** P1 — Customer-Facing
**Impact:** 100% of checkout attempts are failing — no orders are completing

Your team has been paged again. New Relic is reporting a sharp spike in errors during the checkout flow.
Customers are adding items to their cart successfully, but **every single checkout attempt is failing**.
This is a complete revenue stop.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is the source of the errors?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

### Step 1: Reproduce the Problem
Open the **Astronomy Shop** tab and try to complete a purchase:
1. Add any item to your cart
2. Click **Place Order**
3. What error do you see?

### Step 2: Check APM for Error Spikes
1. Go to **APM & Services** in New Relic
2. Look for any service with a spiking **error rate**
3. Which service is showing errors — and what does the error message say?

### Step 3: Follow the Trace
In APM, click into the service with errors and go to **Distributed Tracing**:
1. Filter for traces with **errors**
2. Open a failing trace and examine the **waterfall**
3. Which span is failing? What is the error message on that span?
4. Pay attention to the **relationship between services** — which service is the *caller* and which is the *callee*?

### Step 4: Read the Error Message Carefully
The error message in the failing span will tell you exactly what went wrong.
Look for keywords like:
- "connection refused"
- "host not found"
- "dial tcp"
- "no such host"

This type of error indicates a **network connectivity problem** between two services.

### Step 5: Identify the Root Cause
Based on what you find in the trace:
- Which service is **making the call that fails**?
- Which **downstream service** is it trying to reach?
- What does the error tell you about *why* the call fails?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `checkoutservice; high error rate; payment service unreachable`

**Format hints:**
- Service name: the service where the error originates (e.g., `checkoutservice`)
- Issue type: what kind of problem is this? (e.g., `high error rate`)
- Root cause: what is causing the failure? (e.g., `payment service unreachable`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Every second counts — customers can't check out! 🚀
