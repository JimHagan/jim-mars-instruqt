---
slug: mars-incident-7-golden-path
id: c9vlmtk2rzxn
type: challenge
title: 'Incident 7: Golden Path'
teaser: How to diagnose CPU saturation using infrastructure and runtime metrics
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: true
---

# 🏆 Golden Path: Ad Service High CPU

## What Was Happening

The `adHighCpu` feature flag was enabled, spawning additional threads in the **Ad service** that performed CPU-intensive work (busy loops). This artificially saturated the available CPU for the ad service pod. With CPU saturated, the service becomes CPU throttled — it can still process requests, but everything takes longer as the CPU is starved for cycles.

---

## The Ideal Debugging Path

### 1. Check Workload: Resource Signal, Not Error Signal (30 seconds)

Open your New Relic Workload. Similar to the memory leak incident, you may not see error alerts firing. Instead, look for any service with elevated resource indicators.

**The challenge:** CPU saturation doesn't immediately produce errors. The service keeps working — just slowly. You need CPU metrics, not error metrics.

---

### 2. APM: Response Time Elevated, Errors Low (1 minute)

Go to **APM → adservice → Summary**.

You'd see:
- **Error rate**: ~0% or very low
- **Response time**: Significantly elevated — ad requests that used to take 10ms now take 100ms+
- **Throughput**: Normal (requests are still coming in and completing)

This pattern — normal error rate, elevated response time — is the **CPU throttling signature** in APM.

---

### 3. Infrastructure: The CPU Chart (2 minutes)

Go to **Infrastructure** and find the `adservice` pod/container.

Look at the **CPU Usage** metric:
```
CPU Usage (%)
     ^
100% |████████████████████████████████████
 80% |
 60% |
 40% |
 20% |                            (baseline)
     +------------------------------------> time
```

The CPU chart shows the pod pegged at or near its CPU limit. Now check if CPU **throttling** is occurring — most infrastructure tools show a "CPU throttled %" metric that confirms the pod is requesting more CPU than it's allowed.

**Why this matters:** CPU throttling is invisible in APM alone. A request that should take 10ms takes 80ms because it keeps getting paused by the kernel while waiting for CPU time. The request itself doesn't error — it just takes much longer.

---

### 4. Kubernetes: CPU Limit vs. Request (1 minute)

In the **Kubernetes Cluster Explorer**, find the `adservice` pod and look at:
- **CPU request**: The guaranteed CPU allocation
- **CPU limit**: The maximum CPU allowed
- **Current CPU usage**: Is it at or near the limit?

When usage bumps against the limit, Kubernetes starts throttling — pausing the process when it exceeds the limit and resuming it later. This causes latency spikes without errors.

---

### 5. Traces: CPU-Bound Spans (1 minute)

In **APM → adservice → Distributed Tracing**, open a slow trace.

You'd see spans with high duration that have:
- No downstream service calls (not waiting on I/O or network)
- Just CPU computation time
- No error status

```
frontend  →  adservice [SLOW, no errors]
                └── GetAds
                      duration: 250ms  ← pure CPU time, no I/O
```

This confirms it's CPU work, not network/IO waiting. A span blocked on I/O would show a different pattern (waiting on a database call, HTTP request, etc.).

---

## Summary: The 5-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Workload | Workload | No errors, elevated response time signal |
| APM | APM Summary | High response time, low error rate |
| CPU metrics | Infrastructure | CPU usage near 100% of limit |
| Throttling | K8s Cluster Explorer | CPU throttling % elevated |
| Trace analysis | Distributed Tracing | High-duration spans with no downstream calls |

**Total time to root cause: ~5 minutes**

---

## Key Takeaways

- **CPU saturation ≠ errors.** A CPU-bound service keeps working — just slowly. Error-based alerts alone will miss this. You need response time + CPU metric alerts.
- **CPU throttling is the hidden culprit.** Kubernetes enforces CPU limits by pausing processes. From the pod's perspective, requests just mysteriously take longer with no errors logged.
- **Latency without errors = resource constraint.** When you see high latency with near-zero errors, check CPU and memory before looking at application logic.
- **Trace spans with high duration and no child spans = pure CPU.** If a span is slow and has no downstream calls, the time is spent on computation — confirming CPU contention rather than I/O or network issues.
- **Set both CPU and memory alerts on all pods.** Resource saturation is as impactful as application errors but requires different alert conditions.

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may be miss key details.