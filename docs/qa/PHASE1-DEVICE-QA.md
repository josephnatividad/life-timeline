# Phase 1 Device QA

Status: required manual validation for the release-candidate audit

Use a fresh checklist for every device/build. Never use real identity documents
or irreplaceable photos. Create synthetic sensitive values and keep an external
copy of every test backup/archive.

## Run record

- [ ] Platform: Android / iOS
- [ ] Device and model:
- [ ] OS version and security patch:
- [ ] Build version/hash:
- [ ] Install type: fresh / upgrade from version:
- [ ] Tester and date:
- [ ] Overall result: PASS / FAIL / BLOCKED
- [ ] Notes and evidence location:

Priority means release impact: P0 protects data/privacy/security, P1 validates
core behavior, and P2 covers quality/accessibility. Repeat platform-neutral
cases on both Android and iOS unless marked otherwise.

## P0 - backup and restore semantics

- [ ] Create a dataset containing exact, month, year, approximate, range,
  before, after, and unknown dates; active/archived/trashed memories; entities;
  relationships; evidence; 1/10/50-photo memories; hero/order/captions; archive
  references; candidates/provenance; reminders; and every privacy class.
- [ ] Create an encrypted backup, verify the system destination chooser appears,
  and confirm cancellation leaves no misleading success state.
- [ ] On a fresh install, restore with only the backup and recovery password;
  compare IDs, counts, temporal precision, relationships, media ordering/hero,
  captions, privacy, checksums, reminders, archive references, candidates,
  search results, Ask results, and Story eligibility.
- [ ] Select the backup from device storage and at least one Android/iOS document
  provider. Selection must show local inspection progress, advance to the
  recovery-password screen, and show a retryable error rather than silently
  disabling the page when the provider cannot supply the document.
- [ ] Restore over existing data; confirm replacement warning, immediate screen
  refresh, no restart requirement, correct notification reconciliation, and no
  mixture of old/new timeline rows.
- [ ] Enter a wrong password; existing data and managed files remain unchanged.
- [ ] Try truncated and byte-modified backups; authentication fails safely and
  existing data remains unchanged.
- [ ] Test missing/corrupt attachment payloads and an invalid manifest; restore
  stops before replacement and reports non-destructive failure.
- [ ] Simulate process termination, backgrounding, provider cancellation, and
  low storage during create/decrypt/stage/commit; after restart, the previous
  timeline is usable and no new partial generation is referenced.
- [ ] Restore the oldest supported real backup and reject a synthetically newer
  unsupported format/database before mutation.
- [ ] Verify temporary decrypted ZIP/database/attachments are not visible after
  success or handled failure; record any OS-termination residue.

## P0 - privacy and security

- [ ] Lock the app, background it on sensitive content, and inspect recent-app
  snapshots. Timeline content must be covered on Android and iOS.
- [ ] With immediate and delayed lock policies, background/foreground before and
  after the threshold; verify killed-process startup is locked.
- [ ] Verify notification content for synthetic passport number, booking code,
  serial number, address, OCR text, and `neverShare` fields remains generic.
- [ ] Tap a reminder notification while locked; authenticate, reach the intended
  destination, and use Back to return to Timeline without exiting or bypassing
  the lock.
- [ ] Attempt every Story template with address, passport, booking, serial,
  receipt, personal photo, exact travel dates, share-safe fields, and protected
  evidence media. `neverShare` cannot export; sensitive/personal inclusion
  follows explicit-sharing policy; evidence is never ordinary Story media.
- [ ] Perform OCR in airplane mode. Confirm capture, candidate editing, linking,
  and confirmation work without internet.
- [ ] Inspect release-build network traffic before/during/after OCR on Android and
  iOS. Record all DNS/connections and compare with Google's ML Kit disclosures.
  Do not mark external-release privacy approved until the P0 owner decision is
  closed.
- [ ] Confirm Android release manifest lacks `INTERNET` and
  `ACCESS_NETWORK_STATE`; do not use a debug manifest for this assertion.
- [ ] Verify PIN enrollment, 4-12 digit bounds, persisted retry throttling,
  successful reset of retry state, and no PIN/recovery password in screenshots,
  clipboard, logs, or crash output.

## P0 - archive and file safety

- [ ] Archive a managed original to every supported local/provider destination;
  verify encrypted output before enabling local-original removal.
- [ ] Cancel/fail archive export and corrupt the saved archive; the local
  original remains and metadata never claims a verified archive.
- [ ] Remove a local original only after verification; Timeline and preview still
  work when the archive is unavailable.
- [ ] Reconnect, authenticate, retrieve, and verify encrypted/original checksums;
  wrong password/corruption must not create a referenced partial original.
- [ ] Reorder/delete/permanently delete mixed local, referenced, thumbnail,
  evidence, and archive-protected files. Only unreferenced app-owned files may be
  removed; user-selected external files are never deleted.

## P1 - upgrades, lifecycle, and reminders

- [ ] Upgrade real installed databases from each available historical app build
  in sequence to current. Validate memories, relationships, evidence, media,
  archive/trash, candidates, reminders, FTS/search, and foreign-key integrity.
