---
slug: mars-incident-8-golden-path
id: d7qwpkn9zvrx
type: challenge
title: 'Incident 8: Golden Path'
teaser: How to diagnose Kafka consumer lag using messaging metrics and trace gaps
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: null
---

# 🏆 Golden Path: Kafka Queue Problems

## What Was Happening

The `kafkaQueueProblems` feature flag was enabled with a 10x multiplier, causing the load generator to flood the Kafka topic with 10x the normal message volume. The consumer services (like `accountingservice` and `frauddetectionservice`) process messages at a fixed rate — they could not keep up with the influx of messages. Consumer lag grew continuously as messages piled up faster than they could be consumed.

**The sneaky part:** The Astronomy Shop frontend looked completely fine. Orders were accepted successfully. Only the asynchronous downstream processing (order confirmations, fraud checks, accounting records) was falling behind — invisible to users until delays became very long.

---

## The Ideal Debugging Path

### 1. Identify the Symptom Source (1 minute)

This incident is different — the user-facing frontend shows no errors. Start by checking:
- **Checkout flow**: Orders complete successfully
- **Downstream signals**: Are order confirmation emails delayed? Is accounting data stale?

If your alerts are set up correctly, a **Kafka consumer lag alert** would have fired — pointing directly at the queue, not the application services.

**Key insight:** Async pipeline failures are invisible to error rate monitors. You need **consumer lag metrics** as explicit alert conditions.

---

### 2. Kafka Consumer Lag Metrics (2 minutes)

In New Relic, use **NRQL** to query Kafka consumer lag:

```sql
SELECT latest(kafka.consumer_group.lag) as 'Consumer Lag'
FROM Metric
WHERE kafka.topic IS NOT NULL
FACET kafka.topic, kafka.consumer_group
SINCE 30 minutes ago
TIMESERIES
```

You'd see a chart where consumer lag is **growing linearly** rather than staying near zero:

```
Consumer Lag (messages)
     ^
5000 |                                    ●
4000 |                            ●
3000 |                    ●
2000 |            ●
1000 |    ●
   0 |●
     +------------------------------------> time
```

A growing lag means producers are outrunning consumers. A flat non-zero lag means consumers are processing at the same rate as producers but can't catch up.

---

### 3. Distributed Tracing: The Message Gap (2 minutes)

In **APM → accountingservice → Distributed Tracing**, look for traces that include messaging spans.

Open a trace and look at the waterfall. You'd see a distinctive pattern:

```
[Load Generator] — publish message → Kafka
                                           ←— 45 second gap —→
                                                                [accountingservice] — process message
```

The gap between `messaging.publish.timestamp` and the consumer span's start time represents **time the message spent waiting in the queue**. During the incident, this gap grows from milliseconds to minutes.

**NRQL to find message wait time:**

```sql
SELECT average(messaging.kafka.message.lag) as 'Message Wait Time (ms)'
FROM Span
WHERE service.name = 'accountingservice'
  AND span.kind = 'consumer'
SINCE 30 minutes ago
TIMESERIES
```

---

### 4. Identify the Imbalance (1 minute)

Compare producer throughput vs. consumer throughput:

```sql
SELECT rate(count(*), 1 minute) as 'Messages/min'
FROM Span
WHERE messaging.system = 'kafka'
FACET span.kind
SINCE 30 minutes ago
TIMESERIES
```

With `kafkaQueueProblems` at 10x, you'd see:
- **Producer**: 10x normal message rate
- **Consumer**: Processing at normal rate (1x)
- **Result**: 9x more messages arriving than being consumed → growing lag

---

## Summary: The 5-Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Frontend check | Astronomy Shop | Frontend fine, async processing delayed |
| Alert | Consumer lag alert | Kafka lag growing (if alert configured) |
| Kafka metrics | NRQL | Consumer lag growing linearly |
| Trace gap | Distributed Tracing | Minutes between publish and consume timestamps |
| Imbalance | NRQL | Producer rate 10x higher than consumer rate |

**Total time to root cause: ~5 minutes**

---

## Key Takeaways

- **Async failures are invisible to synchronous monitoring.** A healthy frontend with broken backend processing is one of the hardest incidents to detect without explicit queue metrics.
- **Consumer lag is the key metric.** Growing lag = consumers falling behind. Zero lag = healthy. You need this as an alert condition on all Kafka consumer groups.
- **Trace timestamps reveal queue wait time.** The gap between `messaging.publish.timestamp` and the consumer span start time is the actual queue latency — invisible without distributed tracing across async boundaries.
- **Monitor both sides of the queue.** Alert on consumer lag, producer throughput, and consumer throughput separately — the imbalance between producer and consumer rates tells you which side is the problem.
- **Synthetic transactions for async flows.** Consider using synthetic monitors to test end-to-end async flows (order → confirmation received) to catch delays before users notice.
