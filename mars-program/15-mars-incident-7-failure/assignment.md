---
slug: mars-incident-7-failure
id: h5xpwqt8zkmr
type: challenge
title: 'Incident 7: Failure'
teaser: The ad service CPU is pegged — pages are slow to render ads
tabs:
- id: t5xmqk9nvzbl
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: q7nwfm4kzxtp
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Ad Service CPU Saturation

**Severity:** P2 — Performance Degradation
**Impact:** The Ad service is consuming excessive CPU, causing slow ad rendering and increased latency across pages that display ads

Your team is paged. New Relic is showing abnormally high CPU utilization on the **Ad service**. The service is still responding, but it's taking significantly longer than baseline — customers may notice slower page loads on product pages and the homepage.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is CPU-bound?
2. **What type of issue** is affecting it?
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
