---
slug: mars-program-incident-1
id: hyun1dpgehs4
type: challenge
title: Incident 1
teaser: A critical service is experiencing performance issues
tabs:
- id: wcivltpnoqh8
  title: Check
  type: terminal
  hostname: k8s
  cmd: /tmp/generic_prompt
- id: wavjvto8acrz
  title: Shell
  type: terminal
  hostname: k8s
- id: dxornyimeuum
  title: Astronomy Shop
  type: service
  hostname: k8s
  path: /
  port: 30080
difficulty: basic
timelimit: 1800
enhanced_loading: null
---

# 🚨 Incident Alert: Checkout Service Performance Degradation

Your team has received an alert from New Relic indicating that the **Astronomy Shop** checkout service is experiencing degraded performance.
Customers are reporting slow checkout times, which is impacting revenue during a critical sales period.

## Your Mission

Use New Relic to investigate this incident and identify:

1. **Which service** is the root cause of the degradation?
2. **What type of issue** is affecting the service? (e.g., high latency, high error rate, resource exhaustion)
3. **What is the specific root cause** of the problem?

## Getting Started

1. Check the alert you will receive on Slack
2. Use New Relic APM, distributed tracing, and other observability tools to investigate
3. Once you've identified the answers, go to the **Check** terminal tab
4. Enter your answers in the following format (separated by semi-colons):
   ```
   service name; issue type; root cause
   ```
   **Example:** `productcatalogservice; high latency; database connection timeout`
5. Click the **Check** button to validate your answers
6. If incorrect, you can re-enter your answers in the terminal

## Important Notes

- ⏱️ You have **30 minutes** to resolve this incident
- 💡 If you're stuck after 15 minutes, ask your instructor for hints
- 🎯 Answer all questions correctly to automatically resolve the incident

Good luck! 🚀