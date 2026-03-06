---
slug: mars-incident-2-failure
id: l9hhxsicfkgf
type: challenge
title: 'Incident 2: Failure'
teaser: Checkouts are failing — no one can complete a purchase
tabs:
- id: pbbntcr3meqw
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: t1oyak3sxy9k
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Checkout Failures — Revenue at Risk

**Severity:** P1 — Customer-Facing
**Impact:** 100% of checkout attempts are failing — no orders are completing

Your team has been paged again. New Relic is reporting a sharp spike in errors during the checkout flow.
Customers are adding items to their cart successfully, but **every single checkout attempt is failing**.
This is a complete revenue stop.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service** is the source of the checkout errors?
2. **Which downstream dependency** is unreachable?
3. **What exception name** appears in the traces?

## 🔍 Investigation Guide

Start broad, then narrow down.  As always check your configured workloads to get awareness of impacted entities:

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
Browse the product catalog, add some items to your cart, and try to check out — what happens?



## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter your answers:

**Answer Format:**

```
failing service; unreachable dependency; exception name
```

**Example:** `cartservice; emailservice; service unavailable`

**Format hints:**
- Failing service: the service where errors are observed in APM (e.g., `cartservice`)
- Unreachable dependency: which downstream service can't be reached? (look in error messages or traces)
- Exception name: Paste in the exception name from the error messages or traces (e.g., `service unavailable`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

<!--
=============================================================================
BETA TESTING REVIEW NOTES — Incident 2 Failure Path
=============================================================================

## Gotchas to Watch in Beta Testing

- The key insight (paymentservice has ZERO throughput during the incident)
  is counterintuitive. Most students will look FOR errors on paymentservice
  APM, find nothing, and conclude "payment service is fine." Watch for
  teams who get stuck at this point — game manager hint: "Check the
  throughput chart on paymentservice, not just the error rate."

- The error message variants can be: "connection refused", "no such host",
  "dial tcp: lookup paymentservice-invalid", "UNAVAILABLE desc = connection
  error." The check script must handle all of these. Observe what students
  actually see in the lab environment and ensure those exact strings are
  accepted.

- Groups fresh from Incident 1 will immediately go to Errors Inbox. There
  will be errors there (on checkoutservice), but the root cause is a
  connectivity issue, not an application error. Watch for teams who stop
  at Errors Inbox without following the trace to understand WHY checkout
  is failing.

- The gRPC error on checkoutservice spans may display differently across
  different New Relic UI versions. Validate that the span attribute
  `rpc.service: oteldemo.PaymentService` is visible in the lab's OTel
  traces before the beta.
=============================================================================
-->
