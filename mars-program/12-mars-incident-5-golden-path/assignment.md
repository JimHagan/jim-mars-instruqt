---
slug: mars-incident-5-golden-path
id: lqpd1qss7gfr
type: challenge
title: 'Incident 5: Golden Path'
teaser: How to detect and diagnose a memory leak using infrastructure and runtime metrics
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---

# 🏆 Golden Path: Recommendation Cache Memory Leak

## What Was Happening

The `recommendationCacheFailure` feature flag was enabled, causing the **Recommendation service** to use an exponentially growing in-memory cache with no eviction policy. Every product recommendation request added more items to the cache but nothing was ever removed. Memory grew continuously until the pod would eventually be killed by Kubernetes (OOMKilled) and restart, only to begin the cycle again.

---

## The Ideal Debugging Path

### 1. Check Workload: No Obvious Errors (30 seconds)

Open your New Relic Workload. You might notice `recommendationservice` with elevated resource usage, but *no error rate spike*. This is a resource exhaustion incident, not an error incident.

**Key insight:** Error-based alerts won't catch this until the pod crashes and restarts. You need **resource metric alerts** (memory thresholds) to catch memory leaks early.

---

### 2. APM: Response Time Creeping Up (1 minute)

Go to **APM → recommendationservice → Summary**.

You'd observe:
- **Error rate**: ~0% (the service is still functioning — for now)
- **Response time**: Gradually increasing over time as the cache grows and memory pressure mounts
- **Throughput**: Normal

The response time trend is an early warning before the service fails completely.

---

### 3. Infrastructure Metrics: The Smoking Gun (2 minutes)

Go to **Infrastructure** or use the **Kubernetes Cluster Explorer** in New Relic.

Find the `recommendationservice` pod and look at its **memory usage** over time:

```
Memory Usage (MB)
    ^
300 |                                    ●
250 |                             ●
200 |                       ●
150 |                 ●
100 |           ●
 50 |     ●
    |●
    +-------------------------------------> time
```

A continuous, near-linear rise in memory is the signature of a **memory leak**. Compare this to normal services which hold steady or show GC sawtooth patterns.

**Why Infrastructure first matters here:** APM error rates are zero. Without infrastructure/runtime metrics, you'd have no signal that anything is wrong — until the pod crashes.

---

### 4. Runtime Metrics: Confirm with JVM/Process Metrics (1 minute)

In **APM → recommendationservice**, look for **Runtime** metrics (if available for the language):
- `process.runtime.*.memory.usage` — continuously growing heap
- GC frequency metrics — the garbage collector running more and more frequently trying (and failing) to reclaim memory

**The pattern:** Memory growing + GC running more frequently + GC unable to reclaim = classic unbounded cache / memory leak.

---

### 5. Traces: Look for Cache Behavior (2 minutes)

In **APM → Distributed Tracing**, inspect recommendation request spans.

Look for span attributes like:
- `app.recommendations.cache.size` — if present, you'd see this number growing with each request
- `app.recommendations.count` — high counts from cache

You might also see span duration increasing over time as cache lookups through ever-larger data structures take longer.

---

### 6. Confirm: OOMKill History (optional)

In the **Kubernetes Cluster Explorer**:
- Check the `recommendationservice` pod's **restart count** — if the pod has crashed before, you'll see restarts here
- Look at pod **events** for `OOMKilled` reasons in the events tab

This confirms the cycle: memory leak → OOMKill → pod restart → leak starts again.

---

## Summary: The 5-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Workload | Workload | No errors, but elevated resource usage |
| APM trend | APM Summary | Response time slowly increasing |
| Memory trend | Infrastructure / K8s | Continuous linear memory growth |
| Runtime metrics | APM Runtime | Heap growing, GC unable to reclaim |
| Trace attributes | Distributed Tracing | Cache size attribute growing per request |
| History | K8s Events | Prior OOMKill restarts |

**Total time to root cause: ~5 minutes**

---

## Key Takeaways

- **Memory leaks are silent killers.** They produce no errors until the service crashes. By then, you've already had downtime. Alert on memory growth trends, not just error rates.
- **Resource metrics are a separate signal from APM.** Error rate = 0 doesn't mean healthy. Always monitor CPU, memory, and GC metrics alongside error rate and latency.
- **Sawtooth = GC at work. Linear growth = leak.** A healthy service shows memory rise and fall as GC kicks in. A continuous straight line upward is a classic memory leak signature.
- **Proactive alerting saves SLOs.** A `memory > 80% of limit` alert would have fired before the pod crashed, giving the team time to investigate without an outage.
- **Look at restart counts.** High restart counts in K8s often indicate OOMKills — a historical record of memory exhaustion that APM alone wouldn't show you.

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may be miss key details.