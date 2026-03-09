---
slug: mars-incident-9-golden-path
id: j8mzvqk5pxtn
type: challenge
title: 'Incident 9: Golden Path'
teaser: How to diagnose Kubernetes readiness probe failures using K8s signals and APM
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---

# 🏆 Golden Path: Failed Readiness Probe

## What Was Happening

The `failedReadinessProbe` feature flag was enabled, causing the **Cart service** to fail its Kubernetes **readiness probe**. A readiness probe is a periodic health check Kubernetes uses to decide whether a pod should receive traffic. When the probe fails, Kubernetes removes the pod from the service's endpoint list — traffic stops being routed to it. If there's only one cart service pod, the service becomes effectively unavailable.

**This is a Kubernetes-layer incident, not an application-layer incident.** The application code may be running fine — the issue is in the health check signaling.

---

## The Ideal Debugging Path

### 1. APM: Unusual Traffic Pattern (1 minute)

Go to **APM → cartservice → Summary**.

You'd see something unusual:
- **Throughput**: Drops suddenly to near-zero (no requests reaching the pod)
- **Error rate**: May be 0% — because no requests are reaching it at all
- **Upstream impact**: The `frontend` service shows errors when trying to call cartservice (503 Service Unavailable)

**The signal:** Throughput dropping to zero without a deployment is a Kubernetes routing problem. Either the pod is gone or it's been taken out of rotation.

---

### 2. Kubernetes Cluster Explorer: The Root Cause (2 minutes)

Navigate to **Kubernetes** (Cluster Explorer) in New Relic:

1. Select the `opentelemetry-demo` namespace
2. Find the `cartservice` pod
3. Look at pod **status**: you'd see it flagged as `Not Ready` (yellow/red indicator)
4. Open the pod details and look at **Events**:

```
LAST SEEN   TYPE      REASON      OBJECT          MESSAGE
30s         Warning   Unhealthy   Pod/cartservice Readiness probe failed:
                                                  HTTP probe failed with
                                                  statuscode: 500
10s         Warning   Unhealthy   Pod/cartservice Readiness probe failed: ...
```

**The events tell the whole story:** Kubernetes is running the readiness probe, the probe is returning a non-2xx status code, and Kubernetes has flagged the pod as NotReady.

---

### 3. Understand the Mechanism (30 seconds)

In Kubernetes, when a pod's readiness probe fails:
1. The pod stays **running** (the container isn't killed like with a liveness probe failure)
2. The pod's IP is **removed** from the Service's endpoint list
3. New requests to the Service are **not routed** to this pod
4. The pod remains in `NotReady` state until the probe starts passing again

**Readiness vs. Liveness:**
- **Readiness probe**: "Am I ready to serve traffic?" — failure removes pod from rotation
- **Liveness probe**: "Am I alive?" — failure causes pod restart

This distinction is important for diagnosis. NotReady + no restart = readiness probe failure.

---

### 4. Correlate with Frontend (1 minute)

In **APM → frontend → Distributed Tracing**, look for traces that fail when calling cartservice:

```
frontend  →  [503 Service Unavailable]
                └── Attempted to call cartservice
                      error: "connection refused" or "upstream connect error"
```

The frontend's error spans confirm that the request never reached cartservice — it was rejected at the Kubernetes service layer before reaching the pod.

---

### 5. Verify Pod Count (30 seconds)

In the Kubernetes Cluster Explorer, check the Deployment:
- **Desired replicas**: 1
- **Ready replicas**: 0 (or N-1 if multiple replicas)
- **Available**: 0

If `Ready` < `Desired`, Kubernetes is reporting the shortfall — a definitive indicator of a probe failure or pod crash.

---

## Summary: The 4-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| APM traffic | APM Summary | cartservice throughput = 0 (not routed to) |
| Frontend errors | APM / Distributed Tracing | 503 errors calling cartservice |
| Pod status | K8s Cluster Explorer | Pod = `Not Ready` |
| K8s Events | K8s Events | "Readiness probe failed" events |
| Deployment health | K8s Deployment | Ready replicas = 0 |

**Total time to root cause: ~4 minutes**

---

## Key Takeaways

- **Kubernetes signals are first-class observability.** APM alone shows "no traffic" — which could mean many things. K8s events give you the exact reason: `Readiness probe failed`.
- **NotReady ≠ OOMKilled ≠ CrashLoopBackOff.** Each has a different root cause. K8s events disambiguate: probe failures are readiness/liveness issues; OOMKill is memory; CrashLoopBackOff is application crashes.
- **Zero throughput without deployment = K8s routing change.** When traffic suddenly drops to zero without anyone pushing code, look at pod health before looking at application code.
- **Readiness probes protect users.** The fact that Kubernetes stopped routing traffic is the system working as intended — preventing a degraded pod from serving users. The probe failure is the symptom; the question is why the probe is failing.
- **Monitor pod readiness as a metric.** Alert on `k8s.pod.ready = 0` for critical services. Don't wait for users to report errors — catch pod readiness failures before they cause full outages.

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may be miss key details.