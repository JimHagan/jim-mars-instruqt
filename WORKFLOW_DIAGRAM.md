# M.A.R.S. Program - Workflow Diagrams

## Overall Game Day Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      GAME DAY STARTS                                │
│                 Instructor welcomes teams                           │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   CHALLENGE BEGINS                                   │
│  • Instruqt provisions environment (VM + K8s)                       │
│  • Track setup deploys OpenTelemetry Demo                           │
│  • Challenge setup-k8s enables feature flag                         │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                 INCIDENT TRIGGERED                                   │
│  • Feature flag causes service degradation                          │
│  • Alert fires in New Relic                                         │
│  • SLO error budget starts consuming                                │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│              TEAMS INVESTIGATE (0-15 min)                           │
│  • Open New Relic                                                   │
│  • Check alerts                                                     │
│  • Examine APM metrics                                              │
│  • Review distributed traces                                        │
│  • Analyze service dependencies                                     │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
                ┌─────────────────┐
                │  Stuck?         │
                └────┬────────┬───┘
                     │        │
              Yes ───┘        └─── No
                │                  │
                ▼                  ▼
┌───────────────────────────┐  ┌──────────────────────────────────┐
│ INSTRUCTOR PROVIDES HINTS │  │  TEAMS IDENTIFY ROOT CAUSE       │
│ • Level 1 (15 min)        │  │  • Service name                  │
│ • Level 2 (20 min)        │  │  • Issue type                    │
│ • Level 3 (25 min)        │  │  • Root cause                    │
└───────────┬───────────────┘  └──────────────┬───────────────────┘
            │                                  │
            └──────────────┬───────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  TEAMS SUBMIT ANSWERS                                │
│  $ submit-answers                                                   │
│  1. Which service? productcatalogservice                            │
│  2. What issue? high latency                                        │
│  3. Root cause? product catalog failure                             │
│  4. Bypass code? [empty or code]                                    │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│              TEAMS CLICK "CHECK" BUTTON                             │
│  Instruqt runs: check-k8s script                                    │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
                ┌─────────────────────┐
                │ Bypass code entered? │
                └─────┬───────────┬───┘
                      │           │
               Yes ───┘           └─── No
                  │                    │
                  ▼                    ▼
        ┌──────────────────┐    ┌──────────────────────┐
        │ BYPASS CODE      │    │ Within cooldown?     │
        │ Valid?           │    └──────┬───────────┬───┘
        └───┬──────────┬───┘           │           │
            │          │          Yes ─┘           └─ No
         Yes│          │No             │               │
            │          │               ▼               ▼
            │          │     ┌──────────────────┐ ┌──────────────────┐
            │          │     │ WAIT MESSAGE     │ │ VALIDATE ANSWERS │
            │          │     │ "Wait X seconds" │ │ Case-insensitive │
            │          │     └──────────────────┘ │ Check alternatives│
            │          │                          └───┬──────────┬───┘
            │          │                              │          │
            │          │                        All ──┘          └─ Some/None
            │          │                      Correct              Wrong
            │          │                         │                   │
            ▼          ▼                         ▼                   ▼
┌────────────────────────────┐       ┌────────────────────┐  ┌──────────────────┐
│  AUTO-RESOLVE INCIDENT     │       │   SUCCESS!         │  │   TRY AGAIN      │
│  • Disable feature flag    │◄──────┤   Disable flag     │  │   Wait 60s       │
│  • Record completion time  │       │   Record metrics   │  │   Review answers │
│  • Mark challenge complete │       │   Show feedback    │  └──────────────────┘
└────────────┬───────────────┘       └────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  CHALLENGE CLEANUP                                   │
│  • cleanup-k8s runs                                                 │
│  • Ensures flag disabled                                            │
│  • Removes state files                                              │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
                ┌─────────────────┐
                │  More challenges? │
                └────┬────────┬───┘
                     │        │
              Yes ───┘        └─── No
                │                  │
                │                  ▼
                │         ┌──────────────────┐
                │         │  GAME DAY ENDS   │
                │         │  • Debrief       │
                │         │  • Scoring       │
                │         │  • Celebrate! 🎉 │
                │         └──────────────────┘
                │
                └──► (Loop back to "CHALLENGE BEGINS")