- [ ] Exercise Active -> Archive -> Restore, Active -> Trash -> Restore, and
  Active -> Trash -> Permanent Delete. Search, Ask, Insights, Stories, reminders,
  relationships, media, evidence, and archive references must follow policy with
  no stale normal-surface leakage.
- [ ] Create/edit/disable/re-enable reminders with notifications granted, denied,
  later granted, and permanently denied. Database state and platform schedules
  reconcile after restart.
- [ ] Verify reminders while the app is foregrounded, backgrounded, minimized,
  terminated, after device reboot, and across timezone/manual-clock changes.
  Cover Android OEM battery restrictions and iOS Focus/notification settings.
- [ ] Tap an elapsed notification. The reminder becomes Opened, not automatically
  completed; task completion remains an explicit action.
- [ ] Trash and permanently delete linked memories; their reminders cannot remain
  scheduled. Restore must not silently re-enable a previously disabled reminder.
- [ ] Confirm restored reminders are rescheduled only when valid and permitted;
  missed/expired entries display the documented state.

## P1 - biometrics and interruption recovery

- [ ] Test fingerprint, supported face authentication, PIN fallback, user cancel,
  failed match, temporary/permanent lockout, no enrollment, enrollment added or
  removed after enabling, sensor unavailable, and device restart.
- [ ] Verify the settings control reflects actual strong/device-supported
  biometric capability; face unlock that is not exposed by the OS biometric API
  must not be falsely advertised.
- [ ] Background/kill during camera selection, OCR preparation/native recognition,
  candidate persistence, media optimization, thumbnail generation, Story render,
  backup, restore, archive, and archive retrieval. Resume/restart must expose no
  corrupt row and no referenced partial file.
- [ ] Force low storage during photo import, thumbnail generation, OCR temporary
  copy, Story render, backup, restore, and archive retrieval. Retry after freeing
  space; existing records remain usable.

## P1 - media, OCR, and core offline operation

- [ ] Test 1, 10, and 50 mixed-size/orientation/color-profile photos. Validate
  Timeline, Memory Detail, Gallery, viewer, reorder, hero changes, archive, and
  Story selection without crashes or visible original-resolution eager loading.
- [ ] Test OCR with no text, blur, 90/180/270-degree rotation, huge input, dark
  input, unsupported/corrupt format, camera cancellation, and denied permissions.
  No corrupt candidate or consumed complimentary action may result; manual entry
  remains available.
- [ ] Complete OCR -> Candidate -> Edit -> Link existing entity -> Confirm and
  Candidate -> Ignore. Force a failure during confirmation and verify there is no
  partial timeline memory/relationship/provenance.
- [ ] In airplane mode exercise Timeline, Add/Edit, Search, Memory Inbox, Ask,
  Insights, Stories, reminders, Storage Manager, local archive, backup, and
  restore. Record any unexpected network prompt or unavailable core action.

## P2 - UI, accessibility, and performance

- [ ] Review every major route in light/dark mode and portrait/landscape where
  supported: contrast, overlays, photos, fields, dialogs, sheets, destructive
  actions, Ask, Stories, Storage, Inbox, security, backup, and reminders.
- [ ] Navigate into every detail/editor from all entry points. App bars use
  `AppIcons`, nested routes expose a usable Back action, top-level shell routes do
  not show a misleading Back action, and system Back never unexpectedly exits.
- [ ] Test system text scales from default through the platform maximum. Content
  remains reachable; no clipped critical labels, controls, dialogs, or sheets.
- [ ] Use TalkBack/VoiceOver end-to-end. Verify reading order, route names, image
  descriptions, field errors, status semantics independent of color, privacy
  badges, destructive confirmations, timeline connectors, and notification flow.
- [ ] Verify interactive targets are at least the official tokenized target size
  and remain operable with switch/keyboard navigation where supported.
- [ ] Enable Reduce Motion/remove animations. Screen, sheet, list, Story, and
  loading transitions use the documented fallback without losing state feedback.
- [ ] On a minimum-spec supported device, profile cold/warm startup and Timeline,
  search, Ask, Insights, detail, Gallery, and database operations at approximately
  100, 1,000, and 10,000 memories. Record duration, frame jank, peak memory, and
  database size; pay particular attention to full Timeline materialization.

## Platform completion

### Android

- [ ] Test minimum supported API, one current API, and at least one OEM-modified
  Android build.
- [ ] Inspect merged debug and release manifests; explain every permission.
- [ ] Verify system picker destinations, reboot rescheduling, exact-alarm behavior,
  background restrictions, recent-app privacy cover, and APK install/upgrade.
- [ ] Result: PASS / FAIL / BLOCKED
- [ ] Notes:

### iOS

- [ ] Build on supported macOS/Xcode with the pinned Flutter version and resolve
  native package dependencies from a clean checkout.
- [ ] Test minimum deployment target and a current iOS release on physical devices.
- [ ] Verify photo/camera permissions, file import/export providers, Face ID/Touch
  ID fallback, notifications, Focus behavior, task-switcher privacy cover, secure
  storage across upgrade/reinstall expectations, and app interruption.
- [ ] Perform the OCR traffic/privacy check; there is no Android-style network
  permission barrier.
- [ ] Result: PASS / FAIL / BLOCKED
- [ ] Notes:
