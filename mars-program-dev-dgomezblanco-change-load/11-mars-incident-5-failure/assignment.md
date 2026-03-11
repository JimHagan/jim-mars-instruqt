---
slug: mars-incident-5-failure
id: hs0jawdoem7t
type: challenge
title: 'Incident 5: Failure'
teaser: The recommendation service is consuming ever-growing memory
tabs:
- id: egvadj7ztyqa
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: detn2upx8adq
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Recommendation High Memory Utilization

**Severity:** P2 — Service Degradation (escalating to P1)
**Impact:** The Recommendation service memory usage is growing continuously — if unchecked, it will OOMKill and affect the home page and product pages

Your team is paged. This is a slow-burn incident — the service isn't failing yet, but memory is climbing at an alarming rate. Left unchecked, the pod will be killed by Kubernetes when it hits its memory limit, causing recommendation failures for all customers.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is experiencing the memory issue?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads to get awareness of impacted entities:


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

**Example:** `search-service; high error rate; database connection timeout`

**Format hints:**
- Service name: use the exact name as it appears in New Relic (e.g., `search-service`)
- Issue type: describe what you observe (e.g., `high error rate`)
- Root cause: what is causing this? (e.g., `database connection timeout`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **10 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀
