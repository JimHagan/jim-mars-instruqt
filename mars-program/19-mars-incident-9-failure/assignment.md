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

This incident requires you to look **below the application layer** into Kubernetes infrastructure signals.

### Step 1: Check APM — The Symptom
1. Go to **APM & Services → cartservice**
2. Look at the error rate and throughput
3. You might see: throughput dropping to near-zero (no traffic reaching the pod) OR 503 errors from the ingress

### Step 2: Kubernetes Cluster Explorer — The Root Cause Signal
This is where this incident lives:
1. In New Relic, go to **Kubernetes** (search "Cluster Explorer" or "Kubernetes")
2. Navigate to the `opentelemetry-demo` namespace
3. Find the `cartservice` pod
4. Look at the pod **status** — is it `Ready` or `Not Ready`?
5. Check **pod events** — look for readiness probe failure messages like:
   - "Readiness probe failed: ..."
   - "Back-off restarting failed container"

### Step 3: Read the Kubernetes Events
In the Kubernetes Cluster Explorer pod view:
1. Find the **Events** section for the `cartservice` pod
2. What does the readiness probe failure message say?
3. How frequently is the probe failing?
4. Is the pod being **restarted** or just kept out of the service endpoint rotation?

### Step 4: Understand Readiness vs. Liveness
Think about what a **readiness probe failure** means:
- The pod is **running** (it exists and the container is up)
- But the pod **fails its readiness check** (it signals to Kubernetes: "I'm not ready to serve traffic yet")
- Kubernetes responds by removing the pod from the service's endpoint list
- Traffic that would have gone to this pod is either rejected (503) or routed to other pods

### Step 5: Correlate with APM
Go back to **APM → cartservice**:
- Is the throughput suddenly dropping to zero?
- Are there 503 errors appearing in the upstream services (frontend calling cart)?
- Check **Distributed Tracing** — are requests to the cart service being rejected at the network level?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `cartservice; readiness probe failure; failed readiness probe`

**Format hints:**
- Service name: which service? (e.g., `cartservice`)
- Issue type: what kind of problem? (e.g., `readiness probe failure`)
- Root cause: what is causing it? (e.g., `failed readiness probe`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- This is a **Kubernetes infrastructure** incident — look in the Kubernetes Cluster Explorer, not just APM
- If stuck after 15 minutes, ask your Game Manager for a hint 🚀
