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

### Step 1: Check Workload for Resource Issues
1. Open your New Relic **Workload**
2. Look for services showing resource saturation rather than errors
3. This incident involves **CPU**, not memory — look at CPU utilization metrics

### Step 2: APM — Check Response Time
1. Go to **APM & Services → adservice**
2. Look at the **Summary** — what is the response time compared to baseline?
3. Error rate may be low, but response time should be elevated
4. Check the **Transactions** tab — which transaction is slowest?

### Step 3: Infrastructure / Container Metrics
1. Go to **Infrastructure** and find the `adservice` container/pod
2. Look at the **CPU usage** metric — is it near or at the CPU limit?
3. What is the CPU utilization pattern? (spike vs. sustained high)
4. Compare to other services — is this uniquely high?

### Step 4: Kubernetes Cluster Explorer
1. In the **Kubernetes Cluster Explorer**, find the `adservice` pod
2. Check the CPU utilization as a percentage of the configured CPU limit
3. Is the pod being **CPU throttled**? (throttling occurs when a pod tries to use more CPU than its limit)
4. Look at **resource limits** — how much CPU is the pod allowed?

### Step 5: Trace Analysis
1. Go to **APM → adservice → Distributed Tracing**
2. Open slow traces — what operations take the most time?
3. Are the long spans tied to CPU-intensive work (computation, algorithms) rather than I/O or network calls?
4. Look for spans with high duration but no downstream service calls — pure CPU work

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `adservice; high cpu; ad service high cpu`

**Format hints:**
- Service name: which service? (e.g., `adservice`)
- Issue type: what kind of problem? (e.g., `high cpu`)
- Root cause: what is causing it? (e.g., `ad service high cpu`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- This is a **CPU resource** incident — focus on CPU metrics, not error rates
- If stuck after 15 minutes, ask your Game Manager for a hint 🚀
