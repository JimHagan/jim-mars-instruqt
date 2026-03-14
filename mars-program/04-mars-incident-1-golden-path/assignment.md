---
slug: mars-incident-1-golden-path
id: bdqxvmlvblxc
type: challenge
title: 'Incident 1: Golden Path'
teaser: How to debug a product catalog error spike like a pro
difficulty: ""
lab_config:
  custom_layout: '{"root":{"children":[{"leaf":{"tabs":["assignment"],"activeTabId":"assignment","size":100}}],"orientation":"Horizontal"}}'
enhanced_loading: true
---

# 🏆 Golden Path: Product Catalog Failure

## What Was Happening

The `productCatalogFailure` feature flag was enabled, causing the **Product Catalog service** to return errors for a specific product (`OLJCESPC7Z` — "Explorascope"). Any customer who tried to view or purchase that product received a 500 error from the product catalog service.

## Alerts For This Incident

![Product Catalog Failure Alerts](../assets/product-catalog-failure-alerts.png)


## Errors Inbox View
![Product Catalog Failure Inbox](../assets/product-catalog-failure-errors-inbox.png)
---

## The Ideal Debugging Path

### 1. Start with Your Workload (60 seconds)

Open your New Relic **Workload** and scan the health overview.
You'd see `product-catalog` in a degraded/red state with an elevated error rate.

Workloads give you a single-pane-of-glass view. Instead of checking each service individually, you immediately see which one is sick.  

However, you may find a lot of "sick" services.


---



### 2. (Option 1) Check APM & Tracing For Possible Root Cause (3 minutes)

Choose the product-catalog service as indicated.

Navigate to **APM & Services → distributed tracing**.

- Look at the spans in the error traces
- track them through to product-catalog
- Identify the impacted product either in the trace or jump into errors inbox for the product-service application.

**Drawbacks to This Approach:** If you don't have a real strong hunch as to what service to start with you may go down a few dark alleys with this one.

---

### 3. (Option 2) Open Errors Inbox For Workload (2 minutes)

Go to the `Errors Inbox` page *for the whole workload*.  Investigte new errors types that have recently cropped up.   From their you may drill into specific services.


You'd find a new error group for product-catalog with a group name like:
```
oteldemo.ProductCatalogService/GetProduct
```

These errors would show that error group message (as well as the otel.status_description) was 

```
Error: Product Catalog Fail Feature Flag Enabled
```

Click into the error group and:

- Look at the **Occurrences** tab and notice the same product ID appears in every single trace.
- Look at the **Profile** tab, and notice this is not random — it's a specific product

Inspect the errors attributes and you'll see:
- `app.product.id`: `OLJCESPC7Z`
- `otel.status_description`: `Error: Product Catalog Fail Feature Flag Enabled`

**Why Errors Inbox wins here:** It automatically groups similar errors and shows you frequency, so you immediately know "this error is happening a lot, not just once."  In addition you don't have to "guess" about which server to look at.  You can survey errors coming from all services in one pane of glass.

---



## Summary: The 3 to 5 Minute Debug

| Step | Tool | Finding |
|------|------|---------|
| Workload health | Workloads | multiple degraded services (including `product-catalog`)|
| Analyze Service With Critical Alert or Error Anomaly| APM & DT | `product-catalog` failure| 
| Use Errors Inbox (Whole Workload) for Broad Overview | drill into product related errors | Find impacted product `OLJCESPC7Z`  |

**Total time to root cause: ~5 minutes**

---

## Key Takeaways

- **Error rate ≠ latency issue.** Always check both metrics — they tell different stories.
- **Errors Inbox groups noise into signal.** Instead of reading raw logs, you get a ranked list of what's actually broken.
- **Span attributes are your evidence.** OpenTelemetry-instrumented services emit rich attributes — `app.product.id`, feature flag names — that pinpoint the exact cause.
- **Distributed traces connect the dots.** Even if the alert fires on `frontend`, following the trace shows you the real culprit is `product-catalog`.

## ⛔ Wait Before Continuing

**Wait** for your Game Manager's instructions before hitting _"Next"_ below.

Remember: **you want to have all info you can before triggering an incident**, otherwise you may miss key details.
