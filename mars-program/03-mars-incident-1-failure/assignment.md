---
slug: mars-incident-1-failure
id: 9tzxyporxwx2
type: challenge
title: 'Incident 1: Failure'
teaser: Product failures observed
tabs:
- id: 0fauemzw7uty
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: f9pbngi7pgdg
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

1. **Which service** is generating the product errors?
2. **Which specific product ID or IDs** are failing to load?
3. **What is the exact `otel.status_description` for the error that** shows the failing product?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads:

## Step 1: Check Your Workload

Open your New Relic **Workload** and scan the health overview for degraded services.  If you see a clue by looking at the workload jump ahead to step 2 and focus on the service related to that clue.

> **Note:** The workload may show multiple services in a degraded or red state at the same time. Not all of them are the root cause — some are failing as a downstream consequence of the real problem. Use this view to get oriented, then dig deeper to find what's actually broken.


### Step 2: Dig into APM & Distributed Tracing
1. Look at the service identified by the workload status.
2. Look at a service map to see what the downstream services are.
3. Use the `Errors Inbox` view for this service to see what errors may be concurrent with the start of this incident.
4. If needed investigate distributed tracing to track the full chain of spans related to this error.  

>*Hint* You may find in some cases broadening your investigation and looking at the `Errors Inbox` for the *whole workload* to be helpful for a broad overview of incoming errors.





## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter your answers:

**Answer Format:**
```
affected service; affected product id; exception text
```

**Example:** `shippingservice; product almceykc8x; service timeout`

**Format hints:**
- Paste the name of the impacted service: use the exact name as it appears in New Relic (e.g., `shippingservice`)
- Affected product id: the ext product ID or IDs that fail to load
- Exact `otel.status_description`: paste the exact text from NR (e.g., `Error: database connection timed out`, `Error: file not found` etc.)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **15 minutes** for this incident
- If stuck after 10 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

