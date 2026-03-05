---
slug: mars-incident-6-failure
id: b2kvgmq5xznt
type: challenge
title: 'Incident 6: Failure'
teaser: The recommendation service is consuming ever-growing memory
tabs:
- id: v4qnxbm7kztl
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: p8fwtqk6zxmn
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Recommendation Service Memory Exhaustion

**Severity:** P2 — Service Degradation (escalating to P1)
**Impact:** The Recommendation service memory usage is growing continuously — if unchecked, it will OOMKill and affect the home page and product pages

Your team is paged. This is a slow-burn incident — the service isn't failing yet, but memory is climbing at an alarming rate. Left unchecked, the pod will be killed by Kubernetes when it hits its memory limit, causing recommendation failures for all customers.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is experiencing the memory issue?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

### Step 1: Check Your Workload
1. Open your New Relic **Workload**
2. Look for services showing elevated resource consumption rather than errors
3. Note: this incident may not trigger error-based alerts — you need to watch **resource metrics**

### Step 2: Investigate Infrastructure Metrics
1. In New Relic, go to **APM & Services → recommendationservice**
2. Look at the **Summary** — you may not see elevated error rates, but check **response time**
3. Click on **Metrics** or go to **Infrastructure** to find the pod/container memory metrics
4. Look for the **memory usage** metric over the last 30 minutes — what pattern do you see?
   - Is it flat? Sawtooth? Or continuously climbing?

### Step 3: Check Kubernetes Cluster Explorer
1. Go to **Kubernetes** in New Relic (or search for "Cluster Explorer")
2. Find the `recommendationservice` pod
3. Look at the **memory usage** graph for the pod — you should see a continuous upward slope
4. Check for any pod restarts or OOMKill events in the events

### Step 4: Correlate with Traces
1. Go to **APM → recommendationservice → Distributed Tracing**
2. Look at trace durations over time — are they increasing as memory grows?
3. Check if any spans show cache-related attributes

### Step 5: Identify the Root Cause
Based on your investigation:
- Is memory growing in a sawtooth pattern (leak + GC recovery) or a straight line?
- What component of the service could cause unbounded memory growth?
- A growing **cache** with no eviction policy would cause this — is there anything in the spans or error messages that mentions caching?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `recommendationservice; memory leak; recommendation cache failure`

**Format hints:**
- Service name: which service? (e.g., `recommendationservice`)
- Issue type: what kind of problem? (e.g., `memory leak`)
- Root cause: what is causing it? (e.g., `recommendation cache failure`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- This is a resource-based incident, not an error-based one — look at **memory metrics**, not error rates
- If stuck after 15 minutes, ask your Game Manager for a hint 🚀
