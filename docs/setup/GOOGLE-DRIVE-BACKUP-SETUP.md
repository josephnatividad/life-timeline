# Google Drive Backup: Google Cloud and OAuth Setup

Last verified: 2026-08-18

## Purpose and scope

This guide configures the approved direct Google Drive automatic-backup path
for the Life Timeline Flutter application. It covers Google Cloud project
creation, Drive API enablement, OAuth consent, Android and Web OAuth clients,
and passing the Web client ID to the app from Android Studio.

This setup does not create a Life Timeline account, backend, service account,
developer-owned storage bucket, or cloud processing path. The app requests
only `drive.appdata` and uploads locally encrypted LTBACK01 backup artifacts to
the connected user's hidden Drive application-data folder.

Follow `docs/15-cost-safety.md`: do not attach Cloud Billing, accept paid
over-quota usage, or enable another API as part of this procedure. If Google
requires billing or a payment method at any step, stop and review the current
provider terms before proceeding.

## Values for the current Android development build

| Setting | Development value |
| --- | --- |
| Android application ID | `com.lifetimeline.life_timeline` |
| Android debug SHA-1 | `3B:0D:7F:08:BB:0E:64:EE:FB:CD:68:68:92:DD:91:A8:ED:42:F1:F4` |
| Requested Drive scope | `https://www.googleapis.com/auth/drive.appdata` |
| Web OAuth client ID | `325497920230-3k8bguvdv096cd6o1iinuda5v3nf639m.apps.googleusercontent.com` |
| Dart define | `LIFE_TIMELINE_GOOGLE_SERVER_CLIENT_ID` |

An OAuth client ID is a public application identifier, not a password. Never
commit or place a Web client **secret**, access token, refresh token, recovery
password, or user credential in the application or repository.

## 1. Create a dedicated Google Cloud project

1. Open <https://console.cloud.google.com/>.
2. Open the project selector and choose **New Project**.
3. Use a clear environment-specific name such as
   `Life Timeline Development`.
4. Create and select the project.
5. Open **Billing** and confirm that no Cloud Billing account is linked.

Use separate development and production projects so test credentials, users,
quotas, and future production approval cannot be confused. Creating the
production project is a separate release activity.

## 2. Enable only the Google Drive API

1. Open **APIs & Services** → **Library**.
2. Search for **Google Drive API**.
3. Open it and select **Enable**.
4. Open **APIs & Services** → **Enabled APIs & services** and review the list.

Do not create an API key. A normal API key cannot authorize private user Drive
access. Do not enable Firebase, Cloud Storage, Cloud Functions, Cloud Run,
Vertex AI, logging exports, or another service for this backup integration.

Google's current Drive limits and pricing are documented at:
<https://developers.google.com/workspace/drive/api/guides/limits>.

## 3. Configure Google Auth Platform

The current Cloud Console groups OAuth settings under **Google Auth
Platform**.

### Branding

1. Open **Google Auth Platform** → **Branding**.
2. Set the application name to the approved current display name. `Life
   Timeline` remains a working name, not a confirmed final brand.
3. Set the user-support email and developer-contact email.
4. Save the configuration.

Production publication may require verified domains, a public home page, a
privacy policy, and brand verification. Do not invent production URLs during
development.

### Audience and test users

1. Open **Google Auth Platform** → **Audience**.
2. Choose **External** unless use is restricted to one managed Google
   Workspace organization.
3. Keep the development project in **Testing**.
4. Add every Google account that will test Drive backup on an emulator or
   device under **Test users**.

Testing-mode authorization can expire according to Google's current OAuth
policy. Do not diagnose that expiry as lost backup data; reconnect the Drive
destination and re-authorize. Current audience documentation:
<https://support.google.com/cloud/answer/15549945>.

### Data access

1. Open **Google Auth Platform** → **Data Access**.
2. Choose **Add or remove scopes**.
3. Add this exact scope:

   ```text
   https://www.googleapis.com/auth/drive.appdata
   ```

4. Save the scope configuration.

Do not add `drive`, `drive.readonly`, `drive.file`, Gmail, Contacts, Calendar,
or another scope. Google documents `drive.appdata` as the narrow scope for an
app's own hidden Drive data:
<https://developers.google.com/workspace/drive/api/guides/appdata>.

## 4. Create the Android OAuth client

1. Open **Google Auth Platform** → **Clients**.
2. Select **Create Client**.
3. Choose **Android** as the application type.
4. Use an environment-specific name such as
   `Life Timeline Android Debug`.
5. Enter the development application ID:

   ```text
   com.lifetimeline.life_timeline
   ```

6. Enter the development SHA-1:

   ```text
   3B:0D:7F:08:BB:0E:64:EE:FB:CD:68:68:92:DD:91:A8:ED:42:F1:F4
   ```

7. Create the client.

The Android client is matched automatically using application ID and signing
certificate. Its client ID is not passed through the Dart define.

To recheck fingerprints after a signing change, run from
`apps/mobile/android`:

