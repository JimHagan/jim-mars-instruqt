---
slug: mars-incident-1-failure
id: hyun1dpgehs4
type: challenge
title: 'Incident 1: Failure'
teaser: Product failures observed
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
2. **Which specific product or products** is failing to load?
3. **What types of issue** are affecting the service?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads:


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
Try clicking on a variety of products. See if you notice any telemetry impact — new errors or changes to golden signals.



## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter your answers:

**Answer Format:**
```
affected service; affected product id; issue type
```

**Example:** `shippingservice; product almceykc8x; service timeout`

**Format hints:**
- Paste the name of the impacted service: use the exact name as it appears in New Relic (e.g., `shippingservice`)
- Affected product id: the product that fails to load
- Issue type: what you observe in APM (e.g., `service timeout`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **15 minutes** for this incident
- If stuck after 10 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

<!--

=============================================================================
BETA TESTING REVIEW NOTES — Incident 1 Failure Path
=============================================================================

## Gotchas to Watch in Beta Testing

- Teams that go to Logs first (Step 3) before APM will struggle to correlate
  log lines to a specific service without prior context. Watch for groups
  spending 10+ minutes in Logs before pivoting to APM.

- Alert firing lag: New Relic error rate alerts have an evaluation window
  (typically 1–5 minutes). If students check alerts immediately after the
  challenge starts, they may see no active alerts and assume nothing is wrong.
  Game managers should know this and advise teams to check APM directly if
  alerts haven't fired yet.

- New Relic APM entity names are case-sensitive. "productcatalogservice"
  must be entered exactly as it appears. Watch for answers like
  "ProductCatalogService" or "product-catalog-service". Verify the check
  script normalizes case.

- The error rate spike may take 1–2 minutes to visibly register in APM after
  the challenge setup script runs. Groups who jump in immediately may see
  healthy charts briefly.
=============================================================================

-->
