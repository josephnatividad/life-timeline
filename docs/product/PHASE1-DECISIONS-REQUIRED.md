# Phase 1 Decisions Required

Status: product/privacy-owner input required before external release

This register contains only choices that cannot be settled safely as technical
stabilization. PDDs, accepted ADRs, and `AGENTS.md` remain authoritative until a
decision is accepted and incorporated into them.

## P0 - OCR SDK metrics and the no-analytics promise

**Decision**

Can a release containing OCR use Google ML Kit under the project's unqualified
no-analytics promise?

**Current behavior**

Life Timeline performs OCR inference on-device, has no application-authored
network client in this feature, does not log OCR content, and does not send
personal timeline data from application code. Google nevertheless states that
ML Kit SDKs send performance/utilization metrics and documents collection of
technical identifiers, diagnostics, configuration, API usage, and errors.
Android release removes `INTERNET` and `ACCESS_NETWORK_STATE` permissions at the
OS boundary; iOS has no equivalent manifest network gate. Airplane-mode success
proves offline operation, not absence of a later SDK metrics upload.

**Options**

1. Replace ML Kit with an audited local OCR engine that has no telemetry path.
2. Temporarily exclude OCR from external builds/platforms that lack a verified
   network barrier, while retaining manual memory entry.
3. Approve ML Kit metrics, revise the privacy promise/PDD, and make the required
   store and in-app disclosures after legal/privacy review.

**Recommendation**

Choose option 1 for the long-term product. Option 2 is the lowest-risk bridge
if an Android-only internal evaluation is needed. Do not silently choose option
3 during stabilization.

**Impact**

Blocks external release and `READY FOR INTERNAL RC` while OCR is enabled under
the current promise. It does not invalidate local-only core timeline QA.

References: [ML Kit terms](https://developers.google.com/ml-kit/terms),
[Android disclosure](https://developers.google.com/ml-kit/android-data-disclosure),
[Apple disclosure](https://developers.google.com/ml-kit/ios-data-disclosure).

## P1 release administration - final identity and signing ownership

**Decision**

Approve the final customer-facing app name, Android application ID, Apple bundle
ID, signing owners, and release key/certificate custody.

**Current behavior**

"Life Timeline" is the working name. The Android project still contains a
placeholder-style application ID and debug signing for release configuration;
the iOS identifier is likewise provisional. "Aevyra" remains only a discarded
visual-reference placeholder.

**Options**

1. Approve final identifiers now and assign secure signing ownership.
2. Keep identifiers provisional for device QA and internal engineering builds.

**Recommendation**

Use option 2 for this audit, then decide option 1 before any store/TestFlight or
externally distributed signed release. Changing identifiers later creates new
app identities and can break update/secure-storage continuity.

**Impact**

Does not block local device QA. Blocks public distribution and production
release signing.

## P2 - ignored Memory Inbox candidate retention

**Decision**

Define how long ignored candidates and their evidence/media should remain and
whether users require an explicit permanent-delete action.

**Current behavior**

Ignore is reversible. The candidate and its evidence/managed attachment remain
local and are included according to current backup policy. No automatic purge is
performed, which avoids silent loss but may retain sensitive scans indefinitely.

**Options**

1. Keep ignored candidates until explicit user deletion and add a future
   deletion/retention control.
2. Apply a documented time-based purge after warning and recovery period.
3. Make Ignore destructive immediately.

**Recommendation**

Choose option 1. It matches the current reversible lifecycle and data-loss
principles; schedule the explicit deletion control as a separately designed
feature. Do not add an automatic purge during the feature freeze.

**Impact**

Does not block technical stabilization or device QA. It must be disclosed and
approved before claiming complete user control over retained OCR artifacts.

## DEFERRED - accept the current Phase 1 entity/evidence surface

**Decision**

Confirm that Phase 1 may ship its current entity, relationship, and evidence
foundations without the visually referenced full Entity Detail/management and
general manual-evidence workflows.

**Current behavior**

Domain models, persistence, linking, search context, OCR evidence, and targeted
relationship flows exist. A complete entity-management surface and general
manual-evidence workflow do not. The roadmap originally treated much of the
current intelligence, Story, storage, and archive work as later phases, so it no
longer describes the implemented vertical slices accurately.

**Options**

1. Accept the existing surface as the frozen Phase 1 scope and realign the
   roadmap after the release audit.
2. Reopen feature development to require full entity/evidence management before
   release.

**Recommendation**

Choose option 1. Option 2 contradicts the current feature freeze and is not
needed to stabilize existing user data paths.

**Impact**

Does not block device QA. It determines release wording and the next roadmap,
not database compatibility.
