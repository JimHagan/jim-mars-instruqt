---
slug: mars-incident-8-failure
id: g3nxmvq6ptbz
type: challenge
title: 'Incident 8: Failure'
teaser: Order processing is falling behind — Kafka consumers can't keep up
tabs:
- id: k6mxqn8vtzbl
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: s9wfpm5kzxnq
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: ""
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Message Queue Overload — Order Processing Delayed

**Severity:** P2 — Data Pipeline Degradation
**Impact:** Order confirmation emails and downstream order processing are severely delayed due to Kafka consumer lag

Your team is paged. The Astronomy Shop is accepting orders successfully, but the **downstream processing** of those orders is falling behind. Customers are completing checkouts but not receiving order confirmations. The Kafka queue is backing up.

## 🎯 Your Mission

Use New Relic to investigate and identify:

1. **Which service/system** is experiencing the queue problems?
2. **What type of issue** is affecting it?
3. **What is the root cause** of the problem?

## 🔍 Investigation Guide

### Step 1: Observe the Symptom
Open the **Astronomy Shop** tab and complete a purchase:
1. Place an order — does the checkout succeed?
2. Does the order confirmation appear quickly, or is there a long delay?
3. Check if order-related downstream actions seem delayed

### Step 2: Check APM for the Accounting/Order Service
1. Go to **APM & Services** in New Relic
2. Look for services that consume Kafka messages (e.g., `accountingservice`, `frauddetectionservice`)
3. Check their **response time** and **throughput** — are consumers processing normally?

### Step 3: Look for Messaging Metrics
1. In New Relic, search for **Kafka** metrics in your account
2. Look for **consumer lag** metrics — this measures how far behind consumers are
3. Key metrics to find:
   - `kafka.consumer_group.lag` — the number of unconsumed messages
   - `messaging.kafka.consumer.lag` (OpenTelemetry)
4. Is the lag growing, stable, or shrinking?

### Step 4: Distributed Tracing — Trace the Message Gap
1. Go to **APM → accountingservice → Distributed Tracing**
2. Look for traces that span from a **producer** to a **consumer**
3. In the trace waterfall, look for the gap between:
   - `messaging.publish.timestamp` (when was the message sent?)
   - The start of the consumer's processing span (when was it actually processed?)
4. This gap represents the **queue wait time** — how long was the message sitting in Kafka?

### Step 5: Identify Root Cause
Based on your investigation:
- Is consumer lag growing continuously (producer faster than consumer)?
- Which service is consuming from Kafka, and is it keeping up?
- What would cause a Kafka queue to overflow? (too many messages, too slow consumers, or both?)

## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter:

```
service name; issue type; root cause
```

**Example:** `kafka; consumer lag; kafka queue problems`

**Format hints:**
- Service name: what system is affected? (e.g., `kafka` or `accountingservice`)
- Issue type: what kind of problem? (e.g., `consumer lag`)
- Root cause: what is causing it? (e.g., `kafka queue problems`)

Click **Check** to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- This incident affects **asynchronous processing** — the shop frontend may look fine
- If stuck after 15 minutes, ask your Game Manager for a hint 🚀