```powershell
.\gradlew.bat signingReport
```

The production signing certificate will have a different SHA-1. A public
Google Play build must register the Play App Signing certificate SHA-1 in a
production Android OAuth client. Never rely on the debug certificate for a
release.

## 5. Create the Web OAuth client

The Flutter Google Sign-In integration uses a Web client ID as its
`serverClientId` on Android when this project does not apply the Firebase
Google Services Gradle plugin.

1. Return to **Google Auth Platform** → **Clients**.
2. Select **Create Client**.
3. Choose **Web application**.
4. Use a name such as `Life Timeline Android Server Client`.
5. Leave JavaScript origins and redirect URLs empty for this native app
   integration.
6. Create the client.
7. Copy the client ID ending in `.apps.googleusercontent.com`.

The approved current development Web client ID is:

```text
325497920230-3k8bguvdv096cd6o1iinuda5v3nf639m.apps.googleusercontent.com
```

Do not copy the Web client secret into Android Studio or Flutter. Native apps
cannot protect a client secret.

## 6. Pass the Web client ID from Android Studio

1. Open the Flutter project in Android Studio.
2. Choose **Run** → **Edit Configurations**.
3. Select the Flutter configuration that launches `lib/main.dart`.
4. In **Additional run args**, enter this as one line:

   ```text
   --dart-define=LIFE_TIMELINE_GOOGLE_SERVER_CLIENT_ID=325497920230-3k8bguvdv096cd6o1iinuda5v3nf639m.apps.googleusercontent.com
   ```

5. Select **Apply**, then **OK**.
6. Stop the existing app process completely and run the configuration again.

Hot reload and hot restart cannot add a compile-time Dart define to an
already-built application. Do a new run/build after changing the value.

The equivalent command from `apps/mobile` is:

```powershell
fvm flutter run --dart-define=LIFE_TIMELINE_GOOGLE_SERVER_CLIENT_ID=325497920230-3k8bguvdv096cd6o1iinuda5v3nf639m.apps.googleusercontent.com
```

## 7. Verify the development connection

1. Confirm the device or emulator has a Google account that is listed as a
   test user.
2. Launch the newly rebuilt app.
3. Open **You** → **Backup & Recovery** → **Automatic Backup**.
4. Select **Connect Google Drive**.
5. Select the intended Google account and review the consent request.
6. Confirm the UI reports the connected account.
7. Configure a recovery password and run **Back up now**.
8. Confirm the app reports a verified backup and records the last-success
   state.

Drive `appDataFolder` is intentionally hidden from the normal My Drive file
list. Not seeing the backup in My Drive is expected and must not be interpreted
as an upload failure. The application's verified backup state is the primary
development check.

## Troubleshooting

### "Google Drive backup is not configured for this app build"

- Confirm the selected Android Studio Flutter run configuration contains the
  complete `--dart-define` argument.
- Stop and rebuild rather than using hot restart.

### Authorization closes, is canceled, or reports a developer/configuration error

- Confirm Android and Web OAuth clients belong to the same Google Cloud
  project.
- Confirm the application ID exactly matches
  `com.lifetimeline.life_timeline`.
- Re-run `signingReport` and compare the installed build's SHA-1 with the
  Android OAuth client.
- Confirm the Dart define contains the **Web** client ID, not the Android
  client ID.
- Confirm the Google account is present under **Audience** → **Test users**.
- Confirm Google Drive API is enabled and `drive.appdata` is configured.

### Authorization worked and later requires reconnection

- Check whether the OAuth project remains in Testing and whether the test
  authorization expired.
- Reconnect the same account. Do not delete local records or remote backup
  generations as a sign-in troubleshooting step.

## Production and iOS follow-up

Production rollout requires a separate review before changing this
development setup:

- Confirm the final app name, support details, privacy policy, and consent
  branding.
- Create production OAuth clients in the approved production project.
- Register the release/Play App Signing SHA-1, not the debug SHA-1.
- Recheck Drive pricing, quotas, verification requirements, and billing state.
- Keep the scope restricted to `drive.appdata`.
- Perform the release network/dependency audit documented in
  `docs/research/NETWORK-DEPENDENCY-AUDIT.md`.

iOS additionally requires an iOS OAuth client for the final bundle identifier,
the matching reversed-client-ID URL scheme in Xcode, and the
`LIFE_TIMELINE_GOOGLE_IOS_CLIENT_ID` Dart define. Final iOS configuration must
be verified on macOS and is not completed by the Android client setup above.

## Cost-safety verification

At the end of setup and before every release:

1. Confirm no Cloud Billing account is attached to the development project.
2. Confirm no API key, service account, cloud runtime, storage bucket, or
   scheduled cloud job was created.
3. Review enabled APIs and investigate anything beyond the approved Drive/OAuth
   support services.
4. Confirm no paid quota increase or paid over-quota use was requested.
5. Record the date current Drive pricing and quota documentation was checked.
6. Follow `docs/15-cost-safety.md` if provider requirements or prices changed.