```

## Challenge Lifecycle Detail

```
┌──────────────────────────────────────────────────────────────────────┐
│                         SETUP PHASE                                   │
│                                                                       │
│  setup-k8s script executes:                                          │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ 1. Wait for K8s cluster ready                                  │ │
│  │    └─ kubectl wait for pods                                    │ │
│  │                                                                 │ │
│  │ 2. Wait for OTel Demo deployed                                 │ │
│  │    └─ kubectl wait for opentelemetry-demo pods                 │ │
│  │                                                                 │ │
│  │ 3. Find feature flag service pod                               │ │
│  │    └─ kubectl get pods -l component=featureflagservice         │ │
│  │                                                                 │ │
│  │ 4. Enable failure feature flag                                 │ │
│  │    └─ kubectl exec curl POST featureflags API                  │ │
│  │       {"name": "productCatalogFailure", "enabled": true}       │ │
│  │                                                                 │ │
│  │ 5. Create state tracking files                                 │ │
│  │    ├─ /tmp/incident1_start_time = $(date +%s)                  │ │
│  │    ├─ /tmp/check_attempt_count = 0                             │ │
│  │    └─ /tmp/last_check_time = 0                                 │ │
│  │                                                                 │ │
│  │ 6. Start web server                                            │ │
│  │    └─ python3 -m http.server 8080 &                            │ │
│  │                                                                 │ │
│  │ 7. Install submit-answers command                              │ │
│  │    └─ cp submit_answers.sh /usr/local/bin/submit-answers       │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    INVESTIGATION PHASE                                │
│                                                                       │
│  Team's activities:                                                  │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ 1. Log in to New Relic                                         │ │
│  │                                                                 │ │
│  │ 2. Navigate to Astronomy Shop                                  │ │
│  │    └─ Find application in APM                                  │ │
│  │                                                                 │ │
│  │ 3. Check alerts                                                │ │
│  │    └─ See checkout service degradation alert                   │ │
│  │                                                                 │ │
│  │ 4. Examine service map                                         │ │
│  │    └─ Identify checkoutservice → productcatalogservice         │ │
│  │                                                                 │ │
│  │ 5. Review distributed traces                                   │ │
│  │    ├─ Find slow /checkout transactions                         │ │
│  │    ├─ Identify slow spans                                      │ │
│  │    └─ See time spent in productcatalog operations              │ │
│  │                                                                 │ │
│  │ 6. Analyze APM metrics                                         │ │
│  │    ├─ Response time increased                                  │ │
│  │    ├─ Throughput normal                                        │ │
│  │    └─ Error rate normal                                        │ │
│  │                                                                 │ │
│  │ 7. Form hypothesis                                             │ │
│  │    └─ Product catalog service has high latency                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     SUBMISSION PHASE                                  │
│                                                                       │
│  Team runs: submit-answers                                           │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Script prompts:                                                 │ │
│  │                                                                 │ │
│  │ Question 1: Which service is the root cause?                   │ │
│  │ > productcatalogservice                                        │ │
│  │                                                                 │ │
│  │ Question 2: What type of issue is affecting the service?       │ │
│  │ > high latency                                                 │ │
│  │                                                                 │ │
│  │ Question 3: What is the specific root cause?                   │ │
│  │ > product catalog failure                                      │ │
│  │                                                                 │ │
│  │ Bypass code (optional):                                        │ │
│  │ > [empty or MARS-OVERRIDE-2026]                                │ │
│  │                                                                 │ │
│  │ Creates: /tmp/incident1_answers.json                           │ │
│  │ {                                                               │ │
│  │   "service": "productcatalogservice",                          │ │
│  │   "issue_type": "high latency",                                │ │
│  │   "root_cause": "product catalog failure",                     │ │
│  │   "bypass": ""                                                 │ │
│  │ }                                                               │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     VALIDATION PHASE                                  │
│                                                                       │
│  Team clicks "Check" → Instruqt runs check-k8s                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ 1. Read current time                                           │ │
│  │    CURRENT_TIME=$(date +%s)                                    │ │
│  │                                                                 │ │
│  │ 2. Check for answer file                                       │ │
│  │    if [[ ! -f /tmp/incident1_answers.json ]]; then             │ │
│  │      fail "No answers submitted"                               │ │
│  │    fi                                                           │ │
│  │                                                                 │ │
│  │ 3. Parse answers from JSON                                     │ │
│  │    SERVICE=$(jq -r '.service' answers.json)                    │ │
│  │    ISSUE_TYPE=$(jq -r '.issue_type' answers.json)              │ │
│  │    ROOT_CAUSE=$(jq -r '.root_cause' answers.json)              │ │
│  │    BYPASS=$(jq -r '.bypass' answers.json)                      │ │
│  │                                                                 │ │
│  │ 4. Check bypass code first                                     │ │
│  │    if [[ "$BYPASS" == "MARS-OVERRIDE-2026" ]]; then            │ │
│  │      disable_flag()                                            │ │
│  │      success "Bypass code accepted"                            │ │
│  │    fi                                                           │ │
│  │                                                                 │ │
│  │ 5. Enforce cooldown                                            │ │
│  │    LAST_CHECK=$(cat /tmp/last_check_time)                      │ │
│  │    TIME_SINCE=$((CURRENT_TIME - LAST_CHECK))                   │ │
│  │    if [[ $TIME_SINCE -lt 60 ]]; then                           │ │
│  │      fail "Wait $((60 - TIME_SINCE)) seconds"                  │ │
│  │    fi                                                           │ │
│  │                                                                 │ │
│  │ 6. Update last check time                                      │ │
│  │    echo "$CURRENT_TIME" > /tmp/last_check_time                 │ │
│  │                                                                 │ │
│  │ 7. Validate each answer                                        │ │
│  │    SERVICE_CORRECT=false                                       │ │
│  │    if check_answer "$SERVICE" "productcatalogservice"; then    │ │
│  │      SERVICE_CORRECT=true                                      │ │
│  │    fi                                                           │ │
│  │    (repeat for issue_type and root_cause)                      │ │
│  │                                                                 │ │
│  │ 8. All correct?                                                │ │
│  │    if all_correct; then                                        │ │
│  │      disable_feature_flag()                                    │ │
│  │      record_completion_time()                                  │ │
│  │      success "Incident resolved!"                              │ │
│  │    else                                                         │ │
│  │      increment_attempt_count()                                 │ │
│  │      fail "Not all correct, try again"                         │ │
│  │    fi                                                           │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌──────────────────────────────────────────────────────────────────────┐
│                       CLEANUP PHASE                                   │
│                                                                       │
│  cleanup-k8s script executes:                                        │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ 1. Ensure feature flag disabled                                │ │
│  │    kubectl exec curl PUT {"enabled": false}                    │ │
│  │                                                                 │ │
│  │ 2. Stop web server                                             │ │
│  │    kill $(cat /tmp/webserver.pid)                              │ │
│  │                                                                 │ │
│  │ 3. Remove state files                                          │ │
│  │    rm /tmp/incident1_*                                         │ │
│  │    rm /tmp/check_*                                             │ │
│  │    rm /tmp/last_check_time                                     │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INSTRUQT ENVIRONMENT                              │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │ Kubernetes Cluster (k3s)                                       │ │
│  │                                                                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │ OpenTelemetry Demo (Astronomy Shop)                      │ │ │
│  │  │                                                           │ │ │
│  │  │  ┌─────────────┐    ┌──────────────┐   ┌──────────────┐ │ │ │
│  │  │  │  Frontend   │───▶│  Checkout    │──▶│   Product    │ │ │ │
│  │  │  │  Service    │    │  Service     │   │   Catalog    │ │ │ │
│  │  │  └─────────────┘    └──────────────┘   └──────────────┘ │ │ │
│  │  │         │                  │                    │         │ │ │
│  │  │         │                  │                    │         │ │ │
│  │  │         └──────────────────┴────────────────────┘         │ │ │
│  │  │                            │                              │ │ │
│  │  │                            ▼                              │ │ │
│  │  │                   ┌─────────────────┐                    │ │ │
│  │  │                   │  OTel Collector │                    │ │ │
│  │  │                   │  (OTLP export)  │                    │ │ │
│  │  │                   └────────┬────────┘                    │ │ │
│  │  └─────────────────────────────┼──────────────────────────────┘ │ │
│  │                                │                                │ │
│  │                                │ OTLP/gRPC                      │ │
│  │                                │                                │ │
│  └────────────────────────────────┼────────────────────────────────┘ │
│                                   │                                  │
└───────────────────────────────────┼──────────────────────────────────┘
                                    │
                                    │ Internet
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     NEW RELIC PLATFORM                               │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │ OTLP Ingest Endpoint                                           │ │
│  └───────────────┬───────────────────────────────────────────────┘ │
│                  │                                                  │
│                  ▼                                                  │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │ NRDB (Native OTLP storage)                                     │ │
│  │ • Traces                                                       │ │
│  │ • Metrics                                                      │ │
│  │ • Logs                                                         │ │
│  └───────────────┬───────────────────────────────────────────────┘ │
│                  │                                                  │
│                  ▼                                                  │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │ Platform Features                                              │ │
│  │ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │ │
│  │ │   APM    │ │  Traces  │ │   Logs   │ │  Alerts  │          │ │
│  │ └──────────┘ └──────────┘ └──────────┘ └──────────┘          │ │
│  │ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │ │
│  │ │   SLOs   │ │ Service  │ │Dashboard │ │Scorecard │          │ │
│  │ │          │ │   Map    │ │          │ │          │          │ │
│  │ └──────────┘ └──────────┘ └──────────┘ └──────────┘          │ │
│  └───────────────┬───────────────────────────────────────────────┘ │
│                  │                                                  │
└──────────────────┼──────────────────────────────────────────────────┘
                   │
                   │ Browser (HTTPS)
                   │
                   ▼
       ┌───────────────────────┐
       │   GAME DAY TEAM       │
       │                       │
       │  Investigates using:  │
       │  • APM                │
       │  • Distributed traces │
       │  • Service map        │
       │  • Alerts             │
       │  • Logs               │
       └───────────────────────┘
