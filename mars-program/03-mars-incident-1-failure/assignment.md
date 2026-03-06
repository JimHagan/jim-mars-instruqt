---
slug: mars-incident-1-failure
id: hyun1dpgehs4
type: challenge
title: 'Incident 1: Failure'
teaser: Customers can't complete purchases — something is broken in the catalog
tabs:
- id: wcivltpnoqh8
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: dxornyimeuum
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Product Errors Spiking

**Severity:** P1 — Customer-Facing
**Impact:** Customers are reporting errors when trying to view or purchase specific products

Your team has been paged. New Relic is showing a spike in errors on the **Astronomy Shop**.
Reports are coming in that certain product pages are failing to load, blocking customers from completing purchases.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is generating the errors?
2. **What type of issue** is affecting the service?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

Start broad, then narrow down:

### Step 1: Check Your Workload Health
1. In New Relic, go to **Workloads** and open your team's workload
2. Look for any entities showing **red** or **degraded** status
3. Note which services are alerting

### Step 2: Dig into APM
1. Go to **APM & Services**
2. Look for services with elevated **error rates** (check the error % column)
3. Click into the affected service and examine:
   - The **Errors** tab — look at the error messages and stack traces
   - **Distributed Tracing** — find traces with errors and examine the failing span

### Step 3: Try to Reproduce
Open the **Astronomy Shop** tab and browse the product catalog.
Try clicking on **"Roof Binoculars"** — what happens?

### Step 4: Examine the Evidence
In the failing trace, look for:
- What is the **error message** on the failing span?
- Is the error tied to a **specific product ID** or all products?
- What span attribute tells you which product is affected?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
affected service; affected product ID; root cause
```

**Example:** `productcatalogservice; OLJCESPC7Z; product catalog failure`

**Format hints:**
- Affected service: which service is generating errors in New Relic APM?
- Affected product ID: which specific product ID is failing? (look in Error Inbox or trace span attributes — it's a code, not a name)
- Root cause: what is causing the failures?

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀
