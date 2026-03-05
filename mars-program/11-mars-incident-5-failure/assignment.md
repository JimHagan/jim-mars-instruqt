---
slug: mars-incident-5-failure
id: xqutxd0jgsmt
type: challenge
title: 'Incident 5: Failure'
teaser: Carts are broken — customers can't add items or view their cart
tabs:
- id: uc8sc5plcjn7
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: 2bkvpym14tgm
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Shopping Cart Service Down

**Severity:** P1 — Customer-Facing
**Impact:** Customers cannot add items to cart or view existing carts — the entire shopping flow is blocked

Your team is paged. New Relic is reporting errors from the cart service. Customers can browse products but the moment they try to add anything to their cart, they get an error. The entire purchase funnel is blocked upstream of checkout.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is failing?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

### Step 1: Reproduce the Problem
Open the **Astronomy Shop** tab:
1. Click on any product
2. Try clicking **Add to Cart**
3. What error do you see?
4. Also try clicking the **Cart** icon to view your cart

### Step 2: Check APM for Error Spikes
1. Go to **APM & Services** in New Relic
2. Look for services with a spiking **error rate**
3. Which service is erroring — and what are the affected operations? (Hint: look for `AddItem`, `GetCart`, `EmptyCart`)

### Step 3: Examine the Error
In the service's APM view:
1. Click the **Errors** tab
2. Read the error message carefully — what does it tell you about what the cart service is failing to do?
3. Is this an internal logic error, or is the cart service failing to connect to something?

### Step 4: Follow the Trace
Go to **Distributed Tracing** and open a failing trace:
1. Find the span that errors — which operation is it?
2. Look at the span attributes — is there a backing store (like Redis/Valkey) mentioned in the error?
3. What does the error message tell you about *why* the operation fails?

### Step 5: Check Infrastructure (Optional)
If you have access to Kubernetes metrics:
- Is the `cartservice` pod healthy?
- Are there any pod restarts or OOMKills visible in the K8s Cluster Explorer?

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `cartservice; high error rate; cart failure`

**Format hints:**
- Service name: which service is failing? (e.g., `cartservice`)
- Issue type: what kind of problem? (e.g., `high error rate`)
- Root cause: what is causing the failure? (e.g., `cart failure`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Hint: the cart service depends on a backing store — check if that connection is the issue 🚀
