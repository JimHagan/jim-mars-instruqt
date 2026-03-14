---
slug: mars-incident-4-golden-path
id: q1muwb6b0zye
type: challenge
title: 'Incident 4: Golden Path'
teaser: How to debug intermittent payment failures using traces and Errors Inbox
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: true
---

# 🏆 Golden Path: Payment Service Failure

## What Was Happening

The `paymentFailure` feature flag was enabled, causing the **Payment service** to randomly fail a percentage of charge requests. Unlike a total outage, this was an **intermittent failure** — some transactions succeeded while others failed, making it harder to diagnose because the system appeared to be "working" some of the time.

## Error Rate Chart

![Payment Failure Error Rate](../assets/random-payment-failure-chart.png)

---

## The Ideal Debugging Path

### 1. Alert Fires: High Error Rate Detected (30 seconds)

An alert fires for a high error rate. Opening your **Workload** you'd see multiple services in a degraded state — including `checkout` and `paymentservice`.

`checkout` is the entry point for the payment flow, so it's expected to show errors when anything downstream fails. The question is: **which service is the actual source?**

**Why this is the right first move:** Workloads give you a single-pane-of-glass view of all affected entities. Rather than checking services one by one, you immediately see the blast radius and can start narrowing toward the root cause.

---

### 2. Trace Downstream: Find the Furthest Affected Service (2 minutes)

Navigate to **APM & Services** and look at the error rate column.

You'd see:
- `checkout` showing elevated errors — but checkout is the *caller*, not the source
- `paymentservice` also showing elevated errors — and it's the furthest downstream service in the payment chain

**Why furthest downstream matters:** In a chain of service calls, errors propagate upstream. The service closest to the root cause is the one furthest downstream that is *also* showing errors. `paymentservice` receives calls from `checkout` — if `paymentservice` is failing internally, `checkout` will fail too. Start your deep investigation at `paymentservice`.

---

### 3. Characterize the Error Rate (1 minute)

In **APM → paymentservice → Summary**, observe the error rate.

You'd see:
- An error rate in the 20–30% range — neither 0% nor 100%
- Throughput looks normal — the service is receiving and processing requests

**Key insight:** A non-zero, sub-100% error rate means an intermittent fault, not a total outage. The service is reachable and handling most requests — only a fraction fail. This rules out connectivity issues and points toward something inside the service logic.

---

### 4. Errors Inbox: Confirm the Pattern (2 minutes)

Go to **Errors Inbox** and filter by `paymentservice`.

You'd find a single error group with a consistent message. Look at the **occurrence graph**:
- Errors are occurring steadily over time — not a single burst
- The frequency matches the observed APM error rate

**Why Errors Inbox is ideal here:** It collapses all the intermittent failures into one error group, showing you frequency and trend at a glance — instead of hunting through individual trace records.

---

### 5. Distributed Tracing: Confirm Location and Randomness (2 minutes)

In **APM → paymentservice → Distributed Tracing**, filter for traces with errors.

Open a **failing trace** and a **successful trace** side by side:

**Failing trace:**
```
checkout  →  paymentservice [ERROR]
                 └── ChargeRequest
                       status: Error
                       error.message: "Payment declined"
                       app.payment.amount: $42.00
```

**Successful trace:**
```
checkout  →  paymentservice [OK]
                 └── ChargeRequest
                       status: OK
                       app.payment.amount: $18.50
```

Comparing the two, you'd notice:
- The failing span is inside `paymentservice` itself — not a connectivity issue from `checkout`
- The `app.payment.amount` attribute differs between traces, but failures don't correlate to any particular amount — the pattern appears random

**Key insight:** The error is generated inside `paymentservice`'s own processing logic. The service is reachable and receiving requests — something inside it is intermittently rejecting charges.

---

## Summary: The 5-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Alert triage | Workload | `checkout` and `paymentservice` both degraded |
| Find root service | APM Summary | `paymentservice` is furthest downstream with errors |
| Characterize rate | APM Error % | ~20–30% error rate — intermittent, not total outage |
| Confirm pattern | Errors Inbox | Single error group, consistent frequency over time |
| Confirm location | Distributed Tracing | Error inside `paymentservice.ChargeRequest`, pattern is random |

**Total time to root cause: ~5 minutes**

---

## Key Takeaways

- **Start at the alert, then go downstream.** When multiple services are degraded, the root cause is usually the furthest downstream service showing errors — not the first one the alert fires on.
- **Intermittent ≠ coincidence.** A consistent ~25% error rate means a systematic issue, not random bad luck. Sub-100% error rate is the key signal that rules out a total outage.
- **Errors Inbox turns noise into signal.** Instead of reading hundreds of individual traces, Errors Inbox groups them and shows you trend and frequency immediately.
- **Trace comparison unlocks insights.** Putting a failing trace next to a successful trace highlights exactly what differs — the most efficient way to test for correlations.
- **Error location matters.** An error on `paymentservice`'s own span means the service is reachable and processing requests, but failing internally. This is different from a connection error on the *caller's* span, which would mean the service was unreachable (as seen in Incident 2).

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may miss key details.

<!--
BETA NOTES — Incident 4 Golden Path

- Verify asset renders: random-payment-failure-chart.png
- Validate NRQL attribute name (`otel.status_code` vs `span.status_code`) and value case in the live environment
- Verify `app.payment.amount` is actually emitted in OTel spans; if missing, Step 5's correlation analysis collapses
- The "~20–30%" error rate here should align to whatever value the check script accepts
-->
