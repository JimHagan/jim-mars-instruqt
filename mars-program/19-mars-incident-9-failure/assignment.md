---
slug: mars-incident-9-failure
id: f6txnqm4vzkp
type: challenge
title: 'Incident 9: Failure'
teaser: The cart service pod is not ready — Kubernetes is refusing to route traffic to it
tabs:
- id: m7xqnv6kztbl
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: x4wqfk9mzntp
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Cart Service Pod Not Ready

**Severity:** P1 — Customer-Facing
**Impact:** The Cart service pod is failing its readiness probe — Kubernetes has taken it out of rotation, causing cart operations to fail or be unavailable

Your team is paged. Customers are getting errors when trying to add items to their cart. Unlike a typical application error, this incident is happening at the **infrastructure level** — Kubernetes itself is refusing to route traffic to the cart service pod because it has declared itself "not ready."

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is affected by the readiness probe failure?
2. **What type of issue** is this?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

Start broad, then narrow down:


### Step 1: Dig into APM
1. Go to **APM & Services**
2. Look for services with elevated **error rates** (check the error % column)
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

```
service name; issue type; root cause
```

**Example:** `checkoutservice; high error rate; database connection timeout`

**Format hints:**
- Service name: use the exact name as it appears in New Relic (e.g., `checkoutservice`)
- Issue type: describe what you observe (e.g., `high error rate`)
- Root cause: what is causing this? (e.g., `product catalog failure`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀
