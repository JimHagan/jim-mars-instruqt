---
slug: mars-incident-6-golden-path
id: y7rjdwn4pqmx
type: challenge
title: 'Incident 6: Golden Path'
teaser: How to debug a cart service failure using APM and distributed tracing
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: true
---

# 🏆 Golden Path: Cart Service Failure

## What Was Happening

The `cartFailure` feature flag was enabled, causing the **Cart service** to fail. The cart service relies on a backing store (Redis/Valkey) to persist cart data. With this flag enabled, the service simulates an inability to connect to or operate on the backing store, causing `AddItem`, `GetCart`, and `EmptyCart` operations to return errors. The entire purchase funnel was blocked — customers could browse but not shop.

---

## The Ideal Debugging Path

### 1. Reproduce (30 seconds)

Open the Astronomy Shop and try to add any product to your cart. You'd immediately see an error response — the action fails visibly in the UI. Try viewing the cart too — same failure.

**Why this is useful:** Unlike intermittent failures (Incident 4), this is a hard 100% failure on cart operations. Any attempt to interact with the cart fails consistently.

---

### 2. APM: Identify the Failing Service (1 minute)

Go to **APM & Services**. The `cartservice` will show a near-100% error rate, specifically on these operations:
- `AddItem`
- `GetCart`
- `EmptyCart`

**Key observation:** The error rate is 100% and affects all cart operations, not just one — this points to an infrastructure dependency failure, not a logic bug on a specific path.

---

### 3. Errors Inbox: Read the Error Message (1 minute)

Go to **Errors Inbox** and filter by `cartservice`.

You'd see an error like:
```
Error: Failed to get cart: rpc error: code = Unavailable
desc = connection error: desc = "transport: Error while dialing: dial tcp:
connecting to cartservice backing store failed"
```

Or more directly:
```
Error: Cart service failure simulated by feature flag
```

**The error message tells the whole story.** Rather than a business-logic error, this is a connectivity/infrastructure error from the backing store layer.

---

### 4. Distributed Tracing: Confirm the Failure Point (1 minute)

In **APM → cartservice → Distributed Tracing**, open a failing trace:

```
frontend  →  cartservice [ERROR]
                └── AddItem
                      └── Redis/Valkey GET/SET [ERROR]
                            error: "connection refused" or "backing store unavailable"
```

The error is in the deepest span — the actual data store call. This confirms:
- The `cartservice` receives the request successfully
- It fails when trying to interact with its persistence layer

**Compare to Incident 2:** In that incident, errors appeared on the *caller's* span (checkout → payment). Here, the error appears *inside* the service itself when it tries to reach its own backing store.

---

### 5. Infrastructure Check (Optional, 1 minute)

In New Relic's **Kubernetes Cluster Explorer**:
- Check the `cartservice` pod status
- Look for pod restarts or OOMKills
- Check if the Valkey/Redis pod is healthy

In a real-world scenario, the backing store pod being unhealthy would be visible here, alongside the APM errors.

---

## Summary: The 4-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Reproduce | Astronomy Shop | All cart actions fail immediately |
| Service triage | APM | `cartservice` 100% error rate on all operations |
| Error message | Errors Inbox | Backing store connectivity failure |
| Confirm | Distributed Tracing | Failure on Redis/Valkey span, not cartservice logic |
| Infrastructure | K8s Cluster Explorer | Pod health / backing store status |

**Total time to root cause: ~4 minutes**

---

## Key Takeaways

- **100% error rate on all operations = infrastructure dependency.** Partial failures on specific operations suggest logic bugs. Total failure across all operations points to a shared dependency (database, cache, external service).
- **Read the error message.** "Connection refused", "backing store unavailable", "transport error" — these are infrastructure signals, not application bugs.
- **Distributed tracing shows dependency depth.** The trace waterfall reveals which layer actually failed — the cart service logic vs. the Redis call vs. the network.
- **Cross-signal correlation.** APM errors + K8s pod health together paint the full picture of what failed and why.

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may be miss key details.

<!--
BETA NOTES — Incident 5 Golden Path

Improvements:
- Step 5 "Infrastructure Check" is misleading — the Valkey pod is healthy because this is a feature flag simulation; add: "In this simulation the pod will appear healthy — in a real incident you'd see pod failures here"
- Verify which error message actually appears in the lab ("rpc error: code = Unavailable" vs "Cart service failure simulated by feature flag") and remove the other
- Add a "What's Next" transition note pointing teams toward the debrief so the ending feels intentional
- Confirm Instruqt gates golden paths behind failure check completion (cartFailure flag name is a spoiler)

Gameday gotchas:
- Students who follow the K8s check step find a healthy pod and are confused; game managers need to know this ahead of time
- Demoralized teams from repeated wrong submissions need active encouragement — "hints are part of the process"
- Have 3–5 structured retrospective questions ready so game managers aren't improvising the debrief wrap-up
-->