```

## State Management

```
/tmp/
├── incident1_start_time          # Unix timestamp of challenge start
│                                  # Used to calculate completion time
│
├── check_attempt_count           # Number of check attempts
│                                  # Incremented on each check
│                                  # Used for scoring
│
├── last_check_time               # Unix timestamp of last check
│                                  # Used to enforce 60s cooldown
│
├── incident1_answers.json        # Team's submitted answers
│   {                              # Created by submit-answers
│     "service": "...",            # Read by check-k8s
│     "issue_type": "...",
│     "root_cause": "...",
│     "bypass": "..."
│   }
│
└── webserver.pid                 # PID of Python HTTP server
                                   # Used to kill server on cleanup
```

## Instructor Decision Tree

```
                    Team requests help
                           │
                           ▼
              ┌────────────────────────┐
              │ How much time elapsed? │
              └────┬────────────┬──────┘
                   │            │
          < 15 min │            │ > 15 min
                   │            │
                   ▼            ▼
         ┌──────────────┐  ┌──────────────────┐
         │ Encourage    │  │ Where are they   │
         │ to continue  │  │ stuck?           │
         └──────────────┘  └────┬─────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
        ┌──────────────┐ ┌────────────┐ ┌────────────┐
        │ Haven't      │ │ Wrong      │ │ Technical  │
        │ started      │ │ direction  │ │ issue      │
        └──────┬───────┘ └──────┬─────┘ └──────┬─────┘
               │                │               │
               ▼                ▼               ▼
        ┌──────────────┐ ┌────────────┐ ┌────────────┐
        │ Give Hint    │ │ Give Hint  │ │ Give bypass│
        │ Level 1      │ │ Level 2    │ │ code       │
        └──────────────┘ └────────────┘ └────────────┘
                │                │               │
                ▼                ▼               ▼
           Wait 5 min       Wait 5 min      Continue
                │                │           to next
                ▼                ▼           challenge
        ┌──────────────┐ ┌────────────┐
        │ Still stuck? │ │ Still stuck│
        └──────┬───────┘ └──────┬─────┘
               │                │
            Yes│             Yes│
               ▼                ▼
        ┌──────────────┐ ┌────────────┐
        │ Give Hint    │ │ Give bypass│
        │ Level 2      │ │ code       │
        └──────────────┘ └────────────┘
               │
               ▼
        At 30 min mark:
        Give bypass code
        to all teams
```
