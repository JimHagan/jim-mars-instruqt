---
slug: mars-incident-3-failure
id: itpv4cbpt8k4
type: challenge
title: 'Incident 3: Failure'
teaser: The Homepage Just Isn't Right
tabs:
- id: vobwgyy8v5y8
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: fshh4nqsxts7
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

1. **Which service** is responsible for the slowness?
2. **How many seconds** is each image request delayed? (check span duration in traces)
3. **Which Core Web Vital** is degraded in Browser monitoring?

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
2. Look at **Core Web Vitals** — are any of the scores elevated or degraded?
3. Check the **AJAX** tab for slow requests — do you see slow calls for image loading?

### Step 3: Investigate with APM
1. Go to **APM & Services** and look for any service with elevated **response time / latency**
2. Check the service handling image requests — look for a service named `imageprovider` or similar
3. In its APM summary, check if the **average response time** is much higher than normal

### Step 4: Dig into Traces
In APM, go to **Distributed Tracing** for the slow service:
1. Open a slow trace for an image-loading request
2. Look at the span duration — **note the exact number of seconds** each request takes
3. Check the span **attributes** — is there anything that suggests artificial delay?

### Step 5: Identify the Root Cause
Based on your investigation:
- Which service is consistently slow?
- How many seconds does each image request take? (this is your delay value)
- Which Core Web Vital in Browser monitoring is most impacted by slow image loads?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

**Answer Format:**

```
slow service; delay in seconds; degraded core web vital
```

**Example:** `recommendationservice; 3; CLS`

**Format hints:**
- Slow service: use the exact name as it appears in New Relic (e.g., `recommendationservice`)
- Delay in seconds: how long does each image request take? (from span duration in traces — enter a whole number, e.g. `3`)
- Degraded core web vital: which Browser Core Web Vital is impacted? (e.g., `CLS`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **15 minutes** for this incident
- If stuck after 10 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

<!--

## Gotchas to Watch in Beta Testing

- Browser monitoring data in New Relic has a ~2–5 minute ingestion delay.
  If students check Browser Core Web Vitals immediately after the incident
  starts, they may see normal LCP. Game managers should advise: "Give it
  2–3 minutes for Browser data to populate, then check Core Web Vitals."

- The Instruqt embedded browser tab may have inherently high latency due
  to the proxy. Teams will struggle to distinguish 2-second artificial
  image delay from normal Instruqt latency. Anchor the investigation in
  APM trace span durations rather than subjective visual timing.

- If the Browser app was not properly configured during track setup
  (Terraform Terraform issues, wrong app ID, etc.), the Browser tab will
  show no data and students will be completely blocked on Steps 2–3.
  Game managers need a fallback path: "If Browser shows no data, go
  directly to APM and look for imageprovider latency."

- The "delay in seconds" answer must match what the check script expects.
  If the feature flag injects exactly 2000ms and spans show 2.1–2.9s
  due to overhead, students who answer "2" vs "3" may get different
  results. Validate the exact span durations in the lab before beta.

- Students unfamiliar with Core Web Vitals may Google what LCP is and
  realize it's related to images — effectively reading the answer. This
  is fine educationally but worth knowing.
=============================================================================
-->
