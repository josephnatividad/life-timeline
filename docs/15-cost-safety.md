# Cost Safety and Billing Policy

Status: Approved project constraint, 2026-08-18

## Objective

Life Timeline must not create an undisclosed or unapproved developer-side
charge. Development, build, test, release, and background execution must fail
closed rather than silently cross from free usage into paid usage.

"Free tier" is not a permanent cost guarantee. Provider prices, quotas, and
terms can change. Cost safety therefore requires both an architecture rule and
a repeatable configuration/release audit.

This policy covers:

- Cloud projects, APIs, OAuth applications, hosted services, storage, network
  egress, logs, analytics, crash reporting, AI inference, scheduled jobs, and
  third-party subscriptions.
- Direct dependencies and transitive SDKs that can make network calls or
  create metered resources.
- Foreground, background, retry, polling, synchronization, migration, test,
  preview, trial, and production usage.
- Charges paid by the developer or company. User-owned storage usage must also
  be disclosed clearly, even when it is not a developer charge.

## Non-negotiable rules

1. **No silent billing enablement.** Do not attach a billing account, accept a
   paid tier, activate a trial that converts to paid, request paid quota, or
   create a metered resource without explicit human approval.
2. **No API key implies spending authority.** An API key, OAuth client, cloud
   credential, Internet permission, or installed SDK authorizes only its
   documented purpose. It does not authorize paid use or use by another
   feature.
3. **Deny paid usage by default.** If a provider requires billing or a payment
   method for a proposed feature, stop and obtain approval before continuing.
4. **Prefer user-owned resources.** User-owned storage and direct-to-provider
   flows are preferred when they preserve privacy and avoid developer-hosted
   storage or transfer charges.
5. **Bound background work.** Background operations must be opt-in where the
   product requires it, event- or schedule-bounded, change-aware, and protected
   against unbounded retry, tight polling, duplicate scheduling, and a
   synchronized request surge.
6. **Fail closed at limits.** A quota/rate-limit failure must defer work and
   preserve local data. The app must not automatically purchase capacity,
   request a quota increase, switch to a paid provider, or discard data.
7. **Do not depend on budget alerts as a hard cap.** Standard Google Cloud
   budget alerts report spending but do not automatically stop usage. A budget
   alert alone does not satisfy this policy.
8. **Revalidate changing terms.** Pricing, free thresholds, scope
   classifications, and billing requirements must be checked against primary
   provider documentation before every public release and at least quarterly
   while a network service remains enabled.

## Approval gate for any potentially billable service

Before enabling a new service or changing an existing service's usage, record:

- Provider, product, API, environment, and responsible owner.
- Whether a billing account or payment method is attached.
- Current unit prices, free allowances, rate limits, egress rules, and the date
  and source used to verify them.
- Expected and worst-reasonable usage at 1,000, 10,000, and 100,000 monthly
  active users.
- Foreground and background triggers, retry limits, retention, and cleanup.
- Which party owns and pays for storage and transfer.
- Enforceable quotas or spend caps, alerts, operational monitoring, and a
  disable/rollback procedure.
- Privacy/data flow, SDK/network dependency audit, and whether a new or
  superseding ADR is required.
- Explicit human approval for any non-zero developer-funded recurring or
  usage-based cost.

No implementation should assume approval merely because the estimated amount
is small.

## Development and Google Cloud configuration

- Use a dedicated development project rather than a project that also hosts
  unrelated paid resources.
- Keep Cloud Billing detached when the approved APIs do not require it.
- Enable only explicitly approved APIs. Review the project's enabled-services
  list after setup and before release.
- Do not create service accounts, API keys, servers, buckets, databases,
  logging sinks, schedulers, or monitoring exports for Drive backup.
- Do not request a quota increase or opt into paid over-quota Drive usage.
- If billing later becomes unavoidable, stop. A separate decision must define
  a maximum accepted spend, provider-supported enforcement, alerts, ownership,
  and shutdown behavior before billing is attached.
- Treat ordinary billing budgets as alerts, not guarantees. Google explicitly
  states that alerts-only budgets do not cap usage or spending:
  <https://docs.cloud.google.com/billing/docs/how-to/budgets>.

## Google Drive automatic-backup cost boundary

The accepted Drive integration remains cost-safe by design:

- The feature is optional and off by default.
- Backups are encrypted locally and stored in each user's Google Drive
  `appDataFolder`; Life Timeline operates no backup server or developer-owned
  storage bucket.
- The only Drive scope is `drive.appdata`.
- The default schedule is weekly and Wi-Fi-only.
- A run is skipped when the timeline has not changed.
- Three verified generations are retained by default.
- A new generation is uploaded before best-effort removal of an older one.
- Routine upload verification uses size/checksum metadata rather than
  downloading the uploaded backup.
- Restore downloads occur only when the user requests a restoration.

As verified on 2026-08-18, Google states that standard Drive API use has no
additional cost. Google also states that usage above its standard thresholds
is planned to become billable later in 2026, with advance notice. This is why
the project must not treat today's free tier as a permanent promise:
<https://developers.google.com/workspace/drive/api/guides/limits>.

### Planning estimate for 10,000 monthly users

This estimate is a capacity guardrail, not a provider invoice forecast. It
assumes roughly 200 quota units for an established backup cycle: one upload,
one list operation, and one retention deletion. Actual quota accounting must
be confirmed in the provider dashboard.

| Scenario | Approximate backup jobs/day | Approximate quota units/day |
| --- | ---: | ---: |
| 10,000 users, all weekly | 1,430 | 286,000 |
| 10,000 users, all daily | 10,000 | 2,000,000 |
| Current standard daily threshold | — | 400,000,000 |

The daily scenario is approximately 0.5% of the documented standard daily
threshold. Monthly active users alone do not determine cost: backup size,
frequency, restore/download volume, request bursts, and future provider terms
also matter.

Google Drive hidden app data consumes the individual user's Google storage,
not developer-owned storage. The product must state that clearly when it
becomes relevant to the user:
<https://support.google.com/drive/answer/9312312>.

### Scale-readiness checks

Before a public or materially larger rollout:

- Recheck Drive pricing, quota-unit weights, per-minute limits, daily billing
  thresholds, and egress limits.
- Confirm Cloud Billing remains detached and paid over-quota use is not
  enabled.
- Inspect actual quota usage for development/test traffic.
- Verify bounded exponential backoff for `403`/`429` responses and that failed
  work cannot retry indefinitely.
- Verify scheduled work is sufficiently distributed or jittered to avoid a
  per-minute request spike.
- Model restore egress separately from routine uploads using representative
  encrypted-backup sizes.
- Retain a configuration or release mechanism that can disable automatic
  Drive backup without harming local timelines or manual backup/restore.

## Release cost audit

Every release that includes networking must confirm:

1. The enabled cloud APIs and attached billing state are expected.
2. No package or native SDK introduced analytics, advertising, telemetry,
   remote processing, paid logging, or another network destination.
3. No development trial, paid plan, quota increase, or auto-upgrade was
   enabled.
4. Background frequency, retry, retention, and cleanup remain bounded.
5. Provider pricing and quotas were rechecked and dated in release evidence.
6. The expected-use estimate remains below the free/standard boundary with a
   conservative margin.
7. Quota exhaustion produces an understandable deferred/failure state and
   never data loss or automatic paid fallback.
8. User-facing language distinguishes developer cost from use of the user's
   own storage or connectivity.

The network dependency audit remains in
`docs/research/NETWORK-DEPENDENCY-AUDIT.md`. Google Drive configuration is
documented in `docs/setup/GOOGLE-DRIVE-BACKUP-SETUP.md`.
