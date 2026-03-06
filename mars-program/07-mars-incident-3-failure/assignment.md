---
slug: mars-incident-3-failure
id: y6xxocxsyopf
type: challenge
title: 'Incident 3: Failure'
teaser: The Homepage Just Isn't Right
tabs:
- id: etdymdhv15kg
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: vefkkpndy0nx
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Image Slow Load

**Severity:** P2 — User Experience Degradation
**Impact:** Product pages are taking longer to fully load

Your team is paged. Customers are complaining that the **Astronomy Shop** feels "broken" and "unusable."
Pages are loading but something is visibly wrong — the customer experience is bad and bounce rates are spiking.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is causing the slowness?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads:

### Step 1: Reproduce the Problem
Open the **Astronomy Shop** tab and navigate to a product detail page.
Click on any product. What do you notice?
- Does the page text load quickly?
- Do the **product images** load at the same speed?
- Time how long the page takes to fully load (images included)

### Step 2: Check Browser Monitoring
This incident affects the **user-facing experience**, so start with **Browser** monitoring:
1. In New Relic, go to **Browser** and find the Astronomy Shop browser app
2. Look at **Core Web Vitals** — is **LCP (Largest Contentful Paint)** elevated?
3. Check the **AJAX** tab for slow requests — do you see slow calls for image loading?

### Step 3: Investigate with APM
1. Go to **APM & Services** and look for any service with elevated **response time / latency**
2. Check the service handling image requests — look for a service named `imageprovider` or similar
3. In its APM summary, check if the **average response time** is much higher than normal

### Step 4: Dig into Traces
In APM, go to **Distributed Tracing** for the slow service:
1. Open a slow trace for an image-loading request
2. Look at the span duration — how long does a single image request take?
3. Check the span **attributes** — is there anything that suggests artificial delay?

### Step 5: Identify the Root Cause
Based on your investigation:
- Which service is consistently slow?
- Is there a pattern? (All requests? Only for images? Only for certain paths?)
- What could cause a service to be artificially slow on every request?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

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

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀
