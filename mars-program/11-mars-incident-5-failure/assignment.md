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
2. **What backing data store** does it depend on? (Try service maps and workloads)
3. **What customer action** is completely blocked?

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
Add any product to your cart — what happens?
- Analyze any error messages that arise?



## 📝 Submit Your Answers

Once you've identified the root cause, go to the **Check** terminal and enter your answers:

**Answer Format:**

```
failing service; backing store; blocked customer action
```

**Example:** `checkoutservice; PostgreSQL; place order`

**Format hints:**
- Paste the name of the failiing service: use the exact name as it appears in New Relic (e.g., `checkoutservice`)
- Backing store: what data store does the cart service depend on? (service maps and workloads can help)
- Blocked customer action: what can customers NOT do? (e.g., `place order`)

Click the **Check** button to validate. You can re-enter if incorrect.

## ⏱️ Notes

- You have **30 minutes** for this incident
- If stuck after 15 minutes, ask your Game Manager for a hint
- Your SLO burn rate is ticking — move fast! 🚀

<!--

## Gotchas to Watch in Beta Testing

- The backing store name is the trickiest answer in the track. In OTel
  spans, the `db.system` attribute will say "redis" (lowercase) even
  if the actual software is Valkey. The error messages in Application
  logs/traces may say "Valkey" or "Redis" inconsistently. Run through
  the actual lab environment and confirm exactly what text appears, then
  align the check script and the format hint.

- "Blocked customer action" as a free-text field will produce enormous
  answer variety: "add to cart", "add items to cart", "adding to cart",
  "cart", "shopping cart", "checkout" (incorrect but plausible).
  The check script needs comprehensive normalization here.

- Students who've seen all previous incidents know the golden path
  pattern by now and may rush through without reading carefully. The
  most common mistake will be reporting "cartservice; Redis; add to
  cart" when the accepted answer may be "cartservice; Valkey; add to
  cart" — a difference of one word. Watch for submissions that are
  95% correct and ensure the check script gives targeted error messages
  (e.g., "check the backing store name").

- The infrastructure check (K8s Cluster Explorer) mentioned in the
  golden path is a natural place students might go — but since this is
  a feature flag simulation, the actual Valkey pod will appear healthy.
  Students who go to K8s first will find nothing wrong there and may
  be confused. Game managers should know this in advance.

- End-of-day logistics: after Incident 5, teams move into debrief. Game
  managers should have a clear plan for transitioning from the final
  golden path to the wrap-up session without dead time.
=============================================================================
-->
